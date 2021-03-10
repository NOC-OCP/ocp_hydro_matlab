function ncfile = msbe_to_mstar(varargin)
%
% % load sbe ctd  file into mstar file
%
m_common
m_margslocal
m_varargs

MEXEC_A.Mprog = 'msbe_to_mstar';
m_proghd

m = 'Type name of sbe file ';
sfile = m_getinput(m,'s');
% sfile = '94ctd12_ctm.cnv';

% mstar_fn = m_getfilename; % file name found later on

fid = fopen(sfile,'r');
shead_all = {};
e = 0;
while e == 0
    s = fgets(fid);
    knl = strfind(s,sprintf('\n')); s(knl) = []; % strip out newline chars
    kcr = strfind(s,sprintf('\r')); s(kcr) = []; % strip out carriage return chars
    shead_all = [shead_all s];
    if strncmp('*END*',s,5); e = 1; end
end

head = shead_all;

% unpack data time origin eg
% # start_time = Dec 12 2003 17:30:06
% * NMEA Latitude = 23 59.95 S
% * NMEA Longitude = 027 01.98 W
% * NMEA UTC (Time) = Mar 29 2009  02:25:31
%   BAK & GDM on JC032 29 March 2009; parse NMEA start time if present
index = strmatch('* NMEA UTC',head);
% index = strmatch('* System UpLoad Time',head);% GDM dummy argument jc064
if ~isempty(index)
    % parse NMEA start time string
    st = head{index};
    isp = strfind(st,' ');
    string = st(1+isp(5):end);
    dnum = datenum(string,'mmm dd yyyy  HH:MM:SS');
    h.data_time_origin = datevec(dnum);
    head(index) = [];
else
    % parse for "start time" string instead
    index = strmatch('# start_time',head);
    st = head{index};
    isp = strfind(st,' ');
    string = st(1+isp(3):end);
    dnum = datenum(string,'mmm dd yyyy HH:MM:SS');
    h.data_time_origin = datevec(dnum);
    head(index) = [];
end
% end of JC032 mod

%unpack scan interval eg
%# interval = seconds: 0.0416667
index = strmatch('# interval',head);
if ~isempty(index)
    st = head{index};
    isp = strfind(st,' ');
    string = st(1+isp(3):end);
    h.recording_interval = string;
    int =  str2num(st(1+isp(4):end));
    head(index) = [];
end

%unpack number of expected cycles eg
% # nvalues = 220423
index = strmatch('# nvalues',head);
st = head{index};
isp = strfind(st,' ');
string = st(1+isp(3):end);
num_expected =  str2num(string);
head(index) = [];

%unpack bad flag eg
% # bad_flag = -9.990e-29
index = strmatch('# bad_flag',head);
st = head{index};
isp = strfind(st,' ');
string = st(1+isp(3):end);
sbe_bad_flag =  str2num(string);
head(index) = [];


% unpack platform details eg
% ** Ship:
% ** Cruise:
% ** Station:
% ** Latitude:
% ** Longitude:
h.platform_type = 'ship'; % maybe a safe assumption ?'

index = strmatch('** Ship',head);
if ~isempty(index)
    st = head{index};
    isp = strfind(st,':');
    string = st(1+isp(1):end);
    h.platform_identifier = m_remove_outside_spaces(string);
    head(index) = [];
else
    h.platform_identifier = [];
end

index = strmatch('** Cruise',head);
if ~isempty(index)
    st = head{index};
    isp = strfind(st,':');
    string = st(1+isp(1):end);
    h.platform_number = m_remove_outside_spaces(string);
    head(index) = [];
else
    h.platform_number =  [];
end


% * NMEA Latitude = 23 59.95 S
% * NMEA Longitude = 027 01.98 W
% * NMEA UTC (Time) = Mar 29 2009  02:25:31
% BAK & GDM on JC032 29 March 2009; parse NMEA positions if present
index = strmatch('* NMEA Latitude',head);
if ~isempty(index)
    % parse NMEA latitude string
    m1 = 'NMEA Latitude string found';
    m2 = 'Do you want to use it in the mstar file header (y (default) or n) ? ';
    m = sprintf('%s\n',m1,m2);
    reply = m_getinput(m,'s');
    if strncmp(reply,'n',1)
        h.latitude = []; % JC032, latitude remains empty if reply is 'n'
    else
        st = head{index};
        isp = strfind(st,' ');
        
        latdegs = st(1+isp(4):2+isp(4));
        latmins = st(1+isp(5):5+isp(5));
        lathems = st(1+isp(6));
        lat = str2num(latdegs) + str2num(latmins)/60;
        if strcmp(lathems,'S'); lat = -lat; end
        
        h.latitude = lat;
        head(index) = [];
    end
else
    m1 = 'NMEA Latitude string not found ';
    m2 = 'Lat info in mstar file will be left as absent ';
    m3 = 'Reply with carriage return for compatibility with case where NMEA is found ';
    m = sprintf('%s\n',m1,m2,m3);
    reply = m_getinput(m,'s');
    index = strmatch('** Latitude',head);
    if ~isempty(index)
        st = head{index};
        isp = strfind(st,':');
        string = st(1+isp(1):end);
        h.latitude =  [];%str2num(string); % temporarily disabled until we know more about format of this variable in sbe files
        %     head(index) = [];% don't remove the lat info because we don't know
        %     how to save it in the mstar header yet
    else
        h.latitude =  [];
    end
end


index = strmatch('* NMEA Longitude',head);
if ~isempty(index)
    % parse NMEA longitude string
    m1 = 'NMEA Longitude string found';
    m2 = 'Do you want to use it in the mstar file header (y (default) or n) ? ';
    m = sprintf('%s\n',m1,m2);
    reply = m_getinput(m,'s');
    if strncmp(reply,'n',1)
        h.longitude = []; % JC032, longitude remains empty if reply is 'n'
    else
        st = head{index};
        isp = strfind(st,' ');
        
        londegs = st(1+isp(4):3+isp(4));
        lonmins = st(1+isp(5):5+isp(5));
        lonhems = st(1+isp(6));
        lon = str2num(londegs) + str2num(lonmins)/60;
        if strcmp(lonhems,'W'); lon = -lon; end
        
        h.longitude = lon;
        head(index) = [];
    end
else
    m1 = 'NMEA Longitude string not found ';
    m2 = 'Lon info in mstar file will be left as absent ';
    m3 = 'Reply with carriage return for compatibility with case where NMEA is found ';
    m = sprintf('%s\n',m1,m2,m3);
    reply = m_getinput(m,'s');
    index = strmatch('** Longitude',head);
    if ~isempty(index)
        st = head{index};
        isp = strfind(st,':');
        string = st(1+isp(1):end);
        h.longitude =  [];%str2num(string); % temporarily disabled until we know more about format of this variable in sbe files
        %     head(index) = []; % don't remove the lon info because we don't know
        %     how to save it in the mstar header yet
    else
        h.longitude =  [];
    end
end


% unpack the var names and units eg
% # nquan = 10
% # nvalues = 220423
% # units = specified
% # name 0 = scan: Scan Count
% # name 1 = prDM: Pressure, Digiquartz [db]
% # name 2 = t090C: Temperature [ITS-90, deg C]
% # name 3 = t190C: Temperature, 2 [ITS-90, deg C]
% # name 4 = c0mS/cm: Conductivity [mS/cm]
% # name 5 = c1mS/cm: Conductivity, 2 [mS/cm]
% # name 6 = altM: Altimeter [m]
% # name 7 = ptempC: Pressure Temperature [deg C]
% # name 8 = nbf: Bottles Fired
% # name 9 = flag:  0.000e+00
% # span 0 =          1,     220423
% # span 1 =     -2.047,   3811.771
% # span 2 =    -0.5848,     1.8990
% # span 3 =    -0.5867,     1.8974
% # span 4 =  -0.002686,  30.688519
% # span 5 =  -1.681554,  30.687321
% # span 6 =       9.47,     100.00
% # span 7 =       0.98,       1.36
% # span 8 =          0,         12
% # span 9 = 0.0000e+00, 0.0000e+00

index = strmatch('# nquan',head);
if ~isempty(index)
    st = head{index};
    isp = strfind(st,' ');
    string = st(1+isp(3):end);
    noflds =  str2num(string);
    head(index) = [];
else
    m = 'Failed to identify number of variables; didn''t find string ''# nquan'' in file';
    fprintf(MEXEC_A.Mfider,'%s\n',m);
    return
end

% scan each variable
for k = 1:noflds
    varname{k} = []; varname_long{k} = []; varunits{k} = [];
    sbe_string = ['# name ' sprintf('%d',k-1) ' '];
    index = strmatch(sbe_string,head);
    st = head{index};
    isp = strfind(st,' ');
    ibrl = strfind(st,'[');
    ibrr = strfind(st,']');
    varname{k} = st(1+isp(4):isp(5)-2);
    if isempty(ibrl);
        varname_long{k} = st(isp(5)+1:end);
        varunits{k} = 'number';
    else
        varname_long{k} = st(isp(5)+1:ibrl-1);
        varunits{k} = st(ibrl+1:ibrr-1);
    end
    head(index) = [];
end
for k = 1:noflds
    % chop the span part out of the header
    sbe_string = ['# span ' sprintf('%d',k-1) ' '];
    index = strmatch(sbe_string,head);
    head(index) = [];
end


h.instrument_identifier = 'ctd';
h.dataname = 'sbe_ctd_rawdata';



mstar_fn = m_getfilename;

ncfile.name = mstar_fn;
ncfile = m_openot(ncfile); %check it is not an open mstar file

nc_attput(ncfile.name,nc_global,'dataname',h.dataname); %set the dataname
nc_attput(ncfile.name,nc_global,'instrument_identifier',h.instrument_identifier);

if ~isempty(h.platform_type); nc_attput(ncfile.name,nc_global,'platform_type',h.platform_type); end
if ~isempty(h.platform_identifier); nc_attput(ncfile.name,nc_global,'platform_identifier',h.platform_identifier); end
if ~isempty(h.platform_number); nc_attput(ncfile.name,nc_global,'platform_number',h.platform_number); end
if ~isempty(h.instrument_identifier); nc_attput(ncfile.name,nc_global,'instrument_identifier',h.instrument_identifier); end
if ~isempty(h.recording_interval); nc_attput(ncfile.name,nc_global,'recording_interval',h.recording_interval); end
if ~isempty(h.latitude); nc_attput(ncfile.name,nc_global,'latitude',h.latitude); end
if ~isempty(h.longitude);nc_attput(ncfile.name,nc_global,'longitude',h.longitude); end
nc_attput(ncfile.name,nc_global,'data_time_origin',h.data_time_origin);

% get data

disp('reading data');

data1 = fscanf(fid,'%f',[noflds,inf]); % read data in, number of rows is noflds
fclose(fid);
numcycles = size(data1,2);

if numcycles ~= num_expected
    m = ['Warning number of cycles read in ('  sprintf('%d',numcycles) ')'];
    m2 = ['was not the same as given in header (' sprintf('%d',num_expected) ')'];
    fprintf(MEXEC_A.Mfider,'%s\n',m,m2)
end

for k = 1:noflds
    clear v
    v.name = m_check_nc_varname(varname{k});
    v.data = data1(k,:);
    v.data(v.data == sbe_bad_flag) = nan; % set sbe bad data to nan
    v.units = varunits{k};
    m = ['writing data for variable ' v.name];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m);
    m_write_variable(ncfile,v);
end


%pack remainder of header in comments
while length(head) > 0
    clear c;
    c = [];
    for k = 1:min(4,length(head))
        c = [c sprintf('%s',head{1}) ' | '];
        head(1) = [];
    end
    inl = strfind(c,sprintf('\n'));
    c(inl) = []; % strip out the newline chars that were read in with fgets
    c = strrep(c,'\','\\');
    m_add_comment(ncfile,c);
end

nowstring = datestr(now,31);
m_add_comment(ncfile,'This mstar file created from sbe file');
m_add_comment(ncfile,sfile);
m_add_comment(ncfile,['at ' nowstring]);



% finish up


m_finis(ncfile);

h = m_read_header(ncfile);
if ~MEXEC_G.quiet; m_print_header(h); end

hist = h;
hist.filename = ncfile.name;
MEXEC_A.Mhistory_ot{1} = hist;
% fake the input file details so that write_history works
histin = h;
histin.filename = sfile;
histin.dataname = [];
histin.version = [];
histin.mstar_site = [];
MEXEC_A.Mhistory_in{1} = histin;
m_write_history;


if numcycles ~= num_expected
    m = ['Warning number of cycles read in ('  sprintf('%d',numcycles) ')'];
    m2 = ['was not the same as given in header (' sprintf('%d',num_expected) ')'];
    fprintf(MEXEC_A.Mfider,'%s\n',' ',m,m2)
end


return
