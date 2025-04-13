function mtsg_bottle_ctd_compare(varargin)
% mtsg_bottle_ctd_compare(dintake)
% mtsg_bottle_ctd_compare(dintake, sepdownup)
% mtsg_bottle_ctd_compare(dintake, sepdownup, reload_cal)
% compare TSG/underway data from the merged, 1-min averaged surface_ocean
% file with bottle parameters (salinity and/or fluorescence, where
% available) and (optionally) near-surface CTD temperature and salinity
%

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING; % cruise name (from MEXEC_G global)

dintake = 3; %depth of UCSW intake, if >0, extract CTD data within 1 dbar of dintake
%***cruise option
sepdownup = 0; %ctd down and upcast data are loaded separately, but will be combined before comparing to tsg if sepdownup is 0
reload_cal = 1;
if nargin>0
    dintake = varargin{1};
    if nargin>1
        sepdownup = varargin{2};
        if nargin>2
            reload_cal = varargin{3};
        end
    end
end
dstr = num2str(dintake);
if dintake>0
    comp2ctd = 1;
else
    comp2ctd = 0;
end


%%%%% load data %%%%%

tsgfile = fullfile(MEXEC_G.mexec_data_root,'met',['surface_ocean_' mcruise '.nc']);
atmfile = fullfile(MEXEC_G.mexec_data_root,'met',['surfmet_' mcruise '_all_edt.nc']);
salfile = fullfile(mgetdir('M_BOT_SAL'),['tsgsal_' mcruise '_all.nc']);
chlfile = fullfile(mgetdir('M_BOT_CHL'),['ucswchl_' mcruise '_all.nc']);
cdatafile = fullfile(MEXEC_G.mexec_data_root,'bottle_samples','uway_cal_data');

%comparison data (bottle, ctd)
if reload_cal

    %load sample data, convert to dday
    bsal = 0; bchl = 0;
    bdelay = 1/1440; %delay bottles by 1 min to allow for delay between bottle being drawn and passing through TSG? ***option?
    tud = ['days since ' MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1) '-01-01 00:00:00'];
    if exist(salfile,'file')
        [dbs, hbs] = mload(salfile,'/');
        dbs.dday = m_commontime(dbs, 'time', hbs, tud)-bdelay;
        bsal = 1;
        disp('loaded bottle salinity')
        dispnames.db.salinity_adj = 'Bottle salinity (pss-78)';
    end
    if exist(chlfile,'file')
        [dbf, hbf] = mload(chlfile,'/');
        dbf.dday = m_commontime(dbf, 'time', hbf, tud)-bdelay;
        bchl = 1;
        disp('loaded bottle Chl')
        dispnames.db.chl = 'Bottle Chl (ug/l)';
    end

    %combine types of sample data into one structure db
    if bsal && bchl
        db = dbs;
        n0 = length(db.dday); nn = length(dbf.dday);
        db.dday = [db.dday; dbf.dday];
        fv = setdiff(fieldnames(db),{'dday'});
        for no = 1:length(fv)
            db.(fv{no}) = [dv.(fv{no}); nan(nn,1)];
        end
        fv = setdiff(fieldnames(dbf),{'dday'});
        for no = 1:length(fv)
            db.(fv{no}) = [nan(n0,1); dbf.(fv{no})];
        end
    elseif bsal
        db = dbs;
    elseif bchl
        db = dbf;
    end

    %add ctd data
    if comp2ctd
        disp('loading CTD data')
        dc = ctds_from_level(dintake, 1);
        n0 = length(db.dday); nn = length(dc.dday);
        db.dday = [db.dday; dc.dday];
        fv = setdiff(fieldnames(db),{'dday'});
        for no = 1:length(fv)
            db.(fv{no}) = [db.(fv{no}); nan(nn,1)];
        end
        fv = setdiff(fieldnames(dc),{'dday'});
        for no = 1:length(fv)
            db.(fv{no}) = [nan(n0,1); dc.(fv{no})];
        end
        dispnames.db.ctdt = ['CTD (down) temp at ' dstr ' dbar'];
        dispnames.db.ctut = ['CTD (up) temp at ' dstr ' dbar'];
        dispnames.db.ctds = ['CTD (down) psal at ' dstr ' dbar'];
        dispnames.db.ctus = ['CTD (up) psal at ' dstr ' dbar'];
        dispnames.db.ctdf = ['CTD (down) fluor at ' dstr ' dbar'];
        dispnames.db.ctuf = ['CTD (up) fluor at ' dstr ' dbar'];
    end

    %***add shallowest bottle stop data?****

    %sort times
    db = struct2table(db);
    [~,ii] = sort(db.dday);
    if length(ii)<length(db.dday)
        disp('different samples at the same time')
        keyboard
        %would need new code to deal with this, but it's unlikely to come up (can
        %only draw one sample at a time, and unlikely CTD would be precisely
        %the same time to the second)
    end
    db = db(ii,:);

    save(cdatafile,'db','dintake')

else

    load(cdatafile)
    bsal = 0; bchl = 0;
    if isfield(db,'salinity_adj') && sum(~isnan(db.salinity_adj))
        bsal = 1;
    end
    if isfield(db,'chl') && sum(~isnan(db.chl))
        bchl = 1;
    end

end
if comp2ctd && ~sepdownup
    db.ct = db.ctdt; db.ct(isnan(db.ct)) = db.ctut(isnan(db.ct));
    db.cs = db.ctds; db.cs(isnan(db.cs)) = db.ctus(isnan(db.cs));
    db.cf = db.ctdf; db.cf(isnan(db.cf)) = db.ctuf(isnan(db.cf));
    db = removevars(db, ["ctdt","ctds","ctdf","ctut","ctus","ctuf"]);
    dispnames.db.ct = ['CTD temp at ' dstr ' dbar'];
    dispnames.db.cs = ['CTD psal at ' dstr ' dbar'];
    dispnames.db.cf = ['CTD fluor at ' dstr ' dbar'];
end
%***temporary: dy180 fluor sample file has duplicate times, exclude (cruise
%option***)
if strcmp('dy180',mcruise)
    db(~isnan(db.chl),:) = []; %will need to reload anyway because without the correct times the ctd data aren't being extracted for these points (they all appear to be at midnight)
end

%tsg data
[dt, ht] = mload(tsgfile,'/');
dt = struct2table(dt);
% guess variable name for each parameter from list of known common names
salvar = munderway_varname('salvar',ht.fldnam,1,'s');
temph = munderway_varname('tempvar',ht.fldnam,1,'s'); %housing
tempin = munderway_varname('sstvar',ht.fldnam,1,'s'); %remote
%tempsst = munderway_varname('sstvar',setdiff(ht.fldnam,tempin),1,'s'); %sst (what about dk?)
fluovar = 'fluo'; %doesn't seem to vary in tsg file? if it does, add to munderway_varname
%don't bother if we don't have any data
m = ~isnan(dt.(temph)) | ~isnan(dt.(tempin)); %if ~isempty(tempsst); m = m | ~isnan(dt.(tempsst)); end
dt = dt(m,:);
%define display names
dispnames.dt.(temph) = ['TSG housing temp (' temph ')'];
dispnames.dt.(tempin) = ['UCSW intake temp (' tempin ')'];
dispnames.dt.(salvar) = ['TSG salinity (' salvar ')'];
dispnames.dt.(fluovar) = ['TSG fluorescence (' fluovar ')'];

%interpolate TSG variables to match calibration data
ivars = {temph,tempin,salvar,fluovar};
for no = 1:length(ivars)
    db.(ivars{no}) = interp1(dt.dday, dt.(ivars{no}), db.dday);
    dispnames.db.(ivars{no}) = dispnames.dt.(ivars{no});
end


%%%%% compare data %%%%%

%find where system was disturbed, so calibration likely to change
tbreak = find_cleaning(dt, temph);


%make comparison plots, flag points not to include in comparison, and
%calculate fits/smoothed differences
%plt.xl = dt.dday(~isnan(dt.(tempin))); plt.xl = [min(plt.xl) max(plt.xl)];
plt.xl = [min(db.dday)-1/24/60 max(db.dday)+1/24/60];
plt.pcolors = [.5 0 0; 1 0 .8; .5 0 .5; 0 0 0];
plt.psym = ['>';'^';'p';'o'];
plt.bigm = 8; %default markersize is 6

if comp2ctd
    % compare TSG and CTD temp
    figure(1); clf
    clear pdata
    pdata.extra = {temph, 'c', '--'};
    pdata.ts = temph;
    if sepdownup
        pdata.points = {'ctut', 'CTDu-UCSWin';...
            'ctdt', 'CTDd-UCSWin'}; %prefer downcast, so make this last
    else
        pdata.points = {'ct', 'CTD-UCSWin'};
    end
    plt.ylab = {'T (degC)';'T difference'};
    cst = plotuc(dt, db, dispnames, pdata, plt, tbreak, []);
end

if comp2ctd || bsal
    % plot TSG and bottle salinity data %add flow rate?***
    figure(2); clf
    clear pdata
    pdata.ts = salvar;
    if comp2ctd && sepdownup
        pdata.points = {'ctus', 'CTDu-TSG';...
            'ctds', 'CTDd-TSG'};
    else
        pdata.points = {'cs', 'CTD-TSG'};
    end
    if bsal
        %prefer to compare to bottles, so make this last
        pdata.points = [pdata.points; 'salinity_adj', 'Bottle-TSG'];
    end
    plt.ylab = {'S (psu)';'S difference'};
    css = plotuc(dt, db, dispnames, pdata, plt, tbreak, []);
end

if comp2ctd || bchl %note if CTD is calibrated or not
    % compare TSG and CTD and bottle fluor
    figure(3); clf
    clear pdata
    pdata.ts = fluovar;
    if comp2ctd && sepdownup
        pdata.points = {'ctuf', 'CTDu-UCSW';...
            'ctdf', 'CTDd-UCSW'};
    else
        pdata.points = {'cf', 'CTD-UCSW'};
    end
    if bchl
        %prefer to compare to bottles
        pdata.points = [pdata.points; 'chl', 'Bottle-UCSW'];
    end
    plt.ylab = {'Chl (ug/ml)';'Chl difference'};
    %find too-much-light points, to be excluded
    [dr, ~] = mload(atmfile,'/');
    ll = 0.1e7; %cruise option? depends on calibration of sensors? ***check ctd samples taken?
    db.par = interp1(dr.dday,dr.parport+dr.parstarboard,db.dday)/2;
    mbad = db.par>ll;
    csf = plotuc(dt, db, dispnames, pdata, plt, tbreak, mbad);
end

keyboard
%add overall smoothed and trends***

printdir = fullfile(MEXEC_G.mexec_data_root,'plots');
printform = '-dpdf';
print(printform,fullfile(printdir,['tsg_bottle_' mcruise]));

if 0%***
    save(fullfile(root_tsg,'sdiffsm'), 'cst', 'css', 'csf'); mfixperms(fullfile(root_tsg,'sdiffsm'));
end


%%%%% subfunctions %%%%%

function tbreak = find_cleaning(dt, temph)
% set breakpoints for fitting/smoothed differences any time tsg was not
% running (tbreaks) to allow for cleaning
tbreak = [];
opt1 = 'uway_proc'; opt2 = 'tsg_ddaybreaks'; get_cropt; %maybe cleaning times were recorded!***how to use
%check and look for more
dgood = dt.dday(~isnan(dt.(temph)));
d = diff(dgood);
djump = dgood(d>15/60/24); %15 minutes too short to need to break the fit?
djump_more = dgood(d>5/60/24);
djump = djump(:)'; djump_more = djump_more(:)';
figure(10); clf
subplot(211)
yl = [min(dt.(temph)) max(dt.(temph))]';
plot(dt.dday,dt.(temph),repmat(djump_more,2,1),repmat(yl,1,length(djump_more)),'--',repmat(djump,2,1),repmat(yl,1,length(djump)))
axis tight; grid; ylabel(temph); xlabel('decimal day'); title('breaks')
subplot(212)
dday = repmat(dt.dday(:),1,length(djump)) - repmat(djump,length(dt.dday),1);
t = repmat(dt.(temph)(:),1,length(djump));
ddaym = repmat(dt.dday(:),1,length(djump_more)) - repmat(djump_more,length(dt.dday),1);
tm = repmat(dt.(temph)(:),1,length(djump_more));
plot(ddaym*24*60, tm, '--', dday*24*60, t); xlim([-60 60*2])
xlabel('minutes from break'); ylabel(temph); grid
tbreak = djump+.5/60/24;
disp('breaks at:')
fprintf(1,'%f ',tbreak); fprintf(1,'\n')
a = input('accept suggested [solid] (y) or change (n)? ','s');
if strcmp('n',a)
    disp('modify tbreak')
    keyboard
end
tbreak = [-inf tbreak inf];


function cs = plotuc(dt, db, dispnames, pdata, plt, tbreak, mbad)

uvar = pdata.ts; %underway (TSG) variable
cvar = pdata.points{end,1}; %main comparison parameter (the last one to be plotted), will be passed to flagsdiffs

%make initial plot

%time series with comparison points
ha(1) = subplot(211);
hl = [];
if isfield(pdata, 'extra')
    hl = plot(dt.dday, dt.(pdata.extra{1}), 'color', pdata.extra{2}, 'linestyle', pdata.extra{3}, 'DisplayName', dispnames.dt.(pdata.extra{1}));
    hold on
end
hl = [hl plot(dt.dday, dt.(uvar), 'b', 'DisplayName', dispnames.db.(uvar))]; hold on
np = size(pdata.points,1);
for no = 1:np
    hp(no) = plot(db.dday, db.(pdata.points{no,1}), 'linestyle', 'none', 'color', plt.pcolors(no,:), 'marker', plt.psym(no), 'DisplayName', dispnames.db.(pdata.points{no,1}));
end
hp(end).MarkerSize = plt.bigm; %last one is the main one
xlabel('decimal day'); ylabel(plt.ylab{1}); grid; axis tight; xlim(plt.xl)
%add tbreak vertical lines
yl = ha(1).YLim'; plot(repmat(tbreak,2,1), repmat(yl,1,length(tbreak)));
legend([hl hp])

%differences
ha(2) = subplot(212);
for no = 1:np
    hd(no) = plot(db.dday, db.(pdata.points{no,1})-db.(uvar), 'linestyle', 'none', 'color', plt.pcolors(no,:), 'marker', plt.psym(no), 'DisplayName', pdata.points{no,2}); hold on
end
hd(end).MarkerSize = plt.bigm; %last one is the main one
xlabel('decimal day'); ylabel(plt.ylab{2}); grid; axis tight; xlim(plt.xl)
%add tbreak vertical lines
yl = ha(2).YLim'; plot(repmat(tbreak,2,1), repmat(yl,1,length(tbreak)));
legend(hd)

linkaxes(ha,'x')

%get smoothed differences, using the last-plotted parameter
trange = dt.dday(~isnan(dt.(uvar))); trange = [min(trange) max(trange)]; %range of good TSG data
[cs.flags, cs.diffsm, cs.diffseg, cs.cseg] = flagsdiffs(db, uvar, cvar, tbreak, mbad, trange);
cs.readme = {'diffsm: smoothed differences';
    'diffseg: median differences over each segment after excluding outliers';
    'trseg: trends in each segment''s differences after excluding outliers';
    'cseg: coefficients of above, [b; m] in mx+b'};

%add to plot
axes(ha(2))
hlsd(1) = plot(db.dday, cs.diffsm, 'DisplayName', ['smoothed difference ' pdata.points{end,2}]);
hlsd(2) = plot(dt.dday, interp1(db.dday,cs.diffseg,dt.dday,'nearest'), 'DisplayName', 'segment medians', 'linestyle', '--');
for kseg = 1:length(tbreak)-1
    t = dt.dday(dt.dday>tbreak(kseg) & dt.dday<=tbreak(kseg+1));
    hlsd(kseg+2) = plot(t, [ones(length(t),1) t]*cs.cseg(:,kseg), 'DisplayName', 'segment trends', 'linestyle', '-.', 'color', 'k');
end
h = [hd hlsd(1:3)];
fm = 3;
if sum(cs.flags>fm)
    %overplot flagged points in gray
    hlb = plot(db.dday(cs.flags>fm), db.(cvar)(cs.flags>fm)-db.(uvar)(cs.flags>fm), 'color', [.6 .6 .6], 'marker', hd(end).Marker, 'markersize', hd(end).MarkerSize, 'linestyle', 'none', 'DisplayName', 'flagged, excluded from above');
    h = [h hlb];
end
legend(h,'location','southwest')


function [flags, sdiffsm, pl, trcseg_all] = flagsdiffs(db, uvar, cvar, tbreak, mbad, trange)
%compare underway data in uvar with calibration data in cvar field of db

% List and discard possible outliers
flags = 2+zeros(size(db.dday));
if ~isempty(mbad) && sum(mbad)
    flags(mbad) = 4;
    db.(uvar)(mbad) = NaN; %***
end
sdiff = db.(cvar) - db.(uvar);
sdiff_std = m_nanstd(sdiff);
sdiff_median = m_nanmedian(sdiff);
idx = find(abs(sdiff-sdiff_median)>3*sdiff_std); 
if ~isempty(idx)
    fprintf(1,'\n Std deviation of differences between comparison data (%s) and TSG/UCSW sensor is %7.3f \n',cvar,sdiff_std)
    fprintf(1,' The following are outliers to be checked: \n')
    fprintf(1,' Sample - dday time    Difference  \n')
    for ii = idx(:)'
        jdx = floor(db.dday(ii));
        fprintf(1,'  %2d  -  %d  %s  %7.3f \n',ii,jdx,datestr(db.dday(ii),15),sdiff(ii))
    end
    a = input('exclude the listed points from the comparison (enter) or keyboard (k) ','s');
else
    a = input('keyboard to set points to exclude from the comparison (k) or enter to continue? ','s');
end
if strcmp('k',a)
    disp('set indices of bad points, idx')
    keyboard
end
sdiff(idx) = NaN; % set values where value>3*SD as NaN
flags(idx) = 4; %may not be bad bottles just bad comparisons, but these are "definitely" bad

%now break into segments and compute smoothed differences
nseg = length(tbreak)-1;
t_all = [];
sdiffsm_all = []; sdiffseg_all = []; trseg_all = [];
trcseg_all = nan(2,nseg);
sc1 = 0.5; sc2 = 0.02;
opt1 = 'uway_proc'; opt2 = 'tsg_sdiff'; get_cropt
if ~exist('sdiffsm','var') %if set in opt_cruise, overrides the below
    for kseg = 1:nseg
        tstart = tbreak(kseg)+1/86400;
        tend = tbreak(kseg+1)-1/86400;
        kbottle = find(db.dday > tstart & db.dday < tend);
        % work out if interval is before or after start of tsg data (and select
        % the later of the 2 start ddays and earlier of the 2 end ddays)
        t0 = max([tstart trange(1)]); % tstart, or start of tsg data
        t1 = min([tend trange(2)]); % tend or end of tsg data

        t = [t0; db.dday(kbottle); t1];
        sdiffseg = [nan; sdiff(kbottle); nan]; % pad this set of ddays with two nans for the pseudo ddays
        % need values for sdiff at the start and end point (for interpolation)
        % such that there will definitely be a tsg dday less and more than the
        % bottle dday for all bottle ddays

        %smoothed difference--default is a two-pass filter on the whole
        %series (should replace with a constant time
        %window filter rather than a constant number of points filter
        %as for everything except bottle salinity in some cases the time
        %distribution of comparison points is likely to be uneven)***
        sdiffsm = filter_bak(ones(1,21),sdiffseg); % first filter
        sdiffseg(abs(sdiffseg-sdiffsm) > sc1) = NaN;
        sdiffsm = filter_bak(ones(1,21),sdiffseg); % harsh filter to determine smooth adjustment
        sdiffseg(abs(sdiffseg-sdiffsm) > sc2) = NaN;
        sdiffsm = filter_bak(ones(1,21),sdiffseg); % harsh filter to determine smooth adjustment
        sdiffsm_all = [sdiffsm_all; sdiffsm];
        t_all = [t_all; t];
        %median in each segment
        sdiffseg_all = [sdiffseg_all; repmat(median(sdiffseg,'omitnan'),length(t),1)];
        %trends in each segment
        r = [ones(length(t),1) t];
        %b = regress(sdiff(~isnan(sdiff)),r(~isnan(sdiff),:));
        bs = regress(sdiffsm(~isnan(sdiffseg)),r(~isnan(sdiffseg),:));
        trcseg_all(:,kseg) = bs;
        %flags
        ii = kbottle(isnan(sdiffseg(2:end-1)));
        flags(ii) = max(3,flags(ii)); %these may not be as far out
    end
    if ~sum(~isnan(sdiffsm_all))
        warning('smoothing excluding all points from %s, adjust sc1 and sc2 in opt_cruise?',uvar)
    end
    sdiffsm = interp1(t_all(~isnan(sdiffsm_all)),sdiffsm_all(~isnan(sdiffsm_all)),db.dday);
    sdiffseg = interp1(t_all(~isnan(sdiffseg_all)),sdiffseg_all(~isnan(sdiffseg_all)),db.dday);

    r = [ones(length(db.dday),1) db.dday];
    b = regress(sdiff(~isnan(sdiff)),r(~isnan(sdiff),:));
    bs = regress(sdiffsm(~isnan(sdiffsm)),r(~isnan(sdiffsm),:));
    disp('mean diff, median diff, RMS diff, offset and trend')
    disp([m_nanmean(sdiff) m_nanmedian(sdiff) sqrt(sum(sdiff(~isnan(sdiff)).^2)/sum(~isnan(sdiff))) b'])
    disp('from smoothed data:')
    disp([m_nanmean(sdiffsm) m_nanmedian(sdiffsm) sqrt(sum(sdiffsm(~isnan(sdiffsm)).^2)/sum(~isnan(sdiffsm))) bs'])

    disp('choose a constant or simple dday-dependent correction for TSG, add to ')
    disp('uway_proc, tsg_cals case in opt_cruise (to be applied to _edt variable(s))')
    disp('(or set it so it uses the smooth function shown here, but be cautious if the comparison is to CTD rather than UCSW bottle samples!)')
end
