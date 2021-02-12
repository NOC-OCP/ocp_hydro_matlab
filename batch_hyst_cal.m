
% apply oxygen hysteresis corrections and/or sensor calibrations
% to the raw/24hz files, and propagate through to subsequent files
%
% this script takes one or more of several variations on klist:
%
% klistraw to rerun mctd_02b, applying (new) oxygen hysteresis correction
%     as well as getting rid of any previously-applied calibrations
% klisttemp to calibrate temperature sensors
% klistcond to calibrate conductivity sensors
% klistoxy to calibrate oxygen sensor(s)
% klistfluor to calibrate fluorescence sensor
% klistxmiss to calibration transmissivity sensor
%
% the correction and calibrations are taken from opt_cruise
%
% you probably wouldn't do klistraw at the same time as the sensor cals,
% but the steps to be rerun from mctd_03 on overlap, so they are combined
% in one batch_ script
%
% ideally you should calibrate temp before deciding on the calibration for
% cond, and calibrate temp and cond before deciding on the calibration for
% oxy


mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

%get concatenated list of stations
list_actions = {'klistraw' 'rerun mctd_02b, applying oxygen hysteresis (if set in opt_cruise) and regenerating _24hz from _raw';
    'klisttemp' 'apply temperature calibrations';
    'klistcond' 'apply conductivity calibrations';
    'klistoxy' 'apply oxygen calibration(s)';
    'klistfluor' 'apply fluorescence calibration';
    'klistxmiss' 'apply transmissivity calibration'};
klistall = [];
for lno = 1:size(list_actions,1)
    if ~exist(list_actions{lno,1}, 'var')
        eval([list_actions{lno,1} ' = [];']);
    else
        eval(['klist = ' list_actions{lno,1} '(:);']);
        klistall = [klistall klist];
        sprintf('Will %s to stations\n', list_actions{lno,2});
        disp(klist); pause(0.5)
    end
end
scriptname = 'castpars'; oopt = 'klist'; get_cropt
klist = setdiff(klist, klist_exc); %remove non-CTD casts

disp('have you uncommented bottle_data_flags.txt?'); pause

if length(klistoxy)>0
    scriptname = 'castpars'; oopt = 'oxyvars'; get_cropt
end

for kloop = klist
    actions = 0; %keep track in case no cals set in opt_cruise
    
    %24hz from raw
    
    if ismember(kloop, klisthyst)
        stn = kloop; mctd_02b; actions = actions+1;
    end
    
    
    %calibrations
    
    if ismember(kloop, klisttemp)
        stn = kloop; calvar = 'temp'; senscal = 1; mctd_senscal
        if length(calstr)>0; actions = actions+1; end
        stn = kloop; calvar = 'temp'; senscal = 2; mctd_senscal
        if length(calstr)>0; actions = actions+1; end
    end
    
    if ismember(kloop, klistcond)
        stn = kloop; calvar = 'cond'; senscal = 1; mctd_senscal
        if length(calstr)>0; actions = actions+1; end
        stn = kloop; calvar = 'cond'; senscal = 2; mctd_senscal
        if length(calstr)>0; actions = actions+1; end
    end
    
    if ismember(kloop, klistoxy)
        for vno = 1:size(oxyvars,1)
            calvar = oxyvars{vno,2};
            stn = kloop; senscal = str2num(calvar(end)); mctd_senscal
            if length(calstr)>0; actions = actions+1; end
        end
    end
    
    if ismember(kloop, klistfluor)
        stn = kloop; calvar = 'fluor'; mctd_senscal
        if length(calstr)>0; actions = actions+1; end
    end
    
    if ismember(kloop, klistxmiss)
        stn = kloop; calvar = 'transmittance'; mctd_senscal
        if length(calstr)>0; actions = actions+1; end
    end
    
    
    if actions>0 %propagate through files
        
        stn = kloop; mctd_03;
        mout_1hzasc(kloop)
        stn = kloop; mctd_04;
        
        stn = kloop; mfir_03;
        stn = kloop; mfir_04;
        
        stn = kloop; msam_02b; %***necessary? what about msam_putpos?***
        
    end
    
end

scriptname = 'batchactions'; oopt = 'ctd'; get_cropt
scriptname = 'batchactions'; oopt = 'sam'; get_cropt
scriptname = 'batchactions'; oopt = 'sync'; get_cropt
clear klist*
