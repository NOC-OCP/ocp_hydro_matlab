function mreset(varargin)

% reset the write flag on an mstar file
% optional argument is filename or name of structure containing filename 
% if no argument, prompt from keyboard eg
% mreset
% mreset(ncfile) % where ncfile.name = 'abc.nc'
% mreset(ncfile.name) 
% mreset('abc.nc') or mreset('abc') or
% mreset abc y

m_common
m_margslocal
m_varargs

MEXEC_A.Mprog = 'mreset';
m_proghd
% varargin; % jc032 no need to echo this any more.

fn = m_getfilename; % this inserts the optional argument if there is one
ncfile.name = fn;
ncfile = m_ismstar(ncfile);

m1 = ['About to reset mstar openflag on file     ' fn '.'];
m2 = 'Do you really want to do this ?       ';
m3 = '            Reply y/yes. Default is no.   ';
msg = sprintf('\n%s',m1,m2,m3);
reply = m_getinput(msg,'s');


if strcmp(reply,'y') | strcmp(reply,'yes')
nc_attput(fn,nc_global,'openflag','R'); %set the open/writing attribute to 'R'
  disp(' ')
    disp(['File ' fn ' has been modified']);
    disp(' ')
else
    disp(' ')
    disp(['File ' fn ' not modified']);
    disp(' ')
end
   
return
