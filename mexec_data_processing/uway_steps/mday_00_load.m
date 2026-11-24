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
% eg mday_00_load('gps_nmea',mutv,33)
% or
%

m_common
m_margslocal
m_varargs


%find this stream's line in the defining table
m = strcmp(streamname,mtable.tablenames);
mstarprefix = mtable.mstarpre{m};
status = 1;
if contains(mstarprefix,['not_' MEXEC_G.Mshipdatasystem])
    status = 2;
    return
end

%where to save processed data
opt1 = 'setup'; opt2 = 'pfiles'; run(MEXEC_G.opt_cruise)
root_out = fileparts(pfiles.uway_raw);
% make output directory if it doesn't exist
if exist(root_out,'dir') ~= 7
    mkdir(root_out); mfixperms(root_out, 'dir');
end

dataname = [mstarprefix '_' mcruise '_all'];
if MEXEC_G.quiet<=1; fprintf(1,'loading underway data stream %s to write to %s\n',streamname,pfiles.uway_raw); end

y = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1);
dn1 = datenum([y 1 1 0 0 0]) + yday - 1;
dn2 = dn1 + 1 - 1/86400;

switch MEXEC_G.Mshipdatasystem
    case 'rvdas'
        %use streamname in case there is more than one streamname that maps
        %to one mstarname
        argot.table = streamname;
        argot.dnums = [dn1 dn2];
        argot.otfile = pfiles.uway_raw;
        argot.dataname = dataname;
        argot.mrtv = mtable;
        status = mrrvdas2mstar('noparse',argot);
    case 'scs'
        status = scs_to_mstar2(streamname,mstarprefix,dn1,dn2,pfiles.uway_raw,dataname);
    case 'scs_ascii'
        load_uway_ascii(streamname) %***
        status = 0;
    otherwise
        warning('update for techsas')
end
