function msam_load(samtyp)
% msam_load(samtyp)
%
% read in bottle sample data, parse and (optionally) derive variables as
%   specified in opt_{cruise}.m, detect and compare replicates, add flags,
%   and save to a concatenated sample file for the samtyp
%   (sal_{cruise}_01.nc, nut_{cruise}_01.nc, etc.) 
%
% sampnum is used to match bottle sample data with CTD or underway sensor
%   data, so it must either be included in each input file or calculated in
%   opt_{cruise}.m, following the conventions given by sampnum_ranges.m:   
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
% lines where the sampnum column is empty will be filled in from the last
%   non-empty sampnum above (effectively labelling successive rows as
%   replicates)
%
% called by
%   samp_process.m
% sets cruise-specific options using
%   opt1 = 'samp_proc' and
%   opt2 in 'files', 'parse', 'calc', 'check', 'flags'***
%   when calling get_cropt.m (mexec_defaults_all.m, opt_{cruise}.m)
% also calls 
%   load_samdata.m, var_renamer.m, msam_replicates.m, mfsave.m
% and may call
%   fill_samdata_statnum.m, oxy_calc.m or sal_calc.m


m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
if MEXEC_G.quiet<=1; fprintf(1, 'loading bottle/calibration %s from file(s) specified in opt_%s, \nhandling calculations, replicates and flags, writing to \n%s_%s_01.nc and sam_%s_all.nc\n',samtyp,mcruise,samtyp,mcruise,mcruise); end

%load data
if nargin==0
    samtyp = input('what type of sample (sal, oxy, nut, chl, co2, etc.)?  ','s');
end
root_in = mgetdir(['bot_' samtyp]);
npat = ''; files = {};
clear sopts
opt1 = 'samp_proc'; opt2 = 'files'; get_cropt
if isempty(files)
    warning('no %s files found in %s; check opt_%s', samtyp, root_in, mcruise)
    return
end
if length(sopts)>1 && length(sopts)~=length(files)
    warning('sopts must be a scalar or must have the same length as files')
    return
end
[sdata, shead] = load_samdata(files, sopts); %shead may be used by opt_cruise to parse info from header?
%remove columns with no non-nan values
sdata = rmmissing(sdata,2,'MinNumMissing',size(sdata,1)); 

%parse what was in files (split strings and datetimes, fill in missing
%station numbers, rename variables to standardised names, add units)
opt1 = 'samp_proc'; opt2 = 'parse'; get_cropt
if exist('fillstatnum','var')
    sdata = fill_samdata_statnum(sdata, fillstatum);
    names0 = sdata.Properties.VariableNames;
    m1 = ismember(names0,{fillstatnum});
    sdata = rmmissing(sdata,'DataVariables',names0(~m1),'MinNumMissing',sum(~m1));
    sdata.sampnum(~isnan(sdata.position)) = sdata.statnum(~isnan(sdata.position))*100 + sdata.position(~isnan(sdata.position));
    %***
end
if exist('varmap','var')
    sdata = var_renamer(sdata, varmap, 'keep_othervars', keepothervars);
end
%where _per_l is in name, move into units
m = cellfun(@(x) contains(x,'_per_l'), sdata.Properties.VariableNames);
sdata.Properties.VariableUnits(m) = {'umol_per_l'}; %***what if not umol?
sdata.Properties.VariableNames(m) = cellfun(@(x) replace(x,'_per_l',''), sdata.Properties.VariableNames(m), 'UniformOutput', false);
sdata.Properties.VariableUnits(strcmp('sampnum',sdata.Properties.VariableNames)) = {'number'};
%assign units to flags, and replace NaN flags with 9s
mf = cellfun(@(x) contains(x,'_flag'),sdata.Properties.VariableNames);
if sum(mf)
    sdata.Properties.VariableUnits(mf) = {'woce_4.9'}; %***overwrite?
    dat = sdata{:,mf}; dat(isnan(dat)) = 9; sdata{:,mf} = dat;
end

%derive certain parameters from those in files
switch samtyp
    case 'oxy'
        %e.g. oxy concentration from titre, std vol, blank vol
        sdata = oxy_calc(sdata); %***output is per_l or per_kg? 
        mt = cellfun(@(x) contains(x, '_temp'), sdata.Properties.VariableNames);
        if sum(mt); sdata.Properties.VariableUnits(mt) = {'degC'}; end %***overwrite?
    case 'sal'
        %e.g. average conductivity from 3 readings, and salinity from that
        sdata = sal_calc(sdata); %***
end
%***custom code, e.g. average extra readings, ... 

%separate out replicates, add flags, and check replicates against each
%other
dbot = msam_replicates(sdata, samtyp); %dnew is a structure***
hnew.comment = sprintf('variables loaded from files %s in %s%s',npat,root_in,addcomment);
%manually set any flags after separating out replicates
%if ~ismember(ds.Properties.VariableNames,'flag')
%    ds.flag = 2+zeros(size(ds,1),1); %***flags before replicates or after or both?***
%    ds.Properties.VariableUnits(strcmp('flag',ds.Properties.VariableNames)) = {'woce_4.9'};
%end
%***
opt1 = 'samp_proc'; opt2 = 'check'; get_cropt
if isfield(checksam,samtyp) && (length(checksam.(samtyp))>1) || checksam.(samtyp)
    repl_check(dbot, checksam.(samtyp), samtyp); %***working on this for nut, need to add code for chl as well as sal and sbe35 (sal repls compared earlier? yes, and handled differently, not flagged as mean of replicates because not separate samples exactly)***
end

%turn into structure
dnew = table2struct(dbot,'ToScalar',true);
hnew.fldnam = dbot.Properties.VariableNames;
hnew.fldunt = dbot.Properties.VariableUnits;
%save to param_cruise_01.nc file
hnew.dataname = sprintf('%s_%s_01',samtyp,mcruise);
root_out = mgetdir(['bot_' samtyp]);
otfile = fullfile(root_out, [hnew.dataname '.nc']);
mfsave(otfile, dnew, hnew);
