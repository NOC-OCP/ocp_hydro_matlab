function m_add_dimension(ncfile,string_dim_name,dim_value)
% function m_add_dimension(ncfile,string_dim_name,dim_value)
%
% Add dimension if it doesn't already exist

metadata = nc_info(ncfile.name); %refresh metadata
ncfile.metadata = metadata;

dimnames = m_unpack_dimnames(ncfile);


%test to see if a dimension already exists; if not, add it.

kmatch = strmatch(string_dim_name,dimnames,'exact');
if isempty(kmatch)
    nc_add_dimension(ncfile.name,string_dim_name,dim_value)
end

% % metadata = nc_info(ncfile.name); %refresh metadata
% % ncfile.metadata = metadata;

return