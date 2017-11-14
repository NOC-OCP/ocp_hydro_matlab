function var_names = m_unpack_varnames(ncfile)

% Unpack variable names from netcdf file

%If the metadata isn't passed in, then read it from the file
[ncid,MEXEC.status] = mexnc('open',ncfile.name,nc_nowrite_mode);
[ndims, nvars, ngatts, record_dimension, MEXEC.status] = mexnc('INQ', ncid);

var_names = cell(nvars,1);

for k = 1:nvars; 
    [varname, datatype, ndims, dims, natts, MEXEC.status] = mexnc('INQ_VAR', ncid, k-1); 
    var_names{k} = varname;
end;

MEXEC.status = mexnc('close',ncid);

% % if ~isfield(ncfile,'metadata')
% %     metadata = nc_info(ncfile.name);
% %     ncfile.metadata = metadata;
% % end
% % 
% % metadata = ncfile.metadata;
% % 
% % if isfield ( metadata, 'Dataset' )
% %     num_vars = length(metadata.Dataset);
% % else
% %     num_vars = 0;
% % end
% % 
% % var_names = cell(num_vars,1);
% % 
% % for k = 1:num_vars
% %     var_names{k} =  metadata.Dataset(k).Name;
% % end
% % 
% % return