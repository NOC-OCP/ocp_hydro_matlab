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
clear vunits
if m_isvartime(vname)
    tunits = nc_attget(ncfile_in.name,vname,'units');
    if ~contains(tunits,'since')
        hin.dto = nc_attget(ncfile_in.name,nc_global,'data_time_origin');
        hot.dto = nc_attget(ncfile_ot.name,nc_global,'data_time_origin');
        if hin.dto~=hot.dto
            [vdata, vunits] = m_adjtime(vname,vdata,hin,hot);
        end
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
    if exist('vunits','var') && strcmp(vanam,'units')
        nc_attput(ncfile_ot.name,newname,vanam,vunits)
    else
        nc_attput(ncfile_ot.name,newname,vanam,vaval);
    end
end

% now write the data, using the attributes already saved in the output file
% this provides the opportunity to change attributes if required, eg fillvalue

nc_varput(ncfile_ot.name,newname,v.data);
m_uprlwr(ncfile_ot,newname,v.data); % not strictly needed if straight copy

return