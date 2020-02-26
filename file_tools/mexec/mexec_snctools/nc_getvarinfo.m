function vinfo = nc_getvarinfo( ncfile , varname )
%
% version of nc_getvarinfo for mexec to replace snctools version
% the aim is to replace snctools nc_ calls with faster versions that make
% simple native matlab netcdf calls.
%
% rather than changing every mexec program, the snctools library can be
% replaced with this library
%
% In this version, the varname is always a name, not a varid.
% In the old snctools version, it was possible to pass in the varid
% of an already open file.
%
% The old snctools description was
%
% % NC_GETVARINFO:  returns metadata about a specific NetCDF variable
% %
% % VINFO = NC_GETVARINFO(NCFILE,VARNAME) returns a metadata structure VINFO about
% % the variable VARNAME in the netCDF file NCFILE.
% %
% % VINFO = NC_GETVARINFO(NCID,VARID) returns a metadata structure VINFO about
% % the variable whose netCDF variable-id is VARID, and whose parent file-id is
% % NCID.  The netCDF file is assumed to be open, and in this case the file will
% % not be closed upon completion.
% %
% % VINFO will have the following fields:
% %
% %    Name:
% %       a string containing the name of the variable.
% %    Nctype:
% %       a string specifying the NetCDF datatype of this variable.
% %    Unlimited:
% %       Flag, either 1 if the variable has an unlimited dimension or 0 if not.
% %    Dimensions:
% %       a cell array with the names of the dimensions upon which this variable
% %       depends.
% %    Attribute:
% %       An array of structures corresponding to the attributes defined for the
% %       specified variable.
% %
% %    Each "Attribute" element contains the following fields.
% %
% %       Name:
% %           a string containing the name of the attribute.
% %       Nctype:
% %           a string specifying the NetCDF datatype of this attribute.
% %       Attnum:
% %           a scalar specifying the attribute id
% %       Value:
% %           either a string or a double precision value corresponding to the
% %           value of the attribute
%
%
% bak jc191 6 Feb 2020
%
%
% This code attempts to check for an unlimited dimension, the number of
% which is discovered from netcdf.inq  . This has not been tested because
% we don't have any mexec files with unlimited dimension.
%

clear vinfo

ncid=netcdf.open(ncfile,'NOWRITE');

[ndims,nvars,ngatts,unlimited_dimnum] = netcdf.inq(ncid); % save the unlimited dimnum if there is one

varid = netcdf.inqVarID(ncid, varname);

[varname,xtype,dimids,natts] = netcdf.inqVar(ncid, varid);

% we seem to need to flip the dimids to get the same effect as the snctools
% nc_addvar

dimids = fliplr(dimids);

ndimsv = length(dimids);

vinfo.Name = varname;
vinfo.Nctype = xtype;
vinfo.Unlimited = 0;

for kd = 1:ndimsv
    [dimname, dimlength] = netcdf.inqDim(ncid, dimids(kd));
    vinfo.Dimension{kd} = dimname;
    vinfo.Size(kd) = dimlength;
    if dimids(kd) == unlimited_dimnum
        vinfo.Unlimited = 1;
    end
end

for ka = 1:natts
    attname = netcdf.inqAttName(ncid,varid,ka-1);
    [xtype,attlen] = netcdf.inqAtt(ncid,varid,attname);
    vinfo.Attribute(ka).Name = attname;
    vinfo.Attribute(ka).Nctype = xtype;
    vinfo.Attribute(ka).Attnum = ka-1;
    vinfo.Attribute(ka).Value = netcdf.getAtt(ncid,varid,attname);
end

netcdf.close(ncid);

return



