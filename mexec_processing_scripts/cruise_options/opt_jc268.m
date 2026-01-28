switch opt1

    case 'setup'
        switch opt2
            case 'time_origin'
                MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [2024 1 1 0 0 0];
        end

    case 'ship'
        switch opt2
            case 'datasys_best' %maybe edit these, ask SSS tech which is best
                default_navstream = 'posmv_gpgga';
                default_hedstream = 'posmv_pashr';
                default_attstream = 'posmv_pashr';
            case 'rvdas_database'
                RVDAS.machine = '192.168.165.51'; %***edit
                RVDAS.user = 'rvdas';
                RVDAS.database = ['"' upper(MEXEC_G.MSCRIPT_CRUISE_STRING) '"'];
        end

    case 'uway_proc'
        switch opt2
            case 'excludestreams'
        end

    case 'castpars'
        switch opt2
            case 's_choice'
                s_choice = 2; %fin sensor
            case 'o_choice'
                o_choice = 2; %fin sensor

        end

    case 'ctd_proc'
        switch opt2
            case 'redoctm'
                redoctm = 1;
            case 'cnvfilename' %may need to edit these if only one frame (e.g. change %03dS.cnv to %03d.cnv, and similarly for blfilename)
                cnvfile = fullfile(cdir,sprintf('%s_CTD%03dS.cnv',upper(mcruise),stn)); %try stainless first
                if ~exist(cnvfile,'file')
                    cnvfile = fullfile(cdir,sprintf('%s_CTD%03dT.cnv',upper(mcruise),stn)); %try Ti
                end
            case 'blfilename'
                blinfile = fullfile(root_botraw,sprintf('%s_CTD%03dS.bl', upper(mcruise), stn));
                if ~exist(blinfile,'file')
                    blinfile = fullfile(root_botraw,sprintf('%s_CTD%03dT.bl', upper(mcruise),stn));
                end
            case 'rawedit_auto'
                if stnlocal==35
                    co.rangelim.press = [-1 8000];
                end
            case 'raw_corrs'
                co.dooxyhyst = 0 ;
            case 'ctd_cals'
            %     co.docal.temp = 1;
            %     co.docal.cond = 1;
            %     co.docal.oxygen = 1;
            %     co.calstr.temp.sn34116.dy181 = 'dcal.temp = d0.temp+interp1([1 101],[1e-3 0e-3],d0.statnum) - 5e-4 +interp1([0 3100],[1e-3 -0.8e-3],d0.press);';
            %     co.calstr.temp.sn34116.msg = 'SBE35 comparison, 180 low gradient points';
            %     co.calstr.temp.sn35838.dy181 = 'dcal.temp = d0.temp+interp1([0 3100],[1.8e-3 0.8e-3],d0.press) - 5e-4;';
            %     co.calstr.temp.sn35838.msg = 'SBE35 comparison, 181 low gradient points';
                co.calstr.cond.sn42450.jc268 = 'dcal.cond = d0.cond.*(1+2e-3/35);';
            %     co.calstr.cond.sn42580.msg = 'bottle salinity comparison, 232 low gradient points';
                % co.calstr.cond.sn43258.dy181 = 'dcal.cond = d0.cond.*(1+interp1([1 101],[-6e-3 -4e-3],d0.statnum)/35 + interp1([0 3100],[0 -1.5e-3],d0.press)/35);';
                % co.calstr.cond.sn43258.msg = 'bottle salinity comparison, 249 low gradient points';
                % co.calstr.oxygen.sn432061.dy181 = 'dcal.oxygen = d0.oxygen.*interp1([0 3100],[1.045 1.065],d0.press);';%interp1([0 101],[1.038 1.045],d0.statnum)+interp1([0 3100],[0 2.5],d0.press);';
                % co.calstr.oxygen.sn432061.msg = 'comparison of upcast and density-matched downcast oxygen with 361 low-background-gradient samples';
                % co.calstr.oxygen.sn432068.dy181 = 'dcal.oxygen = d0.oxygen.*interp1([0 3100],[1.035 1.045],d0.press).*interp1([1 52 53 79 80 101],[0.99 0.99 1.02 1.02 1 1],d0.statnum);';%interp1([0 101],[1.02 1.035],d0.statnum)+interp1([1 101],[2 0],d0.statnum)+interp1([0 3100],[-0.5 2],d0.press);';
                % co.calstr.oxygen.sn432068.msg = 'comparison of upcast and density-matched downcast oxygen with 361 low-background-gradient samples';
        end

    case 'ladcp_proc' %may need to edit these to reflect file name patterns
        cfg.uppat = sprintf('%s_LADCP_CTD%03dS*.000',upper(mcruise),stnlocal);
        cfg.dnpat = sprintf('%s_LADCP_CTD%03dM*.000',upper(mcruise),stnlocal);
        cfg.rawdir = fullfile(mgetdir('ladcp'),'rawdata');
        cfg.p.vlim = 4; %rather than ambiguity vel, match this to LV

    case 'msal_01'
        
        switch opt2
            case 'sal_files'
                salfiles = dir(fullfile(root_sal, ['JC238*.csv']));
                salfiles = {salfiles.name};
                clear iopts; iopts.datetimeformat = 'dd/MM/uuuu'; %***for NMF files
            %case 'sal_parse'
            
            % case 'sal_calc'
            %     sal_off(:,1) = sal_off(:,1)+999000;
            %     sal_off(:,2) = sal_off(:,2)*1e-5;
            %     sal_adj_comment = ['Bottle salinities adjusted using SSW batch P165'];
        end
    case 'check_sams'
        %make this display-dependent? (or session-dependent?)
        check_sal = 0;
        check_oxy = 0;
        check_sbe35 = 0;

        % For the salinity standards (in msal_01.m)
        cellT = 21;
        ssw_batch = 'P167';
        ssw_k15 = 0.99988;
        
    case 'outputs'
        switch opt2
            case 'summary'
                snames = {'nsal' 'noxy' 'nnut' 'nco2'};
                sgrps = {{'botpsal'} {'botoxy'} {'silc' 'phos' 'nitr'} {'dic' 'talk'}};
            case 'exch'
                ns = 10; nt = 10; %edit (but not urgent, easy to regenerate these files with updated header info!)
                expocode = '740H20240817'; %edit
                sect_id = 'ReBELS';
                submitter = 'OCPNOCLC'; %group institution person
                common_headstr = {'#SHIP: RRS James Cook';...
                    '#Cruise JC268; ReBELS-1';...
                    '#Region: subpolar north Atlantic';...
                    ['#EXPOCODE: ' expocode];...
                    %'#DATES: 20240522 - 20240628';... %edit (and ucomment) these lines
                    '#Chief Scientist: F. Carvalho (NOC)';...
                    '#Supported by grants from the UK Natural Environment Research Council.'}; %can add more detail here
                if strcmp(in.type,'ctd')
                    headstring = {['CTD,' datestr(now,'yyyymmdd') submitter]};
                    headstring = [headstring; common_headstr;
                        {sprintf('#%d stations with 24-place stainless-steel rosette',ns);... %edit lines below as necessary
                        sprintf('#%d stations with 24-place trace metal clean rosette',nt);...
                        '#CTD: Who - Y. Firing and T. Petit (NOC); Status - preliminary.';...
                        %'#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                        '# DEPTH_TYPE   : COR';...
                        '# DEPTH_TYPE   : rosette depth from CTDPRS + CTD altimeter range to bottom, or speed of sound-corrected ship-mounted bathymetric echosounder'...
                        }];
                else
                    headstring = {['BOTTLE,' datestr(now,'yyyymmdd') submitter]};
                    headstring = [headstring; common_headstr;
                        {sprintf('#%d stations with 24-place stainless-steel rosette',ns);...
                        sprintf('#%d stations with 24-place trace metal clean rosette',nt);...
                        '#CTD: Who - Y. Firing and T. Petit (NOC); Status - preliminary';...
                        '#Notes: Includes CTDSAL, CTDOXY, CTDTMP';...
                        %'#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                        '# DEPTH_TYPE   : rosette depth from CTDPRS + CTD altimeter range to bottom';...
                        '#Salinity: Who - Y. Firing (NOC); Status - preliminary; SSW batch P165***.';...
                        '#Oxygen: Who - E. Mawji (NOC); Status - preliminary.';...
                        '#Nutrients: Who - E. Mawji (NOC); Status - preliminary.';...
                        '#DIC and Talk: Who - ??? (NOC); Status - preliminary.';...
                        '#***';...
                        }];
                end

            case 'grid'
                    section = 'profiles_only';
                    kstns = [1 2 3 4 5 6 7 8 9 10 11]; %useful to do profiles_only for all stations anyway (smooth in vertical)
                
        end

    case 'best_station_depths'
        switch opt2
            case 'bestdeps'
                % only for stations where we can't use ctd+altimeter
                % replacedeps = [cast_number depth]
                replacedeps = [
                   5 1000];
        end

    % case 'botpsal'
    %      switch opt2
    %          case 'sal_calc'
    %              %sal_off(:,1) = sal_off(:,1)+999000;
    %              %sal_off(:,2) = sal_off(:,2)*3.6e-5;
    %              sal_off(:,2) = 3.6e-5;
    %              sal_adj_comment = ['Bottle salinities adjusted using SSW batch P167'];
         % end
    case 'botpsal'
        switch opt2
            case 'sal_calc'
                 sal_off = [1 3.2
                            2 4.6
                            3 2.3
                            4 4.1
                            5 2.9
                            6 2.8
                            7 -1.9
                            8 1.9
                            9 1
                    ];
                 sal_off(:,1) = sal_off(:,1)+999e3;
                 sal_off(:,2) = sal_off(:,2)*1e-5;
                 sal_off_base = 'sampnum_list'; 
        end
    % case 'msal_01'
    %      switch opt2
    %          case 'sal_parse'
    %              cellT = 24;
    %              ssw_batch = 'P165';
    %              ssw_k15 = 0.99986;
    %      end

end

