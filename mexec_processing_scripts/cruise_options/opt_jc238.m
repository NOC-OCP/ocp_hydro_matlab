switch scriptname
    
    case 'castpars'
        switch oopt
            case 'nnisk'
                nnisk = 12;
            case 'oxy_align'
                if ismember(stnlocal,[2 3 5:8 12:13 17:19]) %add stations finished by dougal here
                    oxy_end = 1;
                end
        end

    case 'batchactions'
        switch oopt
            case 'output_for_others'
                syncfrom = '/local/users/pstar/jc238/mcruise/data/collected_files/';
                syncto = '/local/users/pstar/mounts/public/JC238/ctd_sam_uway_collected_files/';
                system(['rsync -au ' syncfrom ' ' syncto]);
        end

    case 'mctd_01'
        switch oopt
            case 'cnvfilename'
                if redoctm
                    cnvfile = sprintf('%s_CTD_%03d.cnv', upper(mcruise), stnlocal);
                else
                    cnvfile = sprintf('%s_CTD_%03d_align_ctm.cnv', upper(mcruise), stnlocal);
                end
            case 'ctdvars'
                ctdvars_add = {'ph','ph','number'};
        end

    case 'mctd_02'
        switch oopt
            case 'rawedit_auto'
                if stnlocal==3
                   castopts.badscans.transmittance = [0 inf]; %instrument went bad pretty much the cast
                end
        end

    case 'mfir_01'
        switch oopt
            case 'blinfile'
                blinfile = fullfile(root_botraw,sprintf('%s_CTD_%03d.bl', upper(mcruise), stnlocal));
            case 'nispos'
                niskc = [1:2:23]';
                %niskn = [9002 8149 9006:2:9024]'; %25000NNNN
            case 'botflags'
                %Niskin flags: 2 = good, 3 leaking, 4 misfire [wire did not
                %release], 7 unknown problem [for further investigation], 9 not sampled
                switch stnlocal
                    case 1
                        niskin_flag(position==1) = 7; %questionable tap
                    case 17
                        niskin_flag(position==9) = 4; %misfire
                    otherwise
                end
        end

    case 'best_station_depths'
        switch oopt
            case 'bestdeps'
                % only for stations where we can't use ctd+altimeter
                % replacedeps = [cast_number depth]
                %replacedeps = [
                %   1 1088];
        end

    case 'mout_exch'
        switch oopt
            case 'woce_expo'
                expocode = '740H20220712';
                sect_id = 'Ellet Line -- OSNAP-East';
                submitter = 'OCPNOCYLF'; %group institution person
            case 'woce_ctd_headstr'
                headstring = {['CTD,' datestr(now,'yyyymmdd') submitter];...
                    '#SHIP: RRS James Cook';...
                    '#Cruise JC238; OSNAP East (Rockall Trough to Iceland Basin)';...
                    '#Region: Eastern subpolar North Atlantic';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20220712 - 20220801';...
                    '#Chief Scientist: B. Moat, NOC';...
                    '#Supported by grants from the UK Natural Environment Research Council for the OSNAP program (grant no. ***).';...
                    '#*** stations with 12-place rosette';...
                    '#CTD: Who - Y. Firing; Status - uncalibrated';...
%                    '#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                    '# DEPTH_TYPE   : COR';...
                    };
            case 'woce_sam_headstr'
                headstring = {['BOTTLE,' datestr(now,'yyyymmdd') submitter];... 
                    '#SHIP: RRS James Cook';...
                    '#Cruise JC238; OSNAP East (Rockall Trough to Iceland Basin)';...
                    '#Region: Eastern subpolar North Atlantic';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20220712 - 20220801';...
                    '#Chief Scientist: B. Moat, NOC';...
                    '#Supported by grants from the UK Natural Environment Research Council for the OSNAP program (grant no. ***).';...
                    '#*** stations with 12-place rosette';...
                    '#CTD: Who - Y. Firing; Status - uncalibrated';...
                    '#Notes: Includes CTDSAL, CTDOXY, CTDTMP';...
%                    '#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                    '#Salinity: Who - Y. Firing; Status - not yet analysed';...
                    '#Oxygen: Who - S. Beith; Status - not yet analysed';...
                    '#Nutrients: Who - ***; Status - not yet analysed';...
                    '#Carbon: Who - ***; Status - not yet analysed';...
                    };
        end

                %%%%%%%%%% mday_01_fcal %%%%%%%%%%
    case 'mday_01_fcal'
        switch oopt
            case 'uway_factory_cal'
                switch abbrev
                    case 'surfmet'
%                         sensors_to_cal={'fluo';'trans';'parport';'tirport';'parstarboard';'tirstarboard'};
%                         sensorcals={
%                             'y=(x1-0.078)*13.5'; % fluorometer: s/n WS3S-134 cal 14 Jul 2020
%                             'y=(x1-0.058)/(4.625-0.058)*100' %transmissometer: s/n CST-1132PR cal 24 Jun 2019
%                             'y=x1/1.015' % port PAR: s/n 28556 cal 3 Sep 2019
%                             'y=x1/1.073' % port TIR: 047463 cal 6 Jun 2019
%                             'y=x1/0.9860' % stb PAR: s/n 28558 cal 3 Sep 2019
%                             'y=x1/1.158'}; % stb TIR: 047362 cal 6 Jun 2019
%                         % the surfmet instrument box is outputting in V*1e-5 for PAR/TIR already
%                         sensorunits={'ug/l';'percent';'W/m2';'W/m2';'W/m2';'W/m2'};
                end
        end
        %%%%%%%%%% end mday_01_fcal %%%%%%%%%%

    case 'msal_01'
        switch oopt
            case 'sal_files'
                salfiles = dir(fullfile(root_sal, ['JC238_*.csv']));
                salfiles = {salfiles.name};
            case 'sal_calc'
                cellT = 24;
        end
        
    case 'moxy_01'
        switch oopt
            case 'oxy_files'
                ofiles = {'Winkler_Calculation_Spreadsheet_2022.xlsx'};
                hcpat = {'CTD cast no.'};
                chrows = 1;
                chunits = [];
            case 'oxy_parse'
                oxyvarmap = {
                    'statnum',       'ctd_cast_no'
                    'position',      'niskin_bot_no'
                    'vol_blank',     'blank_titre_mls_calculated_under_blank_calculation_tab'
                    'vol_std',       'std_vol_mls'
                    'vol_titre_std', 'std_titre_mls'
                    'fix_temp',      'fixing_temp_c'
                    'sample_titre',  'sample_titre_mls'
                    'flag',          'flag'
                    'oxy_bottle'     'do_sample_bot_no'
                    'bot_vol_tfix'   'bot_vol_at_tfix_mls'
                    'conc_o2',       'c_o2_umol_per_l'};
            case 'oxy_calc'
                mol_std = 0.0030073;
        end

    %%%%%%%%%% mctd_03 %%%%%%%%%%
    case 'mctd_03'
        switch oopt
            case 's_choice' %this applies to both t and c
                s_choice = 2; %sensor on fin
                stns_alternate_s = 20; %salp in CTD2
            case 'o_choice'
                o_choice = 2;
                stns_alternate_s = 20; %salp in CTD2
        end
        %%%%%%%%%% end mctd_03 %%%%%%%%%%
        
        %%%%%%%%%% mfir_03 %%%%%%%%%%
    case 'mfir_03'
        switch oopt
            case 'fir_fill'
                firmethod = 'medint';
                firopts.int = [-1 120]; %average over 5 s to match .ros file used in BASproc
        end
        %%%%%%%%%% end mfir_03 %%%%%%%%%%
        
                
        %%%%%%%%%% mctd_checkplots %%%%%%%%%%
    case 'mctd_checkplots'
        switch oopt
            case 'plot_saltype'
                saltype = 'asal';
        end
        %%%%%%%%%% end mctd_checkplots %%%%%%%%%%
        
        
        %%%%%%%%%% mctd_rawedit %%%%%%%%%%
    case 'mctd_rawedit'
        switch oopt
            case 'rawedit_auto'
                revars = {'press' -1.495 8000
                    'transmittance' 50 105
                    'fluor' 0 0.5
                    'turbidity' 0 0.002
                    };
                if stnlocal == 20
                    sevars = {'temp2' 23658 inf
                        'cond2' 23658 inf
                        'oxygen_sbe2' 23658 inf};
                end
                
        end
        %%%%%%%%%% end mctd_rawedit %%%%%%%%%%
        
        %%%%%%%%%% mctd_02b %%%%%%%%%%
    case 'mctd_02b'
        switch oopt
            case 'ctdcals'
                docal.temp = 1; docal.cond = 1; docal.oxygen = 1;
                    calstr.temp1.dy113 = 'dcal.temp1 = d0.temp1 - 1.5e-5*d0.statnum + interp1([0 5000],[0 -1.5]*1e-3, d0.press) - 1.1e-4;';
                    calstr.temp2.dy113 = 'dcal.temp2 = d0.temp2 - 1e-5*d0.statnum - 3.8e-4';
                    calstr.cond1.dy113 = 'dcal.cond1 = d0.cond1.*(1 + (interp1([0 5000], [-1.8 -6.5], d0.press)*1e-3 - 7.2e-4)/35);';
                    calstr.cond2.dy113 = 'dcal.cond2 = d0.cond2.*(1 + (interp1([0 5000], [1.4 -2], d0.press)*1e-3 - 7e-4)/35);';
                    calstr.oxygen1.dy113 = 'dcal.oxygen1 = 1.025*d0.oxygen1 + interp1([0 5000], [1.8 12.8], d0.press) - 1.5e-2*d0.statnum';
                    calstr.oxygen2.dy113 = 'dcal.oxygen2 = 1.029*d0.oxygen2 + interp1([0 500 5000], [0.5 0.8 9], d0.press) + 1e-2*d0.statnum;';
        end
        %%%%%%%%%% end mctd_senscal %%%%%%%%%%
        
        
        %%%%%%%%%% ix_cast_params %%%%%%%%%%
    case 'ix_cast_params'
        switch oopt
            case 'ladcpopts'
                if stnlocal>=5
                    p.ambiguity = 3.3;
                    p.vlim = 3.3;
                end
                if ismember(stnlocal,[85])
                    p.btrk_mode = 2; %calculate our own since for some reason the rdi bottom track didn't work
                end
        end
        %%%%%%%%%% end ix_cast_params %%%%%%%%%%
        
        %%%%%%%%%% populate_station_depths %%%%%%%%%%
    case 'populate_station_depths'
        switch oopt
            case 'depth_source'
                depth_source = {'ladcp' 'ctd'};
        end
        %%%%%%%%%% end populate_station_depths %%%%%%%%%%
        
        %%%%%%%%%% station_summary %%%%%%%%%%
    case 'station_summary'
        switch oopt
            case 'sum_sams'
                snames = {'noxy'; 'nnuts'; 'no18s'; 'nnisos'}; % Use s suffix for variable to count number on ship for o18 c13 chl, which will be zero
                snames_shore = {'noxy_shore'; 'nnut'; 'no18'; 'nniso'}; % can use name without _shore, because all samples are analysed ashore
                sgrps = { {'botoxy'} %list of oxy variables
                    {'silc' 'phos' 'totnit'} %list of nuts variables
                    {'del18o'} % BGS del O 18
                    {'del15n' 'del30si'}
                    };
                sashore = [0; 1; 1; 1]; %count samples to be analysed ashore? % can't presently count botoxy_flag == 1
            case 'sum_varnames'
                varnames={'statnum' 'time_start' 'time_bottom' 'time_end' 'lat' 'lon' 'cordep' 'maxd' 'ndpths' 'nsal' 'noxy' 'nnut' 'no18' 'nniso'};
                varunits={'number' 'seconds' 'seconds' 'seconds' 'degrees' 'degrees' 'metres' 'metres' 'number' 'number' 'number' 'number' 'number' 'number'};
            case 'sum_stn_list'
                stnadd = [73 74 75 77 79]; % force add of these stations to station list
            case 'sum_comments' % set comments
                comments{1} = 'Test station (SR1b_08)';
                comments{2} = 'Start of SR1b';
                comments{31} = 'End of SR1b';
                comments{32} = 'Start of A23';
                comments{43} = 'moved for iceberg';
                comments{62} = 'End of A23';
                comments{63} = 'Start of Cumberland Bay';
                comments{79} = 'End of Cumberland Bay';
                comments{80} = 'Start of NSR';
                comments{92} = 'Break after NSR_16 for FI call';
                comments{93} = 'Resume NSR near FI';
                comments{104} = 'Repeat of NSR_16';
            case 'parlist' %***
                parlist = [' sal'; ' oxy'; ' nut'; 'd18o'; 'nniso'];
        end
        %%%%%%%%%% end station_summary %%%%%%%%%%
        
                
        %%%%%%%%%% msam_ashore_flag %%%%%%%%%%
    case 'msam_ashore_flag'
        switch oopt
            case 'sam_ashore_all'
                flagnames = {'del18o_flag','silc_flag','phos_flag','totnit_flag','no2_flag','del15n_flag','del30si_flag'};
                fnin = fullfile(mgetdir('M_BOT_ISO'), 'dy113_ashore_samples_log.csv');
                ds_iso = dataset('File',fnin,'Delimiter',','); %csv file including text comments
                ds_iso.sampnum = ds_iso.cast*100+ds_iso.niskin;
                flagvals = 1;
                clear sampnums
                ii = find(~isnan(ds_iso.d18o_sample)); sampnums(1,1) = {ds_iso.sampnum(ii)};
                stations = floor(ds_iso.sampnum(ii)/100);
                ii = find(ds_iso.nuts_nsamp>0); sampnums(2,1) = {ds_iso.sampnum(ii)};
                stations = [stations; floor(ds_iso.sampnum(ii)/100)];
                sampnums(3,:) = sampnums(2,:); sampnums(4,:) = sampnums(2,:); sampnums(5,:) = sampnums(2,:);
                ii = find(ds_iso.niso_nsamp>0); sampnums(6,1) = {ds_iso.sampnum(ii)};
                stations = [stations; floor(ds_iso.sampnum(ii)/100)];
                ii = find(ds_iso.siiso_nsamp>0); sampnums(7,1) = {ds_iso.sampnum(ii)};
                stations = [stations; floor(ds_iso.sampnum(ii)/100)];
        end
        %%%%%%%%%% end msam_ashore_flag %%%%%%%%%%
        
        %%%%%%%%%% msec_run_mgridp %%%%%%%%%%
    case 'msec_run_mgridp'
        switch oopt
            case 'sections'
	    sections = {'eel'};
            case 'ctd_regridlist'
                ctd_regridlist = [ctd_regridlist ' fluor ph'];
            case 'sec_stns'
                switch section
                    case 'eel'
                        kstns = [2:13];
                end
            case 'varuse'
                varuselist.names = {'botoxy'};
        end

end
