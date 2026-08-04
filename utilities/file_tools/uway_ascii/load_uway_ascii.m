function mu = load_uway_ascii
%
% load underway data from ascii files
%   they may contain nmea messages,
%   parsed nmea messages (e.g. with timestamps added, or SCS .ACO files), 
%   or bathymetry .xyz files 

m_common
opt1 = 'uway_proc'; opt2 = 'scs_skip_add'; get_cropt 

files = dir(fullfile(MEXEC_G.MDIRLIST.M_UWAY_RAW,'*'));
files = {files(cellfun(@(x) x>1024,{files.bytes})).name};


%message definitions comma-separated
nmea.GGA = {'msg','timestamp','latitude','ns','longitude','ew','ggaqual','sats','hdop','alt','altval','geosep','geoval','dgpsage','dgpsref_checksum'};
nmeau.GGA = {' ', ' ', 'cdegrees','ns','cdegrees','ew','number','number','disc','disc','disc','disc','disc','disc','disc'};
nmea.GLL = {'msg','latitude','ns','longitude','ew','timestamp','status (A valid V not valid)','checksum'};
nmeau.GLL = {' ', 'dd mm,mmmm','ns','dddd mm,mmmm','ew','utc hhmmss.ss','flag','disc'};
nmea.ZDA = {'msg','utc','day','month','year','tzoff','tzoff','checksum'};
nmeau.ZDA = {' ', ' ', ' ', ' ', ' ', 'hours', 'mins', 'disc'};
nmea.VTG = {'msg','tmg (degrees true)','T','tmgm (degrees magnetic)','M','speed (kt)','N','sog (kph)','K','mode (A autonomous D differential E estimated M manual S simulator N not valid)'};
nmea.VHW = {'msg','heading (nm)','T','heading (degrees magnetic)','M','speed relative to water (kt)'}; %VBW
nmea.HDT = {'msg','head (relative to true north)','checksum'}; %THS replaces this?
nmea.HDG = {'msg','degrees (magnetic)','deviation (degrees magnetic)','devdir (E/W)','variation (degrees magnetic)','vardir (E/W)','checksum'};
nmea.ROT = {'msg','rate of turn (degrees/minute)'};
nmea.DBT = {'msg','depthft','feet','depth_below_transducer (m)','metres','depthfa','fathoms','checksum'};
nmea.DBS = {'msg','depthft','feet','depth_below_surface (m)','metres','depthfa','fathoms','checksum'};
nmea.DPT = {'msg','depth_below_transducer (m)','offset relative to transducer (metres)','max_range_scale','checksum'};
msgs = fieldnames(nmea);

%are there leading columns e.g. datetimestamp columns
opt1 = 'uway_proc'; opt2 = 'scs_nmea_form'; get_cropt 
colsi = {'date','time'};

for no = 1:length(files)
    [p,f,ext] = fileparts(files{no});

    if strcmp(ext,'.XYZ')
        %bathy xyz files
        delim = ' ';
        vn = {'lat','ns','lon','ew','depth','date','time', 'j1'};
        vu = {'degrees','ns','degrees','ew','m','yyyymmdd','HHMMSS.SS',' '};

    elseif strcmp(ext,'.ACO')
        h = readtable(fullfile(p,[f '.TPL']),',');
        vn = {'year', 'dday', 'j1', 'j2', h(:,2)'}; %***is it dday or yday?
        vu = {'year', 'since year', ' ', ' ', h(:,3)'};
        delim = ',';

    elseif ~strcmp(ext,'.TPL') %already read the .TPL file when handling the .ACO
        fid = fopen(fid,'r');
        l1 = fgetl(fid); fclose(fid);
        if contains(l1,',') && contains(l1,'$')
            k = strfind(l1,'$');
            msg = l1(k+3:k+5);
            if isfield(nmea,msg)
                %comma-delimited nmea strings
                delim = ',';
                vn = [colsi nmea.(msg) colsf];
                vu = [untsi nmeau.(msg) untsf];
            else
                warning('%s first line is nmea-like but no nmea message fields defined for %s',files{no},msg)
                %***
            end

        end

    end

    t = readtable(fullfile(MEXEC_G.MDIRLIST.M_UWAY_RAW,files{no}),'FileType','delimitedtext','Delimiter',delim);
    t.Properties.VariableNames = vn;
    t.Properties.VariableUnits = vu;

end

%barry christie at p&o would know about the cr6 met package
