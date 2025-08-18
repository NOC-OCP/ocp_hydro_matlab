function mctd_01(stn)
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
opt1 = 'ctd_proc'; opt2 = 'minit'; get_cropt
if MEXEC_G.quiet<=1; fprintf(1,'converting .cnv to ctd_%s_%s_raw.nc\n',mcruise,stn_string); end

% resolve root directories for various file types
redoctm = 0; opt1 = 'ctd_proc'; opt2 = 'redoctm'; get_cropt
root_ctd = mgetdir('M_CTD');
cdir = mgetdir('M_CTD_CNV');
dataname = ['ctd_' mcruise '_' stn_string];
if ~redoctm %default: operate on file which had the cell thermal mass correction applied in SBE Processing
    otfile = fullfile(root_ctd, [dataname '_raw.nc']);
    cnvfile = fullfile(cdir, sprintf('%s_%03d_align_ctm.cnv',upper(mcruise),stn));
else %in some cases, operate on original file (e.g. to remove large spikes), then apply align and CTM
    otfile = fullfile(root_ctd, [dataname '_raw_noctm.nc']);
    cnvfile = fullfile(cdir, sprintf('%s_%03d.cnv',upper(mcruise),stn));
    disp('starting from noctm file')
end
%now overwrite defaults if relevant
opt1 = 'ctd_proc'; opt2 = 'cnvfilename'; get_cropt
if ~exist(cnvfile,'file') && isfield(MEXEC_G,'mexec_shell_scripts')
    css = fullfile(MEXEC_G.mexec_shell_scripts,'ctd_syncscript');
    if exist(css,'file')
        system(css);
        if exist(cnvfile,'file')
            warn = 0;
        end
    end
end
if ~exist(cnvfile,'file')
    warning(['file ' cnvfile ' not found; make sure it''s there (and not gzipped) and return to try again, or ctrl-c to quit'])
    pause
end


%%%%% convert to mstar %%%%%

%generate file
otfile = m_add_nc(otfile);
if exist(otfile,'file')
    delete(otfile)
end
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
ctdvarmap = {'prDM','press','dbar'
    't090C','temp1','degc90'
    't190C','temp2','degc90'
    'altM','altimeter','meters'
    'ptempC','pressure_temp','degc90'
    'timeS','time','seconds'
    'scan','scan','number'
    'pumps','pumps','pump_status'
    'latitude','latitude','degrees'
    'longitude','longitude','degrees'
    'c0mS_slash_cm','cond1','mS/cm'
    'c1mS_slash_cm','cond2','mS/cm'
    'sbeox0V','sbeoxyV1','volts'
    'sbox0Mm_slash_Kg','oxygen_sbe1','umol/kg'
    'sbeox1V','sbeoxyV2','volts'
    'sbox1Mm_slash_Kg','oxygen_sbe2','umol/kg'
    'T2_minus_T190C','t2_minus_t1','degc90'
    'C2_minus_C1mS_slash_cm','c2_minus_c1','mS/cm'
    'flECO_minus_AFL','fluor','mg/m^3'
    'flC','fluor','ug/l'
    'wetStar','fluor','mg/m^3'
    'wetCDOM','fluor_cdom','mg/m^3'
    'xmiss','transmittance','percent'
    'CStarTr0','transmittance','percent'
    'transmittance','transmittance','percent'
    'CStarAt0','attenuation','1/m'
    'turbWETbb0','turbidity','m^-1/sr'
    'turbWETntu0','turbidity','NTU'
    'par','par','umol photons/m^2/sec'
    'par_slash_sat_slash_log','par','umol photons/m^2/sec'
    'par1','par_downlook','umol photons/m^2/sec'};
opt1 = 'ctd_proc'; opt2 = 'ctdvars'; get_cropt
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
absentvars = {}; opt1 = 'ctd_proc'; opt2 = 'absentvars'; get_cropt
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

% in special cases, read extra/new variables from a different set of files
% (e.g. if a variable was mistakenly not exported in initial conversion to
% .cnv, and has been exported on its own later); merge on scan
extracnv = {}; extravars = {}; opt1 = 'ctd_proc'; opt2 = 'extracnv'; get_cropt
if ~isempty(extracnv) && ~isempty(extravars)
    mctd_extra_cnv
end

% in special cases (i.e. yo-yo or tow-yo casts), split file into multiple
% files, or append file to existing (if data acquisition was
% stopped/restarted mid-cast)***
otfile0 = otfile;
otfiles = {otfile};
opt1 = 'ctd_proc'; opt2 = 'cast_split_comb'; get_cropt

if length(otfiles)>1 && exist('cast_scan_ranges','var')
    [d,h] = mload(otfile0,'/');
    t = struct2table(d);
    for fno = 1:length(otfiles)
        m = d.scan>=cast_scan_ranges(fno,1) & d.scan<=cast_scan_ranges(fno,2);
        dnew = table2struct(t(m,:),'ToScalar',true);
        [~,dataname,~] = fileparts(otfiles{fno});
        dataname = dataname(1:strfind(dataname,'_raw')-1);
        if isempty(dataname)
            error('otfiles %d must contain ''_raw''',fno)
        end
        hnew = h; hnew.dataname = dataname;
        hnew.comment = [hnew.comment '\n split from original ' h.dataname ' using scan range in opt_' mcruise '.m'];
        mfsave(otfiles{fno},dnew,hnew);
    end

elseif exist('otfile_appendto','var') && exist('cast_scan_offset','var') && cast_scan_offset(1)==stnlocal
    [d,h] = mload(otfile,'/');
    %put into time base of other file
    h0 = m_read_header(otfile_appendto);
    d.time = m_commontime(d,'time',h,h0);
    h.fldunt(strcmp('time',h.fldnam)) = h0.fldunt(strcmp('time',h.fldnam));
    if isnan(cast_scan_offset(3))
        %calculate from times
        d0 = mload(otfile_appendto,'scan','time','press',' ');
        cast_scan_offset(3) = round((d.time(1)-d0.time(1))*24)+(d0.scan(1)-d.scan(1));
    end
    sprintf('offsetting cast %s by %d scans (update in opt_cruise for use by mfir_01)',stn_string,cast_scan_offset(3))
    d.scan = d.scan+cast_scan_offset(3);
    mfsave(otfile_appendto, d, h, '-merge', 'scan')
    otfiles = {otfile_appendto}; %now add bottom lat, lon to appended file

end

%other special cases e.g. typos in S/Ns
opt1 = 'ctd_proc'; opt2 = 'header_edits'; get_cropt

% Get position at bottom of cast either from ctd-logged nmea lat, lon or
% from bottom of cast time and mtposinfo/msposinfo/mrposinfo; put in header
for fno = 1:length(otfiles)
    otfile = otfiles{fno};
    [botlon, botlat] = getpos_for_ctd(otfile, 'write');
end

