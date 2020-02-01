function mputdep(ncfile,depth)
% gdm on jc032
%
% insert depth in header from ldeo ladcp processing
%
% function mputpos(filename,depth)
%
% Use: mputdep(filename,depth);

m_common

ncfile = m_resolve_filename(ncfile);

if exist(ncfile.name,'file') ~= 2
    m1 = ['mputdep: ''' ncfile.name ''' not found; skipping']; % command name corrected on di368
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
    if strcmp(gattname,'water_depth_metres'); olddep = globatt(k).Value; end
end


cmd = ['!ls -ld ' filename]; perm = evalc(cmd);
readonly = 0;
if ~strcmp(perm(3),'w')
    readonly = 1;
    cmd = ['!chmod 644 ' filename]; eval(cmd);
end


depstr = sprintf('%010.3f',depth);

odepstr = sprintf('%010.3f',olddep);

m1 = ['mputdep: ' ncfile.name];

if strncmp(depstr,odepstr,10)
    m2 = 'Depth unchanged:';
    m3 = 'skipping update.';
    fprintf(MEXEC_A.Mfidterm,'%s\n',[m1 ' ' depstr ' ' m2 ' ' m3]);
    return
else
    fprintf(MEXEC_A.Mfidterm,'%s\n',[m1 ' ' depstr ' previously ' odepstr ]);
end

%--------------------------------
MEXEC_A.MARGS_IN = {
    filename
    'y'
    '6'
    depstr
    ' '
    ' '
    ' '
    };
mheadr
%--------------------------------

if readonly == 1
    cmd = ['!chmod 444 ' filename]; eval(cmd);
end