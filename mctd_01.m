% mctd_01: 
% 
% input: SBE .cnv, either _align_ctm version or _noctm
%
% read in ctd data from .cnv file;
% rename variables according to ctd_renamelist.csv, and add units***;
% add NaN fields for variables that are not present on this cast (as set in
% opt_cruise)
% add position at bottom of cast to header 
%
%     [this now incorporates the renaming and position-adding portion of 
%     mctd_02a, the editing and align and ctm application portions having
%     been incorporated into mctd_02b]
%
% output: _raw.nc or _raw_noctm.nc (write-protected***)
%
% Use: mctd_01        and then respond with station number, or for station 16
%      stn = 16; mctd_01;
%
% calls: 
%     msbe_to_mstar
%     mheadr
%     mcalib
%

m_common; MEXEC_A.mprog = mfilename;
scriptname = 'castpars'; oopt = 'minit'; get_cropt 
mdocshow(mfilename, ['converts from .cnv to ctd_' mcruise '_' stn_string '_raw.nc']);

% resolve root directories for various file types
root_cnv = mgetdir('M_CTD_CNV');
root_ctd = mgetdir('M_CTD'); 
root_templates = mgetdir('M_TEMPLATES');

dataname = ['ctd_' mcruise '_' stn_string];

scriptname = mfilename; oopt = 'redoctm'; get_cropt
scriptname = mfilename; oopt = 'cnvfilename'; get_cropt
if ~redoctm %default: operate on file which had the cell thermal mass correction applied in SBE Processing
    infile = fullfile(root_cnv, infile);
    otfile = fullfile(root_ctd, [dataname '_raw.nc']);
else %in some cases, operate on original file (to remove large spikes), then apply align and CTM
    infile = fullfile(root_cnv, infile); %align and ctm will be reapplied
    otfile = fullfile(root_cnv, [dataname '_raw_noctm.nc']);
    disp('starting from noctm file')
end

if ~exist(infile,'file')
    warning(['file ' infile ' not found; make sure it''s there (and not gzipped) and return to try again, or ctrl-c to quit'])
    pause
end

if exist(otfile,'file') 
    m = ['File' ];
    m1 = otfile ;
    m2 = ['already exists and is probably write protected'];
    m3 = ['If you want to overwrite it, return to continue; otherwise ctrl-c to quit'];
    fprintf(MEXEC_A.Mfider,'%s\n',m,' ',m1,' ',m2,m3)
    pause
    system(['chmod 644 ' m_add_nc(otfile)])
end


%%%%% convert to mstar %%%%%

%generate file
MEXEC_A.MARGS_IN = {
    infile
    'y'
    'y'
    otfile
    };
msbe_to_mstar;

%modify header
MEXEC_A.MARGS_IN = {
    otfile
    'y'
    '1'
    dataname
    ' '
    '2'
    MEXEC_G.PLATFORM_TYPE
    MEXEC_G.PLATFORM_IDENTIFIER
    MEXEC_G.PLATFORM_NUMBER
    '/'
    '8'
    '-1'
    '-1'
    };
mheadr


%%%%% rename variables, and add units where necessary*** %%%%%

renamefile = fullfile(root_templates, 'ctd_renamelist.csv'); 
dsv = dataset('File', renamefile, 'Delimiter', ',');
scriptname = mfilename; oopt = 'ctdvars'; get_cropt
if length(ctdvars_add)>0
    dsv.sbename = [dsv.sbename; ctdvars_add(:,1)];
    dsv.varname = [dsv.varname; ctdvars_add(:,2)];
    dsv.varunit = [dsv.varunit; ctdvars_add(:,3)];
end
if length(unique(dsv.sbename))<length(dsv.sbename)
    error(['There is a duplicate name in the list of variables to rename; use ctdvars_replace rather than ctdvars_add in opt_' mcruise]);
end
[varnames, junk, iiv] = mvars_in_file(dsv.sbename, infile);
dsv = dsv(iiv,:);
varnames_units = {};
for vno = 1:length(dsv)
    if length(ctdvars_replace)>0
        iir = find(strcmp(ctdvars_replace(:,1), dsv.sbename{vno}));
    else
        iir = [];
    end
    if length(iir)==0
        varnames_units = [varnames_units; dsv.sbename{vno}; dsv.varname{vno}; dsv.varunit{vno}];
    else
        varnames_units = [varnames_units; dsv.sbename{vno}; ctdvars_replace{vno,2}; ctdvars_replace{vno,3}];
    end
end

%edit file names and units in header
MEXEC_A.MARGS_IN_1 = {
    infile
    'y'
    '8'
    };
MEXEC_A.MARGS_IN_2 = varnames_units;
MEXEC_A.MARGS_IN_3 = {
    '-1'
    '-1'
    };
MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN_1; MEXEC_A.MARGS_IN_2; MEXEC_A.MARGS_IN_3];
mheadr

% NaN variables that are in mcvars_list but not present for this station
scriptname = mfilename; oopt = 'absentvars'; get_cropt
if length(absentvars)>0
    MEXEC_A.MARGS_IN = {infile; 'y'};
    for kabs = 1:length(absentvars)
        MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN;
            absentvars{kabs}
            'y = x+nan'
            ' '
            ' '];
    end
    MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; ' '];
    mcalib
end

% Get position at bottom of cast either from ctd-logged nmea lat, lon or
% from bottom of cast time and mtposinfo/msposinfo/mrposinfo; put in header
h = m_read_header(infile);
if sum(strcmp('latitude',h.fldnam)) & sum(strcmp('longitude',h.fldnam))
    d = mloadq(infile,'press','latitude','longitude',' ');
    kbot = min(find(d.press == max(d.press)));
    botlat = d.latitude(kbot); botlon = d.longitude(kbot);
else
    [d h] = mloadq(infile,'time','press',' ');
    kbot = min(find(d.press == max(d.press)));
    tbot = d.time(kbot);
    tbotmat = datenum(h.data_time_origin) + tbot/86400; % bottom time as matlab datenum
    switch MEXEC_G.Mshipdatasystem
        case 'scs'
            [botlat botlon] = msposinfo(tbotmat);
        case 'techsas'
            [botlat botlon] = mtposinfo(tbotmat);
        case 'rvdas'
            [botlat botlon] = mrposinfo(tbotmat);
        otherwise
            botlat = []; botlon = [];
    end
end
if length(botlat>0)
    latstr = sprintf('%14.8f',botlat);
    lonstr = sprintf('%14.8f',botlon);
    MEXEC_A.MARGS_IN = {
        infile
        'y'
        '5'
        latstr
        lonstr
        ' '
        ' '
        };
    mheadr
end

system(['chmod 444 ' m_add_nc(otfile)])

