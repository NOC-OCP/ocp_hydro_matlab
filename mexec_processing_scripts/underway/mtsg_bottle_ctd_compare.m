% compare TSG/underway data from the merged, 1-min averaged surface_ocean
% file with bottle paramters (salinity) and (optionally) near-surface CTD
% data
% 

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING; % cruise name (from MEXEC_G global)

comp2ctd = true ; % set to false if you don't want to compare to CTD data

if comp2ctd==true
    updownboth = 'both' ; %'up' %'down'

    % set a variable for the CTD salinity variable to look at (currently psal
    % but could make it variable...) 
    ctd_sal_var = 'psal';
    ctd_temp_var = 'temp';

    %***fluo etc.

end 

roottsg = fullfile(MEXEC_G.mexec_data_root,'met');
rootsal = mgetdir('M_BOT_SAL'); %***
rootctd = mgetdir('M_CTD');

[dt, ht] = mload(fullfile(roottsg, ['surface_ocean_' mcruise '.nc']),'/');
% obtains variable names for each parameter from ht and list of known
% common variable names for that parameter
salvar = munderway_varname('salvar',ht.fldnam,1,'s');
tempvar = munderway_varname('tempvar',ht.fldnam,1,'s');
tempsst = munderway_varname('sstvar',ht.fldnam,1,'s');
condvar = munderway_varname('condvar',ht.fldnam,1,'s');
%***fluo etc.

[db, hb] = mload(fullfile(rootsal, ['tsgsal_' mcruise '_all.nc']),'/');
%sort all variables in case bottle salinities not in order
[a, iibot] = sort(db.time);
fn = fieldnames(db);
for fno = 1:length(fn)
    db.(fn{fno}) = db.(fn{fno})(iibot);
end

%put bottle ddays in dday
db.dday = m_commontime(db, 'time', hb, ht.fldunt(strcmp('dday',ht.fldnam)));
bdelay = 1/1440; %delay bottles by 1 minute to allow for dday between bottle being drawn and passing through TSG?
%get_cropt***
db.dday = db.dday-bdelay;

%convert to conductivity at TSG housing temp
db.htemp = interp1(dt.dday, dt.temph, db.dday);
db.cond = gsw_C_from_SP(db.salinity_adj, db.htemp, 0);
db.tsgcond = interp1(dt.dday, dt.(condvar), db.dday);
db.tsgsal = interp1(dt.dday, dt.(salvar), db.dday);
db.stemp = interp1(dt.dday, dt.(tempsst), db.dday);

%also use SST as x-axis
nsp = 2;
if exist('tempsst','var') && ~isempty(tempsst)
    db.tsst = interp1(dt.dday, dt.(tempsst), db.dday);
    nsp = 4;
end

opt1 = 'botpsal'; opt2 = 'tsg_bad'; get_cropt %NaN some of the db.salinity_adj points

crat = db.cond./db.tsgcond;
sdiff = db.salinity_adj - interp1(dt.dday, dt.salinity, db.dday);
sdiff_std = m_nanstd(sdiff); sdiff_mean = m_nanmean(sdiff);
idx = find(abs(sdiff-sdiff_mean)>3*sdiff_std); % bak dy146 sdiff-sdiff_mean ?
% List and discard possible outliers
if ~isempty(idx)
	fprintf(1,'\n Std deviation of bottle tsg - differnces is %7.3f \n',sdiff_std)
	fprintf(1,' The following are outliers to be checked: \n')
	fprintf(1,' Sample  Jday dday    Difference  \n')
	for ii = idx(:)'
		jdx = floor(db.dday(ii));
		fprintf(1,'  %2d  -  %d  %s  %7.3f \n',ii,jdx,datestr(db.dday(ii),15),sdiff(ii))
	end
end
sdiffall = sdiff;
sdiff(idx) = NaN; % set values where value>3*SD as NaN
crat(idx) = NaN;

% set breakpoints for sdiffsm anydday tsg was not running (tbreaks) to
% allow for cleaning 
tbreak = []; 
opt1 = mfilename; opt2 = 'tsg_ddaybreaks'; get_cropt;
if ~isempty(tbreak)
    tbreak = m_commondday(tbreak,'datenum',tun);
end
tbreak = [-inf; tbreak; inf];
nseg = length(tbreak)-1;

sdiffsm_all = [];
t_all = [];
sdiffsave = sdiff;
for kseg = 1:nseg % segments; always at least 1; if tbreak started empty, then there is one segment
    tstart = tbreak(kseg)+1/86400;
    tend = tbreak(kseg+1)-1/86400;
    
    kbottle = find(db.dday > tstart & db.dday < tend);
    sdiff = sdiffsave(kbottle);
    
    % add start and end ddays as pseudo ddays of bottles, so there will
    % always be a smoothed adjustment for interpolation
    
    t = db.dday(kbottle)-1;
    
    % work out if interval is before or after start of tsg data (and select
    % the later of the 2 start ddays and earlier of the 2 end ddays)
    t0 = max([tstart min(dt.dday-1)]); % tstart, or start of tsg data
    t1 = min([tend max(dt.dday-1)]); % tend or end of tsg data
    t = [t0; t; t1];
    sdiff = [nan; sdiff; nan]; % pad this set of ddays with two nans for the pseudo ddays
    % need values for sdiff at the start and end point (for interpolation)
    % such that there will definitely be a tsg dday less and more than the
    % bottle dday for all bottle ddays
    
    
    %smoothed difference--default is a two-pass filter on the whole dday series
    clear sdiffsm
    sc1 = 0.5; sc2 = 0.02;
    opt1 = mfilename; opt2 = 'tsg_sdiff'; get_cropt
    if ~isempty(sc1) && ~isempty(sc2) && ~exist('sdiffsm','var')
        sdiffsm = filter_bak(ones(1,21),sdiff); % first filter
        sdiff(abs(sdiff-sdiffsm) > sc1) = NaN;
        sdiffsm = filter_bak(ones(1,21),sdiff); % harsh filter to determine smooth adjustment
        sdiff(abs(sdiff-sdiffsm) > sc2) = NaN;
        sdiffsm = filter_bak(ones(1,21),sdiff); % harsh filter to determine smooth adjustment
        sdiffsm_all = [sdiffsm_all; sdiffsm];
        sdiffsm = sdiffsm_all; % rename back to sdfiff and t for saving, but _all vars are the aggregated ones over all segments
        t_all = [t_all; t];
        t = t_all; 
        if 0
            save(fullfile(root_tsg,'sdiffsm'), 't', 'sdiffsm'); mfixperms(fullfile(root_tsg,'sdiffsm'));
        end
    else
        warning(['sdiffsm not set; check opt_' mcruise])
        sdiffsm = NaN+sdiff;
    end
end

calstr = '';
% plot TSG and bottle salinity data
figure(1); clf
subplot(nsp,1,1)
hl = plot(dt.dday, dt.flow+35, 'c', dt.dday, dt.(salvar), db.dday, db.salinity_adj, 'o', db.dday, db.tsgsal, '.'); grid
legend(hl, 'flow (scaled)', 'TSG','bottle','TSG')
ylabel('Salinity (psu)'); xlabel(ht.fldunt(strcmp('dday',ht.fldnam)))
title([calstr ' TSG'])
xlim(dt.dday([1 end]))
subplot(nsp,1,2) 
plot(db.dday, sdiffall, 'r+-',t_all+1, sdiffsm,' kx-'); grid ; hold on ; 
ylabel([calstr ' bottle - TSG (psu)']); xlabel(ht.fldunt(strcmp('dday',ht.fldnam)))
xlim(dt.dday([1 end]))
ylim([-.02 .06])
if nsp==4
    subplot(nsp,1,3)
    plot(db.stemp, sdiffall, 'r+', db.stemp, sdiffsm(2:end-1), 'kx'); grid % bak on dy146: sdiffsm(2:end-1) so array lengths match
    xlabel('Sea Surface Temperature (^\circC)')
    ylabel([calstr ' bottle - TSG (psu)'])
    legend('Total Difference', 'Smoothed Difference'); hold on ; 
    subplot(nsp,1,4)
    plot(db.tsgsal, sdiffall, 'r+', db.tsgsal, sdiffsm(2:end-1), 'kx'); grid % bak on dy146: sdiffsm(2:end-1) so array lengths match
    xlabel([calstr ' TSG salinity (psu)'])
    ylabel([calstr ' bottle - TSG (psu)'])
end
printdir = fullfile(MEXEC_G.mexec_data_root,'plots');
printform = '-dpdf';
print(printform,fullfile(printdir,['tsg_bottle_' mcruise]));

disp('mean diff, median diff')
[m_nanmean(sdiff) m_nanmedian(sdiff)]
disp('RMS of residuals:')
rms_res = sqrt(sum(sdiff(~isnan(sdiff)).^2)/sum(~isnan(sdiff)))
% disp('stderr:')
% stde = sqrt(sum(sdiff(~isnan(sdiff)).^2)/(sum(~isnan(sdiff))-1)) % not output by bak on dy146; not sure this is helpful

disp(['choose a constant or simple dday-dependent correction for TSG, add to '])
disp(['uway_proc, tsg_cals case in opt_cruise (to be applied to _edt variable(s))'])
disp(['(or set it so it uses the smooth function shown here)'])

dintake = 5;
if comp2ctd
    disp('loading CTD data')
    [dsum,hsum] = mload(fullfile(mgetdir('M_SUM'),['station_summary_' mcruise '_all']),'/');
    ii = find(dsum.time_start/86400>dt.dday(1) & dsum.time_end/86400<dt.dday(end));
    statnum = dsum.statnum(ii);
    dt.ctdt = NaN+dt.dday; dt.ctds = dt.ctdt;
    for sno = 1:length(statnum)
        [d,h] = mload(fullfile(mgetdir('M_CTD'),sprintf('ctd_%s_%03d_psal',mcruise,statnum(sno))),'/');
        d.dday = m_commontime(d, 'time', h, ht.fldunt(strcmp('dday',ht.fldnam)));
        [ddcs,hdcs] = mload(fullfile(mgetdir('M_CTD'),sprintf('dcs_%s_%03d',mcruise,statnum(sno))),'/');
        iid = find(d.scan>ddcs.scan_start & d.scan<ddcs.scan_bot & d.press>dintake-1 & d.press<dintake+1);
        iiu = find(d.scan>ddcs.scan_bot & d.scan<ddcs.scan_end & d.press>dintake-1 & d.press<dintake+1);
        timdif = abs(dt.dday-mean(d.dday(iid)));
        dt.ctdt(timdif==min(timdif)) = nanmean(d.temp(iid));
        dt.ctds(timdif==min(timdif)) = nanmean(d.psal(iid));
        timdif = abs(dt.dday-mean(d.dday(iiu)));
        dt.ctdt(timdif==min(timdif)) = nanmean(d.temp(iiu));
        dt.ctds(timdif==min(timdif)) = nanmean(d.psal(iid)); %***save down vs up separately?
    end

    % plot TSG, bottle and CTD data
    figure(2); clf
    subplot(2,1,1) %nsp
    h2 = plot(dt.dday, dt.(salvar), db.dday, db.salinity_adj, 'o', db.dday, db.tsgsal, '<'); grid
    hold on;
    h3 = plot(dt.dday, dt.ctds, 'r.');
    legend([h2; h3], 'TSG','bottle','TSG', 'CTD')
    hold on; 
    ylabel('Salinity (psu)'); xlabel('decimal day')
    title([calstr ' TSG'])
    xlim(dt.dday([1 end]))
     subplot(2,1,2) %nsp
    h2 = plot(dt.dday, dt.(tempvar), db.dday, db.tsst, 'o'); grid
    hold on;
    h3 = plot(dt.dday, dt.ctdt, 'r.');
    legend([h2; h3], 'TSG','DK', 'CTD')
    hold on; 
    ylabel('T (degC)'); xlabel('decimal day')
    title([calstr ' TSG'])
    xlim(dt.dday([1 end]))
return   
    if 0%nseg < 2
        % relate tsg dday to ctd dday
        % dt.(salvar) = dt.(salvar); %this already defined above
        db.tsgsal_ctd_shallow = interp1(dt.dday, dt.(salvar), ds_i_all_shallowest.dday_jul);
        db.tsgsal_ctd_5m = interp1(dt.dday, dt.(salvar), ds_i_all_5m.dday_jul);

    else 
        %  work out overlapping ddays for each segment
        try 
            db.tsgsal_ctd_shallow = interp1(dt.dday, dt.(salvar), ds_i_all_shallowest.dday_jul);
            db.tsgsal_ctd_5m = interp1(dt.dday, dt.(salvar), ds_i_all_5m.dday_jul);

        catch 
            disp('Interpolation of TSG sal onto CTD sal failed. Likely as TSG not running during CTD deployment. Next section will likely fail.')
        end
        
    end

    nsp = 2;
    if 0%exist('tempsst','var') && ~isempty(tempsst)
        db.stemp_ctd_shallow = interp1(dt.dday, dt.(tempsst), ds_i_all_shallowest.dday_jul);
        db.stemp_ctd_5m = interp1(dt.dday, dt.(tempsst), ds_i_all_5m.dday_jul);

        nsp = 4;
    end

    %NaN some of the db.salinity_adj points ???

    sdiff_ctd_shallow = ds_i_all_shallowest.(ctd_sal_var)-db.tsgsal_ctd_shallow; %offset is bottle minus tsg, so that it is correction to be added to tsg
    sdiff_std_ctd_shallow = m_nanstd(sdiff_ctd_shallow); sdiff_mean_ctd_shallow = m_nanmean(sdiff_ctd_shallow);
    idx = find(abs(sdiff_ctd_shallow-sdiff_mean_ctd_shallow)>3*sdiff_std_ctd_shallow); % bak dy146 sdiff-sdiff_mean ?
    % List and discard possible outliers
    if ~isempty(idx)
	    fprintf(1,'\n Std deviation of ctd tsg - differnces is %7.3f \n',sdiff_std_ctd_shallow)
	    fprintf(1,' The following are outliers to be checked: \n')
	    fprintf(1,' Sample  Jday dday    Difference  \n')
	    for ii = idx(:)'
		    jdx = floor(ds_i_all_shallowest.dday_jul(ii));
		    fprintf(1,'  %2d  -  %d  %s  %7.3f \n',ii,jdx,datestr(ds_i_all_shallowest.dday_jul(ii),15),sdiff_ctd_shallow(ii))
	    end
    end
    sdiffall_ctd_shallow = sdiff_ctd_shallow;
    sdiff_ctd_shallow(idx) = NaN; % set values where value>3*SD as NaN


    sdiff_ctd_5m = ds_i_all_5m.(ctd_sal_var)-db.tsgsal_ctd_5m; %offset is bottle minus tsg, so that it is correction to be added to tsg
    sdiff_std_ctd_5m = m_nanstd(sdiff_ctd_5m); sdiff_mean_ctd_5m = m_nanmean(sdiff_ctd_5m);
    idx = find(abs(sdiff_ctd_5m-sdiff_mean_ctd_5m)>3*sdiff_std_ctd_5m); % bak dy146 sdiff-sdiff_mean ?
    % List and discard possible outliers
    if ~isempty(idx)
	    fprintf(1,'\n Std deviation of ctd tsg - differnces is %7.3f \n',sdiff_std_ctd_5m)
	    fprintf(1,' The following are outliers to be checked: \n')
	    fprintf(1,' Sample  Jday dday    Difference  \n')
	    for ii = idx(:)'
		    jdx = floor(ds_i_all_5m.dday_jul(ii));
		    fprintf(1,'  %2d  -  %d  %s  %7.3f \n',ii,jdx,datestr(ds_i_all_5m.dday_jul(ii),15),sdiff_ctd_5m(ii))
	    end
    end
    sdiffall_ctd_5m = sdiff_ctd_5m;

    sdiff_ctd_5m(idx) = NaN; % set values where value>3*SD as NaN


    % plot TSG and bottle data
    figure(3); clf
    subplot(nsp,1,1)
    
    % plot bottles too
    h4 = plot(dt.dday, dt.(salvar), db.dday, db.salinity, '.y', db.dday, db.salinity_adj, 'o', db.dday, db.tsgsal, '<', ds_i_all.dday_jul, ds_i_all.(ctd_sal_var), 'r.', ds_i_all_shallowest.dday_jul, ds_i_all_shallowest.(ctd_sal_var), 'r.'); grid
    legend(h4([1 3 4 5 6]), 'TSG','bottle','TSG', ctd_all_leg_str, 'Shallowest'); % , '5m')
    h4(6).MarkerSize = 20;

    % just plot CTD data NOT bottles
    %h4 = plot(dt.dday, dt.(salvar), ds_i_all.dday_jul, ds_i_all.(ctd_sal_var), 'k.', ds_i_all_shallowest.dday_jul, ds_i_all_shallowest.(ctd_sal_var), 'r.'); grid
    %legend(h4([1 2 3]), 'TSG', ctd_all_leg_str, 'Shallowest'); % , '5m')
    %h4(3).MarkerSize = 20;
    
    %h3 = plot(ds_i_all.dday_jul, ds_i_all.(ctd_sal_var), 'r.', ds_i_all_shallowest.dday_jul, ds_i_all_shallowest.(ctd_sal_var), 'r.');
    %legend(h2([1 3 4]), 'TSG','bottle','TSG'); %, 'CTD')

    ylabel('Salinity (psu)'); xlabel('yearday, noon on 1 Jan = 1.5')
    title([calstr ' TSG'])
    xlim(dt.dday([1 end]))
    ylim([34.5, 35.5])
    subplot(nsp,1,2)
    plot(ds_i_all_shallowest.dday_jul, sdiffall_ctd_shallow, 'r+-', ds_i_all_5m.dday_jul, sdiffall_ctd_5m, 'k+-') ; grid %,t_all+1, sdiffsm,' kx-'); grid
    hold on ;
    ylabel([calstr ' CTD minus TSG (psu)']); xlabel('yearday, noon on 1 Jan = 1.5')
    xlim(dt.dday([1 end]))
    ylim([-.02 .06])
    legend('Shallowest', '5m');
    hold on ;
    if nsp==4
        subplot(nsp,1,3)
        plot(db.stemp_ctd_shallow, sdiffall_ctd_5m, 'r+', db.stemp_ctd_5m, sdiffall_ctd_5m, 'k+') ; grid %, db.stemp, sdiffsm(2:end-1), 'kx'); grid % bak on dy146: sdiffsm(2:end-1) so array lengths match
        xlabel('Sea Surface Temperature (^\circC)')
        ylabel([calstr ' CTD - TSG (psu)'])
        legend('Shallowest', '5m');
        ylim([-.01, 0.06])
        subplot(nsp,1,4)
        plot(db.tsgsal_ctd_shallow, sdiffall_ctd_shallow, 'r+', db.tsgsal_ctd_5m, sdiffall_ctd_5m, 'k+') ; grid %, db.tsgsal, sdiffsm(2:end-1), 'kx'); grid % bak on dy146: sdiffsm(2:end-1) so array lengths match
        xlabel([calstr ' TSG salinity (psu)'])
        ylabel([calstr ' CTD - TSG (psu)'])
        legend('Shallowest', '5m');
        ylim([-.01, 0.06])

    end
    
    % compare TSG and CTD temp
    figure(4); clf ; 
    h5 = plot(dt.dday, dt.(tempsst), 'k', dt.dday, dt.(tempvar), 'b', ds_i_all.dday_jul, ds_i_all.(ctd_temp_var), 'r.', ds_i_all_shallowest.dday_jul, ds_i_all_shallowest.(ctd_temp_var), 'r.');
    legend(h5([1 2 3]), 'TSG tempr', 'TSG temph', 'CTD temp', 'Shallowest CTD temp') ; %, ctd_all_leg_str, 'Shallowest'); % , '5m')
    h5(3).MarkerSize = 20;


end
    
