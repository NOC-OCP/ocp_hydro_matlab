% miso_01: read in bottle isotope data from csv file or files
%
% Use: miso_01
%
% The input iso data, example filename jc159_13ctdic.csv
%    is a comma-delimited list of isotope data, with a single header line
%    containing fields
%    Station, Niskin, d13C DIC PDB
%    or otherwise as specified in opt_cruise file

scriptname = 'miso_01';
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
if MEXEC_G.quiet<=1; fprintf(1, 'reading bottle del13C, Del14C, del18O data from .csv files into iso_%s_01.nc',mcruise); end

% find list of files
root_iso = mgetdir('M_BOT_ISO');
dataname = ['iso_' mcruise '_01'];
otfile2 = fullfile(root_iso, dataname);
scriptname = mfilename; oopt = 'iso_files'; get_cropt

%load data
if ~iscell(isofiles); isofiles = {isofiles}; end
[ds_iso, isohead] = load_samdata(isofiles, hcpat, 'chrows', 1, 'chunits', 2);

%parse (rename variables)
scriptname = mfilename; oopt = 'iso_parse'; get_cropt %***what about file-dependent parsing, like if we have multiple sources of 13c to rename?
if ~isempty(isovarmap)
    ds_iso_fn = ds_iso.Properties.VariableNames;
    [~,ia,ib] = intersect(isovarmap(:,2)',ds_iso_fn);
    ds_iso_fn(ib) = isovarmap(ia,1)';
    ds_iso.Properties.VariableNames = ds_iso_fn;
end

%compute sampnum
ds_iso.sampnum = 100*ds_iso.statnum + ds_iso.position; 
%add flags if not present? ***

%now put into structure and output

%adjust for replicates and flags, and exclude station numbers with no data
statnum = floor(iso.sampnum/100); sg = [];
fn = fieldnames(iso);
kvar = 2;
while kvar < length(fn)
    
    %average replicate measurements (depending on flag. this should work if flags are 2,3,4,9)
    iir = find(strcmp([fn{kvar} '_rpt'], fn) | strcmp([fn{kvar} '_repl'], fn));
    if ~isempty(iir)
        d = getfield(iso, fn{kvar});
        dr = getfield(iso, fn{iir});
        iif = find(strcmp([fn{kvar} '_flag'], fn));
        iirf = find(strcmp([fn{iir} '_flag'], fn));
        f = getfield(iso, fn{iif});
        fr = getfield(iso, fn{iirf});
        iig = find(f==2 & fr==2); ii2 = find(fr<f);
        %both good: average (what about both flagged 3?)
        d(iig) = .5*(d(iig)+dr(iig));
        f(iig) = 6; %flag for average of repeat measurements
        %second measurement better than first: use that
        d(ii2) = dr(ii2);
        f(ii2) = fr(ii2);
        %now can replace with averaged values, and discard replicates and their flags
        iso = setfield(iso, fn{kvar}, d);
        iso = setfield(iso, fn{iif}, f);
        iso = rmfield(iso, fn([iir iirf]));
        isou = rmfield(isou, fn([iir iirf]));
        fn([iir iirf]) = [];
    end
    
    %make sure NaNs have flag 9 not 2 (or NaN)
    iif = find(strcmp([fn{kvar} '_flag'], fn));
    if ~isempty(iif)
        d = iso.(fn{kvar});
        df = iso.(fn{iif});
        df(isnan(d)) = 9;
        df(isnan(df)) = 9;
    end
    
    %add statnums with data to list
    iif = strfind(fn{kvar}, '_flag');
    if ~isempty(iif)
        sg = [sg; statnum(iso.(fn{kvar})<9)];
    else
        sg = [sg; statnum(~isnan(iso.(fn{kvar})))];
    end
    
    %move on to next variable
    kvar = kvar + 1;
end
sg = unique(sg);
iisg = ismember(statnum, sg);

oopt = 'iso_flags'; get_cropt %additional modifications to flags if required

%prepare for writing mstar file
varnames = {'sampnum';'statnum';'position'};
varnames_units = {'sampnum';'/';'number';'statnum';'/';'number';'position';'/';'number'};
sampnum = iso.sampnum; position = sampnum-statnum*100;
sampnum = sampnum(iisg); statnum = statnum(iisg); position = position(iisg);
fn = fieldnames(iso);
for kvar = 2:length(fn)
    d = iso.(fn{kvar}); d = d(iisg);
    eval([fn{kvar} ' = d;'])
    varnames = [varnames; fn{kvar}];
    varnames_units = [varnames_units; fn{kvar}; {'/'}; getfield(isou, fn{kvar})];
end

%write
timestring = ['[' sprintf('%d %d %d %d %d %d',MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN) ']'];
%--------------------------------
MEXEC_A.MARGS_IN_1 = {
    otfile2
    };
MEXEC_A.MARGS_IN_2 = varnames(:);
MEXEC_A.MARGS_IN_3 = {
    ' '
    ' '
    '1'
    dataname
    '/'
    '2'
    MEXEC_G.PLATFORM_TYPE
    MEXEC_G.PLATFORM_IDENTIFIER
    MEXEC_G.PLATFORM_NUMBER
    '/'
    '4'
    timestring
    '/'
    '8'
    };
MEXEC_A.MARGS_IN_4 = varnames_units(:);
MEXEC_A.MARGS_IN_5 = {
    '-1'
    '-1'
    };
MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN_1; MEXEC_A.MARGS_IN_2; MEXEC_A.MARGS_IN_3; MEXEC_A.MARGS_IN_4; MEXEC_A.MARGS_IN_5];
msave
%--------------------------------


