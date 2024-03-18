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
%   choose_sns serial number(s) to plot (default: all)
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
choose_sns = []; %only loop through these serial numbers
usedn = 0; %set to 1 to use downcast rather than upcast ctd data
okf = [2 6]; %2 and 6 are good (6 is average of replicates); 3 is questionable
pdeep = 1300; %cutoff for "deep" samples
uselegend = 1;
printform = '-dpdf';
plotprof = 1; %first station from which to plot individual profiles with large residuals
printdir = fullfile(MEXEC_G.mexec_data_root, 'plots');

if nargin>1 && isstruct(varargin{1})
    testcal = varargin{1};
    varargin(1) = [];
end
for no = 1:2:length(varargin)
    eval([varargin{no} ' = varargin{no+1};'])
end
if usedn
    dirstr = '_dn';
    udstr = 'd';
else
    dirstr = '';
    udstr = 'u';
end
if exist('rlim','var') %supplied as input
    p.rlim = rlim;
else
    p = [];
end

%load data
rootdir = mgetdir('ctd');
[d, h] = mloadq(fullfile(rootdir, ['sam_' mcruise '_all']), '/');
snfs = h.fldnam(strncmp(h.fldnam,'sn',2));
for no = 1:length(snfs)
    if sum(isnan(d.(snfs{no})))
        d.(snfs{no})(isnan(d.(snfs{no}))) = max(d.(snfs{no}));
        warning('filling NaNs in %s S/N',snfs{no})
    end
end
ddu = ['days since ' num2str(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1)) '-01-01 00:00:00'];
d.([udstr 'dday']) = m_commontime(d, [udstr 'time'], h, ddu);
h.fldnam = [h.fldnam [udstr 'dday']]; h.fldunt = [h.fldunt ddu];
%optionally, apply calibrations (on all sensors)
ds = d;
if sum(cell2mat(struct2cell(testcal)))
    d = apply_cal_samfile(d, h, udstr, testcal, calstr0);
end

%find which serial numbers we have for this sensor type
sns = [d.statnum d.(['sn_' parameter '1'])]; l = size(sns,1);
if isfield(d,['sn_' parameter '2'])
    sns = [sns; [d.statnum d.(['sn_' parameter '2'])]];
end
sns(1:l,3) = 1; sns(l+1:end,3) = 2;
sn = unique(sns(:,2)); sn = sn(~isnan(sn));
if ~isempty(choose_sns)
    sn = intersect(sn,choose_sns);
end

%loop through sensors
for ks = 1:length(sn)
    disp(['s/n' num2str(sn(ks))])

    %stations and indices with this sensor in position 1 or position 2
    stns1 = sns(sns(:,2)==sn(ks) & sns(:,3)==1, 1);
    stns2 = sns(sns(:,2)==sn(ks) & sns(:,3)==2, 1);
    iis1 = find(ismember(d.statnum,stns1));
    iis2 = find(ismember(d.statnum,stns2));

    %get ctd and comparison fields for both sets of indices
    clear p
    %p.xvar = 'statnum'; p.xvarlabel = p.xvar;
    p.xvar = 'dday'; p.xvarlabel = 'days';
    if strcmp(parameter,'oxygen') && ~useoxyratio
        [dc, p, mod] = sensor_cal_comparisons(d, [parameter '_diff'], num2str(sn(ks)), udstr, iis1, iis2, okf, p);
    else
        [dc, p, mod] = sensor_cal_comparisons(d, parameter, num2str(sn(ks)), udstr, iis1, iis2, okf, p);
    end
    if isempty(dc)
        %keyboard
        continue
    end
    if strcmp(parameter,'oxygen') && useoxyratio
        p.edges = [.9:.005:1.1];
    else
        p.edges = [-1:.05:1]*p.rlim(2);
    end
    p.presrange = [-max(d.([udstr 'press'])(~isnan(d.([udstr parameter])))) 0];
    p.statrange = [0 max(d.statnum(~isnan(d.([udstr parameter]))))+1];
    p.mcruise = mcruise;
    if strcmp(p.xvar,'statnum')
        p.xrange = p.statrange;
    else
        p.xrange = [min(dc.(p.xvar)) max(dc.(p.xvar))];
        p.xrange = p.xrange + [-1 1]*mean(p.xrange)*0.02;
    end

    %stats
    p.deep = dc.press>=pdeep;
    if length(p.iigc)<10
        p.md = NaN; p.iqrd = NaN;
        disp('too few comparison points'); continue
    else
        p.md = m_nanmedian(dc.res(p.iigc));
        ms = sqrt(m_nansum((dc.res(p.iigc))-p.md).^2)/(length(p.iigc)-1);
        ngp = length(p.iigc);
        c = dc.res(p.iigc); c = c(dc.press(p.iigc)>pdeep);
        try
            p.iqrd = iqr(c);
        catch
            c = sort(c);
            ii = [round(length(c)/4) round(length(c)*3/4)];
            p.iqrd = c(ii(2))-c(ii(1));
        end
    end

%plot residual or ratio vs statnum, pressure, temperature, and histogram
figure(2); clf
plot_residuals(dc, p, parameter); 
if ~isempty(printform)
    print(printform, fullfile(printdir, ['ctd_eval_' parameter '_' num2str(sn(ks)) '_hist' dirstr]))
end
cont = input('k for keyboard prompt, enter to continue to next\n','s');
if strcmp(cont,'k')
    keyboard
end

ii = find( (abs(dc.res(p.iigc))>p.rlim(2) & dc.press(p.iigc)<pdeep) | (abs(dc.res(p.iigc))>p.rlim(2)/2 & dc.press(p.iigc)>=pdeep) & dc.statnum(p.iigc)>=plotprof);
if ~isempty(ii)
    disp('examine larger differences profile-by-profile to help pick bad or')
    disp('questionable samples and set their flags in opt_cruise msal_01 or moxy_01?')
    next = input('y/k for keyboard/enter to skip and continue?\n','s');
    if strcmp(next,'y')
        plot_comparison_quality(dc,parameter,dc.statnum(p.iigc(ii)),testcal,calstr0,okf,[p.rlim(2) p.rlim(2)/2])
    elseif strcmp(next,'k')
        keyboard
    end
end


end %loop through serial numbers

%%%%%%%%%% subfunctions %%%%%%%%%%

function plot_residuals(dc, p, parameter)

subplot(5,5,[1:5])
hl = plot(dc.(p.xvar), dc.ctdres, 'c+', dc.(p.xvar), dc.res, '.g', dc.(p.xvar)(p.iigc), dc.res(p.iigc), 'b.', dc.(p.xvar)(p.deep), dc.res(p.deep), '.k'); grid
xlabel(p.xvarlabel); xlim(p.xrange); ylim(p.rlim); 
legend(hl([1 3 4 2]),p.colabel,p.cclabel,'deep','high var','location','southeastoutside');
set(gca,'xaxislocation','top')

subplot(5,5,[10 15 20 25])
plot(dc.ctdres, -dc.press, 'c+', dc.res, -dc.press, '.g', dc.res(p.iigc), -dc.press(p.iigc), 'b.'); grid
ylabel('-press'); ylim(p.presrange); xlim(p.rlim)
set(gca,'yaxislocation','right')

subplot(5,5,[6:9])
plot(dc.ctemp, dc.ctdres, 'c+', dc.ctemp, dc.res, '.g', dc.ctemp(p.iigc), dc.res(p.iigc), '.b', dc.ctemp(p.deep), dc.res(p.deep), '.k'); grid
xlabel('T'); ylim(p.rlim);

subplot(5,5,[11:12 16:17])
plot(dc.caldata, dc.ctddata, 'b.', dc.caldata(p.deep), dc.ctddata(p.deep), 'k.', dc.caldata, dc.caldata); grid;
axis image; xlabel(['cal ' parameter]); ylabel(['ctd ' parameter]);

subplot(5,5,[13:14 18:19])
scatter(dc.(p.xvar), -dc.press, 12, dc.res, 'filled'); grid
xlabel(p.xvar); xlim(p.xrange); ylim(p.presrange); ylabel('-press')
caxis(p.rlim); colorbar

subplot(5,5,[21:24])
nh = histc(dc.res, p.edges); nhgc = histc(dc.res(p.iigc), p.edges);
plot(p.edges, nh, 'g', p.edges, nhgc, 'b'); xlim(p.edges([1 end]))
ax = axis;
text(p.edges(end)*.9, ax(4)*.9, ['median ' num2str(round(p.md*1e5)/1e5)], 'horizontalalignment', 'right')
text(p.edges(end)*.9, ax(4)*.7, ['deep 25-75% ' num2str(round(p.iqrd*1e5)/1e5)], 'horizontalalignment', 'right')
xlim(p.edges([1 end])); grid; xlabel(p.cclabel); ylabel('number')


function plot_comparison_quality(dc,parameter,stns_examine,testcal,calstr,okf,llim)
%plot individual stations to check samples with large residuals

m_common

figure(1); clf
if ~isempty(stns_examine)
    stns_examine = stns_examine(ismember(stns_examine,dc.statnum));
    stns_examine = unique(stns_examine);
else
    stns_examine = unique(dc.statnum);
end
if isempty(calstr)
    co_cal = 1;
else
    co_cal = 0;
end
rootdir = mgetdir('ctd');
for no = 1:length(stns_examine)
    stnlocal = stns_examine(no);
    stn_string = sprintf('%03d', stnlocal);

    %load 1 and 2 dbar upcast profiles
    [d1, h1] = mloadq(fullfile(rootdir, ['ctd_' mcruise '_' stn_string '_psal.nc']), '/');
    [dcs, ~] = mloadq(fullfile(rootdir, ['dcs_' mcruise '_' stn_string '.nc']), '/');
    ii1u = find(d1.scan>=dcs.scan_bot & d1.scan<=dcs.scan_end);
    [du, hu] = mloadq(fullfile(rootdir, ['ctd_' mcruise '_' stn_string '_2up.nc']), '/');
    if co_cal
        opt1 = 'ctd_proc'; opt2 = 'ctd_cals'; get_cropt
        if exist('co','var') && isfield(co,'calstr')
            calstr = co.calstr;
        else
            calstr = [];
        end
    end
    if ~isempty(calstr)
        [dcal1, hcal1] = apply_calibrations(d1, h1, calstr, testcal, 'q');
        [dcalu, hcalu] = apply_calibrations(du, hu, calstr, testcal, 'q');
        %put calibrated fields back into d1 and du
        for vno = 1:length(hcal1.fldnam)
            d1.(hcal1.fldnam{vno}) = dcal1.(hcal1.fldnam{vno});
        end
        for vno = 1:length(hcalu.fldnam)
            du.(hcalu.fldnam{vno}) = dcalu.(hcalu.fldnam{vno});
        end
    end

    %bottle samples and niskin data for this station
    iis = find(dc.statnum==stnlocal);
    iisbf = find(dc.statnum==stnlocal & ~ismember(dc.calflag, okf));
    iiq = find(dc.statnum==stnlocal & abs(dc.res)>llim(2) & ismember(dc.calflag, okf));

    plot(d1.(parameter)(ii1u), -d1.press(ii1u), 'c', ...
        du.(parameter), -du.press, 'k--', ...
        dc.caldata(iis), -dc.press(iis), 'r.', ...
        dc.caldata(iisbf), -dc.press(iisbf), 'm.', ...
        dc.caldata(iiq), -dc.press(iiq), 'or', ...
        dc.ctddata(iis), -dc.press(iis), 'b.', ...
        dc.ctddata(iiq), -dc.press(iiq), 'sb');
    grid; title(sprintf('cast %d, cyan 1 hz, red good cal data, magenta bad cal data, blue ctd data, symbols large residuals',stnlocal));
    disp('sampnum residual sample_flag niskin_flag pressure')
    for qno = 1:length(iiq)
        fprintf(1,'%d %5.3f %d %d %d\n', stnlocal*100+dc.nisk(iiq(qno)), dc.res(iiq(qno)), dc.calflag(iiq(qno)), dc.niskf(iiq(qno)), round(dc.press(iiq(qno))))
    end
    cont = input('k for keyboard prompt, enter to continue to next\n','s');
    if strcmp(cont,'k')
        keyboard
    else
        continue
    end
    
end
