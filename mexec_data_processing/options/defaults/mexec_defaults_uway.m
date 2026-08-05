% sets parameters specific to a given underway data system (rvdas, scs, or techsas)
% called from mexec_defaults_all in case opt1 = 'uway_proc', 

if ~strcmp(opt1,'uway_proc')
    error('this file should only be called to get options for uway_proc')

elseif strcmp(MEXEC_G.datatypes.uway,'rvdas')
    switch opt2
        case 'ship_data_sys_names'
            tsgpre = 'tsg';
            metpre = 'surfmet';
        case 'rvdas_database'
            RVDAS.csvroot = fullfile(MEXEC_G.mexec_data_root, 'rvdas', 'rvdas_csv_tmp');
            %RVDAS.jsondir = '/data/pstar/mounts/links/mnt_cruise_data/Ship_Systems/Data/RVDAS/sensorfiles/';
            RVDAS.database = ['"' upper(MEXEC_G.MSCRIPT_CRUISE_STRING) '"'];
        case 'rvdas_form'
            switch MEXEC_G.Mship
                case 'sda'
                    use_cruise_views = 1; %prepend string view_name to names from json files
                    view_name = lower(MEXEC_G.MSCRIPT_CRUISE_STRING);
                    npre = 1; %table names start with an extra prefix before the instrument make/model e.g. anemometer_ft_technologies_etc
                otherwise
                    npre = 0; %table names start with instrument name
                    use_cruise_views = 0;
            end
        case 'rvdas_skip'
            %see opt_dy181
    end

elseif strcmp(MEXEC_G.datatypes.uway,'scs_ascii')
    switch opt2
        case 'ship_data_sys_names' %***used? should be ship-specific not default if so
            tsgpre = 'oceanlogger';
            metpre = 'met';
        case 'scs_skip'
            skip = {'USBL'};
        case 'scs_nmea_form'
            colsi = {}; colsf = {};
            untsi = {}; untsf = {};
            colsi = {'date','time'};
            untsi = {'mm/dd/yyyy','HH:MM:SS.SSS'};
        case 'uway_ascii_parse'
            if sum(strcmp(t.Properties.VariableNames,'datetime'))
                t.dday = datenum(t.datetime)-dd0;
            else
                md = strcmp(t.Properties.VariableNames,'date');
                mt = strcmp(t.Properties.VariableNames,'time');
                dd0 = datenum(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1),1,1);
                if strcmp(t.Properties.VariableTypes(md),'datetime') && strcmp(t.Properties.VariableTypes(mt),'duration')
                    t.dday = datenum(t.date+t.time)-dd0;
                else
                    t.dday = datenum(datetime(sprintf('%08d %08d\n',[t.date';round(t.time)'])))-dd0;
                end
            end
            t.Properties.VariableUnits{strcmp(t.Properties.VariableNames,'dday')} = sprintf('days since %d-01-01 00:00:00',MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN);
            if sum(strcmp(t.Properties.VariableNames','msg')) && strcmp(t.msg(1),'PSXN')
                t = t(t.linetype==23,:);
            end
            nuo = {{'latitudens','ns'} 'cdegrees', @(x,y) (strcmp(y,'N')*2-1)*x/100, 'latitude', 'degrees N';...
                {'longitudeew','ew'} 'cdegrees', @(x) (strcmp(y,'E')*2-1)*x/100, 'longitude', 'degrees E'};
    end

elseif ~strcmp(MEXEC_G.datatypes.uway,'techsas')
    switch opt2
        case 'techsas_form'
            uway_torg = datenum([1899 12 30 0 0 0]); % techsas time origin as a matlab datenum
        case 'ship_data_sys_names'
            tsgpre = 'tsg';
            metpre = 'met';
    end

else
    warning('underway data system not recognised, not able to set default options')
end