function [d, h] = codas_to_mstar(inst)
% function [d, h] = codas_to_mstar(inst);
%
% read data from CODAS .nc file into data and header structures like those
% loaded from mstar files by mload
%
% YLF jc238, derived from mvad_01 (BAK)
% it is no longer part of standard processing to convert the whole CODAS
%   .nc to Mstar .nc (though you could save d and h to an Mstar format file
%   using mfsave)
% instead, this function is called by mvad_list_stations and mvad_stations
%   to list or average VMADCP data for other processing

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

root_vmadcp = mgetdir('M_VMADCP');
                fnin = fullfile(root_vmadcp, 'postprocessing', upper(mcruise), 'proc_editing', inst, 'contour', [inst '.nc']);
opt1 = mfilename; opt2 = 'codas_file'; get_cropt
if ~exist(fnin, 'file')
    error(['input file ' fnin ' not found'])
end

%load data
allin.decday = double(nc_varget(fnin,'time'));
unin.decday = nc_attget(fnin,'time','units');
allin.lon = double(nc_varget(fnin,'lon'));
unin.lon = 'degrees';
allin.lat = double(nc_varget(fnin,'lat'));
unin.lat = 'degrees';
allin.depth = double(nc_varget(fnin,'depth')).';
unin.depth = 'metres';
allin.uabs = double(nc_varget(fnin,'u')).';
unin.uabs = 'm/s';
allin.vabs = double(nc_varget(fnin,'v')).';
unin.vabs = unin.uabs;
allin.uship = double(nc_varget(fnin,'uship'));
unin.uship = 'm/s';
allin.vship = double(nc_varget(fnin,'vship'));
unin.vship = unin.vabs;
% CODAS uses missing_value = 1.0e38 turn these into NaN now.
allin.lat(allin.lat > 1e10) = nan;
allin.lon(allin.lon > 1e10) = nan;
allin.uabs(allin.uabs > 1e10) = nan;
allin.vabs(allin.vabs > 1e10) = nan;
allin.uship(allin.uship > 1e10) = nan;
allin.vship(allin.vship > 1e10) = nan;
kf = strfind(unin.decday,'since');
torgstr = unin.decday(kf+5:end);
cotorg = datenum(torgstr);
torgstr = datestr(cotorg,'yyyy mm dd HH MM SS');
allin.time = 86400*allin.decday; % input time is decimal days past cotorg
unin.time = 'seconds';

% expand the 1-D vars to 2-D
ndeps = size(allin.depth,1);
d = allin;
d.time = repmat(allin.time,1,ndeps).';
d.lat = repmat(allin.lat,1,ndeps).';
d.lon = repmat(allin.lon,1,ndeps).';
d.decday = repmat(allin.decday,1,ndeps).';
d.uship = repmat(allin.uship,1,ndeps).';
d.vship = repmat(allin.vship,1,ndeps).';
d.speed = sqrt(d.uabs.*d.uabs + d.vabs.*d.vabs);
unin.speed = unin.uabs;
d.shipspd = sqrt(d.uship.*d.uship + d.vship.*d.vship);
unin.shipspd = unin.uship;

%construct header
h = m_default_attributes;
h.dataname = [inst '_' mcruise '_01'];
h.data_time_origin_string = torgstr;
h.data_time_origin = datevec(cotorg);
h.fldnam = fieldnames(d);
h.fldunt = {};
for no = 1:length(h.fldnam)
    h.fldunt{no} = unin.(h.fldnam{no});
end
h.comment = ['loaded from ' fnin ' on ' datestr(now)];
