function m_add_comment(ncfile,comment)
% function m_add_comment(ncfile,comment)
%
% get existing comment string from ncfile, add comment to it, and write back to ncfile

com = nc_attget(ncfile.name,nc_global,'comment');
delim = nc_attget(ncfile.name,nc_global,'comment_delimiter_string'); %usually ' \n ' but could be anything

newcom = [com comment delim ];

nc_attput(ncfile.name,nc_global,'comment',newcom); 