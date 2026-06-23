function mhistory
% function mhistory
%
% display the history entry for the most recent program

m_common


cmd = ['!tail -'  sprintf('%d',MEXEC_A.Mhistory_lastlines) ' ' MEXEC_A.Mhistory_filename]
eval(cmd)