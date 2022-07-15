function rawlist = mrmakeraw
% function rawlist = mrmakeraw
%
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
% 
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
%
% Make a list of rvdas tables whose variables will be renamed to _raw when
%   read in with mrload
%
% We know it is likely these variables will have postprocessing, eg
%   calibration of TSG salinity and correction of ea600 for sound speed. By
%   labelling variables raw, we can use the main vaiable name, eg salinity
%   for the calibrated version. So we have salinity_raw and salinity, rather
%   than salinity and salinity_calibrated
%
% Examples
%
%   rawlist = mrmakeraw
%
% Input:
% 
%   None
%
% Output:
%
%   rawlist: A cell array of rvdas table names that will have all variables renamed
%            to have _raw added, at the time of reading in with mrload.
%

rawlist = {
    %     'ships_gyro_hehdt'
    %     'nmf_winch_winch'
    %     'posmv_gyro_gphdt'
    %     'posmv_att_pashr'
    %     'posmv_pos_gpgga'
    %     'posmv_pos_gpvtg'
    'surfmet_gpxsm'
    %'nmf_surfmet_gpxsm'
    %'windsonic_nmea_iimwv'
    %     'cnav_gps_gngga'
    %     'cnav_gps_gnvtg'
    %     'cnav_gps_gngsa'
    %     'dps116_gps_gpgga'
    %     'em120_depth_kidpt'
    'em640_sddbs'
    %'em122_kidpt'
    %'em600_depth_sddbs'
    %     'env_temp_wimta'
    %     'env_temp_wimhu'
    %     'ranger2_usbl_gpgga'
    'sbe45_nanan'
    %'sbe45_tsg_nanan'
    %     'seapath_pos_ingga'
    %     'seapath_pos_ingsa'
    %     'seapath_pos_invtg'
    %     'seapath_att_psxn23'
    %'ships_chernikeef_vmvbw'
    %'ships_skipperlog_vdvbw'
    'slog_chernikeef_vmvbw'
    %     'u12_at1m_uw'
    %     'seaspy_mag_inmag'
    };