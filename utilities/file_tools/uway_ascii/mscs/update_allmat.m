% call ms_update_aco_to_mat on all SCS ACO streams
%
% mexec script update_allmat
% 
%
% If in any doubt about the status of a file, the best thing is to stop the
%   sed conversion from ACO in scs_raw to scs_sed
%   then delete the files for this stream in scs_sed and scs_mat
%   and then rerun the sed script and then rerun this aco_to_mat conversion
%
% In order to read data faster, all non-numeric characters are first removed by
%   sed in a conversion from scs_raw to scs_sed, eg with unix scripts
%   sedexec_stopall (to stop all sed stream conversions)
%   sedexec_startall (to restart and overwrite ACO files in scs_sed
% 
% INPUT:
%   none
%
% OUTPUT:
%   mat files for all streams, in cruise/data/scs_mat
%
% EXAMPLES:
%   update_allmat
%
% UPDATED:
%   help comments added BAK 3 Jun 2014 on jr302



% update all scs matlab files
%[MEXEC.status currentdir] = unix('pwd');
%mcd ('M_SCSMAT'); % change working directory
fullfn = '/local/users/pstar/projects/rpdmoc/en705/mcruise/data/scs/scs_sed/GPS-Furuno-GGA.ACO'; if exist(fullfn,'file')==2; cmd = ['/bin/rm ' fullfn];  [status,result ] = system(cmd); end
cmd = ['cat /local/users/pstar/projects/rpdmoc/en705/mcruise/data/scs/scs_daily/GPS-Furuno-GGA*.ACO > /local/users/pstar/projects/rpdmoc/en705/mcruise/data/scs/scs_sed/GPS-Furuno-GGA.ACO']; [status,result ] = system(cmd);
ms_update_aco_to_mat('GPS-Furuno-GGA')

fullfn = '/local/users/pstar/projects/rpdmoc/en705/mcruise/data/scs/scs_sed/SingleBeam-Knudsen-PKEL99.ACO'; if exist(fullfn,'file')==2; cmd = ['/bin/rm ' fullfn];  [status,result ] = system(cmd); end
cmd = ['cat /local/users/pstar/projects/rpdmoc/en705/mcruise/data/scs/scs_daily/SingleBeam-Knudsen-PKEL99*.ACO > /local/users/pstar/projects/rpdmoc/en705/mcruise/data/scs/scs_sed/SingleBeam-Knudsen-PKEL99.ACO']; [status,result ] = system(cmd);
ms_update_aco_to_mat('SingleBeam-Knudsen-PKEL99')

fullfn = '/local/users/pstar/projects/rpdmoc/en705/mcruise/data/scs/scs_sed/Gyro1-HDT.ACO'; if exist(fullfn,'file')==2; cmd = ['/bin/rm ' fullfn];  [status,result ] = system(cmd); end
cmd = ['cat /local/users/pstar/projects/rpdmoc/en705/mcruise/data/scs/scs_daily/Gyro1-HDT*.ACO > /local/users/pstar/projects/rpdmoc/en705/mcruise/data/scs/scs_sed/Gyro1-HDT.ACO']; [status,result ] = system(cmd);
ms_update_aco_to_mat('Gyro1-HDT')

fullfn = '/local/users/pstar/projects/rpdmoc/en705/mcruise/data/scs/scs_sed/TSG1-SBE21.ACO'; if exist(fullfn,'file')==2; cmd = ['/bin/rm ' fullfn];  [status,result ] = system(cmd); end
cmd = ['cat /local/users/pstar/projects/rpdmoc/en705/mcruise/data/scs/scs_daily/TSG1-SBE21*.ACO > /local/users/pstar/projects/rpdmoc/en705/mcruise/data/scs/scs_sed/TSG1-SBE21.ACO']; [status,result ] = system(cmd);
ms_update_aco_to_mat('TSG1-SBE21')

fullfn = '/local/users/pstar/projects/rpdmoc/en705/mcruise/data/scs/scs_sed/TSG2-SBE45.ACO'; if exist(fullfn,'file')==2; cmd = ['/bin/rm ' fullfn];  [status,result ] = system(cmd); end
cmd = ['cat /local/users/pstar/projects/rpdmoc/en705/mcruise/data/scs/scs_daily/TSG2-SBE45*.ACO > /local/users/pstar/projects/rpdmoc/en705/mcruise/data/scs/scs_sed/TSG2-SBE45.ACO']; [status,result ] = system(cmd);
ms_update_aco_to_mat('TSG2-SBE45')

fullfn = '/local/users/pstar/projects/rpdmoc/en705/mcruise/data/scs/scs_sed/SpeedLog-Furuno-VBW.ACO'; if exist(fullfn,'file')==2; cmd = ['/bin/rm ' fullfn];  [status,result ] = system(cmd); end
cmd = ['cat /local/users/pstar/projects/rpdmoc/en705/mcruise/data/scs/scs_daily/SpeedLog-Furuno-VBW*.ACO > /local/users/pstar/projects/rpdmoc/en705/mcruise/data/scs/scs_sed/SpeedLog-Furuno-VBW.ACO']; [status,result ] = system(cmd);
ms_update_aco_to_mat('SpeedLog-Furuno-VBW')

fullfn = '/local/users/pstar/projects/rpdmoc/en705/mcruise/data/scs/scs_sed/Win1.ACO'; if exist(fullfn,'file')==2; cmd = ['/bin/rm ' fullfn];  [status,result ] = system(cmd); end
cmd = ['cat /local/users/pstar/projects/rpdmoc/en705/mcruise/data/scs/scs_daily/Win1*.ACO > /local/users/pstar/projects/rpdmoc/en705/mcruise/data/scs/scs_sed/Win1.ACO']; [status,result ] = system(cmd);
ms_update_aco_to_mat('Win1')
% ms_update_aco_to_mat('anemometer')
% ms_update_aco_to_mat('ashtech')
% ms_update_aco_to_mat('dopplerlog')
% ms_update_aco_to_mat('ea600')
% ms_update_aco_to_mat('em122')
% ms_update_aco_to_mat('emlog-vhw')
% ms_update_aco_to_mat('emlog-vlw')
% ms_update_aco_to_mat('furuno-gga')
% ms_update_aco_to_mat('furuno-gll')
% ms_update_aco_to_mat('furuno-rmc')
% ms_update_aco_to_mat('furuno-vtg')
% ms_update_aco_to_mat('furuno-zda')
% ms_update_aco_to_mat('glonass')
% ms_update_aco_to_mat('gyro')
% ms_update_aco_to_mat('netmonitor')
% ms_update_aco_to_mat('oceanlogger')
% ms_update_aco_to_mat('seaspy')
% ms_update_aco_to_mat('seatex-gga')
% ms_update_aco_to_mat('seatex-gll')
% ms_update_aco_to_mat('seatex-hdt')
% ms_update_aco_to_mat('seatex-psxn')
% ms_update_aco_to_mat('seatex-vtg')
% ms_update_aco_to_mat('seatex-zda')
% ms_update_aco_to_mat('tsshrp')
% ms_update_aco_to_mat('usbl-gga')
% ms_update_aco_to_mat('winch')


%cmd = ['cd ' currentdir]; eval(cmd);
