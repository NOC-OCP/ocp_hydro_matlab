switch scriptname
    
    %%%%%%%%%% ctd_evaluate_sensors %%%%%%%%%%
    case 'ctd_evaluate_sensors'
        switch oopt
            case {'tsensind','csensind'}
                if sensnum==1 | sensnum==2; sensind = {find(d.statnum >= 1 & d.statnum <= 999)}; end
            case 'osensind'
                sensind(1,1) = {find(d.statnum<=23)}; %first oxy
                sensind(2,1) = {find(d.statnum>=24)}; %second oxy
        end
        %%%%%%%%%% end ctd_evaluate_oxygen %%%%%%%%%%
        
        %%%%%%%%%% temp_apply_cal %%%%%%%%%%
    case 'temp_apply_cal'
        switch sensor
            case 1
                tempadj = 1.7e-3-0.1e-3*stn;
                tempout = temp+tempadj;
            case 2
                tempadj = 2.7e-3-0.1e-3*stn;
                tempout = temp+tempadj;
        end
        %%%%%%%%%% end temp_apply_cal %%%%%%%%%%
        
        %%%%%%%%%% cond_apply_cal %%%%%%%%%%
    case 'cond_apply_cal'
        switch sensor
            case 1
                off = (-0.45 - 0.12*(stn-15) + interp1([0 4500 5000], [.1 -.4 0], press))*1e-3;
                fac = off/35 + 1;
                condadj = 0;
            case 2
                off = (-2.78 - 0.09*(stn-15) + interp1([0 500 5000], [.4 -.2 0], press))*1e-3;
                fac = off/35 + 1;
                condadj = 0;
        end
        condout = cond.*fac;
        condout = condout+condadj;
        %%%%%%%%%% end cond_apply_cal %%%%%%%%%%
        
        %%%%%%%%%% oxy_apply_cal %%%%%%%%%%
    case 'oxy_apply_cal'
        if stn<=23
            alpha = 1.0427 - 4e-4*stn;
            beta = 3.1262 + 12e-4*press;
        elseif stn>=24
            alpha = 1.3317 - 104e-4*stn;
            beta = 15.0859; %not enough samples (particularly as these are on cont. slope) to resolve pressure dependence
        end
        oxyout = alpha.*oxyin + beta;
        %      oxyout = (oxyin - beta)./alpha; %use this line to undo the one above
        %%%%%%%%%% end oxy_apply_cal %%%%%%%%%%
        
        
        %%%%%%%%%% mbot_00 %%%%%%%%%%
    case 'mbot_00'
        switch oopt
            case 'nbotfile' %***only mbot_01 is called on jr16002, reading in this file
                otfile = fullfile(root_botcnv, 'log_samp_jr16002_all.txt');
        end
        %%%%%%%%%% end mbot_00 %%%%%%%%%%
        
        
        %%%%%%%%%% mout_cchdo_sam %%%%%%%%%%
    case 'mout_cchdo_sam'
        switch oopt
            case 'expo'
                expocode = '74JC20161110';
                sect_id = 'SR1b';
            case 'outfile'
                outfile = fullfile(MEXEC_G.MEXEC_DATA_ROOT, 'collected_files' ['sr1b_' expocode]);
            case 'headstr'
                headstring = {['BOTTLE,' datestr(now,'yyyymmdd') 'OCPNOCYLF'];...
                    '#SHIP: James Clark Ross';...
                    '#Cruise JR16002; SR1B';...
                    '#Region: Drake Passage; ~56W';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20161110 - 20161103';...
                    '#Chief Scientist: Y. Firing, NOCS';...
                    '#Supported by NERC National Capability NE/N018095/1 (ORCHESTRA)';...
                    '#30 stations with 24-place rosette';...
                    '#CTD: Who - Y. Firing; Status - final';...
                    '#Notes: Includes CTDSAL, CTDOXY, SBE35';...
                    '#The CTD PRS;  TMP;  SAL; OXY data are all calibrated and good.';...
                    '#Flags in bottle file set to good for all existing values';...
                    '#CTD files also contain CTDXMISS, CTDFLUOR, CTDTURB';...
                    '#Salinity: Who - Y. Firing; Status - final';...
                    '#Notes:';...
                    '#Oxygen: Who - Y. Firing; Status - final';...
                    '#Notes:';...
                    '#These data should be acknowledged with: "Data were collected and made publicly available by the International Global Ship-based Hydrographic Investigations Program (GO-SHIP; http://www.go-ship.org/) with National Capability funding from the UK Natural Environment Research Council to the National Oceanography Centre."'};
        end
        %%%%%%%%%% end mout_cchdo_sam %%%%%%%%%%
        
        %%%%%%%%%% mout_cchdo_ctd %%%%%%%%%%
    case 'mout_cchdo_ctd'
        switch oopt
            case 'expo'
                expocode = '74JC20161110';
                sect_id = 'SR1b';
            case 'outfile'
                outfile = fullfile(MEXEC_G.MEXEC_DATA_ROOT, 'collected_files', ['sr1b_' expocode '_ct1/sr1b_' expocode]);
            case 'headstr'
                headstring = {['CTD,' datestr(now,'yyyymmdd') 'OCPNOCYLF'];...
                    '#SHIP: James Clark Ross';...
                    '#Cruise JR16002; SR1B';...
                    '#Region: Drake Passage; ~56W';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20161110 - 20161103';...
                    '#Chief Scientist: Y. Firing, NOCS';...
                    '#Supported by NERC National Capability NE/N018095/1 (ORCHESTRA)';...
                    '#30 stations with 24-place rosette';...
                    '#CTD: Who - Y. Firing; Status - final';...
                    '#Notes: Includes CTDSAL, CTDOXY, SBE35';...
                    '#The CTD PRS;  TMP;  SAL; OXY data are all calibrated and good.'};
                if stnlocal==20
                    headstring = [headstring; '#These are upcast data (the downcast was not continuous)'];
                end
                headstring = [headstring;...
                    '# DEPTH_TYPE   : COR';...
                    '#These data should be acknowledged with: "Data were collected and made publicly available by the International Global Ship-based Hydrographic Investigations Program (GO-SHIP; http://www.go-ship.org/) with National Capability funding from the UK Natural Environment Research Council to the National Oceanography Centre."'];
        end
        %%%%%%%%%% end mout_cchdo_ctd %%%%%%%%%%
        
        
        %%%%%%%%%% mctd_rawedit %%%%%%%%%%
    case 'mctd_rawedit'
        switch oopt
            case 'rawedit_auto'
                if stnlocal == 22 %CTD comms loss led to lost scans, but first to bad data
                    ser = [179877 181455];
                end
                if stnlocal== 23 %CTD comms loss led to lost scans, but first to bad data
                    ser = [179877 181455];
                else
                    ser = [];
                end
                if length(ser)>0
                    sevars = {'press' ser(1) ser(2)
                        'temp1' ser(1) ser(2)
                        'temp2' ser(1) ser(2)
                        'cond1' ser(1) ser(2)
                        'cond2' ser(1) ser(2)
                        'oxygen_sbe' ser(1) ser(2)
                        'loxygen_sbe' ser(1) ser(2)
                        'sbeoxyV' ser(1) ser(2)
                        'pressure_temp' ser(1) ser(2)
                        'altimeter' ser(1) ser(2)
                        'fluor' ser(1) ser(2)
                        'transmittance' ser(1) ser(2)
                        'par' ser(1) ser(2)
                        'depSM' ser(1) ser(2)};
                end
                
        end
        %%%%%%%%%% end mctd_rawedit %%%%%%%%%%
        
        
        %%%%%%%%%% mctd_04 %%%%%%%%%%
    case 'mctd_04'
        switch oopt
            case 'pre_2_treat'
                if stnlocal==20
                    % use upcast; downcast was 0-600-150-bottom and the average looks ringy around 600
                    kf = find(d.statnum == stnlocal);
                    dcstart = d.dc_bot(kf);
                    dcend = d.dc_end(kf);
                    copystr = {[sprintf('%d',round(dcstart)) ' ' sprintf('%d',round(dcend))]};
                end
        end
        %%%%%%%%%% end mctd_04 %%%%%%%%%%
        
        
        %%%%%%%%%% moxy_01 %%%%%%%%%%
    case 'moxy_01'
        switch oopt
            case 'oxycsv'
                infile = 'ctd/BOTTLE_SAL/log_samp_jr16002_all.txt';
            case 'oxyflags'
                flags3 = [0113; %duplicates quite different
                    1303; %o2 draw questionable
                    1708; %bottle num questionable
                    2603; %bottle num questionable
                    2703]; %probably okay but strong gradient so not using for calibration (does this merit flag of 3 though?)
                flags4 = [0204; %bottle val far from ctd val so must have been bad
                    0409; %splash when removing stopper
                    0705; %bottle val far from ctd val
                    1909; %ditto
                    1921; %ditto
                    2801]; %bottle reading very different, probably bad
                ds_oxy.flag(ismember(ds_oxy.sampnum, flags3)) = 3;
                ds_oxy.flag(ismember(ds_oxy.sampnum, flags4)) = 4;
        end
        %%%%%%%%%% end moxy_01 %%%%%%%%%%
        
        %%%%%%%%%% moxy_ccalc %%%%%%%%%%
    case 'moxy_ccalc'
        switch oopt
            case 'oxypars'
                lab_temp = 22; % lab temp (deg. C) (a guess, similar to sal lab?)
                vol_reag1 = 0.9920; %dispenser A
                vol_reag2 = 0.9800; %dispenser D
            case 'blstd' %these could be station-dependent, but here we use one average value for each (average excluding 1st set, which were erroneous)
                vol_blank = 0.0045;     % volume of blank (mL)
                vol_titre_std = 0.5018; % standard titre (mL) (only one sod thio batch to standardise here)
            case 'botvols'
                fname_bottle = 'ctd/BOTTLE_OXY/bottle_vols.csv';
                ds_bottle = dataset('File', fname_bottle, 'Delimiter', ',');
                mb = max(ds_bottle.bot_num); a = NaN+zeros(mb, 1);
                a(ds_bottle.bot_num) = ds_bottle.bot_vol;
                obot_vol = a(ds_oxy.oxy_bot); %mL
        end
        %%%%%%%%%% end moxy_01y %%%%%%%%%%
        
        
        %%%%%%%%%% msal_01 %%%%%%%%%%
    case 'msal_01'
        switch oopt
            case 'salflags'
                if stnlocal==5
                    flag(ismember(salbot,[18 20])) = 3; %questionable
                elseif stnlocal==11
                    flag(ismember(salbot,[7])) = 3; %questionable
                elseif stnlocal==16
                    flag(ismember(salbot,[22])) = 3; %meas. ok but strong gradient
                elseif stnlocal==20
                    flag(ismember(salbot,[3 9])) = 3; %questionable
                elseif stnlocal==22
                    flag(ismember(salbot,[1])) = 3; %questionable
                    flag(ismember(salbot,[9])) = 9; %ctd data bad
                elseif stnlocal==24
                    flag(ismember(salbot,[1:10])) = 4; %stoppers not well-sealed
                elseif stnlocal==25
                    flag(ismember(salbot,[22])) = 3; %meas. ok but strong gradient
                elseif stnlocal==26
                    flag(ismember(salbot,[15])) = 3; %questionable
                elseif stnlocal==27
                    flag(ismember(salbot,[1 3 7 11 15 21])) = 4; %stoppers not well-sealed
                elseif stnlocal==28
                    flag(ismember(salbot,[1:8])) = 4; %stoppers not well-sealed
                elseif stnlocal==29
                    flag(ismember(salbot,[17 18 20:23])) = 4; %stoppers not well-sealed
                elseif stnlocal==30
                    flag(ismember(salbot, [1])) = 4; %stoppers not well-sealed
                end
        end
        %%%%%%%%%% end msal_01 %%%%%%%%%%
        
        
        %%%%%%%%%% msal_standardise_avg %%%%%%%%%%
    case 'msal_standardise_avg'
        switch oopt
            case 'salcsv'
                sal_csv_file = 'log_sal_jr16002_all.txt';
            case 'std2use'
                std2use(33:34, 1) = 0;
                std2use(35, :) = 0;
                doplot = 0;
            case 'sam2use'
                sam2use(73,2) = 0; sam2use(91,1) = 0;
                doplot = 0;
        end
        %%%%%%%%%% end msal_standardise_avg %%%%%%%%%%
        
        
        %%%%%%%%%% msbe35_01 %%%%%%%%%%
    case 'msbe35_01'
        switch oopt
            case 'sbe35flag'
                % these might have been closed too quickly for a good reading
                d.sbe35temp_flag(isnan(d.sbe35temp)) = 9;
                d.sbe35temp_flag(d.statnum==22 & d.position == 9) = 4;
                d.sbe35temp_flag(d.statnum==24 & (d.position == 6 | d.position ==9)) = 4;
                d.sbe35temp_flag(d.statnum==27 & d.position == 17) = 4;
        end
        %%%%%%%%%% end msbe35_01 %%%%%%%%%%
        
        
        %%%%%%%%%% mtsg_01 %%%%%%%%%%
    case 'mtsg_01'
        switch oopt
            case 'flag'
                ds_sal.flag([50 51]) = 4; %large outliers and no strong gradient, may be mis-measured or mis-logged
                ds_sal.flag([1 5 8 12:14 18]) = 3; %large outliers with strong gradient, so measurements probably ok but comparison not
        end
        %%%%%%%%%% end mtsg_01 %%%%%%%%%%
        
        %%%%%%%%%% mtsg_cleanup %%%%%%%%%%
    case 'mtsg_cleanup'
        switch oopt
            case 'kbadlims'
                kbadlims = [
                    datenum([2016 11 06 00 00 00]) datenum([2016 11 10 12 06 02]) % start of cruise
                    datenum([2016 11 13 09 08 55]) datenum([2016 11 15 21 15 01]) % signy
                    datenum([2016 11 27 10 23 57]) datenum([2016 11 28 19 13 00]) % rothera ice
                    datenum([2016 11 30 11 35 00]) datenum([2016 11 30 12 11 00]) % ?
                    ];
        end
        %%%%%%%%%% end mtsg_cleanup %%%%%%%%%%
        
        
        %%%%%%%%%% tsgsal_apply_cal %%%%%%%%%%
    case 'tsgsal_apply_cal'
        switch oopt
            case 'saladj'
                off = 0.004;
                salout = salin+off;
        end
        %%%%%%%%%% end tsgsal_apply_cal %%%%%%%%%%
        
end
