function mputpos(ncfile,lat,lon) 
% insert position in header
%
% function mputpos(filename,lat,lon)
% 
% Use: mputpos(filename,lat,lon);

m_common

ncfile = m_resolve_filename(ncfile);

if exist(ncfile.name,'file') ~= 2
    m1 = ['mputpos: ''' ncfile.name ''' not found; skipping'];
    fprintf(MEXEC_A.Mfider,'%s\n',m1);
    return
end


ncfile = m_ismstar(ncfile); % check it is an mstar file
filename = ncfile.name;

if exist('ncinfo','file') == 2 % jc191 use matlab netcdf if available
    % make metadata look the same as the old snctools nc_info
    % dm is the matlab data structure; dr is the reconstructed one.
    clear dm dr
    dm = ncinfo(ncfile.name);
    
    dr.Filename = ncfile.name;
    dr.Attribute = dm.Attributes; % don't need in add_variable_name
    dr.Dimension = dm.Dimensions(:);
    for kl = 1:length(dm.Variables);
        dr.Dataset(kl).Name = dm.Variables(kl).Name;
        dr.Dataset(kl).Dimension = dm.Variables(kl).Dimensions.Name;
        dr.Dataset(kl).Nctype = find(strcmp(dm.Variables(kl).Datatype,{'' 'char' '' '' '' 'double' ''}));
    end
    if isfield(dr,'Dataset'); dr.Dataset = dr.Dataset(:); end
    metadata = dr;
else
    metadata = nc_info(ncfile.name); % command before jc191
end

globatt = metadata.Attribute;

for k = 1:length(globatt);
    gattname = globatt(k).Name;
    if strcmp(gattname,'latitude'); oldlat = globatt(k).Value; end
    if strcmp(gattname,'longitude'); oldlon = globatt(k).Value; end
end



cmd = ['!ls -ld ' filename]; perm = evalc(cmd);
readonly = 0;
if ~strcmp(perm(3),'w')
    readonly = 1;
    cmd = ['!chmod 644 ' filename]; eval(cmd);
end

latstr = sprintf('%14.8f',lat);
lonstr = sprintf('%14.8f',lon);
olatstr = sprintf('%14.8f',oldlat);
olonstr = sprintf('%14.8f',oldlon);

    m1 = ['mputpos: ' ncfile.name];

if strncmp(latstr,olatstr,14) & strncmp(lonstr,olonstr,14)
    m2 = 'Lat and lon unchanged:';
    m3 = 'skipping update.';
    fprintf(MEXEC_A.Mfidterm,'%s\n',[m1 ' ' latstr ' ' lonstr  ' ' m2 ' ' m3]);
    return
else
    fprintf(MEXEC_A.Mfidterm,'%s\n',[m1 ' ' latstr ' ' lonstr ' previously ' olatstr ' ' olonstr]);
end


%--------------------------------
MEXEC_A.MARGS_IN = {
filename
'y'
'5'
latstr
lonstr
' '
' '
};
mheadr
%--------------------------------

if readonly == 1
        cmd = ['!chmod 444 ' filename]; eval(cmd);
end