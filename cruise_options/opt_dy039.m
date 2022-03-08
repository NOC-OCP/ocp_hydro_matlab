switch scriptname

    case 'castpars'
        switch oopt
            case 'oxy_align'
                oxy_align = 1;
                oxy_end = 1;
        end

    case 'mfir_01'
        switch oopt
            case 'blinfile'
                blinfile = fullfile(MEXEC_G.mexec_data_root,'ctd','BOTTLE_FILES',sprintf('ctd_%s_%03d.bl',mcruise,stnlocal));
        end
        
    case 'mctd_02'
        switch oopt
            case 'raw_corrs'
                castopts.oxyhyst.H1 = {-0.043 -0.043};
                castopts.oxyhyst.H2 = {5000    5000};
                castopts.oxyhyst.H3 = {4000   1450};
                h3tab1 =[
                    -10 1000
                    2000 1000
                    2001 3000
                    9000 3000
                    ];
                h3tab2 =[
                    -10 1450
                    2000 1450
                    2001 1450
                    9000 1450
                    ];

                castopts.oxyhyst.H3{1} = interp1(h3tab1(:,1),h3tab1(:,2),d.press);
                iib = find(isnan(d.press)); iig = find(~isnan(d.press));
                if ~isempty(iib); castopts.oxyhyst.H3{1}(iib) = interp1(iig,castopts.oxyhyst.H3{1}(iig),iib); end
                castopts.oxyhyst.H3{2} = interp1(h3tab2(:,1),h3tab2(:,2),d.press);
                iib = find(isnan(d.press)); iig = find(~isnan(d.press));
                if ~isempty(iib); castopts.oxyhyst.H3{2}(iib) = interp1(iig,castopts.oxyhyst.H3{2}(iig),iib); end
            case 'ctdcals'
                castopts.docal.cond = 1;
                castopts.docal.oxygen = 1;
%                 a1 = -1.5186e-08;
%                 a2 = 1+4.3419e-5;
%                 b1 = -2.9895e-06;
%                 b2 = 1+1.0117e-5;
%                 castopts.calstr.cond1.dy039 = sprintf('dcal.cond1 = d0.cond1.*(%f*%f*d0.press+%f*%f*d0.temp1+%f*%f);',a1,b2,a2,b1,a2,b2);
%                 castopts.calstr.cond2.dy039 = 'dcal.cond2 = d0.cond2;'; % Do nothing with wanderly second sensor
%                 castopts.calstr.oxygen1.dy039 = 'dcal.oxygen1 = d0.oxygen1+0.0028*d0.press+0.0242*d0.oxygen1;';
%                 castopts.calstr.oxygen2.dy039 = 'dcal.oxygen2 = d0.oxygen2';

% new cond and oxy cal for sensors 1 worked up by bak at end of dy146; 8
% March 2022

                castopts.calstr.cond1.dy039 = 'dcal.cond1 = d0.cond1.*(1 + interp1([-10 0   1000 2000 3750 6000],1*[-10 -10    6 8 -8 -8 ]/1e4,d0.press)/35);';
                castopts.calstr.cond2.dy039 = 'dcal.cond2 = d0.cond2.*(1 + interp1([-10 0 500 1000 2000 3500 4500 8000],1*[0 0 0 0 0 0 0 0]/1e4,d0.press)/35);';
                calms = 'from comparison with bottle salinity, stations 1-25 (all); cond2 uncalibrated';
                castopts.calstr.cond1.msg = calms;
                castopts.calstr.cond2.msg = calms;



                castopts.calstr.oxygen1.dy039 = ['dcal.oxygen1 = d0.oxygen1.*'...
                    'interp1([-10  0  500  1000  2500  4000  6000],[1.024  1.024   1.037 1.046  1.050 1.062 1.070],d0.press).*'...
                    'interp1([1 5 25],[1 1 1],d0.statnum);'];
                castopts.calstr.oxygen2.dy039 = ['dcal.oxygen2 = d0.oxygen2.*'...
                    'interp1([-10      0    1000    3000  5400   6000],[1 1 1 1 1 1],d0.press).*'...
                    'interp1([1 5 25],[1  1 1],d0.statnum);'];
                calms = 'oxygen 1 from comparison with bottle oxygens, stations 1-25 (all); oxygen 2 uncalibrated';
                castopts.calstr.oxygen1.msg = calms;
                castopts.calstr.oxygen2.msg = calms;
        end

    case 'moxy_01'
        switch oopt
            case 'oxy_files_parse'
                                ofpat = ['/CTD*_oxygen.xlsx'];
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
                d.botoxya_flag(d.botoxya_flag==6) = 2;
                d.botoxyb_flag(d.botoxyb_flag==6) = 2;
                m = ismember(d.statnum,[6 7 8]);
                d.botoxya_flag(m) = max(d.botoxya_flag(m),4);
                d.botoxyb_flag(m) = max(d.botoxyb_flag(m),4);
                m = ismember(d.sampnum,[307 321 1819 1905]);
                d.botoxya_flag(m) = max(d.botoxya_flag(m),3);
                d.botoxyb_flag(m) = max(d.botoxyb_flag(m),3);
                m = ismember(d.sampnum, [311 401 405 409 411 415 417 421 423 1311 1907 2007 2023 2105 2107]);
                d.botoxya_flag(m) = max(d.botoxya_flag(m),3);
                d.botoxyb_flag(m) = max(d.botoxyb_flag(m),3);
                d.botoxya_per_l(ismember(d.botoxya_flag,[4 9])) = NaN;
                d.botoxyb_per_l(ismember(d.botoxyb_flag,[4 9])) = NaN;
        end

    case 'msal_01'
        switch oopt
            case 'salfiles'
                hcpat = {'Sampnum'};
            case 'salflags'
                m = ismember(ds_sal.sampnum,[221 723]);
                ds_sal.flag(m) = max(ds_sal.flag(m),3);
                m = ismember(ds_sal.sampnum,[115 117 217 219 319 521]);
                ds_sal.flag(m) = max(ds_sal.flag(m),4);
        end

                %%%%%%%%%% best_station_depths %%%%%%%%%%
 case 'best_station_depths'
        switch oopt
            case 'bestdeps'
                %only for stations where we can't use ctd+altimeter
                replacedeps = [ % from em120
                001 4366
                002 3524
                003 3522
                004 4480
                005 5108
                006 5108
                007 5099
                008 5121
                009 5836
                010 5516
                012 5180
                013 5169
                014 5522
                015 5492
                016 5493
                017 5491
                018 4700
                019 4698
                020 4716
                021 4713
                022 1409
                023 3909
                024 1429
                025 4195
                    ];
        end
   
                %%%%%%%%%% mout_exch %%%%%%%%%%
    case 'mout_exch'
        switch oopt
            case 'woce_expo'
                expocode = '74EQ20151017';
                sect_id = 'RAPID';
            case 'woce_vars_exclude'
                vars_exclude_ctd = {'fluor'};
                vars_exclude_sam = {'ufluor'};
            case 'woce_ctd_headstr'
                headstring = {['CTD,' datestr(now,'yyyymmdd') 'OCPNOCYLF'];...
                    '#SHIP: Discovery';...
                    '#Cruise DY039; RAPID';...
                    '#Region: North Atlantic (subtropical)';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20151007 - 20151201';...
                    '#Chief Scientist: D. R. Rayner, NOC';...
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
                    '#Cruise DY039; RAPID';...
                    '#Region: North Atlantic (subtropical)';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20151007 - 20151201';...
                    '#Chief Scientist: D. R. Rayner, NOC';...
                    '#Supported by grants from the UK Natural Environment Research Council for the RAPID-AMOC program and the ACSIS program (grant no. NE/N018044/1).';...
                    '#25 stations with 12-place rosette';...
                    '#CTD: Who - B. King; Status - final';...
                    '#Notes: Includes CTDTMP, CTDSAL, CTDOXY';...
                    '#The CTD PRS; TMP data are all good.';...
                    '#The CTD SAL; OXY data are all calibrated and good.';...
                    '#Salinity: Who - G. McCarthy; Status - final';...
                    '#Oxygen: Who - S. Fowell; Status - final';...
                    };
        end
        %%%%%%%%%% end mout_cchdo %%%%%%%%%%

   %%%%%%%%%% vmadcp_proc %%%%%%%%%%
   case 'vmadcp_proc'
      switch oopt
         case 'aa75'
	    ang = 0.6; %%% DAS based on calibration from first day of bottom track
	    amp = 1.01;
	 case 'aa150'
	    ang = 0.2; %%% DAS based on calibration from first day of bottom track
	    amp = 1.00;
      end
   %%%%%%%%%% end vmadcp_proc %%%%%%%%%%

end
