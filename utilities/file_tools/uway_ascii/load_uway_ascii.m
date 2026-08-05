function varargout = load_uway_ascii(varargin)
%
% load underway data from ascii files
%   they may contain nmea messages,
%   parsed nmea messages (e.g. with timestamps added, or SCS .ACO files), 
%   or bathymetry .xyz files 

m_common
opt1 = 'uway_proc'; opt2 = 'scs_skip'; get_cropt 

if nargin>0
    ddays = varargin{1};
else
    ddays = [];
end

files = dir(fullfile(MEXEC_G.MDIRLIST.M_UWAY_RAW,'*'));
files = {files(cellfun(@(x) x>1024,{files.bytes})).name};

%message definitions comma-separated
nmea.GGA = {'msg','timestamp','nslatitude','ns','ewlongitude','ew','ggaqual','sats','hdop','alt','altval','geosep','geoval','dgpsage','dgpsref_checksum'};
nmeau.GGA = {' ', ' ', 'cdegrees','ns','cdegrees','ew','number','number','disc','disc','disc','disc','disc','disc','disc'};
nmea.GLL = {'msg','nslatitude','ns','ewlongitude','ew','timestamp','status (A valid V not valid)','checksum'};
nmeau.GLL = {' ', 'dd mm,mmmm','ns','dddd mm,mmmm','ew','utc hhmmss.ss','flag','disc'};
% nmea.ZDA = {'msg','utc','day','month','year','tzoff','tzoff','checksum'};
% nmeau.ZDA = {' ', ' ', ' ', ' ', ' ', 'hours', 'mins', 'disc'};
nmea.VTG = {'msg','tmg (degrees true)','T','tmgm (degrees magnetic)','M','speed','N','sog','K','mode'};% (A autonomous D differential E estimated M manual S simulator N not valid);
nmeau.VTG = {' ','degrees true','disc','degrees magnetic','disc','kt','disc','km/hour','disc','disc'};
nmea.VHW = {'msg','heading_true','T','heading_mag','M','speed relative to water'}; %VBW
nmeau.VHW = {' ', 'nm', 'disc','degrees magnetic','disc','kt'};
nmea.HDT = {'msg','head (relative to true north)','checksum'}; %THS replaces this?
nmeau.HDT = {' ','true','disc'};
nmea.HDG = {'msg','head','deviation','devdir (E/W)','variation','vardir (E/W)','checksum'};
nmeau.HDG = {' ','degrees magnetic','degrees magnetic','ew','degrees magnetic','ew','disc'};
nmea.ROT = {'msg','rate_of_turn'};
nmeau.ROT = {' ','degrees/minute'};
nmea.DBT = {'msg','depthft','feet','depth_below_transducer','metres','depthfa','fathomschecksum'};
nmeau.DBT = {' ','disc','disc','m','disc','disc','disc'};
nmea.DBS = {'msg','depthft','feet','depth_below_surface','metres','depthfa','fathomschecksum'};
nmeau.DBS = {' ','disc','disc','m','disc','disc','disc'};
nmea.DPT = {'msg','depth_below_transducer','offset_relative_to_transducer','max_range_scale','checksum'};
nmeau.DPT = {' ','m','m','disc','disc'};
nmea.CR6 = {'msg','latitude','longitude','airtemp','airpress','m0','humid','winddir_true','windspd_true','m1','m2','m3','m4','m5','timestamp'};
nmeau.CR6 = {' ','degrees N','degrees E','degrees C','Pa','unknown','unknown','degrees relative to true N','m/s','unknown','unknown','unknown','unknown','unknown','disc'};
nmea.PASHR = {'msg','timestamp','head','T','roll','pitch','heave','roll_accuracy','pitch_accuracy','heading_accuracy','qual','alignment_status','checksum'};
nmeau.PASHR = {' ','disc','true','degrees','degrees','m','disc','disc','disc','number','number','disc'};
nmea.PSXN = {'msg','linetype','roll','pitch','heading','psxn_heave'};
nmeau.PSXN = {' ','disc','degrees','degrees','degrees','m_checksum'};
nmea.WIMWD = {'msg','winddir','T','m1','m2','windspd','N','m3','checksum'};
nmeau.WIMWD = {' ','degrees true','disc','disc','disc','m/s','disc','disc','disc'};

%are there leading columns e.g. datetimestamp columns
opt1 = 'uway_proc'; opt2 = 'scs_nmea_form'; get_cropt 
colsi = {'date','time'};

mutv = mudefine;

for no = 1:length(files)
    if sum(cellfun(@(x) contains(files{no},x),skip))
        warning('skipping %s',files{no})
        continue
    end
    [~,f,ext] = fileparts(files{no});
    fin = fullfile(MEXEC_G.MDIRLIST.M_UWAY_RAW,files{no});

    %find out about the file
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
        fid = fopen(fin,'r');
        l1 = fgetl(fid); fclose(fid);
        known = 0; msg = [];
        if contains(l1,',') && contains(l1,'$')
            k1 = strfind(l1,'$'); k2 = strfind(l1,',');
            if ~isempty(k1) && ~isempty(k2)
                k1 = k1(1); k2 = k2(k2>k1); k2 = k2(1);
                msg = l1(k1+1:k2-1);
                if length(msg)==5 && isfield(nmea,msg(3:5))
                    msg = msg(3:5);
                end
                if isfield(nmea,msg)
                    %comma-delimited nmea strings
                    delim = ',';
                    vn = [colsi nmea.(msg) colsf];
                    vu = [untsi nmeau.(msg) untsf];
                    known = 1;
                end
                    
            end
        end
        if ~known
            %custom message string; set delimiter and names in cruise options
            opt1 = 'uway_proc'; opt2 = 'scs_nmea_custom'; get_cropt                
        end

        %load the file, and add names/units to columns
        t = readtable(fin,'FileType','delimitedtext','Delimiter',delim); t0 = t;
        n = length(vn); t = t(:,1:n);
        t.Properties.VariableNames = vn;
        t.Properties.VariableUnits = vu;

        %set up nuo to convert variables
        opt1 = 'uway_proc'; opt2 = 'uway_ascii_parse'; get_cropt
        for no = 1:size(nuo,1)
            [~,ia,ib] = intersect(nuo{no,1},vn,'stable');
            if ~isempty(ia) && strcmp(vu(ib(1)),nuo{no,2})
                evalstr = 'cellfun(nuo{no,3}';
                for no1 = 1:length(ia)
                    evalstr = [evalstr ', t.(nuo{no,1}{' num2str(no1) '})'];
                end
                evalstr = [evalstr ');'];
                t.(nuo{no,4}) = eval(evalstr);
                t.Properties.VariableUnits(strcmp(t.Properties.VariableNames,nuo{no,4})) = nuo(no,5);
            end
        end

        if exist('ddays','var') && ~isempty(ddays)
            t = t(t.dday>=ddays(1) & t.dday<ddays(end)+1, :);
        end
        t.date = []; t.time = []; t.msg = [];
        t(:,strcmp(t.Properties.VariableUnits,'disc')) = [];

        %save, possibly appending (merging on time)
        clear d h
        h.fldnam = t.Properties.VariableNames;
        h.fldunt = t.Properties.VariableUnits;
        h.comment = sprintf('loaded from file %s\n',files{no});
        d = table2struct(t,'ToScalar',true);
        d.time = d.dday*3600*24; 
        h.fldnam = [h.fldnam 'time']; 
        h.fldunt = [h.fldunt replace(h.fldunt{strcmp(h.fldnam,'dday')},'days','seconds')];
        mfsave(otfile, d, h, '-merge', 'time')

        if nargout>0
            ds(no) = d; hs(no) = h;
        end

    end

end

if nargout>0
    varargout{1} = ds;
    if nargout>1
        varargout{2} = hs;
    end
end