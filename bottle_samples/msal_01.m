% msal_01: read in the bottle salinities from digitized autosal log(s)
% and save to sal_cruise_01.nc and sam_cruise_01.nc
%
% Use: msal_01 
%
%   uses gsw: salinity = gsw_SP_salinometer((runavg+offset)/2, cellT);
%
% the input files must include a column or field "sampnum" which takes the
% form
% sampnum = 100*statnum + position
%     where statnum is the station and position the niskin position 
%     ([1 24] or [1 36])
%     for ctd samples,
% sampnum = -yyyymmddhhmm
%     for tsg samples,
% and
% sampnum = 999NNN
%     for standards, where NNN increments sequentially as the standards
%     were run
%     (998NNN, 990NNN, etc. may be used for sub-standards)
% 

m_common
mdocshow(mfilename, ['loads bottle salinities from the file(s) specified in opt_' mcruise ' and writes ctd samples to sal_' mcruise '_01.nc and sam_' mcruise '_all.nc, and underway samples to tsg_' mcruise '_01.nc']);

std_samp_range = [1e5 1e7]; %sample numbers for ssw are in this range, e.g. 999000, 999001, etc.
%ctd sampnums are <1e5, and tsg sampnums are either <0 or larger than 1e7

% resolve root directories for various file types, and set output files
root_sal = mgetdir('M_BOT_SAL');
dataname = ['sal_' mcruise '_01'];
salfile = fullfile(mgetdir('M_CTD'), [dataname '.nc']);
samfile = fullfile(mgetdir('M_CTD'), ['sam_' mcruise '_all.nc']);
scriptname = 'ship'; oopt = 'ship_data_sys_names'; get_cropt
tsgfile = fullfile(mgetdir(tsgpre), ['tsg_' mcruise '_all.nc']);

%get list of files to load
scriptname = mfilename; oopt = 'salfiles'; get_cropt %list of files to load

%initialise with expected fields
ds_sal = dataset;
fn0 = {'sampnum' 'runtime' 'sample_1' 'sample_2' 'sample_3' 'runavg' 'cellt' 'k15' 'flag' 'salinity' 'salinity_adj'}; 
un0 = {'number' 'datenum' '2Rt' '2Rt' '2Rt' '2Rt' 'degC' '2Rt' 'woce_9.4' 'psu' 'psu'};

%load files and store expected fields
ld = 0;
for fno = 1:length(salfiles)
    try
        [ds, hs] = m_load_samin(fullfile(root_sal, salfiles{fno}), {'sampnum'});
    catch me
        warning(me.message)
        warning('moving on to next file')
        continue
    end
    ii = find(isnan(ds.sampnum)); ds(ii,:) = [];
    %change field names if necessary, for instance, sample1 to sample_1, etc.
    scriptname = mfilename; oopt = 'salnames'; get_cropt 
    fn = ds.Properties.VarNames;
    ns = size(ds,1);
    iid = ld+[1:ns]';
    a0 = zeros(ns,1);

    ds_sal.sampnum(iid,1) = ds.sampnum;

    if sum(strcmp('runtime',fn))
        ds_sal.runtime(iid,1) = ds.runtime; %***assume datenum already?
    elseif sum(strcmp('date',fn)) & sum(strcmp('time',fn))
        tim = datevec(ds.time,'HH:MM:SS'); 
        dat = datevec(ds.date,'dd/mm/yyyy'); 
        dv = [dat(:,1:3) tim(:,4:6)];
        ds_sal.runtime(iid,1) = datenum(dv);
    else
        ds_sal.runtime(iid,1) = NaN+a0;
    end
    
    snamep = mvarname_find({'sample1' 'sample_1' 'reading1' 'reading_1' 'r1'},fn);
    if isempty(snamep)
        error(['unknown name for sample data in file ' salfiles{fno}])
    else
        snamep = snamep(1:end-1);
        for sno = 1:3
            sname = sprintf('sample_%d',sno);
            sname0 = sprintf([snamep '%d'],sno);
            d = ds.(sname0);
            d(d<-990) = NaN;
            ds_sal.(sname)(iid,1) = d;
        end
    end
    
    if sum(strcmp('k15',fn))
        ds_sal.k15(iid,1) = ds.k15;
    else
        ds_sal.k15(iid,1) = NaN+a0;
    end
    
    if sum(strcmp('cellt',fn))
        ds_sal.cellt(iid,1) = ds.cellt;
    else
        ii1 = strfind(hs.header,'Bath Temp'); ii2 = strfind(hs.header, ',');
        ii2 = ii2(ii2>ii1);
        t = hs.header(ii2(1):ii2(2)); te = [];
        for tno = 1:length(t)
            if ~isempty(str2num(t(tno))); te = [te t(tno)]; end
        end
        te = str2num(te);
        if ~isempty(te)
            ds_sal.cellt(iid,1) = te+a0;
        end
    end
    
    if sum(strcmp('flag',fn))
        ds_sal.flag(iid,1) = ds.flag;
    else
        ds_sal.flag(iid,1) = 2+a0;
    end
    
    if sum(strcmp('comment',fn))
        ds_sal.comment(iid,1) = ds.comment;
    else
        ds_sal.comment(iid,1) = repmat(' ',size(a0));
    end

    ld = ld+ns;
end

if isempty(ds_sal)
    error('no data loaded')
end

if sum(~isnan(ds_sal.cellt))==0; ds_sal.cellt = []; end
if sum(~isnan(ds_sal.k15))==0; ds_sal.k15 = []; end
ds_sal.runavg = m_nanmean([ds_sal.sample_1 ds_sal.sample_2 ds_sal.sample_3],2);

scriptname = mfilename; oopt = 'salflags'; get_cropt %run this both before and after msal_standardise_avg, in case new onees are added

%check for offsets in cruise options, if not found, run
%msal_standardise_avg to set them. also set things like cellt, k15 here
scriptname = mfilename; oopt = 'sal_off'; get_cropt
if isempty(sal_adj_comment)==0 & ~isempty(sal_off)
    sal_adj_comment = ['Adjustments specified in opt_' mcruise];
end
if isempty(sal_off)
    %ds_sal = msal_standardise_avg(ds_sal); %***currently broken; working
    %on, but not needed for jc211
    %sal_adj_comment = ['Adjustments calculated by msal_standardise_avg'];
    sal_adj_comment = 'no standards adjustment';
elseif length(sal_off)==1
    ds_sal.sal_off = repmat(sal_off, size(ds_sal.sampnum));
elseif length(sal_off)==length(ds_sal.sampnum)
    ds_sal.sal_off = sal_off;
else
    iistd = find(ds_sal.sampnum>=9e4 & ds_sal.sampnum<1e7);
    iis = setdiff(1:length(ds_sal.sampnum),iistd);
    switch sal_off_base
        case 'sampnum_run' %offsets given using standards sampnums; interpolate between them using runtime or order
            dt = ds_sal.runtime(iis)'-ds_sal.runtime(iistd);
            dt(dt<0) = NaN; [dt1,ii1] = min(dt);
            dt = ds_sal.runtime(iis)'-ds_sal.runtime(iistd);
            dt(dt>0) = NaN; [dt2,ii2] = max(dt); dt2 = -dt2;
            iiw = find(min(dt1,dt2)>1/24 | max(dt1,dt2)>3/24); %***
            warning(sprintf('%s\n','these samples are not near any standard; if a standard was not run','on either side of each crate, sampnum_run may not be the best method: '));
            disp(ds_sal.sampnum(iiw))
            [c,ia,ib] = intersect(sal_off(:,1),ds_sal.sampnum);
            ds_sal.sal_off = NaN+zeros(size(ds_sal.sampnum));
            ds_sal.sal_off(ib) = sal_off(ia,2);
            if sum(strcmp('runtime',ds_sal.Properties.VarNames))
                ds_sal.sal_off(iis) = interp1(ds_sal.runtime(iistd),ds_sal.sal_off(iistd),ds_sal.runtime(iis));
            else
                ds_sal.sal_off(iis) = interp1(iistd,ds_sal.sal_off(iistd),iis); %***
            end
        case 'sampnum_list' %offsets given using sample sampnums
            ds_sal.sal_off(iis) = sal_off; %***
        case 'statnum' %offsets given using lists of statnums***what about tsg
            %***
    end
end

%apply offsets (and plot?)***
ds_sal.salinity = gsw_SP_salinometer(ds_sal.runavg/2, ds_sal.cellt); %changed on JC103 in rapid branch, after JR16002 in JCR branch
if ~isempty(sal_off)
    ds_sal.salinity_adj = gsw_SP_salinometer((ds_sal.runavg+ds_sal.sal_off)/2, ds_sal.cellt);
    ds_sal.flag(isnan(ds_sal.salinity_adj) & ds_sal.flag<4) = 4;
elseif isfield(ds_sal, 'salinity_adj')
    ds_sal.salinity_adj = [];
end

%***average at what stage? 
scriptname = mfilename; oopt = 'salflags'; get_cropt

%which 
fn = ds_sal.Properties.VarNames;
d = struct('junk',0); clear h
h.fldnam = {}; h.fldunt = {};
for no = 1:length(fn0)
    if sum(strcmp(fn0{no},fn))
        d.(fn0{no}) = ds_sal.(fn0{no});
        h.fldnam = [h.fldnam fn0{no}];
        h.fldunt = [h.fldunt un0{no}];
    end
end
d = rmfield(d,'junk');

%write all to sal_ file
hc = h;
hc.comment = ['salinity data from ; ' sal_adj_comment]; %***hc.comment
mfsave(salfile, d, hc);

%write some fields for CTD samples to sam_ file
clear dsc
iic = find(d.sampnum>0 & d.sampnum<900*100);
% dsc = d(iic,:);
% bak: jc211 20 feb 2021 the line above doesnt work because d is a structure. Here is a longhand
% way fo doing what seems to be intended
fnd = fieldnames(d);
for no = 1:length(fnd)
    dsc.(fnd{no}) = d.(fnd{no})(iic,:);
end
clear hnew
hnew.fldnam = {'sampnum' 'botpsal' 'botpsal_flag'};
hnew.fldunt = {'number' 'psu' 'woce_9.4'}; %***
hnew.comment = ['salinity data from sal_' mcruise '_01.nc. ' sal_adj_comment];
ds = mloadq(samfile, 'sampnum', ' ');
[~,isam,isal] = intersect(ds.sampnum,dsc.sampnum);
ds.botpsal = NaN+ds.sampnum; ds.botpsal_flag = 9+zeros(size(ds.sampnum));
if isfield(dsc, 'salinity_adj')
    ds.botpsal(isam) = dsc.salinity_adj(isal);
else
    ds.botpsal(isam) = dsc.salinity(isal);
end
ds.botpsal_flag(isam) = dsc.flag(isal);
mfsave(samfile, ds, hnew, '-merge', 'sampnum');

if exist('tsgpre', 'dir') && ~isempty(tsgfiles)
    %get TSG samples, figure out event numbers
    %either negative, dddhhmmss (where ddd is year-day starting at 1), or yyyyhhmmss
    iiu = find(d.sampnum<0 | d.sampnum>=1e7);
    if length(iiu)>0
        
        fnd = fieldnames(d);
        for no = 1:length(fnd)
            dsu.(fnd{no}) = d.(fnd{no})(iiu,:);
        end
        
        scriptname = mfilename; oopt = 'tsgsampnum'; get_cropt
        [c,ia,ib] = intersect(dsu.sampnum,tsg.sampnum);
        dsu.time = NaN+dsu.sampnum;
        dsu.time(ia) = 86400*(tsg.dnum(ib)-datenum(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN));
        if sum(isnan(dsu.time))>0
            warning('missing times for tsg samples:')
            disp(dsu.sampnum(isnan(dsu.time)))
            keyboard
        end
        hu = h;
        hu.fldnam = [hu.fldnam 'time'];
        hu.fldunt = [hu.fldunt 'seconds'];
        hu.comment = hc.comment;
        mfsave(tsgfile, dsu, hu);
    
    end 
end
