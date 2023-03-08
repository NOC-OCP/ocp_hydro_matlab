function status = mday_00_load(streamname,mstarprefix,root_out,day,year)
% function status = mday_00_load(streamname,mstarprefix,root_out,day,year)
%
% use mrrvdas2mstar or mdatapup to grab a day of data from a techsas NetCDF
% file, an SCS file, or an RVDAS table, subsample to 1 Hz, and add to
% appended file for this stream 
%
% char: streamname is the techsas or scs stream name (mtnames or msnames
%     3rd column) or rvdas table name
% char: mstarprefix is the prefix used in mstar filenames
% numeric: day is the day number
% numeric: year is the year in which day falls
%
% eg mday_00_load('gps_nmea','gps',33,2009)
% or
% eg mday_00_load('gps_nmea','gps','33','2009')
%

m_common
m_margslocal
m_varargs
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

status = 1;
if contains(mstarprefix,'not_rvdas')
    status = 2;
    return
end
% make output directory if it doesn't exist
if exist(root_out,'dir') ~= 7
    mkdir(root_out)
end

%day_string = sprintf('%03d',day);
%dataname = [mstarprefix '_' mcruise '_d' day_string];
dataname = [mstarprefix '_' mcruise '_all'];
fnmstar = [dataname '_raw'];
otfile2 = fullfile(root_out, fnmstar);
if MEXEC_G.quiet<=1; fprintf(1,'loading underway data stream %s to write to %s\n',streamname,mstarprefix,mcruise,fnmstar); end

dn1 = datenum([year 1 1 00 00 00]) + day - 1;
dn2 = datenum([year 1 1 23 59 59]) + day - 1;

switch MEXEC_G.Mshipdatasystem
    
    case 'rvdas'
                
        %use streamname in case there is more than one streamname that maps
        %to one mstarname
        status = mrrvdas2mstar(streamname,dn1,dn2,otfile2,dataname,'q');
        
    otherwise
        
        yy = year-2000;
        timestart = datestr(dv1,'HHMMSS');
        timeend = datestr(dv2,'HHMMSS');
        instream = streamname; % this should be set in m_setup and picked up from a global var so that it doesn't have to be edited for each cruise/ship
        varlist = '-';
                
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
        else
            status = 0;
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
