% msbe35_02: paste sbe35 data into sam file

scriptname = 'msbe35_02';
minit
mdocshow(scriptname, ['pastes SBE35 data into sam_' mcruise '_' stn_string '.nc']);

root_sbe35 = mgetdir('M_SBE35');
root_ctd = mgetdir('M_CTD');

prefix1 = ['sbe35_' mcruise '_'];
prefix2 = ['sam_' mcruise '_'];

infile1 = [root_sbe35 '/' prefix1 stn_string];
otfile2 = [root_ctd '/' prefix2 stn_string];

if ~exist(m_add_nc(infile1), 'file')
    mess = ['file ' m_add_nc(infile1) ' not found']; % bak on jc069 exit if file not in the right place
    fprintf(MEXEC_A.Mfider,'%s\n',mess);
    return
end

%--------------------------------
% 2009-03-13 17:06:01
% mpaste
% input files
% Filename sal_jc032_003.nc   Data Name :  sal_jc032_003 <version> 1 <site> jc032
% output files
% Filename sam_jc032_003.nc   Data Name :  sam_jc032_003 <version> 10 <site> jc032
MEXEC_A.MARGS_IN = {
otfile2
infile1
'y'
'sampnum'
'sampnum'
'sbe35temp sbe35flag'
'sbe35temp sbe35flag'
};
mpaste
