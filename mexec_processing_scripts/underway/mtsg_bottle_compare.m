% compare bottle salinity and tsg data
% 
% choose calibrated or uncalibrated data for comparison

mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

scriptname = mfilename; oopt = 'tsg_usecal'; get_cropt;
usecallocal = usecal; clear usecal

scriptname = 'ship'; oopt = 'ship_data_sys_names'; get_cropt
prefix = tsgpre;
root_tsg = mgetdir(tsgpre);

tsgfn = fullfile(root_tsg, [prefix '_' mcruise '_01_medav_clean']); % median averaged file
if usecallocal
    tsgfn = [tsgfn '_cal'];
end
if ~exist(m_add_nc(tsgfn),'file')
    tsgfn = fullfile(root_tsg, [prefix '_' mcruise '_01']);
end
[dt, ht] = mload(tsgfn, '/');
salvar = munderway_varname('salvar',ht.fldnam,1,'s');
tempvar = munderway_varname('tempvar',ht.fldnam,1,'s');
tempsst = munderway_varname('sstvar',ht.fldnam,1,'s');
condvar = munderway_varname('condvar',ht.fldnam,1,'s');

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

botfn = fullfile(root_tsg, ['tsgsal_' mcruise '_all']);
[db, hb] = mload(botfn, '/');
db.time = m_commontime(db.time, hb.data_time_origin, ht.data_time_origin);
%sort all variables
[a, iibot] = sort(db.time);
fn = fieldnames(db);
for fno = 1:length(fn)
    db.(fn{fno}) = db.(fn{fno})(iibot);
end

%year-day
dt.time = dt.time/3600/24+1; 
db.time = db.time/3600/24+1+1/1440; % delay bottles by one minute to allow for time between bottle sample being drawn and water passing through TSG

tsal = dt.(salvar);
tsals = interp1(dt.time, tsal, db.time);
nsp = 2;
if exist('tempsst','var') & ~isempty(tempsst)
    tssts = interp1(dt.time, dt.(tempsst), db.time);
    nsp = 4;
end

scriptname = mfilename; oopt = 'tsg_bad'; get_cropt %NaN some of the db.salinity_adj points

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
sdiff(idx) = NaN;

% bak jc211, break points in sdiffsm to allow for cleaning
tbreak = []; % example of how to set tbreak in opt_jc211
scriptname = mfilename; oopt = 'tsg_timebreaks'; get_cropt;


tbreak = [datenum([1900 1 1]); tbreak; datenum([2200 1 1])]-datenum(ht.data_time_origin);
nseg = length(tbreak)-1;

sdiffsm_all = [];
t_all = [];
sdiffsave = sdiff;
for kseg = 1:nseg % segments; always at least 1; if tbreak started empty, then there is one segment
    tstart = tbreak(kseg)+1/86400;
    tend = tbreak(kseg+1)-1/86400;
    
    kbottle = find(db.time-1 > tstart & db.time-1 < tend);
    sdiff = sdiffsave(kbottle);
    
    % add start and end times as pseudo times of bottles, so there will
    % always be a smoothed adjustment for interpolation
    
    t = db.time(kbottle)-1;
    
    t0 = max([tstart min(dt.time-1)]); % tstart, or start of tsg data
    t1 = min([tend max(dt.time-1)]); % tend or end of tsg data
    t = [t0; t; t1];
    sdiff = [nan; sdiff; nan]; % pad this set of times with two nans for the pseudo times

    
    
    %smoothed difference--default is a two-pass filter on the whole time series
    clear sdiffsm
    scriptname = mfilename; oopt = 'tsg_sdiff'; get_cropt
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

figure(1); clf
subplot(nsp,1,1)
hl = plot(dt.time, tsal, db.time, db.salinity, '.y', db.time, db.salinity_adj, 'o', db.time, tsals, '<'); grid
legend(hl([1 3 4]), 'TSG','bottle','TSG')
ylabel('Salinity (psu)'); xlabel('yearday, noon on 1 Jan = 1.5')
title([calstr ' TSG'])
xlim(dt.time([1 end]))
subplot(nsp,1,2)
plot(db.time, sdiffall, 'r+-',t_all+1, sdiffsm,' kx-'); grid
ylabel([calstr ' bottle minus TSG (psu)']); xlabel('yearday, noon on 1 Jan = 1.5')
xlim(dt.time([1 end]))
ylim([-.02 .04])
if nsp==4
    subplot(nsp,1,3)
    plot(tssts, sdiffall, 'r+', tssts, sdiffsm(2:end-1), 'kx'); grid % bak on dy146: sdiffsm(2:end-1) so array lengths match
    xlabel('Sea Surface Temperature (^\circC)')
    ylabel([calstr ' TSG - bottle (psu)'])
    legend('Total Difference', 'Smoothed Difference');
    subplot(nsp,1,4)
    plot(tsals, sdiffall, 'r+', tsals, sdiffsm(2:end-1), 'kx'); grid % bak on dy146: sdiffsm(2:end-1) so array lengths match
    xlabel([calstr ' TSG salinity (psu)'])
    ylabel([calstr ' TSG - bottle (psu)'])
end

disp('mean diff, median diff')
[m_nanmean(sdiff) m_nanmedian(sdiff)]
disp('RMS of residuals:')
rms_res = sqrt(sum(sdiff(~isnan(sdiff)).^2)/sum(~isnan(sdiff)))
% disp('stderr:')
% stde = sqrt(sum(sdiff(~isnan(sdiff)).^2)/(sum(~isnan(sdiff))-1)) % not output by bak on dy146; not sure this is helpful

if ~usecallocal
    disp(['choose a constant or simple time-dependent correction for TSG, add to tsgsal_apply_cal case of opt_' mcruise])
    disp(['you can set it so tsgsal_apply_cal calculates the smooth function shown here'])
end
