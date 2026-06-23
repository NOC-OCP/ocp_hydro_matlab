function m_add_default_variable_attributes(ncfile,var_name)
% function m_add_default_variable_attributes(ncfile,var_name)
%
% Add the default attributes for a variable to ncfile

vinfo = nc_getvarinfo(ncfile.name,var_name);


if vinfo.Nctype == 6 %this is a double variable
    attlist = {
        'long_name'         ' '
        'units'             ' '
        'min_value'          -99999
        'max_value'          -99999
        '_FillValue'         -99999
        'missing_value'      -99999
        'number_fillvalue'   0
        };

end

if vinfo.Nctype == 2 %this is a char variable
    attlist = {
        'long_name'         ' '
        'units'             ' '
        '_FillValue'        ' '
        'missing_value'     ' '
        'number_fillvalue'   0
        };

end

for k = 1:size(attlist,1)
    nc_attput(ncfile.name,var_name,attlist{k,1},attlist{k,2});
end
