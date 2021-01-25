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

metadata = nc_info(ncfile.name); %refresh metadata

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