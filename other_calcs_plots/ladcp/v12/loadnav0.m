%======================================================================
%                    L O A D N A V . M 
%                    doc: Thu Jun 17 18:01:50 2004
%                    dlm: Mon Jan  3 02:01:17 2011
%                    (c) 2004 ladcp@
%                    uE-Info: 252 25 NIL 0 0 72 0 2 8 NIL ofnI
%======================================================================

% MODIFICATIONS BY ANT:
%   Jun 26, 2004: - totally re-wrote the file-reading, which reduces
%		    run time by over factor 90(!!!) --- 5.7 instead of
%		    527 seconds in the test case --- for deep casts
%   Jul  1, 2004: - added support for time bases
%		  - made input definition flexible
%		  - removed ipos argument
%   Dec 18, 2004: - BUG: header_lines > 0 did not work
%   Jun  9, 2005: - improved time-base comments
%   Aug  9, 2006: - added support for elapsed-time
%   Jan  5, 2007: - removed LADDER-1 specific code for IX_4 distribution
%		  - added Dan Torres' code to interpolate irregular
%		    GPS time series
%		  - added nav file layout into p structure
%   Jan 17, 2007: - added support for new [geomag.m]
%   Jan 26, 2007: - BUG: file layout default was in p (rather than f) structure
%   Jun 30, 2008: - adapted to calculate magdev using external program geomag60
%   Jul  2, 2008: - BUG: missing "" in geomag command to allow spcs in 
%			 cof-file path
%   Jul 17, 2008: - moved some code to [loadctd.m] to fix bug associated with
%		    adjusting of start/end positions in case of significant
%		    ADCP vs GPS/CTD clock offset (unclear whether this happened
%		    only when elapsed time was used)
%   Jul 27, 2008: - nanmean() -> meannan()
%   Oct 15, 2008: - replaced mean by median to get lat/lon (bad outliers in L1 data set)
%   Dec  1, 2009: - BUG: geomag date check was wrong (Dec 1 2009 resulted in a date >= 2010)
%   Jan 22, 2010: - adapted to Eric Firing's much simplified magdec utility
%   Jan  3, 2011: - changed IGRF11 validity to end of 2015 (from 2010)
%   Jan  6, 2016: - changed IGRF11 validity to end of 2016 (from 2015)
%   Feb  7, 2020: EPAB changed IGRF13 validity to end of 2025.

function [d,p]=loadnav(f,d,p)
% function [d,p]=loadnav(f,d,p)

% This routine works for generic ASCII files, containing GPS time series,
% with fields time, lat and lon.

%====================
% TWEAKABLES
%====================

% PRE-AVERAGING OF GPS TIME (IN DAYS)
p = setdefv(p,'navtime_av',2/60/24);

% INTERPOLATE IRREGULAR NAV TIME SERIES (Dan Torres)
p=setdefv(p,'interp_nav_times',0);

% FILE LAYOUT
f = setdefv(f,'nav_header_lines',0);
f = setdefv(f,'nav_fields_per_line',3);
f = setdefv(f,'nav_time_field',1);
f = setdefv(f,'nav_lat_field',2);
f = setdefv(f,'nav_lon_field',3);

% TIME BASE
% 	0 for elapsed time in seconds
% 	1 for year-day (1.0 = Jan 1, 00:00)
% 	2 for Visbeck's Gregorian (see gregoria.m)
p = setdefv(p,'nav_time_base',0);

%======================================================================

% MODIFICATIONS BY ANT:
%   Jun 26, 2004: - totally re-wrote the file-reading, which reduces
%		    run time by over factor 90(!!!) --- 5.7 instead of
%		    527 seconds in the test case --- for deep casts
%   Jul  1, 2004: - added support for time bases
%		  - made input definition flexible
%		  - removed ipos argument
%   Dec 18, 2004: - BUG: header_lines > 0 did not work
%   Jun  9, 2005: - improved time-base comments
%   Aug  9, 2006: - added support for elapsed-time
%   Jan  5, 2007: - removed LADDER-1 specific code for IX_4 distribution
%		  - added Dan Torres' code to interpolate irregular
%		    GPS time series
%		  - added nav file layout into p structure
%   Jan 17, 2007: - added support for new [geomag.m]
%   Jan 26, 2007: - BUG: file layout default was in p (rather than f) structure
%   Jan  7, 2009: - tightened use of exist()

disp(['LOADNAV: load NAV time series ',f.nav])
if ~exist(f.nav,'file')
 disp([' can not find ',f.nav])
 return
end

% construct input format
cur_field = 1; input_format = '';
for i=1:f.nav_fields_per_line
  switch i,
    case f.nav_time_field,
      i_time = cur_field; cur_field = cur_field + 1;
      input_format = [input_format ' %g'];
    case f.nav_lat_field
      i_lat = cur_field; cur_field = cur_field + 1;
      input_format = [input_format ' %g'];
    case f.nav_lon_field
      i_lon = cur_field; cur_field = cur_field + 1;
      input_format = [input_format ' %g'];
    otherwise
      input_format = [input_format ' %*g'];
  end
end
if cur_field ~= 4
  error('File format definition error');
end

% open input & skip header
header_lines = f.nav_header_lines;
fp=fopen(f.nav);
while header_lines > 0
  fgets(fp);
  header_lines = header_lines - 1;
end

% read time series
[A,nread] = fscanf(fp,input_format,[3,inf]);

% close file
fclose(fp);

% NAV time
d.navtime_jul=A(i_time,:)';
switch f.nav_time_base
  case 0 % elapsed time in seconds
    d.navtime_jul = d.navtime_jul/24/3600 + julian(p.time_start);
  case 1 % year-day
    d.navtime_jul = d.navtime_jul + julian([p.time_start(1) 1 0 0 0 0]);
end

disp([' number of NAV scans: ',int2str(length(d.navtime_jul)),...
       '  delta t : ',num2str(median(diff(d.navtime_jul))*24*3600),' seconds'])

%----------------------------------------
% interpolate to regular time series
%	code provided by Dan Torres
%----------------------------------------

if p.interp_nav_times
  min_t = min(d.navtime_jul);
  max_t = max(d.navtime_jul);
  delta_t = median(diff(d.navtime_jul));
  data = interp1q(d.navtime_jul,A([i_lat i_lon],:)',[min_t:delta_t:max_t]');
  d.navtime_jul = [min_t:delta_t:max_t]';
  disp(sprintf(' interpolated to %d NAV scans; delta_t = %.2f seconds',...
		length(d.navtime_jul),median(diff(d.navtime_jul))*24*3600));
else
  data=A([i_lat i_lon],:)';
end

p.navdata = 1;
d.slat = data(:,1);
d.slon = data(:,2);

% =================================================================
% - at this point nav data is in d.navtime_jul, d.slon, d.slat
%   and p.navdata is set to 1
% - time shifting & extraction of begin/end position is handled
%   in [loadctd.m]
% =================================================================

if ~isfinite(p.drot)		      % set magdecl
 [s,o] = system('magdec');
 if s == 1
   p.drot = geomag(f,meannan(d.navtime_jul),medianan(d.slat),medianan(d.slon));
 else
   warn = sprintf('"magdec" not found; using old magdev code with IGRF00',f.IGRF);
   disp(['WARNING: ' warn]);
   p.warn(size(p.warn,1)+1,1:length(warn))=warn;
   p.drot = magdev(medianan(d.slat),medianan(d.slon));
 end
 [d.ru,d.rv]=uvrot(d.ru,d.rv,p.drot);
 [d.bvel(:,1),d.bvel(:,2)]=uvrot(d.bvel(:,1),d.bvel(:,2),p.drot);
 disp(sprintf(' corrected for magnetic declination of %.1f deg',p.drot));
end

% ================================================================

function depth=p2z(p,lat)
% !!!!!! USES Z=0 AT P=0  (I.E. NOT 1ATM AT SEA SURFACE)
%	pressure to depth conversion using
%	saunders&fofonoff's method (deep sea res.,
%	1976,23,109-111)
%	formula refitted for alpha(p,t,s) = eos80
%	units:
%		depth         z        meter
%		pressure      p        dbars  (original in bars, but below
%                                              division by 10 is included)
%		latitude      lat      deg
%	checkvalue:
%		depth =       9712.654  m
%	for
%		p     =         1000.     bars
%		lat   =           30.     deg
%	real lat,p
        if nargin < 2, lat=54; end
        p=p/10.;
	x=sin(lat/57.29578);
	x=x*x;
	gr=9.780318*(1.0+(5.2788e-3+2.36e-5*x)*x)+1.092e-5*p;
	depth=(((-1.82e-11*p+2.279e-7).*p-2.2512e-3).*p+97.2659).*p;
	depth=depth./gr;
%

function a=datestrj(b)
% 
% print julian date string
%
a=datestr(b-julian([0 1 0 0 0 0]));

%
%==============================================================
function [hours]=hms2h(h,m,s);
%HMS2H converts hours, minutes, and seconds to hours
%
%  Usage:  [hours]=hms2h(h,m,s);   or [hours]=hms2h(hhmmss);
%
if nargin== 1,
   hms=h;
   h=floor(hms/10000);
   ms=hms-h*10000;
   m=floor(ms/100);
   s=ms-m*100;
   hours=h+m/60+s/3600;
else
   hours=h+(m+s/60)/60;
end

%===============================================================
function  dev=geomag(f,date,lat,lon);
% function  dev=geomag(f,date,lat,lon);
% 
% call SOEST magdec to compute magnetic deviation

% INSTALLATION INSTRUCTIONS:
%	- src available as "geomag" at http://currents.soest.hawaii.edu/hg/hgwebdir.cgi
%	- on UNIX systems (I tested Linux, MacOSX & FreeBSD), 
%		1) compile by typing "make" or "gmake" in source directory
%		2) install by typing "make install" or "gmake install" as root
%		3) test by executing matlab command "system('magdec')"
%			if this test produces an error and a return value of 127, 
%			the path is not set correctly

dstr = gregoria(date);					% convert date (approx)
year = dstr(1); month = dstr(2); day = dstr(3);
if (year < 1900 || year > 2025)
	error(sprintf('year = %d out of range',year));
end
							% execute external program
CMD = sprintf('magdec %g %g %d %d %d',lon,lat,year,month,day);
disp(sprintf('executing %s',CMD));
[status,work] = system(CMD);
if status ~= 0
	error(['cannot execute <' CMD '>']);
end

vals = sscanf(work,'%g');				% parse output
if length(vals) ~= 4
	error(['unexpected output from <' CMD '>']);
end

dev = vals(1);						% return result
