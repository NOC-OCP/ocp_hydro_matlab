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
        end
        %%%%%%%%%% end msal_01 %%%%%%%%%%
        
    case 'moxy_01'
        switch oopt
            case 'oxy_parse'
                hcpat = {'std_titre (mL)'};
                chrows = 1;
                mvar_fvar = {
                    'statnum',       'cruise_ctd_'
                    'position',      'nisk_'  
                    'vol_blank',     'blank_titre_ml_'   
                    'vol_std',       'std_vol_ml_'        
                    'vol_titre_std', 'std_titre_ml'
                    'fix_temp',      'fix_temp_degc'  
                    'sample_titre',  'sample_titre_ml'   
                    'oxy_bottle'     'o2_bot'
                    'bot_vol_tfix',       'bot_vol_at_tfix_ml'
                    'conc_o2', 'c_o2_umol_l'};
            case 'oxy_parse_files'
                ds.statnum = str2num(cell2mat(replace(ds.cruise_ctd,'DY130-','')));
            case 'oxyflags'
                ds_oxy.botoxya_flag(ismember(ds_oxy.sampnum,[803 816])) = 3; %sample or titration errors
                ds_oxy.botoxya_flag(ismember(ds_oxy.sampnum,[124 804 1002])) = 3; %misfires
                ds_oxy.botoxyb_flag(ismember(ds_oxy.sampnum,[1002])) = 3; %misfires
        end
        
end
