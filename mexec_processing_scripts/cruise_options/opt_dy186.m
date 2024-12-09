switch opt1

    %%%%%%%%%%%%%%%%%%%%%% setup and config %%%%%%%%%%%%%%%%%%%%%%%%
    case 'setup'
        switch opt2
            case 'time_origin'
                MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [2024 1 1 0 0 0 ];
            case 'setup_datatypes'
                use_ix_ladcp = 'no';
        end

    case 'ship'
        switch opt2
            case 'datasys_best'
                default_navstream = 'posmv_gpgga';
                default_hedstream = 'posmv_pashr';
                default_attstream = 'posmv_pashr';
            case 'rvdas_database'
                RVDAS.jsondir = '/data/pstar/mounts/mnt_cruise_data/Ship_Systems/Data/RVDAS/Sensorfiles/'; %original
                RVDAS.database = ['"' upper(MEXEC_G.MSCRIPT_CRUISE_STRING) '"'];
                RVDAS.loginfile = '/data/pstar/plocal/rvdas_addr';
            case 'rvdas_skip'
                %skips.sentence = [skips.sentence, 'surfmet_gpxsm', 'ranger2usbl_psonlld'];
        end


        %%%%%%%%%%%%%%%%%%%%%%%% basic processing %%%%%%%%%%%%%%%%%%%%%%
            case 'uway_proc'
        switch opt2
            case 'sensor_unit_conversions'
                %check opt_dy181 for examples
            case 'rawedit'
                %check opt_dy181 for examples
            case 'tsg_avedits' 
                check_tsg = 1;
            case 'tsg_cals'
                clear uo
                uo.docal.salinity = 0;
                %uo.calstr.salinity.pl.dy186 = '';
                %uo.calstr.salinity.pl.msg = '';
            case 'avedit'
                %check opt_dy181 for examples
        end

    case 'ctd_proc'
        switch opt2
            case 'redoctm'
                redoctm = 1;
            case 'cnvfilename'
                %***
        end

    case 'nisk_proc'
        switch opt2
            case 'niskins'
            case 'blfilename'
            case 'botflags'
        end

        %%%%%%%%%%%%%%%%% bottle samples %%%%%%%%%%%%%%%%%%%%%%%
    case 'botpsal'
        switch opt2
            case 'sal_files'
                %salfiles = dir(fullfile(root_sal, ['autosal_' mcruise '_*.csv'])); 
            case 'sal_parse'
                %check opt_dy181 for examples
            case 'sal_calc'
                %check opt_dy181 for examples
        end

    case 'botoxy'
                %check opt_dy181 for examples
        switch opt2
            case 'oxy_files'
            case 'oxy_parse'
            case 'oxy_calc'
            case 'oxy_flags'
        end

    case 'sbe35'
        switch opt2
            case 'sbe35file'
                %sbe35file = sprintf('%s_*.asc', upper(mcruise));
                %stnind = [7:9]; % index in file name of where the station number can be found. File name eg = DY174_001.asc, so index is 7:9
        end

    case 'check_sams'
        check_oxy = 1; %step through mismatched oxygen replicates
        check_sal = 1; %step through each station's conductivity ratio readings


        %%%%%%%%%%%%%%%%%%%%%% outputs and summaries %%%%%%%%%%%%%%%%%%%%%%
            case 'outputs'
        switch opt2
            case 'summary'
                snames = {'nsal' 'noxy'};
                sgrps = {{'botpsal'} {'botoxy'}};
            case 'exch'
                n12 = 12; 
                expocode = '74EQ20241211';
                sect_id = 'RAPID-West';
                submitter = 'OCPNOCTP'; %group institution person
                common_headstr = {'#SHIP: RRS Discovery';...
                    '#Cruise DY186; RAPID moorings';...
                    '#Region: Western North Atlantic (subtropical)';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20241211 - 20241219';...
                    '#Chief Scientist: B. Moat (NOC) and T. Petit (NOC)';...
                    '#Supported by RAPID-Evolution (grant NE/Y003551/1) from the UK Natural Environment Research Council.'};
                if strcmp(in.type,'ctd')
                    headstring = {['CTD,' datestr(now,'yyyymmdd') submitter]};
                    headstring = [headstring; common_headstr;
                        {sprintf('#%d stations with 24-place rosette with 12 bottles',n12);...
                        '#CTD: Who - T. Petit (NOC); Status - preliminary.';...
                        %'#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                        '# DEPTH_TYPE   : COR';...
                        '# DEPTH_TYPE   : rosette depth from CTDPRS + CTD altimeter range to bottom, or speed of sound-corrected ship-mounted bathymetric echosounder'...
                        }];
                else
                    headstring = {['BOTTLE,' datestr(now,'yyyymmdd') submitter]};
                    headstring = [headstring; common_headstr;
                        {sprintf('#%d stations with 24-place rosette with 12 bottles',n12);...
                        '#CTD: Who - T. Petit (NOC); Status - preliminary';...
                        '#Notes: Includes CTDSAL, CTDOXY, CTDTMP';...
                        %'#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                        '# DEPTH_TYPE   : rosette depth from CTDPRS + CTD altimeter range to bottom';...
                        '#Salinity: Who - T. Petit (NOC); Status - preliminary; SSW batch P***.';...
                        '#Oxygen: Who - ; Status - preliminary.';...
                        }];
                end
        end

end

