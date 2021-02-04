function [dd ds names units] = get_from_rvdas(stream,dv1,dv2)

% stream = 'surfmet';
% dv1 = [2021 1 27 0 0 0];
% dv2 = [2021 1 28 0 0 0];
switch nargin
    case 2
        dv2 = [2200 01 01 00 00 00]; % far in future
    case 1
        dv2 = [2200 01 01 00 00 00]; % far in future
        dv1 = [1900 01 01 00 00 00]; % far in past
end
dv1 = datevec(datenum(dv1)); % this will convert a datenum to a datevec
dv2 = datevec(datenum(dv2));

[sqlcom fncsv units] = make_psql(stream,dv1,dv2);

fnin = fncsv;

[stat res] = system(sqlcom);

clear ds dd 
ds = dataset('file',fnin,'delimiter',',');

names = ds.Properties.VarNames; names = names(:);

names(1) = []; % variable 1 is always time
units(1) = [];

for kl = 1:length(names)
    cmd = ['dd.' names{kl} ' = ds.' names{kl} ';']; eval(cmd) % convert to structure; time is always present; extract it separately.
end


ts = ds.time;% This is massively faster if we extract ts, and don't access ds.time inside the loop

nt = length(ts);

% padding strings
e4 = '.000+00';
e2 = '00+00';
e1 = '0+00';

for kl = 1:nt
    t = ts{kl};  % This is massively faster if we extract ts, and don't access d.time inside the loop

    lt = length(t);
    % if lt == 26; continue; end
    % if lt == 25; continue;end
    % if lt == 24; continue;end
    % if lt == 22; continue;end
    switch lt
        case 26
            % do nothing
        case 25
            ts{kl} = [t(1:22) e1];
        case 24
            ts{kl} = [t(1:21) e2];
        case 22
            ts{kl} = [t(1:19) e4];
        otherwise
            % should never occur
    end
end


cc = char(ts); % convert from cell array to single long string
st1 = cc'; st1 = st1(:)';
dall = sscanf(st1,'%4d-%2d-%2d %2d:%2d:%6f+%*2d'); % * means skip %2d
dall = reshape(dall,[6 nt]);
dall = dall';
dd.dnum = datenum(dall);

names = [names; {'dnum'}];
units = [units; {'matlab_datenum'}];



% now check for lat and lon that need to be converted from ddmm.mmm to
% decimal degrees

% search strings are 
% 'degrees and decimal minutes'
% 'latitude' 'latdir' 'longitude' 'londir'
ustr1 = 'degrees and decimal minutes';
ustr2 = 'degrees, minutes and decimal minutes'; % some variables use this in the units string

klat1 = find(strcmp('latitude',names));
klat2 = find(strcmp('latdir',names));
if ~isempty(klat1) % latitude found
    if ~isempty(klat2) & (strcmp(units{klat1},ustr1) | strcmp(units{klat1},ustr2)) % latdir found and units of latitude suggest it needs to be converted
        lat1 = dd.latitude;
        deg = floor(lat1/100);
        min = lat1-100*deg;
        
        latdir = char(dd.latdir); latdir = latdir(:)';
        klats = strfind(latdir,'s');
        
        dd.latitude = deg+min/60;
        dd.latitude(klats) = -dd.latitude(klats);
        dd = rmfield(dd,'latdir');
        names(klat2) = [];
        units(klat2) = [];
        units{klat1} = 'decimaldegrees';

    end
end

klon1 = find(strcmp('longitude',names));
klon2 = find(strcmp('londir',names));
if ~isempty(klon1) % longitude found
    if ~isempty(klon2) & (strcmp(units{klon1},ustr1) | strcmp(units{klon1},ustr2)) % londir found and units of longitude suggest it needs to be converted
        lon1 = dd.longitude;
        deg = floor(lon1/100);
        min = lon1-100*deg;
        
        londir = char(dd.londir); londir = londir(:)';
        klonw = strfind(londir,'w');
        
        dd.longitude = deg+min/60;
        dd.longitude(klonw) = -dd.longitude(klonw);
        dd = rmfield(dd,'londir');
        names(klon2) = [];
        units(klon2) = [];
        units{klon1} = 'decimaldegrees';

    end
end






fprintf(1,'%d %s\n',size(ds,2),' vars loaded including time')
numdc = size(ds,1);
if numdc > 0
    fprintf(1,'%d %s %s %s %s\n',size(ds,1),' data cycles loaded from ',datestr(dd.dnum(1),'yyyy-mm-dd HH:MM:SS'), ' to ',datestr(dd.dnum(end),'yyyy-mm-dd HH:MM:SS'))
else
    fprintf(1,'%d %s %s %s %s\n',size(ds,1),' data cycles loaded from ',datestr(dv1,'yyyy-mm-dd HH:MM:SS'), ' to ',datestr(dv2,'yyyy-mm-dd HH:MM:SS'))
end
system(['/bin/rm ' fnin]);
return





