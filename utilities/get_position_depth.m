function get_position_depth(YYYY,MM,dd)
% Find the positions and depths at given times
% e.g.  get_position_depth(2020,03,11)
% then follow prompts to enter times
% assumes that if a time is earlier than previous then it must be following day
% Also gives plot of data so that can be sure answer is not a spike

m_setup;
this_cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
nav_stream = 'posmvpos';
dep_stream = 'sim';
%dep_stream = 'em120';

disp('This script gives positions and depths at user given times')
disp('and plots values over and interval to check for data quality')
disp('Now enter times (UTC) - you must enter atleast 2 times. ')
ient = 1; i = 0;

while ient == 1
    i = i+1;
    disp(['Enter time of position number ' num2str(i-1)])
    stime = input('Time (hh:mm) or (hh:mm:ss) or press return to finish: ','s');
    if strmatch(stime,'');
      ient = 0;
    else
      ctime(i) = {stime};
      hh(i) = str2num(stime(1:2));
      mm = str2num(stime(4:5));
      if length(stime) == 8
        ss = str2num(stime(7:8));
      else
        ss = 0;
      end  
      tme(i) = datenum([YYYY MM dd hh(i) mm ss]) ;
    end
end

% how many points
no_fixes=length(tme);

% in case we go over midnight
for i = 2:no_fixes
  if tme(i) < tme(i-1)
    tme(i) = tme(i)+1;
	fprintf(1,'Assuming monotonic time adding one day!')
  end
end

% Techsas has different time origin
tmm = tme - MEXEC_G.uway_torg;
dtt = 0.1*(tme(end)-tme(1));

% Now get data from Techsas
pos = mtload(nav_stream,datevec(tme(1)-dtt), ...
                        datevec(tme(end)+dtt),'time lat long');
pos.lon = pos.long;
pos.tme = pos.time + MEXEC_G.uway_torg;
lat = interp1(pos.tme,pos.lat,tme);
lon = interp1(pos.tme,pos.lon,tme);

dep = mtload(dep_stream,datevec(tme(1)-dtt), ...
                        datevec(tme(end)+dtt),'time depthm');    

if ~isempty(dep)
	dep.snd = dep.depthm;
	dep.tme = dep.time + MEXEC_G.uway_torg;
	iabs = dep.snd == 0 | isnan(dep.snd) | isnan(dep.tme); 
	dep.snd = dep.snd(~iabs); dep.tme = dep.tme(~iabs);
	[dep.tme,ii,jj] = unique(dep.tme);
	dep.snd = dep.snd(ii);
	wd2 = interp1(dep.tme,dep.snd,tme);
% Work corrected water depths
	for i=1:no_fixes
	    corr_struct = 	mcarter(lat(1),lon(1),wd2(i));
	    wd_corr(i) = corr_struct.cordep;
	end    
	pos.wd = interp1(dep.tme,dep.snd,pos.tme);
	corr_struct = 	mcarter(pos.lat,pos.lon,pos.wd);
	pos.wdc = corr_struct.cordep;
else
	wd2 = NaN*tme;
	wd_corr = wd2;
end

iout = 1;
fprintf(iout,'Time   Lat   Lon  Uncorr Depth Corr depth \n');

for i = 1:no_fixes
  latc = dd2dmc(lat(i));
  lonc = dd2dmc(lon(i));
  fprintf(iout,' %s  %8.4f %8.4f %7.1f % 7.1f \n', ...
  		char(ctime(i)),lat(i),lon(i),wd2(i),wd_corr(i));
  fprintf(iout,'        %s N %s E \n',latc,lonc);
end


figure
subplot(3,1,1)
if ~isempty(dep)
	plot(pos.tme,pos.wdc);
	hold on
	y1 = ylim; 
	for i = 1:no_fixes
  		t1 = tme(i);
  	  	plot([t1 t1],y1,'r');
	end
	datetick;xlabel('Time'),ylabel('Depth');grid on
	ttx = sprintf('%4.4i-%2.2i-%2.2i \n',YYYY,MM,dd);
	title(ttx)
end
subplot(3,1,2)
plot(pos.tme,pos.lon);
hold on
y1 = ylim; t1 = tme(1);
for i = 1:no_fixes
  t1 = tme(i);
  plot([t1 t1],y1,'r');
end
datetick;xlabel('Time'),ylabel('Longitude');grid on
subplot(3,1,3)
plot(pos.tme,pos.lat);
hold on
y1 = ylim; t1 = tme(1);
for i = 1:no_fixes
  t1 = tme(i);
  plot([t1 t1],y1,'r');
end
datetick;xlabel('Time'),ylabel('Latitude');grid on


function [ddmmc] = dd2dmc(dddd)
% Convert format from decimal degrees (dd.dd) to the degrees minutes format
% used by the Slocum Glider (ddmm.mm)
%
% eg.  -115.25 --> -11515
 s = sign(dddd);      % Save original sign
 dddd = abs(dddd);    % Absolute
 d = fix(dddd);       % Degrees
 dd = dddd - d;       % Decimal degrees
 m = dd.*60;            % Decimal Degrees -> Minutes
 ddmm = s.*((d*100)+m);    % Combine degrees and decimal degrees and restore sign
 ddmmc = sprintf('%4.0f%s%5.2f',s*d,char(176),m);


