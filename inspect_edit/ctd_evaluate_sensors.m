function ctd_evaluate_sensors(sensname, varargin)
% ctd_evaluate_sensors(sensname)
% ctd_evaluate_sensors(sensname, varargin)
%
%compare CTD temperature, conductivity, or oxygen to calibration values
%in order to choose calibration functions
%
%produces plots comparing them and a suggested calibration function depending on quantity:
%linear station number drift offset for temp
%linear station number drift + linear in pressure scaling for cond (approximately equivalent to an offset for sal)
%linear station number drift + *** for oxy
%
%set sensname to 'temp1' 'cond1' 'cond2' 'oxygen1' 'oxygen' etc.
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

m_common

%defaults and optional input arguments
precalt = 0; precalc = 0; precalo = 0; %don't apply calibrations
calstr = []; %get calibrations from opt_cruise
okf = [2 3]; %include good or questionable samples (useful for checking niskin flags)
pdeep = 1500; %cutoff for "deep" samples
uselegend = 1;
printform = '-dpdf';
plotprof = 1; %for cond or oxy, make profile plots to check how good samples are
if strncmp(sensname, 'temp', 4)
    rlabel = 'SBE35 T - CTD T (degC)';
    rlim = [-10 10]*1e-3;
    vrlim = [-2 32];
elseif strncmp(sensname, 'cond', 4)
    rlabel = 'C_{bot}/C_{ctd} (psu)';
    rlim = [-10 10]*2e-3;
    vlim = [25 60];
elseif strncmp(sensname, 'oxy', 3)
    rlabel = 'O_{bot} - O_{ctd} (umol/kg)';
    rlim = [-5 5];
    vlim = [50 450];
else
    error('sensname not recognised')
end
llim = [rlim(2)/2 rlim(2)/4]; %threshold for shallow and deep points to examine in individual profiles
stn0 = 0; %only plot individual stations after stn0

for no = 1:2:length(varargin)
    eval([varargin{no} ' = varargin{no+1};'])
end


if ~isempty(str2num(sensname(end)))
    sensnum = sensname(end);
else
    sensnum = [];
end


%load data
d = mloadq(fullfile(MEXEC_G.MEXEC_mexec_data_root, 'ctd', ['sam_' mcruise '_all']), '/');

%apply calibrations to data from all stations
if precalt || precalc || precalo
    docal.temp = precalt;
    docal.cond = precalc;
    docal.oxygen = precalo;
    d = apply_cals_multi_statnums(d, docal, calstr);
end

edges = [-1:.05:1]*rlim(2);
presrange = [-max(d.upress(~isnan(d.(sensname)))) 0];
statrange = [0 max(d.statnum(~isnan(d.(sensname))))+1];
printdir = fullfile(MEXEC_G.MEXEC_mexec_data_root, 'plots');

%get sensor groups
scriptname = 'castpars'; oopt = 'ctdsens_groups'; get_cropt
ctdsens_groups.cond1 = ctdsens_groups.temp1;
ctdsens_groups.cond2 = ctdsens_groups.temp2;
sensind = ctdsens_groups.(sensname);
ng = length(sensind);

%loop through data from different sensors
for gno = 1:ng
    
    iig = find(ismember(d0.statnum, sensind{gno}));
    
    %data to compare
    ctddata = d0.(['u' sensname]); ctddata = ctddata(iig);
    if strncmp(sensname, 'temp', 4)
        caldata = d.sbe35temp(:); calflag = d.sbe35flag(iig);
        res = (caldata - ctddata);
        if isfield(d, 'utemp1') && isfield(d, 'utemp2'); ctdres = (d.utemp2(iig)-d.utemp1(iig)); else; ctdres = NaN+ctddata; end
    elseif strncmp(sensname, 'cond', 4)
        caldata = gsw_C_from_SP(d.botpsal(iig),d.(['utemp' sensnum])(iig),d.upress(iig)); calflag = d.botpsal_flag(iig);
        res = (caldata./ctddata - 1)*35;
        if isfield(d, 'ucond1') && isfield(d, 'ucond2'); ctdres = (d.ucond2(iig)./d.ucond1(iig)-1)*35; else; ctdres = NaN+ctddata; end
    elseif strcmp(sensname, 'oxygen')
        caldata = d.botoxya(:); calflag = d.botoxya_flag(iig);
        res = (caldata - ctddata);
        if isfield(d, 'uoxygen1') && isfield(d, 'uoxygen2'); ctdres = (d.uoxygen2(iig)-d.uoxygen1(iig)); else; ctdres = NaN+ctddata; end
    end
    ii = find(ismember(calflag,okf));
    caldata = caldata(ii); calflag = calflag(ii);
    ctddata = ctddata(ii); ctdres = ctdres(ii);
    iig = iig(ii);
    
    %and model calibration
    if strncmp(sensname, 'temp', 4)
        rmod = [ones(length(d.statnum),1) d.statnum(iig)];
        b = rmod\res;
        sprintf('set %d: temp_{cal} = temp_{ctd} + (%4.2f + %4.2fN)x10^{-3}', gno, b(1), b(2))
    elseif strncmp(sensname, 'cond', 4)
        rmod = [ones(length(d.statnum),1) d.statnum(iig) d.upress(iig)];
        b = rmod\res;
        sprintf('set %d: cond_{cal} = cond_{ctd}[1 + (%6.5f + %6.5fN + %6.5fP)/35]', gno, b(1), b(2), b(3))
    elseif strcmp(sensname, 'oxygen')
        rmod = [ones(length(d.statnum),1) d.upress(iig) ctddata d.statnum(iig).*ctddata];
        b = rmod\caldata;
        sprintf('set %d: oxy_{cal} = oxy_{ctd}(%5.3f + %4.2fNx10^{-4}) + %4.2f + %4.2fPx10^{-3}', gno, b(3), b(4)*1e4, b(1), b(2)*1e3)
    end
    
    %larger residuals to examine station by station
    ii = find( (abs(res)>llim(1) & d.upress(iig)<pdeep) | (abs(res)>llim(2) & d.upress(iig)>=pdeep) );
    mres = [d.statnum(iig(ii)); res(ii)];
    
    
    %plots of the residual/ratio
    
    md = m_nanmedian(res); ms = sqrt(m_nansum((res)-md).^2)/(length(iig)-1);
    iid = find(d.upress(iis)>=pdeep));
    mdd = m_nanmedian(res(iid));
    try
        iqrd = iqr(res(iid));
    catch
        c = sort(res(iid));
        ii = [round(length(c)/4) round(length(c)*3/4)];
        iqrd = c(ii(2))-c(ii(1));
    end
    
    figure((no-1)*10+2); clf; orient tall
    subplot(5,5,[1:5])
    plot(d.statnum(iig), ctdres, 'c.', d.statnum(iig), res, '+k', d.statnum(iig(iid)), res(iid), 'xb'); grid
    if uselegend
        legend('ctd diff','ctd-cal diff',['ctd-cal diff, p>' num2str(pdeep)])
    end
    xlabel('statnum'); xlim(statrange); ylim(rlim)
    title([mcruise ' ' rlabel])
    subplot(5,5,[9:10 14:15 19:20 24:25])
    plot(ctdres, -d.upress(iig), 'c.', res, -d.upress(iig), '+k', [0 0], presrange, 'r'); grid
    ylabel('press'); ylim(presrange); xlim(rlim)
    subplot(5,5,[6:8 11:13])
    plot(caldata, ctddata, 'o-k', caldata(iif), ctddata(iif), 'sb', caldata, caldata); grid;
    axis image; xlabel(['cal ' sensname]); ylabel(['ctd ' sensname]);
    subplot(5,5,[16:18 21:23])
    nh = histc(res, edges);
    bar(edges, nh, 'histc')
    title([mcruise ' ' rlabel])
    ax = axis;
    text(edges(end)*.9, ax(4)*.95, ['median ' num2str(round(md*1e5)/1e5)], 'horizontalalignment', 'right')
    text(edges(end)*.9, ax(4)*.90, ['deep median ' num2str(round(mdd*1e5)/1e5)], 'horizontalalignment', 'right')
    text(edges(end)*.9, ax(4)*.85, ['deep 25-75% ' num2str(round(iqrd*1e5)/1e5)], 'horizontalalignment', 'right')
    xlim(edges([1 end])); grid
    print(printform, fullfile(printdir, ['ctd_eval_' sensname '_set' num2str(no)]))
    
    figure((no-1)*10+3); clf; orient portrait
    load cmap_bo2; colormap(cmap_bo2)
    subplot(1,8,1:2); scatter(d.utemp(iig), -d.upress(iig), 16, res, 'filled'); grid; set(gca,'color',[.8 .8 .8])
    xlabel('temp'); xlim([min(d.utemp(iig)) max(d.utemp(iig))])
    ylabel('press'); ylim(presrange); caxis(rlim); colorbar
    subplot(1,8,3:4); scatter(d.statnum(iig), -d.upress(iig), 16, res, 'filled'); grid; set(gca,'color',[.8 .8 .8])
    xlabel('station'); xlim([min(d.statnum(iig)) max(d.statnum(iig))])
    ylabel('press'); ylim(presrange); caxis(rlim); colorbar
    title([mcruise ' ' rlabel])
    subplot(1,8,5:6); scatter(d.utemp(iig), d.uoxygen(iig), 16, res, 'filled'); grid; set(gca,'color',[.8 .8 .8])
    xlabel('temp'); xlim([min(d.utemp(iig)) max(d.utemp(iig))])
    ylabel('oxygen'); ylim([min(d.uoxygen) max(d.uoxygen)]); caxis(rlim); colorbar
    subplot(1,8,7:8); scatter(d.uoxygen(iig), -d.upress(iig), 16, res, 'filled'); grid; set(gca,'color',[.8 .8 .8])
    xlabel('oxygen'); xlim([min(d.uoxygen(iig)) max(d.uoxygen(iig))])
    ylabel('press'); ylim(presrange); caxis(rlim); colorbar
    print(printform, fullfile(printdir, ['ctd_eval_' sensname '_set' num2str(no) '_pt']))
    
    
    %plot individual stations
    if plotprof && ~isempty(mres)
        disp('to examine larger differences profile-by-profile to help pick bad or')
        disp('questionable samples and set their flags in opt_cruise msal_01 or moxy_01,')
        disp('press any key to continue (or ctrl-c to quit)')
        pause
        
        figure(1); clf
        s = unique(mres(1,:)); s = s(s>=stn0);
        for no = 1:length(s)
            stnlocal = s(no);
            stn_string = sprintf('%03d', stnlocal);
            
            %load and calibrate 1 hz and 2 dbar upcast profiles
            [d1, h1] = mloadq(fullfile(MEXEC_G.MEXEC_mexec_data_root, 'ctd', ['ctd_' mcruise '_' stn_string '_psal.nc']), '/');
            iidu1 = find(d1.press==max(d1.press)); iidu1 = iidu1:length(d1.press);
            [du, hu] = mloadq(fullfile(MEXEC_G.MEXEC_mexec_data_root, 'ctd', ['ctd_' mcruise '_' stn_string '_2up.nc']), '/');
            scriptname = 'mctd_02'; oopt = 'ctd_cals'; get_cropt
           
            if precalt || precalc || precalo
                %overwrite docal flags
                castopts.docal.temp = precalt;
                castopts.docal.cond = precalc;
                castopts.docal.oxygen = precalo;
                [dc1, ~] = ctd_apply_calibrations(d1, [], castopts.docal, castopts.calstr);
                [dcu, ~] = ctd_apply_calibrations(du, [], castopts.docal, castopts.calstr);
                if precalt
                        d1.temp1 = dc1.temp1;
                        du.temp1 = dcu.temp1;
                        d1.temp2 = dc1.temp2;
                        du.temp2 = dcu.temp2;
                end
                if precalc
                        d1.cond1 = dc1.cond1;
                        du.cond1 = dcu.cond1;
                        d1.cond2 = dc1.cond2;
                        du.cond2 = dcu.cond2;
                end
                if precalo
                        d1.oxygen1 = dc1.oxygen1;
                        du.oxygen1 = dcu.oxygen1;
                        d1.oxygen1 = dc1.oxygen1;
                        du.oxygen1 = dcu.oxygen1;
                end
            end

            iis = find(d.statnum(:)==s(no));
            iisbf = find(d.statnum(:)==s(no) & ~ismember(calflag, okf));
            iiq = find(d.statnum(:)==s(no) & mres & ismember(calflag, okf));

            plot(d1.(sensname)(iidu1), -d1.press(iidu1), 'c', du.(sensname), -du.press, 'k--', ...
                caldata(iis), -d.upress(iis), 'r.', caldata(iisbf), -d.upress(iisbf), 'm.', ctddata(iis), -d.upress(iis), 'b.', ...
                caldata(iiq), -d.upress(iiq), 'or', ctddata(iiq), -d.upress(iiq), 'sb');
            grid; title(sprintf('cast %d, cyan 1 hz, red good cal data, magenta bad cal data, blue ctd data, symbols large residuals',s(no)));
            mn = m_nanmean(c); st = m_nanstd(c); xl = [-st st]*5+mn; set(gca, 'xlim', xl);
            text(repmat(st*4.5+mn,length(iiq),1), -d.upress(iiq), num2str(d.position(iiq)));
            for qno = 1:length(iiq)
                sprintf('%d %d %5.2f %d %d', s(no), d.position(iiq(qno)), res(iiq(qno)), calflag(iiq(qno)), d.niskin_flag(iiq(qno)))
            end
            keyboard


        end
    end
    
end


function d = apply_cals_multi_statnums(d, docal, calstr);
%loop through station numbers to run ctd_apply_cals

if isempty(calstr)
    cropt_cal = 1;
else
    cropt_cal = 0;
end

stns = unique(d.statnum);
for sno = stns(:)'
    
    stnlocal = stns(sno);
    iig = find(d.statnum==stnlocal);
    
    if cropt_cal
        scriptname = 'mctd_02'; oopt = 'ctd_cals'; get_cropt
    end
    
    d0.statnum = d.statnum(iig);
    d0.position = d.position(iig);
    d0.sampnum = d.sampnum(iig);
    d0.press = d.press(iig);
    d0.temp1 = d.temp1(iig);
    d0.cond1 = d.cond1(iig);
    d0.oxygen1 = d.oxygen1(iig);
    d0.temp2 = d.temp2(iig);
    d0.cond2 = d.cond2(iig);
    if isfield(d, 'oxygen2')
        d0.oxygen2 = d.oxygen2(iig);
    end
    
    [dcal, ~] = ctd_apply_calibrations(d0, [], docal, calstr);
    if precalt
        d.temp1(iig) = dcal.temp1;
        d.temp2(iig) = dcal.temp2;
    end
    if precalc
        d.cond1(iig) = dcal.cond1;
        d.cond2(iig) = dcal.cond2;
    end
    if precalo
        d.oxygen1(iig) = dcal.oxygen1;
        if isfield(dcal,'oxygen2')
            d.oxygen2(iig) = dcal.oxygen2;
        end
    end
    
end
