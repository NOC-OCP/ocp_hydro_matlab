switch scriptname
    
    %%%%%%%%% cond_apply_cal %%%%%%%%%
    case 'cond_apply_cal'
        switch sensor
            case 1
                fac  = 1;
                condadj = 0;
                if ismember(stn, 1:40) %first sensor1
                    fac1 = 1 + 0.0110/35; % initial cal determined from ctd_evaluate_sensors_jr281
                    off2 = interp1([-10 0 4000 8000],[0.0005 0.0005 -0.0015 -0.0030],press); % refinement
                    fac2 = off2/35 + 1;
                    fac = fac1.*fac2;
                elseif ismember(stn, 45) %first sensor1
                    fac1 = 1 + 0.0150/35; % initial cal determined from ctd_evaluate_sensors_jr281
                    off2 = interp1([-10 0 4000 8000],[0.0005 0.0005 -0.0015 -0.0030],press); % refinement
                    fac2 = off2/35 + 1;
                    fac = fac1.*fac2;
                elseif ismember(stn, 46:999) %second sensor1
                    fac1 = 1 + 0.0000/35;
                    %off2 = interp1([-10 0 4000 8000],[0.0005 0.0005 -0.0015 -0.0030],press);
                    off2 = interp1([-10 0 4000 8000],[0.0005 0.0005 -0.0010 -0.0020],press); % revised 16 apr 1213
                    fac2 = off2/35 + 1;
                    fac = fac1.*fac2;
                end
                condout = cond.*fac;
                condout = condout+condadj;
            case 2
                fac = 1;
                condadj = 0;
                if ismember(stn, [1:16]) %first sensor2
                    fac1 = 1 + 0.0110/35; % initial cal determined from ctd_evaluate_sensors_jr281
                    off2 = interp1([-10 0 500 4000 8000],[0.0010 0.0010 -0.0003 -0.0020 -0.0040],press); % refinement
                    fac2 = off2/35 + 1;
                    fac = fac1.*fac2;
                elseif ismember(stn, 17:56); %second sensor2
                    fac1 = 1 - 0.0023/35; % initial cal determined from ctd_evaluate_sensors_jr281
                    % station dependent offset during drifting phase of this sensor
                    statoffsets = [
                        18 -0.0007
                        19 -0.0007
                        22 -0.0005
                        23 -0.0006
                        24 -0.0006
                        25 -0.0007
                        26 -0.0008
                        27 -0.0009
                        28 -0.0010
                        29 -0.0010
                        30 -0.0010
                        31 -0.0010
                        32 -0.0012
                        33 -0.0012
                        35 -0.0010
                        36 -0.0010
                        37 -0.0010
                        38 -0.0010
                        39 -0.0010
                        40 -0.0010
                        45 -0.0005
                        47 -0.0005
                        48 0.0013
                        49 0.0026
                        52 0.0026
                        53 0.0032
                        54 0.0032
                        55 0.0047
                        56 0.0051
                        ]; % revised for stations 18 to 40. 16 april 2013
                    kfind = find(statoffsets(:,1) == stn);
                    if ~isempty(kfind)
                        off = statoffsets(kfind,2);
                        facs = off/35 + 1;
                        fac1 = fac1*facs;
                    end
                    %off2 = interp1([-10 0 4000 8000],[0.0010 0.0010 -0.0010 -0.0020],press); % refinement
                    off2 = interp1([-10 0 4000 8000],[0.0010 0.0010 0.0000 0.0000],press); % revision 17 april after also revising k12
                    fac2 = off2/35 + 1;
                    fac = fac1.*fac2;
                elseif ismember(stn, 60:61) % k23
                    fac1 = 1 + 0.0000/35; % initial cal determined from ctd_evaluate_sensors_jr281
                    off2 = interp1([-10 0 1500 8000],[0.0000 0.0000 -0.0012 -0.0012],press); % from comparing c2 and c1 on station 60
                    fac2 = off2/35 + 1;
                    fac = fac1.*fac2;
                elseif ismember(stn, [64:122]); % k24 first sensor back on. initially use same cal as before
                    fac1 = 1 + 0.0110/35; % initial cal determined from ctd_evaluate_sensors_jr281
                    %off2 = interp1([-10 0 500 4000 8000],[0.0010 0.0010 -0.0003 -0.0020 -0.0040],press); % refinement
                    off2 = interp1([-10 0 4000 8000],[0.0002 0.0002 -0.0028 -0.0038],press); % revised 16 april 2013
                    fac2 = off2/35 + 1;
                    fac = fac1.*fac2;
                elseif ismember(stn, 123:999) %k25 replaced secondary temperature
                    fac1 = 1 + 0.0110/35; % initial cal determined from ctd_evaluate_sensors_jr281
                    %off2 = interp1([-10 0 500 4000 8000],[0.0010 0.0010 -0.0003 -0.0020 -0.0040],press); % refinement
                    %off2 = interp1([-10 0 4000 8000],[0.0002 0.0002 -0.0028 -0.0038],press); % revised 16 april 2013
                    off2 = interp1([-10 0 2000 4000 8000],[0.0022 0.0022 0.0007 0.0007 0.0007],press); % even though c2 hasnt been changed, the vertical shape with the new T sensor seems different
                    fac2 = off2/35 + 1;
                    fac = fac1.*fac2;
                end
                if ismember(stn, 90) %  fouling in 2 stages on upcast, clears befpore 1800 on upcast.
                    fac1 = fac; % start with existing adjustment, and modify it for ranges of offsets.
                    off2 = 0*cond;
                    kof1 = find(scan >= 70141 & scan <= 72563);
                    kof2 = find(scan >= 72564 & scan <= 84919);
                    off2(kof1) = 0.0012; % psal offsets for blocks of scan numbers;
                    off2(kof2) = 0.0020;
                    fac2 = off2/35+1;
                    fac = fac1.*fac2;
                elseif ismember(stn, 110) %  c2 fouls near bottom of downcast, clears on upcast.
                    fac1 = fac; % start with existing adjustment, and modify it for ranges of offsets.
                    off2 = 0*cond;
                    kof1 = find(scan >= 111310 & scan <= 167990);
                    salcor = 0.0106 - 0.0008*(scan-111310)/(167990-111310); % correction is 0.0103 to start, drifts by 0.001 during the offset phase
                    off2(kof1) = salcor(kof1); % apply to affected scan numbers; zero for the rest.
                    fac2 = off2/35+1;
                    fac = fac1.*fac2;
                end
                condout = cond.*fac;
                condout = condout+condadj;
            otherwise
                fprintf(2,'%s\n','Should not enter this branch of cond_apply_cal !!!!!')
        end
        %%%%%%%%% end cond_apply_cal %%%%%%%%%
        
        
        %%%%%%%%%% ctd_evaluate_sensors %%%%%%%%
    case 'ctd_evaluate_sensors'
        switch oopt
            case {'csensind','tsensind'}
                if sensnum==1
                    sensind(1,1) = {find(d.statnum >= 1 & d.statnum <= 45)};   % first psal1
                    sensind(2,1) = {find(d.statnum >=46 & d.statnum <= last_stat)};   % second psal1
                elseif sensnum==2
                    sensind(1,1) = {find(d.statnum >= 1 & d.statnum <= 16)};   % first psal2
                    sensind(2,1) = {find(d.statnum >=17 & d.statnum <= 56)};   % second psal2
                    sensind(3,1) = {find(d.statnum >=57 & d.statnum <= 61)};   % third psal2
                    sensind(4,1) = {find(d.statnum >=62 & d.statnum <= 122)};   % first psal2 back on
                    sensind(5,1) = {find(d.statnum >=123 & d.statnum <= last_stat)};   % change temp2
                end
        end
        %%%%%%%%%% end ctd_evaluate_sensors %%%%%%%%
        
        
        %%%%%%%%%% mbot_00 %%%%%%%%%%
    case 'mbot_00'
        switch oopt
            case 'nbotfile'
                botfile = fullfile(root_botcsv, [prefix1 '001.csv']); % on jr281 have a single bottle input file
            case 'nispos'
                if stnlocal>=74
                    nis(12:22) = 14:24;
                    nis(23:24) = [25 26]; % order of niskins when two are off frame for sparging
                end
        end
        %%%%%%%%% end mbot_00 %%%%%%%%%
        
        
        %%%%%%%%%% mout_cchdo_ctd %%%%%%%%%%
    case 'mout_cchdo_ctd'
        switch oopt
            case 'expo'
                expocode = 'James_Clark_Ross_20130813';
                sect_id = 'DIMES_UK4';
            case 'outfile'
                outfile = ['sr1b_' expocode'];
            case 'headstr'
                headstring = ['# The CTD PRS;  TMP;  SAL data are all calibrated and good . '];
        end
        %%%%%%%%%% end mout_cchdo_ctd %%%%%%%%%%
        
        %%%%%%%%%% mout_cchdo_sam %%%%%%%%%%
    case 'mout_cchdo_sam'
        switch oopt
            case 'expo'
                expocode = 'James_Clark_Ross_20130813';
                sect_id = 'DIMES_UK4';
            case 'outfile'
                outfile = ['dimes_uk4'];
        end
        %%%%%%%%%% end mout_cchdo_sam %%%%%%%%%%
        
        
        %%%%%%%%%% mcfc_02 %%%%%%%%%%
    case 'mcfc_02'
        switch oopt
            case 'infile1'
                infile1 = fullfile(root_cfc, [prefix1 stn_string]);
            case 'cfclist'
                cfcinlist = 'sf6 sf6_flag cfc12 cfc12_flag cfc13 cfc13_flag sf5cf3 sf5cf3_flag';
                cfcotlist = cfcinlist;
        end
        %%%%%%%%%% end mcfc_02 %%%%%%%%%%
        
        %%%%%%%%% mctd_03 %%%%%%%%%
    case 'mctd_03'
        switch oopt
            case '24hz_edit'
                if stnlocal == 97
                    % remove some fouling on cond1 and temp1 on upcast and replace with cond2 and temp2
                    scanlo = 107935; scanhi = 121400;
                    switchscans24 = {'cond' scanlo scanhi; 'temp' scanlo scanhi};
                end
            case 's_choice'
                % both sensors give data that are about 0.011 fresh at start of
                % cruise, but in very close agreement. Secondary sensor swapped
                % for station 17. Replacement is close to bottles.
                % Use primary for 1 to 16. This will be adjusted to agree with
                % replacement secondary durign overlap period stations 17 and
                % after. Use new secondary for station 17 and after.
                % station 45, first primary had further fresh offset after freezing
                % first primary changed after station 45, and new primary for
                % stations 47 and onwards.
                % secondary drifting to fresher values for staitions 48 and
                % following
                % primary fouled on downcast station 61
                % stations 64, 66 and following, the original secondary is back on
                % as secondary
                s_choice = 1; % default, 1 = primary
                stns_alternate_s = []; % list of station numbers for which alternate is preferred
                %alternate = [1:16 47:999]; % list of station numbers for which alternate is preferred
                % after examining bottle salts and psal1-psal2 differences, prefer
                % calibrated psal1 for all stations up to 66. Station 45 after the
                % frozen cond1 seems to be fine after a new offset for calibration.
        end
        %%%%%%%%% end mctd_03 %%%%%%%%%
        
        
        %%%%%%%%%% msal_standardise_avg %%%%%%%%%%
    case 'msal_standardise_avg'
        switch oopt
            case 'indata'
                oklist = [72]; % proceed on these stations. CTD but no salts
                if(isempty(find(oklist == stnlocal)));
                    return
                end
                indata = {}; % the rest of the code seems to run fine if indata is empty.
        end
        %%%%%%%%%% end msal_standardise_avg %%%%%%%%%%
        
        
        %%%%%%%%%% msbe35_01 %%%%%%%%%%
    case 'msbe35_01'
        switch oopt
            case 'sbe35flag'
                % did not wait 20 seconds for 10 dbar bottles in position > 8 on station 040
                d.sbe35temp_flag(d.statnum==40 & d.position > 8) = 4;
                d.sbe35temp_flag(isnan(d.sbe35temp_flag)) = 9;
        end
        %%%%%%%%%% end msbe35_01 %%%%%%%%%%
        
        
        %%%%%%%%%% mtsg_bottle_compare %%%%%%%%%%
    case 'mtsg_bottle_compare'
        switch oopt
            case 'dbbad'
                db.salinity_adj(45) = nan; % bad comparison point on jr281
            case 'sdiff'
                clear sdiffsm
                sc1 = 0.01; sc2 = 0.05;
        end
        %%%%%%%%%% end mtsg_bottle_compare %%%%%%%%%%
        
        
        %%%%%%%%% mtsg_cleanup %%%%%%%%%
    case 'mtsg_cleanup'
        switch oopt
            case 'kbadlims'
                kbadlims = [
                    datenum([2013 01 01 00 00 00]) datenum([2013 03 18 14 51 00]) % start of cruise
                    datenum([2013 04 12 09 20 00]) datenum([2013 04 13 13 42 00])
                    datenum([2013 04 01 07 31 00]) datenum([2013 04 04 11 44 00])
                    datenum([2013 03 23 05 22 00]) datenum([2013 03 23 12 01 00])
                    datenum([2013 04 27 10 44 00]) datenum([2013 04 28 00 00 00]) % end of cruise
                    ];
        end
        %%%%%%%%% end mtsg_cleanup %%%%%%%%%
        
        %%%%%%%%% tsgsal_apply_cal %%%%%%%%%
    case 'tsgsal_apply_cal'
        switch oopt
            case 'saladj'
                botfile = ['ocl_' MEXEC_G.MSCRIPT_CRUISE_STRING '_01_medav_clean_botcompare'];
                MARGS_STORE = MEXEC_A.MARGS_IN_LOCAL;
                [db hb] = mload(botfile,'/');
                MEXEC_A.MARGS_IN_LOCAL = MARGS_STORE; % put things back how they were !
                db.salinity_adj(45) = nan; % bad bottle comparison
                % same code as used to generate smoothed adjustment in
                % mtsg_bottle_compare
                sdiff = db.salinity_adj-db.salinity;
                sdiffsm = filter_bak(ones(1,21),sdiff); % first filter
                res = sdiff - sdiffsm;
                sdiff(abs(res) > 0.01) = nan;
                sdiffsm = filter_bak(ones(1,21),sdiff); % harsh filter to determine smooth adjustment
                res = sdiff - sdiffsm;
                sdiff(abs(res) > 0.005) = nan;
                sdiffsm = filter_bak(ones(1,21),sdiff); % harsh filter to determine smooth adjustment
                db.dn = datenum(hb.data_time_origin)+db.time/86400;
                dv = datevec(db.dn(1));
                decday = db.dn-datenum([dv(1) 1 1 0 0 0]);
                adj = interp1([0 db.dn(:)' 1e10],[sdiffsm(1) sdiffsm(:)' sdiffsm(end)],dn); % extrapolate correction
                vout = salin+adj;
            case 'plot'
                m_figure
                plot(decday,sdiff,'k+');
                hold on; grid on;
                plot(decday,sdiffsm,'r+-');
                xlabel('Decimal day; noon on 1 Jan = 0.5');
                ylabel('salinity difference PSS-78');
                title({MEXEC_G.MSCRIPT_CRUISE_STRING; 'Bottle minus TSG salinity differences'; 'Individual bottles and smoothed adjustment applied'});
        end
        %%%%%%%%% end tsgsal_apply_cal %%%%%%%%%
        
        
        %%%%%%%%%% list_bot %%%%%%%%%%
    case 'list_bot'
        switch oopt
            case 'printmsg'
                fprintf(fidout,'%s\n','CTD data calibrated up to station 91; adjusted after that');
                %fprintf(fidout,'%s\n','CTD adjusted stns 1 to 66');
        end
        %%%%%%%%%% list_bot %%%%%%%%%%
        
        %%%%%%%%%% populate_station_depths %%%%%%%%%%
    case 'populate_station_depths'
        switch oopt
            case 'depth_source'
                fnintxt = fullfile(root_ctddep, [cruise '_stn_depth.txt']);
            case 'bestdeps'
                bestdeps(35,2) = 3443; % from CTD deck unit log aborted cast
                bestdeps(122,2) = 6059; % from CTD deck unit log cast did not go to full depth
        end
        %%%%%%%%%% end populate_station_depths %%%%%%%%%%
        
        
        %%%%%%%%%% station_summary %%%%%%%%%%
    case 'station_summary'
        switch oopt
            case 'sum_comments'
                comments{1} = 'Test station';
                ki = 2:33; comments(ki) = repmat({'sr1b'}, length(ki), 1);
                ki = [8 10 12 14 17 19 24 28]; comments(ki) = repmat({[comments{ki} ', float']}, length(ki), 1);
                ki = 34:66; comments(ki) = repmat({'Orkney Passage'}, length(ki), 1);
                ki = 35; comments(ki) = repmat({[comments{ki} ', aborted']}, length(ki), 1);
                ki = 67:92; comments(ki) = repmat({'A23'}, length(ki), 1);
                ki = 93:112; comments(ki) = repmat({'N Scotia Ridge'}, length(ki), 1);
                ki = 113:122; comments(ki) = repmat({'Arg. Basin'}, length(ki), 1);
                ki = 123:128; comments(ki) = repmat({'F. Trough'}, length(ki), 1);
            case 'parlist'
                parlist = [' sal'; ' cfc'];
        end
        %%%%%%%%%% end station_summary %%%%%%%%%%
        
        %%%%%%%%%% msec_run_mgridp %%%%%%%%%%
    case 'msec_run_mgridp'
        switch oopt
            case 'sections'
                sections = {'orkney' 'a23' 'srp' 'nsr' 'nsra23' 'abas' 'falk' 'sr1b'};
            case 'sec_stns'
                switch section
                    case 'sr1b'
                        kstns = [2:19 22:33];
                    case 'orkney'
                        kstns = [60 53:55 52 56 49 61 48 47 36 66 38 64 39 40 45];
                    case 'a23'
                        kstns = [67:92];
                    case 'srp'
                        kstns = 108:112;
                    case 'nsr'
                        kstns = 93:107;
                    case 'nsra23'
                        kstns = [67:107];
                    case 'abas'
                        kstns = 113:122;
                    case 'falk'
                        kstns = 123:128;
                end
            case 'sam_gridlist'
                varuselist.names = {'botoxy' 'totnit' 'phos' 'silc' 'dic' 'alk'};
        end
        %%%%%%%%%% end msec_run_mgridp %%%%%%%%%%
        
        
        %%%%%%%%%% m_maptracer %%%%%%%%%%
    case 'm_maptracer'
        switch oopt
            case 'kstatgroups'
                kstatgroups = {[60 53 54 55 52 56 49 61 48 47 36 38 39 40 45]}; % jr281
                kstatgroups = {[1:33] [60 53 54 55 52 56 49 61 48 47 36 38 39 40 45] [67:82]}; % jr281
                kstatgroups = {[67:82]}; % jr281
        end
        %%%%%%%%%% end m_maptracer %%%%%%%%%%
        
        
        %%%%%%%%%%%%%%%%%%
end