%script to compare CTD temperature, conductivity, or oxygen to calibration values
%in order to choose calibration functions
%
%produces plots comparing them and a suggested calibration function depending on quantity:
%linear station number drift offset for temp
%linear station number drift + linear in pressure scaling for cond (approximately equivalent to an offset for sal)
%linear station number drift + *** for oxy
%
%must set sensname to one of {'temp', 'cond', 'oxy'} to select which quantity to compare
%
%and set sensnum to 1, 2, or [] to indicate which sensor to use (i.e. temp1, temp2, oxygen1, oxygen)
%
%can also set precalt, precalc, or precalo to apply calibrations using temp_apply_cal, cond_apply_cal, oxy_apply_cal
%for testing
%for instance if sensname = 'temp' and you set precalt=1, it would test a calibration coded into the
%temp_apply_cal case in opt_cruise
%if sensname = 'cond' and you set precalt=1, it would apply the temperature calibration coded into the temp_apply_cal case
%in opt_cruise to temperature first before converting from bottle salinity to conductivity (so, this is a good idea)
%
%this on-the-fly calibrating, because it is applied to conductivity not salinity at this stage, and because
%oxygen sensors are not associated with a single temp/cond sensor pair, won't be used to reconvert bottle
%oxygen from umol/l to umol/kg. so for oxygen the best procedure is to apply temperature and conductivity
%calibrations to the files first, then determine the oxygen calibration
%
%for oxygen, it's better to apply the t & c cals to the files first, because then you also select the best sensor
%to use. however the difference these density calibrations make to the oxygen residual is probably relatively small.  
%
%loads sam_cruise_all
%
%there are some selection and plotting options near the top, otherwise they are set in opt_cruise
%
%could add options for fluor as well but i don't know what its cal function should depend on

scriptname = 'ctd_evaluate_sensors';
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
oopt = '';

okf = [2 2.3]; %only bother with good samples
%okf = [2 3]; %include good or questionable samples (useful for checking flags due to niskins)

printdir = [MEXEC_G.MEXEC_DATA_ROOT '/plots/'];
prstr = '';
if ~exist('plotprof','var'); plotprof = 1; end %for cond or oxy, make profile plots to check how good samples are

d = mload([MEXEC_G.MEXEC_DATA_ROOT '/ctd/sam_' mcruise '_all'], '/');
presrange = [-max(d.upress(~isnan(d.utemp))) 0];
pdeep = 1500;

if length(sensnum)>0; sensstr = num2str(sensnum); else; sensstr = ''; sensnum = 1; end


% apply calibration values first? (to test a calibration, or to use calibrated temperature or salinity in
% subsequent conversions, even if the calibrations haven't yet been applied to files)

if exist('precalt','var') & precalt
   fnm = ['utemp' sensstr]; 
   d = setfield(d, fnm, temp_apply_cal(sensnum, d.statnum, d.upress, d.time, getfield(d, fnm)));
else
   precalt = 0;
end

if exist('precalc','var') & precalc
   if ~precalt; warning('you may want to calibrate temperature before calibrating conductivity'); end
   fnmt = ['utemp' sensstr];
   fnm = ['ucond' sensstr];
   d = setfield(d, fnm, cond_apply_cal(sensnum, d.statnum, d.upress, d.time, getfield(d, fnmt), getfield(d, fnm)));
else
   precalc = 0;
   fnm = ['ucond' sensstr];
end

if exist('precalo','var') & precalo
   if ~exist('precalt') | ~exist('precalc') | ~precalt | ~precalc; warning('you may want to calibrate temperature and conductivity before calibrating oxygen'); end
   fnm = ['uoxygen' sensstr];
   d = setfield(d, fnm, oxy_apply_cal(sensnum, d.statnum, d.upress, d.time, d.utemp, getfield(d, fnm)));
else
   precalo = 0;
end

%get data to compare, and sets of indices corresponding to different sensors
if strcmp(sensname, 'temp')
   fnm = ['utemp' sensstr]; ctddata = getfield(d, fnm); ctddata = ctddata(:);
   caldata = d.sbe35temp(:); calflag = d.sbe35flag(:);
   oopt = 'tsensind'; get_cropt ;
   res = (caldata - ctddata);
   if isfield(d, 'utemp1') & isfield(d, 'utemp2'); ctdres = (d.utemp2-d.utemp1); else; ctdres = NaN+ctddata; end
   rlabel = 'SBE35 T - CTD T (degC)'; rlim = [-10 10]*1e-3;
   vlim = [-2 32];
   
elseif strcmp(sensname, 'cond')
   fnm = ['ucond' sensstr]; ctddata = getfield(d, fnm); ctddata = ctddata(:);
   caldata = [gsw_C_from_SP(d.botpsal(:),d.utemp1(:),d.upress(:)) gsw_C_from_SP(d.botpsal(:),d.utemp2(:),d.upress(:))]; calflag = d.botpsalflag(:);
   caldata = caldata(:,sensnum);
   oopt = 'csensind'; get_cropt;
   res = (caldata./ctddata - 1)*35;
   if isfield(d, 'ucond1') & isfield(d, 'ucond2'); ctdres = (d.ucond2(:)./d.ucond1(:)-1)*35; else; ctdres = NaN+ctddata; end
   rlabel = 'C_{bot}/C_{ctd} (psu)'; rlim = [-10 10]*2e-3;
   vlim = [25 60];
   
elseif strcmp(sensname, 'oxy')
   fnm = ['uoxygen' sensstr]; ctddata = getfield(d, fnm); ctddata = ctddata(:);
   caldata = d.botoxy(:); calflag = d.botoxyflag(:);
   oopt = 'osensind'; get_cropt
   res = (caldata - ctddata);
   if isfield(d, 'uoxygen1') & isfield(d, 'uoxygen2'); ctdres = (d.uoxygen2(:)-d.uoxygen1(:)); else; ctdres = NaN+ctddata; end
   rlabel = 'O_{bot} - O_{ctd} (umol/kg)'; rlim = [-10 10];
   vlim = [50 450];
   
else
   error('must set sensname to one of ''temp'', ''cond'', or ''oxy''')
end
edges = [-1:.05:1]*rlim(2);
statrange = [0 max(d.statnum(~isnan(caldata)))+1];

%only compare points with certain flags
iig = find(ismember(calflag, okf));
n = size(sensind,1);
for no = 1:n
   sensind{no} = intersect(sensind{no},iig);
end

%model calibration
if strcmp(sensname, 'temp')
   rmod = [ones(length(d.statnum),1) d.statnum(:)];
   for no = 1:n
      b = regress(res(sensind{no})*1e3, rmod(sensind{no},:));
      sprintf('set %d: temp_{cal} = temp_{ctd} + (%4.2f + %4.2fN)x10^{-3}', no, b(1), b(2))
   end
   
elseif strcmp(sensname, 'cond')
   rmod = [ones(length(d.statnum),1) d.statnum(:) d.upress(:)];
   for no = 1:n
      b = regress(res(sensind{no}), rmod(sensind{no},:));
      sprintf('set %d: cond_{cal} = cond_{ctd}[1 + (%6.5f + %6.5fN + %6.5fP)/35]', no, b(1), b(2), b(3))
   end
   
elseif strcmp(sensname, 'oxy')
   rmod = [ones(length(d.statnum),1) d.upress(:) ctddata d.statnum(:).*ctddata];
   for no = 1:n
      b = regress(caldata(sensind{no}), rmod(sensind{no},:));
      sprintf('set %d: oxy_{cal} = oxy_{ctd}(%5.3f + %4.2fNx10^{-4}) + %4.2f + %4.2fPx10^{-3}', no, b(3), b(4)*1e4, b(1), b(2)*1e3)
   end

end


%plots of the residual/ratio
for no = 1:n

   md = nanmedian(res(sensind{no})); ms = sqrt(nansum((res(sensind{no}))-md).^2)/(length(sensind{no})-1);
   iid = intersect(sensind{no}, find(d.upress>=pdeep)); mdd = nanmedian(res(iid)); iqrd = iqr(res(iid));
   figure((no-1)*10+2); clf
   subplot(5,5,[1:5])
   plot(d.statnum, ctdres, 'c.', d.statnum(sensind{no}), res(sensind{no}), '+k', d.statnum(iid), res(iid), 'xb'); grid
   legend('ctd diff','ctd-cal diff',['ctd-cal diff, p>' num2str(pdeep)])
   xlabel('statnum'); xlim(statrange); ylim(rlim)
   title([mcruise ' ' rlabel])
   subplot(5,5,[9:10 14:15 19:20 24:25])
   plot(ctdres, -d.upress, 'c.', res(sensind{no}), -d.upress(sensind{no}), '+k', [0 0], presrange, 'r'); grid
   ylabel('press'); ylim(presrange); xlim(rlim)
   subplot(5,5,[6:8 11:13])
   plot(caldata, ctddata, 'o-k', caldata(iig), ctddata(iig), 'sb', caldata, caldata); axis image; xlabel(['cal ' sensname]); ylabel(['ctd ' sensname]); %axis(repmat([min([caldata ctddata]) max([caldata ctddata])],1,2))
   subplot(5,5,[16:18 21:23])
   nh = histc(res(sensind{no}), edges);
   bar(edges, nh, 'histc')
   title([mcruise ' ' rlabel])
   ax = axis;
   text(edges(end)*.9, ax(4)*.95, ['median ' num2str(round(md*1e5)/1e5)], 'horizontalalignment', 'right')
   text(edges(end)*.9, ax(4)*.90, ['deep median ' num2str(round(mdd*1e5)/1e5)], 'horizontalalignment', 'right')
   text(edges(end)*.9, ax(4)*.85, ['deep 25-75% ' num2str(round(iqrd*1e5)/1e5)], 'horizontalalignment', 'right')
   xlim(edges([1 end])); grid
   orient tall; print('-dpdf', [printdir 'ctd_eval_' sensname sensstr '_set' num2str(no)])

   figure((no-1)*10+3); clf; orient portrait
   load cmap_bo2; colormap(cmap_bo2)
   subplot(1,8,1:2); scatter(d.utemp(sensind{no}), -d.upress(sensind{no}), 16, res(sensind{no}), 'filled'); grid; set(gca,'color',[.8 .8 .8])
   xlabel('temp'); xlim([min(d.utemp(sensind{no})) max(d.utemp(sensind{no}))])
   ylabel('press'); ylim(presrange); caxis(rlim); colorbar
   subplot(1,8,3:4); scatter(d.statnum(sensind{no}), -d.upress(sensind{no}), 16, res(sensind{no}), 'filled'); grid; set(gca,'color',[.8 .8 .8])
   xlabel('station'); xlim([min(d.statnum(sensind{no})) max(d.statnum(sensind{no}))])
   ylabel('press'); ylim(presrange); caxis(rlim); colorbar
   title([mcruise ' ' rlabel])
   subplot(1,8,5:6); scatter(d.utemp(sensind{no}), d.uoxygen(sensind{no}), 16, res(sensind{no}), 'filled'); grid; set(gca,'color',[.8 .8 .8])
   xlabel('temp'); xlim([min(d.utemp(sensind{no})) max(d.utemp(sensind{no}))])
   ylabel('oxygen'); ylim([min(d.uoxygen) max(d.uoxygen)]); caxis(rlim); colorbar
   subplot(1,8,7:8); scatter(d.uoxygen(sensind{no}), -d.upress(sensind{no}), 16, res(sensind{no}), 'filled'); grid; set(gca,'color',[.8 .8 .8])
   xlabel('oxygen'); xlim([min(d.uoxygen(sensind{no})) max(d.uoxygen(sensind{no}))])
   ylabel('press'); ylim(presrange); caxis(rlim); colorbar
   print('-dpdf', [printdir 'ctd_eval_' sensname sensstr '_set' num2str(no) '_pt'])

end

if sum(strcmp(sensname, {'temp';'cond';'oxy'})) & plotprof
%profile plots to display off-scale differences profile-by-profile 
%(to help pick bad or questionable samples and set their flags in opt_cruise msal_01 or moxy_01)

   %for any of the presently ok flagged samples, over all sets
   mres = abs(res)>rlim(2)/2; mres(d.upress>=pdeep) = abs(res(d.upress>=pdeep))>rlim(2)/4;
   ii = find(mres & ismember(calflag, okf));
   if length(ii)>0
      disp([sensname sensstr ' difference out of range (station, bottle, press, res):']);  
      a = d.statnum(ii); b = d.position(ii); c = d.upress(ii);
      disp(round([a(:) b(:) c(:) res(ii)]))
      disp('dbcont to plot profile-by-profile')
      keyboard

      if strcmp(sensname, 'cond')
         fnm1 = ['cond' sensstr];
      elseif strcmp(sensname, 'oxy')
         fnm1 = ['oxygen' sensstr];
      elseif strcmp(sensname, 'temp')
          fnm1 = ['temp' sensstr];
      end

      figure(1); clf
      s = unique(d.statnum(ii)); if ~exist('stn0', 'var'); stn0 = 0; end; s = s(s>=stn0);
      for no = 1:length(s);
         stn_string = sprintf('%03d', s(no));

         [d1, h1] = mload([MEXEC_G.MEXEC_DATA_ROOT '/ctd/ctd_' mcruise '_' stn_string '_psal.nc'], '/');
         iidu1 = find(d1.press==max(d1.press)); iidu1 = iidu1:length(d1.press);
         [du, hu] = mload([MEXEC_G.MEXEC_DATA_ROOT '/ctd/ctd_' mcruise '_' stn_string '_2up.nc'], '/');

         iiq = find(d.statnum(:)==s(no) & mres & ismember(calflag, okf));
         iis = find(d.statnum(:)==s(no)); iisbf = find(d.statnum(:)==s(no) & ~ismember(calflag, okf));
         
         b = getfield(d1, fnm1); c = getfield(du, fnm1);
         if strcmp(sensname, 'cond')
	    if precalc
	       b = cond_apply_cal(sensnum, s(no), d1.press, d1.time, d1.temp, b);
	       c = cond_apply_cal(sensnum, s(no), du.press, du.time, du.temp, c);
	    end
	 elseif strcmp(sensname, 'temp') & precalt
	    b = temp_apply_cal(sensnum, s(no), d1.press, d1.time, b);
	    c = temp_apply_cal(sensnum, s(no), du.press, du.time, c);
	 elseif strcmp(sensname, 'oxy') & precalo
	    b = oxy_apply_cal(sensnum, s(no), d1.press, d1.time, d1.temp, b);
	    c = oxy_apply_cal(sensnum, s(no), du.press, du.time, du.temp, c);
	 end
         plot(b(iidu1), -d1.press(iidu1), 'c', c, -du.press, 'k--', ...
	 caldata(iis), -d.upress(iis), 'r.', ...
     caldata(iisbf), -d.upress(iisbf), 'm.', ctddata(iis), -d.upress(iis), 'b.', ...
	 caldata(iiq), -d.upress(iiq), 'or', ctddata(iiq), -d.upress(iiq), 'sb');
	 grid; title(sprintf('cast %d, cyan 1 hz, red good cal data, magenta bad cal data, blue ctd data, symbols large residuals',s(no)));
	 mn = nanmean(c); st = nanstd(c); xl = [-st st]*5+mn; set(gca, 'xlim', xl);
         text(repmat(st*4.5+mn,length(iiq),1), -d.upress(iiq), num2str(d.position(iiq)));
	 for qno = 1:length(iiq)
            sprintf('%d %d %5.2f %d %d', s(no), d.position(iiq(qno)), res(iiq(qno)), calflag(iiq(qno)), d.bottle_qc_flag(iiq(qno)))
	 end
         keyboard

      end
   end
end
