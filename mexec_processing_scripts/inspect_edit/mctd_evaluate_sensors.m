function mctd_evaluate_sensors(parameter, varargin)
% mctd_evaluate_sensors(parameter)
% mctd_evaluate_sensors(parameter, testcal, varargin)
%
% compare CTD temperature, conductivity, or oxygen to calibration values
%   in order to choose calibration functions; inspect casts with outlier
%   residuals
% loops through different sensor serial numbers 
%
% produces plots comparing them and a suggested calibration function
%     depending on quantity:
%   linear station number drift offset for temp
%   linear station number drift + linear in pressure scaling for cond
%     (approximately equivalent to an offset for sal)
%   linear station number drift + *** for oxy
%
% inputs:
% parameter: 'temp', 'cond', 'oxygen' etc.
%
% [optional] testcal: structure whose fieldnames are variables (temp, cond,
%   etc.) and values are 1 to apply calibrations or 0 (or missing) to not
%   (default: empty; no action)
% [optional] calstr0: (only used if testcal is set) a structure giving the
%   calibration strings (see setdef_cropt_cast.m under mctd_02, ctd_cals);
%   if not supplied or empty, the calstr set in opt_cruise will be used
% [optional] parameter-value pairs:
%   useoxyratio (default 0) set to 1 to plot oxygen in terms of ratio
%     rather than difference
%   usedn (default 0) set to 1 to use neutral density-matched downcast ctd
%     data instead of upcast
%   okf (default [2 6]) sample flags that are okay to plot
%   pdeep (default 1200) cutoff for "deep" vs "shallow" samples
%   uselegend (default 1) to add legend to plots
%   printform (default '-dpdf') for how to print plots
%   plotprof (default 1) first station for which to potentially plot
%     individual profiles; switch to inf or nan for none
%   stns_examine (default []) list of station numbers for which to plot
%     individual profiles (supersedes plotprof)
%
% e.g.
%   testcal.temp = 1;
%   mctd_evaluate_sensors('temp',testcal)
%     will apply the calibrations coded into the mctd_02 case in opt_cruise
%     (for both temp1 and temp2) before plotting
%   testcal.temp = 1; calstr0.temp1.jc238 = 'dcal.temp1 = d0.temp1+1e-4;';
%   mctd_evaluate_sensors('temp',testcal,calstr0)
%     will instead apply this calibration function
% if you want to test out a conductivity calibration and have an estimated
%   but not yet applied (to the ctd and sam files) temperature calibration,
%   it is a good idea to also set testcal.temp = 1 to use the best estimate
%   of temperature in the salinity-conductivity conversion
% for oxygen, this script will not reconvert from umol/l to umol/kg, so if
%   you have determined temperature and conductivity calibrations, apply
%   them to the (ctd and sam) files first, then run this script to
%   determine the final oxygen calibration
%
% loads sam_{cruise}_all.nc and sensor_groups.mat
%

%***add fluor

m_common

%defaults and optional input arguments
testcal.temp = 0; testcal.cond = 0; testcal.oxygen = 0; testcal.fluor = 0;
calstr0 = []; %get calibration from opt_cruise -- but may depend on station number
useoxyratio = 0;
usedn = 0; %set to 1 to use downcast rather than upcast ctd data
okf = [2 6]; %2 and 6 are good (6 is average of replicates); 3 is questionable
pdeep = 1000; %cutoff for "deep" samples
uselegend = 1;
printform = '-dpdf';
plotprof = 1; %first station from which to plot individual profiles with large residuals
stns_examine = [];
if strncmp(sensname, 'temp', 4)
    rlabel = 'SBE35 T - CTD T (degC)';
    rlim = [-1 1]*1e-2;
    %vrlim = [-2 32];
elseif strncmp(sensname, 'cond', 4)
    rlabel = 'C_{bot}/C_{ctd} (equiv. psu)';
    rlim = [-1 1]*2e-2;
    %vlim = [25 60];
elseif strncmp(sensname, 'oxy', 3)
    rlabel = 'O_{bot} - O_{ctd} (umol/kg)';
    rlim = [-5 5];
    %vlim = [50 450];
else
    error('sensname not recognised')
end
llim = [rlim(2) rlim(2)/2]; %threshold for shallow and deep points to examine in individual profiles
printdir = fullfile(MEXEC_G.mexec_data_root, 'plots');

if nargin>1 && isstruct(varargin{1})
    testcal = varargin{1};
    varargin(1) = [];
end
for no = 1:2:length(varargin)
    eval([varargin{no} ' = varargin{no+1};'])
end

dirstr = '';
if usedn; dirstr = '_dn'; end

if strncmp(sensname, 'oxy', 3) && useoxyratio
    rlabel = 'O_{bot}/O_{ctd}';
    rlim = [-1 1]*1.5;
    llim = [rlim(2) rlim(2)/2];
end

rootdir = mgetdir('ctd');
%load data
[d, h] = mloadq(fullfile(rootdir, ['sam_' mcruise '_all']), '/');
%and turn utemp etc into temp etc. so apply_calibrations will work
uflds = {'press' 'temp1' 'temp2' 'psal1' 'psal2' 'cond1' 'cond2' 'oxygen1' 'oxygen2' 'fluor'};
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
        stnlocal = sno;
        %get only the calibration functions we want to test here
        if cropt_cal %didn't specify as input, get from opt_cruise
            scriptname = 'mctd_02'; oopt = 'ctd_cals'; get_cropt
            calstr0 = castopts.calstr;
        end
        calstr = select_calibrations(testcal, calstr0);
        %and apply them
        clear d0
        iig = find(d.statnum==stnlocal);
        for vno = 1:length(uflds)
            d0.(uflds{vno}) = d.(uflds{vno})(iig);
        end
        [dcal, hcal] = apply_calibrations(d0, h, calstr, 'q');
        %put calibrated data from this station only back into d
        for vno = 1:length(hcal.fldnam)
            d.(hcal.fldnam{vno})(iig) = dcal.(hcal.fldnam{vno});
        end
    end
    
end

edges = [-1:.05:1]*rlim(2);

presrange = [-max(d.press(~isnan(d.(sensname)))) 0];
statrange = [0 max(d.statnum(~isnan(d.(sensname))))+1];

scriptname = 'castpars'; oopt = 'ctdsens_groups'; get_cropt

lp = length(parameter);
fn = fieldnames(sng);
fn = fn(strncmp(parameter,fn,lp));
sns = str2num(cell2mat(cellfun(@(x) x(lp+2:end),fn,'UniformOutput',false)));


%sg

%***


sensother = num2str(setdiff([1 2],str2num(sensnum)));

iig = find(ismember(d.statnum, sens_stns));

%data to compare
ctddata = d.(sensname)(iig);
if strncmp(sensname, 'temp', 4)
    caldata = d.sbe35temp(iig);
    calflag = d.sbe35temp_flag(iig);
    ii = find(ismember(calflag,okf));
    caldata = caldata(ii); calflag = calflag(ii);
    ctddata = ctddata(ii);
    iig = iig(ii);
    res = (caldata - ctddata);
    if isfield(d, 'temp1') && isfield(d, 'temp2')
        ctdres = d.(['temp' sensother])(iig) - ctddata;
        clabel = ['ctd temp' sensother ' - ' sensname];
    else
        ctdres = NaN+ctddata;
        clabel = '';
    end
    isratio = 0;
elseif strncmp(sensname, 'cond', 4)
    caldata = gsw_C_from_SP(d.botpsal(iig),d.(['temp' sensnum])(iig),d.press(iig)); %cond at CTD temp
    calflag = d.botpsal_flag(iig);
    ii = find(ismember(calflag,okf));
    caldata = caldata(ii); calflag = calflag(ii);
    ctddata = ctddata(ii);
    iig = iig(ii);
    res = (caldata./ctddata - 1)*35;
    if isfield(d, 'cond1') && isfield(d, 'cond2')
        sother = gsw_SP_from_C(d.(['cond' sensother])(iig),d.(['temp' sensother])(iig),d.press(iig)); %sal from other CTD
        cother_tempsens = gsw_C_from_SP(sother,d.(['temp' sensnum])(iig),d.press(iig)); %cond from this sal at CTD temp
        ctdres = (cother_tempsens./ctddata-1)*35; %ratio reflecting sal differences only (not temp differences)
        clabel = ['ctd (cond' sensother ' at temp' sensnum ')/' sensname];
    else
        ctdres = NaN+ctddata;
        clabel = '';
    end
    isratio = 1;
elseif strncmp(sensname, 'oxygen', 6)
    caldata = d.botoxy(:);
    calflag = d.botoxy_flag(iig);
    ii = find(ismember(calflag,okf));
    caldata = caldata(ii); calflag = calflag(ii);
    ctddata = ctddata(ii);
    iig = iig(ii);
    if useoxyratio
        res = caldata./ctddata;
        isratio = 1;
        rlim = 1+rlim/100; % percent rather than difference
    else
        res = (caldata - ctddata);
        isratio = 0;
    end
    if isfield(d, 'oxygen1') && isfield(d, 'oxygen2')
        if useoxyratio
            ctdres = d.(['oxygen' sensother])(iig)./ctddata;
            clabel = ['ctd oxygen' sensother '/' sensname];
        else
            ctdres = d.(['oxygen' sensother])(iig) - ctddata;
            clabel = ['ctd oxygen' sensother ' - ' sensname];
        end
    else
        ctdres = NaN+ctddata;
        clabel = '';
    end
end

%get other quantities we might use
stn = d.statnum(iig);
nisk = d.position(iig); niskf = d.niskin_flag(iig);
press = d.upress(iig); ctemp = d.utemp(iig); csal = d.upsal(iig);

%check for high-variance bottle stops
cqflag = 2+zeros(length(iig),1);
m = false(size(cqflag));
if isfield(d,['std1_' sensname(1:end-1)])
    m = m | d.(['std1_' sensname(1:end-1)])(iig)>rlim(2)*.8;
end
if isfield(d,['grad_' sensname(1:end-1)])
    m = m | abs(d.(['grad_' sensname(1:end-1)])(iig))>rlim(2)*.8;
end
cqflag(m) = 3;
iigc = find(cqflag==2);
[length(iig) length(iigc)]

%fit model
if strncmp(sensname,'temp',4)
    model = [ones(length(iigc),1) press(iigc) stn(iigc)];
    modform = 'tempcal = temp + C1 + C2(press) + C3(stn)';
    C = regress(res(iigc),model);
elseif strncmp(sensname,'cond',4)
    model = [ctddata(iigc) ctddata(iigc).*press(iigc) ctddata(iigc).*stn(iigc)];
    modform = 'condcal = cond*(C1 + C2(press) + C3(stn))';
    C = regress(caldata(iigc),model);
elseif strncmp(sensname,'oxygen',6)
    model = [ones(length(iigc),1) press(iigc) press(iigc).^2 ctddata(iigc) ctddata(iigc).*press(iigc) ctddata(iigc).*press(iigc).^2];
    modform = 'oxycal = C1 + C2(press) + C3(press^2) + (C4 + C5(press) + C6(press^2))(oxy)';
    C = regress(caldata(iigc),model);
end
disp(modform); format long; disp(C); format

%stats
md = m_nanmedian(res(iigc)); ms = sqrt(m_nansum((res(iigc))-md).^2)/(length(iigc)-1);
deep = press>=pdeep;
ngp = length(iigc);
c = res(iigc); c = c(press(iigc)>pdeep);
try
    iqrd = iqr(c);
catch
    c = sort(c);
    ii = [round(length(c)/4) round(length(c)*3/4)];
    iqrd = c(ii(2))-c(ii(1));
end

%plot residual or ratio vs statnum, pressure, and histogram
figure(2); clf; orient tall
subplot(5,5,[1:5])
plot(stn, ctdres, 'c.', stn, res, '.g', stn(iigc), res(iigc), '+k', stn(deep), res(deep), 'xb'); grid
if uselegend
    if isratio
        legend(clabel,'cal/ctd','cal/ctd steady',['cal/ctd, p>' num2str(pdeep)])
    else
        legend(clabel,'cal-ctd','cal-ctd steady',['cal-ctd, p>' num2str(pdeep)])
    end
end
xlabel('statnum'); xlim(statrange); ylabel(rlabel); ylim(rlim)
title([mcruise])
subplot(5,5,[9:10 14:15 19:20 24:25])
plot(ctdres, -press, 'c.', res, -press, '.g', res(iigc), -press(iigc), '+k', [0 0], presrange, 'r'); grid
ylabel('press'); ylim(presrange); xlabel(rlabel); xlim(rlim)
subplot(5,5,[6:8 11:13])
plot(caldata, ctddata, 'o-k', caldata(deep), ctddata(deep), 'sb', caldata, caldata); grid;
axis image; xlabel(['cal ' sensname]); ylabel(['ctd ' sensname]);
subplot(5,5,[16:18 21:23])
nh = histc(res, edges); nhgc = histc(res(iigc),edges);
plot(edges, nh, 'g', edges, nhgc, 'k');
title([mcruise ' ' rlabel])
ax = axis;
text(edges(end)*.9, ax(4)*.95, ['median ' num2str(round(md*1e5)/1e5)], 'horizontalalignment', 'right')
text(edges(end)*.9, ax(4)*.85, ['deep 25-75% ' num2str(round(iqrd*1e5)/1e5)], 'horizontalalignment', 'right')
xlim(edges([1 end])); grid
if ~isempty(printform)
    print(printform, fullfile(printdir, ['ctd_eval_' sensname '_hist_stns_' num2str(min(stn)) '_' num2str(max(stn)) dirstr]))
end

%plot residual or ratio in color vs 2 of statnum, press, temp, oxygen,
%T-S
figure(3); clf; orient portrait
set(gcf,'defaultaxescolor',[.8 .8 .8])
load cmap_bo2; colormap(cmap_bo2)
subplot(4,4,[1 5]); scatter(ctemp, -press, 16, res, 'filled'); grid;
xlabel('temp'); xlim([min(ctemp) max(ctemp)])
ylabel('press'); ylim(presrange); caxis(rlim); colorbar
subplot(4,4,[2 6]); scatter(stn, -press, 16, res, 'filled'); grid;
xlabel('station'); xlim([min(stn) max(stn)])
ylabel('press'); ylim(presrange); caxis(rlim); colorbar
title([mcruise ' ' rlabel])
subplot(4,4,[3 7]); scatter(ctemp, d.uoxygen(iig), 16, res, 'filled'); grid;
xlabel('temp'); xlim([min(ctemp) max(ctemp)])
ylabel('oxygen'); ylim([min(d.uoxygen) max(d.uoxygen)]); caxis(rlim); colorbar
subplot(4,4,[4 8]); scatter(csal, ctemp, 16, res, 'filled'); grid;
xlabel('S'); ylabel('T'); caxis(rlim); colorbar
xlim([min(csal) max(csal)]); ylim([min(ctemp) max(ctemp)]);
if exist('cqflag','var')
    subplot(4,4,[1 5]+8); scatter(ctemp(iigc), -press(iigc), 16, res(iigc), 'filled'); grid;
    xlabel('temp'); xlim([min(ctemp) max(ctemp)])
    ylabel('press'); ylim(presrange); caxis(rlim); colorbar
    subplot(4,4,[2 6]+8); scatter(stn(iigc), -press(iigc), 16, res(iigc), 'filled'); grid;
    xlabel('station'); xlim([min(stn) max(stn)])
    ylabel('press'); ylim(presrange); caxis(rlim); colorbar
    title([mcruise ' ' rlabel])
    subplot(4,4,[3 7]+8); scatter(ctemp(iigc), d.uoxygen(iig(iigc)), 16, res(iigc), 'filled'); grid;
    xlabel('temp'); xlim([min(ctemp) max(ctemp)])
    ylabel('oxygen'); ylim([min(d.uoxygen) max(d.uoxygen)]); caxis(rlim); colorbar
    subplot(4,4,[4 8]+8); scatter(csal(iigc), ctemp(iigc), 16, res(iigc), 'filled'); grid;
    xlabel('S'); ylabel('T'); caxis(rlim); colorbar
    xlim([min(csal) max(csal)]); ylim([min(ctemp) max(ctemp)]);
end
if ~isempty(printform)
    print(printform, fullfile(printdir, ['ctd_eval_' sensname '_stns_' num2str(min(stn)) '_' num2str(max(stn)) dirstr]));
end


%plot individual stations to check samples with large residuals
ii = find( (abs(res)>llim(1) & press<pdeep) | (abs(res)>llim(2) & press>=pdeep) & stn>=plotprof);
cstn = stn(ii); cnisk = nisk(ii);
if ~isempty(cstn)
    disp('to examine larger differences profile-by-profile to help pick bad or')
    disp('questionable samples and set their flags in opt_cruise msal_01 or moxy_01,')
    disp('press any key to continue (or ctrl-c to quit)')
    pause
end

figure(1); clf
s = unique(union(cstn,stns_examine));
for no = 1:length(s)
    stnlocal = s(no);
    stn_string = sprintf('%03d', stnlocal);
    
    %load 1 and 2 dbar upcast profiles
    [d1, h1] = mloadq(fullfile(rootdir, ['ctd_' mcruise '_' stn_string '_psal.nc']), '/');
    [dcs, ~] = mloadq(fullfile(rootdir, ['dcs_' mcruise '_' stn_string '.nc']), '/');
    ii1u = find(d1.scan>=dcs.scan_bot & d1.scan<=dcs.scan_end);
    [du, hu] = mloadq(fullfile(rootdir, ['ctd_' mcruise '_' stn_string '_2up.nc']), '/');
    scriptname = 'mctd_02'; oopt = 'ctd_cals'; get_cropt
    %calibrate them
    if exist('cropt_cal','var')
        if cropt_cal
            scriptname = 'mctd_02'; oopt = 'ctd_cals'; get_cropt
            calstr0 = castopts.calstr;
        end
        calstr = select_calibrations(testcal, calstr0);
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
    iis = find(stn==s(no));
    iisbf = find(stn==s(no) & ~ismember(calflag, okf));
    iiq = find(stn==s(no) & abs(res)>llim(2) & ismember(calflag, okf));
    
    plot(d1.(sensname)(ii1u), -d1.press(ii1u), 'c', ...
        du.(sensname), -du.press, 'k--', ...
        caldata(iis), -press(iis), 'r.', ...
        caldata(iisbf), -press(iisbf), 'm.', ...
        caldata(iiq), -press(iiq), 'or', ...
        ctddata(iis), -press(iis), 'b.', ...
        ctddata(iiq), -press(iiq), 'sb');
    grid; title(sprintf('cast %d, cyan 1 hz, red good cal data, magenta bad cal data, blue ctd data, symbols large residuals',s(no)));
    disp('sampnum residual sample_flag niskin_flag pressure')
    for qno = 1:length(iiq)
        sprintf('%d %5.3f %d %d %d', s(no)*100+nisk(iiq(qno)), res(iiq(qno)), calflag(iiq(qno)), niskf(iiq(qno)), round(press(iiq(qno))))
    end
    cont = input('k for keyboard prompt, enter to continue to next\n','s');
    if strcmp(cont,'k')
        keyboard
    else
        continue
    end
    
end


