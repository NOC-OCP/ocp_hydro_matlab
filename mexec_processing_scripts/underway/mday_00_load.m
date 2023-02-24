function status = mday_00_load(streamname,mstarprefix,root_out,day,year)
% function status = mday_00_load(streamname,mstarprefix,root_out,day,year)
%
% use mdatapup to grab a day of data from a techsas NetCDF file or SCS file
%
% char: streamname is the techsas or scs stream name (mtnames or msnames
%     3rd column) or rvdas table name
% char: mstarprefix is the prefix used in mstar filenames
% numeric: daynum is the day number
% numeric: year is the required year in which daynum falls. If not set it
%            is current year obtained from the matlab 'datevec(now)' command
%
% eg mday_00_load('gps_nmea','gps',33)
% or
% eg mday_00_load('gps_nmea','gps',33,09)
% or
% eg mday_00_load('gps_nmea','gps',33,2009)
% or
% eg mday_00_load('gps_nmea','gps','33','2009')
%

m_common
m_margslocal
m_varargs

mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

day_string = sprintf('%03d',day);
if MEXEC_G.quiet<=1; fprintf(1,'loading underway data stream %s to write to %s_%s_d%s_raw.nc\n',streamname,mstarprefix,mcruise,day_string); end

status = 1;
% make output directory if it doesn't exist
if exist(root_out,'dir') ~= 7
    mkdir(root_out)
end

switch MEXEC_G.Mshipdatasystem
    
    case 'rvdas'
                
        table = mstarprefix;
        if contains(mstarprefix,'not_rvdas')
            status = 2;
            return
        end
        
        dn1 = datenum([year 1 1 00 00 00]) + day - 1;
        dn2 = datenum([year 1 1 23 59 59]) + day - 1;
        
        prefix1 = [mstarprefix '_' mcruise '_'];
        fnmstar = [prefix1 'd' day_string '_raw'];
        otfile2 = fullfile(root_out, fnmstar);
        dataname = [prefix1 'd' day_string];
        
        try
            mrrvdas2mstar(table,dn1,dn2,otfile2,dataname,'q');
        catch me
            if strcmp(me.message,'No data cycles loaded with mrload')
               m = [otfile2 ' not created because no data cycles found in time range.'];
            else
                m = ['mrrvdas2mstar failed with ' me.message];
            end
            fprintf(MEXEC_A.Mfider,'%s\n',' ',m,' ');
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
            mdatapupscs(yy,day,timestart,yy,day,timeend,'-',instream,otfile2,varlist);
        else % techsas
            mdatapuptechsas(yy,day,timestart,yy,day,timeend,'-',instream,otfile2,varlist);
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
status = 0;
