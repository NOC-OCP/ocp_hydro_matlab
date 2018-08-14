
for kl = [3:150]%16:19
    
    fn = sprintf('%s%03d','sam_jc159_',kl);

%--------------------------------
% 2018-03-05 17:00:01
% mheadr
% calling history, most recent first
%    mheadr in file: mheadr.m line: 47
% input files
% Filename sam_jc159_999.nc   Data Name :  sam_jc159_999 <version> 3 <site> jc159
% output files
% Filename sam_jc159_999.nc   Data Name :  sam_jc159_999 <version> 4 <site> jc159
MEXEC_A.MARGS_IN = {
fn
'y'
'8'
'16'
'botoxya_per_l'
'/'
'21'
'botoxyb_per_l'
'/'
%'73'
% 'del13c_imp'
% 'per_mil'
% '74'
% 'del13c_imp_flag'
% ' woce_table_4.9'
% '75'
% 'del14c_imp'
% 'per_mil'
% '76'
% 'del14c_imp_flag'
% ' woce_table_4.9'
% '77'
% 'del13c_whoi'
% 'per_mil'
% '78'
% 'del13c_whoi_flag'
% ' woce_table_4.9'
% '79'
% 'del14c_whoi'
% 'per_mil'
% '80'
% 'del14c_whoi_flag'
% ' woce_table_4.9'
% '81'
% 'del13c_bgs'
% 'per_mil'
% '82'
% 'del13c_bgs_flag'
% ' woce_table_4.9'
% '83'
% 'del18o_bgs'
% 'per_mil'
% '84'
% 'del18o_bgs_flag'
% ' woce_table_4.9'
'-1'
' '
};
mheadr
%--------------------------------

end