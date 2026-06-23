function m_pstar_filedate(ncfile,pstar_fn)
% function m_pstar_filedate(ncfile,pstar_fn)
%
% Add or update a variable that stores the last time the file was modified
% when converting pstar files, use unix file date

% Use this dimension and name for "file update date".
string_dim_name = 'n_unity';
string_dim_val = 1;
string_var_name = 'date_file_updated';

files = dir(pstar_fn);
tfile = cell2mat({files.datenum});

torg = datenum(1950,1,1,0,0,0);
t = tfile-torg;

metadata = nc_info(ncfile.name); %refresh metadata
ncfile.metadata = metadata;
% 
% dimnames = m_unpack_dimnames(ncfile);
% varnames = m_unpack_varnames(ncfile);
% % % % % 
% % % % % 
% % % % % % Add unity dimension if needed.
% % % % % 
% % % % % m_add_dimension(ncfile,string_dim_name,string_dim_val);
% % % % % m_add_variable_name(ncfile,string_var_name,{string_dim_name},'double');
% % % % % m_add_default_variable_attributes(ncfile,string_var_name);
% % % % % 
% % % % % %put units for this variable
% % % % % nc_attput(ncfile.name,string_var_name,'units','decimal days since (1950,1,1,0,0,0)');
% % % % % 
% % % % % %put data
% % % % % nc_varput(ncfile.name,string_var_name,t);
% % % % % 
% % % % % %update uprlwr
% % % % % m_uprlwr(ncfile,string_var_name);


v = datevec(tfile);
vr = round(v);
nc_attput(ncfile.name,nc_global,'date_file_updated',vr);

return