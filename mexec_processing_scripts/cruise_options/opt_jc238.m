switch scriptname
    
    case 'castpars'
        switch oopt
            case 'nnisk'
                nnisk = 12;
            case 'oxy_align'
                if ismember(stnlocal,[2 3 5:8 11:13 17:18 25:26 33 37 40 41]) %add stations where CTD was not turned off before pumps switched off here
                    oxy_end = 1;
                end
            case 'shortcasts'
                shortcasts = 42 ;
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
                   castopts.badscans.transmittance = [0 inf]; %instrument went bad pretty much the whole cast
                elseif stnlocal==19
                    castopts.despike.cond1 = [0.2 0.1];
                    castopts.despike.cond2 = [0.2 0.1];
                elseif stnlocal==38
                    %caught a fish
                    castopts.badscans.temp1 = [135900 inf];
                    castopts.badscans.cond1 = [135900 inf];
                    castopts.badscans.oxygen_sbe1 = [135900 inf];
                end
            case 'ctd_cals'              
                %calibration strings below for testing; not final; do not
                %apply to ctd files
                castopts.docal.temp = 0;
                castopts.docal.cond = 0;
                castopts.docal.oxygen = 0;

                castopts.calstr.temp1.jc238 = 'dcal.temp1 = d0.temp1 + interp1([-10 3100],[2 -1]*1e-3,d0.press);';
                castopts.calstr.temp2.jc238 = 'dcal.temp2 = d0.temp2 + 1e-3;';
%                calms = 'from comparison with SBE35, stations 1-33 (all)';
%                castopts.calstr.temp1.msg = calms;
%                castopts.calstr.temp2.msg = calms;

                %castopts.calstr.cond1.jc238 = 'dcal.cond1 = d0.cond1;';
                castopts.calstr.cond2.jc238 = 'dcal.cond2 = d0.cond2.*(1 + interp1([-10 3100],[-2.2e-3 1.7e-3],d0.press)/35);';
%                calms = 'from comparison with bottle salinity, stations 1-25 (all)';
%                castopts.calstr.cond1.msg = calms;
%                castopts.calstr.cond2.msg = calms;
                
                 castopts.calstr.oxygen1.jc238 = 'dcal.oxygen1 = d0.oxygen1.*interp1([-10 3100],[1.03 1.04],d0.press)+interp1([-10 3100],[2 1],d0.press);';
                 castopts.calstr.oxygen2.jc238 = 'dcal.oxygen2 = d0.oxygen2.*interp1([-10 3100],[1.01 1.04],d0.press)+1.8;';
%                 calms = 'from comparison with bottle oxygens, stations 1-29 (all)';
%                 castopts.calstr.oxygen1.msg = calms;
%                 castopts.calstr.oxygen2.msg = calms;

        end

    case 'mctd_03'
        switch oopt
            case 's_choice'
                s_choice = 2;
            case 'o_choice'
                o_choice = 2;
        end

    case 'mfir_01'
        switch oopt
            case 'blinfile'
                blinfile = fullfile(root_botraw,sprintf('%s_CTD_%03d.bl', upper(mcruise), stnlocal));
            case 'nispos'
                niskc = [1:2:23]';
                niskn = [6914:2:6936]'; %26000NNNN
                if stnlocal>41
                    niskn(1) = [6915]; %bottle 1 leaked, switched out
                end
            case 'botflags'
                %Niskin flags: 2 = good, 3 leaking, 4 misfire [wire did not
                %release], 7 unknown problem [for further investigation], 9 not sampled
                switch stnlocal
                    case 1
                        niskin_flag(position==1) = 3; %questionable tap and oxy looks bad so suspect leak
                    case 4
                        niskin_flag(position==9) = 4; %most likely misfire based on sample and botoxytemp (looks like it closed around 600)
                    case 17
                        niskin_flag(position==9) = 4; %misfire
                    case 23
                        niskin_flag(position==9) = 4; %misfire         
                    case 28
                        niskin_flag(position==12) = 9; %bottle fired but not attached 
                    case 30
                        niskin_flag(position==3) = 7; %possible leak but we might have opened the tap first
                    case 41
                        niskin_flag(position==1) = 3; %definite leak
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
            case 'woce_vars_exclude'
                %use this space to calculate sigma0 (for sam file only)
                if isfield(d,'upsal')
                    d.upden = sw_pden(d.upsal,d.utemp,d.upress,0);
                end
                %if isfield(d,'botpsal')
                %    d.pden = sw_pden(d.botpsal,d.utemp,d.upress,0);
                %end
        end

                %%%%%%%%%% mday_01_fcal %%%%%%%%%%
    case 'mday_01_fcal'
        switch oopt
            case 'uway_factory_cal'
                switch abbrev
                    case 'surfmet'
%                         sensors_to_cal={'fluo';'trans';'parport';'tirport';'parstarboard';'tirstarboard'};
                         sensors_to_cal={'parport';'tirport';'parstarboard';'tirstarboard'};
                         sensorcals={
%                             'y=(x1-0.078)*13.5'; % fluorometer: s/n WS3S-134 cal 14 Jul 2020
%                             'y=(x1-0.058)/(4.625-0.058)*100' %transmissometer: s/n CST-1132PR cal 24 Jun 2019
                             'y=x1/1.059' % port PAR: s/n 28559 cal 23 Mar 2021
                             'y=x1/1.134' % port TIR: 994132 cal 6 Apr 2021
                             'y=x1/1.016' % stb PAR: s/n 28560 cal 23 Mar 2021
                             'y=x1/1.065'}; % stb TIR: 047463 cal 18 Aug 2021
%                         % the surfmet instrument box is outputting in V*1e-5 for PAR/TIR already
%                         sensorunits={'ug/l';'percent';'W/m2';'W/m2';'W/m2';'W/m2'};
                         sensorunits={'W/m2';'W/m2';'W/m2';'W/m2'};
                end
        end
        %%%%%%%%%% end mday_01_fcal %%%%%%%%%%

    case 'msal_01'
        switch oopt
            case 'sal_files'
                salfiles = dir(fullfile(root_sal, ['JC238*.csv']));
                salfiles = {salfiles.name};
            case 'sal_parse'
                cellT = 24;
                ssw_batch = 'P165';
                ssw_k15 = 0.99986;
            case 'sal_calc'
                sal_off = [
                    1 1
                    2 3
                    3 3 %3 is a repeat from same bottle as 2; using value from 2
                    4 2
                    5 0
                    6 2
                    7 2 %7 is a repeat from same bottle as 6; using value from 6
                    8 2
                    9 -1
                    10 2
                    11 2 %11 is a repeat from same bottle as 10; using value from 10
                    12 2
                    13 -3
                    14 1
                    15 3
                    16 0
                    17 2
                    18 1
                    19 0
                    20 1
                    21 1
                    22 -1
                    23 -2
                    24 3];
                sal_off(:,1) = sal_off(:,1)+999000;
                sal_off(:,2) = sal_off(:,2)*1e-5;
                sal_adj_comment = ['Bottle salinities adjusted using SSW batch P165'];
            case 'sal_flags'
        end

    case 'moxy_01'
        switch oopt
            case 'oxy_files'
                ofiles = {'Winkler_Calculation_Spreadsheet_JC238_2022.xlsx'};
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
            case 'oxy_flags'
                % a few more outliers (others flagged in input .xlsx file)
                d.botoxya_flag(ismember(d.sampnum,[1223 2301 2303 2815 2819 2901 3219])) = 4;
                % these stations are low compared to CTDs, throughout the
                % water column. not sure why (they weren't all analysed in
                % a row or with the same standard/blank different from
                % others), but it doesn't appear to be a function of
                % watermass 
                d.botoxya_flag(ismember(d.statnum,[7 9:13])) = 3; 
        end

        %%%%%%%%%% mfir_03 %%%%%%%%%%
    case 'mfir_03'
        switch oopt
            case 'fir_fill'
                firmethod = 'medint';
                firopts.int = [-1 120]; %average over 5 s to match .ros file used in BASproc
                firopts.prefill = 48;
        end
        %%%%%%%%%% end mfir_03 %%%%%%%%%%
        
                
        %%%%%%%%%% mctd_checkplots %%%%%%%%%%
    case 'mctd_checkplots'
        switch oopt
            case 'plot_saltype'
                saltype = 'asal';
        end
        %%%%%%%%%% end mctd_checkplots %%%%%%%%%%
                
        
        %%%%%%%%%% populate_station_depths %%%%%%%%%%
    case 'populate_station_depths'
        switch oopt
            case 'depth_source'
                depth_source = {'ladcp' 'ctd'};
        end
        %%%%%%%%%% end populate_station_depths %%%%%%%%%%
        
        %%%%%%%%%% msec_grid %%%%%%%%%%
    case 'msec_grid'
        switch oopt
            case 'sections_to_grid'
	    sections = {'osnape' 'ungridded'};
            case 'sec_stns_grids'
                      zpressgrid = [0 5 25 50 75 100 175 250 375 500 625 750 875 1000 1250 1500 1750 2000 2250 2500 2750 3000]';  
                switch section
                    case 'osnape'
                      kstns = [5:8 4 10:25 27 26 28:32 35:39 43 40 41];
                    case 'all'
                      kstns = [1:41 43];
                end
            case 'ctd_regridlist'
                ctd_regridlist = [ctd_regridlist 'fluor' 'ph'];
        end

    case 'msam_ashore_flag'
        switch oopt
            case 'sam_ashore_nut'
                fnin = fullfile(mgetdir('M_BOT_ISO'),'Nutrient_Tube_Numbers.xlsx');
                st = readtable(fnin);
                st = fill_samdata_statnum(st,'CTDCastNo_');
                clear dnew
                dnew.sampnum = st.CTDCastNo_*100+st.NiskinBottleNo_;
                dnew.flag = 9+zeros(size(dnew.sampnum));
                dnew.flag(st.No_OfNutrientSamples>0) = 1;
                vars = {'silc','totnit','phos'};
                do_empty_vars = 1;
            case 'sam_ashore_co2'
                fnin = fullfile(mgetdir('M_BOT_ISO'),'Carbon_Bottle_Names.xlsx');
                st = readtable(fnin);
                st = fill_samdata_statnum(st,'CTDCastNo_');
                clear dnew
                dnew.sampnum = st.CTDCastNo_*100+st.NiskinBottleNo_;
                dnew.flag = 9+zeros(size(dnew.sampnum));
                dnew.flag(st.CarbonSamplesNo_>0) = 1;
                vars = {'dic' 'alk'};
                do_empty_vars = 1;
        end

    case 'ix_cast_params'
        switch oopt
            case 'ladcpopts'
                if isfield(cfg,'pdir_root') && ~strcmp(cfg.pdir_root,'processed')
%                 if stnlocal==43
%                     p.vlim = 3.3; %for example
%                 elseif ismember(stnlocal,[1 3])
%                     p.btrk_mode = 0; %for example
%                 end



%OUTLIER detection is called twice once to clean the raw data
%	and a second time to clean the super ensembles
%        [n1 n2 n3 ...] the length gives the number of scans and
%	each value the maximum allowed departure from the mean in std
%	applied for the u,v,w fields for each bin over blocks 
%   of p.outlier_n profiles
% p=setdefv(p,'outlier',[4.0  3.0]);
% default for p.outlier_n is number of profiles in 5 minutes
% p=setdefv(p,'outlier_n',100);
% minimum std for horizontal velocities of super ensemble
% p=setdefv(p,'superens_std_min',0.01);


%SPIKES
% 	maximum value for abs(V-error) velocity
p.elim = 0.3;
% 	maximum value for horizontal velocity 
% p=setdefv(p,'vlim',2.5);
% 	minimum value for %-good
 p.pglim = 50;
%	maximum value for W difference between the mean W and actual
%        W(z) for each profile. 
 p.wlim = 0.10;
p.edit_spike_filter=0;
p.edit_spike_filter_max_curv=2;

                end
        end
end
