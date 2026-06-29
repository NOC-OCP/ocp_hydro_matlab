function status = mday_00_load(streamname, yday, mtable)
% function status = mday_00_load(streamname, yday, mtable)
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
% eg mday_00_load('gps_nmea',mrtv,33)
% or
%

m_common
m_margslocal
m_varargs
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;


%lookup for this stream
m = strcmp(streamname,mtable.tablenames);
mstarprefix = mtable.mstarpre{m};
status = 1;
if contains(mstarprefix,'not_rvdas')
    status = 2;
    return
end
root_out = fullfile(MEXEC_G.mexec_data_root,mtable.mstardir{m});

% make output directory if it doesn't exist
if exist(root_out,'dir') ~= 7
    mkdir(root_out); mfixperms(root_out, 'dir');
end

dataname = [mstarprefix '_' mcruise '_all'];
fnmstar = [dataname '_raw'];
otfile2 = fullfile(root_out, fnmstar);
if MEXEC_G.quiet<=1; fprintf(1,'loading underway data stream %s to write to %s\n',streamname,mstarprefix,mcruise,fnmstar); end

y = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1);
dn1 = datenum([y 1 1 0 0 0]) + yday - 1;
dn2 = dn1 + 1 - 1/86400;

switch MEXEC_G.Mshipdatasystem
    case 'rvdas'                
        %use streamname in case there is more than one streamname that maps
        %to one mstarname
        argot.table = streamname; 
        argot.dnums = [dn1 dn2]; 
        argot.otfile = otfile2;
        argot.dataname = dataname;
        argot.mrtv = mtable;
        status = mrrvdas2mstar('noparse',argot);
    case 'scs'
        status = scs_to_mstar2(streamname,mstarprefix,dn1,dn2,otfile2,dataname);
    otherwise
        warning('update for techsas')
end
