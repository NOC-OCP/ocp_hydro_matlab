
% mctd_celltm: apply celltm to a cond channel
%
% Use: mctd_celltm        and then respond with station number, or for station 16
%      stn = 16; mctd_cleanedita;
%
% apply this to the 'raw' file; if necessary back it up to _original, and
% create a 'cleaned' file. This is the same file as used for
% mctd_cleanedita and mctd_rawedit
%
% bak dy040 21 dec 2015

scriptname = 'mctd_celltm';

if exist('stn','var')
    m = ['Running script ' scriptname ' on station ' sprintf('%03d',stn)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
clear stn % so that it doesn't persist

% resolve root directories for various file types
mcd('M_CTD'); % change working directory

prefix1 = ['ctd_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];

infile1 = [prefix1 stn_string '_noctm'];
otfile1 = [prefix1 stn_string '_raw'];

in1nc = m_add_nc(infile1);
ot1nc = m_add_nc(otfile1);

cmd = ['chmod 644 ' ot1nc]; unix(cmd);
cmd = ['/bin/cp -p ' in1nc ' ' ot1nc]; unix(cmd);
cmd = ['chmod 644 ' ot1nc]; unix(cmd);

% select sensor; same code for choosing as mctd_condcal
% can avoid this prompt by setting 'senscal'

% % if exist('senscal','var')
% %     m = ['Running script ' scriptname ' on sensor ' sprintf('%03d',senscal)];
% %     fprintf(MEXEC_A.Mfidterm,'%s\n',m)
% % else
% %     senscal = input('type choice of sensor to calibrate, reply 1 or 2 : ');
% % end
% % 
% % senslocal = senscal; clear senscal; % so it doesnt persist.
% % 
% % if senslocal ~= 1 & senslocal ~= 2
% %     m = ['Must specify sensor as 1 or 2. Sensor was sepcified as ' sprintf('%d',senslocal)];
% %     fprintf(2,'%s\n',m)
% %     return
% % end
% % 
% % condname=['cond' num2str(senslocal)];
% % tempname=['temp' num2str(senslocal)];
% % invarnames = ['time ' tempname ' ' condname];
% % 
% % 

condname = 'cond1';
invarnames = 'time temp1 cond1';


MEXEC_A.MARGS_IN = {
    otfile1
    'y'
    'cond1'
    'time temp1 cond1'
    'y = x1; y = ctd_apply_celltm(x1,x2,x3);'
    ' '
    ' '
    'cond2'
    'time temp2 cond2'
    'y = x1; y = ctd_apply_celltm(x1,x2,x3);'
    ' '
    ' '
    'oxygen_sbe1'
    'time oxygen_sbe1'
    'y = x1; y = interp1(x1,x2,x1+5)'
    ' '
    ' '
    'oxygen_sbe2'
    'time oxygen_sbe2'
    'y = x1; y = interp1(x1,x2,x1+5)'
    ' '
    ' '
    ' '
    };
mcalib2
%--------------------------------



cmd = ['chmod 444 ' ot1nc]; unix(cmd);

