function ncfile = m_exitifopen(ncfile)
% function ncfile = m_exitifopen(ncfile)
%
% Check if an mstar file is already open for write and exit with error if
% answer is yes. Assume we have already checked that this is a valid mstar
% file using m_ismstar(ncfile)

if nargin ~= 1
%     error('Must supply precisely one argument to m_ismstar');
% bug/typo noticed on jr302 by bak. Error message was cut and pasted from a
% different function. Corrected.
    error('Must supply precisely one argument to m_exitifopen');
end

ncfile.name = m_add_nc(ncfile.name);

% Check the write flag

openflag = nc_attget(ncfile.name,nc_global,'openflag');

if strcmp(openflag,'W')
    %file is already open for write
    % Modified by Loic during JR239. Add an error line to explain why tmp.nc is already open. 
    % Further mod to msg by BAK at NOC 17 Aug 2010
    errstr0 = sprintf('%s',['Exit with error because file ' ncfile.name ' is already open for write']);
    errstr1 = sprintf('%s',['It may be the case that this program has crashed or been interrupted before, leaving the write flag set in the file']);
    errstr2 = sprintf('%s','If required you can reset the write flag using');
    errstr3 = sprintf('\n%s\n','mreset(filename) or mreset(ncfile)');
    errstr4 = sprintf('%s','where filename or ncfile.name is a char string containing the name of the mstar file');
%     errstr4 = sprintf('\n%s\n%s\n%s\n%s\n',errstr0,errstr1,errstr2,errstr3);
    errstr5 = sprintf('\n%s',errstr0,errstr1,errstr2,errstr3,errstr4);
    error(errstr5);
end

