function [firstm lastm numdc] = mgetfiletimes(fname)
% function [firstm lastm numdc] = mgetfiletimes(fname)
%
% get the time of the first and last data cycle in a techsas file, and
% return the times as matlab datenums; return a third argument which is the
% number of data cycles in the techsas file.
%
% first draft BAK JC032
% 
% mstar techsas (mt) routine; requires mexec to be set up
%
% The techsas files are searched for in a directory uway_root defined in
% cruise options. At sea, this will typically be a data area exported from a
% ship's computer and cross-mounted on the mexec processing machine
%
% ylf modified jc159 to look for first/last good time in first/last 10
% points if first/last point is NaN

m_common

scriptname = 'ship'; oopt = 'datasys_best'; get_cropt
fullfn = [uway_root '/' fname];

techsas_time_dim = nc_getdiminfo(fullfn,'time'); % bak jc032 need to know present number of records in growing techsas file
techsas_time_length = techsas_time_dim.Length;

firstt = -uway_torg; lastt = firstt; numdc = 0; % default if no data in file

if techsas_time_length > 0
    firstt = nc_varget(fullfn,'time',0,1); % read one time cycle
    if isnan(firstt)
        firstt = min(nc_varget(fullfn,'time',0,10));
    end
    lastt = nc_varget(fullfn,'time',techsas_time_length-1,1);
    if isnan(lastt)
        lastt = max(nc_varget(fullfn,'time',techsas_time_length-10,10));
    end
    numdc = techsas_time_length;
end
firstm = MEXEC_G.uway_torg+firstt;
lastm = MEXEC_G.uway_torg+lastt;

