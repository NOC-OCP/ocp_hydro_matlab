% sets parameters specific to a given underway data system (rvdas, scs, or techsas)
% called from mexec_defaults_all in case opt1 = 'uway_proc', 

if ~strcmp(opt1,'uway_proc')
    error('this file should only be called to get options for uway_proc')

elseif strcmp(MEXEC_G.datatypes.uway,'rvdas')
    switch opt2
        case 'datasys_best'
            uway_torg = 0; %mrvdas parsing returns matlab datenum, no offset required
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

elseif strcmp(MEXEC_G.uway,'scs')
   switch opt2
        case 'datasys_best'
            uway_torg = 0; % mexec parsing of SCS files converts matlab datenum, so no offset required
            uway_root = fullfile(MEXEC_G.mexec_data_root, 'scs', 'scs_raw'); % scs raw data on logger machine
            uway_sed = fullfile(MEXEC_G.mexec_data_root, 'scs', 'scs_sed'); % scs raw data on logger machine
            uway_mat = fullfile(MEXEC_G.mexec_data_root, 'scs', 'scs_mat'); % local directory for scs converted to matlab
        case 'ship_data_sys_names'
            tsgpre = 'oceanlogger';
            metpre = 'met';
    end

elseif ~strcmp(MEXEC_G.uway,'techsas')
    switch opt2
        case 'datasys_best'
            uway_torg = datenum([1899 12 30 0 0 0]); % techsas time origin as a matlab datenum
            uway_root = fullfile(MEXEC_G.mexec_data_root, 'techsas', 'netcdf_files_links');
            if ismac; uway_root = [uway_root '_mac']; end
        case 'ship_data_sys_names'
            tsgpre = 'tsg';
            metpre = 'met';
    end

else
    warning('underway data system not recognised, not able to set default options')
end