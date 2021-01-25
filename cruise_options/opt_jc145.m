switch scriptname
    
    %%%%%%%%%% mout_cchdo_sam %%%%%%%%%%
    case 'mout_cchdo_sam'
        switch oopt
            case 'expo'
                expocode = 'jc145';
                sect_id = 'RAPID_2017';
            case 'outfile'
                outfile = ['RAPID_jc145'];
        end
        %%%%%%%%%% end mout_cchdo_sam %%%%%%%%%%
        
        %%%%%%%%%% mout_cchdo_ctd %%%%%%%%%%
    case 'mout_cchdo_ctd'
        switch oopt
            case 'expo'
                expocode = 'jc145';
                sect_id = 'RAPID_2017';
            case 'outfile'
                outfile = ['RAPID_jc145'];
        end
        %%%%%%%%%% end mout_cchdo_ctd %%%%%%%%%%
        
        %%%%%%%%%% ctd_evaluate_sensors %%%%%%%%%%
    case 'ctd_evaluate_sensors'
        switch oopt
            case {'csensind','osensind'}
                if sensnum==1 | sensnum==2
                    sensind(1,1) = {find(d.statnum<=6)}; %first CTD set (all sensors)
                    sensind(2,1) = {find(d.statnum>=7)}; %second CTD set (all sensors)
                end
        end
        %%%%%%%%%% end ctd_evaluate_sensors %%%%%%%%%%
        
        %%%%%%%%%% cond_apply_cal %%%%%%%%%%
    case 'cond_apply_cal'
        switch stn
            case {1 2 3 4 5 6}
                switch sensor
                    case 1
                        off = ( 0.03006 - 0.00934*press/1000 -0.00512*temp)/1000;
                    case 2
                        off = ( 0.06040 - 0.01482*press/1000 -0.00634*temp)/1000;
                end
            case {7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25}
                switch sensor
                    case 1
                        off = (-0.02086 - 0.00732*press/1000 -0.00554*temp)/1000;
                    case 2
                        off = ( 0.02576 - 0.01267*press/1000 -0.00308*temp)/1000;
                end
        end
        fac = 1 + off;
        condout = cond.*fac;
        %%%%%%%%%% end cond_apply_cal %%%%%%%%%%
        
        %%%%%%%%%% tsgsal_apply_cal %%%%%%%%%%
    case 'tsgsal_apply_cal'
        %off = -0.0152;
        off = (-0.0001/86400)*time-0.00763;
        salout = salin + off;
        %%%%%%%%%% end tsgsal_apply_cal %%%%%%%%%%
        
        %%%%%%%%%% oxy_apply_cal %%%%%%%%%%
    case 'oxy_apply_cal'
        switch sensor
            case 1
                %      if stn<=23
                %         alpha = 1.0427 - 4e-4*stn;
                %         beta = 3.1262 + 12e-4*press;
                %      elseif stn>=24
                %	 alpha = 1.3317 - 104e-4*stn;
                %	 beta = 15.0859; %not enough samples (particularly as these are on cont. slope) to resolve pressure dependence
                %      end
        end
        %      oxyout = alpha.*oxyin + beta;
        %      oxyout = (oxyin - beta)./alpha; %use this line to undo the one above
        %%%%%%%%%% end oxy_apply_cal %%%%%%%%%%
        
        %%%%%%%%%% mctd_02b %%%%%%%%%%
    case 'mctd_02b'
        switch oopt
            case 'oxyhyst'
                H1 = zeros(size(D));
                h2tab = [-10 5000
                    2000 5000
                    2001 4200
                    7000 4200];
                H2 = interp1(h2tab(:,1), h2tab(:,2), d.press);
                h3tab = [-10 1450
                    2000 1450
                    2001 5000
                    7000 5000];
                H3 = interp1(h3tab(:,1), h3tab(:,2), d.press);
        end
        %%%%%%%%%% end mctd_02b %%%%%%%%%%
        
        
        %%%%%%%%%% mctd_03 %%%%%%%%%%
    case 'mctd_03'
        switch oopt
            case 's_choice'
                s_choice = 2; %use T,C 2
                stns_alternate_s = [1:6]; %stations on which to use the other sensor
            case 'o_choice'
                o_choice = 2; %use oxygen 2
        end
        %%%%%%%%%% end mctd_03 %%%%%%%%%%
        
        
        %%%%%%%%%% mctd_checkplots %%%%%%%%%%
    case 'mctd_checkplots'
        switch oopt
            case 'plot_saltype'
                saltype = 'asal';
        end
        %%%%%%%%%% end mctd_checkplots %%%%%%%%%%
        
                
        %%%%%%%%%% moxy_01 %%%%%%%%%%
    case 'moxy_01'
        switch oopt
            case 'oxysampnum'
                ds_oxy.niskin = ds_oxy.botnum*2; %only even Niskins on the rosette
        end
        %%%%%%%%%% end moxy_01 %%%%%%%%%%
               
        
        %%%%%%%%%% msal_standardise_avg %%%%%%%%%%
    case 'msal_standardise_avg'
        switch oopt
            case 'salcsv'
                sal_csv_file = 'sal_jc145_01.csv';
            case 'cellT'
                ds_sal.cellT = 21+zeros(length(ds_sal.sampnum),1);
            case 'offset'
                ds_sal.offset = zeros(length(ds_sal.sampnum),1);
                ds_sal.offset(ismember(ds_sal.sampnum,[ 1:224])) = 0;
                ds_sal.offset(ismember(ds_sal.sampnum,[ 300:1024])) = 0.000085;
                ds_sal.offset(ismember(ds_sal.sampnum,[1100:2524])) = 0.000160;
            case 'std2use'
                %	       std2use  = zeros(25,1);
                %	       std2use([1 2 3 10 11 25]) = 1;
                %	       doplot = 0;
            case 'sam2use'
                %sam2use(73,2) = 0; sam2use(91,1) = 0;
                %salbotqf([]) = 3;
                doplot = 0;
        end
        %%%%%%%%%% end msal_standardise_avg %%%%%%%%%%
        
        
        %%%%%%%%%% msim_plot %%%%%%%%%%
    case 'msim_plot'
        switch oopt
            case 'sbathy'
                bfile = '/local/users/pstar/cruise/data/tracks/n_atlantic';
        end
        %%%%%%%%%% end msim_plot %%%%%%%%%%
        
        %%%%%%%%%% mem120_plot %%%%%%%%%%
    case 'mem120_plot'
        switch oopt
            case 'sbathy'
                bfile = '/local/users/pstar/cruise/data/tracks/n_atlantic';
        end
        %%%%%%%%%% end mem120_plot %%%%%%%%%%
        
        
        %%%%%%%%%% msal_01 %%%%%%%%%%
    case 'mtsg_01'
        switch oopt
            case 'flag'
                %	    flag(ismember(ds_sal.sampnum, [])) = 3; %questionable
                doplot = 0;
            case 'sstdagain'
                sstdagain = 1;
        end
        %%%%%%%%%% end mtsg_01 %%%%%%%%%%
        
        %%%%%%%%%% mtsg_cleanup %%%%%%%%%%
    case 'mtsg_cleanup'
        switch oopt
            case 'kbadlims'
                kbadlims = [datenum([2017 02 09 15 45 00])  datenum([2017 02 21 14 10 00])
                    datenum([2017 02 23 11 24 00])  datenum([2017 02 28 15 39 00])
                    datenum([2017 03 27 11 32 00])  datenum([2017 03 28 07 04 00])
                    ];
        end
        %%%%%%%%%% end mtsg_cleanup %%%%%%%%%%
        
        
        
        %%%%%%%%%% sal_standardise_avg %%%%%%%%%%
    case 'sal_standardise_avg'
        switch oopt
            case 'std2use'
                std2use = ones(size(offs));
                %keyboard %initially
                %	    std2use(33:34, 1) = 0;
                %            std2use(35, :) = 0;
            case 'sam2use'
                sam2use = ones(size(sams)); salbotqf = 2+zeros(size(sams,1),1);
                %ii = find(ds_sal.station_day(iisam)<0); %these are for TSG
                %subplot(3,1,2:3); plot(ii, sams0(ii,1), 'o', ii, sams0(ii,2), 's', ii, sams0(ii,3), '<'); title('tsg'); keyboard
                %stnos = unique(ds_sal.station_day(ds_sal.station_day>0)); %plot for all CTDs
                %for no = 1:length(stnos)
                %   ii = find(ds_sal.station_day(iisam)==stnos(no));
                %   subplot(3,1,2:3); plot(ii, sams0(ii,1), 'o', ii, sams0(ii,2), 's', ii, sams0(ii,3), '<'); title(['ctd ' num2str(stnos(no))]); keyboard
                %end
                sam2use(73,2) = 0; sam2use(91,1) = 0;
                %salbotqf***
        end
        %%%%%%%%%% end sal_standardise_avg %%%%%%%%%%
        
        
        %%%%%%%%%% smallscript %%%%%%%%%%
    case 'smallscript'
        switch oopt
            case 'klist'
                klist = 1:5;
                klist = 7:16; %***
        end
        %%%%%%%%%% end smallscript %%%%%%%%%%
        
        
        %%%%%%%%%% station_summary %%%%%%%%%%
    case 'station_summary'
        switch oopt
            case 'optsams'
                %	    snames = {'noxy'}; sgrps = {'oxy'};
                sashore = 0;
            case 'stnmiss'
                stnmiss = [];
            case 'comments'
                comments = cell(size(stnset));
        end
        %%%%%%%%%% end station_summary %%%%%%%%%%
        
        %%%%%%%%%% vmadcp_proc %%%%%%%%%%
    case 'vmadcp_proc'
        switch oopt
            case 'aa0_75' %set approximate/nominal instrument angle and amplitude
                ang = -10.0; amp = 1;
            case 'aa0_150' %set approximate/nominal instrument angle and amplitude
                ang = -1.3; amp = 1;  %-1.3            ang = 0;
                %if seq<6; ang = -0.2; else; ang = -0.1; end
                amp = 1;
            case 'aa150' %refined additional rotation and amplitude corrections based on btm/watertrk
                ang = 0;
                amp = 1;
        end
        %%%%%%%%%% end vmadpc_proc %%%%%%%%%%
        
end
