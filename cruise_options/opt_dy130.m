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
                condcal = 1;
                oxygencal = 0;
              case 'ctdcals'
                  calstr = [calstr;
                      'dcal.cond2 = d0.cond2.*(1 + (3.8e-4 - 3.9e-4*d0.statnum + interp1([0 5000],[0 3e-3],d0.press))/35);';
                      'dcal.cond1 = d0.cond1.*(1 + (2.5e-3 - 2.7e-4*d0.statnum)/35);';
                            ];
                    calms = 'from comparison with bottle salinities, stations 1-14';
                    calmsg = [calmsg;
                        {'cond2 dy130' calms}
                        {'cond1 dy130' calms}
                        ];           
                    calstr = [calstr;
                        'dcal.oxygen1 = d0.oxygen1 + interp1([0 2000 5000],[2 3.5 4],d0.press) + interp1([1 14],[-1 1],d0.statnum);'
                        ];
                    calms = 'oxygen stations 1-14';
                    calmsg = [calmsg;
                        {'oxygen1 dy130' calms}
                        ];
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
                d.botoxya_flag(ismember(d.sampnum,[803 816])) = 3; %sample or titration errors
                d.botoxya_flag(ismember(d.sampnum,[124 804 1002])) = 3; %misfires
                d.botoxyb_flag(ismember(d.sampnum,[1002])) = 3; %misfires
        end
        
end
