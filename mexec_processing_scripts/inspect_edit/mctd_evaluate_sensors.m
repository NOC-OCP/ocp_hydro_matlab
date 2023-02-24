function mctd_evaluate_sensors(parameter, varargin)
% mctd_evaluate_sensors(parameter)
% mctd_evaluate_sensors(parameter, testcal, varargin)
%
% using sam_{cruise}_all.nc, compare CTD temperature, conductivity, or
%   oxygen to sbe35 or bottle sample values in order to choose calibration
%   functions; inspect casts with outlier residuals
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
% parameter: 'temp', 'cond', 'oxygen' ***etc. tbi
%
% [optional] testcal: structure whose fieldnames are variables (temp, cond,
%   etc.) and values are 1 to apply calibrations or 0 (or missing) to not
%   (default: empty; no action)
% [optional] calstr0: (only used if testcal is set) a structure giving the
%   calibration strings (see mctd_02 for syntax); if not supplied or empty,
%   the calstr set in opt_cruise will be used
% [optional] parameter-value pairs:
%   useoxyratio (default 1) set to 0 to plot oxygen in terms of difference
%     rather than ratio
%   usedn (default 0) set to 1 to use neutral density-matched downcast ctd
%     data instead of upcast
%   okf (default [2 6]) sample flags that are okay to plot
%   pdeep (default 1000) cutoff for "deep" vs "shallow" samples
%   uselegend (default 1) to add legend to plots
%   printform (default '-dpdf') for how to print plots
%   plotprof (default 1) first station for which plot individual profiles;
%     inf or nan for none 
%   stns_examine (no default) list of station numbers for which to plot
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

m_common

%defaults and optional input arguments
testcal.temp = 0; testcal.cond = 0; testcal.oxygen = 0; testcal.fluor = 0;
calstr0 = []; %get calibration from opt_cruise -- but may depend on station number
useoxyratio = 1;
usedn = 0; %set to 1 to use downcast rather than upcast ctd data
okf = [2 6]; %2 and 6 are good (6 is average of replicates); 3 is questionable
pdeep = 1000; %cutoff for "deep" samples
uselegend = 1;
printform = '-dpdf';
plotprof = 1; %first station from which to plot individual profiles with large residuals
if strcmp(parameter, 'temp')
    rlabel = 'SBE35 T - CTD T (degC)';
    rlim = [-1 1]*1e-2;
elseif strcmp(parameter, 'cond')
    rlabel = 'C_{bot}/C_{ctd} (equiv. psu)';
    rlim = [-1 1]*2e-2;
elseif strcmp(parameter, 'oxygen')
    rlabel = 'O_{bot}/O_{ctd}';
    rlim = [-1 1]*1.5;
else
    error('sensname not recognised')
end
printdir = fullfile(MEXEC_G.mexec_data_root, 'plots');

if nargin>1 && isstruct(varargin{1})
    testcal = varargin{1};
    varargin(1) = [];
end
for no = 1:2:length(varargin)
    eval([varargin{no} ' = varargin{no+1};'])
end
if strcmp(parameter, 'oxygen') && ~useoxyratio
    rlabel = 'O_{bot} - O_{ctd} (umol/kg)';
    rlim = 1+[-5 5]/100;
end
if usedn
    dirstr = '_dn';
    prestr = 'd';
else
    dirstr = '';
    prestr = 'u';
end

%load data
rootdir = mgetdir('ctd');
[d, h] = mloadq(fullfile(rootdir, ['sam_' mcruise '_all']), '/');
%apply calibrations?
if sum(cell2mat(struct2cell(testcal)))
    d = apply_cal_samfile(d, h, testcal, calstr0);
end

p.edges = [-1:.05:1]*rlim(2);
p.presrange = [-max(d.([prestr 'press'])(~isnan(d.([prestr parameter])))) 0];
p.statrange = [0 max(d.statnum(~isnan(d.([prestr parameter]))))+1];

%find which serial numbers we have for this sensor type
sns = [d.statnum d.(['sn_' parameter '1'])]; l = size(sns,1);
if isfield(d,['sn_' parameter '2'])
    sns = [sns; [d.statnum d.(['sn_' parameter '2'])]];
end
sns(1:l,3) = 1; sns(l+1:end,3) = 2;
sn = unique(sns(:,2));

%loop through
for ks = 1:length(sn)

    %stations and indices with this sensor in position 1 or position 2
    stns1 = sns(sns(:,2)==sn(ks) & sns(:,3)==1, 1);
    stns2 = sns(sns(:,2)==sn(ks) & sns(:,3)==2, 1);
    iis1 = find(ismember(d.statnum,stns1));
    iis2 = find(ismember(d.statnum,stns2));

    %get ctd and comparison fields for both sets of indices
    [dc, p, mod] = sensor_cal_comparisons(d, parameter, num2str(sn(ks)), prestr, iis1, iis2, okf, rlim(2)*.8, rlim(2)*.8);


%stats
p.md = m_nanmedian(dc.res(p.iigc)); 
ms = sqrt(m_nansum((dc.res(p.iigc))-p.md).^2)/(length(p.iigc)-1);
p.deep = dc.press>=pdeep;
ngp = length(p.iigc);
c = dc.res(p.iigc); c = c(dc.press(p.iigc)>pdeep);
try
    p.iqrd = iqr(c);
catch
    c = sort(c);
    ii = [round(length(c)/4) round(length(c)*3/4)];
    p.iqrd = c(ii(2))-c(ii(1));
end

%plot residual or ratio vs statnum, pressure, and histogram
figure(2); clf; orient tall
plot_residuals(dc, p, parameter);
if ~isempty(printform)
    print(printform, fullfile(printdir, ['ctd_eval_' parameter '_' num2str(sn(ks)) 'hist' dirstr]))
end

% %plot residual or ratio in color vs 2 of statnum, press, temp, oxygen,
% %T-S
% figure(3); clf; orient portrait
% set(gcf,'defaultaxescolor',[.8 .8 .8])
% load cmap_bo2; colormap(cmap_bo2)
% subplot(4,4,[1 5]); scatter(ctemp, -press, 16, res, 'filled'); grid;
% xlabel('temp'); xlim([min(ctemp) max(ctemp)])
% ylabel('press'); ylim(presrange); caxis(rlim); colorbar
% subplot(4,4,[2 6]); scatter(stn, -press, 16, res, 'filled'); grid;
% xlabel('station'); xlim([min(stn) max(stn)])
% ylabel('press'); ylim(presrange); caxis(rlim); colorbar
% title([mcruise ' ' rlabel])
% subplot(4,4,[3 7]); scatter(ctemp, d.uoxygen(iig), 16, res, 'filled'); grid;
% xlabel('temp'); xlim([min(ctemp) max(ctemp)])
% ylabel('oxygen'); ylim([min(d.uoxygen) max(d.uoxygen)]); caxis(rlim); colorbar
% subplot(4,4,[4 8]); scatter(csal, ctemp, 16, res, 'filled'); grid;
% xlabel('S'); ylabel('T'); caxis(rlim); colorbar
% xlim([min(csal) max(csal)]); ylim([min(ctemp) max(ctemp)]);
% if exist('cqflag','var')
%     subplot(4,4,[1 5]+8); scatter(ctemp(iigc), -press(iigc), 16, res(iigc), 'filled'); grid;
%     xlabel('temp'); xlim([min(ctemp) max(ctemp)])
%     ylabel('press'); ylim(presrange); caxis(rlim); colorbar
%     subplot(4,4,[2 6]+8); scatter(stn(iigc), -press(iigc), 16, res(iigc), 'filled'); grid;
%     xlabel('station'); xlim([min(stn) max(stn)])
%     ylabel('press'); ylim(presrange); caxis(rlim); colorbar
%     title([mcruise ' ' rlabel])
%     subplot(4,4,[3 7]+8); scatter(ctemp(iigc), d.uoxygen(iig(iigc)), 16, res(iigc), 'filled'); grid;
%     xlabel('temp'); xlim([min(ctemp) max(ctemp)])
%     ylabel('oxygen'); ylim([min(d.uoxygen) max(d.uoxygen)]); caxis(rlim); colorbar
%     subplot(4,4,[4 8]+8); scatter(csal(iigc), ctemp(iigc), 16, res(iigc), 'filled'); grid;
%     xlabel('S'); ylabel('T'); caxis(rlim); colorbar
%     xlim([min(csal) max(csal)]); ylim([min(ctemp) max(ctemp)]);
% end
% if ~isempty(printform)
%     print(printform, fullfile(printdir, ['ctd_eval_' sensname '_stns_' num2str(min(stn)) '_' num2str(max(stn)) dirstr]));
% end

llim = [rlim(2) rlim(2)/2];
ii = find( (abs(dc.res)>llim(1) & dc.press<pdeep) | (abs(dc.res)>llim(2) & dc.press>=pdeep) & dc.statnum>=plotprof);
if ~isempty(ii)
    disp('to examine larger differences profile-by-profile to help pick bad or')
    disp('questionable samples and set their flags in opt_cruise msal_01 or moxy_01,')
    disp('press any key to continue (or ctrl-c to quit)') %***loop
    pause
end
plot_comparison_quality(dc,ii,stns_examine,cropt_cal,testcal,calstr0,okf,llim)


end %loop through serial numbers

%%%%%%%%%% subfunctions %%%%%%%%%%

function d = apply_cal_samfile(d, oxyvars, usedn, testcal, calstr0)
% function d = apply_cal_samfile(d, oxyvars, usedn, testcal, calstr0);
% wrapper for apply_calibrations to work on utemp etc.

m_common

%rename variables
opt1 = 'castpars'; opt2 = 'oxyvars'; get_cropt
uflds = {'press' 'temp1' 'temp2' 'psal1' 'psal2' 'cond1' 'cond2' 'oxygen1' 'oxygen2' 'fluor'};
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
%set up
if isempty(calstr0); cropt_cal = 1; else; cropt_cal = 0; end

%loop through stations, since they might have different cal functions
stns = unique(d.statnum);
for sno = stns(:)'
    stnlocal = sno;
    %get only the calibration functions we want to test here
    if cropt_cal %didn't specify as input, get from opt_cruise
        opt1 = 'calibration'; opt2 = 'ctd_cals'; get_cropt
        calstr0 = castopts.calstr;
    end
    clear d0
    iig = find(d.statnum==stnlocal);
    for vno = 1:length(uflds)
        d0.(uflds{vno}) = d.(uflds{vno})(iig);
    end
    [dcal, hcal] = apply_calibrations(d0, h, calstr0, testcal, 'q');
    %put calibrated data from this station only back into d
    for vno = 1:length(hcal.fldnam)
        d.(hcal.fldnam{vno})(iig) = dcal.(hcal.fldnam{vno});
    end

end

%rename back
for no = 1:length(uflds)-3
    if ~usedn
        d.(['u' uflds{no}]) = d.(uflds{no});
    else
        d.(['d' uflds{no}]) = d.(uflds{no});
    end
end



function plot_residuals(dc, p, parameter)
%first plot
subplot(5,5,[1:5])
hl = plot(dc.statnum, dc.ctdres, 'c.', dc.statnum, dc.res, 'og', dc.statnum(p.iigc), dc.res(p.iigc), '+b', dc.statnum(p.deep), dc.res(p.deep), 'xk'); grid
xlabel('statnum'); xlim(p.statrange); ylim(p.rlim)
legend(hl([1 2 4]),p.colabel,p.cclabel,'deep'); title(p.mcruise)
subplot(5,5,[9:10 14:15 19:20 24:25])
plot(dc.ctdres, -dc.press, 'c.', dc.res, -dc.press, 'og', dc.res(p.iigc), -dc.press(p.iigc), '+b', [0 0]); grid
ylabel('press'); ylim(p.presrange); xlim(p.rlim)
legend(hl(1:2),p.colabel,p.cclabel)
subplot(5,5,[6:8 11:13])
plot(dc.caldata, dc.ctddata, 'o-k', dc.caldata(p.deep), dc.ctddata(p.deep), 'sb', dc.caldata, dc.caldata); grid;
axis image; xlabel(['cal ' parameter]); ylabel(['ctd ' parameter]);
subplot(5,5,[16:18 21:23])
nh = histc(dc.res, p.edges); nhgc = histc(dc.res(p.iigc), p.edges);
plot(p.edges, nh, 'g', p.edges, nhgc, 'k');
title([p.mcruise ' ' p.rlabel])
ax = axis;
text(p.edges(end)*.9, ax(4)*.95, ['median ' num2str(round(p.md*1e5)/1e5)], 'horizontalalignment', 'right')
text(p.edges(end)*.9, ax(4)*.85, ['deep 25-75% ' num2str(round(p.iqrd*1e5)/1e5)], 'horizontalalignment', 'right')
xlim(p.edges([1 end])); grid


function plot_comparison_quality(dc,ii,stns_examine,cropt_cal,testcal,calstr0,okf,llim)
%plot individual stations to check samples with large residuals

cstn = dc.statnum(ii); %cnisk = dc.nisk(ii);

figure(1); clf
if ~isempty(stns_examine)
    s = unique(union(cstn,stns_examine));
else
    s = unique(cstn);
end
for no = 1:length(s)
    stnlocal = s(no);
    stn_string = sprintf('%03d', stnlocal);
    
    %load 1 and 2 dbar upcast profiles
    [d1, h1] = mloadq(fullfile(rootdir, ['ctd_' mcruise '_' stn_string '_psal.nc']), '/');
    [dcs, ~] = mloadq(fullfile(rootdir, ['dcs_' mcruise '_' stn_string '.nc']), '/');
    ii1u = find(d1.scan>=dcs.scan_bot & d1.scan<=dcs.scan_end);
    [du, hu] = mloadq(fullfile(rootdir, ['ctd_' mcruise '_' stn_string '_2up.nc']), '/');
    opt1 = 'calibration'; opt2 = 'ctd_cals'; get_cropt
    %calibrate them
    if ~isempty(cropt_cal)
        if cropt_cal
            opt1 = 'mctd_02'; opt2 = 'ctd_cals'; get_cropt
            calstr0 = castopts.calstr;
            if exist('testcal','var')
                castopts.docal = testcal;
            end
        end
        [dcal1, hcal1] = apply_calibrations(d1, h1, calstr0, castopts.docal);
        [dcalu, hcalu] = apply_calibrations(du, hu, calstr0, castopts.docal);
        %put calibrated fields back into d1 and du
        for vno = 1:length(hcal1.fldnam)
            d1.(hcal1.fldnam{vno}) = dcal1.(hcal1.fldnam{vno});
        end
        for vno = 1:length(hcalu.fldnam)
            du.(hcalu.fldnam{vno}) = dcalu.(hcalu.fldnam{vno});
        end
    end
    
    %bottle samples and niskin data for this station
    iis = find(dc.statnum==s(no));
    iisbf = find(dc.statnum==s(no) & ~ismember(dc.calflag, okf));
    iiq = find(dc.statnum==s(no) & abs(dc.res)>llim(2) & ismember(dc.calflag, okf));
    
    plot(d1.(sensname)(ii1u), -d1.press(ii1u), 'c', ...
        du.(sensname), -du.press, 'k--', ...
        dc.caldata(iis), -dc.press(iis), 'r.', ...
        dc.caldata(iisbf), -dc.press(iisbf), 'm.', ...
        dc.caldata(iiq), -dc.press(iiq), 'or', ...
        dc.ctddata(iis), -dc.press(iis), 'b.', ...
        dc.ctddata(iiq), -dc.press(iiq), 'sb');
    grid; title(sprintf('cast %d, cyan 1 hz, red good cal data, magenta bad cal data, blue ctd data, symbols large residuals',s(no)));
    disp('sampnum residual sample_flag niskin_flag pressure')
    for qno = 1:length(iiq)
        sprintf('%d %5.3f %d %d %d', s(no)*100+dc.nisk(iiq(qno)), dc.res(iiq(qno)), dc.calflag(iiq(qno)), dc.niskf(iiq(qno)), round(dc.press(iiq(qno))))
    end
    cont = input('k for keyboard prompt, enter to continue to next\n','s');
    if strcmp(cont,'k')
        keyboard
    else
        continue
    end
    
end
