function varargout = load_uway_ascii(varargin)
%
% load underway data from ascii files
%   they may contain nmea messages,
%   parsed nmea messages (e.g. with timestamps added, or SCS .ACO files), 
%   or bathymetry .xyz files 

m_common
mutv = mudefine;
opt1 = 'uway_proc'; opt2 = 'scs_skip'; get_cropt 
mutv(ismember(mutv.nmeas_msg,skip),:) = [];

if nargin>0
    ddays = varargin{1};
else
    ddays = [];
end

%get the defined sentences
nmeas = nmea_sentences; 
%get special patterns (no $MSG in the file) as well as info on e.g. datimestamp columns
opt1 = 'uway_proc'; opt2 = 'scs_nmea_form'; get_cropt 

for tno = 99:length(mutv.scsfilepat)

    %will we subsample times before saving? e.g. gyro to 1 hz
    opt1 = 'uway_proc'; opt2 = 'tstep_save'; get_cropt

    files = dir(fullfile(MEXEC_G.MDIRLIST.M_UWAY_RAW,mutv.scsfilepat{tno}));
    files = {files(cellfun(@(x) x>153,{files.bytes})).name};
    otfile = fullfile(MEXEC_G.mexec_data_root,mutv.mstardir{tno},[mutv.mstarpre{tno} '_' mcruise '_all_raw.nc']);

    for fno = 1:length(files)
        if sum(cellfun(@(x) contains(files{fno},x),skip))
            warning('skipping %s',files{fno})
            continue
        end
        [~,f,ext] = fileparts(files{fno});
        fin = fullfile(MEXEC_G.MDIRLIST.M_UWAY_RAW,files{fno});

        %find out about the file
        if strcmp(ext,'.XYZ')
            %bathy xyz files
            delim = ' ';
            vn = {'nslatitude','ns','ewlongitude','ew','depth',    'date',     'time', 'j1'};
            vu = {   'degrees','ns',    'degrees','ew',    'm','yyyymmdd','HHMMSS.SS',  ' '};
    
        elseif strcmp(ext,'.ACO')
            h = readtable(fullfile(p,[f '.TPL']),',');
            vn = {'year', 'dday', 'j1', 'j2', h(:,2)'}; %***is it dday or yday?
            vu = {'year', 'since year', ' ', ' ', h(:,3)'};
            delim = ',';
    
        elseif ~strcmp(ext,'.TPL') %already read the .TPL file when handling the .ACO
            if ~isempty(mutv.nmeas_msg{tno})
                vn = [colsi nmeas.(mutv.nmeas_msg{tno})(1,:) colsf];
                vu = [untsi nmeas.(mutv.nmeas_msg{tno})(2,:) untsf];
                delim = ',';
            else
                %custom message string; set delimiter and names in cruise options
                opt1 = 'uway_proc'; opt2 = 'scs_nmea_custom'; get_cropt                
            end
        end

        %load the file, and add names/units to columns
        if isempty(delim)
            t = readtable(fin,'FileType','fixedwidth');
        else
            t = readtable(fin,'FileType','delimitedtext','Delimiter',delim);
        end
        t = t(:,1:length(vn));
        t.Properties.VariableNames = vn;
        t.Properties.VariableUnits = vu;

        %set up nuo to convert variables
        opt1 = 'uway_proc'; opt2 = 'uway_ascii_parse'; get_cropt

        if exist('ddays','var') && ~isempty(ddays)
            %only concerned with some ddays
            t = t(t.dday>=ddays(1) & t.dday<ddays(end)+1, :);
        end

        %keep only variables listed in mutv
        m = ismember(t.Properties.VariableNames,mutv.mstarvars{tno}) | ismember(t.Properties.VariableNames,{'dday','time'});
        t = t(:,m);
        
        %if set in opt_cruise, subsample/remove duplicate times 
        t = times_subsample(t, 'time', stepfreq_force, tstep_resol);        

        %save, possibly appending (merging on time)
        clear d h
        h.fldnam = t.Properties.VariableNames;
        h.fldunt = t.Properties.VariableUnits;
        h.comment = sprintf('loaded from file %s\n',files{fno});
        d = table2struct(t,'ToScalar',true);
        mfsave(otfile, d, h, '-merge', 'time')

        if nargout>0
            ds(fno) = d; hs(fno) = h;
        end

    end

end

opt1 = 'uway_proc'; opt2 = 'uway_load_extra'; get_cropt
if nargout>0
    varargout{1} = ds;
    if nargout>1
        varargout{2} = hs;
        if nargout>3
            if exist('uway_extra','var')
                varargout{3} = uway_extra;
            else
                varargout{3} = '';
            end
        end
    end
end
