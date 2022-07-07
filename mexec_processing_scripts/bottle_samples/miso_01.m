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

% resolve root directories for various file types
root_iso = mgetdir('M_BOT_ISO');
dataname = ['iso_' mcruise '_01'];
otfile2 = fullfile(root_iso, dataname);

oopt = 'files'; get_cropt

%initialise sampnum in case different subsets of samples in different files
iso.sampnum = repmat(1:999,24,1)*100+repmat([1:24]',1,999); iso.sampnum = iso.sampnum(:);
isou.sampnum = 'number';
oopt = 'vars'; get_cropt %set vars: {varnames varunits origvarnames}

%load data and put into fields with standard names specified by vars
for fno = 1:length(files)
    
    %read csv file
    infile = files{fno};
    if ~exist(infile, 'file'); warning(['file ' infile ' not found']); continue; end
    ds_iso = dataset('File', infile, 'Delimiter', ',');
    ds_iso_fn = ds_iso.Properties.VarNames;
    
    %default ways to get station, niskin, sampnum
    if sum(strcmp('sampnum', vars{fno}(:,1)))==0
        if sum(strcmp('Station', ds_iso_fn)) & sum(strcmp('Niskin', ds_iso_fn))
            ds_iso.sampnum = ds_iso.Station*100 + ds_iso.Niskin;
        else
            iis = find(strcmp('statnum', vars{fno}(:,1)));
            iin = find(strcmp('position', vars{fno}(:,1)));
            if length(iis)>0 & length(iin)>0
                ds_iso.sampnum = getfield(ds_iso, vars{fno}{iis,3})*100 + getfield(ds_iso, vars{fno}{iin,3});
            end
        end
    end
    oopt = 'sampnum_parse'; get_cropt %special cases
    
    %subset of sample numbers in file
    [c,iisamp,ib] = intersect(iso.sampnum, ds_iso.sampnum);
    if length(ib)<size(ds_iso,1)
        ds_iso = ds_iso(ib,:);
        warning(['file ' infile 'contains invalid station-niskin sample numbers, which are not being read in']);
    end
    
    %look for and fill in each variable in vars
    nvars = size(vars{fno},1);
    for kvar = 1:nvars
        
        %get variable from iso, or initialise
        iif = strfind(vars{fno}{kvar,1}, '_flag');
        if isfield(iso, vars{fno}{kvar,1})
            d0 = getfield(iso, vars{fno}{kvar,1});
        else
            if isempty(iif)
                d0 = NaN+iso.sampnum;
            else
                d0 = 9+zeros(size(iso.sampnum)); %flags default to 9 (missing)
            end
        end
        
        %fill from ds_iso
        if sum(strcmp(vars{fno}{kvar,3}, ds_iso_fn))
            d0(iisamp) = getfield(ds_iso, vars{fno}{kvar,3});
        elseif length(iif)>0 %a flag field that's not in ds_iso
            iid = find(strcmp(vars{fno}{kvar,1}(1:iif-1), vars{fno}));
            dd = getfield(ds_iso, vars{fno}{iid,3}); %data that goes with this flag field
            df = 9+zeros(size(dd)); df(~isnan(dd)) = 2; %2 for data, 9 for no data
            d0(iisamp) = df;
        else
            warning(['no values found for iso variable ' vars{fno}{kvar,1} 'in file ' infile]) %***necessary?
        end
        iso = setfield(iso, vars{fno}{kvar,1}, d0);
        isou = setfield(isou, vars{fno}{kvar,1}, vars{fno}{kvar,2});
        
    end
    
end

%adjust for replicates and flags, and exclude station numbers with no data
statnum = floor(iso.sampnum/100); sg = [];
fn = fieldnames(iso);
kvar = 2;
while kvar < length(fn)
    
    %average replicate measurements (depending on flag. this should work if flags are 2,3,4,9)
    iir = find(strcmp([fn{kvar} '_rpt'], fn) | strcmp([fn{kvar} '_repl'], fn));
    if length(iir)>0
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
    if length(iif)>0
        d = getfield(iso, fn{kvar});
        df = getfield(iso, fn{iif});
        df(isnan(d)) = 9;
        df(isnan(df)) = 9;
    end
    
    %add statnums with data to list
    iif = strfind(fn{kvar}, '_flag');
    if length(iif)>0
        sg = [sg; statnum(getfield(iso, fn{kvar})<9)];
    else
        sg = [sg; statnum(~isnan(getfield(iso, fn{kvar})))];
    end
    
    %move on to next variable
    kvar = kvar + 1;
end
sg = unique(sg);
iisg = ismember(statnum, sg);

oopt = 'flags'; get_cropt %additional modifications to flags if required

%prepare for writing mstar file
varnames = {'sampnum';'statnum';'position'};
varnames_units = {'sampnum';'/';'number';'statnum';'/';'number';'position';'/';'number'};
sampnum = iso.sampnum; position = sampnum-statnum*100;
sampnum = sampnum(iisg); statnum = statnum(iisg); position = position(iisg);
fn = fieldnames(iso);
for kvar = 2:length(fn)
    d = getfield(iso, fn{kvar}); d = d(iisg);
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


