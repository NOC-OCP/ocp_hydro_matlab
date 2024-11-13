function mputdep(ncfile,depth)
% gdm on jc032
%
% insert depth in header from ldeo ladcp processing
%
% function mputdep(filename,depth)
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

metadata = nc_info(ncfile.name); %refresh metadata

globatt = metadata.Attribute;



for k = 1:length(globatt)
    gattname = globatt(k).Name;
    if strcmp(gattname,'water_depth_metres'); olddep = globatt(k).Value; end
end


%cmd = ['!ls -ld ' filename]; perm = evalc(cmd);
%readonly = 0;
%if ~strcmp(perm(3),'w')
%    readonly = 1;
%    cmd = ['!chmod 644 ' filename]; eval(cmd);
%end


depstr = sprintf('%10.3f',depth);

odepstr = sprintf('%10.3f',olddep);

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

%if readonly == 1
%    cmd = ['!chmod 444 ' filename]; eval(cmd);
%end