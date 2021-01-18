switch scriptname
    
        %%%%%%%%%% smallscript %%%%%%%%%%
    case 'smallscript'
        switch oopt

        end
        %%%%%%%%%% end smallscript %%%%%%%%%%
        
        
        %%%%%%%%%% mctd_01 %%%%%%%%%%
    case 'mctd_01'
        switch oopt

        end
        %%%%%%%%%% end mctd_01 %%%%%%%%%%
        
        %%%%%%%%%% mctd_02a %%%%%%%%%%
    case 'mctd_02a'
        switch oopt
            case 'absentvars' % introduced new on jc191

            case 'corraw'
                % pvars is a list of variables to NaN when pumps are off, with the
                % second column setting the number of additional scans after the
                % pumps come back on to also NaN
                pvars = {'temp1' 12
                    'temp2' 12
                    'cond1' 12
                    'cond2' 12
                    'oxygen_sbe1' 8*24 
                    'oxygen_sbe2' 8*24               
                    };
				% Remove out of range variables
                revars = {'press' -10 8000
                    'temp1' -2 32
                    'temp2' -2 32
                    'cond1' 25 60
                    'cond2' 25 60
                    'oxygen_sbe1' 0 400
                    'oxygen_sbe2' 0 400
                    };
				% Despike variables and thresholds for each pass
                dsvars = {'press' 3 2 2
                    'temp1' 1 0.5 0.5
                    'temp2' 1 0.5 0.5
                    'cond1' 1 0.5 0.5
                    'cond2' 1 0.5 0.5
                    'oxygen_sbe1' 3 2 2
                    'oxygen_sbe1' 3 2 2     
                    'pressure_temp' 0.1 0.1 0.1
                    };
				% Allign (5 scans)
                ovars = {['oxygen_sbe1'
                          'oxygen_sbe2']};
        end
        %%%%%%%%%% end mctd_02a %%%%%%%%%%
        
        %%%%%%%%%% mctd_02b %%%%%%%%%%
    case 'mctd_02b'
        switch oopt
		case 'calibs_to_do'
                dooxyhyst = 1;
		case 'oxyhyst'

        end
        %%%%%%%%%% end mctd_02b %%%%%%%%%%
        
        %%%%%%%%%% mcoxyhyst %%%%%%%%%%
    case 'mcoxyhyst'
        %%%%%%%%%% end mcoxyhyst %%%%%%%%%%
%%%%        switch sensor
%%%%            case 1 % primary
%%%%                h3tab = [ % default
%%%%              	  -10 1450
%%%%             	   9000 1450
%%%%                    ];
%%%%        
%%%%        H3 = interp1(h3tab(:,1),h3tab(:,2),press);
        
        %%%%%%%%%% mctd_03 %%%%%%%%%%
    case 'mctd_03'
        switch oopt
            case 's_choice' %this applies to both t and c
                s_choice = 1;
            case 'o_choice' %this applies to oxygen
                o_choice = 1;
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
                % Serial numbers of bottles can be entered here
                
        end
        %%%%%%%%%% end mbot_00 %%%%%%%%%%

        %%%%%%%%%% mbot_01 %%%%%%%%%%
    case 'mbot_01'
        switch oopt
            case 'botflags'
% Set pairs "staion number","position number" for which set QC flags to 3,4 etc
% QC flag = 3
%                 flag3 = [0 0; 8 12; 10 5; 17 5; 29 12; 33 23]; % leaking (Woce table 4.8)
                flag3 = [0 0];
%
% QC flag = 4
%                 flag4 = [0 0; 2 5; 4 3; 4 16; 5 4; 5 20; 5 24; 6 2];
                flag4 = [0 0];
%
% QC flag = 9  - samples not drawn from this bottle (Woce table 4.8)
                flag9 = [0 0]; 
                iif = find(flag3(:,1)==stnlocal); if length(iif)>0; bottle_qc_flag(flag3(iif,2)) = 3; end
                iif = find(flag4(:,1)==stnlocal); if length(iif)>0; bottle_qc_flag(flag4(iif,2)) = 4; end
                iif = find(flag9(:,1)==stnlocal); if length(iif)>0; bottle_qc_flag(flag9(iif,2)) = 9; end
% 
% Or if every bottle on the stations has same flag
%               if ismember(stnlocal, [27 28 59 125]); bottle_qc_flag(:) = 9; end
        end
        %%%%%%%%%% end mbot_01 %%%%%%%%%%
		        
        %%%%%%%%%% mwin_01 %%%%%%%%%%
    case 'mwin_01'
        switch stnlocal
            case 0 % example from jc159
%%                winch_time_start = [2018 3 1 12 30 0]; % first swivel test
%%                winch_time_end = [2018 3 1 14 33 0];
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
                h = m_read_header(pshow2.ncfile.name); 
				if sum(strcmp('oxygen_sbe2', h.fldnam)); 
					pshow2.ylist = 'pressure_temp press oxygen_sbe1 oxygen_sbe2'; 
				end
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
                %msg = [datestr(now,31) ' jc159 CTD PSAL and Oxygen data uncalibrated' ];
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
%                depmeth = 3; % calculate from CTD depth and altimeter reading
            case 'bestdeps'
%                 ii = find(bestdeps(:,1)==2); bestdeps(ii,2) = 37; % from CTD+Altim
%                 ii = find(bestdeps(:,1)==3); bestdeps(ii,2) = 65; % from CTD+Altim
%                 ii = find(bestdeps(:,1)==4); bestdeps(ii,2) = 148; % from CTD+Altim

        end
        %%%%%%%%%% end populate_station_depths %%%%%%%%%%
        
        %%%%%%%%%% msal_01 %%%%%%%%%%
    case 'msal_01'
        switch oopt
        case 'flags'
                flags3 = [0];
                flags4 = [0]; 
                flags5 = [0];
                flags9 = [0];
                flag(ismember(sampnum, flags3)) = 3;
                flag(ismember(sampnum, flags4)) = 4;
                flag(ismember(sampnum, flags5)) = 5;
                flag(ismember(sampnum, flags9)) = 9;
        end
        %%%%%%%%%% end msal_01 %%%%%%%%%%
        
        %%%%%%%%%% msal_standardise_avg %%%%%%%%%%
    case 'msal_standardise_avg'
        switch oopt
			case 'salcsv'
				sal_csv_file = ['sal_' mcruise '_01.csv'];
            case 'check_sal_runs'
                check_sal_runs = 1;
                calc_offset = 1;
            case 'k15'
                sswb = 163; %ssw batch
                msal_ssw
                ds_sal.K15 = zeros(size(ds_sal.sampnum));
                ds_sal.K15(iistd) = ssw_batches(ssw_batches(:,1)==sswb,2)/2;
            case 'cellT'
                ds_sal.cellT = 21+zeros(length(ds_sal.sampnum),1);
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
%%                ds_sal.sampnum = [ds_sal.sampnum; 999000];
%%                ds_sal.offset(end) = 0;
%%                ds_sal.runtime(end) = ds_sal.runtime(1)-1/60/24; %put it 1 minute before sample 1
        end
        %%%%%%%%%% msal_standardise_avg %%%%%%%%%%
        
        %%%%%%%%%% moxy_01 %%%%%%%%%%
    case 'moxy_01'
        switch oopt
            case 'oxyconc_recalc'
                oxyconc_recalc = 0;
            case 'oxycsv'
                %infile = [root_oxy '/oxy_jc159_all.csv'];
                infile = [root_oxy '/' 'oxy_' mcruise '_' sprintf('%03d',stnlocal) '.csv'];
            case 'sampnum_parse'
                ds_oxy.niskin = ds_oxy.botnum;
				ds_oxy.botoxya_per_l = ds_oxy.botoxya;
				ds_oxy.botoxyb_per_l = ds_oxy.botoxyb;
				ds_oxy.botoxyc_per_l = ds_oxy.botoxyc;		
            case 'flags'
%                 flags3 = [0];
%                 flags4 = [2017 2912 3112 3317 3323];
                flags3 = [0];
                flags4 = [0];
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

            case 'blstd'

            case 'botvols'
 
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
                %                 flags4 = [2001 2017 2701 2902 3112 3317 4716 5016 5612 5714 5716 5915 5916 7311 8211 11522 11805 12113];
                flags4 = [0];
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
            % select which cals get applied 
            % default at start of cruise is all switched off
            
            stations_temp = [];
            stations_cond = [];
            stations_oxy = [];
            stations_trans = [];
            stations_fluor = [];
            
            %             stations_temp = [1:999];
            %             stations_cond = [1:999];
            %             stations_oxy = [1:999];
            %             stations_trans = [1:999];
            %             stations_fluor = [1:999];
            
            apply_cals_temp = 0;
            apply_cals_cond = 0;
            apply_cals_oxy = 0;
            apply_cals_trans = 0;
            apply_cals_fluor = 0;
            
            if ismember(stnlocal,stations_temp); apply_cals_temp = 1; end
            if ismember(stnlocal,stations_cond); apply_cals_cond = 1; end
            if ismember(stnlocal,stations_oxy); apply_cals_oxy = 1; end
            if ismember(stnlocal,stations_trans); apply_cals_trans = 1; end
            if ismember(stnlocal,stations_fluor); apply_cals_fluor = 1; end
            
        end

        %%%%%%%%%% ctd_all_part1 %%%%%%%%%%
        
        %%%%%%%%%% cond_apply_cal %%%%%%%%%%
    case 'cond_apply_cal'
%% Need to set these times start of each CTD relative to the time of the first sample
	dayofctd = [ -0.057   0.136  0.799  1.215  1.427  1.692  2.168   2.265  2.359  5.303  6.581  8.052 8.855  9.025];  
        switch sensor
        case 1
	  off = ( 0.07554  - 0.00451*(time/86400 + dayofctd(stn)) - 0.00367*press/1000 - 0.00127*temp)/1000;
	case 2
	  off = ( 0.00105  - 0.00299*(time/86400 + dayofctd(stn)) - 0.00015 *press/1000 + 0.00043 *temp)/1000;
        end
        condadj = 0;	
        fac = 1 + off;
        condout = cond.*fac + condadj;        

	%%%%%%%%%% cond_apply_cal %%%%%%%%%%
        
        %%%%%%%%%% oxy_apply_cal %%%%%%%%%%
    case 'oxy_apply_cal'
        %         function oxyout = oxy_apply_cal(sensor,stn,press,time,temp,oxyin)
        alpha = 1; beta = 0;
        switch sensor
            case 1
                %                 o1rs_s = [ 0 20 70 106 ]; % station
                %                 o1rs_f = [  1.0441  1.0398  1.0588  1.0619 ]; % factor at stn 1 and stn 90
                %                 deps = [-10 2000:1000:6000 6600]; % don't use 1000 dbar; strong gradients
                %                 o1dfac = [0.9857    0.9980    1.0110    1.0189    1.0245    1.0259    1.0259]; % edit fac at 6600
%                 o1rs_s = [ 0 20 70 122 999  ];
%                 o1rs_f = [  1.0410  1.0410  1.0586  1.0627 1.0627  ]; % calculated with stations up to 116
% %                 o1rs_s = [ 0 20 70 122 135  ];
% %                 o1rs_f = [  1.0410  1.0410  1.0586  1.0663 1.0726  ]; % adjusted after 135
% %                 deps = [ -10 2000 3000 4000 5000 6000 6600  ];
% %                 o1dfac = [  0.9835  0.9959  1.0086  1.0170  1.0223  1.0268  1.0268  ]; % calculated with stations up to 116
% %                 o1rs_i = interp1(o1rs_s,o1rs_f,stn); % interpolate station factor and scale dep factor
% %                 o1dfac_p = interp1(deps,o1dfac,press);
% %                 
% %                 alpha = o1rs_i.*o1dfac_p;
% %                 beta = 0;
            case 2
                %                 o2rs_s = [ 0 20 70 106 ]; % station
                %                 o2rs_f = [  1.0320  1.0390  1.0664  1.0662 ]; % factor at stn 1 and stn 90
                %                 deps = [-10 2000:1000:6000 6600]; % don't use 1000 dbar; strong gradients
                %                 o2dfac = [0.9822    1.0016    1.0149    1.0210    1.0239    1.0209    1.0209]; % edit fac at 6600
                
%                 o2rs_s = [ 0 20 70 122  999 ];
%                 o2rs_f = [  1.0370  1.0370  1.0671  1.0654 1.0654  ]; % calculated after 116 and applied
% %                 o2rs_s = [ 0 20 70 122  135 ];
% %                 o2rs_f = [  1.0370  1.0370  1.0671  1.0693 1.0756  ]; % adjusted after 135
% %                 deps = [ -10 2000 3000 4000 5000 6000 6600  ];
% %                 o2dfac = [  0.9822  0.9996  1.0124  1.0186  1.0219  1.0212  1.0212  ];
% %                 o2rs_i = interp1(o2rs_s,o2rs_f,stn);
% %                 o2dfac_p = interp1(deps,o2dfac,press);
% %                 
% %                 alpha = o2rs_i.*o2dfac_p;
% %                 beta = 0;
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
        % % %         if stn >=  1 & stn <= 13; trans_fac = 1.015; end % trans_fac = max of raw trans for these stations
        % % %         if stn >= 14 & stn <= 60; trans_fac = 1.0134; end % trans_fac = max of raw trans for these stations
        % % %         if stn >= 61 & stn <= 61; trans_fac = 1.0105; end % trans_fac = max of raw trans for these stations
        % % %         if stn >= 62 & stn <= 66; trans_fac = 1.0116; end % trans_fac = max of raw trans for these stations
        % % %         % trans off for 67:70
        % % %         if stn >= 71 & stn <= 84; trans_fac = 1.0089; end % trans_fac = max of raw trans for these stations
        % % %         if stn >= 85 & stn <= 85; trans_fac = 1.0052; end % trans_fac = max of raw trans for these stations
        % % %         if stn >= 86 & stn <= 105; trans_fac = 1.0073; end % trans_fac = max of raw trans for these stations
        % % %         if stn >= 106 & stn <= 118; trans_fac = 1.0068; end % trans_fac = max of raw trans for these stations
        % % %         if stn >= 119 & stn <= 119; trans_fac = 0.997; end % trans_fac = max of raw trans for these stations
        % % %         if stn >= 120 & stn <= 999; trans_fac = 1.0005; end % trans_fac = max of raw trans for these stations
        transout = trans/trans_fac;
        %%%%%%%%%% end transmiss_apply_cal %%%%%%%%%%
        
        %%%%%%%%%% fluor_apply_cal %%%%%%%%%%
    case 'fluor_apply_cal'  % not in jc159; added by bak for jc191
        %         function fluorout = fluor_apply_cal(stn,fluor,press,time,temp)
        
        % fluor cal determined from Chl samples provided by Lukas
        fluor_fac = 1; fluor_off = 0;
        
        %         if stn >=  1 & stn <= 999; fluor_fac = 1.85; fluor_off = -0.02; end % fluor_fac = nanmedian of ratio of samples from chl max, stations 4 to 118
        %         % fluor off for 67:70
        %         if stn >= 67 & stn <= 70; fluor_fac = nan; end
        
        fluorout = (fluor + fluor_off) * fluor_fac;
        %%%%%%%%%% end fluor_apply_cal %%%%%%%%%%
        
    case 'temp_apply_cal'  % not in jc159; added by bak for jc191
        %         function tempout = temp_apply_cal(sensor,stn,press,time,temp)
        tempadj = 0;
        switch sensor
            case 1
                %                 if ismember(stn,[1:74])
                %                     tempadj = (0.40 - 0.50*press/1000)/1000; % T11; Adjusted to agree with T22; 0.4 mdeg at surface and -0.5 mdeg per 100 dbar
                %                 end
                %                 if ismember(stn,[75:999])
                %                     tempadj = (0.60 - 0.00*press/1000)/1000; % T12; Adjusted to agree with T22
                %                 end
            case 2
                %                 if ismember(stn,[1:34])
                %                     tempadj = (2.42 - 0.13*press/1000)/1000; % T21; Adjusted to agree with T11
                %                 end
                %                 if ismember(stn,[35:999])
                %                     tempadj = 0;    % T22; accepted unchanged
                %                 end
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
%                 bfile = '/data/pstar/jc159/data/ubak/planning/topo/GMRTv3_5_201802200908topo.mat';
%                 bfile = '/data/pstar/dy040/backup_20160123160346/data/ubak/planning/n_atlantic.mat';
                bfile = '/local/users/pstar/programs/general_sw/topo_grids/topo_jc191_2020/GMRTv3_7_20200110topo_1954metres.mat';
        end
        %%%%%%%%%% end msim_plot %%%%%%%%%%
        
        %%%%%%%%%% mem120_plot %%%%%%%%%%
    case 'mem120_plot'
        switch oopt
            case 'sbathy'
%                 bfile = '/data/pstar/jc159/data/ubak/planning/topo/GMRTv3_5_201802200908topo.mat';
%                 bfile = '/data/pstar/dy040/backup_20160123160346/data/ubak/planning/n_atlantic.mat';
                bfile = '/local/users/pstar/programs/general_sw/topo_grids/topo_jc191_2020/GMRTv3_7_20200110topo_1954metres.mat';
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
%                db.salinity_adj(72) = NaN; % outlier
            case 'sdiff'
                sc1 = 0.02;
                sc2 = 5e-3;
            case 'usecal'
                usecal = 0;
        end
        %%%%%%%%%% end mtsg_bottle_compare %%%%%%%%%%
        
        %%%%%%%%%% mtsg_cleanup %%%%%%%%%%
    case 'mtsg_cleanup'
        switch oopt
            case 'kbadlims' %times when pumps off
                kbadlims = {
                            datenum([2020 3 23 8 39 0]) datenum([2020 3  28 23 59 0]) 'all' % TSG turned off for Spanish waters, offset when turned back on again.
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
                fluor_trans = 1; % CTD fluor and trans is output; zero to switch off output.
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
            case 'xlim'
                flaglim = 2; % default 2; highest flag to be used for gridding
                s.xlim = 2; % default 1; width of gridding window, +/- xlim, measured in statnum
                s.zlim = 4; % default 4; vertical extent of gridding window measured in plev
                % bak jc191 reset s.xlim and s.zlim in a cruise option.
                % s.xlim and s.zlim are the half-width of the number of points used in the
                % local fit. ie s.xlim = 1 means three stations used. This one and one
                % either side.
                %
            case 'scales_xz'
                % bak jc191 feb 2020 . scale_x and scale_z are scalings on the distances xu and zu.
                % xu and zu measure the distance away in counts of stations for x and
                % levels for z. s.xlim and s.zlim control the number of stations/levels
                % included. scale_x and scale_z control the relative importance of
                % those distances in the weight. So low values of scale_x and scale_z
                % make the map smoother by not reducing the weight of more distant points.
                % High values of scale_x and scale_z give high weight to nearby points
                % and low weight to distant points. Default for scale_x and scale_z is
                % unity, unless changed in opt_cruise.
                scale_x = 0.5; % choose value < 1 for smoother
                scale_z = 1;
                % %     xu = xu*scale_x; % appears in m_maptracer
                % %     zu = zu*scale_z;
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
%                 comments{1}  = 'Test station';
%                 comments{2}  = 'Start of Florida St';
%                 comments{13} = 'End of Florida St';
%                 comments{14} = 'Start of main section; heave compensator on';
%                 comments{18} = 'no LADCP data';
%                 comments{21} = 'Carbon bulk sample';
%                 comments{23} = 'Start of alternating (A/B) stations';
%                 comments{70} = 'Deep tow wire; some instruments off';
%                 comments{95} = 'Bulk water station';
            case 'alttimes' % impose start and end times not captured from CTD dcs files
%                 dns(1) = datenum([2018 03 01 12 35 00]); % Swivel test; times from winch data
%                 dnb(1) = datenum([2018 03 01 13 39 00]);
%                 dne(1) = datenum([2018 03 01 14 33 00]);
%                 dne(27) = datenum([2018 03 07 13 38 00]);
%                 dne(28) = datenum([2018 03 07 22 31 00]);
%                 lat(1) =  -23.74599;
%                 lon(1) =  -40.31568;
            case 'altdep'
%                 cordep(1) = 2859; maxw(1) = 2500.1; % cordep from station 3
%                 cordep(63) = 4419; % from CTD + alt; ladcp IX estimate is poor.
%                 cordep(125) = 204; % from em122; 10m dip for go-pro video of bottles closing
%                 minalt(18) = -9; % 
%                 minalt(54) = 83; % from LADCP; No good reading from altimeter.
            case 'parlist'
%                 parlist = [' sal'; ' oxy'; ' nut'; ' car'; ' co2'; ' cfc'; ' ch4'];
                parlist = [' sal'; ' oxy'; ' nut'; ' car'; ' co2'; ' cfc'; ' ch4'];
            case 'varnames'
%                 varnames={'statnum' 'time_start' 'time_bottom' 'time_end' 'lat' 'lon' 'cordep' 'maxd' 'minalt' 'resid' 'maxw' 'maxp' 'ndpths' 'nsal' 'noxy' 'nnut' 'nco2' 'ncfc' 'no18' 'nc13' 'nchl'};
%                 varunits={'number' 'seconds' 'seconds' 'seconds' 'degrees' 'degrees' 'metres' 'metres' 'metres' 'metres' 'metres' 'dbar' 'number' 'number' 'number' 'number' 'number' 'number' 'number' 'number' 'number'};
                varnames={'statnum' 'time_start' 'time_bottom' 'time_end' 'lat' 'lon' 'cordep' 'maxd' 'minalt' 'resid' 'maxw' 'maxp' 'ndpths' 'nsal' 'noxy' };
                varunits={'number' 'seconds' 'seconds' 'seconds' 'degrees' 'degrees' 'metres' 'metres' 'metres' 'metres' 'metres' 'dbar' 'number' 'number' 'number' };
            case 'stnmiss'
%                 stnmiss = [25];
                stnmiss = [];
            case 'stnadd'
%                 stnadd = [1 2 ]; % force add of these stations to station list
        end
        %%%%%%%%%% end station_summary %%%%%%%%%%
        
        
        %%%%%%%%%% mvad_01 %%%%%%%%%%
    case 'mvad_01'
        switch oopt
            case 'files'
                cname = [mcruise '_01'];
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
%                     'spar' 0.986 [2020 1 1 0 0 0] [2021 1 1 0 0 0]
%                     'ppar' 1.015 [2020 1 1 0 0 0] [2021 1 1 0 0 0]
%                     'stir' 0.961 [2020 1 1 0 0 0] [2021 1 1 0 0 0]
%                     'ptir' 1.073 [2020 1 1 0 0 0] [2021 1 1 0 0 0]
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
