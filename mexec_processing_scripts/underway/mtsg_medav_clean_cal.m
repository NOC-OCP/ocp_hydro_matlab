% mtsg_medav_clean_cal: clean and calibrate SBE45 tsg data
%
% Use: mtsg_medav_clean_cal
%
% runs on appended cruise file. This draft bak on jc069
% first reduce data to 1-minute bins, using median rather than mean;
% then apply cleanup and calibration using mcalib2, using function
% mtsg_cleanup, which can be constructed for each cruise. This function can
% discard data when the pumps were off, apply adjustments, etc.
%
% modded bak jr302 second SST

mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

scriptname = 'ship'; oopt = 'ship_data_sys_names'; get_cropt
% bak jc211 ship_data_sys_names sets metpre and tsgpre

if MEXEC_G.quiet<=1
    fprintf(1,'cleaning (calling ctd_apply_autoedits) %s_%s_01.nc and averaging to one minute to make %s_%s_01_medav_clean.nc\n',tsgpre,mcruise,tsgpre,mcruise);
    fprintf(1,'calling m_apply_calibration to apply sal and temp calibrations set in opt_%s for %s_%s_01_medav_clean_cal.nc\n',mcruise,tsgpre,mcruise);
end

root_dir = mgetdir(tsgpre);
infile1 = fullfile(root_dir, [tsgpre '_' mcruise '_01']);
otfile1 = fullfile(root_dir, [tsgpre '_' mcruise '_01_medav_clean']); % 1-minute median data
otfile2 = fullfile(root_dir, [tsgpre '_' mcruise '_01_medav_clean_cal']); % 1-minute median data

if ~exist(m_add_nc(infile1),'file')
    error(['no tsg file ' infile1])
    return
end

[d,h] = mload(infile1,'/');

%clean
scriptname = mfilename; oopt = 'tsg_edits'; get_cropt
if ~isempty(tsgedits)
    [d, comment] = ctd_apply_autoedits(d, tsgedits);
    h.comment = [h.comment comment];
end

%average
scriptname = 'ship'; oopt = 'avtime'; get_cropt
avtsg = round(avtsg);
MEXEC_A.MARGS_IN = {
    infile1
    otfile1
    ' '
    'time'
    sprintf('%d 1e10 60',avtsg)
    'b'
    };
mavmed


%calibrate
scriptname = mfilename; oopt = 'tsgcals'; get_cropt
if isfield(tsgopts, 'calstr') && isfield(tsgopts, 'docal') && tsgopts.docal.salinity
    cmd = ['!/bin/cp -p ' otfile1 '.nc ' otfile2 '.nc']; eval(cmd)
    d.time = (d.time-datenum(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1),1,1))+1; %year-day
    clear dcal hcal
    eval([tsgopts.calstr.salinity.(mcruise)])
    hcal.fldnam = {'salinity_cal'};
    hcal.fldunt = {'psu'};
    mfsave(otfile2, dcal, hcal, '-addvars');
end
