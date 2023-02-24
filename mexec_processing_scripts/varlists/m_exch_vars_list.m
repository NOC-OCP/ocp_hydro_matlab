function [vars, varsh] = m_exch_vars_list(typ)
%function [vars, varsh] = m_exch_vars_list(typ);
%
% Lists of woce exchange format variable names, units, mstar variable
% names, and format strings for printing to _ct1.csv (CTD data, typ=1) or
% _hy1.csv (bottle sample data, typ=2)
%
% you can just add to this list (from the WOCE exchange format documentation); 
% variables not in files will be skipped,
% and in opt_cruise under scriptname = 'mout_cchdo' you can set lists of
% variables (mstar names) to exclude even if they are in the files

if typ==1 % this is for ctd profiles
    
    varsh = {'EXPOCODE', ' ', 'expocode', '%s'
        'SECT_ID', ' ', 'sect_id', '%s'
        'DATE, TIME', ' ', 'datetime', '%s'
        'LATITUDE', ' ', 'latitude', '%9.5f'
        'LONGITUDE', ' ', 'longitude', '%10.5f'
        'DEPTH', ' ', 'depth', '%4.0f'
        'STNNBR', ' ', 'statnum', '%3d'
        'CASTNO', ' ', 'castno', '%d'};
    vars = {'CTDPRS', 'DBAR', 'press', '%8.1f'
        'CTDPRS_FLAG_W', ' ', 'press_flag', '%d'
        'CTDTMP','ITS-90', 'temp', '%7.4f'
        'CTDTMP_FLAG_W', ' ', 'temp_flag', '%d'
        'CTDSAL','PSS-78', 'psal', '%7.4f'
        'CTDSAL_FLAG_W', ' ', 'psal_flag', '%d'
        'CTDOXY','UMOL/KG', 'oxygen', '%6.1f'
        'CTDOXY_FLAG_W', ' ', 'oxygen_flag', '%d'
        'CTDTURB','M^1/SR', 'turbidity', '%8.6f'
        'CTDTURB_FLAG_W', ' ', 'turbidity_flag', '%d'
        'CTDXMISS','%TRANS', 'transmittance', '%8.4f'
        'CTDXMISS_FLAG_W', ' ', 'transmittance_flag', '%d'
        'CTDFLUOR','MG/M^3', 'fluor', '%7.4f'
        'CTDFLUOR_FLAG_W', ' ', 'fluor_flag', '%d'
        'PAR', 'UMOL/M^2/SEC', 'par_up', '%6.5f' %par_up is up-looking (downwelling)
        'PAR_FLAG_W', ' ', 'par_up_flag', '%d'
        %'CTDPH', ' ', 'ph', '%8.4f'
        %'CTDPH_FLAG_W', ' ', 'ph_flag', '%d'
        };
    
elseif typ==2 % this is for comparing with bottle samples
    
    vars = {'EXPOCODE', ' ', 'expocode', '%s'
        'SECT_ID', ' ', 'sect_id', '%s'
        'STNNBR', ' ', 'statnum', '%3d'
        'CASTNO', ' ', 'castno', '%d'
        'SAMPNO', ' ', 'position', '%2d'
        'BTLNBR', ' ', 'niskin', '%d'
        'BTLNBR_FLAG_W', ' ', 'niskin_flag', '%d'
        'BTLNBR_FLAG_W', ' ', 'bottle_qc_flag', '%d'
        'DATE, TIME', ' ', 'datetime', '%s'
        'LATITUDE', ' ', 'stnlat', '%9.5f'
        'LONGITUDE', ' ', 'stnlon', '%10.5f'
        %'BTL_LAT', ' ', 'ulatitude', '%9.5f'
        %'BTL_LON', ' ', 'ulongitude', '%10.5f'
        'DEPTH', 'METERS', 'stndepth', '%4.0f'
        'CTDPRS', 'DBAR', 'upress', '%6.1f'
        'CTDTMP', 'ITS-90', 'utemp', '%7.4f'
        'SBE35', 'ITS-90', 'sbe35temp', '%7.4f'
        'SBE35_FLAG_W', ' ', 'sbe35temp_flag', '%7.4f'
        'CTDSAL', 'PSS-78', 'upsal', '%7.4f'
        'CTDSAL_FLAG_W', ' ', 'upsal_flag', '%d'
        'SALNTY', 'PSS-78', 'botpsal', '%7.4f'
        'SALNTY_FLAG_W', ' ', 'botpsal_flag', '%d'
        'CTDOXY', 'UMOL/KG', 'uoxygen', '%6.1f'
        'CTDOXY_FLAG_W', ' ', 'uoxygen_flag', '%d'
        'OXYGEN', 'UMOL/KG', 'botoxy', '%6.1f'
        'OXYGEN_FLAG_W', ' ', 'botoxy_flag', '%d'
        'SILCAT', 'UMOL/KG', 'silc', '%8.2f'
        'SILCAT_FLAG_W', ' ', 'silc_flag', '%d'
        'NITRAT', 'UMOL/KG', 'no3', '%8.2f'
        'NITRAT_FLAG_W', ' ', 'no3_flag', '%d'
        'NITRIT', 'UMOL/KG', 'no2', '%8.2f'
        'NITRIT_FLAG_W', ' ', 'no2_flag', '%d'
        'NO2+NO3', 'UMOL/KG', 'totnit', '%8.2f'
        'NO2+NO3_FLAG_W', ' ', 'totnit_flag', '%d'
        'PHSPHT', 'UMOL/KG', 'phos', '%8.2f'
        'PHSPHT_FLAG_W', ' ', 'phos_flag', '%d'
        'ALKALI', 'UMOL/KG', 'alk', '%8.1f'
        'ALKALI_FLAG_W', ' ', 'alk_flag', '%d'
        'TCARBN', 'UMOL/KG', 'dic', '%8.1f'
        'TCARBN_FLAG_W', ' ', 'dic_flag', '%d'
        'CFC-11', 'PMOL/L', 'cfc11', '%8.3f'
        'CFC-11_FLAG_W', ' ', 'cfc11_flag', '%d'
        'CFC-12', 'PMOL/L', 'cfc12', '%8.3f'
        'CFC-12_FLAG_W', ' ', 'cfc12_flag', '%d'
        'CFC113', 'PMOL/L', 'f113', '%8.3f'
        'CFC113_FLAG_W', ' ', 'f113_flag', '%d'
        'CCL4', 'PMOL/L', 'ccl4', '%8.3f'
        'CCL4_FLAG_W', ' ', 'ccl4_flag', '%d'
        'SF6', 'FMOL/L', 'sf6', '%8.3f'
        'SF6_FLAG_W', ' ', 'sf6_flag', '%d'
        'SF5CF3', 'FMOL/L', 'sf5cf3', '%8.3f'
        'SF5CF3_FLAG_W', ' ', 'sf5cf3_flag', '%d'
        'DELC14', '/MILLE', 'del14c', '%8.2f'
        'DELC14_FLAG_W', ' ', 'del14c_flag', '%d'
        'DELC13', '/MILLE', 'del13c', '%8.2f'
        'DELC13_FLAG_W', ' ', 'del13c_flag', '%d'
        'DELO18', '/MILLE', 'del18o', '%8.4f'
        'DELO18_FLAG_W', ' ', 'del18o_flag', '%d'
        'D15N_NO3', '/MILLE', 'del15n', '%8.4f'
        'D15N_NO3_FLAG_W', ' ', 'del15n_flag', '%d'
        'D30SI_SILCAT', '/MILLE', 'del30si', '%8.4f'
        'D30SI_SILCAT_FLAG_W', ' ', 'del30si_flag', '%d'
        'CTDFLUOR','MG/M^3', 'ufluor', '%7.4f'
        'BOTCHLA', 'ML/L', 'botchla', '%7.1f'
        'BOTCHLA_FLAG_W', ' ', 'botchla_flag', '%d'
        'PAR', 'UMOL/M^2/SEC', 'upar_up', '%6.5f' %par_up is up-looking (downwelling)
        %'CTDPH', ' ', 'uph', '%8.4f'
        'CTDSIG0', 'KG/M^3', 'upden', '%8.2f'
        'BOTSIG0', 'KG/M^3', 'pden', '%8.2f'
};
        varsh = {};
else
    
    error('pick variable list type 1 or 2')
    
end

