%jc159

m_common

mcd ctd
unix('/bin/rm -f ldcs');
unix('/bin/rm -f dcs_jc159_all.nc');
unix('ls dcs_jc159_0??.nc > ldcs');
unix('ls dcs_jc159_1??.nc >> ldcs');

MEXEC_A.MARGS_IN = {
'dcs_jc159_all'
'dcs_jc159_all'
'f'
'ldcs'
'/'
'c'
};
mapend



unix('/bin/rm -f ldcspos');
unix('/bin/rm -f dcs_jc159_all_pos.nc');
unix('ls dcs_jc159_0??_pos.nc > ldcspos');
unix('ls dcs_jc159_1??_pos.nc >> ldcspos');

MEXEC_A.MARGS_IN = {
'dcs_jc159_all_pos'
'dcs_jc159_all_pos'
'f'
'ldcspos'
'/'
'c'
};
mapend
