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
% Define and show the names of the rvdas tables and the mexec shorthand equivalent.
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
% If called without an agrument, the table will be listed to the screen.
% If called with 'q', the listing to the screen is suppressed.
%
% Output: 
% 
% tablemap is an N x 2 cell array. Column 1 is the list of mexec short
% names. Column 2 is the list of RVDAS table names.


% Search for any of the arguments to be 'q', and set qflag = 'q' or '';
% can't call mrparseargs because that calls mrdefine which calls mrnames

m_common 

qflag = '';
allargs = varargin;
kq = find(strcmp('q',allargs));
if ~isempty(kq)
    qflag = 'q';
    allargs(kq) = [];
else
    qflag = '';
end



tablemap = {

    'winch'        'nmf_winch_winch'
%
    'hdtgyro'      'ships_gyro_hehdt'
%
    'attpmv'       'posmv_pos_pashr'
    'hdtpmv'       'posmv_pos_gphdt'
    'pospmv'       'posmv_pos_gpgga'
    'vtgpmv'       'posmv_pos_gpvtg'
%
    'posfugro'     'fugro_gps_gpgga'
    'vtgfugro'     'fugro_gps_gpvtg'
    'dopfugro'     'fugro_gps_gngsa'
%
    'attphins'     'phins_att_pashr'
    'hdtphins'     'phins_att_hehdt'
    'posphins'     'phins_att_pixsegpsin0' % phins lat and lon
    'hssphins'     'phins_att_pixseheave0' % phins surge sway heave
    'prophins'     'phins_att_pixseatitud' % phins pitch and roll
    'prdphins'     'phins_att_prdid'
%
    'poscnav'      'cnav_gps_gngga'
    'vtgcnav'      'cnav_gps_gnvtg'
%     'dopcnav'      'cnav_gps_gngsa'  % available on jc211

%     'posdps'       'dps116_gps_gpgga' % available on jc211
   
    'posranger'    'ranger2_usbl_gpgga'
%
    'attsea'       'seapath_att_psxn23'
    'hdtsea'       'seapath_pos_inhdt'
    'possea'       'seapath_pos_ingga'
    'vtgsea'       'seapath_pos_invtg'
%     'dopsea'       'seapath_pos_ingsa'  % available on jc211
%
    'surfmet'      'nmf_surfmet_gpxsm'
%     'windsonic'    'windsonic_nmea_iimwv'
    'multib_t'     'em122_depth_kidpt'  %     'em120'        'em120_depth_kidpt'    on jc211
    'singleb'      'em640_depth_sddbs'  %     'ea600'        'em600_depth_sddbs'    on jc211
    'singleb_t'    'em640_depth_sddpt'
    'envtemp'      'env_temp_wimta'
    'envhumid'     'env_temp_wimhu'
    'rex2wave'     'rex2_wave_pramr'
    'wamos'        'wamos_wave_pwam'
    'tsg'          'sbe45_tsg_nanan'
%     'logchf'       'ships_chernikeef_vmvbw'  % available on jc211
    'logskip'      'ships_skipperlog_vdvbw'
    'gravity'      'u12_at1m_uw'
    'mag'          'seaspy_mag_inmag'
    'magerror'     'seaspy_mag_3rr0r'
    };

if ~isempty(qflag); return; end

tablemapsort = sortrows(tablemap,1);

for kl = 1:size(tablemapsort,1)
    pad = '                                            ';
    q = '''';
    s1 = tablemapsort{kl,1}; s1 = [pad q s1 q]; s1 = s1(end-15:end);
    s2 = tablemapsort{kl,2}; s2 = [q s2 q pad]; s2 = s2(1:30);
    
    fprintf(MEXEC_A.Mfidterm,'%s %s\n',s1,s2);
end
