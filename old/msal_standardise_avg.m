function msal_standardise_avg
%function msal_standardise_avg
%
%    loads a comma-delimited file, specified by opt_cruise,
%    which must have one of two general formats (see below)
%
%    puts fields into dataset ds_sal, with fields
%       sampnum, station_day, cast_hour, niskin_minute, sample1, sample2, sample3, cellT, offset, rval, flag
%          where rval is the best average salinometer value for each line, adjusted for standards offset
%
%    input file format:
%
%       TYPE 1: 
%       if file contains a single header line, it will be loaded as a dataset
%          (that is, column order is unimportant)
%          column headers must include: 
%             sample1, sample2, sample3, cellT
%                (the three salinometer readings and the salinometer bath temperature)
%             and variable other fields:
%                to specify the station and niskin for a CTD sample, or the time for a TSG sample:
%                   either station_day, cast_hour, niskin_minute
%                   or sampnum
%                   for CTD samples sampnum = station_day*1e2 + niskin_minute;
%                   for TSG samples sampnum = abs(station_day)*1e6 + cast_hour*1e4 + niskin_minute*1e2;
%                   (TSG station_day is yearday (starts at 1 on 1st Jan))
%               to specify/calculate salinometer standard offset,
%                   either offset (with a value for each sample)
%                   or rows must include standards runs, indicated by station_day = 000 or 999
%                      and K15 must be a column or be set in opt_cruise
%                      (2xK15 is the expected salinometer reading for the standard)
%                      in this case, offsets will be computed here and linearly interpolated***
%                      to samples between standards runs
%               optional: flag
%               optional: cellT (otherwise specify in opt_cruise)
%
%       TYPE 2:
%       if there are multiple header lines, it will be parsed as in mtsg_01_dy040
%          in this case it must begin with a line that includes SALINITYDATAFILE
%          and must have a line (or lines) that include column headers
%          sampnum, Sample 1, Sample 2, Sample 3, and (optionally) offset
%          followed by one or more lines of corresponding data
%          the order of the column headers can vary (for instance if you've concatenated
%          a file with sampnum in column 10 with one with sampnum in column 1)
% 
%
%  saves ds_sal to a .mat file specified in opt_cruise

m_common
scriptname = 'msal_standardise_avg';
stn = 0;
minit
mdocshow(scriptname, ['add documentation string for ' scriptname])

%root directory and filenames
root_sal = mgetdir('M_BOT_SAL');
oopt = 'salcsv'; get_cropt; %sal_csv_file
fname_sal = [root_sal '/' sal_csv_file];


%%%%%%%%% first try loading as dataset; check for required fields %%%%%%%%%
try %first try treating as dataset with required fields

   ds_sal = dataset('File', fname_sal, 'Delimiter', ',');

   %test for required fields
   ds_sal_fn = ds_sal.Properties.VarNames;
   if sum(strcmp('SALINITYDATAFILE', ds_sal_fn)) %***perhaps this should be less strict
      me = MException('myfile:notdataset:autosalexcel', '%s is autosal excel file', fname_sal);
      throw(me)
   elseif ~(sum(strcmp('sampnum', ds_sal_fn))+sum(strcmp('station_day', ds_sal_fn)))
      me = MException('MyFile:NotDataset:unknown', 'check %s format, columns, header', fname_sal);
      throw(me)
   end


%%%%%%%%% if not, try loading as autosal excel file, and putting into dataset %%%%%%%%%
catch me

   if strcmp(me.identifier, 'myfile:notdataset:unknown')
      error(me.message)
   else
      disp(me.message) %probably fine to load as an autosal excel file, but display message just for info
   end

   warning('off', 'stats:dataset:subsasgn:DefaultValuesAdded')

   %load as text
   indata = mtextdload(fname_sal, ',');

   %parse to find column header rows and data rows
   nrows = length(indata);
   ltype = zeros(nrows,1); iisn = []; iisn0 = 1;
   for k = 1:nrows
      iisn = find(strncmp('sampnum', indata{k}, 7));
      if ~isempty(iisn)
	     ltype(k) = 1; %column header
	     iisn0 = iisn;
      elseif length(indata{k})>=iisn0 & ~isempty(str2num(indata{k}{iisn0}))
         ltype(k) = 2; %data
      end
   end

   %initalise dataset
   ds_sal = dataset;
   lsal = 0;
   %put into dataset
   iih = [find(ltype==1); nrows];
   for cno = 1:length(iih)-1
      %find the relevant columns for this block
      isn = strncmpi('sampnum', indata{iih(cno)}, 7);
      is1 = strcmpi('sample 1', indata{iih(cno)});
      is2 = strcmpi('sample 2', indata{iih(cno)});
      is3 = strcmpi('sample 3', indata{iih(cno)});
      iso = strcmpi('offset', indata{iih(cno)});
      isd = strcmpi('date', indata{iih(cno)});
      ist = strcmpi('time', indata{iih(cno)});
      isa = strcmpi('average', indata{iih(cno)});
      %find the sample (including standard sample) lines for this block
      iis = find(ltype==2); iis = iis(iis>iih(cno) & iis<iih(cno+1));
      %append sample rows %***possibly this could be done faster with
      %cell2mat? or possibly not
      for sno = 1:length(iis)
         lsal = lsal+1;
         ds_sal.sampnum(lsal,1) = str2num(indata{iis(sno)}{isn});
         ds_sal.sample1(lsal,1) = str2num(indata{iis(sno)}{is1});
         ds_sal.sample2(lsal,1) = str2num(indata{iis(sno)}{is2});
         ds_sal.sample3(lsal,1) = str2num(indata{iis(sno)}{is3});
         ds_sal.average(lsal,1) = str2num(indata{iis(sno)}{isa});
	     if sum(iso)>0
            ds_sal.offset(lsal,1) = str2num(indata{iis(sno)}{iso});
         else
	        ds_sal.offset(lsal,1) = NaN;
         end
	     if sum(isd)>0 & ~isempty(indata{iis(sno)}{isd})
	        ds_sal.runtime(lsal,1) = datenum(([indata{iis(sno)}{isd} ' ' indata{iis(sno)}{ist}]), 'dd/mm/yy HH:MM:SS');
         else
	        ds_sal.runtime(lsal,1) = NaN;
         end
      end
      %cno
   end
   if sum(~isnan(ds_sal.runtime))==0; ds_sal.runtime = []; end
   
end %end try/catch


%%%%%%%% now operate on dataset %%%%%%%%

oopt = 'cellT'; get_cropt
oopt = 'offset'; get_cropt %for backwards compatibility

ds_sal_fn = ds_sal.Properties.VarNames;


% make sure we have sampnum and station_day, cast_hour, niskin_minute fields
if sum(strcmp('station_day',ds_sal_fn))==0
   %CTD
   ds_sal.station_day = floor(ds_sal.sampnum/100);
   ds_sal.cast_hour = zeros(size(ds_sal.sampnum));
   ds_sal.niskin_minute = ds_sal.sampnum-ds_sal.station_day*100;
   %TSG
   ii = find(ds_sal.sampnum<0);
   ds_sal.sampnum(ii) = -ds_sal.sampnum(ii)*1e2; %convert to spreadsheet convention
   ii = find(ds_sal.sampnum>=1e6);
   ds_sal.station_day(ii) = floor(ds_sal.sampnum(ii)/1e6);
   ds_sal.cast_hour(ii) = floor((ds_sal.sampnum(ii)-ds_sal.station_day(ii)*1e6)/1e4);
   ds_sal.niskin_minute(ii) = ds_sal.sampnum(ii)/1e2-ds_sal.station_day(ii)*1e4-ds_sal.cast_hour(ii)*1e2;
elseif sum(strcmp('sampnum',ds_sal_fn))==0
   %CTD
   ds_sal.sampnum = ds_sal.station_day*100 + ds_sal.niskin_minute;
   %TSG
   ii = find(ds_sal.station_day<0); %this won't occur for spreadsheet tsg because they're put into dataset using sampnum
   ds_sal.sampnum(ii) = (-ds_sal.station_day(ii)*1e6 + ds_sal.cast_hour(ii)*1e4 + ds_sal.niskin_minute(ii)*1e2);

end


%calling sample1, sample2, sample3 r1, r2, r3
if sum(strcmp('r1',ds_sal_fn))==0; ds_sal.r1 = ds_sal.sample1; end
if sum(strcmp('r2',ds_sal_fn))==0; ds_sal.r2 = ds_sal.sample2; end
if sum(strcmp('r3',ds_sal_fn))==0; ds_sal.r3 = ds_sal.sample3; end

ds_sal.r1(ds_sal.r1<=-999) = NaN;
ds_sal.r2(ds_sal.r2<=-999) = NaN;
ds_sal.r3(ds_sal.r3<=-999) = NaN;


% if required/set in opt_cruise, get offsets, and plot over sequential standard number
oopt = 'check_sal_runs'; get_cropt
iistd = find(ds_sal.sampnum==0 | (ds_sal.sampnum>=999000 & ds_sal.sampnum<1000000)); iistd = iistd(:);
if sum(strcmp('offset',ds_sal_fn))==0 | calc_offset

   oopt = 'k15'; get_cropt
   offs0 = ds_sal.offset(iistd);
   ds_sal.offset = NaN+zeros(length(ds_sal.K15),1);
   offs = repmat(2*ds_sal.K15(iistd), 1, 3) - [ds_sal.r1(iistd) ds_sal.r2(iistd) ds_sal.r3(iistd)];

   oopt = 'std2use'; get_cropt %if not set to 0, a plot is made and a keyboard prompt appears
   if check_sal_runs
      diffs = offs*1e5; diffm = sum(diffs.*std2use,2)./sum(std2use,2);
      %diff_filt = filter_bak(ones(1,21),diffm);
      x = 1:length(iistd); 
      x3 = repmat(x',1,3);
      clf
      subplot(211)
      plot(x, diffs(:,1), 'o-b', x, diffs(:,2), 's-r', x, diffs(:,3), '<-k', x3(std2use==1), diffs(std2use==1), '.c'); grid %, x, diff_filt, 'm'); grid
      ylabel('2K15 - standards readings (1e-5)')
      %indicate where standard batch changes***
      %***indicate each crate vs between crates
      legend('run1','run2','run3','good values','smoothed average',0)
      disp('if necessary, set std2use in opt_cruise to change which readings to use');
      disp('if standards are suspicious you may also want to set flags in the msal_01 or mtsg_01 case in opt_cruise');
   end

   %best standards offsets
   std2use(isnan(offs)) = 0; offs(isnan(offs)) = 0;
   ds_sal.offset(iistd) = sum(offs.*std2use, 2)./sum(std2use, 2);
   ds_sal.offset(~isfinite(ds_sal.offset)) = NaN;

   ii = find(isnan(ds_sal.offset(iistd)));
   if ~isempty(ii)
      disp('missing standards:')
      sprintf('%d\n', ds_sal.sampnum(ii));
      disp('use opt_cruise to fill these in')
   end
   
   disp('if necessary, fill in missing standards and set interpolation ordinate (in opt_cruise)')
   oopt = 'fillstd'; get_cropt %fill in missing standards and select x-axis for interpolation

   %interpolate best offsets to samples
   iistd = find(ds_sal.sampnum>=999000 & ds_sal.sampnum<1e6);
   iisam = setdiff([1:length(ds_sal.station_day)]', iistd);
   [x0,ii] = sort(xoff(iistd)); iistd = iistd(ii); 
   ds_sal.offset(iisam) = interp1(xoff(iistd), ds_sal.offset(iistd), xoff(iisam));
   iib = find(isnan(ds_sal.cellT(iisam)));
   ds_sal.cellT(iisam(iib)) = interp1(xoff(iistd), ds_sal.cellT(iistd), xoff(iisam(iib)));

   if check_sal_runs
       subplot(212)
       plot(interp1(xoff(iistd), ds_sal.sampnum(iistd), xoff(iisam))-999000, ds_sal.offset(iisam)*1e5, '.'); grid
       ylabel('offset (10^-5)')
       xlabel('standard number')
      disp('return when finished')
      keyboard
   end
   
else %use the existing column of offsets for each sample

   %use offsets from file
   iisam = find(ds_sal.sampnum>0 & ds_sal.sampnum<1e7);
   
end

sams0 = [ds_sal.r1(iisam) ds_sal.r2(iisam) ds_sal.r3(iisam)];
sams = sams0 + repmat(ds_sal.offset(iisam), 1, 3); %plot this, but output the non-adjusted version (along with the offset field)


%plot for tsg and individual stations, pausing to enable setting/editing sam2use and salbotqf
oopt = 'sam2use'; get_cropt %set sample run flags and sample bottle flags

if check_sal_runs

   x = 1:length(iisam); x3 = repmat(x',1,3);
   res = sams - repmat(sum(sams.*sam2use, 2)./sum(sam2use, 2),1,3);
   resg = res; resg(find(sam2use==0)) = NaN;
   xs = ds_sal.sampnum(iisam);
   
   subplot(3,1,1)
   plot(x, res(:,1), 'o', x, res(:,2), 's', x, res(:,3), '<', x3(sam2use==1), res(sam2use==1), '.c'); grid
   xlabel('sample index')
   
   %TSG samples
   ii = find(xs>1e6);
   subplot(3,3,[4 7])
   plot(xs(ii), res(ii,1), 'o', xs(ii), res(ii,2), 's', xs(ii), res(ii,3), '<', xs(ii), resg(ii,:), '.c'); title('tsg'); grid

   disp('if necessary, set sam2use in opt_cruise to change which readings to use');

   %CTD samples
   stnos = unique(ds_sal.station_day(ds_sal.sampnum>0 & ds_sal.sampnum<90000)); %plot for all CTDs
   if plot_all_stations
      for no = 1:length(stnos)
         ii = find(floor(ds_sal.sampnum(iisam)/100)==stnos(no));
         subplot(3,3,[5 6 8 9]);
         plot(xs(ii), res(ii,1), 'o', xs(ii), res(ii,2), 's', xs(ii), res(ii,3), '<', xs(ii), resg(ii,:), '.c'); grid
         title(['ctd ' num2str(stnos(no))]); disp('return to go on to next station'); keyboard
      end
   end
   
end

%rerun in case of changed flags %***will the changes be loaded?***
oopt = 'sam2use'; get_cropt

%average of good readings for each sample
sam2use(isnan(sams0)) = 0; sams0(isnan(sams0)) = 0;
sams0 = sum(sams0.*sam2use, 2)./sum(sam2use, 2);
sams0(~isfinite(sams0)) = NaN;

ds_sal.rval = NaN+zeros(length(ds_sal.r1),1);
if ~sum(strcmp('flag', ds_sal_fn))
   ds_sal.flag = 9+zeros(length(ds_sal.r1),1);
end
ds_sal.rval(iisam) = sams0;
ds_sal.flag(iisam) = salbotqf;

%now save
readme = 'rval is the average of good readings. it has not had the offset applied.';
save([root_sal '/' sal_mat_file], 'ds_sal', 'readme');
