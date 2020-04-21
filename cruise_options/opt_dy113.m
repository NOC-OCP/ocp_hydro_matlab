switch scriptname
    

        %%%%%%%%%% mctd_02b %%%%%%%%%%
    case 'mctd_02b'
        switch oopt            
            case 'calibs_to_do'
                dooxyhyst = 1;
                doturbV = 0;
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

        %%%%%%%%%% mctd_04 %%%%%%%%%%
    case 'mctd_04'
        switch oopt
            case 'pretreat'
            case 'doloopedit'
                doloopedit = 1;
                ptol = 0.08; %default is not to apply, but this would be the default value if you did
            case 'interp2db'
                %if doloopedit; interp2db = 1; end
        end
        %%%%%%%%%% end mctd_04 %%%%%%%%%%

        
                %%%%%%%%%% mbot_00 %%%%%%%%%%
    case 'mbot_00' %information about niskin bottle numbers
        switch oopt
            case 'nispos'
                %inventory/serial numbers of the niskins in order of 1 to 24
                nis = [2754:2774 2776:2778]; %250002754:250002778
        end
        %%%%%%%%%% end mbot_00 %%%%%%%%%%

        %%%%%%%%%% mbot_01 %%%%%%%%%%
    case 'mbot_01'
        switch oopt
            case 'botflags'
                flag3 = []; flag4 = []; flag9 = []; %[station niskin]
                flag3 = [1 1; 1 20; 2 1; 6 9; 7 5; 7 8; 13 18; 17 9; 22 13; 24 7;...
                         26 9; 29 9; 32 12; 56 12; 62 8; 70 5]; % (possibly) leaking or questionable based on visual
                flag3 = [flag3; 6 14; 20 2; 22 13; 24 17; 24 19]; %sample data suspicious
                flag4 = [1 17; 5 15; 7 6; 7 9; 8 4; 8 7; 14 15; 16 4; ...
                         17 1; 17 4; 19 4; 23 15; 25 2; 25 7; 27 7; 32 5; 33 9; 42 22; 45 9]; 
                     flag4 = [flag4; 59 24; 62 1; 62 9; 67 9; 69 9; 72 9; 87 2; 89 9; 101 14]; %bad (end cap not closed)
                     flag4 = [flag4; 1 1; 8 2; 22 13]; %sample data very suspicious
                flag9 = [13 4; 21 4; 25 4; 26, 4; 41 5; 51 12]; %did not fire
                iif = find(flag3(:,1)==stnlocal); if length(iif)>0; bottle_qc_flag(flag3(iif,2)) = 3; end
                iif = find(flag4(:,1)==stnlocal); if length(iif)>0; bottle_qc_flag(flag4(iif,2)) = 4; end
                iif = find(flag9(:,1)==stnlocal); if length(iif)>0; bottle_qc_flag(flag9(iif,2)) = 9; end
                %cast 45: some question about niskins closing at wrong
                %depth if damaged by slack wire but probably ok
        end
   %%%%%%%%%% end mbot_01 %%%%%%%%%%
   
           %%%%%%%%%% mfir_03 %%%%%%%%%%
    case 'mfir_03'
        avi_opt = [0 121/24]-1/24; %default is to linearly interpolate, not average
        %%%%%%%%%% end mfir_03 %%%%%%%%%%
        
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
              if stnlocal == 20
                doscanedit = 1;
	            sevars = {'temp2'
                    'cond2' 
                    'oxygen_sbe2'};
                sestring = {'y = x1; y(x2 >= 23658) = NaN;'
                    'y = x1; y(x2 >= 23658) = NaN;'
                    'y = x1; y(x2 >= 23658) = NaN;'};
              end

        end
        %%%%%%%%%% end mctd_rawedit %%%%%%%%%%

        %%%%%%%%%% set_cast_params_cfgstr %%%%%%%%%%
    case 'set_cast_params_cfgstr'
        switch oopt
            case 'ladcpopts'
                if stnlocal>=5
           p.ambiguity = 3.3;
           p.vlim = 3.3;
        end
        if ismember(stnlocal,[85])
           p.btrk_mode = 2; %calculate our own since for some reason the rdi bottom track didn't work
        end
        end
        %%%%%%%%%% end set_cast_params_cfgstr %%%%%%%%%%

        %%%%%%%%%% populate_station_depths %%%%%%%%%%
    case 'populate_station_depths'
        switch oopt
            case 'fnin'
                fnin = [root_ctddep '/station_depths_' mcruise '.txt'];
                depmeth = 4; %calculate from ladcp data
                %if stnlocal==85
                %    depmeth = 3; %from ctd
                %end
            case 'bestdeps'
        end
        %%%%%%%%%% end populate_station_depths %%%%%%%%%%

                %%%%%%%%%% station_summary %%%%%%%%%%
    case 'station_summary'
        switch oopt
            case 'optsams'
                snames = {'noxy'; 'nnuts'; 'no18s'; 'nnisos'}; % Use s suffix for variable to count number on ship for o18 c13 chl, which will be zero
                snames_shore = {'noxy_shore'; 'nnut'; 'no18'; 'nniso'}; % can use name without _shore, because all samples are analysed ashore
                sgrps = { {'botoxy'} %list of oxy variables
                    {'silc' 'phos' 'totnit'} %list of nuts variables
                    {'del18o'} % BGS del O 18
                    {'del15n' 'del30si'}
                    };
                sashore = [0; 1; 1; 1]; %count samples to be analysed ashore? % can't presently count botoxy_flag == 1
            case 'comments' % set comments
                comments{1} = 'Test station (SR1b_08)';
                comments{2} = 'Start of SR1b';
                comments{31} = 'End of SR1b';
                comments{32} = 'Start of A23';
                comments{43} = 'moved for iceberg';
                comments{62} = 'End of A23';
                comments{63} = 'Start of Cumberland Bay';
                comments{79} = 'End of Cumberland Bay';
                comments{80} = 'Start of NSR';
                comments{92} = 'Break after NSR_16 for FI call';
                comments{93} = 'Resume NSR near FI';
                comments{104} = 'Repeat of NSR_16';
            case 'parlist'
                parlist = [' sal'; ' oxy'; ' nut'; 'd18o'; 'nniso'];
            case 'varnames'
                varnames={'statnum' 'time_start' 'time_bottom' 'time_end' 'lat' 'lon' 'cordep' 'maxd' 'ndpths' 'nsal' 'noxy' 'nnut' 'no18' 'nniso'};
                varunits={'number' 'seconds' 'seconds' 'seconds' 'degrees' 'degrees' 'metres' 'metres' 'number' 'number' 'number' 'number' 'number' 'number'};
            case 'stnadd'
                stnadd = [73 74 75 77 79]; % force add of these stations to station list
        end
        %%%%%%%%%% end station_summary %%%%%%%%%%
        
        
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
                %make the next two variables 1 if you want to check the
                %salinity readings (do this when you first read in a
                %station or set of stations)
                check_sal_runs = 0; %plot standards and sample runs to compare before averaging
            case 'plot_stations'
                plot_all_stations = 0; 
                iistno = 1:length(stnos);
            case 'std2use'
                std2use(ismember(ssns, [8 16 18 19 26 27 27.5 31 33 47 57 61]),1) = 0;
                std2use(ssns==4, 2) = 0;
                std2use(ismember(ssns,[3 13 23 39 55]),3) = 0;
            case 'fillstd'
                xoff = ds_sal.runtime; 
            case 'sam2use'
                sb1 = [115 123 201 208 301 303 403 413 415 505 510 605 703 817 914];
                sb1 = [sb1 1315 1409 1913 2209 2613 2701 2802 2813 2905 2913 3101];
                sb1 = [sb1 3201 3302 3304 3706 3717 4021 4113 4523 4914 5312 6202 7001 8001 9701 10016 10101 10418];
                sam2use(ismember(ds_sal.sampnum(iisam),sb1),1) = 0; %1017 1023
                sb2 = [315 514 815 1003 1101 1514 2101 2214 2514 2815 3218 3221];
                sb2 = [sb2 3223 3606 3712 4217 4403 4709 5710 5915 8208];
                sam2use(ismember(ds_sal.sampnum(iisam),sb2),2) = 0;
                sb3 = [114 121 219 511 611 1809 1907 2421 3503 3711 3905];
                sb3 = [sb3 4221 4805 5105 5109 5411 5815 5921 5923 8107 8117 8503 8910 10206];
                sam2use(ismember(ds_sal.sampnum(iisam),sb3),3) = 0;
                sam2use(ismember(ds_sal.sampnum(iisam),[1017 1023 1103]),2:3) = 0;
                ii1 = find(sum(sam2use,2)==1); 
                ds_sal.flag(iisam(ii1)) = max(ds_sal.flag(iisam(ii1)),3);
                ds_sal.flag(ds_sal.sampnum==2213) = 3;
        end
%%%%%%%%%% msal_standardise_avg %%%%%%%%%%
      
          %%%%%%%%%% moxy_01 %%%%%%%%%%
    case 'moxy_01'
        switch oopt
            case 'oxycsv'
                infile = [root_oxy '/oxy_dy113_' stn_string '.csv'];
            case 'sampnum_parse'
                ds_oxy.sampnum = ds_oxy.statnum*100+ds_oxy.niskin;
            case 'flags'
                botoxyflaga(botoxyflaga==2.3) = 2; %these are mostly 'tiny bubbles'
                botoxyflagb(botoxyflagb==2.3) = 2; %and replicates show they don't make a difference
                %botoxyflaga(ismember(ds_oxy.statnum, [1:15 20:24])) = 4; 
                %botoxyflagb(ismember(ds_oxy.statnum, [1:15 20:24])) = 4; 
                %botoxyflaga(ismember(ds_oxy.statnum, [16:19])) = 3; 
                %botoxyflagb(ismember(ds_oxy.statnum, [16:19])) = 3; 
        end
        %%%%%%%%%% end moxy_01 %%%%%%%%%%

        %%%%%%%%%% moxy_ccalc %%%%%%%%%%
    case 'moxy_ccalc'
        switch oopt
            case 'oxypars'
                vol_reag1 = 0.99; %?
                vol_reag2 = 0.99; %?seems coincidental they're all labelled 0.99g
            case 'blstd'
                %vol_std = ds_oxy.vol_std;
                %vol_titre_std = ds_oxy.vol_titre_std;
                %vol_blank = ds_oxy.vol_blank;
                vol_std = 5;
                if stnlocal<40
                   vol_titre_std = 0.4438;
                   vol_blank = -0.0053; 
                else %new sodthio batch. why does this affect the blank though? 
                    vol_titre_std = 0.4491;
                    vol_blank = -0.0006; %***
                end
            case 'botvols'
                obot_vol = ds_oxy.bot_vol;
        end
        %%%%%%%%%% end moxy_ccalc %%%%%%%%%%

                %%%%%%%%%% msam_ashore_flag %%%%%%%%%%
    case 'msam_ashore_flag'
        switch samtype
            case 'all'
                flagnames = {'del18o_flag','silc_flag','phos_flag','totnit_flag','no2_flag','del15n_flag','del30si_flag'};
                fnin = [mgetdir('M_BOT_ISO') '/dy113_ashore_samples_log.csv'];
                ds_iso = dataset('File',fnin,'Delimiter',','); %csv file including text comments
                ds_iso.sampnum = ds_iso.cast*100+ds_iso.niskin;
                flagvals = 1;
                clear sampnums
                ii = find(~isnan(ds_iso.d18o_sample)); sampnums(1,1) = {ds_iso.sampnum(ii)};
                stations = floor(ds_iso.sampnum(ii)/100);
                ii = find(ds_iso.nuts_nsamp>0); sampnums(2,1) = {ds_iso.sampnum(ii)};
                stations = [stations; floor(ds_iso.sampnum(ii)/100)];
                sampnums(3,:) = sampnums(2,:); sampnums(4,:) = sampnums(2,:); sampnums(5,:) = sampnums(2,:);
                ii = find(ds_iso.niso_nsamp>0); sampnums(6,1) = {ds_iso.sampnum(ii)};
                stations = [stations; floor(ds_iso.sampnum(ii)/100)];
                ii = find(ds_iso.siiso_nsamp>0); sampnums(7,1) = {ds_iso.sampnum(ii)};
                stations = [stations; floor(ds_iso.sampnum(ii)/100)];
        end
        %%%%%%%%%% end msam_ashore_flag %%%%%%%%%%

        %%%%%%%%%% msec_run_mgridp %%%%%%%%%%
    case 'msec_run_mgridp'
        switch oopt
            case 'regridctd'
                regridctd = 1;
            case 'sections'
                sections = {'sr1b' 'a23' 'cb' 'nsr'};
            case 'varlist'
                varlist = [varlist ' fluor transmittance'];
            case 'kstns'
                switch section
                    case 'sr1b'
                        sstring = '[2:31]';
                    case 'a23'
                        sstring = '[32:62]';
                    case 'cb'
                        sstring = '[63:79]';
                    case 'nsr'
                        sstring = '[80:92 104:-1:93]';
                end
            case 'varuse'
                varuselist.names = {'botoxy'};
        end
        %%%%%%%%%% end msec_run_mgridp %%%%%%%%%%

                %%%%%%%%%% m_maptracer %%%%%%%%%%
    case 'm_maptracer'
        switch oopt
            case 'kstatgroups'
                kstatgroups = {1 [2:31] [32:62] [63:79] [80:92 104:-1:93]};
        end
        %%%%%%%%%% end m_maptracer %%%%%%%%%%


        %%%%%%%%%% msam_checkbottles_01 %%%%%%%%%%
    case 'msam_checkbottles_01'
        switch oopt
            case 'section'
                if stnlocal<=31
                    section = 'sr1b';
                elseif stnlocal<=62
                    section = 'a23';
                elseif stnlocal<=79
                    section = 'cb';
                else
                  section = 'nsr';
                end
            case 'docals'
                doocal = 1;
        end
        %%%%%%%%%% end msam_checkbottles_01 %%%%%%%%%%

        %%%%%%%%%% end msam_checkbottles_02 %%%%%%%%%%
    case 'msam_checkbottles_02'
        switch oopt
            case 'section'
                if stnlocal<=31
                   stns = [2:31];
                   section = 'sr1b';
                elseif stnlocal<=62
                    stns = [32:62];
                    section = 'a23';
                elseif stnlocal<=79
                    stns = [63:79];
                    section = 'cb';
                else
                    stns = [80:92 104:-1:93];
                    section = 'nsr';
                end
                stnlist = find(stns==stnlocal);
                stnlist = stnlist-2:stnlist+2; stnlist(stnlist<1) = 1; stnlist(stnlist>length(stns)) = length(stns); 
                stnlist = stns(stnlist); stnlist(3) = stnlocal;
            case 'docals'
                doocal = 1;
        end
        %%%%%%%%%% end msam_checkbottles_02 %%%%%%%%%%

        %%%%%%%%%% temp_apply_cal %%%%%%%%%%
   case 'temp_apply_cal'
      switch sensor
         case 1
	    tempout = temp - 1.5e-5*stn + interp1([0 5000],[0 -1.5]*1e-3, press) - 1.1e-4; %interp1([0 5000],[.75 2],press)*1e-3; 
        case 2
        tempout = temp - 1e-5*stn - 3.8e-4;
      end
   %%%%%%%%%% end temp_apply_cal %%%%%%%%%%
       
          %%%%%%%%%% cond_apply_cal %%%%%%%%%%
    case 'cond_apply_cal'
        switch sensor
            case 1
                %off = interp1([0 300 2000 3500 5000], [-.6 -3 -4.2 -6 -7], press)*1e-3;
                off = interp1([0 5000], [-1.8 -6.5], press)*1e-3 - 7.2e-4;
            case 2
                %off = interp1([0 100 1600 5000], [1.2 0.5 -.8 -2.7], press)*1e-3 + 1.5e-4;
                off = interp1([0 5000], [1.4 -2], press)*1e-3 - 7e-4;
        end
        fac = 1 + off/35; 
        condadj = 0;
        condout = cond.*fac + condadj;
        %%%%%%%%%% cond_apply_cal %%%%%%%%%%
        
        %%%%%%%%%% oxy_apply_cal %%%%%%%%%%
    case 'oxy_apply_cal'
        switch sensor
            case 1
                alpha = 1.025;
        beta = interp1([0 5000],[1.8 12.8],press) - 1.5e-2*stn;
            case 2
               alpha = 1.029;%interp1([0 5000]',[1.035 1.062]',press) + 0.3*1e-4*stn;
        beta = interp1([0 500 5000],[.5 .8 9],press) + 1e-2*stn;
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

        %%%%%%%%%% mday_01_clean_av %%%%%%%%%%
    case 'mday_01_clean_av'
        switch oopt
          case 'uway_apply_cal'
          switch abbrev
            case 'met_tsg'
                sensors_to_cal={'fluo','trans'};
                sensorcals={'y=(x1-0.045)*11.4' % fluorometer: s/n WS3S-351P
                    'y=(x1-0.004)/(4.700-0.004)*100' %transmissometer: s/n CST-1852PR
                    };
                sensorunits={'ug/l','percent'};
            case 'surflight'
                % fix radiometers on DY113 - before normal calibration
                if ~exist([otfile '.nc'])
                   unix(['/bin/cp ' infile '.nc ' otfile '.nc']);
                end
                h = m_read_header(otfile);
                MEXEC_A.MARGS_IN = {
                   otfile
                   'y' % yes, overwrite file
                   '8' % rename vars
                   '3 4 5 6' % variable number to rename - ppar, ptir, spar, stir
                   'ppar_orig' % new name
                   '/' % keep existing unit (volt*10^-5?)
                   'ptir_orig' % new name
                   '/' % keep existing unit (volt*10^-5?)
                   'spar_orig' % new name
                   '/' % keep existing unit (volt*10^-5?)
                   'stir_orig' % new name
                   '/' % keep existing unit (volt*10^-5?)
                   '-1' % done
                   '/' % quit
                };
                mheadr
                MEXEC_A.MARGS_IN = {
                   otfile
                   'y' % yes, overwrite file
                   'ppar_orig' % variable to calibrate
                   'ppar_orig ptir_orig spar_orig stir_orig' % input variables for calibration
                   ['plateaus=find(diff(x1)==0 & diff(x2)==0 & diff(x3)==0 & diff(x4)==0);',...
                    'plateau_end=[plateaus(find(diff(plateaus)~=1)),plateaus(end)];',...
                    'plateau_start=[plateaus(1),plateaus(find(diff(plateaus)~=1)+1)];',...
                    'plateau_length=plateau_end-plateau_start+1;',... % only remove plateaus longer than two points
                    'plateau_mask=zeros(size(x1));plateau_mask(plateaus+1)=1;',... % set plateaus to 1 in mask
                    'plateau_mask(plateau_start)=0;',... % keep first point of each plateau
                    'ind_to_keep=find(plateau_length<=2);',... % only remove plateaus longer than two points
                    'for q=1:length(ind_to_keep),',...
                       'plateau_mask(plateau_start(ind_to_keep(q)):plateau_end(ind_to_keep(q)))=0;',...
                    'end,',...
                    'y=x1;y(plateau_mask==1)=nan;'] % function for calibration
                   'ppar' % new name for output variable
                   '/' % new unit for output variable (or '/' to retain existing)
                   'ptir_orig' % variable to calibrate
                   'ptir_orig ppar' % input variables for calibration
                   'y=x1;y(isnan(x2))=nan;' % function for calibration
                   'ptir' % new name for output variable
                   '/' % new unit for output variable (or '/' to retain existing)
                   'spar_orig' % variable to calibrate
                   'spar_orig ppar' % input variables for calibration
                   'y=x1;y(isnan(x2))=nan;' % function for calibration
                   'spar' % new name for output variable
                   '/' % new unit for output variable (or '/' to retain existing)
                   'stir_orig' % variable to calibrate
                   'stir_orig ppar' % input variables for calibration
                   'y=x1;y(isnan(x2))=nan;' % function for calibration
                   'stir' % new name for output variable
                   '/' % new unit for output variable (or '/' to retain existing)
                   ' ' % quit
                   };
                mcalib2
                
                sensors_to_cal={'ppar','ptir','spar','stir'}; 
                sensorcals={'y=x1*1.061' % port PAR: s/n 28562
                    'y=x1*1.100' % port TIR: 973134
                    'y=x1*0.9398' % stb PAR: s/n 28563
                    'y=x1*1.135'}; % stb TIR: 994132
                % the surfmet instrument box is outputting in V*1e-5 already
                sensorunits={'W/m2','W/m2','W/m2','W/m2'};
            case 'attphins'
                sensors_to_cal={'roll'};
                sensorcals = {'y=-x1'};
                % the phins is incorrectly applying a -1 to its pashr
                % messages, which is ok for pitch because the instrument
                % is installed the reverse of the convention in techsas
                % comments. However, roll is now opposite to Phins convention
                % and specs for PASHR message in the Phins manual
                sensorunits = {'/'}; % keep "degree" as unit
          end
        end
        %%%%%%%%%% end mday_01_clean_av %%%%%%%%%%
        
        %%%%%%%%%% tsgsal_apply_cal %%%%%%%%%%
    case 'tsgsal_apply_cal'
        switch oopt
            case 'saladj'
                jday=time./86400+1;
                adj=interp1([38 51.666 51.667 64 65 75],...
                    [0.0040 0.0114 -0.0034 0.0100 -0.0034 0.0045],jday,'linear','extrap');
                salout=salin+adj; % final cal on 10 Mar 2020.
                % calculated as follows (after running mtsg_bottle_compare):
%                 segment1=polyfit(db.time(db.time<51.666&~isnan(sdiff)),sdiff(db.time<51.666&~isnan(sdiff)),1)
%                 segment2=polyfit(db.time(db.time>51.666&db.time<64&~isnan(sdiff)),sdiff(db.time>51.666&db.time<64&~isnan(sdiff)),1)
%                 segment3=polyfit(db.time(db.time>64&~isnan(sdiff)),sdiff(db.time>64&~isnan(sdiff)),1)
%                 adj1=polyval(segment1,[38 51.666]);
%                 adj2=polyval(segment2, [51.667 64]);
%                 adj3=polyval(segment3, [65 75]);
%                 -[adj1 adj2 adj3]
%                 adj=interp1([38 51.666 51.667 64 65 75],...
%                     -[adj1 adj2 adj3],jday,'linear','extrap');
            case 'tempadj'
                jday=time./86400+1;
                adj=zeros(size(jday))-0.267;
                adj(jday>=64.50833333)=-0.391; % final cal on 10 Mar 2020.
                % polyval([-0.0307 -0.2352],log(8.5-tempin)); % preliminary cal on 1 Mar 2020.
                tempout=tempin+adj; 
        end
        %%%%%%%%%% end tsgsal_apply_cal %%%%%%%%%%

        %%%%%%%%%% mtsg_bottle_compare %%%%%%%%%%
    case 'mtsg_bottle_compare'
        switch oopt
            case 'usecal'
                usecal=1;
        end
        %%%%%%%%%% end mtsg_bottle_compare %%%%%%%%%%

        %%%%%%%%%% mtsg_cleanup %%%%%%%%%%
    case 'mtsg_cleanup'
        switch oopt
          case 'kbadlims'
	        kbadlims = [
              datenum([2020 2 1 0 0 0]) datenum([2020 2 6 15 6 0]) % tsg flow off at start of cruise
              datenum([2020 2 12 16 30 35]) datenum([2020 2 12 16 46 0])  % tsg being cleaned, flow off
              datenum([2020 2 20 15 48 30]) datenum([2020 2 20 16 09 0])  % tsg being cleaned, flow off
              datenum([2020 2 24 14 42 07]) datenum([2020 2 24 14 50 38])  % tsg being cleaned, flow off
              datenum([2020 3 2 16 12 15]) datenum([2020 3 5 14 59 35])  % in Stanley, flow off
              datenum([2020 3 11 16 16 52]) datenum([2020 3 31 23 59 59]) % tsg flow off at end of cruise
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
              datenum([2020 2 16 2 38 10]) datenum([2020 2 16 2 42 12])
              datenum([2020 2 16 14 37 51]) datenum([2020 2 16 14 41 53])
              datenum([2020 2 17 2 37 12]) datenum([2020 2 17 2 41 14])
              datenum([2020 2 17 14 36 53]) datenum([2020 2 17 14 40 55])
              datenum([2020 2 18 2 36 14]) datenum([2020 2 18 2 40 16])
              datenum([2020 2 18 14 35 54]) datenum([2020 2 18 14 39 56])
              datenum([2020 2 19 2 35 17]) datenum([2020 2 19 2 39 19])
              datenum([2020 2 19 14 34 55]) datenum([2020 2 19 14 38 57])
              datenum([2020 2 20 2 34 11]) datenum([2020 2 20 2 38 13])
              datenum([2020 2 20 14 33 55]) datenum([2020 2 20 14 37 57])
              datenum([2020 2 21 2 33 12]) datenum([2020 2 21 2 37 14])
              datenum([2020 2 21 14 32 50]) datenum([2020 2 21 14 36 52])
              datenum([2020 2 22 2 32 13]) datenum([2020 2 22 2 36 15])
              datenum([2020 2 22 14 31 53]) datenum([2020 2 22 14 35 55])
              datenum([2020 2 23 2 31 15]) datenum([2020 2 23 2 35 17])
              datenum([2020 2 23 14 31 0]) datenum([2020 2 23 14 35 2])
              datenum([2020 2 24 2 30 22]) datenum([2020 2 24 2 34 24])
              datenum([2020 2 24 14 30 0]) datenum([2020 2 24 14 34 2])
              datenum([2020 2 25 2 29 15]) datenum([2020 2 25 2 33 17])
              datenum([2020 2 25 14 28 51]) datenum([2020 2 25 14 32 53])
              datenum([2020 2 26 2 28 15]) datenum([2020 2 26 2 32 16])
              datenum([2020 2 26 14 27 53]) datenum([2020 2 26 14 31 55])
              datenum([2020 2 27 2 27 15]) datenum([2020 2 27 2 31 17])
              datenum([2020 2 27 14 26 51]) datenum([2020 2 27 14 30 53])
              datenum([2020 2 28 2 26 14]) datenum([2020 2 28 2 30 16])
              datenum([2020 2 28 14 25 55]) datenum([2020 2 28 14 29 57])
              datenum([2020 2 29 2 25 19]) datenum([2020 2 29 2 29 21])
              datenum([2020 2 29 14 24 58]) datenum([2020 2 29 14 28 60])
              datenum([2020 3 1 2 24 21]) datenum([2020 3 1 2 28 22])
              datenum([2020 3 1 14 24 3]) datenum([2020 3 1 14 28 4])
              datenum([2020 3 2 2 23 25]) datenum([2020 3 2 2 27 27])
              datenum([2020 3 2 14 23 6]) datenum([2020 3 2 14 27 8])
              datenum([2020 3 6 2 30 37]) datenum([2020 3 6 2 34 39])
              datenum([2020 3 6 14 29 43]) datenum([2020 3 6 14 33 45])
              datenum([2020 3 7 2 29 39]) datenum([2020 3 7 2 33 41])
              datenum([2020 3 7 14 28 46]) datenum([2020 3 7 14 32 48])
              datenum([2020 3 8 2 28 41]) datenum([2020 3 8 2 32 43])
              datenum([2020 3 8 14 27 49]) datenum([2020 3 8 14 31 51])
              datenum([2020 3 9 2 27 44]) datenum([2020 3 9 2 31 45])
              datenum([2020 3 9 14 26 54]) datenum([2020 3 9 14 30 56])
              datenum([2020 3 10 2 26 50]) datenum([2020 3 10 2 30 52])
              datenum([2020 3 10 14 25 57]) datenum([2020 3 10 14 29 59])
              datenum([2020 3 11 2 18 41]) datenum([2020 3 11 2 22 43])
              datenum([2020 3 11 14 24 55]) datenum([2020 3 11 14 28 57])
              ];

%           % The non-cleaning lines are to remove the "Discovery quasi-semidiurnal 
%           % oscillation", which is caused by the seawater pumps changing over.
%           % They were generated by running the following lines:
%           [d,h]=mload('met_tsg_dy113_01.nc','/');
%           d.jday=d.time./24./3600+1;
%           centerpoints=[38.1165:.49966:63,66.1048:.49966:max(d.jday)];
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
	    expocode = '74EQ20200203';
            sect_id = 'SR1b, A23';
	 case 'outfile'
	    outfile = [MEXEC_G.MEXEC_DATA_ROOT '/collected_files/sr1b_a23_' expocode];
	 case 'headstr'
            headstring = {['BOTTLE,' datestr(now,'yyyymmdd') 'OCPNOCYLF'];... %the last field specifies group, institution, initials
	    '#SHIP: Discovery';...
	    '#Cruise DY113; SR1B and A23';...
	    '#Region: Drake Passage, Weddell Sea, Scotia Sea';...
	    ['#EXPOCODE: ' expocode];...
	    '#DATES: 20200203 - 20200313';...
	    '#Chief Scientist: Y. Firing, NOC';...
	    '#Supported by NERC National Capability NE/N018095/1 (ORCHESTRA)';...
	    '#104 stations with 24-place rosette';...
	    '#Notes: PI for SR1B section (1-31): Y. Firing; PI for A23 section (32-62): E.P. Abrahamsen';...
	    '#CTD: Who - Y. Firing; Status - final';...
	    '#Notes: Includes CTDSAL, CTDOXY, SBE35';...
	    '#The CTD PRS;  TMP;  SAL; OXY data are all calibrated and good.';...
	    '#CTD files also contain CTDXMISS, CTDFLUOR';...
	    '#Salinity: Who - Y. Firing; Status - final';...
        '#Oxygen: Who - N. Ensor; Status - final';...
        '#Nutrients: Who - E. Mawji; Status - not yet analysed';...
        '#DELO18: Who - M. Leng; Status - not yet analysed';...
        '#Nutrient isotopes: Who - R. Tuerena; Status - not yet analysed';...
        '#These data should be acknowledged with: "Data were collected and made publicly available by the international Global Ship-based Hydrographic Investigations Program (GO-SHIP; http://www.go-ship.org/) with National Capability funding from the UK Natural Environment Research Council to the National Oceanography Centre and the British Antarctic Survey."'}; 
      end
   %%%%%%%%%% end mout_cchdo_sam %%%%%%%%%%

   %%%%%%%%%% mout_cchdo_ctd %%%%%%%%%%
   case 'mout_cchdo_ctd'
      switch oopt
         case 'expo'
	        expocode = '74EQ20200203';
            sect_id = 'SR1b, A23';
	 case 'outfile'
	    outfile = [MEXEC_G.MEXEC_DATA_ROOT '/collected_files/sr1b_a23_' expocode '_ct1/sr1b_a23_' expocode];
	 case 'headstr'
	    headstring = {['CTD,' datestr(now,'yyyymmdd') 'OCPNOCYLF'];...
	    '#SHIP: Discovery';...
	    '#Cruise DY113; SR1B and A23';...
	    '#Region: Drake Passage, Weddell Sea, Scotia Sea';...
	    ['#EXPOCODE: ' expocode];...
	    '#DATES: 20200203 - 20200313';...
	    '#Chief Scientist: Y. Firing, NOC';...
	    '#Supported by NERC National Capability NE/N018095/1 (ORCHESTRA)';...
	    '#104 stations with 24-place rosette';...
	    '#Notes: PI for SR1B section (1-31): Y. Firing; PI for A23 section (32-62): E.P. Abrahamsen';...
        '#CTD: Who - Y. Firing; Status - final';...
	    '#Notes: Includes CTDSAL, CTDOXY, SBE35';...
	    '#The CTD PRS;  TMP;  SAL; OXY data are all calibrated and good.';...
	    '# DEPTH_TYPE   : COR';...
        '#These data should be acknowledged with: "Data were collected and made publicly available by the international Global Ship-based Hydrographic Investigations Program (GO-SHIP; http://www.go-ship.org/) with National Capability funding from the UK Natural Environment Research Council to the National Oceanography Centre and the British Antarctic Survey."'}; 
      end
   %%%%%%%%%% end mout_cchdo_ctd %%%%%%%%%%
 
end
