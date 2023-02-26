% bak jc069 compare bottles and tsg data
% overhauled on jr281, based on jr069 version, to be suitable for any ship

% choose calibrated or uncalibrated data for comparison

% modified by eck on DY040 to try to compare 5m ctd temperature (top bottle)
% with tsg

cal = 'cal';
cal = 'uncal';

ship = MEXEC_G.MSCRIPT_CRUISE_STRING(1:2);

switch ship
    case {'jc' 'dy'}
        % set up by bak on dy040 17 dec 2015; guessing will work on jc
        mcd M_MET_TSG
        prefix1 = ['met_tsg_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
        salvar_raw = 'salin'; % salinity vars in tsg data stream
        salvar_cal = 'salin_cal';
        tempvar = 'temp_h'; % housing temp
        condvar = 'cond'; % conductivity
        switch cal
            case 'uncal'
                tsgfn = [prefix1 '01_medav_clean']; % median averaged file
            case 'cal'
                tsgfn = [prefix1 '01_medav_clean_cal']; % median averaged file
        end
        
        tsgall_root = []; % tsg sample files were in surftsg on dy040; no need to go elsewhere for them
    case 'jcr'
        % eg jr281
        mcd M_OCL
        prefix1 = ['ocl_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
        salvar_raw = 'salinity'; % salinity vars in tsg data stream
        salvar_cal = 'salinity_cal';
%         tempvar = 'sampletemp'; % housing temp
        tempvar = 'tstemp'; % housing temp bak jr302
        condvar = 'conductivity'; % conductivity
        switch cal
            case 'uncal'
                tsgfn = [prefix1 '01_medav_clean']; % median averaged file, but not really needed on jr281; kept for consistency with jc069
            case 'cal'
                tsgfn = [prefix1 '01_medav_clean_cal']; % median averaged file
        end       
        tsgall_root = []; % tsg files were in OCL on jr281. NO need ot go elsewhere for them.
end

botfn = [tsgall_root 'tsg_' MEXEC_G.MSCRIPT_CRUISE_STRING '_all'];

switch cal % either ship; choose variables for merge; include calibrated variable if it exists
    case 'uncal'
        varline = [salvar_raw ' ' tempvar ' ' condvar];
        salvartest = salvar_raw;
    case 'cal'
        varline = [salvar_raw ' ' tempvar ' ' condvar ' ' salvar_cal];
        salvartest = salvar_cal;
end


tsgot = [tsgfn '_botcompare']; 
%--------------------------------
% 2012-03-09 08:40:22
% mmerge
% calling history, most recent first
%    mmerge in file: mmerge.m line: 402
% input files
% Filename ../ctd/tsg_jc069_all.nc   Data Name :  tsg_jc069_all <version> 11 <site> jc069_atsea
% Filename tsg_jc069_01_med.nc   Data Name :  tsg_jc069_01 <version> 43 <site> jc069_atsea
% output files
% Filename wk2.nc   Data Name :  tsg_jc069_all <version> 13 <site> jc069_atsea
MEXEC_A.MARGS_IN = {
tsgot
botfn
'time salinity_adj' % corrected salinity from autosal analyses
'time'
tsgfn
'time'
varline
'k'
};
mmerge
%--------------------------------


[db hb] = mload(tsgot,'/');
yyyy = hb.data_time_origin(1);
db.decday = datenum(hb.data_time_origin) + db.time/86400 - datenum([yyyy 1 1 0 0 0]);

% quick and dirty assume time origin is start of year
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
switch cruise
    case 'jc069'
        db.salinity_adj(10) = nan; % bad data point on jc069
    case 'jr281'
        db.salinity_adj(45) = nan; % bad comparison point on jr281
    case 'dy040'
        db.salinity_adj(17) = nan; % bad comparison point on dy040
        db.salinity_adj(43) = nan; % bad comparison point on dy040
    otherwise
end

% choose salinity variable for comparison; this is set earlier for raw or
% cal data
cmd = ['saltest = db.' salvartest ';']; eval(cmd)
sdiff = db.salinity_adj - saltest;

sdiffall = sdiff;
switch cruise
    case 'jr281' % try a two=pass filter, removing bad outliers, re-filtering and then refining 
        sdiffsm = filter_bak(ones(1,21),sdiff); % first filter 
        res = sdiff - sdiffsm;
        sdiff(abs(res) > 0.01) = nan;
        sdiffsm = filter_bak(ones(1,21),sdiff); % harsh filter to determine smooth adjustment
        res = sdiff - sdiffsm;
        sdiff(abs(res) > 0.005) = nan;
        sdiffsm = filter_bak(ones(1,21),sdiff); % harsh filter to determine smooth adjustment
    case 'jr302' % try a two=pass filter, removing bad outliers, re-filtering and then refining 
        sdiffsm = filter_bak(ones(1,21),sdiff); % first filter 
        res = sdiff - sdiffsm;
        sdiff(abs(res) > .5) = nan;
        sdiffsm = filter_bak(ones(1,21),sdiff); % first filter 
        res = sdiff - sdiffsm;
        sdiff(abs(res) > 0.02) = nan;
%         sdiffsm = filter_bak(ones(1,21),sdiff); % first filter 
%         res = sdiff - sdiffsm;
%         sdiff(abs(res) > 0.1) = nan;
%         sdiffsm = filter_bak(ones(1,21),sdiff); % harsh filter to determine smooth adjustment
%         res = sdiff - sdiffsm;
%         sdiff(abs(res) > 0.01) = nan;
        sdiffsm = filter_bak(ones(1,11),sdiff); % harsh filter to determine smooth adjustment
    case 'dy040'
        % introduce break point at day 350 when the TSG was cleaned
        idx1=db.decday<350;
        idx2=db.decday>=350;
        sdiffsm = nan(size(sdiff));
        res = nan(size(sdiff));
        
        % now determine corrections, not in a loop so different filters can
        % potentially be applied to each section
        
        % correction for data prior to day 350
        sdiffsm(idx1) = filter_bak(ones(1,21),sdiff(idx1)); % first filter
        res(idx1) = sdiff(idx1) - sdiffsm(idx1);
        sdiff(idx1 & abs(res) > 0.03) = nan;
        sdiffsm(idx1) = filter_bak(ones(1,41),sdiff(idx1)); % second filter
        res(idx1) = sdiff(idx1) - sdiffsm(idx1);
        
        % correction for data after day 350
        sdiffsm(idx2) = filter_bak(ones(1,21),sdiff(idx2)); % first filter
        res(idx2) = sdiff(idx2) - sdiffsm(idx2);
        sdiff(idx2 & abs(res) > 0.03) = nan;
        sdiffsm(idx2) = filter_bak(ones(1,41),sdiff(idx2)); % second filter
        res(idx2) = sdiff(idx2) - sdiffsm(idx2);
        
    otherwise
        sdiffsm = filter_bak(ones(1,21),sdiff); % harsh filter to determine smooth adjustment
end

m_figure
plot(db.decday,sdiffall,'r+'); % the excluded data will remain. included data will be overplotted in black
hold on; grid on;
plot(db.decday,sdiff,'k+');
plot(db.decday,sdiffsm,'m+-');
xlabel('Decimal day; noon on 1 Jan = 0.5');
ylabel('salinity difference PSS-78');
ax = axis;
ax(3) = min([-0.05 ax(3)]); % tweak on dy040 bak 17 dec 2015, axes are +/- 0.05, or larger if required
ax(4) = max([0.05 ax(4)]);
axis(ax);
switch cal
    case 'uncal'
        title({MEXEC_G.MSCRIPT_CRUISE_STRING; 'Bottle minus TSG salinity differences'; 'Individual bottles and smoothed adjustment applied'});
    case 'cal'
        title({MEXEC_G.MSCRIPT_CRUISE_STRING; 'Bottle minus TSG salinity differences: calibrated data'; 'Individual bottles'});
end
 
 
% load tsg data and get time in decday
[dt ht] = mload(tsgfn,'/');
yyyy = ht.data_time_origin(1);
dt.decday = datenum(ht.data_time_origin) + dt.time/86400 - datenum([yyyy 1 1 0 0 0]);

m_figure
cmd = ['plotvar = dt.' salvartest ';']; eval(cmd);
plot(dt.decday,plotvar,'b-');
hold on; grid on;
plot(db.decday,db.salinity_adj,'r+');
xlabel('Decimal day; noon on 1 Jan = 0.5');
ylabel('Salinity PSS-78');
ax2 = axis;
axis([ax(1:2) ax2(3:4)]);
switch cal
    case 'uncal'
        title({MEXEC_G.MSCRIPT_CRUISE_STRING; 'Bottle and TSG salinity '; 'Uncalibrated'});
    case 'cal'
        title({MEXEC_G.MSCRIPT_CRUISE_STRING; 'Bottle and TSG salinity '; 'Calibrated'});
end

% display the rms of differences
disp('RMS of residuals is:');
rms_res = sqrt(sum(sdiff(~isnan(sdiff)).^2)/length(sdiff(~isnan(sdiff)))),

 
 
 
 
