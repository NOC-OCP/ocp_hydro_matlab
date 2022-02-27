% mctd_01: 
% 
% read in ctd data from SBE .cnv file (either _align_ctm version, or _noctm);
% rename variables according to ctd_renamelist.csv (formerly done by mctd_02a), 
% add units***, 
% add NaN fields for variables that are not present on this cast (as set in
% opt_cruise)
% add position at bottom of cast to header (formerly done by mctd_02a)
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

%%%%% setup %%%%%

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
    cnvfile = fullfile(root_cnv, cnvfile);
    otfile = fullfile(root_ctd, [dataname '_raw.nc']);
else %in some cases, operate on original file (to remove large spikes), then apply align and CTM
    cnvfile = fullfile(root_cnv, cnvfile); %align and ctm will be reapplied
    otfile = fullfile(root_ctd, [dataname '_raw_noctm.nc']);
    disp('starting from noctm file')
end

if ~exist(cnvfile,'file')
    warning(['file ' cnvfile ' not found; make sure it''s there (and not gzipped) and return to try again, or ctrl-c to quit'])
    pause
end

if exist(otfile,'file') 
    m = ['File' ];
    m1 = otfile ;
    m2 = ['already exists and is probably write protected'];
    m3 = ['If you want to overwrite it, return to continue; otherwise ctrl-c to quit'];
    fprintf(MEXEC_A.Mfider,'%s\n',m,' ',m1,' ',m2,m3)
    pause
    system(['chmod 644 ' m_add_nc(otfile)]);
end


%%%%% convert to mstar %%%%%

%generate file
MEXEC_A.MARGS_IN = {
    cnvfile
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
if ~isempty(ctdvars_add)
    dsv.sbename = [dsv.sbename; ctdvars_add(:,1)];
    dsv.varname = [dsv.varname; ctdvars_add(:,2)];
    dsv.varunit = [dsv.varunit; ctdvars_add(:,3)];
end
if length(unique(dsv.sbename))<length(dsv.sbename)
    error(['There is a duplicate name in the list of variables to rename; use ctdvars_replace rather than ctdvars_add in opt_' mcruise]);
end
[varnames, junk, iiv] = mvars_in_file(dsv.sbename, otfile);
dsv = dsv(iiv,:);
varnames_units = cell(3,length(dsv));
for vno = 1:length(dsv)
    varnames_units{1,vno} = dsv.sbename{vno};
    if ~isempty(ctdvars_replace)
        iir = find(strcmp(ctdvars_replace(:,1), dsv.sbename{vno}));
    else
        iir = [];
    end
    if isempty(iir)
        varnames_units(2:3,vno) = {dsv.varname{vno}; dsv.varunit{vno}};
    else
        varnames_units(2:3,vno) = {ctdvars_replace{iir,2}; ctdvars_replace{iir,3}};
    end
end
varnames_units = varnames_units(:);

%edit file names and units in header
MEXEC_A.MARGS_IN_1 = {
    otfile
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

% create NaN variables that are in mcvars_list but not present for this station
scriptname = mfilename; oopt = 'absentvars'; get_cropt
if ~isempty(absentvars)
    MEXEC_A.MARGS_IN = {otfile; 'y'};
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
h = m_read_header(otfile);
if sum(strcmp('latitude',h.fldnam)) && sum(strcmp('longitude',h.fldnam))
    d = mloadq(otfile,'press','latitude','longitude',' ');
    kbot = find(d.press == max(d.press), 1 );
    botlat = d.latitude(kbot); botlon = d.longitude(kbot);
else
    [d, h] = mloadq(otfile,'time','press',' ');
    kbot = find(d.press == max(d.press), 1 );
    tbot = d.time(kbot);
    tbotmat = datenum(h.data_time_origin) + tbot/86400; % bottom time as matlab datenum
    switch MEXEC_G.Mshipdatasystem
        case 'scs'
            [botlat, botlon] = msposinfo(tbotmat);
        case 'techsas'
            [botlat, botlon] = mtposinfo(tbotmat);
        case 'rvdas'
            [botlat, botlon] = mrposinfo(tbotmat);
        otherwise
            botlat = []; botlon = [];
    end
end
if ~isempty(botlat)
    latstr = sprintf('%14.8f',botlat);
    lonstr = sprintf('%14.8f',botlon);
    MEXEC_A.MARGS_IN = {
        otfile
        'y'
        '5'
        latstr
        lonstr
        ' '
        ' '
        };
    mheadr
end

system(['chmod 444 ' m_add_nc(otfile)]);

