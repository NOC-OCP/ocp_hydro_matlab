function m_update_filedate(ncfile)




%get present time
tnow = now;

v = datevec(tnow);
vr = round(v);

% % % % % 
% % % % % reftime_string = sprintf('(%d,%d,%d,%d,%d,%d)',tref);
% % % % % torg = datenum(tref);
% % % % % t = tnow-torg;

nc_attput(ncfile.name,nc_global,'date_file_updated',vr);

% % % % metadata = nc_info(ncfile.name); %refresh metadata
% % % % ncfile.metadata = metadata;
% % % % % 
% % % % % dimnames = m_unpack_dimnames(ncfile);
% % % % % varnames = m_unpack_varnames(ncfile);
% % % % 
% % % % 
% % % % % Add unity dimension if needed.
% % % % 
% % % % m_add_dimension(ncfile,string_dim_name,string_dim_val);
% % % % m_add_variable_name(ncfile,string_var_name,{string_dim_name},'double');
% % % % m_add_default_variable_attributes(ncfile,string_var_name);

% % % % % %put units for this variable
% % % % % nc_attput(ncfile.name,string_var_name,'units',['decimal days since ' reftime_string]);
% % % % % 
% % % % % %put data
% % % % % nc_varput(ncfile.name,string_var_name,t);
% % % % % 
% % % % % %update uprlwr
% % % % % m_uprlwr(ncfile,string_var_name);

return