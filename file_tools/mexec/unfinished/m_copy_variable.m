function m_copy_variable(ncfile_in,vname,ncfile_ot,newname,indexrows,indexcols)
% function m_copy_variable(ncfile_in,vname,ncfile_ot,newname,indexrows,indexcols)
%
% Copy a variable from input file to output file, with optional new name in
% output file
% 
% Optional copy of subset of vars
% 
% if it is recognised as a time variable, adjust for data_time_origin

m_common

clear v

v.name = newname;
vdata = nc_varget(ncfile_in.name,vname);

% hin = m_read_header(ncfile_in);
% hot = m_read_header(ncfile_ot);
% BAK after jc032: in order to speed this subroutine up, we will read
% the data time origin directly. m_read_header does too much extra work,
% so the subroutine runs too slowly when called eg from mcalc or mcopya.
% Therefore we assume that the passed in file names are properly resolved
% mstar filenames complete with .nc

hin.data_time_origin = nc_attget(ncfile_in.name,nc_global,'data_time_origin');
hot.data_time_origin = nc_attget(ncfile_ot.name,nc_global,'data_time_origin');
torg1 = hin.data_time_origin;
torg2 = hot.data_time_origin;
tdif = torg1-torg2;
if max(abs(tdif)) > 0
    if m_isvartime(vname)
        % this is a time variable name; adjust for data time origin
        vdata = m_adjtime(vname,vdata,hin,hot);
    end
end

if nargin == 4
    v.data = vdata;
else
    v.data = vdata(indexrows,indexcols);
end
m_write_variable(ncfile_ot,v,'nodata'); %write the variable information into the header but not the data

% next copy the attributes
vinfo = nc_getvarinfo(ncfile_in.name,vname);
va = vinfo.Attribute;
for k2 = 1:length(va)
    vanam = va(k2).Name;
    vaval = va(k2).Value;
    nc_attput(ncfile_ot.name,newname,vanam,vaval);
end

% now write the data, using the attributes already saved in the output file
% this provides the opportunity to change attributes if required, eg fillvalue

nc_varput(ncfile_ot.name,newname,v.data);
m_uprlwr(ncfile_ot,newname,v.data); % not strictly needed if straight copy

return