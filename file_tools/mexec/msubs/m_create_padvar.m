function m_create_padvar(ncfile)

%create a padding variable so there is always at least one variable in the
%file



% Use this dimension and name .
string_dim_name = 'n_unity';
string_dim_val = 1;
string_var_name = 'pad_variable';


% Add unity dimension if needed.

m_add_dimension(ncfile,string_dim_name,string_dim_val);
m_add_variable_name(ncfile,string_var_name,{string_dim_name},'double');
m_add_default_variable_attributes(ncfile,string_var_name);

%put units for this variable
nc_attput(ncfile.name,string_var_name,'units','pad variable to ensure there is always at least one variable');
% BAK after jc032: eck suggests adding this string to long_name
nc_attput(ncfile.name,string_var_name,'long_name','pad variable to ensure there is always at least one variable');

%put data
nc_varput(ncfile.name,string_var_name,0);

%update uprlwr
m_uprlwr(ncfile,string_var_name,0);

return