function mtsg_bottle_ctd_compare(varargin)
% mtsg_bottle_ctd_compare(dintake)
% mtsg_bottle_ctd_compare(dintake, sepdownup)
% mtsg_bottle_ctd_compare(dintake, sepdownup, reload_cal)
% mtsg_bottle_ctd_compare(dintake, sepdownup, reload_cal, usecal, printsuf)
%
% compare TSG/underway data from the merged, 1-min averaged surface_ocean
% file with bottle parameters (salinity and/or fluorescence, where
% available) and (optionally) near-surface CTD temperature and salinity
% from near intake depth dintake, examining down and upcast data separately
% if sepdownup
% comparison/calibration data (including, optionally, CTD data) are saved
% in uway_cal_data.mat and if reload_cal is set to 0 they are loaded from
% this file, otherwise (default) they are reloaded from tsgsal, ucswchl,
% and ctd files
% if printsuf is not empty, comparison figures are printed to .png; use
% printsuf to save files as '*_uncal.png' or '*_3dbar.png' etc.
%
% e.g.
% mtsg_bottle_ctd_compare(3, 0, 0, 'uncal')


m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING; % cruise name (from MEXEC_G global)

v = {3, 0, 1, 1, ''};
v(1:nargin) = varargin(1:nargin);
[dintake, sepdownup, reload_cal, usecal, printsuf] = varargin{:};
if dintake>0
    comp2ctd = 1;
else
    comp2ctd = 0;
end


%%%%% load data %%%%%

sdir = fullfile(MEXEC_G.mexec_data_root,'met');
tsgfile = fullfile(MEXEC_G.mexec_data_root,'met',['surface_ocean_' mcruise '.nc']);
atmfile = fullfile(MEXEC_G.mexec_data_root,'met',['surfmet_' mcruise '_all_edt.nc']);
salfile = fullfile(mgetdir('M_BOT_SAL'),['tsgsal_' mcruise '_all.nc']);
chlfile = fullfile(mgetdir('M_BOT_CHL'),['ucswchl_' mcruise '_all.nc']);
cdatafile = fullfile(MEXEC_G.mexec_data_root,'bottle_samples','uway_cal_data'); %save here

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
        dstr = num2str(dintake);
        dispnames.db.tctdd = ['CTD (down) temp at ' dstr ' dbar'];
        dispnames.db.tctdu = ['CTD (up) temp at ' dstr ' dbar'];
        dispnames.db.sctdd = ['CTD (down) psal at ' dstr ' dbar'];
        dispnames.db.sctdu = ['CTD (up) psal at ' dstr ' dbar'];
        dispnames.db.fctdd = ['CTD (down) fluor at ' dstr ' dbar'];
        dispnames.db.fctdu = ['CTD (up) fluor at ' dstr ' dbar'];
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
    db.tctd = db.tctdd; db.tctd(isnan(db.tctd)) = db.tctdu(isnan(db.tctd));
    db.sctd = db.sctdd; db.sctd(isnan(db.sctd)) = db.sctdu(isnan(db.sctd));
    db.fctd = db.fctdd; db.fctd(isnan(db.fctd)) = db.fctdu(isnan(db.fctd));
    db = removevars(db, ["tctdd","sctdd","fctdd","tctdu","sctdu","fctdu"]);
    dispnames.db.tctd = ['CTD temp at ' dstr ' dbar'];
    dispnames.db.sctd = ['CTD psal at ' dstr ' dbar'];
    dispnames.db.fctd = ['CTD fluor at ' dstr ' dbar'];
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
if usecal
    if sum(strcmp([tempin '_cal'],ht.fldnam)); tempin = [tempin '_cal']; end
    if sum(strcmp([salvar '_cal'],ht.fldnam)); salvar = [salvar '_cal']; end
    if sum(strcmp([fluovar '_cal'],ht.fldnam)); fluovar = [fluovar '_cal']; end
end
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

if comp2ctd
    dotemp = 1;
end
if comp2ctd || bsal
    dosal = 1;
end
if comp2ctd || bchl
    dochl = 1;
end

%make comparison plots, flag points not to include in comparison, and
%calculate fits/smoothed differences
%plt.xl = dt.dday(~isnan(dt.(tempin))); plt.xl = [min(plt.xl) max(plt.xl)];
plt.xl = [min(db.dday)-1/24/60 max(db.dday)+1/24/60];
plt.pcolors = [.5 0 0; 1 0 .8; .5 0 .5; 0 0 0];
plt.psym = ['>';'^';'p';'o'];
plt.bigm = 8; %default markersize is 6

if dotemp
    % compare TSG and CTD temp
    figure(1); clf
    clear pdata
    pdata.extra = {temph, 'c', '--'};
    pdata.ts = tempin;
    if sepdownup
        pdata.points = {'tctdu', 'CTDu-UCSWin';...
            'tctdd', 'CTDd-UCSWin'}; %prefer downcast, so make this last
    else
        pdata.points = {'tctd', 'CTD-UCSWin'};
    end
    if ~isempty(printsuf)
        plt.pname = fullfile(sdir,sprintf('underway_%s_%s_%s.png',pdata.ts,pdata.points{end,1},printsuf));
    end
    plt.ylab = {'T (degC)';'T difference'};
    cst = plotuc(dt, db, dispnames, pdata, plt, tbreak);
end

if dosal
    % plot TSG and bottle salinity data %add flow rate?***
    figure(2); clf
    clear pdata
    pdata.printsuf = printsuf;
    pdata.ts = salvar;
    if comp2ctd && sepdownup
        pdata.points = {'sctdu', 'CTDu-TSG';...
            'sctdd', 'CTDd-TSG'};
    else
        pdata.points = {'sctd', 'CTD-TSG'};
    end
    if bsal
        %prefer to compare to bottles, so make this last
        pdata.points = [pdata.points; 'salinity_adj', 'Bottle-TSG'];
    end
    plt.ylab = {'S (psu)';'S difference'};
    if ~isempty(printsuf)
        plt.pname = fullfile(sdir,sprintf('underway_%s_%s_%s.png',pdata.ts,pdata.points{end,1},printsuf));
    end
    css = plotuc(dt, db, dispnames, pdata, plt, tbreak);
end

if dochl %note if CTD is calibrated or not
    % compare TSG and CTD and bottle fluor
    figure(3); clf
    %also plot par
    [dr, ~] = mload(atmfile,'/');
    dt.par = interp1(dr.dday,dr.parport+dr.parstarboard,dt.dday)/2/1e7;
    dispnames.dt.par = 'PAR/1e7 (allowed<0.1)';
    db.par = interp1(dt.dday,dt.par,db.dday);
    ll = 0.1; %cruise option? does this depend on sensor cal?***
    clear pdata
    pdata.extra = {'par', 'c', '--'};
    pdata.ts = fluovar;
    if comp2ctd && sepdownup
        pdata.points = {'fctdu', 'CTDu-UCSW';...
            'fctdd', 'CTDd-UCSW'};
    else
        pdata.points = {'fctd', 'CTD-UCSW'};
    end
    if bchl
        %prefer to compare to bottles
        pdata.points = [pdata.points; 'chl', 'Bottle-UCSW'];
    end
    if ~isempty(printsuf)
        plt.pname = fullfile(sdir,sprintf('underway_%s_%s_%s.png',pdata.ts,pdata.points{end,1},printsuf));
    end
    plt.ylab = {'Chl (ug/ml)';'Chl ratio'};
    %find too-much-light points, to be excluded
    mbad = db.par>ll;
    if ~isempty(mbad) && sum(mbad)
        db.(pdata.ts)(mbad) = NaN;
    end
    csf = plotuc(dt, db, dispnames, pdata, plt, tbreak);
end

keyboard

if 0%***
    save(fullfile(sdir,'sdiffsm'), 'cst', 'css', 'csf'); mfixperms(fullfile(sdir,'sdiffsm'));
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
djump_more = dgood(d>5/60/24 & d<=15/60/24);
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


function cs = plotuc(dt, db, dispnames, pdata, plt, tbreak)

uvar = pdata.ts; %underway (TSG) variable
cvar = pdata.points{end,1}; %main comparison parameter (the last one to be plotted), will be passed to mdiffs
flags = 2+zeros(size(db.dday));
flags(isnan(db.(uvar))) = 4;

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

%differences or ratios
if strcmp(uvar,'fluo')
    useratio = 1;
else
    useratio = 0;
end
ha(2) = subplot(212);
for no = 1:np
    if useratio
        y = db.(pdata.points{no,1})./db.(uvar);
    else
        y = db.(pdata.points{no,1})-db.(uvar);
    end
    hd(no) = plot(db.dday, y, 'linestyle', 'none', 'color', plt.pcolors(no,:), 'marker', plt.psym(no), 'DisplayName', pdata.points{no,2}); hold on
end
hd(end).MarkerSize = plt.bigm; %last one is the main one
xlabel('decimal day'); ylabel(plt.ylab{2}); grid; axis tight; xlim(plt.xl)
%add tbreak vertical lines
yl = ha(2).YLim'; plot(repmat(tbreak,2,1), repmat(yl,1,length(tbreak)));
legend(hd)

linkaxes(ha,'x')

%get smoothed differences, using the last-plotted parameter

%thresholds for differences
th4 = 3; %3*stdev different from median -- bad flag of 4
if useratio
    sdiff = db.(cvar)./db.(uvar);
else
sdiff = db.(cvar) - db.(uvar);
end
sc1 = 0.5; %absolute difference relative to median -- bad flag of 3, excluded from smoothing
sc2 = 0.02; %absolute difference relative to first-pass smoothed -- exclude from second pass
opt1 = 'uway_proc'; opt2 = 'tsg_sdiff'; get_cropt

% List and discard possible major outliers
sdiff_test = sdiff; id0 = find(flags==4);
for r = 1:3
    sdiff_std = std(sdiff_test,'omitmissing');
    sdiff_median = median(sdiff_test,'omitmissing');
    idx = find(abs(sdiff_test-sdiff_median)>th4*sdiff_std);
    sdiff_test(idx) = NaN;
end
idx = setdiff(find(isnan(sdiff_test)),id0);
if ~isempty(idx)
    fprintf(1,'\n Std deviation of differences between comparison data (%s) and TSG/UCSW sensor is %7.3f \n',cvar,sdiff_std)
    fprintf(1,' The following are outliers to be checked: \n')
    fprintf(1,' Sample - dday time    Difference  \n')
    for bii = idx(:)'
        jdx = floor(db.dday(bii));
        fprintf(1,'  %2d  -  %d  %s  %7.3f \n',bii,jdx,datestr(db.dday(bii),15),sdiff(bii))
    end
    a = input('exclude the listed points from the comparison (enter) or keyboard (k) ','s');
else
    a = input('no points found to exclude from the comparison; keyboard to set some (k) or enter to continue ','s');
end
if strcmp('k',a)
    disp('set indices of bad points, idx')
    keyboard
end
if ~isempty(idx)
    db.(cvar)(idx) = NaN; % set values where value>3*SD as NaN
    db.(uvar)(idx) = NaN;
    sdiff(idx) = NaN;
    flags(idx) = 4; %may not be bad bottles just bad comparisons, but these are "definitely" bad
    %replot
    delete(hd)
for no = 1:np
    if useratio
        y = db.(pdata.points{no,1})./db.(uvar);
    else
        y = db.(pdata.points{no,1})-db.(uvar);
    end
    hd(no) = plot(db.dday, y, 'linestyle', 'none', 'color', plt.pcolors(no,:), 'marker', plt.psym(no), 'DisplayName', pdata.points{no,2}); hold on
end
    hd(end).MarkerSize = plt.bigm; %last one is the main one
    xlabel('decimal day'); ylabel(plt.ylab{2}); grid on; axis tight; xlim(plt.xl)
    %add tbreak vertical lines
    yl = ha(2).YLim'; plot(repmat(tbreak,2,1), repmat(yl,1,length(tbreak)));
    legend(hd)
end

%now break into segments and compute smoothed differences, plus for a
%segment containing the whole series
tsb = [tbreak(1:end-1)' tbreak(2:end)']; 
tsb = [tsb; -Inf Inf];
nseg = size(tsb,1);
cs.smd = NaN+dt.dday;
cs.smd_all = cs.smd;
cs.trsmdseg = cs.smd;
cs.msmdseg = cs.smd;
cs.csmdseg = nan(2,nseg);
sint = 0.5/24/60; %interpolate to 30 s
per = round(24/24/sint); if per/2==floor(per/2); per = per-1; end
for kseg = 1:nseg
    tstart = tsb(kseg,1)+sint;
    tend = tsb(kseg,2)-sint;
    kbottle = find(db.dday > tstart & db.dday < tend);
    ksens = find(dt.dday > tstart & dt.dday < tend);
    if isscalar(kbottle)
        cs.smd(ksens) = sdiff(kbottle);
        cs.msmdseg(ksens) = sdiff(kbottle);
        cs.trsmdseg(ksens) = sdiff(kbottle);
        continue
    elseif isempty(kbottle)
        continue
    end

    %flag questionable based on first parameter-specific (possibly
    %cruise-specific) thresholds
    mb = abs(sdiff(kbottle)-median(sdiff(kbottle),'omitmissing'))>sc1;
    flags(kbottle(mb)) = max(flags(kbottle(mb)),3);
    sdiff(kbottle(mb)) = NaN;

    %interpolate to even spacing and filter
    m = flags(kbottle)==2;
    sdiffseg = interp1(db.dday(kbottle(m)),sdiff(kbottle(m)), dt.dday(ksens));
    sdf = filter_bak(ones(1,per),sdiffseg);

    %check for outliers and interpolate over them, then redo filter
    mb = abs(sdiffseg-sdf)>sc2;
    sdiffseg(mb) = interp1(find(~mb),sdiffseg(~mb),find(mb));
    sdf = filter_bak(ones(1,per),sdiffseg);
    
    %fill to edges of segment
    mb = isnan(sdf);
    sdf(mb) = interp1(find(~mb),sdf(~mb),find(mb),'nearest','extrap');

    if kseg==nseg
        cs.smd_all = sdf;
    else
        cs.smd(ksens) = sdf;
    %compute median of smoothed segment
    cs.msmdseg(ksens) = median(sdf);
    %map back to bottle points and compute trend
    s = interp1(dt.dday(ksens),sdf,db.dday(kbottle));
    mb = isnan(s);
    s(mb) = interp1(find(~mb),s(~mb),find(mb),'nearest','extrap');
    %compute trend coefficients of segment
    cs.csmdseg(:,kseg) = regress(s,[ones(length(kbottle),1) db.dday(kbottle)]);
    %and trend series for segment
    cs.trsmdseg(ksens) = [ones(length(ksens),1) dt.dday(ksens)]*cs.csmdseg(:,kseg);
    end

end

%median of smoothed series, and trend based on bottle times
cs.msmd_all = median(cs.smd_all);
s = interp1(dt.dday, cs.smd_all, db.dday);
cs.csmd_all = regress(s,[ones(length(s),1) db.dday]);
cs.trsmd_all = [ones(length(dt.dday),1) dt.dday]*cs.csmd_all;
%median of concatenated smoothed segment series, and trend based on bottle times
cs.msmd = median(cs.smd,'omitnan');
s = interp1(dt.dday, cs.smd, db.dday);
mb = isnan(s);
s(mb) = interp1(find(~mb),s(~mb),find(mb),'nearest','extrap');
cs.csmd = regress(s,[ones(length(s),1) db.dday]);
cs.trsmd = [ones(length(dt.dday),1) dt.dday]*cs.csmd;

cs.diffs = sdiff;
cs.flags = flags;
cs.readme = {'diffs: differences between underway and bottle/ctd comparion points';
    'smd_all: smoothed differences';
    'msmdseg: median differences for each smoothed segment';
    'smd: concatenated smoothed segment differences';
    'trsmd*: trend, csmd* coefficients of trend ([b;m] from mx+b)'};

%add to plot
axes(ha(2)); hold on
hlsd(2) = plot(dt.dday, cs.smd, 'DisplayName', ['segment smoothed difference ' pdata.points{end,2}], 'color', [0 0 1], 'linewidth', 2);
hlsd(1) = plot(dt.dday, cs.smd_all, 'DisplayName', ['smoothed difference ' pdata.points{end,2}], 'color', [1 0 0], 'linewidth', 2);
hlsd(3) = plot(dt.dday, cs.msmdseg, 'DisplayName', 'segment medians', 'linestyle', '--');
nd = length(hlsd);
for kseg = 1:length(tbreak)-1
    %plot in different colors
    t = dt.dday(dt.dday>tbreak(kseg) & dt.dday<=tbreak(kseg+1));
    hlsd(kseg+nd) = plot(t, [ones(length(t),1) t]*cs.csmdseg(:,kseg), 'DisplayName', 'segment trends', 'linestyle', '-.', 'color', 'k');
end
h = [hd hlsd(1:4)];
hlt = plot(dt.dday, [ones(length(dt.dday),1) dt.dday]*cs.csmd, 'DisplayName', 'trend', 'linestyle', ':', 'color', 'k');
h = [h hlt];
fm = 2;
if sum(cs.flags>fm)
    %overplot flagged points in gray
    hlb = plot(db.dday(cs.flags>fm), db.(cvar)(cs.flags>fm)-db.(uvar)(cs.flags>fm), 'color', [.6 .6 .6], 'marker', hd(end).Marker, 'markersize', hd(end).MarkerSize, 'linestyle', 'none', 'DisplayName', 'flagged 3, excluded from smoothing');
    h = [h hlb];
end
legend(h)

disp('choose a constant or simple dday-dependent correction for TSG, add to ')
disp('uway_proc, tsg_cals case in opt_cruise (to be applied to _edt variable(s))')
disp('(or set it so it uses an extrapolation of the smooth function shown here, but be cautious with this if the comparison is to CTD or to few UCSW bottle samples!)')
if isfield(plt,'pname')
    pstr = [' before printing to ' plt.pname ' '];
else
    pstr = '';
end
a = input(sprintf('keyboard (k) to inspect/modify plot%s,\n or enter to continue  ',pstr),'s');
if strcmp(a,'k')
    keyboard
end
if isfield(plt,'pname')
    print('-dpng',plt.pname)
end

