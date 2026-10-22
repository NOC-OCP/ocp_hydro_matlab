function msam_load(samtyp)
% msam_load(samtyp)
%
% processing of a type of bottle sample data:
%   - read/parse bottle sample data from .csv or spreadsheet files
%   - for some types (and if specified in opt_{cruise}.m), derive new
%     variables before averaging (e.g. oxygen conc. from titre etc.)
%   - compare and average replicate measurements
%       for salinity this may be repeat readings
%   - if specified in opt_{cruise}.m, add flags, optionally) derive variables as  
%   specified in opt_{cruise}.m, detect and compare replicates, add flags,
%   and save to a concatenated sample file for the samtyp
%   (sal_{cruise}_01.nc, nut_{cruise}_01.nc, etc.) 
%
% sampnum is used to match bottle sample data with CTD or underway sensor
%   data, so it must either be included in each input file or calculated in
%   opt_{cruise}.m, following the conventions given by m_sampnum.m:   
% for CTD samples, 
%   sampnum = 100*statnum + position
%       where statnum is the unique cast number (often referred to as
%       station number) and position is the niskin position on the rosette
%       (from [1:24] or [1:36]) 
% for underway samples, 
%   sampnum = yyyymmddHHMM
%   or 
%   sampnum = -dddHHMM (where ddd is year-day, and the negative sign is
%     important) 
% for (sub)standards or other special rows to be used by {samtyp}_calc.m,  
%   9e5 >= sampnum <= 1e6, e.g. salinity standards are labelled with
%     sampnum = 999NNN, where NNN increments sequentially in the order in
%     which the standards were run (and 998NNN, 990NNN, etc. may be used
%     for sub-standards) 
%
% lines where the sampnum column is empty will be assumed to be replicates
% and filled in from the last non-empty sampnum above (unless opt_cruise
% samp_proc, parse case removes them first)
%
% called by
%   samp_process.m
% sets cruise-specific options using
%   opt1 = 'samp_proc' and
%   opt2 in 'files', 'parse', 'calc', 'check', 'flags'***
%   when calling run(MEXEC_G.opt_cruise).m (mexec_defaults_all.m, opt_{cruise}.m)
% also calls 
%   load_samdata.m, var_renamer.m, msam_replicates.m, mfsave.m
% and may call
%   fill_samdata_statnum.m, oxy_calc.m or sal_calc.m


m_common
if MEXEC_G.quiet<=1; fprintf(1, 'loading bottle/calibration %s from file(s) specified in opt_%s, \nhandling calculations, replicates and flags, writing to \n%s_%s_01.nc and sam_%s_all.nc\n',samtyp,MEXEC_G.mcruise,samtyp,MEXEC_G.mcruise,MEXEC_G.mcruise); end

%files to load
if nargin==0
    samtyp = input('what type of sample (sal, oxy, nut, chl, co2, etc.)?  ','s');
end
clear sopts
pd = mexec_file_locations('procfiles','samp',samtyp);
opt1 = 'samp_proc'; opt2 = 'files'; run(['opt_' MEXEC_G.mcruise])
if isempty(files)
    warning('no %s files found in %s; check opt_%s', samtyp, root_in, MEXEC_G.mcruise)
    return
end
if length(sopts)>1 && length(sopts)~=length(files)
    warning('sopts must be a scalar or must have the same length as files')
    return
end
%load column/matrix data into table sdata, and any headers in cell array
%shead, which may be used by opt_{cruise}.m
[sdata, shead] = load_samdata(files, sopts); 
%remove columns with no non-nan values

%parse what was in files (split strings and datetimes, fill in missing
%station numbers, rename variables to standardised names, where replicates
%are in different columnes combine them, and add units if necessary) 
%also do some basic checks on sampnums and other values in case of typos
%(only if switched on?) before doing any filling or renaming or relabelling
%units
opt1 = 'samp_proc'; opt2 = 'parse'; run(['opt_' MEXEC_G.mcruise])
if exist('fillstatnum','var')
    sdata = fill_samdata_statnum(sdata, fillstatum);
    names0 = sdata.Properties.VariableNames;
    m1 = ismember(names0,{fillstatnum});
    sdata = rmmissing(sdata,'DataVariables',names0(~m1),'MinNumMissing',sum(~m1));
    sdata.sampnum(~isnan(sdata.position)) = sdata.statnum(~isnan(sdata.position))*100 + sdata.position(~isnan(sdata.position));
end
if exist('varmap','var')
    sdata = var_renamer(sdata, varmap, 'keep_othervars', keepothervars);
end
%where _per_l is in name, move into units (in case this wasn't done above)
m = cellfun(@(x) contains(x,'_per_l'), sdata.Properties.VariableNames);
sdata.Properties.VariableUnits(m) = {'umol_per_l'}; %***what if not umol?
sdata.Properties.VariableNames(m) = cellfun(@(x) replace(x,'_per_l',''), sdata.Properties.VariableNames(m), 'UniformOutput', false);
sdata.Properties.VariableUnits(strcmp('sampnum',sdata.Properties.VariableNames)) = {'number'};
%assign units to flags, and replace NaN flags with 9s
mf = cellfun(@(x) contains(x,'_flag'),sdata.Properties.VariableNames);
if sum(mf)
    mnw = strcmp('woce_4.9',sdata.Properties.VariableUnits);
    if sum(mf & mnw)
        warning('about to overwrite flag units; should you convert instead (in opt_cruise, samp_proc, parse)?')
        keyboard
    end%***
    sdata.Properties.VariableUnits(mf) = {'woce_4.9'}; %***overwrite?
    dat = sdata{:,mf}; dat(isnan(dat)) = 9; sdata{:,mf} = dat;
end

%do parameters need to be derived before examining replicates and flagging?
switch samtyp
    case 'oxy'
      m = strncmp('botoxy',sdata.Properties.VariableNames,6);
      if ~sum(m)
          tpar.vol_reag_tot = 2; %total volume of reagents (mL) added before closing bottle
tpar.vol_std = 5; %volume of standard added in standardisation
  %e.g. oxy concentration from titre, std vol, blank vol
        mt = cellfun(@(x) contains(x, '_temp'), sdata.Properties.VariableNames);
        if sum(mt); sdata.Properties.VariableUnits(mt) = {'degC'}; end %***overwrite?
        sdata = oxy_from_titre(sdata, 'vol_std', vol_std, 'vol_reag_tot', vol_reag_tot); %***output is per_l or per_kg?
        sdata.botoxy = sdata.conc_o2;
      end

        sdata.botoxy_temp = sdata.fix_temp;
        vnkeep = {'sampnum','botoxy','botoxy_flag','botoxy_temp'};
        vnrequire = {'botoxy','botoxy_temp'}; %all must be non-nan for value of first to be reported
        vnrepl = {'botoxy'};
    case 'sal'
        %e.g. average conductivity from 3 readings, and salinity from that

        %sdata = sal_calc(sdata); %***this happens after replicates are checked, keep special code to not flag reading replicates as replicate sample bottles?***
        vnkeep = {'sampnum','reading','botpsal'};
        vnrequire = {'reading','botpsal','k15','cellT'};
        vnrepl = {'reading'};
    case 'nut'
    case 'co2'
    case 'chl'
    case 'cfc'
    case 'iso'
end

    %shift tsg sampnum times if using >0 method
    ii = find(ds_sal.sampnum>1000e8);
    ds_sal.sampnum(ii) = ds_sal.sampnum(ii)-MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1)*1e8;

    % flags
if ~sum(strcmp(sdata.Properties.VariableNames,'flag'))
    sdata.flag = nan(size(sdata.sampnum));
end

sdata(:,~ismember(sdata.Properties.VariableNames,union(vnkeep,vnrepl,vnrequire))) = [];
%***custom code, e.g. average extra readings, ... 

%group or arrange replicates into 2D matrices, add flags, and check
%replicates against each other
dbot = msam_replicates(sdata, samtyp);
%manually set any flags after separating out replicates
%if ~ismember(ds.Properties.VariableNames,'flag')
%    ds.flag = 2+zeros(size(ds,1),1); %***flags before replicates or after or both?***
%    ds.Properties.VariableUnits(strcmp('flag',ds.Properties.VariableNames)) = {'woce_4.9'};
%end
%***

%
switch samtyp
    case 'sal'
        sdata.botpsal_flag(sdata.botpsal_flag==5) = 2; %always? option to re-run msam_replicates to find and compare true replicates? 
        sdata = sal_from_salinometer(sdata);
end

%turn into structure
dnew = dbot;
dnew = table2struct(dnew,'ToScalar',true);
hnew.fldnam = dbot.Properties.VariableNames;
hnew.fldunt = dbot.Properties.VariableUnits;
%save to param_cruise_01.nc file
hnew.dataname = pd.([samtyp 'name']);
indir = fileparts(files{1});
hnew.comment = sprintf('variables loaded from files in %s%s',indir,addcomment);
mfsave(pd.(samtyp), dnew, hnew);


function gs = msam_replicates(ds, samtyp)
% gs = msam_replicates(ds, samtyp)
% arrange sample data into sampnum x replicate number 
%
% ds is a structure or table including columns sampnum, (tabdatavar), and
% flag 
%
% for each tabdatavar, adds units, separates and renames replicates, makes
% flags consistent, and outputs in table gs
%

if isstruct(ds)
    ds = struct2table(ds);
end

%masks for different types of fields (only want to look for main sample
%data)
names0 = ds.Properties.VariableNames;
mx = ismember(names0,{'sampnum'}); %everything in ~mx will be replicated where sampnum is repeated, and given alphabetic suffixes
mf = ~mx & cellfun(@(x) contains(x,'_flag'),names0);
if strcmp(samtyp, 'oxy')
    mt = ~mx & ~mf & cellfun(@(x) contains(x, '_temp'), names0); %botoxy_temp is an auxilliary variable to botoxy
else
    mt = false(size(names0));
end
mi = ~mx & ~mf & cellfun(@(x) contains(x, '_inst'), names0);
mv = ~mx & ~mf & ~mt & ~mi; %"normal" variables

%turn names of different analysing instruments into numbers***why?
for varno = find(mi)
    gi = findgroups(ds.(names0{varno}));
    gis = groupsummary(ds,names0{varno});
    ds.(names0{varno}) = gi;
    ds.Properties.VariableUnits{varno} = strjoin(gis.(names0{varno}),' / ');
end

%fill missing sampnums with unique values (so as not to group)
mjunk = ~isfinite(ds.sampnum);
ds.sampnum(mjunk) = [0:sum(mjunk)-1]-1e10; %these sampnums aren't used for anything even TSG times so safe to use here
%***get rid of later? why not now? 

%initialise a table for the grouped replicates
g = findgroups(ds.sampnum);
gs = groupsummary(ds,"sampnum","sum",names0(mv));
mr = max(gs.GroupCount);
m = strcmp('sampnum',gs.Properties.VariableNames);
gs = gs(:,m);
gs.Properties.VariableUnits(1) = {'number'};

%arrange replicates into matrices [sampnum, replicate index]
for varno = find(~mx)
    %loop through ds variables other than sampnum
    varnam = names0{varno};
    
    %***if replicates are already called {param}a, {param}b or {param}1,
    %{param}2, etc., rearrange into matrix***

    %replicates are on different lines; put into padded array for each sampnum
    a = splitapply(@(x) [x(:)' nan(1,mr-length(x))], ds.(varnam), g);
    %remove any all-nan columns for this variable (in case some variables
    %had more replicates than others)
    a(:,sum(~isnan(a))==0) = [];
    %append to table gs as matrix
    gs.(varnam) = a;
    gs.Properties.VariableUnits(strcmp(varnam,gs.Properties.VariableNames)) = ds.Properties.VariableUnits(varno);

end
%recalculate statnum and position
gs.statnum = floor(gs.sampnum/100);
gs.position = gs.sampnum-gs.statnum*100;
gs.Properties.VariableUnits(end-1:end) = {'number','on.rosette'};

%add existing flags from editlogs***
    %edits
    reapply_saledits = 1; edfile = fullfile(root_sal,'editlogs','bad_sal_readings');
    opt1 = 'samp_proc'; opt2 = 'sal_flags'; run(['opt_' MEXEC_G.mcruise])
    if reapply_saledits
        [ds_sal, ~] = apply_guiedits(ds_sal, 'sampnum', [edfile '*']);
    end

opt1 = 'samp_proc'; opt2 = 'flag'; run(['opt_' MEXEC_G.mcruise]) %apply flags if specified in opt_cruise
%recalculate mean, stdev, range (or for the first time? or do this after
%repl_check?)
okf = [2 3];
stlev = 2; %flag as outlier repls > stlev*stdev diff from mean for this sampnum
nrepstats = 2; %only when there are more than nrepstats replicates at this sampnum
nit = 2;
for varno = find(mv)
    varnam = names0{varno};
    d = gs.(varnam); f = gs.([varnam '_flag']); f(isnan(f)) = 9;
    d(~ismember(f,okf)) = NaN;
    m = false(size(d));
    for itno = 1:nit
        mn = mean(d,2,'omitnan');
        st = std(d,[],2,'omitnan');
        %outliers
        nc = size(d,2); nr = sum(~isnan(d),2);
        prmsa = abs(gs.(varnam)-repmat(mn,1,nc))./repmat(st,1,nc);
        m = m | (prmsa>stlev & repmat(nr,1,nc)>nrepstats);
        d(m) = NaN;
    end
    gs.(varnam) = d;
    gs.([varnam '_flag']) = max(f,double(m)+2); %false --> 2, true --> 3
end

%optionally check replicates against each other
opt1 = 'samp_proc'; opt2 = 'replcheck'; run(['opt_' MEXEC_G.mcruise])
if isfield(checksam,samtyp) && (length(checksam.(samtyp))>1) || checksam.(samtyp)
    repl_check(samtyp, gs, checksam.(samtyp)); %***working on this for nut, need to add code for chl as well as sal and sbe35 (sal repls compared earlier? yes, and handled differently, not flagged as mean of replicates because not separate samples exactly)***
end
