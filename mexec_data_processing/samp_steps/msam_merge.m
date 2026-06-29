function msam_merge(samtyp)
%
% msam_merge(samtyp)
%
% follow-on to msam_load: load the sample (Niskin bottle or SBE35) data
% from specific type of file (e.g. sal, nut, oxy), convert (e.g. to
% umol/kg) and average replicates as necessary, paste into combined
% sam_mcruise_all.nc file
%
% which variables to use and conversions to apply are specified by
% switch-case on paramtype, below, can can be modified in the opt_cruise
% file
%
% called by samp_process.m

m_common
samcfile = fullfile(mgetdir('M_CTD'), ['sam_' mcruise '_all.nc']);
samufile = fullfile(mgetdir('M_BOT'), ['ucsw_' mcruise '_all.nc']); %save underway data here
samusrcfile = fullfile(mgetdir('M_TSG'), ['surface_ocean_' mcruise '_all.nc']);
if MEXEC_G.quiet<1; fprintf(1, 'loading bottle %s from %s_%s_01.nc, saving to %s and %s',samtyp,samtyp,samcfile,samufile); end

%defaults
dataname = [samtyp '_' mcruise '_01'];
pointfile = fullfile(mgetdir('bot'),[dataname '.nc']); %input file
svars = {'sampnum','niskin_flag'}; %variables to load from sample file (already matched to Niskin firings)
uvars = {'dday','flow'}; %variables to load from underway time series file (and interpolate)
pvars = 1; %1 to save all variables from paramfile to sam*file, otherwise list specific variables (using names after convs.rename has been applied)
%modify defaults
switch samtyp
    case 'chl'
        hnew.comment = ['chlorophyll data from ' dataname '.nc'];
        uvars = [uvars, 'fluo'];
    case 'oxy'
        %rename for backwards compatibility?***
        convs.umol_per_l_to_per_kg.temp = 'botoxy_temp'; %convert using oxygen draw temperature from each sample if recorded
        svars = [svars, 'uasal'];
        pvars = {'botoxy','botoxy_temp','botoxy_flag'};
        hnew.comment = ['oxygen data from ' dataname '.nc'];
        opt1 = 'samp_proc'; opt2 = 'oxy_to_sam'; get_cropt %could set to not avg, or could set to not convert units if they were already reported in /kg
        %losing backwards compatibility to make an appended oxy file
        %first***
    case 'nut'
        convs.umol_per_l_to_per_kg.temp = 20; %convert using default lab temperature***
        svars = [svars, 'uasal'];
        uvars = [uvars, 'salinity']; %***
        opt1 = 'samp_proc'; opt2 = 'nut_to_sam'; get_cropt %could set to not avg, or change the lab temp***
        hnew.comment = ['nutrient data from ' dataname '.nc']; %***overwrite comment or add comment?
    case 'sal'
%        convs.rename = {'botpsal', {'salinity_adj','salinity'};... %by
%        default this should be in mexec_defaults samp_proc parse as
%        varmap***
%            'botpsal_flag', {'flag'}}; %backwards compatibility
        pvars = {'botpsal','botpsal_flag'};
        uvars = [uvars, 'salinity'];
        hnew.comment = ['salinity data from ' dataname '.nc'];
    case 'sbe35'
        pointfile = fullfile(mgetdir('M_SBE35'), dataname);
        pvars = {'sbe35temp'; 'sbe35temp_flag'}; %list which to copy because we don't need to copy tdiff etc.***
        hnew.comment = ['SBE35 data from ' dataname '.nc'];
    case 'iso'
        %***just default?
    otherwise
end

%load data saved by msam_load in pointfile, along with CTD/underway
%parameters required to convert from samcfile and samusrcfile 
[dp, hp] = mloadq(pointfile, '/');
if sum(dp.sampnum>0 & dp.sampnum<1e6)
    %there are CTD samples
    [dc, hc] = mloadq(samcfile, strjoin(svars, ' ')); %***
    [dp, hp] = merge_mvars(dp, hp, dc, hc, 'sampnum', 1);
end
if sum(dp.sampnum<0 | dp.sampnum>1e9)
    %there are underway samples; interpolate from surface_ocean file
    [du, hu] = mloadq(samusrcfile, strjoin(uvars, ' '));
    dnum = m_commontime(du,'dday',hu,'datenum');
    sampnump = str2num(datestr(dnum,'yyyymmddHHMM'));
    sampnumn = -floor(du.dday)*1e4 - str2num(datestr(dnum,'HHMM'));
    flds = setdiff(uvars, {'dday','times'});
    for no = 1:length(flds)
        m = dp.sampnum>1e9;
        dp.(flds{no})(m) = interp1(sampnump,du.(flds{no}),dp.sampnum(m));
        m = dp.sampnum<0;
        dp.(flds{no})(m) = interp1(sampnumn,du.(flds{no}),dp.sampnum(m));
        m = strcmp(flds{no},hu.fldnam);
        hp.fldnam = [hp.fldnam flds{no}];
        hp.fldunt = [hp.fldunt hu.fldunt{m}];
    end
end

%turn into table, add units, and rename variables if specified
dp = struct2table(dp);
dp.Properties.VariableUnits = hp.fldunt;
opt1 = 'samp_proc'; opt2 = 'parse'; get_cropt %for backwards compatibility, do renaming here as well as in msam_load?***
if exist('varmap','var')
    dp = var_renamer(dp, varmap, 'keep_othervars', keepothervars);
end
hnew.comment = '';

%convert parameter sample data e.g. from umol_per_l to umol_per_kg, as
%specified in convs  
[dp, hnew] = samp_units_conv(dp, hnew, convs);
%***what about underway data?

if iscell(pvars)
    %drop variables we don't need
    mdel = ismember(dp.Properties.VariableNames, [pvars 'sampnum niskin_flag']); %***uway flag var?
    dp(:,mdel) = [];
end

%average replicates 
[dp, hnew] = repl_avg(dp, hnew);

%***post-averaging conversions/calculations?

%limit variables to save
if ~isempty(pvars)
    m = setdiff(dp.Properties.VariableNames,['sampnum ' pvars]);
    dp(:,m) = [];
end
m = cellfun(@(x) contains(x,'_inst_flag'), dp.Properties.VariableNames);
dp(:,m) = [];

%***eventually put msam_ashore_flag here to just read in sample collection
%flag data from logs?

%apply niskin flags (and also confirm consistency between sample and
%flag)
dp = table2struct(dp,'ToScalar',true);
dp.niskin_flag = dc.niskin_flag;
dp = hdata_flagnan(dp, 'keepemptyvars', 1);
dp = rmfield(dp,'niskin_flag');

%save samfile
mfsave(samcfile, dc, hnew, '-merge', 'sampnum');

%underway merged file ***
switch samtyp
    case 'chl'
        outu = fullfile(root_in,['ucswchl_' mcruise '_all.nc']);
        tsd_uway = dc(strncmp('UW',dc.cast_number,2),:);
        clear du hu
        to = [MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1) 1 1 0 0 0];
        du.time = datenum(tsd_uway.date_day_month_year)-datenum(to); %***HH MM?????
        du.chl = tsd_uway.chlorophyll_dil_x_r_adj_x_fl_bl_x_ace_per_sampl;
        hu.fldnam = {'time', 'chl'};
        hu.fldunt = {['days since ' datestr(to,'yyyy-mm-dd HH:MM:SS')], 'ug_per_l'}; %***
        hu.comment = comment;
        mfsave(outu,du,hu)
end



function [dp, hnew] = samp_units_conv(dp, hnew, convs)

%conversions that use CTD data, before averaging
if isfield(convs,'per_l_to_per_kg') && isfield(convs.per_l_to_per_kg,'temp')
    %use CTD salinity, but which temperature to use depends on parameter,
    %so must be passed in
    temp = convs.per_l_to_per_kg.temp;
    if isnumeric(temp)
        if isscalar(temp) %e.g., constant lab temp (approx)
            ctemp = repmat(temp,size(dp.sampnum));
            temp = [num2str(temp) 'C'];
        elseif size(temp,1)==size(dp.sampnum,1) %varying temperature (must already be interpolated to samfile***)
            ctemp = temp;
            temp = 'temperature specified in opt_cruise';
        else
            error('convs.umol_per_l_to_per_kg.temp must be string, scalar, or match rows of ds.sampnum')
        end
    else
        ctemp = dp.(temp); %e.g. botoxy_temp
    end
    nc = size(ctemp,2);
    dens = gsw_rho(repmat(dp.uasal,1,nc), gsw_CT_from_t(repmat(dp.uasal1,nc), ctemp, 0), 0);
    %convert all variables whose units are umol_per_l (*** or just
    %*_per_l?)
    m = strcmp('umol_per_l',dp.Properties.VariableUnits);
    dp(:,m) = dp(:,m)./(repmat(dens,1,sum(m))/1000);
    %change units
    dp.Properties.VariableUnits(m) = {'umol_per_kg'};
    %if variable names also contained _per_l, change them
    dp.Properties.VariableNames(m) = cellfun(@(x) replace(x,'_per_l',''), dp.Properties.VariableNames(m), 'UniformOutput', false); %***
    hnew.comment = [hnew.comment ', converted from umol/l to umol/kg using ' c.temp ' and CTD salinity'];
end

function [dp, hnew] = repl_avg(dp, hnew)
%mean and stdev of replicates, with flags
%different types of parameters
mf = cellfun(@(x) contains(x,'_flag'),hnew.fldnam); %flags
ma = cellfun(@(x) contains(x,'_inst'),hnew.fldnam) | cellfun(@(x) contains(x,'oxy_temp'),hnew.fldnam); %auxillary variables
mv = ~mf & ~ma & ~ismember(hnew.fldnam, [svars 'dday']); %regular variables, e.g. botoxy, silc, chl
vnames = hnew.fldnam(mv);
un = hnew.fldunt(mv);

%backwards compatibility for {param}a {param}b etc. form?***

%and loop through them to average
for nno = 1:length(vnames)
    vname = vnames{nno};
    vunit = un{nno};
    data = dp.(vname);
    [nr,nc] = size(data);
    flag = dp.([vname '_flag']);
    %find best flag for each sampnum (2 better than 3
    %better than 4, 1 and 9 irrelevant)
    flag(flag==1) = NaN; %1 not yet analysed means we won't have data anyway
    flag0 = repmat(min(flag,[],2),1,nc);
    %mask values worse than best flag, and then average
    data(flag~=flag0) = NaN;
    nav = sum(~isnan(data),2);
    dataav = mean(data,2,'omitnan');
    datast = std(data,[],2,'omitnan');
    %but where best was more than one bad value, just keep
    %first***?
    if isfield(dp,[vname '_inst'])
        inst = dp.([vname '_inst']);
        inst(flag~=flag0) = NaN;
        i1 = min(inst,[],2); i2 = max(inst,[],2);
        inst = i1; inst(i1~=i2) = inf; %multiple instruments
    end
    if isfield(dp,[vname '_temp'])
        ind = repmat(1:nc,nr,1);
        ind(flag~=flag0) = NaN;
        ind = sub2ind([nr nc], 1:nr, min(ind));
        dp.([vname '_temp']) = dp.([vname '_temp'])
        temp = mean(temp,2,'omitnan'); %use temp of first recorded good value
    end
    %where two or more points were averaged, set flag to 6,
    %unless both were flagged bad (4)***what about
    %questionable (3)?
    flag0(nav>1 & flag0<4) = 6;
    %add new fields
    dp.(vname) = dataav;
    dp.(fname) = flag0;
    hnew.fldnam = [hnew.fldnam vname fname];
    hnew.fldunt = [hnew.fldunt vunit 'woce_4.9'];
    if max(nav)>1
        sname = [vname '_std'];
        nname = [vname '_N'];
        dp.(sname) = datast;
        dp.(nname) = nav;
        hnew.fldnam = [hnew.fldnam sname nname];
        hnew.fldunt = [hnew.fldunt vunit 'number'];
    end
    if sum(flag0==6)
        hnew.comment = [hnew.comment ', ' vname ' average of replicates (' strjoin(rname,',') ')'];
    end
    %remove replicate fields
    m = ismember(hnew.fldnam,[rnames rfnames]);
    dp(:,m) = []; hnew.fldnam(m) = []; hnew.fldunt(m) = [];
end

