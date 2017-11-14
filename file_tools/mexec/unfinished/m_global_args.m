% m_global_args
% 
% mexec script
% declares MEXEC_A to be global

global MEXEC_A

% output fidterm = 1 is screen; fider = 2 is standard error printed in red;
MEXEC_A.Mfidterm = 1;
MEXEC_A.Mfider = 2;

% variable names recognised as time: 
MEXEC_A.Mtimnames = {'time'}; % 'tim' 'other_string'} any variable whose name begins 'time' eg 'time' 'timenew'
% time units recognised as days and assumed to be relative to mstar_data_origin: 
MEXEC_A.Mtimunits_days = {'day'}; % any unit whose name begins 'day' eg 'day' 'day_of_year'
% time units recognised as seconds and assumed to be relative to mstar_data_origin:
MEXEC_A.Mtimunits_seconds = {'sec'}; % any unit whose name begins 'sec' eg 'sec' 'seconds' 'sec_of_year'