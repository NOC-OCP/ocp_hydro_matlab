% mco2_02: paste co2 data into sam file

scriptname = 'mco2_02';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

if exist('stn','var')
    m = ['Running script ' scriptname ' on station ' sprintf('%03d',stn)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
clear stn % so that it doesn't persist

root_co2 = mgetdir('M_BOT_CO2');
root_ctd = mgetdir('M_CTD');
prefix1 = ['co2_' cruise '_'];
prefix2 = ['sam_' cruise '_'];
infile1 = [root_co2 '/' prefix1 '01'];
otfile2 = [root_ctd '/' prefix2 stn_string];


%--------------------------------
% 2009-03-13 17:06:01
% mpaste
% input files
% Filename co2_jc032_003.nc   Data Name :  co2_jc032_003 <version> 1 <site> jc032
% output files
% Filename sam_jc032_003.nc   Data Name :  sam_jc032_003 <version> 10 <site> jc032
MEXEC_A.MARGS_IN = {
otfile2
infile1
'y'
'sampnum'
'sampnum'
'alk alk_flag dic dic_flag'
'alk alk_flag dic dic_flag'
};
mpaste
