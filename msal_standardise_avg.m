function ds_sal = msal_standardise_avg(ds_sal);
%function ds_sal = msal_standardise_avg(ds_sal);
%
% operates on dataset having fields
%    sample1, sample2, sample3, cellT
%       the three salinometer readings and the salinometer bath temperature
%    and variable other fields:
%    to specify the station and niskin for a CTD sample, or the time for a TSG sample, 
%       must either have fields
%          station_day, cast_hour, niskin_minute
%       or have field
%          sampnum
%       for CTD samples, sampnum = station_day*1e2 + niskin_minute
%       for TSG samples, sampnum = -(station_day*1e4 + cast_hour*1e2 + niskin_minute); 
%       TSG station_day is yearday (starts at 1 on 1st Jan)
%    to specify/calculate salinometer standard offset,
%       must either have field
%          offset
%             giving the offset for each sample
%       or include standards runs, indicated by station_day = 000, and have field
%          K15
%             giving the expected salinometer reading for each standard run
%       in the second case, the autosal offsets will be computed here and linearly interpolated to samples between standards runs
%    optionally may have a flag field
%
% returns dataset having fields
%    sampnum, station_day, cast_hour, niskin_minute, sample1, sample2, sample3, cellT, offset, rval, flag
%       where rval is the best average salinometer value for each line, adjusted for standards offset

m_common

scriptname = 'msal_standardise_avg';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

% want to have both sampnum and station_day, cast_hour, niskin_minute fields
if sum(strcmp('station_day',ds_sal.Properties.VarNames))==0
   %CTD
   ds_sal.station_day = floor(ds_sal.sampnum/100);
   ds_sal.cast_hour = zeros(size(ds_sal.sampnum));
   ds_sal.niskin_minute = ds_sal.sampnum-ds_sal.station_day*100;
   %TSG
   ii = find(ds_sal.sampnum<0);
   ds_sal.station_day(ii) = floor(-ds_sal.sampnum(ii)/1e4);
   ds_sal.cast_hour(ii) = floor((-ds_sal.sampnum(ii)-ds_sal.station_day(ii)*1e4)/1e2);
   ds_sal.niskin_minute(ii) = -ds_sal.sampnum(ii)-ds_sal.station_day(ii)*1e4-ds_sal.cast_hour(ii)*1e2;
end
if sum(strcmp('sampnum',ds_sal.Properties.VarNames))==0
   %CTD
   ds_sal.sampnum = ds_sal.station_day*100 + ds_sal.niskin_minute;
   %TSG
   ii = find(ds_sal.sampnum<0);
   ds_sal.sampnum(ii) = -(ds_sal.station_day(ii)*1e4 + ds_sal.cast_hour(ii)*1e2 + ds_sal.niskin_minute(ii));
end

if sum(strcmp('r1',ds_sal.Properties.VarNames))==0; ds_sal.r1 = ds_sal.sample1; end
if sum(strcmp('r2',ds_sal.Properties.VarNames))==0; ds_sal.r2 = ds_sal.sample2; end
if sum(strcmp('r3',ds_sal.Properties.VarNames))==0; ds_sal.r3 = ds_sal.sample3; end

ds_sal.r1(ds_sal.r1<=-999) = NaN; ds_sal.r2(ds_sal.r2<=-999) = NaN; ds_sal.r3(ds_sal.r3<=-999) = NaN;

if sum(strcmp('offset',ds_sal.Properties.VarNames))==0
   iistd = find(ds_sal.station_day==0 | ds_sal.station_day>900); iistd = iistd(:);
   ds_sal.offset = NaN+zeros(length(ds_sal.K15),1);
   ds_sal.offset(iistd) = repmat(2*ds_sal.K15(iistd), 1, 3) - [ds_sal.r1(iistd) ds_sal.r2(iistd) ds_sal.r3(iistd)];

   cellTs = ds_sal.cellT(iistd);

   oopt = 'std2use'; get_cropt %if not otherwise set, a keyboard prompt appears
   if doplot
      plot(iistd, offs(:,1), 'o', iistd, offs(:,2), 's', iistd, offs(:,3), '<')
      disp('if necessary, set std2use in opt_cruise'); keyboard
   end
   offs(std2use==0) = NaN; offs = nanmean(offs, 2); %these are the "best" standards offsets

   iisam = setdiff([1:length(ds_sal.station_day)]', iistd); 
   sams0 = [ds_sal.r1(iisam) ds_sal.r2(iisam) ds_sal.r3(iisam)];
   sams = sams0 + repmat(interp1(iistd, offs, iisam), 1, 3);
   ds_sal.cellT(iisam) = interp1(iistd, cellTs, iisam);

else
   iisam = find(ds_sal.station_day<900);
   sams0 = [ds_sal.r1(iisam) ds_sal.r2(iisam) ds_sal.r3(iisam)];
   sams = sams0 + repmat(ds_sal.offset(iisam), 1, 3);
end

oopt = 'sam2use'; get_cropt %if not otherwise set, will plot for tsg and individual stations, pausing to enable setting/editing sam2use and salbotqf
if doplot
   subplot(3,1,1); plot(iisam, sams(:,1), 'o', iisam, sams(:,2), 's', iisam, sams(:,3), '<')
   ii = find(ds_sal.station_day(iisam)<0); %these are for TSG
   disp('if necessary, set sam2use, salbotqf in opt_cruise');
   subplot(3,3,[4 7]); plot(ii, sams0(ii,1), 'o', ii, sams0(ii,2), 's', ii, sams0(ii,3), '<'); title('tsg');
   stnos = unique(ds_sal.station_day(ds_sal.station_day>0 & ds_sal.station_day<900)); %plot for all CTDs
   for no = 1:length(stnos)
      ii = find(ds_sal.station_day(iisam)==stnos(no));
      subplot(3,3,[5 6 8 9]); plot(ii, sams0(ii,1), 'o', ii, sams0(ii,2), 's', ii, sams0(ii,3), '<'); title(['ctd ' num2str(stnos(no))]); keyboard
   end
end
sams(sam2use==0) = NaN; sams = nanmean(sams, 2); %these are the "best" values for each sample

ds_sal.rval = NaN+zeros(length(ds_sal.r1),1);
if ~sum(strcmp('flag', ds_sal.Properties.VarNames)); ds_sal.flag = 9+zeros(length(ds_sal.r1),1); end
ds_sal.rval(iisam) = sams; ds_sal.flag(iisam) = salbotqf;
