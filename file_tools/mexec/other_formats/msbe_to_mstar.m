function varargout = msbe_to_mstar(varargin)
%
% ncfile = msbe_to_mstar(varargin)
% [d, h, ncfile] = msbe_to_mstar(varargin)
% [d, h] = msbe_to_mstar(varargin)
%
% load sbe ctd file into mstar file (ncfile)
% and/or into mstar-format data (d) and header (h) structures

m_common
m_margslocal
m_varargs

MEXEC_A.Mprog = mfilename;
m_proghd

if nargout==2
    savefile = 0;
else
    savefile = 1;
end

m = 'Type name of sbe file ';
sfile = m_getinput(m,'s');
% sfile = '94ctd12_ctm.cnv';

fid = fopen(sfile,'r');
head = {};
while 1
    s = fgets(fid);
    if strncmp('*END*',s,5); break; end
    %knl = strfind(s,newline); s(knl) = []; % strip out newline chars
    %kcr = strfind(s,sprintf('\r')); s(kcr) = []; % strip out carriage return chars
    s = replace(replace(s,newline,''),'\r',''); % strip out newline and carriage return chars
    head = [head s];
end

% unpack data time origin eg
% # start_time = Dec 12 2003 17:30:06
% * NMEA UTC (Time) = Mar 29 2009  02:25:31
%   BAK & GDM on JC032 29 March 2009; parse NMEA start time if present
index = strncmp('* NMEA UTC',head,10);
if sum(index)==0
    % parse for "start time" string instead
    index = strncmp('# start_time',head,12);
end
if sum(index)
    % parse NMEA start time string
    st = head{index};
    isp = strfind(st,'=');
    string = st(isp+2:end);
    dnum = datenum(string,'mmm dd yyyy  HH:MM:SS');
    h.data_time_origin = datevec(dnum);
    head(index) = [];
end

%unpack scan interval e.g.
%  # interval = seconds: 0.0416667
index = strncmp('# interval',head,10);
if sum(index)
    st = head{index};
    isp = strfind(st,'=');
    string = st(isp+2:end);
    h.recording_interval = string;
    head(index) = [];
end

%unpack number of expected cycles eg
% # nvalues = 220423
index = strncmp('# nvalues',head,9);
st = head{index};
isp = strfind(st,'=');
string = st(isp+2:end);
num_expected = str2double(string);
head(index) = [];

%unpack bad flag eg
% # bad_flag = -9.990e-29
index = strncmp('# bad_flag',head,10);
st = head{index};
isp = strfind(st,'=');
string = st(isp+2:end);
sbe_bad_flag =  str2double(string);
head(index) = [];


% unpack platform details eg
% ** Ship:
% ** Cruise:
% ** Station:
% ** Latitude:
% ** Longitude:
h.platform_type = 'ship'; % maybe a safe assumption ?'

index = strncmp('** Ship',head,7);
if ~isempty(index)
    st = head{index};
    isp = strfind(st,':');
    string = st(1+isp(1):end);
    h.platform_identifier = m_remove_outside_spaces(string);
    head(index) = [];
else
    h.platform_identifier = [];
end

index = strncmp('** Cruise',head,9);
if ~isempty(index)
    st = head{index};
    isp = strfind(st,':');
    string = st(1+isp(1):end);
    h.platform_number = m_remove_outside_spaces(string);
    head(index) = [];
else
    h.platform_number =  [];
end


% BAK & GDM on JC032 29 March 2009; parse NMEA positions if present
index = strncmp('* NMEA Latitude',head,15);
if sum(index)
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
        lat = str2double(latdegs) + str2double(latmins)/60;
        if strcmp(lathems,'S'); lat = -lat; end
        
        h.latitude = lat;
    end
    head(index) = [];
else
    index = strncmp('** Latitude',head,11);
    if sum(index)
        st = head{index};
        m1 = 'NMEA Latitude string not found but operator-entered latitude found';
        m2 = 'Do you want to use it in the mstar file header (n or carriage return (default) or y)?';
        m = sprintf('%s\n',m1,m2);
        reply = m_getinput(m,'s');
        if strncmp(reply,'y',1)
            isp = strfind(st,':');
            string = st(1+isp(1):end);
            h.latitude = str2double(string);
        else
            h.latitude =  [];
        end
        head(index) = [];
    end
end


index = strmatch('* NMEA Longitude',head);
if sum(index)
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
        lon = str2double(londegs) + str2double(lonmins)/60;
        if strcmp(lonhems,'W'); lon = -lon; end
        h.longitude = lon;
    end
    head(index) = [];
else
    index = strmatch('** Longitude',head);
    if sum(index)
        m1 = 'NMEA Longitude string not found but operator-entered longitude found';
        m2 = 'Do you want to use it in the mstar file header (n or carriage return (default) or y)?';
        m = sprintf('%s\n',m1,m2);
        reply = m_getinput(m,'s');
        if strncmp(reply,'y',1)
            st = head{index};
            isp = strfind(st,':');
            string = st(1+isp(1):end);
            h.longitude = str2double(string);
        else
            h.longitude =  [];
        end
        head(index) = [];
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

index = strncmp('# nquan',head,7);
if sum(index)
    st = head{index};
    isp = strfind(st,' ');
    string = st(1+isp(3):end);
    noflds = str2double(string);
    head(index) = [];
else
    m = 'Failed to identify number of variables; didn''t find string ''# nquan'' in file';
    fprintf(MEXEC_A.Mfider,'%s\n',m);
    return
end

% scan names and units for each variable
varname = cell(1,noflds); varname_long = varname; varunits = varname;
for k = 1:noflds
    sbe_string = ['# name ' sprintf('%d',k-1) ' '];
    index = strncmp(sbe_string,head,length(sbe_string));
    st = head{index};
    isp = strfind(st,' ');
    ibrl = strfind(st,'[');
    ibrr = strfind(st,']');
    varname{k} = st(1+isp(4):isp(5)-2);
    if isempty(ibrl)
        varname_long{k} = st(isp(5)+1:end);
        varunits{k} = 'number';
    else
        varname_long{k} = st(isp(5)+1:ibrl-1);
        varunits{k} = st(ibrl+1:ibrr-1);
    end
    head(index) = [];
end
% chop all the span lines out of the header
index = strncmp('# span ',head,6);
head(index) = [];


h.instrument_identifier = 'ctd';
h.dataname = 'sbe_ctd_rawdata';


if savefile
    
    %get mstar filename and check it is not open
    ncfile.name = m_getfilename;
    ncfile = m_openot(ncfile);
    
    nc_attput(ncfile.name,nc_global,'dataname',h.dataname); %set the dataname
    nc_attput(ncfile.name,nc_global,'instrument_identifier',h.instrument_identifier);
    
    %write header variables
    if ~isempty(h.platform_type); nc_attput(ncfile.name,nc_global,'platform_type',h.platform_type); end
    if ~isempty(h.platform_identifier); nc_attput(ncfile.name,nc_global,'platform_identifier',h.platform_identifier); end
    if ~isempty(h.platform_number); nc_attput(ncfile.name,nc_global,'platform_number',h.platform_number); end
    if ~isempty(h.instrument_identifier); nc_attput(ncfile.name,nc_global,'instrument_identifier',h.instrument_identifier); end
    if ~isempty(h.recording_interval); nc_attput(ncfile.name,nc_global,'recording_interval',h.recording_interval); end
    if ~isempty(h.latitude); nc_attput(ncfile.name,nc_global,'latitude',h.latitude); end
    if ~isempty(h.longitude);nc_attput(ncfile.name,nc_global,'longitude',h.longitude); end
    nc_attput(ncfile.name,nc_global,'data_time_origin',h.data_time_origin);
    
else
    h.fldnam = {}; h.fldunt = {};
    h.comment = [];
    clear d %unnecessary? but acts as marker
end

% get data

disp('reading data');

data1 = fscanf(fid,'%f',[noflds,inf]); % read data in, different variables go into rows (noflds), find out how many scans
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
    v.data = data1(k,:)';
    v.data(v.data == sbe_bad_flag) = nan; % set sbe bad data to nan
    v.units = varunits{k};
    if savefile
        m = ['writing data for variable ' v.name];
        fprintf(MEXEC_A.Mfidterm,'%s\n',m);
        m_write_variable(ncfile,v);
    else
        h.fldnam = [h.fldnam v.name];
        h.fldunt = [h.fldunt v.units];
        d.(v.name) = v.data;
    end
end


%pack remainder of header in comments
while ~isempty(head)
    clear c;
    c = [];
    for k = 1:min(4,length(head))
        c = [c sprintf('%s',head{1}) ' | '];
        head(1) = [];
    end
    inl = strfind(c,newline);
    c(inl) = []; % strip out the newline chars that were read in with fgets
    c = strrep(c,'\','\\');
    if savefile
        m_add_comment(ncfile,c);
    else
        h.comment = [h.comment c];
    end
end

nowstring = datestr(now,31);
if savefile
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
end

if nargout==1
    varargout = ncfile;
elseif ~savefile
    varargout{1} = d; varargout{2} = h;
    if nargout==3
        varargout{3} = ncfile;
    end
end

if numcycles ~= num_expected
    m = ['Warning number of cycles read in ('  sprintf('%d',numcycles) ')'];
    m2 = ['was not the same as given in header (' sprintf('%d',num_expected) ')'];
    fprintf(MEXEC_A.Mfider,'%s\n',' ',m,m2)
end


return
