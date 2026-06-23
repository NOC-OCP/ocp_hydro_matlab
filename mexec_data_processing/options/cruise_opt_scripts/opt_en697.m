switch scriptname

    case 'm_setup'
        switch oopt
            case 'setup_datatypes'
                use_ix_ladcp = 'no';
        end

    case 'm_daily_proc'
        switch oopt
            case 'excludestreams'
%                 uway_excludes = {'singleb_t'};
        end

        %%%%%%%%%% mctd_01 %%%%%%%%%%
    case 'mctd_01'
        switch oopt
            case 'ctdvars'
                crhelp_str = {'Place to put additional (ctdvars_add) or replacement (ctdvars_replace)'
                    'triplets of SBE variable name, mstar variable name, mstar variable units to '
                    'supplement those in ctd_renamelist.csv. Default is both empty.'};
                ctdvars_replace = {};
                ctdvars_add = {'sal00' 'psal_sbe1' 'psu';'sal11' 'psal_sbe2' 'psu'};
        end
        %%%%%%%%%% end mctd_01 %%%%%%%%%%

    case 'mctd_02'
        switch oopt
            case 'raw_corrs'
                castopts.oxyhyst.H1 = {-0.055 -0.055};
                castopts.oxyhyst.H2 = {5000    5000};
                castopts.oxyhyst.H3 = {4000   4000};
                h3tab1 =[
                    -10 500
                    1000 500
                    1001 1500
                    2000 1500
                    2001 1500
                    3000 1500
                    3001 3000
                    9000 3000
                    ];
                h3tab2 =[
                    -10 500
                    1000 500
                    1001 1800
                    2000 1800
                    2001 1800
                    3000 1800
                    3001 3000
                    9000 3000
                    ];

                castopts.oxyhyst.H3{1} = interp1(h3tab1(:,1),h3tab1(:,2),d.press);
                iib = find(isnan(d.press)); iig = find(~isnan(d.press));
                if ~isempty(iib); castopts.oxyhyst.H3{1}(iib) = interp1(iig,castopts.oxyhyst.H3{1}(iig),iib); end
                castopts.oxyhyst.H3{2} = interp1(h3tab2(:,1),h3tab2(:,2),d.press);
                iib = find(isnan(d.press)); iig = find(~isnan(d.press));
                if ~isempty(iib); castopts.oxyhyst.H3{2}(iib) = interp1(iig,castopts.oxyhyst.H3{2}(iig),iib); end
            case 'ctd_cals'
                castopts.docal.temp = 1;
                castopts.docal.cond = 1;
                castopts.docal.oxygen = 1;

                castopts.calstr.temp1.en697 = 'dcal.temp1 = d0.temp1 + interp1([-10 0 2000 6000],0*[ 0 0 0 0]/1e4,d0.press);';
                castopts.calstr.temp2.en697 = 'dcal.temp2 = d0.temp2 + interp1([-10 0 2000 6000],1*[3 3 3 -16]/1e4,d0.press);';
                calms = 'from comparison of t1-t2, and using microcats on cal casts to decide to adjust t2; t1 is unadjusted;';
                castopts.calstr.temp1.msg = calms;
                castopts.calstr.temp2.msg = calms;

%                 shape = 1*[-10 -10  -20 7 15 10 0 0];
% 
%                 fac1(k11) = interp1([-10 0 500 1000 1500 2000 3000  8000],( 26+1*[0 0 0 0 0 0 0 0]+shape)/1e4,d.upress(k11));
%                 fac1(k12) = interp1([-10 0 500 1000 1500 2000 3000  8000],( 26+1*[0 0 0 0 0 0 0 0]+shape)/1e4,d.upress(k12));
%                 fac2(k21) = interp1([-10 0 500 1000 1500 2000 3000  8000],( 35+1*[0 5 8 -3 -5 -2 -3 2]+shape)/1e4,d.upress(k21));
%                 fac2(k22) = interp1([-10 0 500 1000 1500 2000 3000  8000],(-20+1*[0 -5 8 7 5 3 0 0]+shape)/1e4,d.upress(k22));
% 
%                 facstn1 = 0*fac1; % to get dimesnions correct
%                 facstn2 = 0*fac2;
% 
%                 facstn1(k11) = 0;
%                 facstn1(k12) = 0;
%                 facstn2(k21) = interp1([1 7 8 9 10 100],[0 0 30 45 0 0 ]/1e4,d.statnum(k21));
%                 facstn2(k22) = interp1([1 9 10 33 34 100],[0 0 5 5 0 0 ]/1e4,d.statnum(k22));
%                 fac1 = fac1+facstn1;
%                 fac2 = fac2+facstn2;

                if stnlocal <=9
                    castopts.calstr.cond1.en697 = 'dcal.cond1 = d0.cond1.*(1 + 1*(interp1([-10 0 500 1000 1500 2000 3000  8000],([-10 -10  -20 7 15 10 0 0]+26+[0 0 0 0 0 0 0 0])/1e4,d0.press)+interp1([1 999],[0 0]/1e4,d0.statnum))/35);';
                    castopts.calstr.cond2.en697 = 'dcal.cond2 = d0.cond2.*(1 + 1*(interp1([-10 0 500 1000 1500 2000 3000  8000],([-10 -10  -20 7 15 10 0 0]+35+[0 5 8 -3 -5 -2 -3 2])/1e4,d0.press)+interp1([1 7 8 9 10 999],[0 0 30 45 0 0]/1e4,d0.statnum))/35);';
                end
                if stnlocal >= 10
                    castopts.calstr.cond1.en697 = 'dcal.cond1 = d0.cond1.*(1 + 1*(interp1([-10 0 500 1000 1500 2000 3000  8000],([-10 -10  -20 7 15 10 0 0]+26+[0 0 0 0 0 0 0 0])/1e4,d0.press)+interp1([1 999],[0 0 ]/1e4,d0.statnum))/35);';
                    castopts.calstr.cond2.en697 = 'dcal.cond2 = d0.cond2.*(1 + 1*(interp1([-10 0 500 1000 1500 2000 3000  8000],([-10 -10  -20 7 15 10 0 0]-20+[0 -5 8 7 5 3 0 0])/1e4,d0.press)+interp1([1 9 10 33 34 999],[0 0 5 5 0 0]/1e4,d0.statnum))/35);';
                end

                calms = 'from comparison with bottle salinity, stations 3-37';
                castopts.calstr.cond1.msg = calms;
                castopts.calstr.cond2.msg = calms;


                castopts.calstr.oxygen1.en697 = ['dcal.oxygen1 = d0.oxygen1.*'...
                    'interp1([-10      0   500  1000  2000  3000  4000 5000   6000],1*[1.018 1.018 1.014 0.998 1.000 1.004 1.006 1.010 1.012  ],d0.press).*'...
                    'interp1([1 10 22 23 24 25  38 39 999],1*[0.99 1.00 1.00 1.015 1.015 1.014 1.014 1.026 1.026],d0.statnum);'];
                castopts.calstr.oxygen2.en697 = ['dcal.oxygen2 = d0.oxygen2.*'...
                    'interp1([-10      0  500  1000  2000  3000  4000 5000   6000],1*[1.015 1.015 1.025 1.010 1.016 1.024 1.030 1.035 1.040],d0.press).*'...
                    'interp1([1 10 22 23 33 34 38 39 999],1*[ 0.99 1.00 1.00  1.01 1.01 1.01 1.01 1.022 1.022],d0.statnum);'];
                calms = 'from comparison with bottle oxygens, stations 3-38';
                castopts.calstr.oxygen1.msg = calms;
                castopts.calstr.oxygen2.msg = calms;

        end
        %%%%%%%%%% mctd_03 %%%%%%%%%%
    case 'mctd_03'
        switch oopt
            case 's_choice'
                stns_alternate_s = [ 999 ]; % choose primary
            case 'o_choice'
                stns_alternate_o = [ 1:999 ]; % choose secondary; slightly cleaner.
        end
        %%%%%%%%%% end mctd_03 %%%%%%%%%%
    case 'best_station_depths'
        switch oopt
            case 'depth_source'
                depth_source = {'ctd'}; % checked OK for stns 35:38
            case 'bestdeps'
                %only for stations where we can't use ctd+altimeter
                replacedeps = [
                    34 3400
%                     35 4307 % altim 27 off
%                     36 4245 % altim 13 off
%                     37 4720 % altim 50 off
%                     38 4701 % altim 45 off
                    39 4700 % no alt
                    40 1700 % no alt
                    41 4137 % no alt
                    42 4722 % no alt
                    43 4155 % no alt
%                     44 1401 % altim 21 off
                    ];
% 
%                 0.0340    3.4000       NaN
%                 0.0350    4.3059    0.0010
%                 0.0360  do  4.2447    0.0010
%                 0.0370    4.7182    0.0010
%                 0.0380    4.6993    0.0010
%                 0.0390       NaN       NaN
%                 0.0400       NaN       NaN
%                 0.0410       NaN       NaN
        end

        %%%%%%%%%% mout_exch %%%%%%%%%%
    case 'mout_exch'
        switch oopt
            case 'woce_expo'
                expocode = '32EV20230205';
                sect_id = 'RAPID-West';
            case 'sam_stations_to_print'
                stations_to_print = [1:44]; % stations to print to CCHDO sample file
            case 'woce_vars_exclude'
                %                 vars_exclude_ctd = {
                %                     };
                %vars_exclude_sam = {'upsal_flag'; 'uoxygen_flag'};
            case 'woce_ctd_headstr'
%                 headstring = {['CTD,' datestr(now,'yyyymmdd') 'OCPNOCBAK'];...
%                     '#SHIP: Endeavor';...
%                     '#Cruise EN697 Legs 2 and 3; RAPID Western Boundary';...
%                     '#Region: Western North Atlantic (subtropical)';...
%                     ['#EXPOCODE: ' expocode];...
%                     '#DATES: 20230205 - 20230308';...
%                     '#Chief Scientist: W. Johns, U Miami; Co-Chief Scientist B. Moat, NOC';...
%                     '#';...
%                     '#Stations 34 to 44 out of 44 stations with 24-place rosette';...
%                     '#CTD: Who - B. King; Status - final';...
%                     '#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
%                     '# DEPTH_TYPE   : COR';...
%                     };
                headstring = {'CTD';...
                    '#SHIP: Endeavor';...
                    '#Cruise EN697';...
                    };
            case 'woce_sam_headstr'
%                 headstring = {['BOTTLE,' datestr(now,'yyyymmdd') 'OCPNOCBAK'];... %the last field specifies group, institution, initials
%                     '#SHIP: Endeavor';...
%                     '#Cruise EN697 Legs 2 and 3; RAPID Western Boundary';...
%                     '#Region: Western North Atlantic (subtropical)';...
%                     ['#EXPOCODE: ' expocode];...
%                     '#DATES: 20230205 - 20230308';...
%                     '#Chief Scientist: W. Johns, U Miami; Co-Chief Scientist B. Moat, NOC';...
%                     '#';...
%                     '#Stations 34 to 44 out of 44 stations with 24-place rosette';...
%                     '#CTD: Who - B. King; Status - final';...
%                     '#Notes: Includes CTDSAL, CTDOXY, CTDTMP';...
%                     '#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
%                     '#Salinity: Who - L. Clement, B. King and E. Hayes; Status - final';...
%                     '#Oxygen: Who - E. Hayes, L. Clement and B. King; Status - final';...
%                     };
                headstring = {'BOTTLE';... %the last field specifies group, institution, initials
                    '#SHIP: Endeavor';...
                    '#Cruise EN697';...
                    };
        end
        %%%%%%%%%% end mout_cchdo %%%%%%%%%%

    case 'mtsg_medav_clean_cal'
        switch oopt
            case 'tsg_edits'
                kbadlims = [
                    datenum([2023 01 01 00 00 00]) datenum([2023 02 06 01 00 00]) % start of cruise
                    datenum([2023 02 12 22 00 00]) datenum([2023 02 13 19 00 00]) % leg 1 midcruise
                    datenum([2023 02 18 11 00 00]) datenum([2023 02 24 17 00 00]) % leg 1 2 call
                    datenum([2023 03 01 13 30 00]) datenum([2023 01 02 19 50 00]) % leg 2 3 call 1350 1355
                    datenum([2023 03 05 13 50 00]) datenum([2023 03 05 13 55 00]) % briefly off 1350 1355
                    ];
                kbadlims = (kbadlims-datenum([2023 1 1]))*86400; % needed to make mtsg_medav_clean_cal work
                fn = setdiff(h.fldnam,{'time' 'deltat'});
                for no = 1:length(fn)
                    tsgedits.badtimes.(fn{no}) = kbadlims;
                end
            case 'tsgcals'
                tsgopts.docal.salinity = 1;
                load(fullfile(root_dir,'sdiffsm'))
                kbad = find(isnan(t+sdiffsm)); t(kbad) = []; sdiffsm(kbad) = [];
                tsgopts.calstr.salinity.en697 = 'dcal.salinity_cal = d.psal + interp1([30;50.99;51;61;61.01;90],[0;0;0.108;0.108;-0.007;-0.007],d.time);';
        end

        %%%%%%%%%% mtsg_bottle_compare %%%%%%%%%%
    case 'mtsg_bottle_compare'
        switch oopt
            case 'tsg_usecal'
                usecal = 1;
            case 'tsg_timebreaks'
                tbreak = [
                    ];
            case 'tsg_sdiff'
                sc1 = 0.5; sc2 = 0.01; %thresholds to use for smoothed series
        end
        %%%%%%%%%% end mtsg_bottle_compare %%%%%%%%%%

    case 'ship'
        %parameters used by multiple scripts, related to ship underway data
        switch oopt
            case 'ship_data_sys_names'
                crhelp_str = {'Datasystem- (and possibly ship-) specific list of mexec directory names '
                    'for tsg file (tsgpre) and surfmet file (metpre).'};
                switch MEXEC_G.Mshipdatasystem
                    case 'scs'
                        tsgpre = 'sbe45';
                        metpre = 'met';
                end
        end

    case 'mfir_01'
        switch oopt
%             case 'nispos'
%                 niskc = [1:2:23]';
%                 niskn = [9002 8149 9006:2:9024]'; %25000NNNN
            case 'botflags'
                switch stnlocal
                    case 41
                        niskin_flag(position==13) = 4; %bottom end cap leaking badly; O ring reseated afterwards
                    otherwise
                end
        end



end
