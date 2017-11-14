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
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
oopt = '';

okf = [2]; %only bother with good samples
okf = [2 3]; %include good or questionable samples

printdir = ['/local/users/pstar/cruise/data/plots/'];
prstr = '';
if ~exist('plotprof','var'); plotprof = 1; end %for cond or oxy, make profile plots to check how good samples are

d = mload(['/local/users/pstar/cruise/data/ctd/sam_' cruise '_all'], '/');
statrange = [0 max(d.statnum)+1];
presrange = [-5000 0];
edges = -10:.2:10;


if length(sensnum)>0; sensstr = num2str(sensnum); else; sensstr = ''; sensnum = 1; end


% apply calibration values first? (to test a calibration, or to use calibrated temperature or salinity in
% subsequent conversions, even if the calibrations haven't yet been applied to files)

if exist('precalt','var') & precalt
   fnm = ['utemp' sensstr];
   d = setfield(d, fnm, temp_apply_cal(sensnum, d.statnum, d.upress, d.time, getfield(d, fnm)));
end

if exist('precalc','var') & precalc
   if ~precalt; warning('you may want to calibrate temperature before calibrating conductivity'); end
   fnmt = ['utemp' sensstr];
   fnm = ['ucond' sensstr];
   d = setfield(d, fnm, cond_apply_cal(sensnum, d.statnum, d.upress, d.time, getfield(d, fnmt), getfield(d, fnm)));
end

if exist('precalo','var') & precalo
   if ~precalt | ~precalc; warning('you may want to calibrate temperature and conductivity before calibrating oxygen'); end
   fnm = ['uoyxgen' sensstr];
   d = setfield(d, fnm, oxy_apply_cal(sensnum, d.statnum, d.upress, d.time, d.utemp, getfield(d, fnm)));
end


%get data to compare, and sets of indices corresponding to different sensors
if strcmp(sensname, 'temp')
   fnm = ['utemp' sensstr]; ctddata = getfield(d, fnm);
   caldata = d.sbe35temp; calflag = d.sbe35flag;
   oopt = 'tsensind'; get_cropt ;
   res = caldata - ctddata;
   rlabel = 'SBE35 T - CTD T (degC)'; rlim = [-10 10]*1e-3;

elseif strcmp(sensname, 'cond')
   fnm = ['ucond' sensstr]; ctddata = getfield(d, fnm);
   caldata = [gsw_C_from_SP(d.botpsal,d.utemp1,d.upress) gsw_C_from_SP(d.botpsal,d.utemp2,d.upress)]; calflag = d.botpsalflag;
   oopt = 'csensind'; get_cropt; keyboard
   res = (caldata(:,sensnum)./ctddata - 1)*35;
   rlabel = 'C_{bot}/C_{ctd} (psu)'; rlim = [-10 10]*1e-3;

elseif strcmp(sensname, 'oxy')
   fnm = ['uoxygen' sensstr]; ctddata = getfield(d, fnm);
   caldata = d.botoxy; calflag = d.botoxyflag;
   oopt = 'osensind'; get_cropt
   res = (caldata - ctddata);
   rlabel = 'O_{bot} - O_{ctd} (umol/kg)'; rlim = [-10 10]*4;

else
   error('must set sensname to one of ''temp'', ''cond'', or ''oxy''')
end

%only compare points with certain flags
iig = find(ismember(calflag, okf));
n = size(sensind,1);
for no = 1:n
      sensind{no} = intersect(sensind{no},iig);
end

%model calibration
if strcmp(sensname, 'temp')
   rmod = [ones(length(d.statnum),1) d.statnum];
   for no = 1:n
      b = regress(res(sensind{no})*1e3, rmod(sensind{no},:));
      disp(['set' num2str(no) ': temp_{cal} = temp_{ctd} + (' num2str(round(b(1)*10)/10) ' + ' num2str(round(b(2)*10)/10) 'statnum)x10^{-3}'])
   end
   
elseif strcmp(sensname, 'cond')
   rmod = [ones(length(d.statnum),1) d.statnum d.upress];
   for no = 1:n
      b = regress((res(sensind{no})-1)/35*1e3, rmod(sensind{no},:));
      disp(['set' num2str(no) ': cond_{cal} = cond_{ctd}[1 + (' num2str(round(b(1)*10)/10) ' + ' num2str(round(b(2)*10)/10) 'statnum ' + num2str(round(b(3)*1e3)/1e3) 'press)35x10^{-3}]'])
   end
   
elseif strcmp(sensname, 'oxy')
   rmod = [ones(length(d.statnum),1) d.upress ctddata d.statnum.*ctddata];
   for no = 1:n
      b = regress(caldata(sensind{no}), rmod(sensind{no},:));
      disp(['set' num2str(no) ': oxy_{cal} = ' num2str(round(b(3)*10)/10) ' + ' num2str(round(b(4)*10)/10) 'statnum)oxy_{ctd} + (' num2str(round(b(1)*10)/10) ' + ' num2str(round(b(2)*1e2)/1e2) ')press'])
   end

end


%plots of the residual/ratio
for no = 1:n

   figure((no-1)*10+2); clf
   nh = histc(res(sensind{no}), edges);
   bar(edges, nh, 'histc')
   title([cruise ' ' rlabel])
   md = nanmedian(res(sensind{no})); ms = sqrt(nansum((res(sensind{no}))-md).^2)/(length(sensind{no})-1);
   iid = intersect(sensind{no}, find(d.upress>100)); mn = nanmean(res(iid)); st = nanstd(res(iid));
   ax = axis;
   text(edges(end)*.9, ax(4)*.95, ['median ' num2str(round(md*100)/100)], 'horizontalalignment', 'right')
   text(edges(end)*.9, ax(4)*.90, ['sqrt(''L2'') ' num2str(round(ms*100)/100)], 'horizontalalignment', 'right')
   text(edges(end)*.9, ax(4)*.85, ['mean ' num2str(round(mn*100)/100)], 'horizontalalignment', 'right')
   text(edges(end)*.9, ax(4)*.80, ['\sigma ' num2str(round(st*100)/100)], 'horizontalalignment', 'right')
   print('-dpdf', ['ctd_eval_' sensname sensstr '_set' num2str(no) '_hist'])

   figure((no-1)*10+3); clf
   subplot(3,3,1:2)
   plot(d.statnum(sensind{no}), res(sensind{no}), '+k'); grid
   xlabel('statnum'); xlim(statrange); ylim(rlim)
   title([cruise ' ' rlabel])
   subplot(3,3,[3 6 9])
   plot(res(sensind{no}), d.upress(sensind{no}), '+k'); grid
   ylabel('press'); ylim(presrange); xlim(rlim)
   subplot(3,3,[4 5 7 8])
   plot(caldata, ctddata); axis image; xlabel(['cal ' sensname]); ylabel(['ctd ' sensname])
   print('-dpdf', ['ctd_eval_' sensname sensstr '_set' num2str(no)])

   if strcmp(sensname, 'oxy')
      figure((no-1)*10+4); clf
      %scatter(d.statnum(sensind{no}), d.upress(sensind{no}), 10, res); grid
      %xlabel('statnum'); xlim(statrange);
      scatter(d.utemp(sensind{no}), d.upress(sensind{no}), 10, res); grid
      xlabel('temp'); xlim([min(d.utemp) max(d.utemp)])
      ylabel('press'); ylim(presrange); caxis(rlim); colorbar
      title([cruise ' ' rlabel])
      print('-dpdf', ['ctd_eval' sensname sensstr '_set' num2str(no) '_pt'])
   end

end


%profile plots to display off-scale differences profile-by-profile 
%(to help pick bad or questionable samples and set their flags in opt_cruise msal_01 or moxy_01)
if sum(strcmp(sensname, {'cond';'oxy'})) & plotprof

   %for any of the presently ok flagged samples, over all sets
   ii = intersect(iig, find(abs(res)>rlim(2)));
   if length(ii)>0
      disp([sensname sensstr ' difference out of range (station, bottle, press):']);  
      disp([d.statnum(ii) d.position(ii) round(d.upress(ii)) res(ii)])
      pause

      if strcmp(sensname, 'cond')
         fnm1 = ['psal' sensstr];
      elseif strcmp(sensname, 'oxy')
         fnm1 = ['oxygen' sensstr];
      end

      figure(1); clf
      s = unique(d.statnum(ii));
      xl = [33 35];
      for no = 1:length(s);
         stnstr = ['00' num2str(s(no))]; stnstr = stnstr(end-2:end);

         [d1, h1] = mload(['ctd/ctd_' cruise '_' stnstr '_psal.nc'], '/');
         iid = find(d1.press==max(d1.press)); iid = iid:length(d1.press);
         [du, hu] = mload(['ctd/ctd_' cruise '_' stnstr '_2up.nc'], '/');

         iiq = find(d.statnum==s(no) & abs(res)>rlim(2));

         disp([stnstr ' ' num2str(d.position(iiq))])
         plot(getfield(d, fnm1), -d1.press, 'c', getfield(du, fnm1), -du.press, 'k--', caldata(iiq), -d.upress(iiq), 'ob', ctddata(iiq), -d.upress(iiq), 'sr'); grid; title(s(no))
	 ax = get(gca, 'axis');
         text(repmat(ax(2)+.2,length(iiq),1), -d.upress(iiq), num2str(d.position(iiq)));
         keyboard

      end
   end
end
