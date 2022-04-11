function varlist = mrvdasnames(show);


varlist = {
    'gyro_s'      'ships_gyro_hehdt'
    'winch'   'nmf_winch_winch'
    'gyropmv' 'posmv_gyro_gphdt'
    'attposmv' 'posmv_att_pashr'
    'posmvpos' 'posmv_pos_gpgga'
    'posmvvtg' 'posmv_pos_gpvtg'
    'surfmet' 'nmf_surfmet_gpxsm'
    'windsonic' 'windsonic_nmea_iimwv'
    'cnav' 'cnav_gps_gngga'
    'cnavvtg' 'cnav_gps_gnvtg'
    'cnavdop' 'cnav_gps_gngsa'
    'posdps' 'dps116_gps_gpgga'
    'em120' 'em120_depth_kidpt'
    'ea600m' 'em600_depth_sddbs'
    'sim' 'em600_depth_sddbs'
    'envtemp' 'env_temp_wimta'
    'envhumid' 'env_temp_wimhu'
    'posranger' 'ranger2_usbl_gpgga'
    'tsg' 'sbe45_tsg_nanan'
    'seapos' 'seapath_pos_ingga'
    'seadop' 'seapath_pos_ingsa'
    'seavtg' 'seapath_pos_invtg'
    'attsea' 'seapath_att_psxn23'
    'log_chf' 'ships_skipperlog_vdvbw'
    'log_skip' 'ships_skipperlog_vdvbw'
    'gravity' 'u12_at1m_uw'
    'mag' 'seaspy_mag_inmag'
    };

if nargin > 0; return; end

for kl = 1:size(varlist,1)
    pad = '                                            ';
    q = '''';
    s1 = varlist{kl,1}; s1 = [pad q s1 q]; s1 = s1(end-15:end);
    s2 = varlist{kl,2}; s2 = [q s2 q pad]; s2 = s2(1:30);
    
    fprintf(1,'%s %s\n',s1,s2);
end