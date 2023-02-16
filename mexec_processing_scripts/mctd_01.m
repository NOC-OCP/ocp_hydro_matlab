% mctd_01:
%
% read in ctd data from SBE .cnv file (either _align_ctm version, or _noctm);
% rename variables based on cruise options, and add units if not present,
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
if MEXEC_G.quiet<=1; fprintf(1,'converting .cnv to ctd_%s_%s_raw.nc\n',mcruise,stn_string); end

% resolve root directories for various file types
scriptname = mfilename; oopt = 'redoctm'; get_cropt

root_ctd = mgetdir('M_CTD');
dataname = ['ctd_' mcruise '_' stn_string];
if ~redoctm %default: operate on file which had the cell thermal mass correction applied in SBE Processing
    otfile = fullfile(root_ctd, [dataname '_raw.nc']);
else %in some cases, operate on original file (to remove large spikes), then apply align and CTM
    otfile = fullfile(root_ctd, [dataname '_raw_noctm.nc']);
    disp('starting from noctm file')
end

scriptname = 'castpars'; oopt = 'cast_groups'; get_cropt %define shortcasts and ticasts
scriptname = mfilename; oopt = 'cnvfilename'; get_cropt
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

%modify header platform information***
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


%%%%% rename variables, and add units where necessary %%%%%

h = m_read_header(otfile);
scriptname = mfilename; oopt = 'ctdvars'; get_cropt
names_new = h.fldnam; 
for no = 1:length(h.fldnam)
    iis = find(strcmp(h.fldnam{no},ctdvarmap(:,1)));
    if ~isempty(iis)
        if length(iis)>1
            warning('more than one mstar name listed for variable %s; using first',h.fldnam{no})
        end
        iis = iis(1);
        newname = ctdvarmap{iis,2};
        if ~strcmp(h.fldnam{no},newname)
            mm = strcmp(newname,names_new([1:no-1 no+1:end]));
            if sum(mm)
                error('more than one SBE variable with the same mstar name %s; edit ctdvarmap',newname);
            end
            names_new{no} = newname;
            nc_varrename(otfile,h.fldnam{no},newname);
        end
    end

    %units
    newunits = [];
    if isempty(h.fldunt{no})
        newunits = m_remove_outside_spaces(ctdvarmap{iis(1),3});
    elseif strcmpi(h.fldunt{no},'ITS-90, deg C') || strcmpi(h.fldunt{no},'deg C')
        newunits = 'degc90';
    elseif strcmpi(h.fldunt{no},'deg')
        newunits = 'degrees';
    elseif strcmpi(h.fldunt{no},'db')
        newunits = 'dbar';
    elseif strcmp(h.fldunt{no},'%')
        newunits = 'percent';
    end
    if ~isempty(newunits)
        nc_attput(otfile,names_new{no},'units',newunits);
    end

end

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

% in special cases, read extra/new variables from a different set of files
% (e.g. if a variable was mistakenly not exported in initial conversion to
% .cnv, and has been exported on its own later); merge on scan
scriptname = mfilename; oopt = 'extracnv'; get_cropt
if ~isempty(extracnv) && ~isempty(extravars)
    mctd_extra_cnv
end

