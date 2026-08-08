function msbe_01_load(stn)
% msbe_01_load(stn)
%
% read in ctd data from SBE .cnv file (specified in opt_cruise),
% rename variables based on cruise options, and add units if not present,
% add NaN fields for variables that are not present on this cast (as set in
% opt_cruise)
% add position at bottom of cast to header
%
% output: _cnv.nc
%
% calls:
%     msbe_to_mstar
%     mheadr
%     mcalib
%

%%%%% setup %%%%%

m_common; MEXEC_A.mprog = mfilename;
opt1 = 'ctd_proc'; opt2 = 'ctdfiles'; get_cropt
pd = mexec_file_locations('procfiles','ctd');
dataname = sprintf(pd.ctdname,stn_string);
rawfile = sprintf(pd.ctdraw,stn_string);
if MEXEC_G.quiet<=1; fprintf(1,'converting %s to %s\n',cnvfile,rawfile); end

% input and output files
if ~exist(cnvfile,'file') && isfield(MEXEC_G,'mexec_shell_scripts')
    css = fullfile(MEXEC_G.mexec_shell_scripts,'data_to_ws','ctd_syncscript.sh');
    if exist(css,'file')
        system(['bash ' css]);
    end
end
if ~exist(cnvfile,'file')
    warning(['file ' cnvfile ' not found; make sure it''s there (and not gzipped) and return to try again, or ctrl-c to quit'])
    pause
end


%%%%% convert to mstar %%%%%

%generate file
rawfile = m_add_nc(rawfile);
if exist(rawfile,'file')
    delete(rawfile)
end
MEXEC_A.MARGS_IN = {
    cnvfile
    'y'
    'y'
    rawfile
    };
msbe_to_mstar;

%modify header platform information***
MEXEC_A.MARGS_IN = {
    rawfile
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

h = m_read_header(rawfile);
if ~ismember(h.fldnam,'time')
    warning('you are missing time variable from %s, \ndid you forget to run DatCNV with time elapsed?',cnvfile)
end
if ~ismember(h.fldnam,'scan')
    error('scan is required for processing %s',cnvfilename)
end
if ~isempty(setdiff({'pumps','latitude','longitude'},h.fldnam))
    warning('you are missing pump status, latitude, and/or longitude from %s, \ndid you forget to export them in DatCnv?',cnvfile)
end

% create NaN variables that are missing on this station
absentvars = {}; opt1 = 'ctd_proc'; opt2 = 'absentvars'; get_cropt
if ~isempty(absentvars)
    MEXEC_A.MARGS_IN = {rawfile; 'y'};
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

% in special cases, either read extra/new variables from a different set of files
% (e.g. if a variable was mistakenly not exported in initial conversion to
% .cnv, and has been exported on its own later), merging on scan, or add
% NaNs for variables that are usually present but are missing on this
% station, or if time was not exported,
opt1 = 'ctd_proc'; opt2 = 'ctd_raw_extra'; get_cropt
if ~isempty(extrasource) && ~isempty(extravars)
    if MEXEC_G.quiet<=1; fprintf(1,'adding selected variables to ctd_%s_%s_raw.nc\n',mcruise,stn_string); end
    mctd_extra(rawfile, extravars, extrasource)
end

% in special cases (i.e. yo-yo or tow-yo casts), split file into multiple
% files, or append file to existing (if data acquisition was
% stopped/restarted mid-cast)***
otfile0 = rawfile;
otfiles = {rawfile};
opt1 = 'ctd_proc'; opt2 = 'cast_split_comb'; get_cropt

if length(otfiles)>1 && exist('cast_scan_ranges','var')
    [d,h] = mload(otfile0,'/');
    t = struct2table(d);
    for fno = 1:length(otfiles)
        m = d.scan>=cast_scan_ranges(fno,1) & d.scan<=cast_scan_ranges(fno,2);
        dnew = table2struct(t(m,:),'ToScalar',true);
        [~,dataname,~] = fileparts(otfiles{fno});
        dataname = dataname(1:strfind(dataname,'_raw')-1); %***
        if isempty(dataname)
            error('otfiles %d must contain ''_raw''',fno)
        end
        hnew = h; hnew.dataname = dataname;
        hnew.comment = [hnew.comment '\n split from original ' h.dataname ' using scan range in opt_' mcruise '.m'];
        mfsave(otfiles{fno},dnew,hnew);
    end

elseif ~isempty(comb_stns) && comb_stns(1)==stnlocal
    [d,h] = mload(rawfile,'/');
    %put into time base of other file
    stn = comb_stns(2); opt1 = 'setup'; opt2 = 'm_stn_string'; get_cropt
    otfile_appendto = sprintf(pd.ctdraw,stn_string);
    h0 = m_read_header(otfile_appendto);
    d.time = m_commontime(d,'time',h,h0);
    h.fldunt(strcmp('time',h.fldnam)) = h0.fldunt(strcmp('time',h.fldnam));
    if isnan(comb_stns(3))
        %calculate from times
        d0 = mload(otfile_appendto,'scan','time','press',' ');
        comb_stns(3) = round((d.time(1)-d0.time(1))*24)+(d0.scan(1)-d.scan(1));
        warn = ' (update in opt_cruise for use by mfir_01)';
    else
        warn = '';
    end
    fprintf(1,'offsetting cast %s by %d scans%s',stn_string,comb_stns(3),warn)
    if ~isempty(warn); pause; end
    d.scan = d.scan+comb_stns(3);
    mfsave(otfile_appendto, d, h, '-merge', 'scan')
    otfiles = {otfile_appendto}; %now add bottom lat, lon to appended file

end

%other special cases e.g. typos in S/Ns
opt1 = 'ctd_proc'; opt2 = 'header_edits'; get_cropt

% Get position at bottom of cast either from ctd-logged nmea lat, lon or
% from bottom of cast time and mtposinfo/msposinfo/mrposinfo; put in header
for fno = 1:length(otfiles)
    rawfile = otfiles{fno};
    [~, ~] = getpos_for_ctd(rawfile, 'write');
end

function mctd_extra(rawfile, extravars, extrasource)

m_common

[d0, h0] = mloadq(rawfile,'/');
ow = intersect(h0.fldnam,extravars);
if ~isempty(ow) && MEXEC_G.quiet<=1
    warning('overwriting variables %s,',ow{:});
end
for fno = 1:length(extrasource)
    if exist(extrasource{fno},'file')
        [dn, hn] = msbe_to_mstar(extracnv{fno},'y','y');
        clear d h
        d.scan = d0.scan;
        h.fldnam = {'scan'}; h.fldunt = {'number'};
        %don't use mfsave merge because it might keep some old data;
        %instead, merge here
        [~,i0,in] = intersect(d0.scan, dn.scan, 'stable');
        for vno = 1:length(extravars)
            d.(extravars{vno}) = NaN+d.scan;
            d.(extravars{vno})(i0) = dn.(extravars{vno})(in);
        end
        extravars = [extravars 'scan'];
        [h.fldnam,~,ib] = intersect(extravars,hn.fldnam,'stable');
        h.fldunt = hn.fldunt(ib);
        h.comment = sprintf('with parameters added from sbe file %s',extracnv{fno});
        mfsave(rawfile, d, h, '-addvars');
    else
        clear d h
        eval(extrasource{fno})
        h.fldnam = extravars(1,fno); 
        h.fldunt = extravars(2,fno);
        h.fldserial = {'n/a'};
        h.comment = sprintf('added parameter %s',extrasource{fno});
        mfsave(rawfile, d, h, '-addvars');
    end
end



