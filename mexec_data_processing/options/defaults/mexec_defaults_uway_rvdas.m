switch opt2
    case 'ship_data_sys_names'
        tsgpre = 'tsg';
        metpre = 'surfmet';
    case 'rvdas_database'
        RVDAS.csvroot = fullfile(MEXEC_G.mexec_data_root, 'rvdas', 'rvdas_csv_tmp');
        %RVDAS.jsondir = '/data/pstar/mounts/links/mnt_cruise_data/Ship_Systems/Data/RVDAS/sensorfiles/';
        RVDAS.database = ['"' upper(MEXEC_G.mcruise) '"'];
    case 'rvdas_form'
        switch MEXEC_G.Mship
            case 'sda'
                use_cruise_views = 1; %prepend string view_name to names from json files
                view_name = lower(MEXEC_G.mcruise);
                npre = 1; %table names start with an extra prefix before the instrument make/model e.g. anemometer_ft_technologies_etc
            otherwise
                npre = 0; %table names start with instrument name
                use_cruise_views = 0;
        end
    case 'rvdas_skip'
        %see opt_dy181
end
