switch scriptname
        
        %%%%%%%%%% mbot_00 %%%%%%%%%% added by Kristin, 10/10/2020
    case 'mbot_00' %information about niskin bottle numbers
        switch oopt
            case 'nispos'
                %inventory/serial numbers of the niskins in order of 1 to 24
                nis = [2754:2774 2776:2778]; %250002754:250002778
        end
        %%%%%%%%%% end mbot_00 %%%%%%%%%%
        
        %%%%%%%%%% mbot_01 %%%%%%%%%% added by Kristin, 10/10/2020
    case 'mbot_01'
        switch oopt
            case 'botflags'
                % CTD has only 12 bottles, set every 2nd bottle 9: did not
                % fire
                bottle_qc_flag(2:2:24) = 9;
                % set individual flags for each cast [station_number bottle_number]
                flag3 = []; flag4 = []; flag9 = []; %[station niskin]
                %flag3 = []; % (possibly) leaking or questionable based on visual
                %flag3 = [flag3; 6 14; 20 2; 22 13; 24 17; 24 19]; %sample data suspicious
                flag4 = [1 15; 1 21; 2 1; 3 11;]; %bad (end cap not closed)
                %     flag4 = [flag4; 1 1; 8 2; 22 13]; %sample data very suspicious
                %flag9 = []; %did not fire
                %iif = find(flag3(:,1)==stnlocal); if length(iif)>0; bottle_qc_flag(flag3(iif,2)) = 3; end
                iif = find(flag4(:,1)==stnlocal); if length(iif)>0; bottle_qc_flag(flag4(iif,2)) = 4; end
                %iif = find(flag9(:,1)==stnlocal); if length(iif)>0; bottle_qc_flag(flag9(iif,2)) = 9; end
                %cast 45: some question about niskins closing at wrong
                %depth if damaged by slack wire but probably ok
        end
        %%%%%%%%%% end mbot_01 %%%%%%%%%
        
        %%%%%%%%%% populate_station_depths %%%%%%%%%%
    case 'populate_station_depths'
        switch oopt
            case 'depth_source'
                depmeth = 3; %calculate from CTD depth and altimeter reading (will load and update station_depths.mat)
            case 'bestdeps'
                ii = find(bestdeps(:,1)==3); bestdeps(ii,2) = 1787; % from CTD+Altim
        end
        %%%%%%%%%% end populate_station_depths %%%%%%%%%%
        
        %%%%%%%%%% mvad_01 %%%%%%%%%%
    case 'mvad_01'
        switch oopt
            case 'files'
                pre1 = ['postprocessing/DY120/proc_editing/' inst nbbstr ];
                datadir = [root_vmadcp '/' pre1 '/contour'];
                fnin = [datadir '/' inst nbbstr '.nc'];
                dataname = [inst '_' mcruise '_01'];
        end
        %%%%%%%%%% end mvad_01 %%%%%%%%%%
        
        
        %%%%%%%%%% msal_standardise_avg %%%%%%%%%%
    case 'msal_standardise_avg'
        switch oopt
            case 'salcsv'
                sal_csv_file = 'sal_dy120_01.csv';
            case 'check_sal_runs'
                check_sal_runs = 1;
                calc_offset = 1;
                plot_all_stations = 1;
            case 'k15'
                sswb = 163; %ssw batch
                msal_ssw
                ds_sal.K15 = zeros(size(ds_sal.sampnum));
                ds_sal.K15(iistd) = ssw_batches(ssw_batches(:,1)==sswb,2)/2;
            case 'cellT'
                ds_sal.cellT = 21+zeros(length(ds_sal.sampnum),1);
            case 'std2use'
                %                 std2use([47 68 121],1) = 0;
                %                 std2use([50],2) = 0;
                %                 std2use([61],3) = 0;
            case 'sam2use'
                %                 sam2use(51,2) = 0;
                %                 sam2use([2587 2896],3) = 0;
            case 'fillstd'
                %add the start standard--can add it at the end because we'll
                %use time to interpolate
                %%                ds_sal.sampnum = [ds_sal.sampnum; 999000];
                %%                ds_sal.offset(end) = 0;
                %%                ds_sal.runtime(end) = ds_sal.runtime(1)-1/60/24; %put it 1 minute before sample 1
                %%machine was re-standardised before running stn 68
                %ds_sal.sampnum = [ds_sal.sampnum; 999097.5];
                %ds_sal.offset(end) = 4e-6;
                %ds_sal.runtime(end) = ds_sal.runtime(ds_sal.sampnum==6801)-1/60/24;
                %this half-crate had no standard at the end so use the one
                %from the beginning
        end
        %%%%%%%%%% msal_standardise_avg %%%%%%%%%%
        
        %%%%%%%%%% cond_apply_cal %%%%%%%%%% added by KB
    case 'cond_apply_cal'
        switch sensor
            case 1
                if ~isempty(find(1:10 == stn));
                    fac = 0.99997559;
                    condadj = 0;
                    %calculated with script /local/users/pstar/dy120/mcruise/data/mexec_processing_scripts/ctd_cal_dy120.m
                end
            case 2
                if ~isempty(find(1:10 == stn));
                    fac = 1.00004201;
                    condadj = (stn.*-0.00012320+0.00067593);
                    % station dependent
                    %calculated with script /local/users/pstar/dy120/mcruise/data/mexec_processing_scripts/ctd_cal_dy120.m
                end
        end
        condout = cond.*fac+condadj;
        %%%%%%%%%% cond_apply_cal %%%%%%%%%%
        
        %%%%%%%%%% oxy_apply_cal %%%%%%%%%%
    case 'oxy_apply_cal'
        switch sensor
            case 1
                alpha = 0.9976;
                beta = -0.93 + 0.00143.*press;
            case 2
                alpha = 0.9724;
                beta = -1.46 + 0.00223.*press;
        end
        oxyout = alpha.*oxyin+beta;
        %%%%%%%%%% end oxy_apply_cal %%%%%%%%%%
        
        %%%%%%%%%% mday_01_clean_av %%%%%%%%%% added by KB
    case 'mday_01_clean_av'
        switch oopt
            case 'uway_apply_cal'
                switch abbrev
                    case 'met_tsg'
                        sensors_to_cal={'fluo','trans'};
                        sensorcals={'y=(x1-0.055)*14.8' % fluorometer: s/n WS3S-246 (changed KB)
                            'y=(x1-0.010)/(4.698-0.010)*100' %transmissometer: s/n CST-1131PR (changed KB)
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
                        sensorcals={'y=x1*1.011' % port PAR: s/n 48927 (changed KB)
                            'y=x1*1.017' % port TIR: 962276 (changed KB)
                            'y=x1*0.9398' % stb PAR: s/n 28563 (ok)
                            'y=x1*0.976'}; % stb TIR: 962301 (changed KB)
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
                adj= 0.00021012.*jday -0.05784;
                salout=salin+adj;% final cal on 29 Oct 2020.
                % calculated as follows (after running mtsg_bottle_compare):
                %                 sdiff = db.salinity_adj-tsals; % bak jc191: I regard this as a bug fix. Offset should be bottle minus tsg, so the quantity is the additive correction to be applied ot the tsg
                %                 sdiff_std = nanstd(sdiff);
                %                 sdiff_mean = nanmean(sdiff);
                %                 idx = find(abs(sdiff)>3*sdiff_std);
                %                 sdiff(idx)=NaN;
                %                 sdiffall = sdiff;
                %                 x_lim = [283 db.time(end)];
                %                 segment2=polyfit(db.time(db.time>x_lim(1)&~isnan(sdiffall)),...
                %                     sdiffall(db.time>x_lim(1)&~isnan(sdiffall)),1)
                %                 adj2= segment2(1).*db.time +segment2(2);
        end
        %%%%%%%%%% end tsgsal_apply_cal %%%%%%%%%%
        
        %%%%%%%%%% mtsg_cleanup %%%%%%%%%%
    case 'mtsg_cleanup'
        switch oopt
            case 'kbadlims'
                kbadlims = [datenum([2020 9 30 16 38 0]) datenum([2020 10 9 10 48 0]) % time in harbour, added by hand
                    datenum([2020 10 9 22 42 0]) datenum([2020 10 9 22 47 0]) % from here periods of bad data are found by code below
                    datenum([2020 10 10 10 42 0]) datenum([2020 10 10 10 47 0])
                    datenum([2020 10 10 13 53 0]) datenum([2020 10 10 13 58 0])
                    datenum([2020 10 10 13 54 0]) datenum([2020 10 10 13 59 0])
                    datenum([2020 10 10 14 3 0]) datenum([2020 10 10 14 8 0])
                    datenum([2020 10 10 14 59 0]) datenum([2020 10 10 15 4 0])
                    datenum([2020 10 10 15 30 0]) datenum([2020 10 10 15 35 0])
                    datenum([2020 10 10 16 48 0]) datenum([2020 10 10 16 53 0])
                    datenum([2020 10 10 16 49 0]) datenum([2020 10 10 16 54 0])
                    datenum([2020 10 10 18 16 0]) datenum([2020 10 10 18 21 0])
                    datenum([2020 10 10 19 18 0]) datenum([2020 10 10 19 23 0])
                    datenum([2020 10 10 20 51 0]) datenum([2020 10 10 20 56 0])
                    datenum([2020 10 10 21 46 0]) datenum([2020 10 10 21 51 0])
                    datenum([2020 10 10 22 1 0]) datenum([2020 10 10 22 6 0])
                    datenum([2020 10 10 22 13 0]) datenum([2020 10 10 22 18 0])
                    datenum([2020 10 10 22 36 0]) datenum([2020 10 10 22 41 0])
                    datenum([2020 10 11 2 35 0]) datenum([2020 10 11 2 40 0])
                    datenum([2020 10 11 3 13 0]) datenum([2020 10 11 3 18 0])
                    datenum([2020 10 11 4 3 0]) datenum([2020 10 11 4 8 0])
                    datenum([2020 10 11 4 20 0]) datenum([2020 10 11 4 25 0])
                    datenum([2020 10 11 5 3 0]) datenum([2020 10 11 5 8 0])
                    datenum([2020 10 11 6 32 0]) datenum([2020 10 11 6 37 0])
                    datenum([2020 10 11 7 13 0]) datenum([2020 10 11 7 18 0])
                    datenum([2020 10 11 8 47 0]) datenum([2020 10 11 8 52 0])
                    datenum([2020 10 11 11 22 0]) datenum([2020 10 11 11 27 0])
                    datenum([2020 10 11 11 53 0]) datenum([2020 10 11 11 58 0])
                    datenum([2020 10 11 12 11 0]) datenum([2020 10 11 12 16 0])
                    datenum([2020 10 11 12 50 0]) datenum([2020 10 11 12 55 0])
                    datenum([2020 10 11 13 11 0]) datenum([2020 10 11 13 16 0])
                    datenum([2020 10 11 14 43 0]) datenum([2020 10 11 14 48 0])
                    datenum([2020 10 11 15 6 0]) datenum([2020 10 11 15 11 0])
                    datenum([2020 10 11 15 20 0]) datenum([2020 10 11 15 25 0])
                    datenum([2020 10 11 15 33 0]) datenum([2020 10 11 15 38 0])
                    datenum([2020 10 11 16 8 0]) datenum([2020 10 11 16 13 0])
                    datenum([2020 10 11 16 36 0]) datenum([2020 10 11 16 41 0])
                    datenum([2020 10 11 17 21 0]) datenum([2020 10 11 17 26 0])
                    datenum([2020 10 11 17 30 0]) datenum([2020 10 11 17 35 0])
                    datenum([2020 10 11 17 47 0]) datenum([2020 10 11 17 52 0])
                    datenum([2020 10 11 18 4 0]) datenum([2020 10 11 18 9 0])
                    datenum([2020 10 11 18 33 0]) datenum([2020 10 11 18 38 0])
                    datenum([2020 10 11 20 24 0]) datenum([2020 10 11 20 29 0])
                    datenum([2020 10 11 22 1 0]) datenum([2020 10 11 22 6 0])
                    datenum([2020 10 11 22 44 0]) datenum([2020 10 11 22 49 0])
                    datenum([2020 10 11 23 12 0]) datenum([2020 10 11 23 17 0])
                    datenum([2020 10 11 23 47 0]) datenum([2020 10 11 23 52 0])
                    datenum([2020 10 12 0 8 0]) datenum([2020 10 12 0 13 0])
                    datenum([2020 10 12 1 36 0]) datenum([2020 10 12 1 41 0])
                    datenum([2020 10 12 3 6 0]) datenum([2020 10 12 3 11 0])
                    datenum([2020 10 12 3 7 0]) datenum([2020 10 12 3 12 0])
                    datenum([2020 10 12 3 23 0]) datenum([2020 10 12 3 28 0])
                    datenum([2020 10 12 3 49 0]) datenum([2020 10 12 3 54 0])
                    datenum([2020 10 12 3 54 0]) datenum([2020 10 12 3 59 0])
                    datenum([2020 10 12 4 12 0]) datenum([2020 10 12 4 17 0])
                    datenum([2020 10 12 4 39 0]) datenum([2020 10 12 4 44 0])
                    datenum([2020 10 12 5 4 0]) datenum([2020 10 12 5 9 0])
                    datenum([2020 10 12 5 47 0]) datenum([2020 10 12 5 52 0])
                    datenum([2020 10 12 5 58 0]) datenum([2020 10 12 6 3 0])
                    datenum([2020 10 12 6 26 0]) datenum([2020 10 12 6 31 0])
                    datenum([2020 10 12 7 3 0]) datenum([2020 10 12 7 8 0])
                    datenum([2020 10 12 7 10 0]) datenum([2020 10 12 7 15 0])
                    datenum([2020 10 12 7 23 0]) datenum([2020 10 12 7 28 0])
                    datenum([2020 10 12 8 49 0]) datenum([2020 10 12 8 54 0])
                    datenum([2020 10 12 11 17 0]) datenum([2020 10 12 11 22 0])
                    datenum([2020 10 12 12 14 0]) datenum([2020 10 12 12 19 0])
                    datenum([2020 10 12 13 26 0]) datenum([2020 10 12 13 31 0])
                    datenum([2020 10 12 18 49 0]) datenum([2020 10 12 18 54 0])
                    datenum([2020 10 12 19 21 0]) datenum([2020 10 12 19 26 0])
                    datenum([2020 10 12 19 49 0]) datenum([2020 10 12 19 54 0])
                    datenum([2020 10 12 21 38 0]) datenum([2020 10 12 21 43 0])
                    datenum([2020 10 12 22 28 0]) datenum([2020 10 12 22 33 0])
                    datenum([2020 10 13 4 30 0]) datenum([2020 10 13 4 35 0])
                    datenum([2020 10 13 6 5 0]) datenum([2020 10 13 6 10 0])
                    datenum([2020 10 13 7 11 0]) datenum([2020 10 13 7 16 0])
                    datenum([2020 10 13 9 10 0]) datenum([2020 10 13 9 15 0])
                    datenum([2020 10 13 14 1 0]) datenum([2020 10 13 14 6 0])
                    datenum([2020 10 13 14 18 0]) datenum([2020 10 13 14 23 0])
                    datenum([2020 10 13 17 37 0]) datenum([2020 10 13 17 42 0])
                    datenum([2020 10 13 18 29 0]) datenum([2020 10 13 18 34 0])
                    datenum([2020 10 13 18 38 0]) datenum([2020 10 13 18 43 0])
                    datenum([2020 10 14 6 4 0]) datenum([2020 10 14 6 9 0])
                    datenum([2020 10 14 10 8 0]) datenum([2020 10 14 10 13 0])
                    datenum([2020 10 14 10 21 0]) datenum([2020 10 14 10 26 0])
                    datenum([2020 10 14 22 20 0]) datenum([2020 10 14 22 25 0])
                    datenum([2020 10 14 22 21 0]) datenum([2020 10 14 22 26 0])
                    datenum([2020 10 15 10 20 0]) datenum([2020 10 15 10 25 0])
                    datenum([2020 10 15 14 0 0]) datenum([2020 10 15 14 5 0])
                    datenum([2020 10 15 14 55 0]) datenum([2020 10 15 15 0 0])
                    datenum([2020 10 15 15 45 0]) datenum([2020 10 15 15 50 0])
                    datenum([2020 10 15 16 16 0]) datenum([2020 10 15 16 21 0])
                    datenum([2020 10 15 16 28 0]) datenum([2020 10 15 16 33 0])
                    datenum([2020 10 15 16 43 0]) datenum([2020 10 15 16 48 0])
                    datenum([2020 10 15 17 50 0]) datenum([2020 10 15 17 55 0])
                    datenum([2020 10 15 17 59 0]) datenum([2020 10 15 18 4 0])
                    datenum([2020 10 15 18 14 0]) datenum([2020 10 15 18 19 0])
                    datenum([2020 10 15 18 45 0]) datenum([2020 10 15 18 50 0])
                    datenum([2020 10 15 23 19 0]) datenum([2020 10 15 23 24 0])
                    datenum([2020 10 15 23 50 0]) datenum([2020 10 15 23 55 0])
                    datenum([2020 10 16 0 11 0]) datenum([2020 10 16 0 16 0])
                    datenum([2020 10 16 1 57 0]) datenum([2020 10 16 2 2 0])
                    datenum([2020 10 16 2 46 0]) datenum([2020 10 16 2 51 0])
                    datenum([2020 10 16 3 12 0]) datenum([2020 10 16 3 17 0])
                    datenum([2020 10 16 9 22 0]) datenum([2020 10 16 9 27 0])
                    datenum([2020 10 16 9 23 0]) datenum([2020 10 16 9 28 0])
                    datenum([2020 10 16 10 14 0]) datenum([2020 10 16 10 19 0])
                    datenum([2020 10 16 10 30 0]) datenum([2020 10 16 10 35 0])
                    datenum([2020 10 16 10 39 0]) datenum([2020 10 16 10 44 0])
                    datenum([2020 10 16 11 42 0]) datenum([2020 10 16 11 47 0])
                    datenum([2020 10 16 11 56 0]) datenum([2020 10 16 12 1 0])
                    datenum([2020 10 16 12 2 0]) datenum([2020 10 16 12 7 0])
                    datenum([2020 10 16 14 46 0]) datenum([2020 10 16 14 51 0])
                    datenum([2020 10 16 15 1 0]) datenum([2020 10 16 15 6 0])
                    datenum([2020 10 16 16 56 0]) datenum([2020 10 16 17 1 0])
                    datenum([2020 10 16 18 33 0]) datenum([2020 10 16 18 38 0])
                    datenum([2020 10 17 6 37 0]) datenum([2020 10 17 6 42 0])
                    datenum([2020 10 17 9 17 0]) datenum([2020 10 17 9 22 0])
                    datenum([2020 10 17 9 32 0]) datenum([2020 10 17 9 37 0])
                    datenum([2020 10 17 10 17 0]) datenum([2020 10 17 10 22 0])
                    datenum([2020 10 17 13 1 0]) datenum([2020 10 17 13 6 0])
                    datenum([2020 10 17 13 2 0]) datenum([2020 10 17 13 7 0])
                    datenum([2020 10 17 20 39 0]) datenum([2020 10 17 20 44 0])
                    datenum([2020 10 17 21 29 0]) datenum([2020 10 17 21 34 0])
                    datenum([2020 10 18 9 28 0]) datenum([2020 10 18 9 33 0])
                    datenum([2020 10 18 9 29 0]) datenum([2020 10 18 9 34 0])
                    datenum([2020 10 18 20 28 0]) datenum([2020 10 18 20 33 0])
                    datenum([2020 10 18 20 29 0]) datenum([2020 10 18 20 34 0])
                    datenum([2020 10 18 20 44 0]) datenum([2020 10 18 20 49 0])
                    datenum([2020 10 18 20 58 0]) datenum([2020 10 18 21 3 0])
                    datenum([2020 10 18 21 5 0]) datenum([2020 10 18 21 10 0])
                    datenum([2020 10 18 21 26 0]) datenum([2020 10 18 21 31 0])
                    datenum([2020 10 18 21 46 0]) datenum([2020 10 18 21 51 0])
                    datenum([2020 10 18 21 53 0]) datenum([2020 10 18 21 58 0])
                    datenum([2020 10 18 22 6 0]) datenum([2020 10 18 22 11 0])
                    datenum([2020 10 18 22 15 0]) datenum([2020 10 18 22 20 0])
                    datenum([2020 10 18 22 33 0]) datenum([2020 10 18 22 38 0])
                    datenum([2020 10 18 23 31 0]) datenum([2020 10 18 23 36 0])
                    datenum([2020 10 18 23 48 0]) datenum([2020 10 18 23 53 0])
                    datenum([2020 10 19 0 24 0]) datenum([2020 10 19 0 29 0])
                    datenum([2020 10 19 1 4 0]) datenum([2020 10 19 1 9 0])
                    datenum([2020 10 19 1 22 0]) datenum([2020 10 19 1 27 0])
                    datenum([2020 10 19 1 26 0]) datenum([2020 10 19 1 31 0])
                    datenum([2020 10 19 1 53 0]) datenum([2020 10 19 1 58 0])
                    datenum([2020 10 19 2 5 0]) datenum([2020 10 19 2 10 0])
                    datenum([2020 10 19 2 20 0]) datenum([2020 10 19 2 25 0])
                    datenum([2020 10 19 2 31 0]) datenum([2020 10 19 2 36 0])
                    datenum([2020 10 19 3 3 0]) datenum([2020 10 19 3 8 0])
                    datenum([2020 10 19 3 21 0]) datenum([2020 10 19 3 26 0])
                    datenum([2020 10 19 3 44 0]) datenum([2020 10 19 3 49 0])
                    datenum([2020 10 19 4 22 0]) datenum([2020 10 19 4 27 0])
                    datenum([2020 10 19 4 32 0]) datenum([2020 10 19 4 37 0])
                    datenum([2020 10 19 4 42 0]) datenum([2020 10 19 4 47 0])
                    datenum([2020 10 19 5 34 0]) datenum([2020 10 19 5 39 0])
                    datenum([2020 10 19 6 16 0]) datenum([2020 10 19 6 21 0])
                    datenum([2020 10 19 6 28 0]) datenum([2020 10 19 6 33 0])
                    datenum([2020 10 19 6 47 0]) datenum([2020 10 19 6 52 0])
                    datenum([2020 10 19 7 2 0]) datenum([2020 10 19 7 7 0])
                    datenum([2020 10 19 7 11 0]) datenum([2020 10 19 7 16 0])
                    datenum([2020 10 19 7 36 0]) datenum([2020 10 19 7 41 0])
                    datenum([2020 10 19 7 45 0]) datenum([2020 10 19 7 50 0])];
                %           % The non-cleaning lines are to remove the effect of a defect cable on discovery.
                %           % They were generated by running the following lines:
                %           [d,h]=mload('met_tsg_dy120_01_medav_clean.nc','/');
                %           time = d.time;
                %           dn = datenum(h.data_time_origin)+time/86400;
                %           cond_diff = diff(d.cond);
                %           idx = find(cond_diff > 0.0125)+1;
                %           iib = [];
                %           for no = 1:length(idx)
                %             iib = [iib idx(no)-1:idx(no)+4];
                %             disp(sprintf('datenum([%g %g %g %g %g %g]) datenum([%g %g %g %g %g %g])', datevec(dn(idx(no)-1)), datevec(dn(idx(no)+4))))
                %           end
                
        end
        %%%%%%%%%% end mtsg_cleanup %%%%%%%%%%
        
end
