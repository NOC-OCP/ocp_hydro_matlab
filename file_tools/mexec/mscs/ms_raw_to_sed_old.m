
% str = 'GPS-Furuno-GGA'; kkk = 0224;
% str = 'SingleBeam-Knudsen-PKEL99'; kkk = 224;%205:222;
% str = 'Gyro1-HDT'; kkk = 224; %[131 201:224];
% str = 'TSG1-SBE21'; kkk = 224;%[205:221];
% str = 'TSG2-SBE45'; kkk = 224;%[131 201:221];
% str = 'SpeedLog-Furuno-VBW'; kkk = 224;%[ 205:221];

procall = {
    'GPS-Furuno-GGA'            [225]
    'SingleBeam-Knudsen-PKEL99' [225]
    'Gyro1-HDT'                 [225]
    'TSG1-SBE21'                [225]
    'TSG2-SBE45'                [225]
    'SpeedLog-Furuno-VBW'       [225]
    };

for kproc = [1 2 3 4 5 6]

    str = procall{kproc,1}
    kkk = procall{kproc,2}


    for kl = kkk

        fprintf('%s %d\n','kl = ',kl)

        fnroot = [str '_2023' sprintf('%04d',kl) '-000000'];
        fnraw = ['/mnt/en697data/scs/raw/' fnroot '.Raw'];

        fnsed = ['/local/users/pstar/projects/rpdmoc/en697/mcruise/data/scs/scs_daily/' fnroot '.ACO'];
        fnmat = ['/local/users/pstar/projects/rpdmoc/en697/mcruise/data/scs/scs_daily/' fnroot '.mat'];

        fprintf(1,'%s\n','reading raw');

        raw = mtextdload(fnraw,',',0);

        fprintf(1,'%s\n','parsing')

        nlines = length(raw);

        fid = fopen(fnsed,'w');

        %     vnames = {
        %         'GPS-Furuno-GGA-lat'
        %         'GPS-Furuno-GGA-lon'
        %         'GPS-Furuno-GGA-time'
        %         };
        %     vunits = {
        %         'degrees'
        %         'degrees'
        %         'HHMMSS'
        %         };
        % cmd = ['cat /local/users/pstar/projects/rpdmoc/en697/mcruise/data/scs/scs_daily/TSG1-SBE21*.ACO >! /local/users/pstar/projects/rpdmoc/en697/mcruise/data/scs_sed/TSG1-SBE21.ACO']; [status,result ] = system(cmd);

        %     nv = length(vnames);
        %
        %     time_all = nan(1,nlines);
        %     data_all = nan(nv,nlines);



        for kk = 1:nlines
            c = raw{kk};
            if (kproc == 5 && length(c) ~= 6); continue; end % bad formatted line
            in.ymd = c{1};
            in.hms = c{2};
            yyyy = str2double(in.ymd(7:10));
            dd = str2double(in.ymd(4:5));
            mo = str2double(in.ymd(1:2));
            hh = str2double(in.hms(1:2));
            mm = str2double(in.hms(4:5));
            ss = str2double(in.hms(7:8));

            dnum = datenum([yyyy mo dd hh mm ss]);
            dorg = datenum([2023 1 1]);
            ot.ddd = dnum-dorg+1;
            ot.doy = floor(ot.ddd);
            ot.dfrac = ot.ddd-ot.doy;
            ot.yyyy = yyyy;
            switch str
                case 'GPS-Furuno-GGA'
                    in.time = c{4};
                    in.lat = c{5};
                    in.lon = c{7};



                    ot.time = str2double(in.time);
                    lat1 = str2double(in.lat)/100;
                    latdeg = floor(lat1);
                    latmin = (lat1-latdeg)*100;
                    ot.lat = latdeg+latmin/60;
                    lon1 = str2double(in.lon)/100;
                    londeg = floor(lon1);
                    lonmin = (lon1-londeg)*100;
                    ot.lon = -(londeg+lonmin/60);



                    fprintf(fid,'%4d %10.6f %3d %10.8f %8.5f %8.5f %06d\n',ot.yyyy, ot.ddd, ot.doy, ot.dfrac, ot.lat, ot.lon, ot.time);

                    %                 time_all(kl) = dnum;
                    %                 data_all(:,kl) = [ot.lat ot.lon ot.time];
                    %                 bytes_all = nan;
                case 'SingleBeam-Knudsen-PKEL99'
                    in.dep = c{9};
                    ot.dep = str2double(in.dep);
                    fprintf(fid,'%4d %10.6f %3d %10.8f %8.1f\n',ot.yyyy, ot.ddd, ot.doy, ot.dfrac, ot.dep);
                case 'Gyro1-HDT'
                    in.heading = c{4};
                    ot.heading = str2double(in.heading);
                    fprintf(fid,'%4d %10.6f %3d %10.8f %8.2f\n',ot.yyyy, ot.ddd, ot.doy, ot.dfrac, ot.heading);
                case 'TSG1-SBE21'
                    % delimited by multiple spaces, so c{3} is the whole
                    % message
                    call = [c{3} ' ']; % ensure ends in a space as well
                    while 1
                        ksp = strfind(call,'  ');
                        if isempty(ksp); break; end
                        call(ksp) = [];
                    end
                    ksp = strfind(call,' ');
                    if length(ksp) < 12
                        continue % line is formatted badly
                    end
                    in.cond = call(ksp(1)+1:ksp(2)-1);
                    in.housetemp = call(ksp(2)+1:ksp(3)-1);
                    in.psal = call(ksp(3)+1:ksp(4)-1);
                    in.hulltemp = call(ksp(4)+1:ksp(5)-1);
                    in.fluor1 = call(ksp(8)+1:ksp(9)-1);
                    in.fluor2 = call(ksp(9)+1:ksp(10)-1);
                    ot.cond = str2double(in.cond)*10;
                    ot.housetemp = str2double(in.housetemp);
                    ot.psal = str2double(in.psal);
                    ot.hulltemp = str2double(in.hulltemp);
                    ot.fluor1 = str2double(in.fluor1);
                    ot.fluor2 = str2double(in.fluor2);
                    fprintf(fid,'%4d %10.6f %3d %10.8f %9.5f %9.5f %9.5f %9.5f %9.5f %9.5f\n',ot.yyyy, ot.ddd, ot.doy, ot.dfrac, ot.cond, ot.housetemp, ot.psal, ot.hulltemp, ot.fluor1, ot.fluor2);
                case 'TSG2-SBE45'
                    in.cond = c{4};
                    in.housetemp = c{3};
                    in.psal = c{5};
                    ot.cond = str2double(in.cond)*10;
                    ot.housetemp = str2double(in.housetemp);
                    ot.psal = str2double(in.psal);
                    fprintf(fid,'%4d %10.6f %3d %10.8f %9.5f %9.5f %9.5f\n',ot.yyyy, ot.ddd, ot.doy, ot.dfrac, ot.cond, ot.housetemp, ot.psal);
                case 'SpeedLog-Furuno-VBW'
                    in.speedfa = c{4};
                    in.speedps = c{5};
                    ot.speedfa = str2double(in.speedfa);
                    ot.speedps = str2double(in.speedps);
                    fprintf(fid,'%4d %10.6f %3d %10.8f %6.2f %6.2f\n',ot.yyyy, ot.ddd, ot.doy, ot.dfrac, ot.speedfa, ot.speedps);
                otherwise
            end

        end

        fclose(fid)
        %
        % fprintf(1,'%s\n','Writing mat');
        %
        % save(fnmat,'bytes_all','data_all','time_all','vnames','vunits');

    end

end