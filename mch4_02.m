% mch4_02: paste ch4 data into sam file

scriptname = 'mch4_02';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

if exist('stn','var')
    m = ['Running script ' scriptname ' on station ' sprintf('%03d',stn)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
clear stn % so that it doesn't persist

root_ch4 = mgetdir('M_BOT_CH4');
root_ctd = mgetdir('M_CTD');
prefix1 = ['ch4_' cruise '_'];
prefix2 = ['sam_' cruise '_'];
infile1 = [root_ch4 '/' prefix1 stn_string];
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
'ch4 ch4_flag ch4_sat n2o n2o_flag n2o_sat ch4_temp'
'ch4 ch4_flag ch4_sat n2o n2o_flag n2o_sat ch4_temp'
};
mpaste
