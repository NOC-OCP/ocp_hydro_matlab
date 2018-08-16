function mcsetd(varargin)
% function mcsetd(varargin)
%
% can be used in a matlab session or called from a script
%
% set global variable for mexec current working directory: MEXEC_G.MEXEC_CWD
%
% If you simply want to change directory, use 'mcd'
%
% USE:
%  mcsetd gps; 
%  mcsetd M_GPS; % where M_GPS is a pointer stored in global variable MEXEC_G.MDIRLIST
%  mcsetd('gps');
%  mcsetd('M_GPS');
%
% INPUT:
%   target directory, given as argument or prompted from keyboard
%   if you set a second argument, 'q', then there is less echo
%
% OUTPUT:
%   none; global variable MEXEC_G.MEXEC_CWD is set.
%
% UPDATED:
%   Initial version BAK 2008-10-17 at NOC
%   Updated for jr195 BAK 2009-09-17 on nosea2

m_common
m_margslocal
m_varargs

MEXEC_A.Mprog = 'mcsetd';
m_proghd



% m_getinput takes input from MEXEC_A.MARGS_IN via varargin if present

m1 = 'Set a directory as the mexec current working directory';
m2 = ['This will be below the MEXEC_G.MEXEC_DATA_ROOT : ' MEXEC_G.MEXEC_DATA_ROOT];
m = sprintf('%s\n',m1,m2);
if nargin == 2; m = ''; end
dn = m_getinput(m,'s');

% sort out if it is one in the global list

mstar_list = MEXEC_G.MDIRLIST(:,1);
target_list = MEXEC_G.MDIRLIST(:,2);

k = strmatch(dn,mstar_list,'exact');
if isempty(k)
    % not one of the global list, assume it is just a simple directory name
else
    dn = target_list{k};
end


MEXEC_G.MEXEC_CWD = [MEXEC_G.MEXEC_DATA_ROOT '/' dn]; % set current working directory
m2 = ['MEXEC_G.MEXEC_CWD set to : ' MEXEC_G.MEXEC_CWD];
if nargin < 2
    if ~MEXEC_G.quiet; fprintf(MEXEC_A.Mfidterm,'%s\n',m2); end
end

if exist(MEXEC_G.MEXEC_CWD,'dir') ~= 7
    fprintf(MEXEC_A.Mfider,'%s\n',['Warning: Directory selected by MEXEC_G.MEXEC_CWD does not exist: ' MEXEC_G.MEXEC_CWD]);
end

return

