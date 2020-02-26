function finfo = nc_info ( ncfile )
%
% version of nc_info for mexec to replace snctools version
% the aim is to replace snctools nc_ calls with faster versions that make
% simple native matlab netcdf calls.
%
% in tests, this is as fast as netcdf ncinfo and much fater than snctools
% nc_info
%
%
% rather than changing every mexec program, the snctools library can be
% replaced with this library
%
% The old snctools description was
%
% % USAGE:  fileinfo = nc_info ( ncfile );
% %
% % PARAMETERS:
% % Input:
% %    ncfile:
% %        a string that specifies the name of the NetCDF file
% % Output:
% %    fileinfo:
% %        A structure whose fields contain information about the contants
% %        of the NetCDF file.  The set of fields return in "fileinfo" are:
% %
% %        Filename:
% %            a string containing the name of the file.
% %        Dimension:
% %            an array of structures describing the NetCDF dimensions.
% %        Dataset:
% %            an array of structures describing the NetCDF datasets.
% %        Attributes:
% %            An array of structures These correspond to the global attributes.
% %
% %
% %        Each "Dimension" element contains the following fields:
% %
% %        Name:
% %            a string containing the name of the dimension.
% %        Length:
% %            a scalar value, the size of this dimension
% %        Unlimited:
% %            Set to 1 if the dimension is the record dimension, set to
% %            0 otherwise.
% %
% %
% %        Each "Dataset" element contains the following structures.
% %
% %        Name:
% %            a string containing the name of the variable.
% %        Nctype:
% %            a string specifying the NetCDF datatype of this variable.
% %        Dimensions:
% %            a cell array with the names of the dimensions upon which
% %            this variable depends.
% %        Unlimited:
% %            Flag, either 1 if the variable has an unlimited dimension
% %            or 0 if not.
% %        Rank:
% %            Array that describes the size of each dimension upon which
% %            this dataset depends.
% %        DataAttributes:
% %            Same as "Attributes" above, but here they are the variable
% %            attributes.
% %
% %        Each "Attribute" or "DataAttribute" element contains the following
% %        fields.
% %
% %        Name:
% %            a string containing the name of the attribute.
% %        Nctype:
% %            a string specifying the NetCDF datatype of this attribute.
% %        Attnum:
% %            a scalar specifying the attribute id
% %        Value:
% %            either a string or a double precision value corresponding to
% %            the value of the attribute
% %
% %
% % The "Dataset" elements are not populated with the actual data values.
% %
% % This routine purposefully mimics that of Mathwork's hdfinfo.
% % character data remains just character data.
%
%
% bak jc191 6 Feb 2020
%

clear finfo

finfo.Filename = ncfile;

globvarnum = netcdf.getConstant('NC_GLOBAL'); % The number to use as varid global attributes. Expect it to be -1

ncid = netcdf.open(ncfile,'NOWRITE');

[numdims,numvars,numglobalatts,unlimdimid] = netcdf.inq(ncid);

for kg = 1:numglobalatts
    % for global atts, use varid -1
    attname = netcdf.inqAttName(ncid,globvarnum,kg-1);
    [xtype,attlen] = netcdf.inqAtt(ncid,globvarnum,attname);
    attrvalue = netcdf.getAtt(ncid,globvarnum,attname);
    finfo.Attribute(kg).Name = attname;
    finfo.Attribute(kg).Nctype = xtype;
    finfo.Attribute(kg).Attnum = kg-1;
    finfo.Attribute(kg).Value = attrvalue;
end

for kd = 1:numdims
    [dimname, dimlen] = netcdf.inqDim(ncid,kd-1);
    finfo.Dimension(kd).Name = dimname;
    finfo.Dimension(kd).Length = dimlen;
    finfo.Dimension(kd).Unlimited = 0;
    if kd == unlimdimid; finfo.Dimension(kd).Unlimited = 1; end
end

for kv = 1:numvars
    [varname,xtype,dimids,natts] = netcdf.inqVar(ncid,kv-1);
    finfo.Dataset(kv).Name = varname;
    finfo.Dataset(kv).Nctype = xtype;
    finfo.Dataset(kv).Unlimited = 0;
    finfo.Dataset(kv).Dimension = {};
    finfo.Dataset(kv).Size = [];
    for kd = 1:length(dimids)
        finfo.Dataset(kv).Dimension = [finfo.Dataset(kv).Dimension finfo.Dimension(dimids(kd)+1).Name];
        finfo.Dataset(kv).Size = [finfo.Dataset(kv).Size finfo.Dimension(dimids(kd)+1).Length];
        if ismember(unlimdimid,dimids); finfo.Dataset(kv).Unlimited = 1; end
    end
    for ka = 1:natts
        attname = netcdf.inqAttName(ncid,kv-1,ka-1);
        [xtype,attlen] = netcdf.inqAtt(ncid,kv-1,attname);
        attrvalue = netcdf.getAtt(ncid,kv-1,attname);
        finfo.Dataset(kv).Attribute(ka).Name = attname;
        finfo.Dataset(kv).Attribute(ka).Nctype = xtype;
        finfo.Dataset(kv).Attribute(ka).Attnum = ka-1;
        finfo.Dataset(kv).Attribute(ka).Value = attrvalue;
    end
    
end

if isfield(finfo,'Attribute'); finfo.Attribute = finfo.Attribute(:); end
if isfield(finfo,'Dimension'); finfo.Dimension = finfo.Dimension(:); end
if isfield(finfo,'Dataset'); finfo.Dataset = finfo.Dataset(:); end


netcdf.close(ncid);

return


