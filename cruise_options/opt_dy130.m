switch scriptname
    
    case 'mctd_01'
        switch oopt
            case 'cnvfilename'
                if redoctm
                    infile = sprintf('DY130_%03d.cnv', stnlocal);
                else
                    infile = sprintf('DY130_%03d_align_CTM.cnv', stnlocal);
                end
        end
        
    case 'mctd_02b'
        switch oopt
            case 'raw_corrs'
                docal.cond = 1;
                docal.oxygen = 1;
            case 'ctdcals'
                calstr.cond2.dy130 = 'dcal.cond2 = d0.cond2.*(1 + (3.8e-4 - 3.9e-4*d0.statnum + interp1([0 5000],[0 3e-3],d0.press))/35);';
                calstr.cond1.dy130 = 'dcal.cond1 = d0.cond1.*(1 + (2.5e-3 - 2.7e-4*d0.statnum)/35);';
                calms = 'from comparison with bottle salinities, stations 1-14';
                calstr.cond2.calmsg = calms;
                calstr.cond1.calmsg = calms;
                calstr.oxygen1.dy130 = 'dcal.oxygen1 = d0.oxygen1 + interp1([0 2000 5000],[1.8 3.5 4],d0.press) + interp1([1 14 ],[-1 1],d0.statnum);'
                calstr.oxygen2.dy130 = 'dcal.oxygen2 = d0.oxygen2*0.95 + 4 + interp1([1 14],[-1 3],d0.statnum);'
                calms = 'oxygen stations 1-14';
                calstr.oxygen1.calmsg = calms;
                calstr.oxygen2.calmsg = calms;
        end
        %%%%%%%%%% end mctd_02b %%%%%%%%%%
   
    case 'mfir_01'
        switch oopt
            case 'blinfile'
                infile = sprintf('DY130_%03d.bl', stnlocal);
        end
        
    case 'mbot_01'
        switch oopt
            case 'blfilename'
                infile = sprintf('DY130_%03d.bl', stnlocal);
        end
        
       %%%%%%%%%% mctd_rawedit %%%%%%%%%%
    case 'mctd_rawedit'
        switch oopt
            case 'rawedit_auto'
                          revars = {'press' -1.4 8000};
            
        end
        %%%%%%%%%% end mctd_rawedit %%%%%%%%%%   
        
        %%%%%%%%%% msal_01 %%%%%%%%%%
    case 'msal_01'
        switch oopt
            case 'salfiles'
                salfiles = dir(fullfile(root_sal, 'DY130_*.csv'));
                salfiles = {salfiles.name};
            case 'sal_off'
                sal_off_base = 'sampnum_run';
                sal_off = [1 -4
                    2 -4
                    3 -6
                    4 -9
                    5 -9
                    6 -9
                    7 -8 
                    8 -13
                    9 -13
                    ];
                sal_off(:,1) = sal_off(:,1)+999900;
                sal_off(:,2) = sal_off(:,2)*1e-5;
                sal_adj_comment = 'Autosal output .xls files, adjusted by inspection of SSW runs';
        end
        %%%%%%%%%% end msal_01 %%%%%%%%%%
        
    case 'moxy_01'
        switch oopt
            case 'oxy_files'
                clear ofiles
                ofiles.name = 'DY130_bot_o2.csv';
            case 'oxy_parse'
                hcpat = {'std_titre (mL)'};
                chrows = 1;
                mvar_fvar = {
                    'position',      'nisk'  
                    'vol_blank',     'blank_titre_ml'   
                    'vol_std',       'std_vol_ml'        
                    'vol_titre_std', 'std_titre_ml'
                    'fix_temp',      'fix_temp_degc'  
                    'sample_titre',  'sample_titre_ml'   
                    'oxy_bottle'     'o2_bot'
                    'bot_vol_tfix',       'bot_vol_at_tfix_ml'
                     'conc_o2', 'c_o2_umol_l' %comment this line out, uncomment 'oxycalcpars' case below, and put a debug point in moxy_01 line 124 if you want to compare spreadsheet to calculated conc_o2
                    };
            case 'oxy_parse_files'
                ds_oxy.statnum = str2num(cell2mat(replace(ds.cruise_ctd,'DY130-','')));
            %case 'oxycalcpars'
            %    vol_reag_tot = 0;
            case 'oxyflags'
                flag3a = [803 816]; %sample or titration errors
                flag3a = [flag3a 1002]; %misfires
                flag3b = 1002;
                d.botoxya_flag(ismember(d.sampnum,flag3a)) = max(d.botoxya_flag(ismember(d.sampnum,flag3a)),3);
                d.botoxyb_flag(ismember(d.sampnum,flag3b)) = max(d.botoxyb_flag(ismember(d.sampnum,flag3b)),3);
        end
        
    case 'populate_station_depths'
        switch oopt
            case 'depth_source'
                crhelp_str = {'depth_source (default: {''file'', ''ctd''}) determines preferred method(s), '
                    'in order, for finding station depths. Other option is ''ladcp''. If one of the methods '
                    'is ''file'', fnintxt specifies name of ascii (csv or two-column text) file of [stations, depths].'};
                depth_source = {'file'}; %load from two-column text file, then fill with ctd press+altimeter
                fnintxt = fullfile(mgetdir('M_SUM'), 'dy130_bottom_depths.csv');
        end
        
    case 'station_summary'
        switch oopt
            case 'sum_varsams'
                ii = find(strcmp('maxw',vars(:,1)));
                vars(ii,:) = [];
        end
        
                %%%%%%%%%% mout_cchdo %%%%%%%%%%
    case 'mout_cchdo'
        switch oopt
            case 'woce_expo'
                expocode = '74EQ20210321';
                sect_id = 'PAP-SO';
            case 'woce_vars_exclude'
                vars_exclude_ctd = {};
            case 'woce_ctd_headstr'
                headstring = {['CTD,' datestr(now,'yyyymmdd') 'OBGNOCAF'];...
                    '#SHIP: RRS Discovery';...
                    '#Cruise DY130';...
                    '#Region: Porcupine Abyssal Plain Sustained Observatory (PAP-SO); Northeast Atlantic ';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20210321 - 20210414';...
                    '#Chief Scientist: S. Hartman, NOC';...
                    '#Supported by NERC National Capability xxxx (CLASS)';...
                    '#14 stations with 24-place rosette';...
                    '#Notes: DY130 in collaboration with NASA-EXPORTS programme (DY131, xxxx) ';...
                    '#CTD: Who - S. Hartman and A. Flohr; Status - final';...
                    '#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                    '# DEPTH_TYPE   : COR';...
                    '#These data should be acknowledged with: "Data were collected and made publicly with National Capability funding from the UK Natural Environment Research Council to the National Oceanography Centre."'};
            case 'woce_sam_headstr'
                headstring = {['BOTTLE,' datestr(now,'yyyymmdd') 'OBGNOCAF'];... %the last field specifies group, institution, initials
                    '#SHIP: RRS Discovery';...
                    '#Cruise DY130';...
                    '#Region: Porcupine Abyssal Plain Sustained Observatory (PAP-SO); Northeast Atlantic ';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20210321 - 20210414';...
                    '#Chief Scientist: S. Hartman, NOC';...
                    '#Supported by NERC National Capability xxxx (CLASS)';...
                    '#14 stations with 24-place rosette';...
                    '#Notes: Sampling during DY130 in collaboration with NASA-EXPORTS programme (DY131, xxxx) ';...
                    '#CTD: Who - S. Hartman and A. Flohr; Status - final';...
                    '#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                    '#Salinity: Who - B. Platt and P. Henderson ; Status - final';...
                    '#Notes: bottle salinity from stations 1-14 used for CTD calibration';...
                    '#Oxygen: Who - A. Flohr; Status - final';...
                    '#Notes: bottle oxygen from stations 1-14 used for CTD calibration';...
                    '#Nutrients: Who - E. Mawji and F. Carvalho; Status - analysed but not yet included';...
                    '#TA/DIC: Who - A. Flohr; Status - not yet analysed';...
                    '#13C-DIC isotopes: Who - H.N. Kokuhennadige; Status - not yet analysed';...
                    '#TOC: Who - F. Carvalho - not yet analysed';...
                    '#DOC: Who - H.N. Kokuhennadige and E.Z. Mawji; Status - not yet analysed';...
                    '#13C-DOC isotopes: Who - H.N. Kokuhennadige; Status - not yet analysed';...
                    '#Chlorophyll: Who - C. Pebody and F. Carvalho; Status - not yet analysed';...
                    '#These data should be acknowledged with: "Data were collected and made publicly with National Capability funding from the UK Natural Environment Research Council to the National Oceanography Centre."'};
        end
        %%%%%%%%%% end mout_cchdo %%%%%%%%%%
        
    case 'mctd_addvars'
        switch oopt
            case 'newvars'
                newvars = {'flECO_minus_AFL'};
        end
        
end
