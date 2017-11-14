function newdir = mcd(varargin)
% function newdir = mcd(varargin)
% 
% function to change directory to the directory stored in global variable MEXEC_G.MEXEC_CWD
%
%  The target directory can be identified either as 
%    a simple character string, which is searched for under MEXEC_G.MEXEC_DATA_ROOT
%    eg 'ctd' or 'nav/gps'
%  or
%    a directory abbreviation, which is resolved using to the list MEXEC_G.MDIRLIST
%    which is set in m_setup
%    eg 'M_CTD' or 'M_GPS'
%    
%  If the output option to return MEXEC_G.MEXEC_CWD is not being used,
%    the varargin syntax seems to allow the argument to be put on the command line
%    without enclosing in brackets and quotes. See USE examples below
% 
%  If no argument supplied the user is prompted
% 
% USE:
%  newdir = mcd(varargin)
%       examples
%  newdir = mcd('M_GPS')
%  newdir = mcd('nav/gps')
%  mcd M_GPS
%  mcd nav/gps
%
% INPUT:
%   name of directory to be made current working directory
%
% OUTPUT:
%   newdir is the new matlab current working directory
%
% UPDATED:
%   Initial version BAK 2009-01-30 at NOC


m_common
m_margslocal
m_varargs

MEXEC_A.Mprog = 'mcd';
if ~MEXEC_G.quiet; m_proghd; end

e = 0;
while e == 0
    m = 'Type name of directory to change to (/ or return  to end) ';
    reply = m_getinput(m,'s');
    if strncmp(' ',reply,1) == 1; MEXEC_G.MEXEC_CWD = ' '; return; end
    if strncmp('/',reply,1) == 1; MEXEC_G.MEXEC_CWD = ' '; return; end
    target = reply;

    mcsetd(target);

    if exist(MEXEC_G.MEXEC_CWD,'dir') ~= 7
        %         fprintf(MEXEC_A.Mfider,'%s\n',['Directory selected by MEXEC_G.MEXEC_CWD does not exist: ' MEXEC_G.MEXEC_CWD]);
    else
        e = 1;
    end
end

newdir = MEXEC_G.MEXEC_CWD;

cmd = ['cd ' MEXEC_G.MEXEC_CWD ';']; eval(cmd)
if ~MEXEC_G.quiet; m = ['Directory changed to ' MEXEC_G.MEXEC_CWD]; fprintf(MEXEC_A.Mfidterm,'%s\n',m); end



