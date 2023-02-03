function tablemap = mrnames(varargin)
% function tablemap = mrnames(qflag)
%
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
% 
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
%
% Define and show the names of the rvdas tables and the mexec shorthand
% equivalent (i.e. mstar filename prefixes)
%
% Examples
%
%   mrnames;
%
%   mrnames q;
%
%   tablemap = mrnames('q');
%
% Input:
% 
% If called without an argument, the table will be listed to the screen.
% If called with 'q', the listing to the screen is suppressed.
%
% Output: 
% 
% tablemap is an N x 2 cell array. Column 1 is the list of mexec short
% names. Column 2 is the list of RVDAS table names. When mrnames is used
% (e.g. in mrdefine) it will be tested against the result of
% mrtables_from_json to find the messages actually present and being
% ingested on this cruise; therefore column 1 can have repeated values as
% long as only one of the corresponding messages is being read in on a
% given cruise (e.g. if on one ship the pmvpos message is posmv_gpgga and
% on the other it is posmv_gpggk, both lines can be kept in the list
% below). If there are duplicate lines that both have ingested messages on
% a cruise, the first will be used.


% Search for any of the arguments to be 'q', and set qflag = 'q' or '';
% can't call mrparseargs because that calls mrdefine which calls mrnames

m_common 

qflag = '';
allargs = varargin;
mq = strcmp('q',allargs);
if sum(mq)
    qflag = 'q';
    allargs(mq) = [];
end


tablemap = {

    'winch'        'winchlog_winch'    

    'hdtgyro'      'sgyro_hehdt'       

    'attpmv'       'posmv_pashr'       
    'hdtpmv'       'posmv_gphdt'       
    'pospmv'       'posmv_gpgga'      
    'pospmv'       'posmv_gpggk'       
    'vtgpmv'       'posmv_gpvtg'       

    'posfugro'     'fugro_gps_gpgga'  
    'vtgfugro'     'fugro_gps_gpvtg'  
    'dopfugro'     'fugro_gps_gngsa'  

    'attphins'     'phins_att_pashr'   
    'hdtphins'     'phins_att_hehdt'   
    'posphins'     'phins_att_pixsegpsin0'   % phins lat and lon
    'hssphins'     'phins_att_pixseheave0'   % phins surge sway heave
    'prophins'     'phins_att_pixseatitud'   % phins pitch and roll
    'prdphins'     'phins_att_prdid'   

    'poscnav'      'cnav_gngga'   
    'vtgcnav'      'cnav_gnvtg'   
    'dopcnav'      'cnav_gngsa'  % available on jc211
    'posdps'       'dps116_gps_gpgga'    % available on jc211
   
    'posranger'    'ranger2usbl_gpgga'   

    'attsea'       'seapathatt_psxn23'   
    'hdtsea'       'seapathgps_inhdt'   
    'possea'       'seapathgps_ingga'   
    'vtgsea'       'seapathgps_invtg'   
    'dopsea'       'seapath_pos_ingsa'  % available on jc211

    'sbe38'        'sbe38dropkeel_sbe38'   
    'surfmet'      'surfmet_gpxsm'   
    'windsonic'    'windsonicnmea_iimwv'   
    'tsg'          'sbe45_nanan'   
    'rex2wave'     'rex2_wave_pramr'   
    'wamos'        'wamos_wave_pwam'   
     
    'multib'     'em122_kidpt'   
    'singleb'    'ea640_sddpt'   
    'singleb'    'ea640_sddbs'   

    'envtemp'      'envtemp_wimta'   
    'envhumid'     'envtemp_wimhu'   

    'logchf'       'slogchernikeef_vmvbw'  % available on jc211
    'logskip'      'ships_skipperlog_vdvbw'
    'gravity'      'u12_at1m_uw'
    'mag'          'seaspy_mag_inmag'
    'magerror'     'seaspy_mag_3rr0r'
    
    %SDA
    'windft'       'anemometer_ft_technologies_ft702lt_wimwv'
    'windsonic1'               'anemometer_metek_usonic3_1_pmwind'
    'windsonic2'               'anemometer_metek_usonic3_2_pmwind'
'windsonic3'               'anemometer_metek_usonic3_3_pmwind'
'windomc1'            'anemometer_observator_omc116_1_wimwv'
'windomc2'            'anemometer_observator_omc116_2_wimwv'
'hdtphins'     'attitude_ixblue_phins_surface_heading_hehdt'
'attphins'      'attitude_ixblue_phins_surface_motion_kmatt'
'hdtsea1'            'attitude_seapath_320_1_heading_inhdt'
%'rotsea1'            'attitude_seapath_320_1_heading_inrot'
'attsea1'             'attitude_seapath_320_1_motion_kmatt'
'hdtsea2'            'attitude_seapath_320_2_heading_inhdt'
%'rotsea2'            'attitude_seapath_320_2_heading_inrot'
'attsea2'             'attitude_seapath_320_2_motion_kmatt'
'attimu'                     'attitude_smc_imu108_2_psmcv'
%'attimu'                     'attitude_smc_imu108_2_psmcb'
'vtgfugro'                      'gnss_fugro_oceanstar_gpvtg'
'vtgsaab'                      'gnss_saab_r5_supreme_gnvtg'
'possaab'                      'gnss_saab_r5_supreme_gngll'
'possea1'                        'gnss_seapath_320_1_ingga'
'vtgsea1'                        'gnss_seapath_320_1_invtg'
'possea2'                        'gnss_seapath_320_2_ingga'
'vtgsea2'                        'gnss_seapath_320_2_invtg'
'hdtgyro1'     'gyrocompass_raytheon_standard_30_mf_1_hehdt'
'rotgyro1'     'gyrocompass_raytheon_standard_30_mf_1_herot'
'hdtgyro2'     'gyrocompass_raytheon_standard_30_mf_2_hehdt'
'rotgyro2'     'gyrocompass_raytheon_standard_30_mf_2_herot'
'hdtgyrosaf'              'gyrocompass_safran_bluenaute_hehdt'
'rotgyrosaf'              'gyrocompass_safran_bluenaute_herot'
'envbir'               'met_biral_sws_200_j11302_01_pbpws:'
'skyeli'                 'met_eliasson_cbme80_2275_peceil:'
'dewmic'                'met_michell_optidew_154553_pmdew'
% 'envvai1'              'met_vaisala_hmp155e_s0850273_pvtnh'
'envvai1'             'met_vaisala_hmp155e_s0850274_pvtnh2'
'envvai2'              'met_vaisala_hmp155e_s0850275_pvtnh'
'prsvai1'               'met_vaisala_ptb330_n2410065_pvbar'
'prsvai2'               'met_vaisala_ptb330_n2410066_pvbar'
'envsch'                'platform_schneider_ap8953_ps8953'
'envyot'                     'platform_yotta_a1819_pytemp'
'envptu1'               'ptu_vaisala_ptb330_n2410065_pvbar'
'envptu2'               'ptu_vaisala_ptb330_n2410066_pvbar'
'radhei1'       'radiometer_heitronics_ct15_85_13316_phsst'
'radhei2'       'radiometer_heitronics_ct15_85_13317_phsst'
'radkip1'      'radiometer_kipp_zonen_sgr4a_190056_pkpyrge:'
'radkip2'      'radiometer_kipp_zonen_sgr4a_190057_pkpyrge:'
'radkip3'     'radiometer_kipp_zonen_smp22a_190028_pkpyran:'
'radkip4'     'radiometer_kipp_zonen_smp22a_190029_pkpyran:'
'radsat1'    'radiometer_satlantic_par_ser_icsa_2039_pspar'
'radsat2'    'radiometer_satlantic_par_ser_icsa_2040_pspar'
'singleb'                'singlebeam_kongsberg_ea640_dbdbt'
'singlebskip'                 'singlebeam_skipper_gds102_sddbt'
'svelval'      'soundvelocity_valeport_minisvs_ucsw1_pvsvs'

    };

scriptname = 'mrvdas_ingest'; oopt = 'use_cruise_views'; get_cropt
if use_cruise_views
    tablemap(:,2) = cellfun(@(x) [view_name '_' x], tablemap(:,2), 'UniformOutput', false);
end

if ~isempty(qflag); return; end

tablemapsort = sortrows(tablemap,1);

for kl = 1:size(tablemapsort,1)
    pad = '                                            ';
    q = '''';
    s1 = tablemapsort{kl,1}; s1 = [pad q s1 q]; s1 = s1(end-15:end);
    s2 = tablemapsort{kl,2}; s2 = [q s2 q pad]; s2 = s2(1:30);
    
    fprintf(MEXEC_A.Mfidterm,'%s %s\n',s1,s2);
end
