function m_uprlwr(ncfile,var,x)
% function m_uprlwr(ncfile,var,x)
%
% determine upper and lower limit of data and number of fillvalues

vinfo = nc_getvarinfo(ncfile.name,var);
fill = nc_attget(ncfile.name,var,'_FillValue');


% function will execute quicker if we pass the data in as well; save reading it.
if nargin < 3
%    disp('reading data xx')
    x = nc_varget(ncfile.name,var);
end

s  = size(x);
if length(s) > 1
    x = reshape(x,1,numel(x));
end

if vinfo.Nctype == 6 %this is a double variable, min, max, fill have obvious meaning
    % FillValues and missingvalues are read in as NaN
    vmin = min(x);
    vmax = max(x);
    nfill = sum(isnan(x));
    
    if isnan(vmin); vmin = fill; end
    if isnan(vmax); vmax = fill; end

    nc_attput(ncfile.name,var,'min_value',vmin);
    nc_attput(ncfile.name,var,'max_value',vmax);

end



if vinfo.Nctype == 2 %this is a char variable
    nfill = length(strfind(x,fill));
end

nc_attput(ncfile.name,var,'number_fillvalue',nfill);

return
