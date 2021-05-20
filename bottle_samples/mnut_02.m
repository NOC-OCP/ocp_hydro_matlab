% mnut_02: paste nut data into sam file

minit; scriptname = mfilename;
mdocshow(scriptname, ['pastes bottle nutrient data into sam_' mcruise '_' stn_string '.nc']);

root_nut = mgetdir('M_BOT_NUT');
root_ctd = mgetdir('M_CTD');
prefix1 = ['nut_' mcruise '_'];
prefix2 = ['sam_' mcruise '_'];
infile1 = fullfile(root_nut, [prefix1 stn_string]);
otfile2 = fullfile(root_ctd, [prefix2 stn_string]);

% bak on jr302 19 jun 2014 some stations don't have any nut data; exit
% gracefully

if exist(m_add_nc(infile1),'file')~=2;
    mess = ['File ' m_add_nc(infile1) ' not found'];
    fprintf(MEXEC_A.Mfider,'%s\n',mess)
    return
end

% 
%--------------------------------
% 2009-03-11 02:02:37
% mpaste
% input files
% Filename nut_jc032_001.nc   Data Name :  nut_jc032_001 <version> 3 <site> jc032
% output files
% Filename sam_jc032_001.nc   Data Name :  sam_jc032_001 <version> 16 <site> jc032
MEXEC_A.MARGS_IN = {
otfile2
infile1
'y'
'sampnum'
'sampnum'
'no3no2 no3no2_flag sio4 sio4_flag po4 po4_flag no2 no2_flag'
'totnit totnit_flag silc silc_flag phos phos_flag no2 no2_flag'
};
mpaste
%--------------------------------
