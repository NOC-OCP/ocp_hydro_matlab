 switch scriptname 
     
         %%%%%%%%%% castpars (not a script) %%%%%%%%%%
    case 'castpars'
        switch oopt
            case 'shortcasts'
                shortcasts = [1 2 6 7 11 14]; 
            case 'oxy_align'
                oxy_end = 1;
        end
        %%%%%%%%%% end castpars (not a script) %%%%%%%%%%
        

             %%%%%%%%%% mbot_01 %%%%%%%%%%
    case 'mbot_01'
        switch oopt
            case 'nispos'
                bottle_number = [9002 9003 8149 9005 9006 9007 9008 ...
                    9009 9010 8156 9012 9013 9014 9015 9016 9017 ...
                    9018 9019 9020 9021 9022 9023 9024 9025]; %25000NNNN
            case 'botflags'
                bottle_qc_flag(ismember(statnum,[3 4 7 9]) & position==3) = 4; %bottom endcap not closed
                bottle_qc_flag(10,10) = 4; %did not seal
        end
        %%%%%%%%%% end mbot_01 %%%%%%%%%%

         %%%%%%%%%% msbe35_01 %%%%%%%%%%
     case 'msbe35_01'
         switch oopt
             case 'sbe_datetime_adj'
                 iibt = find(statnum<=10); %time was right but date was wrong for first 10 CTDs
                 datnum(iibt) = datnum(iibt)+11;
         end
         %%%%%%%%%% end msbe35_01 %%%%%%%%%%
         
         %%%%%%%%%% moxy_01 %%%%%%%%%%
     case 'moxy_01'
         switch oopt
             case 'oxycsv'
                 infile = [root_oxy '/oxygen_calculation_' mcruise '_' stn_string '.csv'];
         end
         %%%%%%%%%% end moxy_01 %%%%%%%%%%

         %%%%%%%%%% moxy_ccalc %%%%%%%%%%
    case 'moxy_ccalc'
        switch oopt
            case 'oxypars'
                vol_reag1 = 1; % MnCl2 vol (mL) (default)
                vol_reag2 = 0.99; % NaOH/NaI vol (mL) (default)
            case 'blstd' %no defaults, blank and standard titre volumes are cruise-specific
                vol_std = 5;           % volume (mL) standard KIO3
                %vol_blank = mean([0.01955 0.01394 0.01481]);
                %vol_titre_std = mean([0.4639 0.4619 0.4620]);
                vol_blank = ds_oxy.vol_blank;
                vol_titre_std = ds_oxy.vol_titre_std;
            case 'compcalc'
                compcalc = 0; %if there are pre-calculated concentrations and concentrations calculated by moxy_ccalc, pause to compare them
        end
        %%%%%%%%%% end moxy_ccalc %%%%%%%%%%
        
        
         %%%%%%%%%% mday_01_clean_av %%%%%%%%%%
     case 'mday_01_clean_av'
         switch oopt
             case 'pre_edit_uway'
                 %on day 37-38 there was a 3-hour rvdas outage; patching
                 %major streams with techsas data
                 if day==37
                     tfill = 1;
                 elseif day==38
                     tfill = 2;
                 end
                 if ismember(day,[37 38])
                     get_techsas_for_rvdas_gap
                 end
         end
         %%%%%%%%%% end mday_01_clean_av %%%%%%%%%%
         
         %%%%%%%%%% mday_01_fcal %%%%%%%%%%
     case 'mday_01_fcal'
         switch oopt
             case 'uway_factory_cal'
                 switch abbrev
                     case 'surfmet'
                         sensors_to_cal={'fluo';'trans';'parport';'tirport';'parstarboard';'tirstarboard'};
                         sensorcals={
                             'y=(x1-0.078)*13.5'; % fluorometer: s/n WS3S-134 cal 14 Jul 2020
                             'y=(x1-0.058)/(4.625-0.058)*100' %transmissometer: s/n CST-1132PR cal 24 Jun 2019
                             'y=x1/1.015' % port PAR: s/n 28556 cal 3 Sep 2019
                            'y=x1/1.073' % port TIR: 047463 cal 6 Jun 2019
                            'y=x1/0.9860' % stb PAR: s/n 28558 cal 3 Sep 2019
                            'y=x1/1.158'}; % stb TIR: 047362 cal 6 Jun 2019
                        % the surfmet instrument box is outputting in V*1e-5 for PAR/TIR already
                        sensorunits={'ug/l';'percent';'W/m2';'W/m2';'W/m2';'W/m2'};
                end
         end
         %%%%%%%%%% end mday_01_clean_av %%%%%%%%%%
         
         %%%%%%%%%% bathy (not a script) %%%%%%%%%%
     case 'bathy'
         switch oopt
             case 'bathy_grid'
                 bfile = '/local/users/pstar/jc211/mcruise/data/bathy/gebco2014_jc211.mat';
                 load(bfile); disp(bfile)
                 clear top
                 top.lon = gebco_jc211.lon;
                 top.lat = gebco_jc211.lat;
                 top.depth = gebco_jc211.depth;
         end
         %%%%%%%%%% end bathy (not a script) %%%%%%%%%%
         
         
                        
        %%%%%%%%%% populate_station_depths %%%%%%%%%%
    case 'populate_station_depths'
        switch oopt
            case 'depth_source'
                depth_source = {'ladcp' 'ctd' 'bathy'}; %load from two-column text file, then fill with ctd press+altimeter, then with ea600
            case 'bestdeps'
%                 replacedeps = [17 NaN];
            case 'depth_recalc'
                recalcdepth_stns = 1:999;
        end
        %%%%%%%%%% end populate_station_depths %%%%%%%%%%
        
        %%%%%%%%%% station_summary %%%%%%%%%%
     case 'station_summary'
         switch oopt
             case 'sum_sams'
                 snames = {'nsal'; 'noxy'; 'nnuts'; 'no18s'; 'nnisos'; 'npoms'; 'nchls'};
                 snames_shore = {'nsal_shore'; 'noxy_shore'; 'nnuts_shore'; 'no18s_shore'; 'nnisos_shore'; 'npoms_shore'; 'nchls_shore'};
                 sgrps = {{'sal'} % salt
                     {'botoxy'} % oxygen
                     {'silc','phos','totnit','nh4'} % BAS nutrients
                     {'del18o'} % BGS del O 18
                     {'del30si'} % BAS silicate isotopes
                     {'pom'} % BAS POM
                     {'chlora'}}; % BAS chlorophyll
                 sashore = [0; 0; 1; 1; 1; 1; 1];
         end
         %%%%%%%%%% end station_summary %%%%%%%%%%
         
         %%%%%%%%%% batchactions (not a script) %%%%%%%%%%
     case 'batchactions'
         switch oopt
             case 'syncc'
                 rd = '/local/users/pstar/public/data/mstar_proc_data';
                 ctdd = mgetdir('M_CTD');
                 unix(['rsync -au ' ctdd '/ ' rd '/ctd/']);
                 unix(['rsync -au ' MEXEC_G.MEXEC_DATA_ROOT '/collected_files/ ' rd '/collected_files/']);
             case 'syncu'
                 rd = '/local/users/pstar/public/data/mstar_proc_data';
                 unix(['rsync -au ' MEXEC_G.MEXEC_DATA_ROOT '/bathy/ ' rd '/bathy/']);
                unix(['rsync -au ' MEXEC_G.MEXEC_DATA_ROOT '/nav/ ' rd '/nav/']);
                unix(['rsync -au ' MEXEC_G.MEXEC_DATA_ROOT '/met/ ' rd '/met/']);
                unix(['rsync -au ' MEXEC_G.MEXEC_DATA_ROOT '/uother/ ' rd '/uother/']);
                %unix(['rsync -au ' MEXEC_G.MEXEC_DATA_ROOT '/vmadcp/ ' rd '/vmadcp/']); %***which files are mstar files or changed from default? 
        end
    %%%%%%%%%% batchactions (not a script) %%%%%%%%%%    
    
            %%%%%%%%%% set_cast_params_cfgstr %%%%%%%%%%
    case 'set_cast_params_cfgstr'
        switch oopt
            case 'ladcpopts' %***check, but should be same as dy113
                p.ambiguity = 3.3;
                p.vlim = 3.3;
                p.down_sn = 24466;
                p.up_sn = 24465;
        end
        %%%%%%%%%% end set_cast_params_cfgstr %%%%%%%%%%

    


end