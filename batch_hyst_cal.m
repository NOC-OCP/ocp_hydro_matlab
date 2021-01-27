
% apply oxygen hysteresis corrections and/or sensor calibrations
% to the raw/24hz files, and propagate through to subsequent files
%
% this script takes one or more of several variations on klist:
%
% klisthyst or klistfromraw to rerun mctd_02b, applying (new) oxygen
%     hysteresis correction as well as getting rid of any
%     previously-applied calibrations
% klisttemp to calibrate temperature sensors
% klistcond to calibrate conductivity sensors
% klistoxy to calibrate oxygen sensor(s)
% klistfluor to calibrate fluorescence sensor
% klistxmiss to calibration transmissivity sensor
%
% the correction and calibrations are taken from opt_cruise


mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

%accept either list for running mctd_02b
if ~exist('klisthyst'); klisthyst = []; end
if exist('klistfromraw','var'); klisthyst = unique([klisthyst(:); klistfromraw(:)]); end

%get concatenated list of stations
list_actions = {'klisthyst' 'rerun mctd_02b, applying oxygen hysteresis (if set in opt_cruise) and regenerating _24hz from _raw';
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
        stn = kloop; msam_updateall;
        
        %stn = kloop; mout_cchdo_ctd
    end
    
end

%mout_cchdo_sam %reverse niskin option
%sync if selected
