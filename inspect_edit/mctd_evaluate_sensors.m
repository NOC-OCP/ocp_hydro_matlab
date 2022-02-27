function mctd_evaluate_sensors(sensname, varargin)
% mctd_evaluate_sensors(sensname)
% mctd_evaluate_sensors(sensname, testcal, varargin)
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
% can also set testcal, structure whose fieldnames are variables (temp,
% cond, etc.) and values are 1 to apply calibrations or 0 (or missing) to
% not (default: empty; no action)
% and, if testcal is set, calstr0, otherwise it defaults to getting calstr
% from opt_cruise
%
% for instance if sensname = 'temp' and docal.temp = 1, it would test
% calibrations coded into the mctd_02 case in opt_cruise (for both temp1
% and temp2)
% if sensname = 'cond' and docal.temp=1 and docal.cond=1, it would apply
% the temperature calibration coded into the mctd_02, cal_ctd case in
% opt_cruise to temperature first before converting from bottle salinity to
% conductivity (generally this is a good idea)
%
% this test calibrating, because it is applied to conductivity not salinity
% at this stage, and because oxygen sensors are not associated with a
% single temp/cond sensor pair, won't be used to reconvert bottle oxygen
% from umol/l to umol/kg. so for oxygen the best procedure is to apply
% temperature and conductivity calibrations to the files first, then
% determine the oxygen calibration, but it also doesn't make as much
% difference to the oxygen residuals (not as much as temperature would for
% conductivity)
%
%loads sam_cruise_all
%
%there are some selection and plotting options near the top, otherwise they are set in opt_cruise
%

%***add fluor

m_common

%defaults and optional input arguments
testcal.temp = 0; testcal.cond = 0; testcal.oxygen = 0; testcal.fluor = 0;
usedn = 0; %use upcast not downcast ctd data
calstr0 = []; %get calibration from opt_cruise -- but may depend on station number
okf = [2 3]; %include good or questionable samples (useful for checking niskin flags)
pdeep = 1500; %cutoff for "deep" samples
uselegend = 1;
printform = '-dpdf';
plotprof = 1; %for cond or oxy, make profile plots to check how good samples are
printdir = fullfile(MEXEC_G.mexec_data_root, 'plots');
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

if ~isempty(str2double(sensname(end)))
    sensnum = sensname(end);
else
    sensnum = [];
end

dirstr = '';
if usedn; dirstr = '_dn'; end

rootdir = mgetdir('ctd');
%load data
[d, h] = mloadq(fullfile(rootdir, ['sam_' mcruise '_all']), '/');
%and turn utemp etc into temp etc. so apply_calibrations will work
uflds = {'press' 'temp1' 'temp2' 'psal1' 'psal2' 'cond1' 'cond2'};
scriptname = 'castpars'; oopt = 'oxyvars'; get_cropt
for no = 1:size(oxyvars,1)
    uflds = [uflds oxyvars(no,2)];
end
for no = 1:length(uflds)
    if ~usedn
        d.(uflds{no}) = d.(['u' uflds{no}]);
    else
        d.(uflds{no}) = d.(['d' uflds{no}]);
    end
end
uflds = [uflds 'statnum' 'position' 'niskin_flag'];

%apply calibrations (may vary by station)
if sum(cell2mat(struct2cell(testcal)))
    %set up
    if isempty(calstr0); cropt_cal = 1; else; cropt_cal = 0; end
    
    %loop through stations, since they might have different cal functions
    stns = unique(d.statnum);
    for sno = stns(:)'
        stnlocal = stns(sno);
        %get only the calibration functions we want to test here
        if cropt_cal %didn't specify as input, get from opt_cruise
            scriptname = 'mctd_02'; oopt = 'ctd_cal'; get_cropt
            calstr0 = castopts.calstr;
        end
        calstr = select_calibrations(testcal, calstr0);
        %and apply them
        clear d0
        iig = find(d.statnum==stnlocal);
        for vno = 1:length(uflds)
            d0.(uflds{vno}) = d.(uflds{vno})(iig);
        end
        [dcal, hcal] = apply_calibrations(d0, h, calstr);
        %put calibrated data from this station only back into d
        for vno = 1:length(hcal.fldnam)
            d.(hcal.fldnam{vno})(iig) = dcal.(hcal.fldnam{vno});
        end
    end
    
end

edges = [-1:.05:1]*rlim(2);
presrange = [-max(d.press(~isnan(d.(sensname)))) 0];
statrange = [0 max(d.statnum(~isnan(d.(sensname))))+1];

%get sensor groups
scriptname = 'castpars'; oopt = 'ctdsens_groups'; get_cropt
ctdsens.cond1 = ctdsens.temp1;
ctdsens.cond2 = ctdsens.temp2;
sensind = ctdsens.(sensname);
sensg = unique(sensind(2,:));

%loop through data from different sensor S/Ns
for gno = 1:length(sensg)
    iig = find(ismember(d.statnum, sensind(1,sensind(2,:)==sensg(gno))));
    
    %data to compare
    ctddata = d.(sensname)(iig);
    if strncmp(sensname, 'temp', 4)
        caldata = d.sbe35temp(iig); 
        calflag = d.sbe35flag(iig);
        ii = find(ismember(calflag,okf));
        caldata = caldata(ii); calflag = calflag(ii); ctddata = ctddata(ii);
        iig = iig(ii);
        res = (caldata - ctddata);
        if isfield(d, 'temp1') && isfield(d, 'temp2')
            ctdres = (d.temp2(iig)-d.temp1(iig)); 
            clabel = 'ctd temp2 - temp1';
        else
            ctdres = NaN+ctddata; 
            clabel = '';
        end
    elseif strncmp(sensname, 'cond', 4)
        caldata = gsw_C_from_SP(d.botpsal(iig),d.(['temp' sensnum])(iig),d.press(iig)); 
        calflag = d.botpsal_flag(iig);
        ii = find(ismember(calflag,okf));
        caldata = caldata(ii); calflag = calflag(ii); ctddata = ctddata(ii);
        iig = iig(ii);
        res = (caldata./ctddata - 1)*35;
        if isfield(d, 'cond1') && isfield(d, 'cond2')
            ctdres = (d.cond2(iig)./d.cond1(iig)-1)*35; 
            clabel = 'ctd cond2/cond1';
        else
            ctdres = NaN+ctddata; 
            clabel = '';
        end
    elseif strncmp(sensname, 'oxygen', 6)
        caldata = d.botoxy(:); 
        calflag = d.botoxy_flag(iig);
        ii = find(ismember(calflag,okf));
        caldata = caldata(ii); calflag = calflag(ii); ctddata = ctddata(ii);
        iig = iig(ii);
        res = (caldata - ctddata);
        if isfield(d, 'oxygen1') && isfield(d, 'oxygen2')
            ctdres = (d.oxygen2(iig)-d.oxygen1(iig)); 
            clabel = 'ctd oxygen2 - oxygen1';
        else
            ctdres = NaN+ctddata; 
            clabel = '';
        end
    end
    
    %get other quantities we might use
    stn = d.statnum(iig); 
    nisk = d.position(iig); niskf = d.niskin_flag(iig);
    press = d.upress(iig); ctemp = d.utemp(iig);

    %fit model
    if strncmp(sensname,'temp',4)
        model = [ones(size(caldata)) d.press d.statnum];
        modform = 'tempcal = temp + C1 + C2(press) + C3(stn)';
        C = regress(res,model);
    elseif strncmp(sensname,'cond',4)
        model = [ctddata ctddata.*press ctddata.*stn];
        modform = 'condcal = cond*(C1 + C2(press) + C3(stn))';
        C = regress(caldata,model);
    elseif strncmp(sensname,'oxygen',6)
        model = [ones(size(ctddata)) press press.^2 ctddata ctddata.*press ctddata.*press.^2];
        modform = 'oxycal = C1 + C2(press) + C3(press^2) + (C4 + C5(press) + C6(press^2))(oxy)';
        C = regress(caldata,model);
    end
    disp(modform); format long; disp(C); format

    %stats
    md = m_nanmedian(res); ms = sqrt(m_nansum((res)-md).^2)/(length(iig)-1);
    deep = d.upress(iig)>=pdeep;
    mdd = m_nanmedian(res(deep));
    try
        iqrd = iqr(res(deep));
    catch
        c = sort(res(deep));
        ii = [round(length(c)/4) round(length(c)*3/4)];
        iqrd = c(ii(2))-c(ii(1));
    end
    
    %plot residual or ratio vs statnum, pressure, and histogram
    figure((gno-1)*10+2); clf; orient tall
    subplot(5,5,[1:5])
    plot(stn, ctdres, 'c.', stn, res, '+k', stn(deep), res(deep), 'xb'); grid
    if uselegend
        legend(clabel,'ctd-cal diff',['ctd-cal diff, p>' num2str(pdeep)])
    end
    xlabel('statnum'); xlim(statrange); ylim(rlim); ylabel(rlabel)
    title([mcruise])
    subplot(5,5,[9:10 14:15 19:20 24:25])
    plot(ctdres, -press, 'c.', res, -press, '+k', [0 0], presrange, 'r'); grid
    ylabel('press'); ylim(presrange); xlim(rlim); xlabel(rlabel)
    subplot(5,5,[6:8 11:13])
    plot(caldata, ctddata, 'o-k', caldata(deep), ctddata(deep), 'sb', caldata, caldata); grid;
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
    if ~isempty(printform)
        print(printform, fullfile(printdir, ['ctd_eval_' sensname '_set' num2str(no)]))
    end
    
    %plot residual or ratio in color vs 2 of statnum, press, temp, oxygen
    figure((gno-1)*10+3); clf; orient portrait
    load cmap_bo2; colormap(cmap_bo2)
    subplot(1,8,1:2); scatter(ctemp, -press, 16, res, 'filled'); grid; set(gca,'color',[.8 .8 .8])
    xlabel('temp'); xlim([min(ctemp) max(ctemp)])
    ylabel('press'); ylim(presrange); caxis(rlim); colorbar
    subplot(1,8,3:4); scatter(stn, -press, 16, res, 'filled'); grid; set(gca,'color',[.8 .8 .8])
    xlabel('station'); xlim([min(stn) max(stn)])
    ylabel('press'); ylim(presrange); caxis(rlim); colorbar
    title([mcruise ' ' rlabel])
    subplot(1,8,5:6); scatter(ctemp, d.uoxygen(iig), 16, res, 'filled'); grid; set(gca,'color',[.8 .8 .8])
    xlabel('temp'); xlim([min(ctemp) max(ctemp)])
    ylabel('oxygen'); ylim([min(d.uoxygen) max(d.uoxygen)]); caxis(rlim); colorbar
    subplot(1,8,7:8); scatter(d.uoxygen(iig), -press, 16, res, 'filled'); grid; set(gca,'color',[.8 .8 .8])
    xlabel('oxygen'); xlim([min(d.uoxygen(iig)) max(d.uoxygen(iig))])
    ylabel('press'); ylim(presrange); caxis(rlim); colorbar
    if ~isempty(printform)
        print(printform, fullfile(printdir, ['ctd_eval_' sensname '_set' num2str(no) '_pt']))
    end
    
    
    %plot individual stations to check samples with large residuals
    ii = find( (abs(res)>llim(1) & press<pdeep) | (abs(res)>llim(2) & press>=pdeep) );
    cstn = stn(ii); cnisk = nisk(ii); 
    if plotprof && ~isempty(cstn)
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
            [d1, h1] = mloadq(fullfile(rootdir, ['ctd_' mcruise '_' stn_string '_psal.nc']), '/');
            [dcs, ~] = mloadq(fullfile(rootdir, ['dcs_' mcruise '_' stn_string '.nc']), '/');
            ii1u = find(d1.scan>=dcs.scan_bot & d1.scan<=dcs.scan_end);
            [du, hu] = mloadq(fullfile(rootdir, ['ctd_' mcruise '_' stn_string '_2up.nc']), '/');
            scriptname = 'mctd_02'; oopt = 'ctd_cals'; get_cropt
            
            if exist('cropt_cal','var')
                if cropt_cal
                    scriptname = 'mctd_02'; oopt = 'ctdcals'; get_cropt
                    calstr0 = castopts.calstr;
                end
                calstr = select_calibrations(testcal, calstr0);
                %and apply them
                [dcal1, hcal1] = apply_calibrations(d1, h1, calstr);
                [dcalu, hcalu] = apply_calibrations(du, hu, calstr);
                %put calibrated fields back into d1 and du
                for vno = 1:length(hcal1.fldnam)
                    d1.(hcal1.fldnam{vno}) = dcal1.(hcal1.fldnam{vno});
                end
                for vno = 1:length(hcalu.fldnam)
                    du.(hcalu.fldnam{vno}) = dcalu.(hcalu.fldnam{vno});
                end
            end
            
            %bottle samples and niskin data for this station
            iis = find(d.statnum(:)==s(no));
            iisbf = find(d.statnum(:)==s(no) & ~ismember(calflag, okf));
            iiq = find(d.statnum(:)==s(no) & mres & ismember(calflag, okf));
            
            plot(d1.(sensname)(ii1u), -d1.press(ii1u), 'c', du.(sensname), -du.press, 'k--', ...
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

