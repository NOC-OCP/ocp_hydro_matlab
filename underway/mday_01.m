function mday_01(streamname,mstarprefix,day,year)
% function mday_01(streamname,mstarprefix,day,year)
%
% use mdatapup to grab a day of data from a techsas NetCDF file or SCS file
%
% char: streamname is the techsas or scs stream name (mtnames or msnames 3rd column)
% char: mstarprefix is the prefix used in mstar filenames
% numeric: daynum is the day number
% numeric: year is the required year in which daynum falls. If not set it
%            is current year obtained from the matlab 'datevec(now)' command
%
% eg mday_01('gps_nmea','gps',33)
% or
% eg mday_01('gps_nmea','gps',33,09)
% or
% eg mday_01('gps_nmea','gps',33,2009)
% or
% eg mday_01('gps_nmea','gps','33','2009')
%

m_common
m_margslocal
m_varargs

mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

day_string = sprintf('%03d',day);
daylocal = day;
clear day % so that it doesn't persist

mdocshow(mfilename, ['loads in underway data stream ' streamname ', writes to ' mstarprefix '_' mcruise '_d' sprintf('%03d',daylocal), '_raw.nc']);

root_out = mgetdir(mstarprefix);
if exist(root_out,'dir') ~= 7
    % requested data stream/directory doesn't seem to exist
    m = ['Directory ' mstarprefix ' not found - skipping'];
    fprintf(MEXEC_A.Mfider,'%s\n',m);
    return
end

switch MEXEC_G.Mshipdatasystem
    
    case 'rvdas'
        
        % function mrrvdas2mstar(table, dn1, dn2, otfile, dataname)
        
        table = mstarprefix;
        dn1 = datenum([year 1 1 00 00 00]) + daylocal - 1;
        dn2 = datenum([year 1 1 23 59 59]) + daylocal - 1;
        
        prefix1 = [mstarprefix '_' mcruise '_'];
        fnmstar = [prefix1 'd' day_string '_raw'];
        otfile2 = fullfile(root_out, fnmstar);
        dataname = [prefix1 'd' day_string];
        
        mrrvdas2mstar(table,dn1,dn2,otfile2,dataname,'q');
        % mrrvdas2mstar will quit without writing a file if no data found.
        
        if ~exist(m_add_nc(otfile2),'file')
            % mrrvdas2mstar didn't make an output file, probably because no data cycles
            % found
            m = [otfile2 ' not created. Possibly no data cycles found in time range.'];
            fprintf(MEXEC_A.Mfider,'%s\n',' ',m,' ');
            %cmd = ['cd ' currentdir]; eval(cmd);
            return
        end

        
        
    otherwise
        
        yy = year-2000;
        timestart = 000000;
        timeend = 235959;
        instream = streamname; % this should be set in m_setup and picked up from a global var so that it doesn't have to be edited for each cruise/ship
        varlist = '-';
        
        prefix1 = [mstarprefix '_' mcruise '_'];
        fnmstar = [prefix1 'd' day_string '_raw'];
        otfile2 = fullfile(root_out, fnmstar);
        dataname = [prefix1 'd' day_string];
        
        % upgrade by bak at noc aug 2010 so it works on either scs or techsas
        if strncmp(MEXEC_G.Mshipdatasystem,'scs',3)
            mdatapupscs(yy,daylocal,timestart,yy,daylocal,timeend,'-',instream,otfile2,varlist);
        else % techsas
            mdatapuptechsas(yy,daylocal,timestart,yy,daylocal,timeend,'-',instream,otfile2,varlist);
        end
        
        if ~exist(m_add_nc(otfile2),'file')
            % mdatapup didn't make an output file, probably because no data cycles
            % found
            m = [otfile2 ' not created. Possibly no data cycles found in time range.'];
            fprintf(MEXEC_A.Mfider,'%s\n',' ',m,' ');
            %cmd = ['cd ' currentdir]; eval(cmd);
            return
        end
        
        
        % fix data time origin for datapup files that come in with century = 19.
        oldh = m_read_header(otfile2);
        torg = oldh.data_time_origin;
        oldyear = torg(1);
        if(oldyear < 1950); torg(1) = torg(1)+100;end
        torgstring = ['[' sprintf('%d %d %d %d %d %d',torg) ']'];
        
        MEXEC_A.MARGS_IN = {
            otfile2
            'y'
            '1'
            dataname
            '/'
            '2'
            MEXEC_G.PLATFORM_TYPE
            MEXEC_G.PLATFORM_IDENTIFIER
            MEXEC_G.PLATFORM_NUMBER
            '/'
            '4'
            torgstring
            '/'
            '-1'
            };
        mheadr
        
        % upgrade by bak at noc aug 2010 so it works on either scs or techsas
        if strncmp(MEXEC_G.Mshipdatasystem,'scs',3)
            mtranslate_varnames(otfile2,instream); % translate the var names as required, using lookup table derived from instream
        end
        
end
