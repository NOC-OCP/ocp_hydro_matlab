function [vars, varsh] = mvars_outvars_formats(formtyp, datatyp)
%function [vars, varsh] = mvars_outvars_formtyp(formtyp, datatyp);
%
% Lists of lookups for renaming/reformatting mstar variables, as well as
% associated required metadata) according to the formtyp and the datatyp,
% e.g.
%
% [vars, varsh] = mvars_outvars_formats('exch', 'ctd')
% or
% [vars, vars] = mvars_outvars_formats('exch', 'sam')
% give a list of mstar variable names with corresponding exchange format
% names and units and format strings for use with fprintf
%
% variables not in files will be skipped, as well as variables listed in
% opt_cruise under ***

varsh = {}; vars = {};

switch formtyp

    case 'exch'

        switch datatyp

            case 'ctd'

                varsh = { 'expocode'          ,    'EXPOCODE' ,    ' ',    '%s'    ;
                    'sect_id'           ,    'SECT_ID'  ,    ' ',    '%s'    ;
                    'date'              ,    'DATE'     ,    ' ',    '%s'    ;
                    'time'              ,    'TIME'     ,    ' ',    '%s'    ;
                    'latitude'          ,    'LATITUDE' ,    ' ',    '%9.5f' ;
                    'longitude'         ,    'LONGITUDE',    ' ',    '%10.5f';
                    'water_depth_metres',    'DEPTH'    ,    ' ',    '%4.0f' ;
                    'statnum'           ,    'STNNBR'   ,    ' ',    '%3d'   ;
                    'castno'            ,    'CASTNO'   ,    ' ',    '%d'    };
                vars = {'press',  'CTDPRS',         'DBAR',        '%8.1f';
                    'press_flag',        'CTDPRS_FLAG_W',  ' ',           '%d'   ;
                    'temp',              'CTDTMP',         'ITS-90',      '%7.4f';
                    'temp_flag',         'CTDTMP_FLAG_W',  ' ',           '%d'   ;
                    'psal',              'CTDSAL',         'PSS-78',      '%7.4f';
                    'psal_flag',         'CTDSAL_FLAG_W',  ' ',           '%d'   ;
                    'oxy',               'CTDOXY',         'UMOL/KG',     '%6.1f';
                    'oxy_flag',          'CTDOXY_FLAG_W',  ' ',           '%d'   ;
                    'turbidity',         'CTDTURB',        'M^1/SR',      '%8.6f';
                    'turbidity_flag',    'CTDTURB_FLAG_W', ' ',           '%d'   ;
                    'transmittance',     'CTDXMISS',       '%TRANS',      '%8.4f';
                    'transmittance_flag','CTDXMISS_FLAG_W',' ',           '%d'   ;
                    'fluor',             'CTDFLUOR',       'MG/M^3',      '%7.4f';
                    'fluor_flag',        'CTDFLUOR_FLAG_W',' ',           '%d'   ;
                    'par',               'PAR',            'UMOL/M^2/SEC','%6.5f';
                    'par_flag',          'PAR_FLAG_W',     ' ',           '%d'   ;
                    'par_up',            'PAR',            'UMOL/M^2/SEC','%6.5f';
                    'par_up_flag',       'PAR_FLAG_W',     ' ',           '%d'   ;
                    'ph', 'CTDPH', ' ', '%8.4f';
                    'ph_flag', 'CTDPH_FLAG_W', ' ', '%d'};

            case 'sam' % this is for bottle samples and corresponding CTD data

                varsh = {}; %none defined?
                vars = {'expocode',         'EXPOCODE', ' ', '%s';
                    'sect_id',           'SECT_ID',        ' ',           '%s'    ;
                    'statnum',           'STNNBR',         ' ',           '%3d'   ;
                    'castno',            'CASTNO',         ' ',           '%d'    ;
                    'position',          'SAMPNO',         ' ',           '%2d'   ;
                    'niskin',            'BTLNBR',         ' ',           '%d'    ;
                    'niskin_flag',       'BTLNBR_FLAG_W',  ' ',           '%d'    ;
                    'bottle_qc_flag',    'BTLNBR_FLAG_W',  ' ',           '%d'    ;
                    'datetime',          'DATE, TIME',     ' ',           '%s'    ;
                    'stnlat',            'LATITUDE',       ' ',           '%9.5f' ;
                    'stnlon',            'LONGITUDE',      ' ',           '%10.5f';
                    %'ulatitude', 'BTL_LAT', ' ', '%9.5f';
                    %'ulongitude', 'BTL_LON', ' ', '%10.5f';
                    'stndepth',          'DEPTH',          'METERS',      '%4.0f' ;
                    'upress',            'CTDPRS',         'DBAR',        '%6.1f' ;
                    'utemp',             'CTDTMP',         'ITS-90',      '%7.4f' ;
                    'sbe35temp',         'SBE35',          'ITS-90',      '%7.4f' ;
                    'sbe35temp_flag',    'SBE35_FLAG_W',   ' ',           '%d'    ;
                    'upsal',             'CTDSAL',         'PSS-78',      '%7.4f' ;
                    'upsal_flag',        'CTDSAL_FLAG_W',  ' ',           '%d'    ;
                    'botpsal',           'SALNTY',         'PSS-78',      '%7.4f' ;
                    'botpsal_flag',      'SALNTY_FLAG_W',  ' ',           '%d'    ;
                    'uoxy',              'CTDOXY',         'UMOL/KG',     '%6.1f' ;
                    'uoxy_flag',         'CTDOXY_FLAG_W',  ' ',           '%d'    ;
                    'botoxy',            'oxy',            'UMOL/KG',     '%6.1f' ;
                    'botoxy_flag',       'oxy_FLAG_W',     ' ',           '%d'    ;
                    'ufluor',            'CTDFLUOR',       'MG/M^3',      '%7.4f' ;
                    'ufluor_flag',       'CTDFLUOR_FLAG_W',' ',           '%d'    ;
                    'botchla',           'CHLORA',         'ML/L',        '%7.1f' ;
                    'botchla_flag',      'CHLORA_FLAG_W',  ' ',           '%d'    ;
                    'turbidity',         'CTDTURB',        'M^1/SR',      '%8.6f' ;
                    'turbidity_flag',    'CTDTURB_FLAG_W', ' ',           '%d'    ;
                    'transmittance',     'CTDXMISS',       '%TRANS',      '%8.4f' ;
                    'transmittance_flag','CTDXMISS_FLAG_W',' ',           '%d'    ;
                    'upar',              'PAR',            'UMOL/M^2/SEC','%6.5f' ;
                    'upar_flag',         'PAR_FLAG_W',     ' ',           '%d'    ;
                    %'uph', 'CTDPH', ' ', '%8.4f';
                    'upden',             'CTDSIG0',        'KG/M^3',      '%8.2f' ;
                    'pden',              'BOTSIG0',        'KG/M^3',      '%8.2f' ;
                    'silc',              'SILCAT',         'UMOL/KG',     '%8.3f' ;
                    'silc_flag',         'SILCAT_FLAG_W',  ' ',           '%d'    ;
                    'no3',               'NITRAT',         'UMOL/KG',     '%8.3f' ;
                    'no3_flag',          'NITRAT_FLAG_W',  ' ',           '%d'    ;
                    'no2',               'NITRIT',         'UMOL/KG',     '%8.2f' ;
                    'no2_flag',          'NITRIT_FLAG_W',  ' ',           '%d'    ;
                    'totnit',            'NO2+NO3',        'UMOL/KG',     '%8.3f' ;
                    'totnit_flag',       'NO2+NO3_FLAG_W', ' ',           '%d'    ;
                    'phos',              'PHSPHT',         'UMOL/KG',     '%8.3f' ;
                    'phos_flag',         'PHSPHT_FLAG_W',  ' ',           '%d'    ;
                    'amon',              'AMMONI',         'UMOL/KG',     '%8.3f' ;
                    'amon_flag',         'AMMONI_FLAG_W',  ' ',           '%d'    ;
                    'alk',               'ALKALI',         'UMOL/KG',     '%8.1f' ;
                    'alk_flag',          'ALKALI_FLAG_W',  ' ',           '%d'    ;
                    'dic',               'TCARBN',         'UMOL/KG',     '%8.1f' ;
                    'dic_flag',          'TCARBN_FLAG_W',  ' ',           '%d'    ;
                    'cfc11',             'CFC-11',         'PMOL/L',      '%8.3f' ;
                    'cfc11_flag',        'CFC-11_FLAG_W',  ' ',           '%d'    ;
                    'cfc12',             'CFC-12',         'PMOL/L',      '%8.3f' ;
                    'cfc12_flag',        'CFC-12_FLAG_W',  ' ',           '%d'    ;
                    'f113',              'CFC113',         'PMOL/L',      '%8.3f' ;
                    'f113_flag',         'CFC113_FLAG_W',  ' ',           '%d'    ;
                    'ccl4',              'CCL4',           'PMOL/L',      '%8.3f' ;
                    'ccl4_flag',         'CCL4_FLAG_W',    ' ',           '%d'    ;
                    'sf6',               'SF6',            'FMOL/L',      '%8.3f' ;
                    'sf6_flag',          'SF6_FLAG_W',     ' ',           '%d'    ;
                    'sf5cf3',            'SF5CF3',         'FMOL/L',      '%8.3f' ;
                    'sf5cf3_flag',       'SF5CF3_FLAG_W',  ' ',           '%d'    ;
                    'del14c',            'DELC14',         '/MILLE',      '%8.2f' ;
                    'del14c_flag',       'DELC14_FLAG_W',  ' ',           '%d'    ;
                    'del13c',            'DELC13',         '/MILLE',      '%8.2f' ;
                    'del13c_flag',       'DELC13_FLAG_W',  ' ',           '%d'    ;
                    'del18o',            'DELO18',         '/MILLE',      '%8.4f' ;
                    'del18o_flag',       'DELO18_FLAG_W',  ' ',           '%d'    ;
                    'del15n',            'D15N_NO3',       '/MILLE',      '%8.4f' ;
                    'del15n_flag',       'D15N_NO3_FLAG_W',' ',           '%d'    ;
                    'del30si',           'DELSI30',        '/MILLE',      '%8.4f' ;
                    'del30si_flag',      'DELSI30_FLAG_W', ' ',           '%d'    ;
                    'fe',                'FE',             'NMOL/L',      '%7.4f' ;
                    'fe_flag',           'FE_FLAG_W',      ' ',           '%d'    ;
                    'ra226',             'RA-226',         'DM/.1MG',     '%7.4f' ;
                    'ra226_flag',        'RA-226_FLAG_W',  ' ',           '%d'    ;
                    'ra228',             'RA-228',         'DM/.1MG',     '%7.4f' ;
                    'ra228_flag',        'RA-228_FLAG_W',  ' ',           '%d'    ;
                    'poc',               'POC',            'UG/L',        '%7.1f' ;
                    'poc_flag',          'POC_FLAG_W',     ' ',           '%d'    };
        end

    case 'bodc'

    case 'summary'
        
end
