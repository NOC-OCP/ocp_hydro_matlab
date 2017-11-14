function mday_plots(day,stream)

% make a series of plots to display a day of underway data
% function mday_plots(day,stream)
% recognised streams are
%     case 'pos'
%     case 'gyr'
%     case 'chf'
%     case 'ash'
%     case 'metraw'
%     case 'airraw'
%     case 'metpro'
%     case 'met_light'
%     case 'met_tsg'
%     case 'tsg'
%bak on jc069
% revised for ship options on jr281 bak march 2013
m_setup
pdfsroot = [MEXEC.mexec_processing_scripts '/pdfs'];
day_string = sprintf('%03d',day);

switch MEXEC_G.Mship
    case 'cook'
        lon_name = 'long'; % name for longitude variable
    case 'jcr'
        lon_name = 'lon';
    otherwise
        msg = ['edit ship navigation details as new case in mday_plots.m'];
        fprintf(2,'\n\n%s\n\n\n',msg);
        return
end

switch stream
    case 'posmvpos'
        root_dir = mgetdir('M_POSMVPOS');
        prefix1 = ['posmvpos' '_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
        infile1 = [root_dir '/' prefix1 'd' day_string '_edt'];
        prefix2 = ['bst' '_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
        infile2 = [root_dir '/' prefix1 '01'];
        if exist(m_add_nc(infile1),'file') ~= 2; return; end

        clear p
        p.xlist = lon_name;
        p.ylist = 'lat';
        p.ncfile.name = infile1;
        p.widths = 3;
        p = mplotxy(p); % plot daily file
        close
        %p = maxmerc(p); % make mercator
        p = mplotxy(p); % replot
        hold on; grid on;
        % now plot bst file for this day
        if exist(m_add_nc(infile2),'file') ~= 2; return; end

        p2 = p;
        p2.over = 1;
        p2.ncfile.name = infile2;
        p2.cols = 'r';
        p2.widths = 1;
        p2.startdc = [day 0 0 0];
        p2.stopdc = [day+1 0 0 0];
        p2 = mplotxy(p2);
    case 'gyro_s'
        root_dir = mgetdir('M_GYRO_S');
        prefix1 = ['gyro_s' '_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
        infile1 = [root_dir '/' prefix1 'd' day_string '_edt'];
        if exist(m_add_nc(infile1),'file') ~= 2; return; end

        clear p
        p.xlist = 'time';
        p.ylist = 'head_gyr';
        p.ncfile.name = infile1;
        p.startdc = [day 0 0 0];
        p.stopdc = [day+1 0 0 0];
        p.time_scale = 3;
        p.xax = [0 24];
        p.yax = [-60  420];
        p.ntick = [6 8];

        p = mplotxy(p); % plot daily file
        hold on; grid on;
    case 'log_chf'
        switch MEXEC_G.Mship
            case 'jcr'
                p_ylist = 'velocity_f_a';
            case 'cook'
                p_ylist = 'speedfa';
            otherwise
                msg = ['edit em log details as new case in mday_plots.m'];
                fprintf(2,'\n\n%s\n\n\n',msg);
                return
        end
        root_dir = mgetdir('M_LOG_CHF');
        prefix1 = ['log_chf' '_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
        infile1 = [root_dir '/' prefix1 'd' day_string '_raw'];
        if exist(m_add_nc(infile1),'file') ~= 2; return; end

        clear p
        p.xlist = 'time';
        p.ylist = p_ylist;
        p.ncfile.name = infile1;
        p.startdc = [day 0 0 0];
        p.stopdc = [day+1 0 0 0];
        p.time_scale = 3;
        p.xax = [0 24];
        p.yax = [-6 18];
        p.ntick = [6 10];

        p = mplotxy(p); % plot daily file
        hold on; grid on;
    case 'ash'
        switch MEXEC_G.Mship
            case 'jcr'
                return % not working on jr281
            otherwise
        end
        root_dir = mgetdir('M_ASH');
        prefix1 = ['ash' '_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
        infile1 = [root_dir '/' prefix1 'd' day_string ''];
        if exist(m_add_nc(infile1),'file') ~= 2;
            % file does not exist
            m_figure
            axes
            mess = ['file ' infile1 ' does not exist'];
            ht = text(.5,.5,mess);
            set(ht,'color','r','interpreter','none','horizontalalignment','center')
            return
        end
            
        clear p
        p.xlist = 'time';
        p.ylist = 'head_gyr head_ash a_minus_g_sm pitch roll';
        p.ncfile.name = infile1;
        p.startdc = [day 0 0 0];
        p.stopdc = [day+1 0 0 0];
        p.time_scale = 3;
        p.xax = [0 24];
        p.yax = [
            -90 810
            -90 810
            -14 6
            -18 12
            -18 12
            ];
        p.ntick = [6 10];

        p = mplotxy(p); % plot daily file
        hold on; grid on;
    case 'surfmet'
        switch MEXEC_G.Mship
            case 'cook'
                p_ylist = 'speed direct airtemp humid';
                p_yax = [
                    0 60 % wind speed
                    -90 810 % direction
                    -4 36 % temp
                    -60 140 % humid
                    ];
            case 'jcr'
                p_ylist = 'wind_speed wind_dir';
                p_yax = [
                    0 60 % wind speed
                    -90 810 % direction
                    ];
            otherwise
                msg = ['edit wind parameter details as new case in mday_plots.m'];
                fprintf(2,'\n\n%s\n\n\n',msg);
                return
        end

        root_dir = mgetdir('M_SURFMET');
        %raw wind 
        prefix1 = ['surfmet' '_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
        infile1 = [root_dir '/' prefix1 'd' day_string '_raw'];
        if exist(m_add_nc(infile1),'file') ~= 2; return; end

        clear p
        p.xlist = 'time';
        p.ylist = p_ylist;
        p.ncfile.name = infile1;
        p.startdc = [day 0 0 0];
        p.stopdc = [day+1 0 0 0];
        p.time_scale = 3;
        p.xax = [0 24];
        p.yax = p_yax;
        p.ntick = [6 10];
        p.symbols = {' ' '+' ' ' ' '};
        p.styles = {'-' ' ' '-' ' '};

        p = mplotxy(p); % plot daily file
        hold on; grid on;
    case 'airraw'
        switch MEXEC_G.Mship
            case 'cook' % not used; air data are in metraw -> surfmet
            case 'jcr'
                p_ylist = 'airtemp1 airtemp2 humidity1 humidity2';
                p_yax = [
                    -4 36 % temp
                    -4 36 % temp
                    -60 140 % humid
                    -60 140 % humid
                    ];
            otherwise
                msg = ['edit air parameter details as new case in mday_plots.m'];
                fprintf(2,'\n\n%s\n\n\n',msg);
                return
        end

        root_dir = mgetdir('M_OCL');
        %raw wind 
        prefix1 = ['ocl' '_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
        infile1 = [root_dir '/' prefix1 'd' day_string '_raw'];
        if exist(m_add_nc(infile1),'file') ~= 2; return; end

        clear p
        p.xlist = 'time';
        p.ylist = p_ylist;
        p.ncfile.name = infile1;
        p.startdc = [day 0 0 0];
        p.stopdc = [day+1 0 0 0];
        p.time_scale = 3;
        p.xax = [0 24];
        p.yax = p_yax;
        p.ntick = [6 10];

        p = mplotxy(p); % plot daily file
        hold on; grid on;
    case 'metpro'
        root_dir = mgetdir('M_SURFMET');
        %processed wind 
        prefix1 = ['surfmet' '_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
        infile1 = [root_dir '/' prefix1 'trueav' ''];
        if exist(m_add_nc(infile1),'file') ~= 2; return; end

        clear p
        p.xlist = 'time';
        p.ylist = 'truwind_spd truwind_dir';
        p.ncfile.name = infile1;
        p.startdc = [day 0 0 0];
        p.stopdc = [day+1 0 0 0];
        p.time_scale = 3;
        p.xax = [0 24];
        p.yax = [
            0 30
            -90 810
            ];
        p.ntick = [6 10];

        p = mplotxy(p); % plot daily file
        hold on; grid on;
    case 'met_light'
        % met light including pressure; oceanlogger on jcr
        switch MEXEC_G.Mship
            case 'jcr'
                root_dir = mgetdir('M_OCL');
                prefix1 = ['ocl' '_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
                p_ylist = 'par1 par2 tir1 tir2 baro1 baro2';
                p_yax = [
                    -1000 1000
                    -1000 1000
                    -200 1800
                    -200 1800
                    950 1050
                    951 1051
                    ];
            case 'cook'
                root_dir = mgetdir('M_MET_LIGHT');
                prefix1 = ['met_light' '_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
                p_ylist = 'ppar spar ptir stir pres';
                p_yax = [
                    -1000 1000
                    -1000 1000
                    -200 1800
                    -200 1800
                    950 1050
                    ];
            otherwise
                msg = ['edit tsg details as new case in mday_plots.m'];
                fprintf(2,'\n\n%s\n\n\n',msg);
                return
        end
        infile1 = [root_dir '/' prefix1 'd' day_string '_raw'];
        if exist(m_add_nc(infile1),'file') ~= 2; return; end

        clear p
        p.xlist = 'time';
        p.ylist = p_ylist;
        p.ncfile.name = infile1;
        p.startdc = [day 0 0 0];
        p.stopdc = [day+1 0 0 0];
        p.time_scale = 3;
        p.xax = [0 24];
        p.yax = p_yax;
        p.ntick = [6 10];

        p = mplotxy(p); % plot daily file
        hold on; grid on;
    case 'met_tsg'
        switch MEXEC_G.Mship
            case 'jcr'
                % all oceanlogger sea variables
                root_dir = mgetdir('M_OCL');
                prefix1 = ['ocl' '_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
                p_ylist = ' sstemp tstemp salinity chlorophyll trans  conductivity';
                p_yax = [
                    -4 36
                    -4 36
                    30 36 % salinity
                    0 12 % fluor
                    0 5 % trans
                    2 5 % cond
                    ];
            case 'cook'
                root_dir = mgetdir('M_MET_TSG')
                % met tsg including fluor & trans
                prefix1 = ['met_tsg' '_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
                p_ylist = ' temp_h temp_m psal fluo trans cond';
                p_yax = [
                    10 30
                    10 30
                    30 38
                    0 2 % fluor
                    2 5 % trans
                    2 6 % cond
                    ];
            otherwise
                msg = ['edit tsg details as new case in mday_plots.m'];
                fprintf(2,'\n\n%s\n\n\n',msg);
                return
        end
        infile1 = [root_dir '/' prefix1 'd' day_string '_edt'];
        if exist(m_add_nc(infile1),'file') ~= 2; return; end

        clear p
        p.xlist = 'time';
        p.ylist = p_ylist;
        p.ncfile.name = infile1;
        p.startdc = [day 0 0 0];
        p.stopdc = [day+1 0 0 0];
        p.time_scale = 3;
        p.xax = [0 24];
        p.yax = p_yax;
        p.ntick = [6 10];

        p = mplotxy(p); % plot daily file
        hold on; grid on;
    case 'tsg'
        switch MEXEC_G.Mship
            case 'jcr'
                root_dir = mgetdir('M_OCL');
                prefix1 = ['ocl' '_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
                p_ylist = ' sstemp tstemp sampletemp salinity sound_velocity conductivity flowrate';
                p_yax = [
                    -4 36 % sea temp
                    -4 36 % sal sample temp
                    -4 36 % fluor sample temp
                    30 36 % salin
                    1200 1600 % sndspeed
                    2 5 % cond
                    -8 2 % flow
                    ];
            case 'cook'
                root_dir = mgetdir('M_TSG');
                prefix1 = ['tsg' '_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
                p_ylist = ' temp_h temp_r salin sndspeed cond';
                p_yax = [
                    -4 36 % housing ?
                    -4 36 % remote ?
                    30 36 % salin
                    1200 1600 % sndspeed
                    2 5 % cond
                    ];
            otherwise
                msg = ['edit tsg details as new case in mday_plots.m'];
                fprintf(2,'\n\n%s\n\n\n',msg);
                return
        end
        % met tsg including fluor & trans
        infile1 = [root_dir '/' prefix1 'd' day_string '_raw'];
        if exist(m_add_nc(infile1),'file') ~= 2; return; end

        clear p
        p.xlist = 'time';
        p.ylist = p_ylist;
        p.ncfile.name = infile1;
        p.startdc = [day 0 0 0];
        p.stopdc = [day+1 0 0 0];
        p.time_scale = 3;
        p.xax = [0 24];
        p.yax = p_yax;
        p.ntick = [6 10];

        p = mplotxy(p); % plot daily file
        hold on; grid on;
    otherwise
        return
end


%
%     case 'sim'
%         mout = 'M_SIM';
%         rvsstream = 'ea600m';
%     case 'gyr'
%         mout = 'M_GYS';
%         rvsstream = 'gyro_s';
%     case 'gyp'
%         mout = 'M_GYP';
%         if strncmp(MEXEC_G.Mshipdatasystem,'scs',3)
%             return
%         else % techsas
%             rvsstream = 'gyropmv';
%         end
%     case 'gp4'
%         mout = 'M_GP4'; % gps4000 on di368 jul 2011 and later
%         if strncmp(MEXEC_G.Mshipdatasystem,'scs',3)
%             return
%         else % techsas
%             rvsstream = 'gps4000';
%         end
%     case 'pos'
%         mout = 'M_POS';
%         if strncmp(MEXEC_G.Mshipdatasystem,'scs',3)
%             rvsstream = 'seatex-gll';
%         else % techsas
% %            rvsstream = 'posmvpos';
%             rvsstream = MEXEC_G.Mtechsas_default_navstream;
%         end
