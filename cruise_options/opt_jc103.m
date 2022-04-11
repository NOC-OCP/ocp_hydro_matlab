switch scriptname

        case 'castpars'
        switch oopt
            case 'oxy_align'
                oxy_end = 1;
        end

    case 'mctd_02'
        switch oopt
            case 'ctdcals'
                castopts.docal.cond = 1;
                castopts.docal.oxygen = 0;
                castopts.calstr.cond1.jc103 = 'dcal.cond1 = d0.cond1;';
                castopts.calstr.cond1.msg = 'uncalibrated';
                castopts.calstr.cond2.jc103 = 'dcal.cond2 = d0.cond2*1.00003;';% well calibrated cond sensor on jc103. v. small adjustment
                castopts.calstr.oxygen1.jc103 = 'dcal.oxygen1 = d0.oxygen1;';
                castopts.calstr.oxygen1.msg = 'uncalibrated';
                castopts.calstr.oxgyen2.jc103 = 'dcal.oxygen2 = d0.oxygen2*1.055-4; dcal.oxygen2(d0.temp2<5) = d0.oxygen2(d0.temp2<5)*1.055-1.55*d0.temp2(d0.temp2<5)+3.75;';
                % jc103 oxygen had a dog-leg in its calibration
                % warmer than 5º, a scaling and offset in oxygen is applied
                % cooler than 5º, a temperature scaling and additional
                % offset on top of the scaling and offset in oxygen is
                % applied. Correction is continuous at 5ºC.
        end

            case 'moxy_01'
        switch oopt
            case 'oxy_files_parse'
                                ofpat = ['/Cast*_oxygen.xls'];
                ofiles = dir(fullfile(root_oxy, ofpat));
                ofiles = struct2cell(ofiles); ofiles = ofiles(1,:)';
                sheets = 1;
                                oxyvarmap = {
                    'statnum',       'cast_number'
                    'position',      'niskin_bottle'
                    'vol_blank',     'blank_titre'
                    'vol_std',       'std_vol'
                    'vol_titre_std', 'standard_titre'
                    'fix_temp',      'fixing_temp'
                    'sample_titre',  'sample_titre'
                    'flag',          'flag'
                    'oxy_bottle'     'bottle_no'
                    'date_titre',    'dnum'
                    'bot_vol_tfix'   'botvol_at_tfix'
                    'conc_o2',       'c_o2_'}; %not including conc_o2, recalculating instead
            case 'oxyflags'
                d.botoxya_flag(d.statnum==6) = max(d.botoxya_flag(d.statnum==6),4);
                d.botoxyb_flag(d.statnum==6) = max(d.botoxyb_flag(d.statnum==6),4);
        end

    case 'msal_01'
        switch oopt
            case 'salflags'
                m = ismember(ds_sal.sampnum,[1502 1114]);
                ds_sal.flag(m) = max(ds_sal.flag(m),3);
        end
    case 'best_station_depths'
        switch oopt
            case 'bestdeps'
                %only for stations where we can't use ctd+altimeter
                replacedeps = [ % from a variety of sources, including singlebeam, CTD+Altimeter and deck unit operator entry
                    001   5491
                    002   5420
                    003   4101
                    004   4651
                    005   4706
                    006   3565
                    007   3860
                    008   4581
                    009   5490
                    010   5496
                    011   5144
                    012   5323
                    013   5331
                    014   5097
                    015   4472
                    016   1215
                    017    747
                    018    235
                    019     89
                    020   1220
                    021   1359
                    022   1608
                    023   3542
                    024   3542
                    ];
        end     
                %%%%%%%%%% mout_exch %%%%%%%%%%
    case 'mout_exch'
        switch oopt
            case 'woce_expo'
                expocode = '74EQ20140423';
                sect_id = 'RAPID';
            case 'woce_vars_exclude'
                vars_exclude_ctd = {'fluor'};
                vars_exclude_sam = {'ufluor'};
            case 'woce_ctd_headstr'
                headstring = {['CTD,' datestr(now,'yyyymmdd') 'OCPNOCYLF'];...
                    '#SHIP: Discovery';...
                    '#Cruise JC103; RAPID';...
                    '#Region: North Atlantic (subtropical)';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20140423 - 20140603';...
                    '#Chief Scientist: D. Smeed, NOC';...
                    '#Supported by grants from the UK Natural Environment Research Council for the RAPID-AMOC program and the ACSIS program (grant no. NE/N018044/1).';...
                    '#25 stations with 12-place rosette';...
                    '#CTD: Who - B. King; Status - final';...
                    '#The CTD PRS; TMP data are all good.';...
                    '#The CTD SAL; OXY data are all calibrated and good.';...
                    '# DEPTH_TYPE   : COR';...
                    };
            case 'woce_sam_headstr'
                headstring = {['BOTTLE,' datestr(now,'yyyymmdd') 'OCPNOCYLF'];... %the last field specifies group, institution, initials
                    '#SHIP: Discovery';...
                    '#Cruise JC103; RAPID';...
                    '#Region: North Atlantic (subtropical)';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20140423 - 20140603';...
                    '#Chief Scientist: D. Smeed, NOC';...
                    '#Supported by grants from the UK Natural Environment Research Council for the RAPID-AMOC program and the ACSIS program (grant no. NE/N018044/1).';...
                    '#25 stations with 12-place rosette';...
                    '#CTD: Who - B. King; Status - final';...
                    '#Notes: Includes CTDTMP, CTDSAL, CTDOXY';...
                    '#The CTD PRS; TMP data are all good.';...
                    '#The CTD SAL; OXY data are all calibrated and good.';...
                    '#Salinity: Who - G. McCarthy; Status - final';...
                    '#Oxygen: Who - D. Rayner; Status - final';...
                    };
        end
        %%%%%%%%%% end mout_cchdo %%%%%%%%%%


   %%%%%%%%%% vmadcp_proc %%%%%%%%%%
   case 'vmadcp_proc'
      switch oopt
         case 'aa75'
	    ang = -10.23; %%% CHECK THIS!
	    amp = 1.00;
	 case 'aa150'
	    ang = -1.5; %%% As run for 1-16
	    amp = 1.0;
      end
   %%%%%%%%%% end vmadcp_proc %%%%%%%%%%

end
