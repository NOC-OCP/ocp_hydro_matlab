function ms_rawwin_to_sed(dn)

% dn is day of year, 1 Jan == 1
dnum = datenum([2023 1 1])+dn-1;
[yy mo dd] = datevec(dnum);
kday = 100*mo+dd;



% str = 'GPS-Furuno-GGA'; kkk = 0224;
% str = 'SingleBeam-Knudsen-PKEL99'; kkk = 224;%205:222;
% str = 'Gyro1-HDT'; kkk = 224; %[131 201:224];
% str = 'TSG1-SBE21'; kkk = 224;%[205:221];
% str = 'TSG2-SBE45'; kkk = 224;%[131 201:221];
% str = 'SpeedLog-Furuno-VBW'; kkk = 224;%[ 205:221];

% winch data are not in scs

procall = {
%     'GPS-Furuno-GGA'            226 %[131 201:225]
%     'SingleBeam-Knudsen-PKEL99' 226 % [205:222 224 225]
%     'Gyro1-HDT'                 226 %[131 201:225]
%     'TSG1-SBE21'                226 %[205:221 224 225]
%     'TSG2-SBE45'                226 % [131 201:221 224 225]
%     'SpeedLog-Furuno-VBW'       226 % [ 205:221 224 225]
    'Win1'                      kday % [131 201:226];
    };

for kproc = 1


    str = procall{kproc,1};
    kkk = procall{kproc,2};

    fprintf(1,'\n\n%s %4d %s %s\n','Reading day',kkk,'stream',str)

    for kl = kkk

%         fprintf('%s %d\n','kl = ',kl)
        mo = floor(kl/100);
        dd = kl-100*mo;

        fnrootin = [str '_2023' sprintf('%s%02d%s%02d','-',mo,'-',dd)];
        fnrootot = [str '_2023' sprintf('%04d',kl) '-000000'];
        
        fnraw = ['/mnt/cruisedata/winch/proc/' fnrootin '.tab'];

        fnsed = ['/local/users/pstar/projects/rpdmoc/en705/mcruise/data/scs/scs_daily/' fnrootot '.ACO'];
        fnmat = ['/local/users/pstar/projects/rpdmoc/en705/mcruise/data/scs/scs_daily/' fnrootot '.mat'];
        fndone = ['/local/users/pstar/projects/rpdmoc/en705/mcruise/data/scs/scs_daily/donelines.txt'];

        fprintf(1,'%s\n','reading raw');

%         raw = mtextdload(fnraw,',',0);
        raw = load(fnraw);

        nlines = size(raw,1);



        fid = fopen(fnsed,'a'); mfixperms(fnsed);

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

        if ~exist(fndone,'file')
            fid_done = fopen(fndone,'w'); mfixperms(fndone);
            fprintf(fid_done,'%s\n','zblank,0');
            fclose(fid_done);
        end
        fid_done = fopen(fndone,'r');
        % read in the done files so far
        done = {};
        while 1
            tline = fgetl(fid_done);
            if ~ischar(tline), break, end
            kcom = strfind(tline,',');
            new = {tline(1:kcom-1) tline(kcom+1:end)};
            done = [done; new];
        end
        fclose(fid_done);

        kfile = find(strcmp(fnsed,done(:,1)));

        if isempty(kfile)
            line1 = 1;
        else
            line1 = str2double(done{kfile,2})+1;
        end



        line2 = nlines;

        fprintf(1,'%s %d %s\n','parsing',line2-line1+1,'lines')



        for kk = line1:line2
            yyyy = raw(kk,1);
            yy3 = [yyyy 0*yyyy+1 0*yyyy];
            dorg = datenum(yy3);
            decday = raw(kk,2); % 31.5 is noon on 31 Jan;
            dnum = dorg+decday;

            dorg = datenum([2023 1 1]);
            ot.ddd = dnum-dorg+1;
            ot.doy = floor(ot.ddd);
            ot.dfrac = ot.ddd-ot.doy;
            ot.yyyy = yyyy;
            switch str
                case 'Win1'
                    ot.tension = raw(kk,3);
                    ot.rate = raw(kk,4);
                    ot.wireout = raw(kk,5);
                    fprintf(fid,'%4d %12.8f %3d %10.8f %6.0f %6.2f %7.1f\n',ot.yyyy, ot.ddd, ot.doy, ot.dfrac, ot.tension, ot.rate, ot.wireout);
                otherwise
            end

        end

        fclose(fid);
        %
        % fprintf(1,'%s\n','Writing mat');
        %
        % save(fnmat,'bytes_all','data_all','time_all','vnames','vunits');

        nowdone = {fnsed sprintf('%d',line2)};

        if isempty(kfile)
            done = [done; nowdone];
        else
            done(kfile,:) = nowdone;
        end

        fid_done = fopen(fndone,'w'); mfixperms(fndone);
        [~,ksort] = sort(done(:,1));
        done = done(ksort,:);
        for knum = 1:size(done,1)
            fprintf(fid_done,'%s%s%s\n',done{knum,1},',',done{knum,2});
        end
        fclose(fid_done);

    end

end