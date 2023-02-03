function tablemap = mrnames(mrtables_list, varargin)
% function tablemap = mrnames(mrtables_list, qflag)
%
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
%
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
%
% Define and show the mexec shorthand names (i.e. mstar filename prefixes)
% corresponding to rvdas tables in mrtables_list
%
% Examples
%
%   tablemap = mrnames(mrtables_list);
%   tablemap = mrnames(mrtables_list, 'q');
%
% Input:
%
% mrtables_list is a cell array of strings containing the rvdas table names
% If called without 'q', the table will be listed to the screen.
%
% Output:
%
% tablemap is an N x 2 cell array. Column 1 is the list of mexec short
% names. Column 2 is the list of RVDAS table names (mrtables_list limited
% to those with matching mexec short names).
% When called in mrdefine, mrtables_list is the list of tables and messages
% actually present and being ingested on this cruise; therefore the same
% mexec short name may correspond to multiple possible rvdas table names,
% as long as only one is actually present and being read in on a given
% cruise (e.g. if on one ship the pmvpos message is posmv_gpgga and on the
% other it is posmv_gpggk, both lines can be kept in the list below). If
% there are duplicate lines that both have ingested messages on a cruise,
% the first will be used (in mrdefine).


m_common

if nargin>1 && ~isempty(find(strcmp('q',varargin), 1))
    qflag = 'q';
else
    qflag = '';
end

tablemap = cell(size(mrtables_list));
for tno = 1:length(mrtables_list)
    tname = mrtables_list{tno};

    %first do the regular ones (note: in lists of instruments, for instance,
    %'seapath_320_' must come before 'seapath')

    cat.msg = {'gga','ggk','gll','pixsegpsin0'}; 
    cat.inst = {'ranger','posmv','dps116','fugro','cnav','seapath_320_','seapath','saab'};
    inst = parse_tname(cat);
    if ~isempty(inst)
        tablemap{tno} = ['pos' inst]; continue
    end
    cat.msg = {'gsa'}; 
    cat.inst = {'fugro','cnav','seapath'};
    inst = parse_tname(cat);
    if ~isempty(inst)
        tablemap{tno} = ['dop' inst]; continue
    end
    cat.msg = {'vtg'}; 
    cat.inst = {'posmv','fugro','cnav','seapath_320_','seapath','saab'};
    inst = parse_tname(cat);
    if ~isempty(inst)
        tablemap{tno} = ['vtg' inst]; continue
    end

    cat.msg = {'att','pashr','psxn23'}; 
    cat.inst = {'phins','posmv','seapath_320_','imu108_'};
    inst = parse_tname(cat);
    if ~isempty(inst)
        tablemap{tno} = ['att' inst]; continue
    end
    cat.msg = {'hdt'}; 
    cat.inst = {'posmv','seapath_320_','seapath'};
    inst = parse_tname(cat);
    if ~isempty(inst)
        tablemap{tno} = ['hdt' inst]; continue
    end

    cat.msg = {'mvw'};
    cat.inst = {'windsonic'};
    inst = parse_tname(cat);
    if ~isempty(inst)
        tablemap{tno} = [inst]; continue
    end


    cat.msg = {'winch'}; 
    cat.inst = {'winchlog','winch_sda_v'};
    inst = parse_tname(cat);
    if ~isempty(inst)
        tablemap{tno} = ['winch']; continue
    end

end

%now do the special cases
    cat.msg = {'hdt'}; 
    cat.inst = {'gyrocompass_raytheon_standard_30_','gyro','sgyro','gyrocompass_safran'};
    inst = parse_tname(cat);
    if ~isempty(inst)
        if strcmp(inst,'gyrocompass_safran')
            tablemap{tno} = ['hdtgyrosaf']; continue
        else
            tablemap{tno} = ['hdtgyro']; continue
        end
    end
    cat.msg = {'pixseheave0'}; 
    cat.inst = {'phins'};
    inst = parse_tname(cat);
    if ~isempty(inst)
        tablemap{tno} = ['hss' inst]; continue
    end
    cat.msg = {'pixseatitud'}; 
    cat.inst = {'phins'};
    inst = parse_tname(cat);
    if ~isempty(inst)
        tablemap{tno} = ['pro' inst]; continue
    end

tablemap = {

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
    
    n = 1; clear wind
    wind(n).name = 'ft';
    wind(n).msg = 'wimwv';
    wind(n).inst = 'anemometer_ft_technologies_ft702lt';
    n = n+1;
    wind(n).name = 'sonic';
    wind(n).msg = {'iimwv','pmwind'};
    wind(n).inst = {'windsonic','anemometer_metek_usonic3'};
    
    wind.ft.msg = 'wimwv';
    wind.ft.inst = 'anemometer_ft_technologies_ft702lt';
    wind.sonic.msg = {'iimwv','pmwind'};
    wind.sonic.inst = {'windsonic','anemometer_metek_usonic3_'};

    %SDA
    'windft'       'anemometer_ft_technologies_ft702lt_wimwv'
    'windsonic1'               'anemometer_metek_usonic3_1_pmwind'
    'windsonic2'               'anemometer_metek_usonic3_2_pmwind'
'windsonic3'               'anemometer_metek_usonic3_3_pmwind'
'windomc1'            'anemometer_observator_omc116_1_wimwv'
'windomc2'            'anemometer_observator_omc116_2_wimwv'
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

if isempty(qflag)

    tablemapsort = sortrows(tablemap,1);
    pad = '                                            ';
    q = '''';
    for kl = 1:size(tablemapsort,1)
        s1 = tablemapsort{kl,1}; s1 = [pad q s1 q]; s1 = s1(end-15:end);
        s2 = tablemapsort{kl,2}; s2 = [q s2 q pad]; s2 = s2(1:30);
        fprintf(MEXEC_A.Mfidterm,'%s %s\n',s1,s2);
    end

end


function inst = parse_tname(cat)
inst = '';
isc = 0; mno = 1;
while isc==0 && mno<=length(cat.msg)
    isc = strcmp(tname(end-length(cat.msg{mno}+1:end),cat.msg{mno}));
    mno = mno+1;
end
if isc
    ii1 = [];
    ino = 1;
    while isempty(ii1) && ino<=length(cat.inst)
        ii1 = findstr(tname,cat.inst{ino});
        ino = ino+1;
    end
    if ~isempty(ii1)
        ii1e = ii1+length(cat.inst{ino})-1;
        ii2 = findstr(tname(ii1e:end),'_');
        inst = tname(ii1:ii2(1)-1);
    end
end
