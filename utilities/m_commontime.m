function time1_origin2 = m_commontime(time1,origin1,origin2);
% function time1_origin2 = m_commontime(time1,origin1,origin2);
%
% put one mstar file time variable into the same units (including origin)
% as another, using the data_time_origin in the headers
%
% e.g.
% [d1,h1] = mload(file1,'/'); [d2,h2] = mload(file2,'/');
% time1_origin2 = m_commontime(d1.time,h1.data_time_origin,h2.data_time_origin);
% time1_origin2 can now be compared with d2.time

time1_origin2 = time1 + (datenum(origin1) - datenum(origin2))*3600*24; %assumes units always s, always true for mstar? think so
