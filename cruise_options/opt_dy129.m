switch scriptname
    
    %%%%%%%%%% mctd_02a %%%%%%%%%%
    case 'mctd_02a'
        switch oopt
            case 'prectm_rawedit'
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
                % Align (5 scans)
                ovars = {['oxygen_sbe1'
                    'oxygen_sbe2']};
        end
        %%%%%%%%%% end mctd_02a %%%%%%%%%%
        
        
        %%%%%%%%%% mfir_03 %%%%%%%%%%
    case 'mfir_03'
        switch oopt
            case 'fir_fill'
                fillstr = '10'; %max gap length to fill is 10 s
        end
        %%%%%%%%%% end mfir_03 %%%%%%%%%%
                
        %%%%%%%%%% mbot_01 %%%%%%%%%%
    case 'mbot_01'
        switch oopt
            case 'botflags'
                % Set pairs "staion number","position number" for which set QC flags to 3,4 etc
                % QC flag = 3
                flag3 = [0 0];
                %
                % QC flag = 4
                flag4 = [0 0];
                %
                % QC flag = 9  - samples not drawn from this bottle (Woce table 4.8)
                flag9 = [0 0];
                iif = find(flag3(:,1)==stnlocal); if length(iif)>0; bottle_qc_flag(flag3(iif,2)) = 3; end
                iif = find(flag4(:,1)==stnlocal); if length(iif)>0; bottle_qc_flag(flag4(iif,2)) = 4; end
                iif = find(flag9(:,1)==stnlocal); if length(iif)>0; bottle_qc_flag(flag9(iif,2)) = 9; end
        end
        %%%%%%%%%% end mbot_01 %%%%%%%%%%
        
        %%%%%%%%%% mctd_checkplots %%%%%%%%%%
    case 'mctd_checkplots'
        switch oopt
            case 'plot_saltype'
                saltype = 'asal';
        end
        %%%%%%%%%% end mctd_checkplots %%%%%%%%%%
                
        %%%%%%%%%% list_bot %%%%%%%%%%
    case 'list_bot'
        switch oopt
            case 'samadj'
                dsam.cruise = 159 + zeros(size(dsam.sampnum));
                hsam.fldnam = [hsam.fldnam {'cruise' 'lon' 'lat' 'bottom_dep' 'udepth' 'usig0' 'ugamma_n'}];
                hsam.fldunt = [hsam.fldunt {'number' 'degreesE' 'degreesN' 'metres' 'metres' 'kg/m3' 'gamma'}];
            case 'printmsg'
                fprintf(1,'%s\n',msg);
                fprintf(fidout,'%s\n',msg);
        end
        %%%%%%%%%% list_bot %%%%%%%%%%
        
                
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
        end
        %%%%%%%%%% msal_standardise_avg %%%%%%%%%%
        
        %%%%%%%%%% moxy_01 %%%%%%%%%%
    case 'moxy_01'
        switch oopt
            case 'oxyconcalc'
                oxyconcalc = 0;
            case 'oxycsv'
                %infile = [root_oxy '/oxy_jc159_all.csv'];
                infile = [root_oxy '/' 'oxy_' mcruise '_' sprintf('%03d',stnlocal) '.csv'];
            case 'oxysampnum'
                ds_oxy.niskin = ds_oxy.botnum;
                ds_oxy.botoxya_per_l = ds_oxy.botoxya;
                ds_oxy.botoxyb_per_l = ds_oxy.botoxyb;
                ds_oxy.botoxyc_per_l = ds_oxy.botoxyc;
            case 'oxyflags'
                flags3 = [0];
                flags4 = [0];
                ds_oxy.flag(ismember(ds_oxy.sampnum, flags3)) = 3;
                ds_oxy.flag(ismember(ds_oxy.sampnum, flags4)) = 4;
        end
        %%%%%%%%%% end moxy_01 %%%%%%%%%%
        
        %%%%%%%%%% moxy_ccalc %%%%%%%%%%
    case 'moxy_ccalc'
        switch oopt
            case 'oxypars'
                
            case 'blstd'
                
            case 'botvols'
                
            case 'compcalc'
                compcalc = 0;
        end
        %%%%%%%%%% end moxy_ccalc %%%%%%%%%%
        
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
        
        %%%%%%%%%% end cond_apply_cal %%%%%%%%%%
        
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
        end 
                        %%%%%%%%%% end tsgsal_apply_cal %%%%%%%%%%

        %%%%%%%%%% msim_plot %%%%%%%%%%
    case 'msim_plot'
        switch oopt
            case 'sbathy'
                bfile = '/local/users/pstar/programs/general_sw/topo_grids/topo_jc191_2020/GMRTv3_7_20200110topo_1954metres.mat';
        end
        %%%%%%%%%% end msim_plot %%%%%%%%%%
        
        %%%%%%%%%% mem120_plot %%%%%%%%%%
    case 'mem120_plot'
        switch oopt
            case 'sbathy'
                bfile = '/local/users/pstar/programs/general_sw/topo_grids/topo_jc191_2020/GMRTv3_7_20200110topo_1954metres.mat';
        end
        %%%%%%%%%% end mem120_plot %%%%%%%%%%
                
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
        
        %%%%%%%%%% mvad_01 %%%%%%%%%%
    case 'mvad_01'
        switch oopt
            case 'vmadcp_files'
                cname = [mcruise '_01'];
                pre1 = ['postprocessing/' mcruise '_01/proc_archive/' oslocal]; %link here to version you want to use (spprocessing or postprocessing)
                fnin = [root_vmadcp '/' pre1 '/contour/' oslocal '.nc'];
                dataname = [oslocal '_' mcruise '_01'];
                %*** station 123?
        end
        %%%%%%%%%% end mvad_01 %%%%%%%%%%
        
        
end
