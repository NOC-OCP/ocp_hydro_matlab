% compare bottle salinity and tsg data
% 
% choose calibrated or uncalibrated data for comparison

mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING; % cruise name (from MEXEC_G global)


comp2ctd = true ; % false %true % set to false if you don't want to compare to CTD data

if comp2ctd==true
    updownboth = 'both' ; %'up' %'down'

    % set a variable for the CTD salinity variable to look at (currently psal
    % but could make it variable...) 
    ctd_sal_var = 'psal';
    ctd_temp_var = 'temp';


end 


% get_cropt basically checks that file exists and sets defaults set
% elsewhere
% opt2 are different case options to run through for setting various defaults

                if ~exist('usecal','var'); usecal = 0; end
opt1 = mfilename; opt2 = 'tsg_usecal'; get_cropt; % mfilename = name of current file
usecallocal = usecal; clear usecal 

opt1 = 'ship'; opt2 = 'ship_data_sys_names'; get_cropt
prefix = tsgpre; % prefix for tsg data
root_tsg = mgetdir(tsgpre); %gets directory from MEXEC_g

tsgfn = fullfile(root_tsg, [prefix '_' mcruise '_01_medav_clean']); % median averaged file
if usecallocal
    tsgfn = [tsgfn '_cal'];
end
if ~exist(m_add_nc(tsgfn),'file') % ensures nc file has .nc suffix
    tsgfn = fullfile(root_tsg, [prefix '_' mcruise '_01']); %combines parts of filenames
end

[dt, ht] = mload(tsgfn, '/'); % load tsg netcdf file

% obtains variable names for each parameter from ht and list of known
% common variable names for that parameter
salvar = munderway_varname('salvar',ht.fldnam,1,'s');
tempvar = munderway_varname('tempvar',ht.fldnam,1,'s');
tempsst = munderway_varname('sstvar',ht.fldnam,1,'s');
condvar = munderway_varname('condvar',ht.fldnam,1,'s');

% if not calibrated, change variable name
if usecallocal
    switch salvar
        case 'salinity_raw'
            salvar = 'salinity_cal';
        otherwise
%             salvar = [salvar '_cal']; % variable is already called
%             salinity_cal
    end
    switch tempvar
        case 'temp_raw'
            tempvar = 'temperature_cal';
        otherwise
            tempvar = [tempvar '_cal'];
    end
    calstr = 'cal';
else
    calstr = 'uncal';
end

%***add code for temperature, other variables (fluo?)

botfn = fullfile(root_tsg, ['tsgsal_' mcruise '_all']); % generate filename for bottle salinities
[db, hb] = mload(botfn, '/'); % load bottle salinities
db.time = m_commontime(db.time, hb, ht); %match up times
%sort all variables
[a, iibot] = sort(db.time);
fn = fieldnames(db);
for fno = 1:length(fn)
    db.(fn{fno}) = db.(fn{fno})(iibot);
end

%year-day
dt.time = dt.time/3600/24+1; 
switch MEXEC_G.Mship
    case {'cook' 'discovery'}
db.time = db.time/3600/24+1-1/1440; % delay bottles by one minute to allow for time between bottle sample being drawn and water passing through TSG
    case 'jcr'
db.time = db.time/3600/24+1-1/1440; % delay bottles by one minute to allow for time between bottle sample being drawn and water passing through TSG
end

tsal = dt.(salvar);
tsals = interp1(dt.time, tsal, db.time);
nsp = 2;
if exist('tempsst','var') && ~isempty(tempsst)
    tssts = interp1(dt.time, dt.(tempsst), db.time);
    nsp = 4;
end

opt1 = mfilename; opt2 = 'tsg_bad'; get_cropt %NaN some of the db.salinity_adj points

sdiff = db.salinity_adj-tsals; %offset is bottle minus tsg, so that it is correction to be added to tsg
sdiff_std = m_nanstd(sdiff); sdiff_mean = m_nanmean(sdiff);
idx = find(abs(sdiff-sdiff_mean)>3*sdiff_std); % bak dy146 sdiff-sdiff_mean ?
% List and discard possible outliers
if ~isempty(idx)
	fprintf(1,'\n Std deviation of bottle tsg - differnces is %7.3f \n',sdiff_std)
	fprintf(1,' The following are outliers to be checked: \n')
	fprintf(1,' Sample  Jday Time    Difference  \n')
	for ii = idx(:)'
		jdx = floor(db.time(ii));
		fprintf(1,'  %2d  -  %d  %s  %7.3f \n',ii,jdx,datestr(db.time(ii),15),sdiff(ii))
	end
end
sdiffall = sdiff;
sdiff(idx) = NaN; % set values where value>3*SD as NaN

% set breakpoints for sdiffsm anytime tsg was not running (tbreaks) to
% allow for cleaning 
tbreak = []; 
opt1 = mfilename; opt2 = 'tsg_timebreaks'; get_cropt;

tbreak = [datenum([1900 1 1]); tbreak; datenum([2200 1 1])];
nseg = length(tbreak)-1;

sdiffsm_all = [];
t_all = [];
sdiffsave = sdiff;
for kseg = 1:nseg % segments; always at least 1; if tbreak started empty, then there is one segment
    tstart = tbreak(kseg)+1/86400;
    tend = tbreak(kseg+1)-1/86400;
    
    % why -1 ??
    kbottle = find(db.time-1 > tstart & db.time-1 < tend);
    sdiff = sdiffsave(kbottle);
    
    % add start and end times as pseudo times of bottles, so there will
    % always be a smoothed adjustment for interpolation
    
    t = db.time(kbottle)-1;
    
    % work out if interval is before or after start of tsg data (and select
    % the later of the 2 start times and earlier of the 2 end times)
    t0 = max([tstart min(dt.time-1)]); % tstart, or start of tsg data
    t1 = min([tend max(dt.time-1)]); % tend or end of tsg data
    t = [t0; t; t1];
    sdiff = [nan; sdiff; nan]; % pad this set of times with two nans for the pseudo times
    % need values for sdiff at the start and end point (for interpolation)
    % such that there will definitely be a tsg time less and more than the
    % bottle time for all bottle times
    
    
    %smoothed difference--default is a two-pass filter on the whole time series
    clear sdiffsm
                    sc1 = 0.5; sc2 = 0.02;
opt1 = mfilename; opt2 = 'tsg_sdiff'; get_cropt
    if exist('sc1') & exist('sc2') & ~exist('sdiffsm')
        sdiffsm = filter_bak(ones(1,21),sdiff); % first filter
        sdiff(abs(sdiff-sdiffsm) > sc1) = NaN;
        sdiffsm = filter_bak(ones(1,21),sdiff); % harsh filter to determine smooth adjustment
        sdiff(abs(sdiff-sdiffsm) > sc2) = NaN;
        sdiffsm = filter_bak(ones(1,21),sdiff); % harsh filter to determine smooth adjustment
        sdiffsm_all = [sdiffsm_all; sdiffsm];
        sdiffsm = sdiffsm_all; % rename back to sdfiff and t for saving, but _all vars are the aggregated ones over all segments
        t_all = [t_all; t];
        t = t_all; 
        if ~usecallocal
%             t = db.time-1; 
            save(fullfile(root_tsg, 'sdiffsm'), 't', 'sdiffsm'); 
        end
    else
        warning(['sdiffsm not set; check opt_' mcruise])
        sdiffsm = NaN+sdiff;
    end
end

% plot TSG and bottle data
figure(1); clf
subplot(nsp,1,1)
hl = plot(dt.time, tsal, db.time, db.salinity, '.y', db.time, db.salinity_adj, 'o', db.time, tsals, '<'); grid
legend(hl([1 3 4]), 'TSG','bottle','TSG')
ylabel('Salinity (psu)'); xlabel('yearday, noon on 1 Jan = 1.5')
title([calstr ' TSG'])
xlim(dt.time([1 end]))
subplot(nsp,1,2)
plot(db.time, sdiffall, 'r+-',t_all+1, sdiffsm,' kx-'); grid ; hold on ; 
ylabel([calstr ' bottle - TSG (psu)']); xlabel('yearday, noon on 1 Jan = 1.5')
xlim(dt.time([1 end]))
ylim([-.02 .06])
if nsp==4
    subplot(nsp,1,3)
    plot(tssts, sdiffall, 'r+', tssts, sdiffsm(2:end-1), 'kx'); grid % bak on dy146: sdiffsm(2:end-1) so array lengths match
    xlabel('Sea Surface Temperature (^\circC)')
    ylabel([calstr ' bottle - TSG (psu)'])
    legend('Total Difference', 'Smoothed Difference'); hold on ; 
    subplot(nsp,1,4)
    plot(tsals, sdiffall, 'r+', tsals, sdiffsm(2:end-1), 'kx'); grid % bak on dy146: sdiffsm(2:end-1) so array lengths match
    xlabel([calstr ' TSG salinity (psu)'])
    ylabel([calstr ' bottle - TSG (psu)'])
end

disp('mean diff, median diff')
[m_nanmean(sdiff) m_nanmedian(sdiff)]
disp('RMS of residuals:')
rms_res = sqrt(sum(sdiff(~isnan(sdiff)).^2)/sum(~isnan(sdiff)))
% disp('stderr:')
% stde = sqrt(sum(sdiff(~isnan(sdiff)).^2)/(sum(~isnan(sdiff))-1)) % not output by bak on dy146; not sure this is helpful

if ~usecallocal
    disp(['choose a constant or simple time-dependent correction for TSG, add to '])
    disp(['mstg_medav_clean_cal:tsgcals case in opt_cruise'])
    disp(['(you can set it so it uses the smooth function shown here)'])
end


if comp2ctd
    load_postedit_ctd_for_tsg_comp
    % Check if variable set for the CTD salinity variable exists within the
    % strcture
    if isfield(ds_i, ctd_sal_var)
       
     else
       prompt= 'Which (salinity) variable would you like to use for comparison with tsg data?' % Options include '+ fnames
       ctd_sal_var = string(input(prompt))
    end

    if isfield(ds_i, ctd_temp_var)
       
    else
       prompt= 'Which (temperature) variable would you like to use for comparison with tsg data?' % Options include '+ fnames
       ctd_temp_var = string(input(prompt))
    end

    % plot TSG, bottle and CTD data
    figure(2); clf
    subplot(1,1,1) %nsp
    h2 = plot(dt.time, tsal, db.time, db.salinity, '.y', db.time, db.salinity_adj, 'o', db.time, tsals, '<'); grid
    hold on;
    h3 = plot(ds_i_all.time_jul, ds_i_all.(ctd_sal_var), 'r.', ds_i_all_shallowest.time_jul, ds_i_all_shallowest.(ctd_sal_var), 'r.');
    h3(2).MarkerSize = 20;
    legend(h2([1 3 4]), 'TSG','bottle','TSG'); %, 'CTD')
    hold on;
    ctd_all_leg_str = 'CTD all downcast < ' + string(max_comp_depth);
    legend(h3([1, 2]), ctd_all_leg_str, 'Shallowest');
    ylabel('Salinity (psu)'); xlabel('yearday, noon on 1 Jan = 1.5')
    title([calstr ' TSG'])
    xlim(dt.time([1 end]))
    
    if nseg < 2
        % relate tsg time to ctd time
        % tsal = dt.(salvar); %this already defined above
        tsals_ctd_shallow = interp1(dt.time, tsal, ds_i_all_shallowest.time_jul);
        tsals_ctd_5m = interp1(dt.time, tsal, ds_i_all_5m.time_jul);

    else 
        %  work out overlapping times for each segment
        try 
            tsals_ctd_shallow = interp1(dt.time, tsal, ds_i_all_shallowest.time_jul);
            tsals_ctd_5m = interp1(dt.time, tsal, ds_i_all_5m.time_jul);

        catch 
            disp('Interpolation of TSG sal onto CTD sal failed. Likely as TSG not running during CTD deployment. Next section will likely fail.')
        end
        
    end

    nsp = 2;
    if exist('tempsst','var') & ~isempty(tempsst)
        tssts_ctd_shallow = interp1(dt.time, dt.(tempsst), ds_i_all_shallowest.time_jul);
        tssts_ctd_5m = interp1(dt.time, dt.(tempsst), ds_i_all_5m.time_jul);

        nsp = 4;
    end

    %NaN some of the db.salinity_adj points ???

    sdiff_ctd_shallow = ds_i_all_shallowest.(ctd_sal_var)-tsals_ctd_shallow; %offset is bottle minus tsg, so that it is correction to be added to tsg
    sdiff_std_ctd_shallow = m_nanstd(sdiff_ctd_shallow); sdiff_mean_ctd_shallow = m_nanmean(sdiff_ctd_shallow);
    idx = find(abs(sdiff_ctd_shallow-sdiff_mean_ctd_shallow)>3*sdiff_std_ctd_shallow); % bak dy146 sdiff-sdiff_mean ?
    % List and discard possible outliers
    if ~isempty(idx)
	    fprintf(1,'\n Std deviation of ctd tsg - differnces is %7.3f \n',sdiff_std_ctd_shallow)
	    fprintf(1,' The following are outliers to be checked: \n')
	    fprintf(1,' Sample  Jday Time    Difference  \n')
	    for ii = idx(:)'
		    jdx = floor(ds_i_all_shallowest.time_jul(ii));
		    fprintf(1,'  %2d  -  %d  %s  %7.3f \n',ii,jdx,datestr(ds_i_all_shallowest.time_jul(ii),15),sdiff_ctd_shallow(ii))
	    end
    end
    sdiffall_ctd_shallow = sdiff_ctd_shallow;
    sdiff_ctd_shallow(idx) = NaN; % set values where value>3*SD as NaN


    sdiff_ctd_5m = ds_i_all_5m.(ctd_sal_var)-tsals_ctd_5m; %offset is bottle minus tsg, so that it is correction to be added to tsg
    sdiff_std_ctd_5m = m_nanstd(sdiff_ctd_5m); sdiff_mean_ctd_5m = m_nanmean(sdiff_ctd_5m);
    idx = find(abs(sdiff_ctd_5m-sdiff_mean_ctd_5m)>3*sdiff_std_ctd_5m); % bak dy146 sdiff-sdiff_mean ?
    % List and discard possible outliers
    if ~isempty(idx)
	    fprintf(1,'\n Std deviation of ctd tsg - differnces is %7.3f \n',sdiff_std_ctd_5m)
	    fprintf(1,' The following are outliers to be checked: \n')
	    fprintf(1,' Sample  Jday Time    Difference  \n')
	    for ii = idx(:)'
		    jdx = floor(ds_i_all_5m.time_jul(ii));
		    fprintf(1,'  %2d  -  %d  %s  %7.3f \n',ii,jdx,datestr(ds_i_all_5m.time_jul(ii),15),sdiff_ctd_5m(ii))
	    end
    end
    sdiffall_ctd_5m = sdiff_ctd_5m;
    sdiff_ctd_5m(idx) = NaN; % set values where value>3*SD as NaN


    % plot TSG and bottle data
    figure(3); clf
    subplot(nsp,1,1)
    
    % plot bottles too
    h4 = plot(dt.time, tsal, db.time, db.salinity, '.y', db.time, db.salinity_adj, 'o', db.time, tsals, '<', ds_i_all.time_jul, ds_i_all.(ctd_sal_var), 'r.', ds_i_all_shallowest.time_jul, ds_i_all_shallowest.(ctd_sal_var), 'r.'); grid
    legend(h4([1 3 4 5 6]), 'TSG','bottle','TSG', ctd_all_leg_str, 'Shallowest'); % , '5m')
    h4(6).MarkerSize = 20;

    % just plot CTD data NOT bottles
    %h4 = plot(dt.time, tsal, ds_i_all.time_jul, ds_i_all.(ctd_sal_var), 'k.', ds_i_all_shallowest.time_jul, ds_i_all_shallowest.(ctd_sal_var), 'r.'); grid
    %legend(h4([1 2 3]), 'TSG', ctd_all_leg_str, 'Shallowest'); % , '5m')
    %h4(3).MarkerSize = 20;
    
    %h3 = plot(ds_i_all.time_jul, ds_i_all.(ctd_sal_var), 'r.', ds_i_all_shallowest.time_jul, ds_i_all_shallowest.(ctd_sal_var), 'r.');
    %legend(h2([1 3 4]), 'TSG','bottle','TSG'); %, 'CTD')

    ylabel('Salinity (psu)'); xlabel('yearday, noon on 1 Jan = 1.5')
    title([calstr ' TSG'])
    xlim(dt.time([1 end]))
    ylim([34.5, 35.5])
    subplot(nsp,1,2)
    plot(ds_i_all_shallowest.time_jul, sdiffall_ctd_shallow, 'r+-', ds_i_all_5m.time_jul, sdiffall_ctd_5m, 'k+-') ; grid %,t_all+1, sdiffsm,' kx-'); grid
    hold on ;
    ylabel([calstr ' CTD minus TSG (psu)']); xlabel('yearday, noon on 1 Jan = 1.5')
    xlim(dt.time([1 end]))
    ylim([-.02 .06])
    legend('Shallowest', '5m');
    hold on ;
    if nsp==4
        subplot(nsp,1,3)
        plot(tssts_ctd_shallow, sdiffall_ctd_5m, 'r+', tssts_ctd_5m, sdiffall_ctd_5m, 'k+') ; grid %, tssts, sdiffsm(2:end-1), 'kx'); grid % bak on dy146: sdiffsm(2:end-1) so array lengths match
        xlabel('Sea Surface Temperature (^\circC)')
        ylabel([calstr ' CTD - TSG (psu)'])
        legend('Shallowest', '5m');
        ylim([-.01, 0.06])
        subplot(nsp,1,4)
        plot(tsals_ctd_shallow, sdiffall_ctd_shallow, 'r+', tsals_ctd_5m, sdiffall_ctd_5m, 'k+') ; grid %, tsals, sdiffsm(2:end-1), 'kx'); grid % bak on dy146: sdiffsm(2:end-1) so array lengths match
        xlabel([calstr ' TSG salinity (psu)'])
        ylabel([calstr ' CTD - TSG (psu)'])
        legend('Shallowest', '5m');
        ylim([-.01, 0.06])

    end
    
    % compare TSG and CTD temp
    figure(4); clf ; 
    h5 = plot(dt.time, dt.(tempsst), 'k', dt.time, dt.(tempvar), 'b', ds_i_all.time_jul, ds_i_all.(ctd_temp_var), 'r.', ds_i_all_shallowest.time_jul, ds_i_all_shallowest.(ctd_temp_var), 'r.');
    legend(h5([1 2 3]), 'TSG tempr', 'TSG temph', 'CTD temp', 'Shallowest CTD temp') ; %, ctd_all_leg_str, 'Shallowest'); % , '5m')
    h5(3).MarkerSize = 20;


end
    
