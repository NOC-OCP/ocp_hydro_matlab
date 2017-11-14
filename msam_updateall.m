% msam_updateall: update the sam_xxxxx_all file with a new sam file from a
% station. This saves re-appending the whole sam set.
%
% Use: msam_updateall        and then respond with station number, or for station 16
%      stn = 16; msam_updateall;

scriptname = 'msam_updateall';

if exist('stn','var')
    m = ['Running script ' scriptname ' on station ' sprintf('%03d',stn)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    stn = input('type stn number ');
end
stnlocal = stn;
stn_string = sprintf('%03d',stn);
clear stn % so that it doesn't persist

root_ctd = mgetdir('M_CTD');
prefix1 = ['sam_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];

infile1 = [root_ctd '/' prefix1 stn_string];
otfile1 = [root_ctd '/' prefix1 'all'];

if exist(m_add_nc(infile1),'file') ~= 2
    % skip this station
    msg = ['input file ' infile1 ' not found: skipping'];
    fprintf(MEXEC_A.Mfider,'%s\n',msg);
    return
end


%--------------------------------
% 2013-04-06 12:58:41
% mpaste
% calling history, most recent first
%    mpaste in file: mpaste.m line: 550
% input files
% no input files
% output files
% Filename sam_jr281_all.nc   Data Name :  sam_jr281_all <version> 19 <site> jr281_atsea
MEXEC_A.MARGS_IN = {
otfile1
infile1
'y'
'sampnum'
'sampnum'
'/'
'/'
};
mpaste
%--------------------------------
