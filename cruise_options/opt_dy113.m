switch scriptname
    

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

        %%%%%%%%%% mctd_03 %%%%%%%%%%
    case 'mctd_03'
        switch oopt         
            case 's_choice' %this applies to both t and c
                s_choice = 2; %sensor on fin
                alternate = 20; %salp in CTD2
            case 'o_choice'
                o_choice = 2;
                alternate = 20; %salp in CTD2
        end
        %%%%%%%%%% end mctd_03 %%%%%%%%%%
        
        %%%%%%%%%% mbot_01 %%%%%%%%%%
    case 'mbot_01'
        switch oopt
            case 'botflags'
                flag3 = []; flag4 = []; flag9 = []; %[station niskin]
                flag3 = [1 1; 1 20; 2 1; 6 9; 7 5; 7 8; 13 18; 17 9; 22 13; 24 7; 26 9; 29 9; 32 12]; % (possibly) leaking or questionable based on visual
                flag3 = [flag3; 6 14; 20 2; 22 13; 24 17; 24 19]; %sample data suspicious
                flag4 = [1 17; 5 15; 7 6; 7 9; 8 4; 8 7; 14 15; 16 4; ...
                         17 1; 17 4; 19 4; 23 15; 25 2; 25 7; 27 7; 32 5]; %bad (end cap not closed)
                     flag4 = [flag4; 1 1; 8 2; 22 13]; %sample data very suspicious
                flag9 = [13 4; 21 4; 25 4; 26, 4]; %did not fire
                iif = find(flag3(:,1)==stnlocal); if length(iif)>0; bottle_qc_flag(flag3(iif,2)) = 3; end
                iif = find(flag4(:,1)==stnlocal); if length(iif)>0; bottle_qc_flag(flag4(iif,2)) = 4; end
                iif = find(flag9(:,1)==stnlocal); if length(iif)>0; bottle_qc_flag(flag9(iif,2)) = 9; end
                %avoid 4, 7, 15?
        end
   %%%%%%%%%% end mbot_01 %%%%%%%%%%
        
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
            case 'pshow1'
                pshow1.ylist = 'temp1 temp2 cond1 cond2 press oxygen_sbe1 oxygen_sbe2';
            case 'autoeditpars'
                dorangeedit = 1; %optionally set good data ranges to edit out-of-range values (see opt_jc159)
                revars = {'press' -1.495 8000
                    'transmittance' 50 105
                    'fluor' 0 0.5
                    'turbidity' 0 0.002
                    };
        end
        %%%%%%%%%% end mctd_rawedit %%%%%%%%%%

        %%%%%%%%%% populate_station_depths %%%%%%%%%%
    case 'populate_station_depths'
        switch oopt
            case 'fnin'
                fnin = [root_ctddep '/station_depths_' mcruise '.txt'];
                depmeth = 4; %calculate from ladcp data
            case 'bestdeps'
        end
        %%%%%%%%%% end populate_station_depths %%%%%%%%%%

          %%%%%%%%%% mout_sam_csv %%%%%%%%%%
  case 'mout_sam_csv'
      switch oopt
          case 'morefields'
      fields = fields0;
      end
      %%%%%%%%%% end mout_sam_csv %%%%%%%%%%
      
%%%%%%%%%% msal_standardise_avg %%%%%%%%%%
    case 'msal_standardise_avg'
        switch oopt
            case 'salcsv'
                sal_csv_file = 'sal_dy113_all.csv';
            case 'k15'
                ds_sal.K15 = repmat(0.99985,length(ds_sal.sampnum),1); %p163
            case 'cellT'
                ds_sal.cellT = 21+zeros(length(ds_sal.sampnum),1);
            case 'check_sal_runs'
                calc_offset = 1; %calculate offset from standards readings - 2*K15
                check_sal_runs = 0; %plot standards and sample runs to compare before averaging
                plot_all_stations = 0;                off = interp1([0 100 1600 5000], [1.2 0.5 -.8 -2.7], press)*1e-3 + 1.5e-4;

            case 'std2use'
                std2use(ismember(ssns, [8 16 18 19 26 27 27.5 31]),1) = 0;
                std2use(ssns==4, 2) = 0;
                std2use(ismember(ssns,[3 13 23]),3) = 0;
            case 'fillstd'
                xoff = ds_sal.runtime; 
            case 'sam2use'
                sam2use(ismember(ds_sal.sampnum(iisam),[115 123 201 208 301 303 403 413 415]),1) = 0;
                sam2use(ismember(ds_sal.sampnum(iisam),[505 510 605 703 817 914]),1) = 0; %1017 1023
                sam2use(ismember(ds_sal.sampnum(iisam),[1315 1409 1913 2101 2209 2613]),1) = 0;
                sam2use(ismember(ds_sal.sampnum(iisam),[2701 2802 2813 2905 2913]),1) = 0;
                sam2use(ismember(ds_sal.sampnum(iisam),[315 514 815 1003 1101 1514 2214 2514 2815]),2) = 0;
                sam2use(ismember(ds_sal.sampnum(iisam),[114 121 219 511 611 1809 1907 2421]),3) = 0;
                sam2use(ismember(ds_sal.sampnum(iisam),[1017 1023 1103]),2:3) = 0;
                ii1 = find(sum(sam2use,2)==1); 
                ds_sal.flag(iisam(ii1)) = max(ds_sal.flag(iisam(ii1)),3);
        end
%%%%%%%%%% msal_standardise_avg %%%%%%%%%%
      
          %%%%%%%%%% moxy_01 %%%%%%%%%%
    case 'moxy_01'
        switch oopt
            case 'oxycsv'
                infile = [root_oxy '/oxy_dy113_' stn_string '.csv'];
            case 'sampnum_parse'
                ds_oxy.statnum = ds_oxy.Cast;
                ds_oxy.niskin = ds_oxy.Niskin;
                ds_oxy.sampnum = ds_oxy.statnum*100+ds_oxy.niskin;
                ds_oxy.oxy_bot = ds_oxy.Bottle;
                ds_oxy.bot_vol = ds_oxy.Bottle1;
                ds_oxy.oxy_temp = ds_oxy.Fixing; 
                ds_oxy.oxy_titre = ds_oxy.Sample;
            case 'flags'
                botoxyflaga(ds_oxy.Blank>=0.1 & botoxyflaga<3) = 3;
                botoxyflagb(ds_oxy.Blank>=0.1 & botoxyflagb<3) = 3;
        end
        %%%%%%%%%% end moxy_01 %%%%%%%%%%

        %%%%%%%%%% moxy_ccalc %%%%%%%%%%
    case 'moxy_ccalc'
        switch oopt
            case 'oxypars'
                vol_reag1 = 0.99; %?
                vol_reag2 = 0.99; %?seems coincidental they're all labelled 0.99g
            case 'blstd'
                vol_std = ds_oxy.Std;
                vol_titre_std = ds_oxy.Standard;
                vol_blank = ds_oxy.Blank;
            case 'botvols'
                obot_vol = ds_oxy.bot_vol;
                if 0 %***
                    fname_bottle = 'ctd/BOTTLE_OXY/bottle_vols.csv'; %***bottle_vols                    ds_bottle = dataset('File', fname_bottle, 'Delimiter', ',');
                    ds_bottle(isnan(ds_bottle.bot_num),:) = [];
                    mb = max(ds_bottle.bot_num); a = NaN+zeros(mb, 1);
                    a(ds_bottle.bot_num) = ds_bottle.bot_vol;
                    iig = find(~isnan(ds_oxy.oxy_bot) & ds_oxy.oxy_bot~=-999);
                    obot_vol = NaN+ds_oxy.oxy_bot; obot_vol(iig) = a(ds_oxy.oxy_bot(iig)); %mL
                end
        end
        %%%%%%%%%% end moxy_ccalc %%%%%%%%%%

        %%%%%%%%%% msec_run_mgridp %%%%%%%%%%
    case 'msec_run_mgridp'
        switch oopt
            case 'regridctd'
                regridctd = 1;
            case 'sections'
                sections = {'sr1b'};
            case 'varlist'
                varlist = [varlist ' fluor transmittance'];
            case 'kstns'
                switch section
                    case 'sr1b'
                        sstring = '[2:31]';
                end
            case 'varuse'
                %varuselist.names = {'botoxy' 'totnit_per_kg' 'phos_per_kg' 'silc_per_kg' 'dic' 'alk' 'cfc11'  'cfc12' 'f113' 'sf6' 'ccl4'};
                %varuselist.names = {'botoxy' 'totnit_per_kg' 'phos_per_kg' 'silc_per_kg' 'dic' 'alk' 'cfc11'  'cfc12' 'f113' 'sf6'};
                varuselist.names = {'botoxy'};
        end
        %%%%%%%%%% end msec_run_mgridp %%%%%%%%%%

        %%%%%%%%%% msam_checkbottles_01 %%%%%%%%%%
    case 'msam_checkbottles_01'
        switch oopt
            case 'section'
                section = '24s';
            case 'docals'
                doocal = 1;
        end
        %%%%%%%%%% end msam_checkbottles_01 %%%%%%%%%%

        %%%%%%%%%% end msam_checkbottles_02 %%%%%%%%%%
    case 'msam_checkbottles_02'
        switch oopt
            case 'section'
                stns = [2:22];
                stnlist = find(stns==stnlocal);
                stnlist = stnlist-2:stnlist+2; stnlist(stnlist<1) = 1; stnlist(stnlist>length(stns)) = length(stns); 
                stnlist = stns(stnlist); stnlist(3) = stnlocal;
                section = 'sr1b';
            case 'docals'
                doocal = 1;
        end
        %%%%%%%%%% end msam_checkbottles_02 %%%%%%%%%%

        %%%%%%%%%% temp_apply_cal %%%%%%%%%%
   case 'temp_apply_cal'
      switch sensor
         case 1
	    %tempout = temp + interp1([0 400 2000 5000],[-.2 -2 -1.6 -2.8],press)*1e-3 + 4.3e-4;
        tempout = temp - .75e-3 - (1.25e-3/5000*press);
	 case 2
	    %tempout = temp + interp1([0 800 5000],[-.5 -1 -0.5],press)*1e-3;
        tempout = temp - 0.6e-3; 
      end
   %%%%%%%%%% end temp_apply_cal %%%%%%%%%%
       
          %%%%%%%%%% cond_apply_cal %%%%%%%%%%
    case 'cond_apply_cal'
        switch sensor
            case 1
                off = interp1([0 300 2000 3500 5000], [-.6 -3 -4.2 -6 -7], press)*1e-3;
            case 2
                off = interp1([0 100 1600 5000], [1.2 0.5 -.8 -2.7], press)*1e-3 + 1.5e-4;
        end
        fac = 1 + off/35; 
        condadj = 0;
        condout = cond.*fac + condadj;
        %%%%%%%%%% cond_apply_cal %%%%%%%%%%
        
        %%%%%%%%%% oxy_apply_cal %%%%%%%%%%
    case 'oxy_apply_cal'
        switch sensor
            case 1
                alpha = 1.08;% - 11e-4*stn;
        beta = 0;%-18 + 2.6e-3*press;
            case 2
                alpha = 1.05;%interp1([0 5000]',[1.035 1.062]',press) + 0.3*1e-4*stn;
        beta = 0;%interp1([0 500 5000],[-1.4 0.5 -0.9],press);
        end
        oxyout = alpha.*oxyin + beta;
        %%%%%%%%%% end oxy_apply_cal %%%%%%%%%%
        
        %%%%%%%%%% mtsg_01 %%%%%%%%%%
%     case 'mtsg_01'
%         switch oopt
%             case 'flag'
%                 flag(ds_sal.sampnum>=313201500 & ds_sal.sampnum<=314010000) = 3;
%         end
%         %%%%%%%%%% end mtsg_01 %%%%%%%%%%
        
        %%%%%%%%%% tsgsal_apply_cal %%%%%%%%%%
    case 'tsgsal_apply_cal'
        switch oopt
            case 'saladj'
                salout = salin - 0.005; % preliminary cal on 14 Feb 2020.
        end
        %%%%%%%%%% end tsgsal_apply_cal %%%%%%%%%%

        %%%%%%%%%% mtsg_cleanup %%%%%%%%%%
    case 'mtsg_cleanup'
        switch oopt
          case 'kbadlims'
	        kbadlims = [
              datenum([2020 2 12 16 32 0]) datenum([2020 2 12 16 46 0])  % tsg being cleaned, flow off
              datenum([2020 2 7 2 47 1]) datenum([2020 2 7 2 51 3])
              datenum([2020 2 7 14 46 47]) datenum([2020 2 7 14 50 49])
              datenum([2020 2 8 2 45 49]) datenum([2020 2 8 2 49 51])
              datenum([2020 2 8 14 45 32]) datenum([2020 2 8 14 49 34])
              datenum([2020 2 9 2 44 50]) datenum([2020 2 9 2 48 51])
              datenum([2020 2 9 14 44 35]) datenum([2020 2 9 14 48 37])
              datenum([2020 2 10 2 43 54]) datenum([2020 2 10 2 47 56])
              datenum([2020 2 10 14 43 37]) datenum([2020 2 10 14 47 39])
              datenum([2020 2 11 2 42 54]) datenum([2020 2 11 2 46 56])
              datenum([2020 2 11 14 42 44]) datenum([2020 2 11 14 46 46])
              datenum([2020 2 12 2 42 3]) datenum([2020 2 12 2 46 5])
              datenum([2020 2 12 14 41 44]) datenum([2020 2 12 14 45 46])
              datenum([2020 2 13 2 40 54]) datenum([2020 2 13 2 44 55])
              datenum([2020 2 13 14 40 34]) datenum([2020 2 13 14 44 36])
              datenum([2020 2 14 2 40 5]) datenum([2020 2 14 2 44 7])
              datenum([2020 2 14 14 39 46]) datenum([2020 2 14 14 43 48])
              datenum([2020 2 15 2 39 7]) datenum([2020 2 15 2 43 9])
              datenum([2020 2 15 14 38 50]) datenum([2020 2 15 14 42 51])
              ];

%           % The other lines are to remove the "Discovery quasi-semidiurnal 
%           % oscillation", which is caused by the seawater pumps changing over.
%           % They were generated by running the following lines:
%           [d,h]=mload('met_tsg_dy113_01.nc','/');
%           d.jday=d.time./24./3600+1;
%           centerpoints=38.1165:.49966:max(d.jday);
%           for n=1:length(centerpoints)
%              ind=find(abs(d.jday-centerpoints(n))<.005);
%              [~,ind2]=max(d.temp_h(ind));
%              fprintf('              datenum([%d %d %d %d %d %.0f]) datenum([%d %d %d %d %d %.0f])\n',...
%                  datevec(d.jday(ind(ind2))+datenum(2020,1,0)-0.0003),...
%                  datevec(d.jday(ind(ind2))+datenum(2020,1,0)+0.0025));
%           end
        end
        %%%%%%%%%% end mtsg_cleanup %%%%%%%%%%


        %%%%%%%%%% mout_cchdo_sam %%%%%%%%%%
   case 'mout_cchdo_sam'
      switch oopt
         case 'expo'
	    expocode = '';%74JC20181103';
            sect_id = 'SR1b, A23';
	 case 'outfile'
	    outfile = [MEXEC_G.MEXEC_DATA_ROOT '/collected_files/sr1b_a23_' expocode];
        %if nocfc; outfile = [outfile '_no_cfc_values']; end
	 case 'headstr'
            headstring = {['BOTTLE,' datestr(now,'yyyymmdd') 'OCPNOCYLF'];... %the last field specifies group, institution, initials
	    '#SHIP: Discovery';...
	    '#Cruise DY113; SR1B and A23';...
	    '#Region: Drake Passage, Weddell Sea, Scotia Sea';...
	    ['#EXPOCODE: ' expocode];...
	    '#DATES: 20200204 - 20200313';...
	    '#Chief Scientist: Y. Firing, NOC';...
	    '#Supported by NERC National Capability NE/N018095/1 (ORCHESTRA)';...% and NERC NE/P019064/1 (TICTOC)';...
	    '#61 stations with 24-place rosette';...
	    '#CTD: Who - Y. Firing; Status - final';...
	    '#Notes: Includes CTDSAL, CTDOXY, SBE35';...
	    '#The CTD PRS;  TMP;  SAL; OXY data are all calibrated and good.';...
	    '#Flags in bottle file set to good for all existing values';...
	    '#CTD files also contain CTDXMISS, CTDFLUOR';...
	    '#Salinity: Who - Y. Firing; Status - final';...
	    '#Notes:';...
        '#Oxygen: Who - N. Ensor; Status - final';...
        '#DEL18O: Who - M. Leng; Status - not yet analysed';...
        '#Notes:';...
        '#These data should be acknowledged with: "Data were collected and made publicly available by the international Global Ship-based Hydrographic Investigations Program (GO-SHIP; http://www.go-ship.org/) with National Capability funding from the UK Natural Environment Research Council to the National Oceanography Centre."'}; %and funding to BGS, and Exeter...
      end
   %%%%%%%%%% end mout_cchdo_sam %%%%%%%%%%

   %%%%%%%%%% mout_cchdo_ctd %%%%%%%%%%
   case 'mout_cchdo_ctd'
      switch oopt
         case 'expo'
	        expocode = '';%74JC20181103';
            sect_id = 'SR1b, A23';
	 case 'outfile'
%	    outfile = [MEXEC_G.MEXEC_DATA_ROOT '/collected_files/sr1b_a23_' expocode '_ct1/sr1b_a23_' expocode];
	    outfile = [MEXEC_G.MEXEC_DATA_ROOT '/collected_files/sr1b_a23_' expocode];
	 case 'headstr'
	    headstring = {['CTD,' datestr(now,'yyyymmdd') 'OCPNOCYLF'];...
	    '#SHIP: Discovery';...
	    '#Cruise DY113; SR1B and A23';...
	    '#Region: Drake Passage, Weddell Sea, Scotia Sea';...
	    ['#EXPOCODE: ' expocode];...
	    '#DATES: 20200204 - 20200313';...
	    '#Chief Scientist: Y. Firing, NOC';...
	    '#Supported by NERC National Capability NE/N018095/1 (ORCHESTRA)';...
	    '#61 stations with 24-place rosette';...
	    '#CTD: Who - Y. Firing; Status - final';...
	    '#Notes: Includes CTDSAL, CTDOXY, SBE35';...
	    '#The CTD PRS;  TMP;  SAL; OXY data are all calibrated and good.';...
	    '# DEPTH_TYPE   : COR';...
   	    '#These data should be acknowledged with: "Data were collected and made publicly available by the International Global Ship-based Hydrographic Investigations Program (GO-SHIP; http://www.go-ship.org/) with National Capability funding from the UK Natural Environment Research Council to the National Oceanography Centre."'};
      end
   %%%%%%%%%% end mout_cchdo_ctd %%%%%%%%%%
 
end
