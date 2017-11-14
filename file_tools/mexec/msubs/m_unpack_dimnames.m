function dim_names = m_unpack_dimnames(ncfile)
% function dim_names = m_unpack_dimnames(ncfile)
%
% Unpack dimension names from netcdf file ncfile (a structure)
%
% If the metadata isn't in the structure ncfile, then read it from the file

if ~isfield(ncfile,'metadata')
    metadata = nc_info(ncfile.name);
    ncfile.metadata = metadata;
end

metadata = ncfile.metadata;

if isfield (metadata, 'Dimension' )
    num_dims = length(metadata.Dimension);
else
    num_dims = 0;
end

dim_names = cell(num_dims,1);

for k = 1:num_dims
    dim_names{k} =  metadata.Dimension(k).Name;
end

return