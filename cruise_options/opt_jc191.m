switch scriptname
    
    %%%%%%%%%% smallscript %%%%%%%%%%
    case 'smallscript'
        switch oopt
            case 'klist_reread_raw'
                klist = [2 ] ; %stations 1 and 2 were swivel tests; 27 and 28 aborted; 59 no samples
            case 'klist_new_oxyhyst'
                klist = [26:49 ] ; %stations 1 and 2 were swivel tests; 27 and 28 aborted; 59 no samples
            case 'klist_all_cals'
                klist = [71:135] ; %stations 1 and 2 were swivel tests; 27 and 28 aborted; 59 no samples
        end
        %%%%%%%%%% end smallscript %%%%%%%%%%
        
        
        %%%%%%%%%% mctd_01 %%%%%%%%%%
    case 'mctd_01'
        switch oopt
            case 'redoctm'
%                 if ismember(stnlocal, [52 53 58 60 66 69 74 77 81 90])
%                     redoctm = 1;
%                 end
        end
        %%%%%%%%%% end mctd_01 %%%%%%%%%%
        
        %%%%%%%%%% mctd_02a %%%%%%%%%%
    case 'mctd_02a'
        switch oopt
            case 'absentvars' % introduced new on jc191
                if sum(ismember(stnlocal,[67:70])) == 1 % deep stations on jc191
                    absentvars = {'fluor' 'transmittance'};
                end
            case 'corraw'
                %pvars is a list of variables to NaN when pumps are off, with the
                %second column setting the number of additional scans after the
                %pumps come back on to also NaN
                pvars = {'temp1' 12
                    'temp2' 12
                    'cond1' 12
                    'cond2' 12
                    'oxygen_sbe1' 8*24
                    };
                revars = {'press' -10 8000
                    'temp1' -2 32
                    'temp2' -2 32
                    'cond1' 25 60
                    'cond2' 25 60
                    'transmittance' 50 100
                    'oxygen_sbe1' 0 400
                    'fluor' 0 0.5
                    };
                dsvars = {'press' 3 2 2
                    'temp1' 1 0.5 0.5
                    'temp2' 1 0.5 0.5
                    'cond1' 1 0.5 0.5
                    'cond2' 1 0.5 0.5
                    'oxygen_sbe1' 3 2 2
                    'transmittance' 0.3 0.2 0.2
                    'fluor' 0.2 0.1 0.1
                    'turbidityV' 0.05 0.05 0.05%***
                    'pressure_temp' 0.1 0.1 0.1
                    };
%                 if ~ismember(stnlocal, [74 90]); dsvars = dsvars(:,1:2); end
                ovars = {'oxygen_sbe1'};
        end
        %%%%%%%%%% end mctd_02a %%%%%%%%%%
        
        %%%%%%%%%% mctd_02b %%%%%%%%%%
    case 'mctd_02b'
        switch oopt
            case 'calibs_to_do'
                dooxyhyst = 1;
                doturbV = 0;
            case 'oxyhyst'
                h = m_read_header(infile);
                if sum(strcmp('oxygen_sbe2',h.fldnam))
                    var_strings = [var_strings; 'oxygen_sbe2 time press'];
                    pars(2) = pars(1);
                    varnames = [varnames; 'oxygen2'];
                end
        end
        %%%%%%%%%% end mctd_02b %%%%%%%%%%
        
        %%%%%%%%%% mcoxyhyst %%%%%%%%%%
    case 'mcoxyhyst'
        %%%%%%%%%% end mcoxyhyst %%%%%%%%%%
        switch sensor
            case 1 % primary
                h3tab = [ % default
                    -10 1450
                    9000 1450
                    ];
                h3tab =[
                    -10 1000
                    1000 1000
                    1001 1000
                    2000 1000
                    2001 3000
                    9000 3000
                    ];
            case 2 % secondary
                h3tab = [ % default
                    -10 1450
                    9000 1450
                    ];
                h3tab =[
                    -10 1000
                    1000 1000
                    1001 1000
                    2000 1000
                    2001 3500
                    9000 3500
                    ];
            otherwise
        end
        
        H3 = interp1(h3tab(:,1),h3tab(:,2),press);
        
        
        %%%%%%%%%% mctd_03 %%%%%%%%%%
    case 'mctd_03'
        switch oopt
            case 's_choice' %this applies to both t and c
                s_choice = 2;
            case 'o_choice' %this applies to oxygen
                o_choice = 2;
        end
        %%%%%%%%%% end mctd_03 %%%%%%%%%%
        
        %%%%%%%%%% mfir_01 %%%%%%%%%%
    case 'mfir_01' %information about bottle firing
        switch oopt
            case 'fixbl'
% % % %                 if stnlocal==74; position(21) = 21; end
                %the .bl and .btl files say 2 but they're wrong (this was when
                %the termination was failing)
                %fix this here to prevent overwriting the good values
                %corresponding to when bottle 2 was actually fired
        end
        %%%%%%%%%% end mfir_01 %%%%%%%%%%
        
        %%%%%%%%%% mfir_03 %%%%%%%%%%
    case 'mfir_03'
        fillstr = '10'; %max gap length to fill is 10 s
        %%%%%%%%%% end mfir_03 %%%%%%%%%%
        
        %%%%%%%%%% mbot_00 %%%%%%%%%%
    case 'mbot_00' %information about niskin bottle numbers
        switch oopt
            case 'nispos'
                %inventory/serial numbers of the 20L niskins in order of 1 to 24
                nis_mix0 = [5977,6406,6407,6408,6409,6410,6411,6412,6413,...
                    6414,6415,6416,6417,6418,6419,6420,1122,1098,6692,...
                    6428,6425,6426,6427,1086];
                               
                nis_mix1 = [3034,3035,3036,3037,3038,nis_mix0(6:9),3043,...
                    3044,3045,3046,7131,3048,3049,3050,3051,3052,3053,...
                    3054,3055,3056,3057];
                
                nis_mix2 = [3034,3035,3036,3037,nis_mix0(5:10),...
                    3044,3045,3046,7131,3048,3049,3050,3051,3052,3053,...
                    3054,3055,3056,3057];
                
                nis = nis_mix0;
                
                if stnlocal >= 31 & stnlocal <= 103 %after station 30, 20 niskins were swapped out for easier 10L niskin spares
                    nis = nis_mix1;
                    %nis(11) now corresponds to max depth
                end % fixed 26 feb. Previous syntax was elseif , which was never executed.
                if stnlocal >= 104 & stnlocal <= 200
                    nis = nis_mix2;
                end
                if stnlocal ==95
                    nis = nis_mix0; % revert to all 20L for bulk water sample.
                end
                
%                 %inventory/serial numbers of the niskins in order of 1 to 24
%                 nis = [5977, 6406, 6407, 6408, 6409, 6410, 6411, 6412, 6413,...
%                     6414, 6415, 6416, 6417, 6418, 6419, 6420, 1122, 6692, 1098,...
%                     6428, 6425, 6426, 6427, 1086]; nis_spare = [1077];
%                 % 18 and 19 were switched from stn51 (and relabelled, so the
%                 %physical labels on the bottles still correspond to position
%                 %on the rosette)
%                 %spare niskin (was labelled "18" but it's a different one so
%                 %calling it 25) in position 1 from stn 101 so that CFCs can sparge
%                 %the original bottle 1
%                 %after stn 103 original 1 was put back in place, spare was moved to
%                 %position 2, and original 2 was taken for sparging
%                 if stnlocal>=51 & stnlocal<101; nis = nis([1:17 19 18 20:24])
%                 elseif stnlocal>=101 & stnlocal<104; nis = [nis_spare nis([2:17 19 18 20:24])];
%                 elseif stnlocal>=104; nis = [nis(1) nis_spare nis([3:17 19 18 20:24])];
%                 end
        end
        %%%%%%%%%% end mbot_00 %%%%%%%%%%
        
        %%%%%%%%%% mwin_01 %%%%%%%%%%
    case 'mwin_01'
        % jc159 - stations 1, 2, 27, 28 have winch data for swivel tests but no ctd files
        switch stnlocal
            case 0 % example from jc159
                winch_time_start = [2018 3 1 12 30 0]; % first swivel test
                winch_time_end = [2018 3 1 14 33 0];
            otherwise
                winch_time_start = nan;
                winch_time_end = nan;
        end
        
        %%%%%%%%%% end mwin_01 %%%%%%%%%%
        
        %%%%%%%%%% mwin_03 %%%%%%%%%%
    case 'mwin_03'
        fix_string = [];
        % jc159: when winch is switched from auto control to manual control
        % for recovery, usually around 100 metres, the winch telemetry is
        % off for a few seconds and techsas records a zero, which sometimes
        % shows up as zero wireout at the bottle closure time. This option
        % first introduced on jr302
        switch stnlocal
%             case 5
%                 fix_string = 'y(14:15) = y(13);'; % use existing bottle wireout to ensure they match exactly
%             case 6
%                 fix_string = 'y(18) = y(17);';
%             case 15
%                 fix_string = 'y(18) = y(19);';
            case 0
                fix_string = 'y(20) = [100];'; % nominal
            otherwise
        end
        %%%%%%%%%% end mwin_03 %%%%%%%%%%
        
        
        %%%%%%%%%% mctd_checkplots %%%%%%%%%%
    case 'mctd_checkplots'
        switch oopt
            case 'pf1'
                pf1.ylist = 'press temp asal oxygen';
            case 'sdata'
                sdata1 = d{ks}.asal1; sdata2 = d{ks}.asal2; tis = 'asal'; sdata = d{ks}.asal;
            case 'odata'
                odata1 = d{ks}.oxygen1; if isfield(d{ks}, 'oxygen2'); odata2 = d{ks}.oxygen2; end
        end
        %%%%%%%%%% end mctd_checkplots %%%%%%%%%%
        
        %%%%%%%%%% mctd_rawshow %%%%%%%%%%
    case 'mctd_rawshow'
        switch oopt
            case 'pshow2'
                h = m_read_header(pshow2.ncfile.name); if sum(strcmp('oxygen_sbe2', h.fldnam)); pshow2.ylist = 'pressure_temp press oxygen_sbe1 oxygen_sbe2'; end
        end
        %%%%%%%%%% end mctd_rawshow %%%%%%%%%%
        
        %%%%%%%%%% mctd_rawedit %%%%%%%%%%
    case 'mctd_rawedit'
        switch oopt
            case 'autoeditpars'
% %                 if stnlocal==90
% %                     dodespike = 1;
% %                     dsvars = {'oxygen_sbe1' 2
% %                         'transmittance' 0.2
% %                         'fluor' 0.2
% %                         'turbidityV' 0.05
% %                         };
% %                 end
        end
        %%%%%%%%%% end mctd_rawedit %%%%%%%%%%
        
        %%%%%%%%%% list_bot %%%%%%%%%%
    case 'list_bot'
        switch oopt
            case 'samadj'
                dsam.cruise = 159 + zeros(size(dsam.sampnum));
                hsam.fldnam = [hsam.fldnam {'cruise' 'lon' 'lat' 'bottom_dep' 'udepth' 'usig0' 'ugamma_n'}];
                hsam.fldunt = [hsam.fldunt {'number' 'degreesE' 'degreesN' 'metres' 'metres' 'kg/m3' 'gamma'}];
            case 'printmsg'
                msg = [datestr(now,31) ' jc159 CTD PSAL and Oxygen data uncalibrated' ];
                %msg = [datestr(now,31) ' dy040 CTD PSAL and Oxygen data preliminary calibration' ]; %dy040 elm 26 Dec 2015
                %msg = [datestr(now,31) ' dy040 CTD PSAL and Oxygen data final end of cruise calibration' ]; %dy040 elm 20 jan 2016 oxy data up to 139; salts up to 135
                fprintf(1,'%s\n',msg);
                fprintf(fidout,'%s\n',msg);
        end
        %%%%%%%%%% list_bot %%%%%%%%%%
        
        %%%%%%%%%% populate_station_depths %%%%%%%%%%
    case 'populate_station_depths'
        switch oopt
            case 'fnin'
                depmeth = 1; %get from text file generated by LADCP basic proc
                fnin = '/local/users/pstar/cruise/data/ladcp/ix/bdeps.txt';
            case 'bestdeps'
                ii = find(bestdeps(:,1)==2); bestdeps(ii,2) = 37; % from CTD+Altim
                ii = find(bestdeps(:,1)==3); bestdeps(ii,2) = 65; % from CTD+Altim
                ii = find(bestdeps(:,1)==4); bestdeps(ii,2) = 148; % from CTD+Altim
                ii = find(bestdeps(:,1)==10); bestdeps(ii,2) = 671; % from CTD+Altim
                ii = find(bestdeps(:,1)==15); bestdeps(ii,2) = -9; % LADCP bottom not found; no em122; sim unreliable
                ii = find(bestdeps(:,1)==16); bestdeps(ii,2) = 1283; % estimated from LADCP
                ii = find(bestdeps(:,1)==18); bestdeps(ii,2) = 2319; % em122 at end of cast; no em122 during cast
                ii = find(bestdeps(:,1)==20); bestdeps(ii,2) = 4532; % LADCP flaky; read from CTD+Altim
                ii = find(bestdeps(:,1)==25); bestdeps(ii,2) = -9;   % Station 25 does not exist;
                ii = find(bestdeps(:,1)==28); bestdeps(ii,2) = 4811; % read from em122
                ii = find(bestdeps(:,1)==61); bestdeps(ii,2) = 5775; % LADCP flaky; read from CTD+Altim
                ii = find(bestdeps(:,1)==62); bestdeps(ii,2) = 5858; % LADCP flaky; read from CTD+Altim
                ii = find(bestdeps(:,1)==67); bestdeps(ii,2) = 6277; % LADCP off for dep > 6000; taken from CTD+Altim
                ii = find(bestdeps(:,1)==68); bestdeps(ii,2) = 6005; % LADCP off for dep > 6000; taken from CTD+Altim
                ii = find(bestdeps(:,1)==69); bestdeps(ii,2) = 6466; % LADCP off for dep > 6000; taken from CTD+Altim
                ii = find(bestdeps(:,1)==70); bestdeps(ii,2) = 5897; % LADCP off for dep > 6000; taken from CTD+Altim
                ii = find(bestdeps(:,1)==73); bestdeps(ii,2) = 5834; % LADCP depth unclear; taken from CTD+Altim
                ii = find(bestdeps(:,1)==74); bestdeps(ii,2) = 5731; % LADCP depth unclear; taken from CTD+Altim
                ii = find(bestdeps(:,1)==75); bestdeps(ii,2) = 5949; % LADCP depth unclear; taken from CTD+Altim
                ii = find(bestdeps(:,1)==78); bestdeps(ii,2) = 5153; % LADCP depth unclear; taken from CTD+Altim
                ii = find(bestdeps(:,1)==83); bestdeps(ii,2) = 5282; % LADCP depth unclear; taken from CTD+Altim
                ii = find(bestdeps(:,1)==84); bestdeps(ii,2) = 4568; % LADCP depth unclear; taken from CTD+Altim
                ii = find(bestdeps(:,1)==86); bestdeps(ii,2) = 5038; % LADCP depth unclear; taken from CTD+Altim
                ii = find(bestdeps(:,1)==90); bestdeps(ii,2) = 4932; % LADCP depth unclear; taken from CTD+Altim
                ii = find(bestdeps(:,1)==95); bestdeps(ii,2) = 4953; % Bulk water station; no bottom approach; depth from em120;
                ii = find(bestdeps(:,1)==100); bestdeps(ii,2) = 5164; %  from CTD+Altim
                ii = find(bestdeps(:,1)==101); bestdeps(ii,2) = 5711; %  from CTD+Altim
                ii = find(bestdeps(:,1)==106); bestdeps(ii,2) = 6280; %  from EM120; profile stopped at 6000 metres.
                ii = find(bestdeps(:,1)==107); bestdeps(ii,2) = 5428; % LADCP depth unclear; taken from CTD+Altim
                ii = find(bestdeps(:,1)==108); bestdeps(ii,2) = 5916; % LADCP depth unclear; taken from CTD+Altim
                ii = find(bestdeps(:,1)==131); bestdeps(ii,2) = 2845; % 2000 metre bulk water station
        end
        %%%%%%%%%% end populate_station_depths %%%%%%%%%%
        
        %%%%%%%%%% mbot_01 %%%%%%%%%%
    case 'mbot_01'
        switch oopt
            case 'botflags'
                %stn nis
% %                 flag3 = [3 9; 6 5; 7 9; 26 5; 36 9; 57 15;... %leaking (clearly) %3716, 4513, 5117
% %                     98 5; 98 6; 98 12; 98 21; 103 19]; %caps were loose, so probably some leaking..?
% %                 flag4 = [4 9; 4 2; 8 22; 9 22; 13 20; 16 1; 32 18; 43 8; 43 16; 48 3; 48 13; 49 16; 74 9; 74 21; 74 22; 74 23; 74 24; 76 9; 80 6; 83 7; 89 16; 112 7; 113 7; 114 10;... %from logsheet
% %                     90 4; 90 8; %pumps off when bottle fired, so we don't know t, s
% %                     41 16; 32 16; 17 13; 18 9; 16 9; 39 13; 47 17; 37 16; 52 22; 97 6; 98 1]; %did not trip correctly (i.e. CTD thought it tripped but it obviously closed at the wrong depth)
% %                 flag9 = [114 17; 114 22; ...
% %                     115 3; 115 6; 115 9; 115 12; 115 14; 115 15; 115 17; 115 18; 115 20; 115 21; 115 23; 115 24; ...
% %                     116 16; 116 19; 116 21; 116 23; 116 24; ...
% %                     117 20; 117 22; 117 24; ...
% %                     122 10; 122 12];
                flag3 = [0 0; 8 12; 10 5; 17 5; 29 12; 33 23]; % leaking (Woce table 4.8)
                flag4 = [0 0; 2 5; 4 3; 4 16; 5 4; 5 20; 5 24; 6 2; 6 16; 6 20; 7 20; 8 3; 9 3; 9 16; 10 1; 10 3; 10 16;...
                    10 20; 10 24; 12 4; 16 4; 18 4; 20 17; 23 1; 23 24; 29 1; 29 2; 29 4; 29 17; 29 19; 29 24;.....
                    31 1; 31 12; 32 1; 33 1; 33 12; 33 17; 34 1; 35 1]; % did not trip correctly (Woce table 4.8)
                flag4 = [flag4; 27 01; 73 10; 84 08; 87 08; 90 08; 96 15; 97 15; 98 15; 114 20]; % 2701 psal, botoxy, silc all suggest closed shallower.
                flag4 = [flag4; 18 20; 73 11; 20 01]; % 1820 may have closed at shallower depth.
                % pylon latch assembly replaced after station 35, and
                % reliability dramatcailly improved. Most of the failures
                % before station 35 were the latch not letting go of the
                % lanyard.
                % No problems noted from station 36 to 79
                flag9 = [0 0]; % samples not drawn from this bottle (Woce table 4.8)
                iif = find(flag3(:,1)==stnlocal); if length(iif)>0; bottle_qc_flag(flag3(iif,2)) = 3; end
                iif = find(flag4(:,1)==stnlocal); if length(iif)>0; bottle_qc_flag(flag4(iif,2)) = 4; end
                iif = find(flag9(:,1)==stnlocal); if length(iif)>0; bottle_qc_flag(flag9(iif,2)) = 9; end
%                 if ismember(stnlocal, [27 28 59 125]); bottle_qc_flag(:) = 9; end
        end
        %%%%%%%%%% end mbot_01 %%%%%%%%%%
        
        
        %%%%%%%%%% msal_01 %%%%%%%%%%
    case 'msal_01'
        switch oopt
            case 'flags'
%                 flags3 = [3123 5620 8122 9209];
%                 flags4 = [0308 1916 3513 3716 ...
%                     4002 4117 4513 5117 5118 5222 5415 5416 5417 6101 6522 ...
%                     7101 7118 7204 7308 7309 7320 7802 7811 7813 7902 ...
%                     8007 8008 8102 8523 8816 8701];
%                 flags5 = [10823];
                flags3 = [0]; % questionable (Woce table 4.9)
                flags4 = [2001 2017 2902 3112]; % bad (Woce table 4.9)
                flags5 = [1317 1517 1810 3014 4515]; % not reported (Woce table 4.9)
                flags9 = [0]; % sample not drawn for this measurement from this bottle (Woce table 4.9)
%                 flag(ismember(ds_sal.sampnum, flags3)) = 3;
%                 flag(ismember(ds_sal.sampnum, flags4)) = 4;
%                 flag(ismember(ds_sal.sampnum, flags5)) = 5;
%                 flag(ismember(ds_sal.sampnum, flags9)) = 9;
                flag(ismember(sampnum, flags3)) = 3;
                flag(ismember(sampnum, flags4)) = 4;
                flag(ismember(sampnum, flags5)) = 5;
                flag(ismember(sampnum, flags9)) = 9;
%                 flags(ismember(ds_sal.station_day, 12)) = 3; %questionable standardisation
        end
        %%%%%%%%%% end msal_01 %%%%%%%%%%
        
        %%%%%%%%%% msal_standardise_avg %%%%%%%%%%
    case 'msal_standardise_avg'
        switch oopt
            case 'check_sal_runs'
                check_sal_runs = 0;
                calc_offset = 1;
                plot_all_stations = 0;
            case 'k15'
                sswb = 163; %ssw batch
                msal_ssw
                ds_sal.K15 = zeros(size(ds_sal.sampnum));
                ds_sal.K15(iistd) = ssw_batches(ssw_batches(:,1)==sswb,2)/2;
            case 'cellT'
                ds_sal.cellT = 24+zeros(length(ds_sal.sampnum),1);
            case 'std2use'
%                 std2use([47 68 121],1) = 0;
%                 std2use([50],2) = 0;
%                 std2use([61],3) = 0;
            case 'sam2use'
%                 sam2use(51,2) = 0;
%                 sam2use([2587 2896],3) = 0;
            case 'fillstd'
                %add the start standard--can add it at the end because we'll
                %use time to interpolate
                ds_sal.sampnum = [ds_sal.sampnum; 999000];
                ds_sal.offset(end) = 0;
                ds_sal.runtime(end) = ds_sal.runtime(1)-1/60/24; %put it 1 minute before sample 1
                %%machine was re-standardised before running stn 68
                %ds_sal.sampnum = [ds_sal.sampnum; 999097.5];
                %ds_sal.offset(end) = 4e-6;
                %ds_sal.runtime(end) = ds_sal.runtime(ds_sal.sampnum==6801)-1/60/24;
                %this half-crate had no standard at the end so use the one
                %from the beginning
                if sum(ds_sal.sampnum==999111)
                    ds_sal.sampnum = [ds_sal.sampnum; 999111.5];
                    ds_sal.offset(end) = ds_sal.offset(ds_sal.sampnum==999111);
                    ds_sal.runtime(end) = ds_sal.runtime(ds_sal.sampnum==7611)+1/60/24;
                    %interpolate based on runtime
                    xoff = ds_sal.runtime;
                end
        end
        %%%%%%%%%% msal_standardise_avg %%%%%%%%%%
        
        %%%%%%%%%% moxy_01 %%%%%%%%%%
    case 'moxy_01'
        switch oopt
            case 'oxyconc_recalc'
                oxyconc_recalc = 1;
            case 'oxycsv'
                %infile = [root_oxy '/oxy_jc159_all.csv'];
                infile = [root_oxy '/' 'oxy_jc191_' sprintf('%03d',stnlocal) '.csv'];
            case 'sampnum_parse'
                ds_oxy.statnum = ds_oxy.Cast;
                ds_oxy.niskin = ds_oxy.Niskin;
                ds_oxy.sampnum = ds_oxy.statnum*100+ds_oxy.niskin;
                ds_oxy.oxy_bot = ds_oxy.Bottle;
                ds_oxy.bot_vol = ds_oxy.Bottle_vol0x2E;
                ds_oxy.vol_blank = ds_oxy.Blank;
                ds_oxy.vol_std = ds_oxy.Std;
                ds_oxy.vol_titre_std = ds_oxy.Standard;
                ds_oxy.oxy_temp = ds_oxy.Fixing_temp0x2E;
                ds_oxy.oxy_titre = ds_oxy.Sample;
                ds_oxy.mol_std = ds_oxy.Iodate_M;
                ds_oxy.nO2 = ds_oxy.n0x28O20x29;
                ds_oxy.concO2 = ds_oxy.C0x28O20x29;
                ds_oxy.flag = ds_oxy.flag;
            case 'flags'
                flags3 = [0];
                flags4 = [2017 2912 3112 3317 3323];
%                 flags3 = [0308 1405 1415 2101 2103 3222 4201 4513 4804 ...
%                     5110 5614 5716 5717 5718 5816 6316 6612 6910 ...
%                     7103 7321 7322 8513];
%                 flags4 = [0406 0523 0601 2106 2311 2320 2322 2323 3004 3023 ...
%                     3217 3506 3915 4115 4121 4203 4707 4720 4724 4810 4811 ...
%                     5023 5123 5222 5313 5402 5605 5616 5712 6005 6011 6014 6101 6124 ...
%                     8124 10917 10904 11022 11023 11213 12020];
                botoxyflaga(ismember(sampnum, flags3)) = 3;
                botoxyflaga(ismember(sampnum, flags4)) = 4;
%                 if ismember(stnlocal, [9:11 24 34 44]) %standardisation probably wrong
%                     %due to bubbles in line; earlier set flags to 3 but now say 4
%                     botoxyflaga(botoxyflaga<=4) = 4;
%                     botoxyflagb(botoxyflagb<=4) = 4;
%                 end
        end
        %%%%%%%%%% end moxy_01 %%%%%%%%%%
        
        %%%%%%%%%% moxy_ccalc %%%%%%%%%%
    case 'moxy_ccalc'
        switch oopt
            case 'oxypars'
%                 vol_reag1 = mean([1.00 1.01 1.01]); % jc159
%                 vol_reag2 = mean([1.04 1.03 1.03 1.03]); % jc159
                vol_reag1 = mean([1.00 1.01 1.01]);
                vol_reag2 = mean([1.04 1.03 1.03 1.03]);
            case 'blstd'
                vol_std = ds_oxy.vol_std;
                vol_titre_std = ds_oxy.vol_titre_std;
                vol_blank = ds_oxy.vol_blank;
                mol_std = ds_oxy.mol_std*1e-3;
            case 'botvols'
                obot_vol = ds_oxy.bot_vol; %***also check volumes?
                if 0
                    fname_bottle = 'ctd/BOTTLE_OXY/flask_vols.csv';
                    ds_bottle = dataset('File', fname_bottle, 'Delimiter', ',');
                    ds_bottle(isnan(ds_bottle.bot_num),:) = [];
                    mb = max(ds_bottle.bot_num); a = NaN+zeros(mb, 1);
                    a(ds_bottle.bot_num) = ds_bottle.bot_vol;
                    iig = find(~isnan(ds_oxy.oxy_bot) & ds_oxy.oxy_bot~=-999);
                    obot_vol = NaN+ds_oxy.oxy_bot; obot_vol(iig) = a(ds_oxy.oxy_bot(iig)); %mL
                end
            case 'compcalc'
                compcalc = 0; %if stnlocal>=30; compcalc = 1; end %***should just check again with up to date precise volumes
        end
        %%%%%%%%%% end moxy_ccalc %%%%%%%%%%
        
        %%%%%%%%%% mnut_01 %%%%%%%%%%
    case 'mnut_01'
        switch oopt
            case 'sampnum_parse'
                ds_nut.position = ds_nut.BTTLE_NB;
                ds_nut.sampnum = 100*ds_nut.station + ds_nut.position;
                ds_nut.niskin = ds_nut.position;
%                 stncol = ds_nut.METH;
%                 ds_nut.sampnum = zeros(size(stncol));
%                 b = zeros(size(stncol));
%                 forms = {'st'; 'sta'; 'stn'}; %station number may be preceded by any of these (or their upper case versions)
%                 for no = 1:length(forms)
%                     b = b + strncmpi([forms{no} stn_string], stncol, length(forms{no})+length(stn_string)); %may be a 3-digit station number
%                     b = b + strncmpi([forms{no} num2str(stnlocal)], stncol, length(forms{no})+length(num2str(stnlocal))); %or may be a variable-digit station number
%                 end
%                 iig = find(b>0);
%                 for no = 1:length(iig)
%                     %station and niskin can be separated by - or space
%                     ii = strfind(stncol{iig(no)}, '-'); if length(ii)==0; ii = strfind(stncol{iig(no)}, ' '); end
%                     %sample may or may not have a trailing letter
%                     nisk = str2num(stncol{iig(no)}(ii+1:end)); if isempty(nisk); nisk = str2num(stncol{iig(no)}(ii+1:end-1)); end
%                     ds_nut.sampnum(iig(no)) = stnlocal*100 + nisk;
%                 end
%                 ds_nut.station = floor(ds_nut.sampnum/100);
%                 ds_nut.niskin = ds_nut.sampnum-floor(ds_nut.sampnum/100)*100;
            case 'vars'
                vars = {
                    'position'     'number'     'niskin'
                    'statnum'      'number'     'station'
                    'sampnum'      'number'     'sampnum'
                    'sio4'         'umol/L'     'SILICATE_per_l'
                    %    		   'sio4'         'umol/L'     'SiCOR'
                    'sio4_flag'    'woceflag'   ''
                    'po4'          'umol/L'     'PHOSPHATE_per_l'
                    %		       'po4'          'umol/L'     'PO4COR'
                    'po4_flag'     'woceflag'   ''
                    'no3no2'       'umol/L'     'NITRATE_per_l'
                    %	    	   'no3no2'       'umol/L'     'NO3_NO2COR'
                    'no3no2_flag'  'woceflag'   ''
                    'no2'          'umol/L'     'NITRITE_per_l'
                    %		       'no2'          'umol/L'     'NO2COR'
                    'no2_flag'	  'woceflag'   ''
                    };
            case 'flags'
                %flags4 = [12001 12004];
                flag0 = 5; % if there is a line in the nut file for this sample, but no value, then the flag is '5', 'not reported'
                flags4 = [2001 2017 2701 2902 3112 3317 4716 5016 5612 5714 5716 5915 5916 7311 8211 11522 11805 12113];
                sampnum = ds_nut.sampnum;
                si04_flag(ismember(sampnum, flags4)) = 4;
                po4_flag(ismember(sampnum, flags4)) = 4;
                no3no2_flag(ismember(sampnum, flags4)) = 4;
                no2_flag(ismember(sampnum, flags4)) = 4;
        end
        %%%%%%%%%% end mnut_01 %%%%%%%%%%
        
        %%%%%%%%%% msam_nutkg %%%%%%%%%%
    case 'msam_nutkg'
        switch oopt
            case 'labtemp'
                labtemp = 25;
        end
        %%%%%%%%%% end msam_nutkg %%%%%%%%%%
        
        
        %%%%%%%%%% mpig_01 %%%%%%%%%%

    case 'mpig_01' % jc191 filtering data for pigments
        switch oopt
            case 'sampnum_parse'
                ds_pig.position = ds_pig.Niskin_0x23;
                scells = ds_pig.Station_0x23; % some 'station' IDs are station numbers; some are text strings
                ncells = length(scells);
                stations = nan(ncells,1);
                for kl = 1:ncells
                    try stations(kl) = str2num(scells{kl});
                    catch
                    end
                end
                ds_pig.station = stations;
                ds_pig.sampnum = 100*ds_pig.station + ds_pig.position;
                ds_pig.niskin = ds_pig.position;
            case 'vars'
                vars = {
                    'position'     'number'     'niskin'
                    'statnum'      'number'     'station'
                    'sampnum'      'number'     'sampnum'
                    'chla'         'ug/l'     'Chl_a'
                    'chla_flag'    'woceflag'   ''
                    'pheoa'          'ug/l'     'pheo_a'
                    'pheoa_flag'     'woceflag'   ''
                    };
            case 'flags'
%                 flags4 = [12001 12004];
                flag0 = 5; % if there is a line in the pig file for this sample, but no value, then the flag is '5', 'not reported'
                flags4 = [0];
                sampnum = ds_pig.sampnum;
                si04_flag(ismember(sampnum, flags4)) = 4;
                po4_flag(ismember(sampnum, flags4)) = 4;
                no3no2_flag(ismember(sampnum, flags4)) = 4;
                no2_flag(ismember(sampnum, flags4)) = 4;
        end
        %%%%%%%%%% end sam_nutkg %%%%%%%%%%

        
        %%%%%%%%%% mpig_01 %%%%%%%%%%

    case 'mpig_01' % jc191 filtering data for pigments
        switch oopt
            case 'sampnum_parse'
                ds_pig.position = ds_pig.Niskin_0x23;
                scells = ds_pig.Station_0x23; % some 'station' IDs are station numbers; some are text strings
                ncells = length(scells);
                stations = nan(ncells,1);
                for kl = 1:ncells
                    try stations(kl) = str2num(scells{kl});
                    catch
                    end
                end
                ds_pig.station = stations;
                ds_pig.sampnum = 100*ds_pig.station + ds_pig.position;
                ds_pig.niskin = ds_pig.position;
            case 'vars'
                vars = {
                    'position'     'number'     'niskin'
                    'statnum'      'number'     'station'
                    'sampnum'      'number'     'sampnum'
                    'chla'         'ug/l'     'Chl_a'
                    'chla_flag'    'woceflag'   ''
                    'pheoa'          'ug/l'     'pheo_a'
                    'pheoa_flag'     'woceflag'   ''
                    };
            case 'flags'
%                 flags4 = [12001 12004];
                flag0 = 5; % if there is a line in the pig file for this sample, but no value, then the flag is '5', 'not reported'
                flags4 = [0];
                sampnum = ds_pig.sampnum;
                si04_flag(ismember(sampnum, flags4)) = 4;
                po4_flag(ismember(sampnum, flags4)) = 4;
                no3no2_flag(ismember(sampnum, flags4)) = 4;
                no2_flag(ismember(sampnum, flags4)) = 4;
        end
        %%%%%%%%%% end mpig_01 %%%%%%%%%%

    %%%%%%%%%% miso_01 %%%%%%%%%%
    case 'miso_01'
        switch oopt
            case 'files'
                files{1} = [root_iso '/c13_jc159_bgs.csv'];
                files{2} = [root_iso '/SampleResults_2018112_withStationNumbersCorrected.csv'];
                files{3} = [root_iso '/A095_740H20180228_no_cfc_values_hy_with_d18o.csv'];
            case 'vars'
                vars{1} = {
                    'del13c_bgs' 'per_mil' 'd13CDICPDB';
                    'del13c_bgs_flag' 'woceflag' ''};
                vars{2} = {
                    'del13c_whoi'  'per_mil' 'd13C'
                    'del14c_whoi'  'per_mil' 'D14C'
                    %'dic_whoi' 'mmol_per_kg' 'DIC Conc (mmol/kg)'
                    'del14c_whoi_flag' 'woceflag' 'flag'
                    'del13c_whoi_flag' 'woceflag' 'flag'};
                vars{3} = {
                    'del18o_bgs'      'per_mil' 'BOT_O_18'
                    'del18o_bgs_flag' 'per_mil' 'BOT_O_18_FLAG'};
            case 'flags'
                del18o_bgs(del18o_bgs<-990) = NaN;
                del18o_bgs_flag(isnan(del18o_bgs) & ismember(del18o_bgs_flag, [2 3])) = 4;
        end
        %%%%%%%%%% end miso_01 %%%%%%%%%%

        %%%%%%%%%% miso_02 %%%%%%%%%%
    case 'miso_02'
        switch oopt
            case 'vars'
                cvars = 'del13c_bgs del13c_bgs_flag del13c_whoi del13c_whoi_flag del14c_whoi del14c_whoi_flag del18o_bgs del18o_bgs_flag'
        end
        %%%%%%%%%% end miso_02 %%%%%%%%%%
        
        %%%%%%%%%% mco2_01 %%%%%%%%%%
    case 'mco2_01'
        switch oopt
            case 'infile'
                load([root_co2 '/' mcruise '_alkalinity_hydro']); indata = hydro;
                indata1 = load([root_co2 '/' mcruise '_dic_hydro']); indata1 = indata1.hydro;
                indata1.talk = NaN+indata1.dic; indata1.talk(1:length(indata.talk)) = indata.talk;
                indata1.QF_talk = NaN+zeros(size(indata1.QF_dic));
                indata1.QF_talk(1:length(indata.QF_talk)) = indata.QF_talk;
                indata = indata1;
            case 'varnames' %capitalisation is important!
                varnames = {'statnum' 'stn'
                    'niskin'  'nisk'
                    'alk' 'talk'
                    'alk_flag' 'QF_talk'
                    'dic' 'dic'
                    'dic_flag' 'QF_dic'
                    };
            case 'flags'
                flag3a = [0000];
                flag4a = [0000];
                flag3d = [0000];
                flag4d = [0000];
                alk_flag(ismember(sampnum, flag3a)) = 3;
                alk_flag(ismember(sampnum, flag4a)) = 4;
                dic_flag(ismember(sampnum, flag3d)) = 3;
                dic_flag(ismember(sampnum, flag4d)) = 4;
        end
        %%%%%%%%%% end mco2_01 %%%%%%%%%%
        
        %%%%%%%%%% mcfc_01 %%%%%%%%%%
    case 'mcfc_01'
        switch oopt
            case 'inputs'
                %list of variables and units in input, and in output, and
                %scale factors
                varsunits = {
                    'station'    'number'  'station'  'number'    1
                    'niskin'     'number'  'position' 'on.rosette' 1
                    'sf6mole' 'mol/l' 'sf6'        'fmol/l' 1e15
                    'sf6flag'   'woce_table_4.9' 'sf6_flag'   'woce_table_4.9' 1
                    'f11mole'      'mol/l' 'cfc11' 'pmol/l' 1e12
                    'f11flag' 'woce_table_4.9' 'cfc11_flag' 'woce_table_4.9' 1
                    'f12mole'      'mol/l'  'cfc12' 'pmol/l'    1e12
                    'f12flag' 'woce_table_4.9' 'cfc12_flag' 'woce_table_4.9' 1
                    'f113mole' 'mol/l' 'f113'       'pmol/l' 1e12
                    'f113flag'  'woce_table_4.9' 'f113_flag'  'woce_table_4.9' 1
                    'ccl4mole' 'mol/l' 'ccl4'       'pmol/l' 1e12
                    'ccl4flag'  'woce_table_4.9' 'ccl4_flag'  'woce_table_4.9' 1
                    };
                % bak post jc159 on bakmac; new file from M-J passed over
                % at LHR
                infile = [root_cfc '/cfc_' mcruise '_all.txt'];

        end
        %%%%%%%%%% end mcfc_01 %%%%%%%%%%
        
        %%%%%%%%%% mcfc_02 %%%%%%%%%%
    case 'mcfc_02'
        switch oopt
            case 'cfclist'
                cfcinlist = 'sf6 sf6_flag cfc11 cfc11_flag cfc12 cfc12_flag f113 f113_flag ccl4 ccl4_flag';
                cfcotlist = cfcinlist;
        end
        %%%%%%%%%% end mcfc_02 %%%%%%%%%%
        
        %%%%%%%%%% msam_checkbottles_02 %%%%%%%%%%
    case 'msam_checkbottles_02'
        switch oopt
            case 'section'
                section = '24n';
%                 section = 'fs27n';
                stnlist = stnlocal-2:stnlocal+2;
            case 'docals'
                doocal = 0;
        end
        %%%%%%%%%% end msam_checkbottles_02 %%%%%%%%%%
        
        %%%%%%%%%% msam_checkbottles_01 %%%%%%%%%%
    case 'msam_checkbottles_01'
        switch oopt
            case 'section'
                section = '24n';
            case 'docals'
                doocal = 1;
        end
        %%%%%%%%%% end msam_checkbottles_01 %%%%%%%%%%
        
        %%%%%%%%%% msam_ashore_flag %%%%%%%%%%
    case 'msam_ashore_flag'
        switch samtype
            case 'del13c_noc'
                % must set the following variables which are used in the calling script  msam_ashore_flag.m
                % stations - list of stations where some flags are set
                % flagnames - a cell array of flagnames for which some flags are set
                % flagvals - an array of flag values that might be being set
                % sampnums - a cell array of size n_flagnames by n_flagvals
                %     in which each cell is the list of sample numbers for
                %     which that flagname gets that flagval
                stations = [7 24 34 40 46 52 55 58 63 66 69 73 79 83 90 ...
                    94 99 103 108 111 115 118 121 124 125]; % list from Pete B station 103 as well
                sampall = []; sampnums = {};
                dsam = mload('/local/users/pstar/jc191/mcruise/data/ctd/sam_jc191_all','/');
                k_all = find(ismember(dsam.statnum,stations) & ismember(dsam.bottle_qc_flag,[2 3]) & isfinite(dsam.dic) | isfinite(dsam.botpsal));
                
                k24 = 1:24; k24 = k24(:);
                allnums = 100*repmat(stations,24,1) + repmat(k24,1,length(stations));
                allnums = allnums(:); % all possible sample numbers on these stations.
                
                sampall_1 = dsam.sampnum(k_all); sampall_1 = sampall_1(:); % set these to 1
                sampall_9 = setdiff(allnums,sampall_1); % make sure the rest are overwritten with 9
                
                flagnames = {'del13c_noc_flag'};
                flagvals = [1 9];
                
                sampnums{1,1} = sampall_1; 
                sampnums{1,2} = sampall_9;
                
            case 'del14c_imp'
                fnin = [mgetdir('M_CTD') '/BOTTLE_14C/del14c_imp_jc191_01.csv'];                
                ds = dataset('File',fnin,'Delimiter',','); % two columns, headed 'station' and 'niskin'
                
                sampall = ds.station*100 + ds.niskin;
                sampall(isnan(sampall)) = [];
                sampall = sampall(:);
                stations = ds.station;
                stations(isnan(stations)) = [];
                
                stations = unique(stations); stations = stations(:)';
                flagnames = {'del13c_imp_flag' 'del14c_imp_flag'};
                flagvals = [1];
                sampnums{1,1} = sampall; % 'del13c_imp_flag'
                sampnums{2,1} = sampall; % 'del14c_imp_flag'
                
            case 'del14c_whoi'
                fnin = [mgetdir('M_CTD') '/BOTTLE_14C/del14c_whoi_jc191_01.csv'];
                ds = dataset('File',fnin,'Delimiter',','); % two columns, headed 'station' and 'niskin'
                
                sampall = ds.station*100 + ds.niskin;
                sampall(isnan(sampall)) = [];
                sampall = sampall(:);
                stations = ds.station;
                stations(isnan(stations)) = [];
                
                stations = unique(stations); stations = stations(:)';
                flagnames = {'del13c_whoi_flag' 'del14c_whoi_flag'};
                flagvals = [1];
                sampnums{1,1} = sampall;
                
            case 'ch4'
                fnin = [mgetdir('M_CTD') '/BOTTLE_CH4/ch4_jc191_sampnums.txt'];
                sampall = load(fnin); % one column of sample numbers
                stations = floor(sampall/100);
                                
                stations = unique(stations); stations = stations(:)';
                flagnames = {'ch4_flag'};
                flagvals = [1];
                sampnums{1,1} = sampall;
                
%             case 'chl'
%                 fnin = [mgetdir('M_BOT_CHL') '/Sample_log_Phyto_Chibo_sampnum.csv'];
%                 d_chl = load(fnin); %this is just three columns of numbers
%                 flagnames = {'botchla_flag'};
%                 flagvals = [1];
%                 sampnums = unique(d_chl(:,3));
%                 stations = floor(sampnums/100);
%                 sampnums = {unique(d_chl(:,3))};
%             case {'bgs' 'whoi'}
%                 if strcmp(samtype, 'bgs')
%                     flagnames = {'del18o_bgs_flag'; 'del13c_bgs_flag'};
%                 elseif strcmp(samtype, 'whoi')
%                     flagnames = {'del14c_whoi_flag'; 'del13c_whoi_flag'};
%                 end
%                 fnin = [mgetdir('M_BOT_ISO') '/sample_log_' samtype '.csv'];
%                 ds_iso = dataset('File',fnin,'Delimiter',','); %csv file including text comments
%                 ds_iso.sampnum = ds_iso.Station*100+ds_iso.Niskin;
%                 flagvals = unique(ds_iso.flag);
%                 for no = 1:length(flagvals)
%                     sampnums(1, no) = {ds_iso.sampnum(find(ds_iso.flag==flagvals(no)))};
%                 end
%                 sampnums(2,:) = sampnums(1,:);
%                 stations = floor(ds_iso.sampnum/100);
%             case 'imp'
%                 fnin = [mgetdir('M_BOT_ISO') '/sample_log_imp.csv'];
%                 ds_iso = dataset('File',fnin,'Delimiter',','); %csv file including text comments
%                 ds_iso.sampnum = ds_iso.Station*100+ds_iso.Niskin;
%                 ds_iso.flag = ones(size(ds_iso.sampnum)); ds_iso.flag(isnan(ds_iso.BagNum)) = 9;
%                 flagnames = {'del14c_imp_flag'; 'del13c_imp_flag'};
%                 flagvals = unique(ds_iso.flag);
%                 for no = 1:length(flagvals)
%                     sampnums(1, no) = {ds_iso.sampnum(find(ds_iso.flag==flagvals(no)))};
%                 end
%                 sampnums(2,:) = sampnums(1,:);
%                 stations = floor(ds_iso.sampnum/100);
%             case 'cfc' %for these, change flags of 9 to 1 where cfc11 and cfc12 flag is 2, 3, or 4 (all quantities analysed for all cfc vars, but not all calibrated/analyses received yet)
%                 flagnames = {'sf6_flag'; 'ccl4_flag'; 'f113_flag'};
%                 flagvals = [1];
%                 a = {[root_sam '/sam_' mcruise '_all']
%                      'sampnum'
%                      'cfc11_flag'
%                      'cfc12_flag'};
%                 a = [a; flagnames; '0'];
%                 MEXEC_A.MARGS_IN = a; [d,h] = mload;
%                 stations = [];
%                 for no = 1:length(flagnames)
%                     ii = find(d.cfc11_flag<=4 & d.cfc12_flag<=4 & getfield(d,flagnames{no})==9);
%                     sampnums(no,:) = {d.sampnum(ii)};
%                     stations = [stations; floor(d.sampnum(ii)/100)];
%                 end
          end
        %%%%%%%%%% end msam_ashore_flag %%%%%%%%%%
        
        
        
        %%%%%%%%%% ctd_all_part1 %%%%%%%%%%
    case 'ctd_all_part1'
        switch oopt
            case 'apply_cals_choice'
            cal_stations_temp = [1:999];
            cal_stations_cond = [1:999];
            cal_stations_oxy = [1:999];
            cal_stations_trans = [1:999];
            cal_stations_fluor = [1:999];
            
        end

        %%%%%%%%%% ctd_all_part1 %%%%%%%%%%
        
        %%%%%%%%%% cond_apply_cal %%%%%%%%%%
    case 'cond_apply_cal'
        %         function condout = cond_apply_cal(sensor,stn,press,time,temp,cond)
        switch sensor
            case 1
                off = interp1([-10 0 1000 4000 6000 8000],([0 0 1.5 -0.5 -0.5 -0.5]-0.3)*1e-3, press);
            case 2
                off = interp1([-10 0 1000 4000 6000 8000],([0 0 1.5 -0.5 -0.5 -0.5]+2.2)*1e-3, press);
        end
        fac = off/35 + 1;
        condadj = 0;
        condout = cond.*fac + condadj;
        %%%%%%%%%% cond_apply_cal %%%%%%%%%%
        
        %%%%%%%%%% oxy_apply_cal %%%%%%%%%%
    case 'oxy_apply_cal'
        %         function oxyout = oxy_apply_cal(sensor,stn,press,time,temp,oxyin)
        switch sensor
            case 1
                %                 o1rs_s = [ 0 20 70 106 ]; % station
                %                 o1rs_f = [  1.0441  1.0398  1.0588  1.0619 ]; % factor at stn 1 and stn 90
                %                 deps = [-10 2000:1000:6000 6600]; % don't use 1000 dbar; strong gradients
                %                 o1dfac = [0.9857    0.9980    1.0110    1.0189    1.0245    1.0259    1.0259]; % edit fac at 6600
%                 o1rs_s = [ 0 20 70 122 999  ];
%                 o1rs_f = [  1.0410  1.0410  1.0586  1.0627 1.0627  ]; % calculated with stations up to 116
                o1rs_s = [ 0 20 70 122 135  ];
                o1rs_f = [  1.0410  1.0410  1.0586  1.0663 1.0726  ]; % adjusted after 135
                deps = [ -10 2000 3000 4000 5000 6000 6600  ];
                o1dfac = [  0.9835  0.9959  1.0086  1.0170  1.0223  1.0268  1.0268  ]; % calculated with stations up to 116
                o1rs_i = interp1(o1rs_s,o1rs_f,stn); % interpolate station factor and scale dep factor
                o1dfac_p = interp1(deps,o1dfac,press);
                
                alpha = o1rs_i.*o1dfac_p;
                beta = 0;
            case 2
                %                 o2rs_s = [ 0 20 70 106 ]; % station
                %                 o2rs_f = [  1.0320  1.0390  1.0664  1.0662 ]; % factor at stn 1 and stn 90
                %                 deps = [-10 2000:1000:6000 6600]; % don't use 1000 dbar; strong gradients
                %                 o2dfac = [0.9822    1.0016    1.0149    1.0210    1.0239    1.0209    1.0209]; % edit fac at 6600
                
%                 o2rs_s = [ 0 20 70 122  999 ];
%                 o2rs_f = [  1.0370  1.0370  1.0671  1.0654 1.0654  ]; % calculated after 116 and applied
                o2rs_s = [ 0 20 70 122  135 ];
                o2rs_f = [  1.0370  1.0370  1.0671  1.0693 1.0756  ]; % adjusted after 135
                deps = [ -10 2000 3000 4000 5000 6000 6600  ];
                o2dfac = [  0.9822  0.9996  1.0124  1.0186  1.0219  1.0212  1.0212  ];
                o2rs_i = interp1(o2rs_s,o2rs_f,stn);
                o2dfac_p = interp1(deps,o2dfac,press);
                
                alpha = o2rs_i.*o2dfac_p;
                beta = 0;
        end
        %         alpha = (1.036 + interp1([0 800 6000], [1 0 -2]*1e-4, press).*stn);
        %         beta = interp1([0 400 1250 2000 3000 4000 6000], [-2.7 0.25 2.75 5.6 7.5 8 7.1], press);
        oxyout = alpha.*oxyin + beta;
        %%%%%%%%%% end oxy_apply_cal %%%%%%%%%%
        
        %%%%%%%%%% transmiss_apply_cal %%%%%%%%%%
    case 'transmiss_apply_cal'  % not in jc159; added by bak for jc191
        %         function transout = transmiss_apply_cal(stn,trans)
        % trans_fac is the max of raw transmittance in the cleanest part of the water column, for groups of stations
        % it is a scaling factor, so divide percent by 100
        trans_fac = 1;
        if stn >=  1 & stn <= 13; trans_fac = 1.015; end % trans_fac = max of raw trans for these stations
        if stn >= 14 & stn <= 60; trans_fac = 1.0134; end % trans_fac = max of raw trans for these stations
        if stn >= 61 & stn <= 61; trans_fac = 1.0105; end % trans_fac = max of raw trans for these stations
        if stn >= 62 & stn <= 66; trans_fac = 1.0116; end % trans_fac = max of raw trans for these stations
        % trans off for 67:70
        if stn >= 71 & stn <= 84; trans_fac = 1.0089; end % trans_fac = max of raw trans for these stations
        if stn >= 85 & stn <= 85; trans_fac = 1.0052; end % trans_fac = max of raw trans for these stations
        if stn >= 86 & stn <= 105; trans_fac = 1.0073; end % trans_fac = max of raw trans for these stations
        if stn >= 106 & stn <= 118; trans_fac = 1.0068; end % trans_fac = max of raw trans for these stations
        if stn >= 119 & stn <= 119; trans_fac = 0.997; end % trans_fac = max of raw trans for these stations
        if stn >= 120 & stn <= 999; trans_fac = 1.0005; end % trans_fac = max of raw trans for these stations
        transout = trans/trans_fac;
        %%%%%%%%%% end transmiss_apply_cal %%%%%%%%%%
        
        %%%%%%%%%% fluor_apply_cal %%%%%%%%%%
    case 'fluor_apply_cal'  % not in jc159; added by bak for jc191
        %         function fluorout = fluor_apply_cal(stn,fluor,press,time,temp)
        
        % fluor cal determined from Chl samples provided by Lukas
        fluor_fac = 1; fluor_off = 0;
        
        if stn >=  1 & stn <= 999; fluor_fac = 1.85; fluor_off = -0.02; end % fluor_fac = nanmedian of ratio of samples from chl max, stations 4 to 118
        % fluor off for 67:70
        if stn >= 67 & stn <= 70; fluor_fac = nan; end
        
        fluorout = (fluor + fluor_off) * fluor_fac;
        %%%%%%%%%% end fluor_apply_cal %%%%%%%%%%
        
    case 'temp_apply_cal'  % not in jc159; added by bak for jc191
        %         function tempout = temp_apply_cal(sensor,stn,press,time,temp)

        switch sensor
            case 1
                if ismember(stn,[1:74])
                    tempadj = (0.40 - 0.50*press/1000)/1000; % T11; Adjusted to agree with T22; 0.4 mdeg at surface and -0.5 mdeg per 100 dbar
                end
                if ismember(stn,[75:999])
                    tempadj = (0.60 - 0.00*press/1000)/1000; % T12; Adjusted to agree with T22
                end
            case 2
                if ismember(stn,[1:34])
                    tempadj = (2.42 - 0.13*press/1000)/1000; % T21; Adjusted to agree with T11
                end
                if ismember(stn,[35:999])
                    tempadj = 0;    % T22; accepted unchanged
                end
        end
        tempout = temp+tempadj;
        %%%%%%%%%% end temp_apply_cal %%%%%%%%%%
        
        %%%%%%%%%% tsgsal_apply_cal %%%%%%%%%%
    case 'tsgsal_apply_cal'
        switch oopt
            case 'saladj'
                mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
                switch MEXEC_G.Mship
                    case 'cook' % used on jc069
                        prefix = 'met_tsg';
                    case 'jcr'
                        prefix = 'oceanlogger';
                end
                root_tsg = mgetdir(prefix);
                fnsm = [root_tsg '/sdiffsm.mat'];
                % make sure sdiffsm exists with zero correction if not
                % already defined; this is so mtsg_medav_clean can work
                % before mtsg_bottle_compare. bak jc191
                if exist(fnsm,'file') ~= 2
                    t = [-1e9 ; 1e9];
                    sdiffsm = [0 ; 0];
                    save(fnsm,'t','sdiffsm')
                end
                if time==1 & salin==1; 
                    salout = 1; 
                else
                    load([root_tsg '/sdiffsm'])
                    salout = salin + interp1([0 t(:)' 1e3],[sdiffsm(1) sdiffsm(:)' sdiffsm(end)],time/86400); % interpolate/extrapolate correction                end
                end
                %%%%%%%%%% end tsgsal_apply_cal %%%%%%%%%%
        end % check this
        
        %%%%%%%%%% msim_plot %%%%%%%%%%
    case 'msim_plot'
        switch oopt
            case 'sbathy'
                bfile = '/data/pstar/jc159/data/ubak/planning/topo/GMRTv3_5_201802200908topo.mat';
                bfile = '/data/pstar/dy040/backup_20160123160346/data/ubak/planning/n_atlantic.mat';
                bfile = '/local/users/pstar/programs/general_sw/topo_grids/topo_jc191_2020/GMRTv3_7_20200110topo_1954metres.mat';
        end
        %%%%%%%%%% end msim_plot %%%%%%%%%%
        
        %%%%%%%%%% mem120_plot %%%%%%%%%%
    case 'mem120_plot'
        switch oopt
            case 'sbathy'
                bfile = '/data/pstar/jc159/data/ubak/planning/topo/GMRTv3_5_201802200908topo.mat';
                bfile = '/data/pstar/dy040/backup_20160123160346/data/ubak/planning/n_atlantic.mat';
        end
        %%%%%%%%%% end mem120_plot %%%%%%%%%%
        
        %%%%%%%%%% mtsg_01 %%%%%%%%%%
    case 'mtsg_01'
        switch oopt
            case 'flag'
                %	    flag(ismember(ds_sal.sampnum, [])) = 3; %questionable
        end
        %%%%%%%%%% end mtsg_01 %%%%%%%%%%
        
        %%%%%%%%%% mtsg_bottle_compare %%%%%%%%%%
    case 'mtsg_bottle_compare'
        switch oopt
            case 'dbbad'
                %	    db.salinity_adj(72) = NaN; %bad comparison point
            case 'sdiff'
                sc1 = 0.02;
                sc2 = 5e-3;
            case 'usecal'
                usecal = 1;
        end
        %%%%%%%%%% end mtsg_bottle_compare %%%%%%%%%%
        
        %%%%%%%%%% mtsg_cleanup %%%%%%%%%%
    case 'mtsg_cleanup'
        switch oopt
            case 'kbadlims' %times when pumps off
                kbadlims = {
                    datenum([2020 01 00 00 00 00]) datenum([2020 01 19 22 38 00]) 'all' % start of jc191
                    datenum([2020 01 28 15 42 00]) datenum([2020 01 28 16 19 00]) 'all' % pumps off
                    datenum([2020 02 04 15 54 00]) datenum([2020 02 04 16 35 00]) 'all' % pumps off
                    datenum([2020 02 10 18 51 00]) datenum([2020 02 10 19 27 00]) 'all' % pumps off
                    datenum([2020 02 17 15 28 00]) datenum([2020 02 17 16 24 00]) 'all' % pumps off
                    datenum([2020 02 23 11 39 00]) datenum([2020 02 23 12 13 00]) 'all' % pumps off
                    datenum([2020 02 29 14 55 00]) datenum([2020 03 31 00 00 00]) 'all' % pumps off end of cruise
                    %hobnobs are for cheesecake
                    };
        end
        %%%%%%%%%% end mtsg_cleanup %%%%%%%%%%
        
        
        %%%%%%%%%% mout_cchdo_sam %%%%%%%%%%
    case 'mout_cchdo_sam'
        switch oopt
            case 'expo'
                expocode = '740H20200119';
                sect_id = 'A05_24N';
            case 'nocfc'
                nocfc = 1;
%                 d.cfc11(:) = NaN; d.cfc12(:) = NaN; d.f113(:) = NaN; d.ccl4(:) = NaN; d.sf6(:) = NaN; d.sf5cf3(:) = NaN;
            case 'fluor_trans' % added bak jc191 to switch on or off the output of CTD trans and fluor
                fluor_trans = 0; % CTD fluor and trans is output; zero to switch off output.
            case 'printorder'
                printorder = {'first_bottle_first' 'first_bottle_last'}; % later in jc191 can now do both in one run; set them up as a cell array
%                 printorder = 'first_bottle_first' ; % for carbon and oxygen
%                 printorder = 'first_bottle_last';  % for nutrients
            case 'outfile'
                outfile = [MEXEC_G.MEXEC_DATA_ROOT '/collected_files/A05_' expocode];
                if nocfc
                   outfile = [outfile '_no_cfc_values'];
                end
                outfile = [outfile '_' printorder];
                if fluor_trans == 1
                    outfile = [outfile '_fluor_trans'];
                end
                
            case 'headstr'
                headstring = {['BOTTLE,' datestr(now,'yyyymmdd') 'OCPNOCBAK'];...
                    '#SHIP: James Cook';...
                    '#Cruise JC191; A05 24N';...
                    '#Region: North Atlantic';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20200119 - 20200301';...
                    '#Chief Scientist: A. Sanchez Franks, NOC';...
%                     '#Supported by NERC NE/N018095/1 (ORCHESTRA) and NERC NE/P019064/1 (TICTOC)';...
%                     '#121 stations with 24-place rosette';...
%                     '#CTD: Who - B. KING; Status - final';...
                    '#CTD: Who - B. KING; Status - final';...
%                     '#CTD: Who - B. KING; Status - uncalibrated';...
                    '#Notes: Includes CTDSAL, CTDOXY';...
                    '#The CTD PRS;  TMP;  SAL; OXY data are all calibrated and good.';...
%                     '#The CTD PRS;  TMP;  SAL; OXY data are all uncalibrated.';...
                    '#Salinity: Who - K. Grayson/B. King; Status - final';...
%                     '#Notes: bottle salinity from stations 1-122 used for CTD calibration';...
%                     '#Oxygen and Nutrients: Who - E. Mawji; Status - final';...
                    '#Oxygen and Nutrients: Who - E. Mawji; Status - end of cruise';...
%                     '#Notes: bottle oxygen from stations 35-123 used for CTD calibration';...
%                     '#DIC and Talk: Who - P. Brown; Status - final ';...
                    '#DIC and Talk: Who - P. Brown; Status - end of cruise ';...
%                     '#CFCs and SF6: Who - M.J. Messias; Status - uncalibrated, proprietary ';...
%                     '#C14/13: Who: A. McNichol; Status - final (data rcd 2019/03/11 from J. Lester)';...
%                     '#O18: Who: M. Leng, M. Meredith; Status - final';...
                    '#The A05 section consists of stations [2:13] [14:20 22:24 26:27 29:94 96:130 132:135] ';...
                    '#Notes:';...
                    '#These data should be acknowledged with: "Data were collected and made publicly available by the international Global Ship-based Hydrographic Investigations Program (GO-SHIP; http://www.go-ship.org/) with funding from the UK Natural Environment Research Council to the National Oceanography Centre."'};
        end
        %%%%%%%%%% end mout_cchdo_sam %%%%%%%%%%
        
        %%%%%%%%%% mout_cchdo_ctd %%%%%%%%%%
    case 'mout_cchdo_ctd'
        switch oopt
            case 'expo'
                expocode = '740H20200119';
                sect_id = 'A05';
            case 'outfile'
                outfile = [MEXEC_G.MEXEC_DATA_ROOT '/collected_files/A05_' expocode '_ct1/A05_' expocode];
                outfileall = [MEXEC_G.MEXEC_DATA_ROOT '/collected_files/ctd_with_fluor/A05_' expocode '_fluor'];
            case 'headstr'
                headstring = {['CTD,' datestr(now,'yyyymmdd') 'OCPNOCBAK'];...
                    '#SHIP: James Cook';...
                    '#Cruise JC191; A05 24N';...
                    '#Region: North Atlantic';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20200119 - 20200301';...
                    '#Chief Scientist: A. Sanchez Franks, NOC';...
%                     '#Supported by NERC NE/N018095/1 (ORCHESTRA)';...
                    '#135 stations with 24-place rosette';...
                    '#CTD: Who - B. King; Status - final';...
                    '#Notes: Includes CTDSAL, CTDOXY';...
                    '#The CTD PRS;  TMP;  SAL; OXY data are all calibrated and good.';...
                    '#DEPTH_TYPE   : COR';...
                    '#The A05 section consists of stations [2:13] [14:20 22:24 26:27 29:94 96:130 132:135] ';...
                    '#These data should be acknowledged with: "Data were collected and made publicly available by the international Global Ship-based Hydrographic Investigations Program (GO-SHIP; http://www.go-ship.org/) with National Capability funding from the UK Natural Environment Research Council to the National Oceanography Centre."'};
                %case 'flags'
                %    if stn<10 & strcmp(newname, 'CTDFLUOR_FLAG_W')
                %        data(data==2 & d.press>1000) = 3;
                %    end
        end
        %%%%%%%%%% end mout_cchdo_ctd %%%%%%%%%%
        
        %%%%%%%%%% msec_run_mgridp %%%%%%%%%%
    case 'msec_run_mgridp'
        switch oopt
            case 'sections'
                sections = {'fs27n' '24n'};
%                 sections = {'fs27n'}; 
                sections = {'24n'}; % note: if you change the section you want, you need to clear 'sections'; otherwise the code doesnt check cropt.
                clear gstart
            case 'varlist'
                varlist = [varlist ' fluor transmittance '];
            case 'kstns'
                switch section
                    case 'fs27n'
                        sstring = '[2:13]';
                    case '24n'
                        sstring = '[14:20 22:24 26:27 29:94 96:130 132:135]'; % 131 = bulk water station 95 = bulk sample; 21 = carbon blanks; 25=26; 28=lukas surface sample
                end
            case 'varuse'
                varuselist.names = {'botoxy' 'totnit_per_kg' 'phos_per_kg' 'silc_per_kg' 'dic' 'alk' 'cfc11'  'cfc12' 'f113' 'sf6' 'ccl4'};
                varuselist.names = {'botpsal' 'botoxy' 'totnit_per_kg' 'phos_per_kg' 'silc_per_kg' 'dic' 'alk' 'totnit' 'phos' 'silc'};
%                 varuselist.names = {'botoxy' 'silc'};
        end
        %%%%%%%%%% end msec_run_mgridp %%%%%%%%%%
        
        %%%%%%%%%% msec_plot_contours_set_clev_col %%%%%%%%%%
    case 'msec_plot_contours_set_clev_col'
        % set options for colours and contours that depart from the WOCE
        % atlas 'defaults'
        % there should be a field c.section to enable different contours on
        % different sections.
        switch oopt
            case 'potemp'
                switch c.section
                    case '24n'
                        c.clev = [c.clev 22 23 24 1:.1:2];
                        cbound = cbound; % no change; here as a placeholder only.
                        cols = cols; % no change
                    case 'fs27n'
                        c.clev = [c.clev 22 23 24];
                end
            case 'psal'
                c.clev = [c.clev 36.25 36.75];
            case 'oxygen'
                c.clev = [c.clev 100 110 120 130 140];
            case 'fluor'
                c.clev = [c.clev];
            case 'silc'
                c.clev = [c.clev];
            case 'phos'
                c.clev = [c.clev];
            case 'totnit'
                c.clev = [c.clev];
            case 'dic'
                c.clev = [c.clev];
            case 'alk'
                c.clev = [c.clev];
            case 'cfc11'
                c.clev = [c.clev];
            case 'cfc12'
                c.clev = [c.clev];
            case 'f113'
                c.clev = [c.clev];
            case 'ccl4'
                c.clev = [c.clev];
            case 'sf6'
                c.clev = [c.clev];
        end
        %%%%%%%%%% end msec_plot_contours_set_clev_col %%%%%%%%%%
        
        %%%%%%%%%% m_maptracer %%%%%%%%%%
    case 'm_maptracer'
        switch oopt
            case 'kstatgroups'
                % jc191 Florida St and main section; each array is a set of stations that can be used for mapping
                kstatgroups = {[2:13] [14:20 22:24 26:27 29:94 96:130 132:135]};
            case 'xzlim'
%defaults
case 'scales_xz'
%defaults
            case 'samfn'
%                 samfn = [root_ctd '/sam_' MEXEC_G.MSCRIPT_CRUISE_STRING '_all' ];
                samfn = [root_ctd '/sam_' MEXEC_G.MSCRIPT_CRUISE_STRING '_all_nutkg' ];
        end
        %%%%%%%%%% end m_maptracer %%%%%%%%%%
        
        %%%%%%%%%% station_summary %%%%%%%%%%
    case 'station_summary'
        switch oopt
            case 'optsams'
%                 snames = {'noxy'; 'nnut'; 'nco2'; 'ncfc'; 'no18s'; 'nc13s'; 'nchls'}; % Use s suffix for variable to count number on ship for o18 c13 chl, which will be zero
                snames = {'noxy'; 'nnut'; 'nco2'; 'nchla' ; 'nch4'}; % Use s suffix for variable to count number on ship for o18 c13 chl, which will be zero
                snames_shore = {'noxy_shore'; 'nnut_shore'; 'nco2_shore'; 'nchla_shore' ; 'nch4_shore' ; 'ndel13c_noc_shore' ; 'ndel14c_shore'}; % can use name without _shore, because all samples are analysed ashore
                sgrps = { {'botoxy'} %list of oxy variables
                    {'silc' 'phos' 'totnit'} %list of nuts variables
                    {'dic' 'talk'} %list of co2 variables
                    %                     {'cfc11' 'cfc12' 'f113' 'sf6' 'ccl4' 'sf5cf3' 'cfc13'} %list of cfc variables
                    %                     {'del18o_bgs'} % BGS del O 18
                    %                     {'del13c_imp' 'del14c_imp' 'del13c_whoi' 'del14c_whoi'} % All delC13  delC14 except BGS
                    {'chla'}
                    {'ch4'}
                    {'del13c_noc'}
                    {'del13c_imp' 'del14c_imp' 'del13c_whoi' 'del14c_whoi'}
                    };
                sashore = [0; 1; 1; 1; 1; 1; 1]; %count samples to be analysed ashore? % can't presently count botoxy_flag == 1
            case 'comments' % set comments
                comments{1}  = 'Test station';
                comments{2}  = 'Start of Florida St';
                comments{13} = 'End of Florida St';
                comments{14} = 'Start of main section; heave compensator on';
                comments{18} = 'no LADCP data';
                comments{21} = 'Carbon bulk sample';
                comments{23} = 'Start of alternating (A/B) stations';
                comments{26} = 'Data acquisition fault on 025';
                comments{28} = 'WHOI Incubation bulk sample';
                comments{31} = 'Niskins at 1:5 and 10:24 switched for 10L';
                comments{34} = 'Temp2 sensor swapped after station?';
                comments{41} = 'SBE35 installed';
                comments{67} = 'Deep tow wire; some instruments off';
                comments{68} = 'Deep tow wire; some instruments off';
                comments{69} = 'Deep tow wire; some instruments off';
                comments{70} = 'Deep tow wire; some instruments off';
                comments{95} = 'Bulk water station';
                comments{131} = 'Bulk water station';
%                 comments{113} = 'Bulk water station';
%                 comments{125} = 'Test station for video recording; CTD 1';
            case 'alttimes' % impose start and end times not captured from CTD dcs files
%                 dns(1) = datenum([2018 03 01 12 35 00]); % Swivel test; times from winch data
%                 dnb(1) = datenum([2018 03 01 13 39 00]);
%                 dne(1) = datenum([2018 03 01 14 33 00]);
%                 dns(2) = datenum([2018 03 01 14 48 00]); % Swivel test; times from winch data
%                 dnb(2) = datenum([2018 03 01 15 45 00]);
%                 dne(2) = datenum([2018 03 01 16 34 00]);
%                 dne(27) = datenum([2018 03 07 13 38 00]);
%                 dne(28) = datenum([2018 03 07 22 31 00]);
%                 lat(1) =  -23.74599;
%                 lon(1) =  -40.31568;
%                 lat(2) =  -23.74601;
%                 lon(2) =  -40.31571;
            case 'altdep'
%                 cordep(1) = 2859; maxw(1) = 2500.1; % cordep from station 3
%                 cordep(2) = 2859; maxw(2) = 2500.1; % cordep from station 3
%                 cordep(27) = 5063; maxw(27) = 661.5; % cordep from station 29
%                 cordep(28) = 5063; maxw(28) = 125.0; % cordep from station 29
%                 cordep(63) = 4419; % from CTD + alt; ladcp IX estimate is poor.
%                 cordep(77) = 4972; % from CTD + alt; ladcp IX estimate is poor.
%                 cordep(78) = 5244; % from CTD + alt; ladcp IX estimate is poor.
%                 cordep(124) = 3624; % from em122; 10m dip for surface bulk water samples
%                 cordep(125) = 204; % from em122; 10m dip for go-pro video of bottles closing
                minalt(1) = -9; % 
                minalt(14) = -9; % 
                minalt(15) = -9; % 
                minalt(16) = -9; % 
                minalt(17) = -9; % 
                minalt(18) = -9; % 
%                 minalt(54) = 83; % from LADCP; No good reading from altimeter.
            case 'parlist'
%                 parlist = [' sal'; ' oxy'; ' nut'; ' car'; ' co2'; ' cfc'; ' ch4'];
                parlist = [' sal'; ' oxy'; ' nut'; ' car'; ' co2'; ' cfc'; ' ch4'];
            case 'varnames'
%                 varnames={'statnum' 'time_start' 'time_bottom' 'time_end' 'lat' 'lon' 'cordep' 'maxd' 'minalt' 'resid' 'maxw' 'maxp' 'ndpths' 'nsal' 'noxy' 'nnut' 'nco2' 'ncfc' 'no18' 'nc13' 'nchl'};
%                 varunits={'number' 'seconds' 'seconds' 'seconds' 'degrees' 'degrees' 'metres' 'metres' 'metres' 'metres' 'metres' 'dbar' 'number' 'number' 'number' 'number' 'number' 'number' 'number' 'number' 'number'};
                varnames={'statnum' 'time_start' 'time_bottom' 'time_end' 'lat' 'lon' 'cordep' 'maxd' 'minalt' 'resid' 'maxw' 'maxp' 'ndpths' 'nsal' 'noxy' 'nnut' 'nco2' 'nchla' 'ndel13c_noc_shore' 'ndel14c_shore' 'nch4_shore'};
                varunits={'number' 'seconds' 'seconds' 'seconds' 'degrees' 'degrees' 'metres' 'metres' 'metres' 'metres' 'metres' 'dbar' 'number' 'number' 'number' 'number' 'number' 'number' 'number' 'number' 'number'};
            case 'stnmiss'
                stnmiss = [25];
            case 'stnadd'
%                 stnadd = [1 2 ]; % force add of these stations to station list
        end
        %%%%%%%%%% end station_summary %%%%%%%%%%
        
        
        %%%%%%%%%% mvad_01 %%%%%%%%%%
    case 'mvad_01'
        switch oopt
            case 'files'
                cname = 'jc191_02';
                pre1 = ['postprocessing/' cname '/proc_archive/' inst nbbstr]; %link here to version you want to use (spprocessing or postprocessing)
                datadir = [root_vmadcp '/' pre1 '/contour'];
                fnin = [datadir '/' inst nbbstr '.nc'];
                dataname = [inst nbbstr '_' mcruise '_01'];
                %*** station 123?
        end
        %%%%%%%%%% end mvad_01 %%%%%%%%%%
        
        %%%%%%%%%% mday_01_clean_av %%%%%%%%%%
    case 'mday_01_clean_av'
        switch oopt
            case 'surflight_factors'
                
                % bak jc191. This is the sensitivity provided by the manufacturer's cal.
                % The sensitivity number is a factor used to DIVIDE the raw counts to
                % get output in W/m2. The number is usually around 10. Techsas scales
                % the output of the sensor by a nominal 10, so Techsas output is the
                % correct order of magnitude. So if the sensitivity scaling is 10.5,
                % then the correct adjustment at this stage is divide by 1.05
                
                % set as many lines of scaling factor as needed in cropt
                % if a sensor doesn't have a line of scaling info, it will be left
                % unchanged.
                % Each line will be applied, in sequence. If the start and end times
                % overlap, a datacycle will be adjusted twice.
                % If a line is repeated, it will be applied twice.
                %
                % adjustment is for start <= time < end
                %
                % add to the allfactors array in cropt, eg
                %
                %       morefactors = {
                %       'ppar' 1.1 [2020 1 1 0 0 0] [2020 1 2 0 0 0]
                %       'spar' 1.1 [2020 1 1 0 0 0] [2020 1 2 0 0 0]
                %       };
                %       allfactors = [allfactors; morefactors];
                
                morefactors = {
                    'spar' 0.986 [2020 1 1 0 0 0] [2021 1 1 0 0 0]
                    'ppar' 1.015 [2020 1 1 0 0 0] [2021 1 1 0 0 0]
                    'stir' 0.961 [2020 1 1 0 0 0] [2021 1 1 0 0 0]
                    'ptir' 1.073 [2020 1 1 0 0 0] [2021 1 1 0 0 0]
                    };
                allfactors = [allfactors; morefactors];
        end
        %%%%%%%%%% end mday_01_clean_av %%%%%%%%%%
        
        %%%%%%%%%% msec_plot_contrs %%%%%%%%%%
    case 'msec_plot_contrs'
        switch oopt
            case 'add_station_depths'
                % bak jc191. control adding station depths to contour plots
                % gretaer than zero adds to the plot with linewidth set
                % here. suggest 3
                station_depth_width = 3; % default is zero for not adding
            case 'add_bottle_depths'
                % bak jc191. control adding bottle positions to contour plots
                % greater than zero adds to the plot with markersize given here
                % suggest 3. Size in plot not the same as it appears on
                % screen
                bottle_depth_size = 3; % default is zero for not adding
        end
        %%%%%%%%%% end msec_plot_contrs %%%%%%%%%%
        
        
end
