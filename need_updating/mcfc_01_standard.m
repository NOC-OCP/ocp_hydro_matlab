% mcfc_01: read in the bottle cfc data
%
% Use: mcfc_01        and then respond with station number, or for station 16
%      stn = 16; mcfc_01;

scriptname = 'mcfc_01';
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
mdocshow(scriptname, ['add documentation string for ' scriptname])

% resolve root directories for various file types
root_cfc = mgetdir('M_BOT_CFC');

dataname = ['cfc_' mcruise '_01'];
otfile = fullfile(root_cfc, dataname);

%load
oopt = 'inputs'; get_cropt %set input filename, variables, and units
if strcmp(infile(end-2:end), 'csv')
    try
       ds_cfc = dataset('file', infile, 'delimiter', ',');
    catch me
        warning('csv not dataset')
        throw(me)
    end
elseif strcmp(infile(end-2:end), 'mat')
    load(infile, 'data'); indata = data.BottleFileData;
    incols = [1 2 7 8 9 10 11 12 13 14 15 16]; % these are the columns that correspond to invars
    indata = indata(:,incols);
    ds_cfc = dataset();
    for no = 1:size(varsunits,1)
       ds_cfc = setfield(ds_cfc, varsunits{no,1}, indata(:,no));
    end
elseif strcmp(infile(end-2:end), 'txt')
    indata = load(infile);
    incols = [1 2 12 13 6 7 4 5 8 9 10 11]; % these are the columns that correspond to invars
    indata = indata(:,incols);
    ds_cfc = dataset();
    for no = 1:size(varsunits,1)
       ds_cfc = setfield(ds_cfc, varsunits{no,1}, indata(:,no));
    end
else
    error('no code for this type of input file');
end
    
ds_fn = ds_cfc.Properties.VarNames;
if ~sum(strcmp('sampnum', ds_fn))
    ds_cfc.sampnum = ds_cfc.station*100 + ds_cfc.niskin;
    ds_fn = ds_cfc.Properties.VarNames;
end

isvar = ones(1,size(varsunits,1)); isflag = zeros(1,size(varsunits,1));
for no = 1:size(varsunits,1)
    %rename
    ii = find(strcmpi(ds_fn, varsunits{no,1}));
    ds_cfc.Properties.VarNames{ii} = varsunits{no,3};
    %scale
    v = getfield(ds_cfc, varsunits{no,3})*varsunits{no,5};
    ds_cfc = setfield(ds_cfc, varsunits{no,3}, v);
    %is sample var?
    if length(varsunits{no,3})>=4 & strcmp(varsunits{no,3}(end-3:end), 'flag')
       isvar(no) = 0; isflag(no) = 1;
    elseif sum(strcmp(varsunits{no,3}, {'sampnum' 'statnum' 'station' 'niskin' 'position' ''}))
       isvar(no) = 0;
    end
end
iivar = find(isvar); iiflag = find(isflag);

% make arrays for all stations
last_stn = max(floor(ds_cfc.sampnum/100));
nsamps = 24*last_stn;
sampnum = NaN+zeros(nsamps,1); statnum = sampnum; position = sampnum;

for no = iivar
   eval([varsunits{no,3} '= NaN+zeros(nsamps,1);'])
   eval([varsunits{no,3} '_flag = 9+zeros(nsamps,1);'])
end

%assign and average over duplicates
for kstn = 1:last_stn
    for kpos = 1:24;

        index = kpos+24*(kstn-1);

        snum = kstn*100+kpos;
        sampnum(index) = snum;
        statnum(index) = kstn;
        position(index) = kpos;

        kmatch = find(ds_cfc.sampnum == snum);
        if ~isempty(kmatch)
           for no = iivar
              v = getfield(ds_cfc, varsunits{no,3});
              f = getfield(ds_cfc, [varsunits{no,3} '_flag']); 
              v = v(kmatch); f = f(kmatch);
              bf = min(f); %best quality flag available for this sample
              v(f>bf) = NaN;
              eval([varsunits{no,3} '(index) = m_nanmean(v);'])
              eval([varsunits{no,3} '_flag(index) = bf;'])
           end
        end

    end
end

oopt = 'flags'; get_cropt

% sorting out units for msave
ii = sort([iivar iiflag]);
varnames = ['sampnum'; varsunits(ii,3)];
varunits = ['number'; varsunits(ii,4)];
varnames_units = {};
for k = 1:length(varnames)
    varnames_units = [varnames_units; varnames(k)];
    varnames_units = [varnames_units; {'/'}];
    varnames_units = [varnames_units; varunits(k)];
end
timestring = ['[' sprintf('%d %d %d %d %d %d',MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN) ']'];

% save
MEXEC_A.MARGS_IN = {
    otfile
    };
MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; varnames(:)];
MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; 
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
    ];
MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; varnames_units(:)];
MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN;
    '-1'
    '-1'
    ];
msave
