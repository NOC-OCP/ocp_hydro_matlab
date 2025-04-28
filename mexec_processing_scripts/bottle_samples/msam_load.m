function msam_load(samtyp)
% read in bottle sample data not covered by specific function (specific
% functions include msal_01, moxy_01, ***mco2_01, mcfc_01***, miso_01***)
%
% for each type of input, parse as specified in opt_cruise, handle
% replicates and flags, save to a concatenated sample file for this type,
% and save data from CTD Niskins to sam_cruise_all.nc
%
% see samp_proc case in set_mexec_defaults.m and in opt_cruise.m 

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
if MEXEC_G.quiet<=1; fprintf(1, 'loading bottle/calibration %s from file(s) specified in opt_%s, \nhandling calculations, replicates and flags, writing to \n%s_%s_01.nc and sam_%s_all.nc\n',samtyp,mcruise,samtyp,mcruise,mcruise); end

%load data
root_in = mgetdir(['bot_' samtyp]);
npat = ''; files = {};
clear sopts
switch samtyp
    case 'chl'
        sopts.hcpat = {'Site'};
    case 'oxy'
        files = dir(fullfile(root_oxy,['oxy_' mcruise '_*.csv']));
        sopts.hcpat = {'Niskin' 'Bottle' 'Number'};
        sopts.icolhead = 1:2; sopts.icolunits = 3;
        sopts.sheets = 1:99;
    case 'nut'
        %find files and load
        npat = ['*.xlsx']; files = [];
        sopts.hcpat = {'Nitrate+Nit'};
        sopts.icolhead = 1; sopts.icolunits = 1; sopts.sheets = 1;
        opt1 = 'samp_proc'; opt2 = 'files'; get_cropt
    case 'sal'
    case 'sbe35'
end
opt1 = 'samp_proc'; opt2 = 'files'; get_cropt
files = sam_files(root_in, npat, files);
if isempty(files)
    if ~isempty(npat)
        warning('no %s files matching %s found in %s', samtyp, npat, root_in)
    else
        warning('no %s files found in %s', samtyp, root_in)
    end
    return
end
[ds, shead] = load_samdata(files, sopts); %shead may be used by opt_cruise to parse info from header?

%parse what was in files (split strings and datetimes, rename variables to standardised names, set units***)
opt1 = 'samp_proc'; opt2 = 'parse'; get_cropt
if ~ismember(ds.Properties.VariableNames,'flag')
    ds.flag = 2+zeros(size(ds,1),1);
end
if exist('varmap','var')
    ds = var_renamer(ds, varmap, 'keep_othervars', keepothervars);
end
ds = rmmissing(ds,2,'MinNumMissing',size(ds,1)); %remove columns with no non-nan values
%calculate sampnum from station and niskin position
if allctd && sum(isnan(ds.statnum))
    %fill missing station numbers if necessary
    ds = fill_samdata_statnum(ds, 'statnum');
    %remove rows where statnum is the only good value
    names0 = ds.Properties.VariableNames;
    m1 = ismember(names0,{'statnum'});
    ds = rmmissing(ds,'DataVariables',names0(~m1),'MinNumMissing',sum(~m1));
end
%calculate sampnum and remove statnum and position for now
ds.sampnum = 100*ds.statnum + ds.position;
ds.Properties.VariableUnits(strcmp('sampnum',ds.Properties.VariableNames)) = {'number'};
ds.statnum = []; ds.position = [];
%where _per_l is in name, move into units
m = cellfun(@(x) contains(x,'_per_l'), ds.Properties.VariableNames);
ds.Properties.VariableUnits(m) = {'umol_per_l'}; %***what if not umol?
ds.Properties.VariableNames(m) = cellfun(@(x) replace(x,'_per_l',''), ds.Properties.VariableNames(m), 'UniformOutput', false);

%calculate new variables in standardised ways, handle replicates and flags
switch samtyp
    case 'oxy'
        ds = oxy_calc(ds); %***output is per_l or per_kg? 
    case 'sal'
        ds = sal_calc(ds);
end

[dnew, hnew] = msam_replicates(ds, samtyp); %dnew is a structure***
hnew.comment = sprintf('variables loaded from files %s in %s%s',npat,root_in,addcomment);
opt1 = 'samp_proc'; opt2 = 'flag'; get_cropt %apply flags if specified in opt_cruise

%check data (usually replicates against each other)***right now this only
%works for CTD data not underway? or does it depend on parameter?
stn_start = 1;
opt1 = 'samp_proc'; opt2 = 'check'; get_cropt
if isfield(checksam,samtyp) && checksam.(samtyp)
    repl_check(samtyp, dnew, orth, stn_start); %***working on this for nut, need to add code for chl as well as sal and sbe35 (sal repls compared earlier? yes, and handled differently, not flagged as mean of replicates because not separate samples exactly)***
    %redo flags in case check has changed them (but does this update?
    %instead warn to rerun msam_load?***)
    opt1 = 'samp_proc'; opt2 = 'flags'; get_cropt
end

%save to param_cruise_01.nc file
hnew.dataname = sprintf('%s_%s_01',samtyp,mcruise);
root_out = mgetdir(['bot_' samtyp]);
otfile = fullfile(root_out, [hnew.dataname '.nc']);
mfsave(otfile, dnew, hnew);

%add CTD Niskin data to sam_cruise_all.nc file
msam_add_to_samfile(samtyp)

%save underway***
switch samtyp
    case 'chl'
        outu = fullfile(root_in,['ucswchl_' mcruise '_all.nc']);
        tsd_uway = dnew(strncmp('UW',dnew.cast_number,2),:);
        clear du hu
        to = [MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1) 1 1 0 0 0];
        du.time = datenum(tsd_uway.date_day_month_year)-datenum(to); %***HH MM?????
        du.chl = tsd_uway.chlorophyll_dil_x_r_adj_x_fl_bl_x_ace_per_sampl;
        hu.fldnam = {'time', 'chl'};
        hu.fldunt = {['days since ' datestr(to,'yyyy-mm-dd HH:MM:SS')], 'ug_per_l'}; %***
        hu.comment = comment;
        mfsave(outu,du,hu)
end


function files = sam_files(root_in, npat, files)
if isempty(files) && ~isempty(npat)
    files = dir(fullfile(root_in,npat));
    files = struct2cell(files); files = files(1,:)';
    for flno = 1:length(files)
        files{flno} = fullfile(root_in,files{flno});
    end
elseif isstruct(files)
    files = fullfile({files.folder}',{files.name}');
end
