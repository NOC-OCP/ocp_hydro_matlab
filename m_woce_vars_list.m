function vars = m_woce_vars_list(typ);
%function vars = m_woce_vars_list(typ);
%
% Lists of ctd (typ = 1) or bottle sample (typ = 2): 
% WOCE exchange format variable name, units, mstar name, format string

% It is safe to simply add to this list from the WOCE tables, because mout_cchdo_ctd.m and
% mout_cchod_sam.m will ignore any variables not in input files, and
% opt_cruise can be used to exclude variables that are 
% (see scriptname = 'mout_cchdo', oopt = 'cchdo_vars_exclude')
%
% flags will also be printed in files but they have standardised name
% formats so don't need to be included in vars

if typ==1 % this is for ctd profiles
    
    vars = {'CTDPRS' 'DBAR' 'press' '%8.1f'
        'CTDTMP' 'ITS-90' 'temp' '%8.4f'
        'CTDSAL' 'PSS-78' 'psal' '%8.4f'
        'CTDOXY' 'UMOL/KG' 'oxygen' '%8.1f'
        'CTDTURB' 'M^1/SR' 'turbidity' '%8.6f'
        'CTDXMISS' '%TRANS' 'transmittance' '%8.4f'
        'CTDFLUOR' 'MG/M^3' 'fluor' '%8.4f'};
    
elseif typ==2 % this is for comparing bottle sample and comparable ctd data in _hy file
    
    vars = {'EXPOCODE', ' ', 'expocode', '%s'
        'SECT_ID', ' ', 'sect_id', '%s'
        'STNNBR', ' ', 'statnum', '%3d'
        'CASTNO', ' ', 1, '%d'
        'SAMPNO', ' ', 'position', '%2d'
        'BTLNBR', ' ', 'niskin', '%2d'
        'DATE', ' ', 'date', '%s'
        'TIME', ' ', 'time', '%s'
        'LATITUDE', ' ', 'ulatitude', '%11.5f'
        'LONGITUDE', ' ', 'ulongitude', '%11.5f'
        'DEPTH', ' ', 'depth', '%6f'
        'CTDPRS', 'DBAR', 'upress', '%8.1f'
        'CTDTMP', 'ITS-90', 'utemp', '%8.4f'
        'SBE35', 'ITS-90', 'sbe35temp', '%8.4f'
        'CTDSAL', 'PSS-78', 'upsal', '%8.4f'
        'SALNTY', 'PSS-78', 'botpsal', '%8.4f'
        'CTDOXY', 'UMOL/KG', 'uoxygen', '%8.1f'
        'OXYGEN', 'UMOL/KG', 'botoxy', '%8.1f'
        'SILCAT', 'UMOL/KG', 'silc', '%8.2f'
        'NITRAT', 'UMOL/KG', 'no3', '%8.2f'
        'NITRIT', 'UMOL/KG', 'no2', '%8.2f'
        'NO2+NO3', 'UMOL/KG', 'totnit', '%8.2f'
        'PHSPHT', 'UMOL/KG', 'phos', '%8.2f'
        'ALKALI', 'UMOL/KG', 'alk', '%8.1f'
        'TCARBN', 'UMOL/KG', 'dic', '%8.1f'
        'CFC-11', 'PMOL/L', 'cfc11', '%8.3f'
        'CFC-12', 'PMOL/L', 'cfc12', '%8.3f'
        'CFC113', 'PMOL/L', 'f113', '%8.3f'
        'CCL4', 'PMOL/L', 'ccl4', '%8.3f'
        'SF6', 'FMOL/L', 'sf6', '%8.3f'
        'SF5CF3', 'FMOL/L', 'sf5cf3', '%8.3f'
        'DELC14', '/MILLE', 'del14c', '%8.2f'
        'DELC13', '/MILLE', 'del13c', '%8.2f'
        'DELO18', '/MILLE', 'del18o', '%8.4f'
        'D15N_NO3', '/MILLE', 'del15n', '%8.4f'
        'D30SI_SILCAT', '/MILLE', 'del30si', '%8.4f'
        };
        
else
    
    error('pick variable list type 1 or 2')
    
end

