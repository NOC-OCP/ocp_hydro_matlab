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

ms_update_aco_to_mat('anemometer')
ms_update_aco_to_mat('ashtech')
ms_update_aco_to_mat('dopplerlog')
ms_update_aco_to_mat('ea600')
ms_update_aco_to_mat('em122')
ms_update_aco_to_mat('emlog-vhw')
ms_update_aco_to_mat('emlog-vlw')
ms_update_aco_to_mat('furuno-gga')
ms_update_aco_to_mat('furuno-gll')
ms_update_aco_to_mat('furuno-rmc')
ms_update_aco_to_mat('furuno-vtg')
ms_update_aco_to_mat('furuno-zda')
ms_update_aco_to_mat('glonass')
ms_update_aco_to_mat('gyro')
ms_update_aco_to_mat('netmonitor')
ms_update_aco_to_mat('oceanlogger')
ms_update_aco_to_mat('seaspy')
ms_update_aco_to_mat('seatex-gga')
ms_update_aco_to_mat('seatex-gll')
ms_update_aco_to_mat('seatex-hdt')
ms_update_aco_to_mat('seatex-psxn')
ms_update_aco_to_mat('seatex-vtg')
ms_update_aco_to_mat('seatex-zda')
ms_update_aco_to_mat('tsshrp')
ms_update_aco_to_mat('usbl-gga')
ms_update_aco_to_mat('winch')


%cmd = ['cd ' currentdir]; eval(cmd);
