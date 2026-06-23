function mdatapup(startyy,startddd,starttime,endyy,endddd,endtime,flags,instream,otfile,varlist)
% function mdatapup(startyy,startddd,starttime,endyy,endddd,endtime,flags,instream,otfile,varlist)
%
% the components of start and end time are numeric
% the time argument must be hhmmss
% all other arguments are strings to be offered directly to datapup
% eg mdatapup(09,020,000000,09,020,235959,' ','gps_nmea','./gpstmp','-')

% eg mdatapup('jruj','/users/pstar/b_king_test','/users/pstar/b_king_test',09,020,000000,09,020,235959,'-k GOOD -i 60','gps_nmea','./gpstmp','-')

% 'remote_machine' is target machine for rsh command
% 'directory_r' is directory for output file on the remote machine, and must be found in remote
%             shell when using cd command. It is safest to construct this
%             as an absolute path name in the calling program.
% 'directory_l' is the name of directory_r on the local machine. It may be
%             different frm directory_r, depending on the details of cross-mounting

m_common

% build start string

strstart = ['-s' sprintf('%02d%03d%06d',startyy,startddd,starttime)];
strend = ['-e' sprintf('%02d%03d%06d',endyy,endddd,endtime)];
strall = ['datapup ' strstart ' ' strend ' ' flags ' ' instream ' ' otfile ' ' varlist];

starthh = floor(starttime/10000);
startmm = floor((starttime-10000*starthh)/100);
startss = starttime-10000*starthh - 100*startmm;
dn1 = datenum([2000+startyy 1 1 0 0 0]) + (startddd-1) + starthh/24 + startmm/1440 + startss/86400;
dv1 = datevec(dn1);
dvstring1 = sprintf('[%4d %02d %02d %02d %02d %4.1f]',dv1)
% datestr(dn1)
endhh = floor(endtime/10000);
endmm = floor((endtime-10000*endhh)/100);
endss = endtime-10000*endhh - 100*endmm;
dn2 = datenum([2000+endyy 1 1 0 0 0]) + (endddd-1) + endhh/24 + endmm/1440 + endss/86400;
dv2 = datevec(dn2);
dvstring2 = sprintf('[%4d %02d %02d %02d %02d %4.1f]',dv2)
% datestr(dn2)

tstream = mtresolve_stream(instream);
dataname = 'null_from_techsas';

%--------------------------------
% 2009-04-08 15:19:16
% techsas_to_mstar2
% input files
% Filename    Data Name :   <version>  <site> 
% output files
% Filename wk.nc   Data Name :  wk <version> 25 <site> jc032
MEXEC_A.MARGS_IN = {
tstream
dvstring1
dvstring2
varlist
otfile
dataname
};
techsas_to_mstar2
%--------------------------------
return