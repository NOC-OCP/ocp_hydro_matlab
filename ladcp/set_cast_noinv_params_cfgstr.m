%======================================================================
%          S E T _ C A S T _ P A R A M S _ C F G S T R . M 
%                    doc: Mon Oct 30 23:25:48 2006
%                    dlm: Fri Aug 19 13:50:14 2011
%                    (c) 2006 ladder@
%                    uE-Info: 9 22 NIL 0 0 72 0 2 4 NIL ofnI
%
%   YLF Sep 2017 based on set_cast_params.m
%   selects options using cfgstr passed through from
%   process_cast_cfgstr
%
%======================================================================

stnlocal = stn; m_global; minit; stn = stnlocal; stnstr = sprintf('%03d', stnlocal);
cd([MEXEC_G.MEXEC_DATA_ROOT '/ladcp/ix/'])
rawdir = 'raw/';

if strcmp(cfgstr.orient, 'DL')
    isdo = 1; isup = 0;
elseif strcmp(cfgstr.orient, 'UL')
    isdo = 0; isup = 1;
elseif strcmp(cfgstr.orient, 'DLUL') | strcmp(cfgstr.orient, 'ULDL')
    isdo = 1; isup = 1;
else
   error('orientation must be one of: DL, UL, DLUL, or ULDL')
end

%enable (or not) SADCP and/or bottom tracking constraints,
%and set up output directories accordingly
subdir = cfgstr.orient;
for no = 1:length(cfgstr.constraints)
   subdir = [subdir '_' cfgstr.constraints{no}];
   if strcmp(cfgstr.constraints{no}, 'BT'); ps.botfac = 1; else; ps.botfac = 0; end
   if strcmp(cfgstr.constraints{no}, 'SADCP'); ps.sadcpfac = 1; else; ps.sadcpfac = 0; end
end
if length(cfgstr.constraints)==0
   subdir = [subdir 'SHR']; %***not sure this will work--what happens if f.ctd is not set?
end
pdir = [subdir '/processed/' stnstr '/'];
if ~exist(pdir, 'dir')
   unix(['mkdir -p ' pdir])
end

close all;
more off;

%find files and set f.ladcpdo and f.ladcpup (if applicable)
%this code allows for the possiblity of multiple files
if isdo
   d = dir([rawdir stnstr '/' stnstr 'DL*.000']);
   dlfiles = {};
   ii = [];
   for no = 1:length(d)
      if d(no).bytes>1024; ii = [ii no]; end
      dlfiles{no} = [rawdir stnstr '/' d(no).name];
   end
   if length(ii)==1; dlfiles = dlfiles{ii}; else; dlfiles = dlfiles(ii); end
end
if isup
   d = dir([rawdir stnstr '/' stnstr 'UL*.000']);
   ulfiles = {};
   ii = [];
   for no = 1:length(d)
      if d(no).bytes>1024; ii = [ii no]; end
      ulfiles{no} = [rawdir stnstr '/' d(no).name];
   end
   if length(ii)==1; ulfiles = ulfiles{ii}; else; ulfiles = ulfiles(ii); end
end
if isdo & ~isup % downlooker only
   f.ladcpdo = dlfiles;
   f.ladcpup = ' ';
elseif ~isdo & isup % uplooker only, put it in ladcpdo as required by code
   f.ladcpdo = ulfiles;
   f.ladcpup = ' ';
elseif isdo & isup % both
   f.ladcpdo = dlfiles;
   f.ladcpup = ulfiles;
end

f.res = [pdir stnstr];
f.checkpoints = sprintf('checkpoints/%03d',stnlocal);
f.sadcp	= ['SADCP/os75_' mcruise '_ctd_' stnstr '.mat'];

f.ctd = ['CTD/ctd.' stnstr '.02.asc'];
if exist(f.ctd,'file')
	f.ctd_header_lines      = 0;		% file layout
	f.ctd_fields_per_line	= 7;
	f.ctd_pressure_field	= 2;
	f.ctd_temperature_field = 3;
	f.ctd_salinity_field	= 4;
	f.ctd_time_field	= 1;
	f.ctd_time_base 	= 0;		% elapsed
	
	f.nav                   = f.ctd;
	f.nav_header_lines	= f.ctd_header_lines;
	f.nav_fields_per_line	= f.ctd_fields_per_line;
	f.nav_time_field	= f.ctd_time_field;
	f.nav_lat_field 	= 5;
	f.nav_lon_field 	= 6;
	f.nav_time_base         = f.ctd_time_base;
else
	f.ctd = ' ';
%	p.drot = 6.3;						%%% nominal
end

%======================================================================

p.cruise_id	= mcruise;
%p.whoami	= 'Y. Firing';
p.ladcp_station = stnlocal;
p.name		= sprintf('%s cast #%d (processing version %s)',p.cruise_id,p.ladcp_station,subdir);

p.saveplot	= [1:14];
p.saveplot_png	= [1:14];
p.orig = 1; % save original data or not

p.btrk_ts = 30;		% with 10 default, false bottom detected on stnlocal 002
					% with 20, false bottom detected on stnlocals 22 & 23

p.avdz = 5;		% for compatibility with UH & new shearmethod output
ps.dz = 5;

p.btrk_mode = 2;

p.edit_mask_dn_bins = [1];
p.edit_mask_up_bins = [1];

p.checkpoints = [1];

%======================================================================
% Diagnostic paramters
%======================================================================
% ps.sadcpfac = 0;
% p.ignore_beam = [4 2];    % for DL/UL profiles
% p.ignore_beam = [4 nan];  % for DL only
% p.ignore_beam = [2 nan];  % for UL only

