% sets parameters specific to a given underway data system (ydayrvdas, scs, or techsas)
% called from mexec_defaults_all in case opt1 = 'uway_proc', 

if strcmp(opt1,'ship')
    error('this file should only be called to get options for ship underway data')
end

%parameters related to ship: underway data system, vmadcp system
switch MEXEC_G.MSCRIPT_CRUISE_STRING(1:2)
    case {'di' 'dy'}
        MEXEC_G.PLATFORM_IDENTIFIER = 'RRS Discovery';
        MEXEC_G.Mshipdatasystem = 'rvdas';
        MEXEC_G.datatype.sadcp = 'uhdas';
        % MEXEC_G.Mshipdatasystem = 'techsas';
    case 'jc'
        MEXEC_G.PLATFORM_IDENTIFIER = 'RRS James Cook';
        MEXEC_G.Mshipdatasystem = 'rvdas';
        MEXEC_G.datatype.sadcp = 'uhdas';
        %MEXEC_G.Mshipdatasystem = 'techsas';
    case 'sd'
        MEXEC_G.PLATFORM_IDENTIFIER = 'RRS Sir David Attenborough';
        MEXEC_G.Mshipdatasystem = 'rvdas';
        MEXEC_G.datatype.sadcp = 'uhdas';
    case 'jr'
        MEXEC_G.PLATFORM_IDENTIFIER = 'RRS James Clark Ross';
        MEXEC_G.Mshipdatasystem = 'scs_ascii';
    case 'kn'
        MEXEC_G.PLATFORM_IDENTIFIER = 'RV Knorr';
        MEXEC_G.Mshipdatasystem = 'scs'; %***update to scs_nc?
        MEXEC_G.datatype.sadcp = 'uhdas';
    case 'en'
        MEXEC_G.PLATFORM_IDENTIFIER = 'RV Endeavor';
        MEXEC_G.Mshipdatasystem = 'scs_nc';
        MEXEC_G.datatype.sadcp = 'uhdas';
    case 'ce'
        MEXEC_G.PLATFORM_IDENTIFIER = 'RV Celtic Explorer';
        MEXEC_G.Mshipdatasystem = 'scs_ascii';
        MEXEC_G.datatype.sadcp = 'uhdas';
    otherwise
        merr = ['Ship ''' MEXEC_G.MSCRIPT_CRUISE_STRING(1:2) ''' not recognised, underway system will not be set up'];
        %fprintf(2,'%s\n',merr);
        %return
        warning(merr)
        MEXEC_G.Mship = '';
        MEXEC_G.PLATFORM_IDENTIFIER = '';
end

if strcmp(MEXEC_G.datatypes.uway,'rvdas')
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