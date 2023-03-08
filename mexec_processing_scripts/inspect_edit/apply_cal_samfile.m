function d = apply_cal_samfile(d, h, udstr, testcal, calstr)
% function d = apply_cal_samfile(d, h, udstr, testcal, calstr);
% wrapper for apply_calibrations to work on utemp etc. and on multiple
% stations 
% 
% called by mctd_evaluate_sensors, ctd_sensor_check, checkbottles_*
%
% d and h are structures (e.g. from sam_{cruise}_all.nc)
% udstr is either 'u' or 'd' to use upcast or downcast data (usually 'u')
% testcal must be supplied (insted of opt_{cruise} castopts.docal)
% calstr may be supplied, or set calstr = [] to use castopts.calstr from
%   opt_{cruise}.m 
%
% returns d, same structure with calibrated fields (where indicated by
%   testcal)
%
% calls m_common, get_cropt (calibration, ctd_cals), and apply_calibrations

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

%variables with a 'u' (or 'd') before them in the sam file, which might be
%calibrated or used in calibration functions
udvars = {'press' 'time' 'temp1' 'temp2' 'psal1' 'psal2' 'cond1' 'cond2' 'oxygen1' 'oxygen2' 'fluor'};

if isempty(calstr)
    cropt_cal = 1;
else
    cropt_cal = 0;
end

%loop through stations, since they might have different cal functions
stns = unique(d.statnum);
for sno = stns(:)'
    stnlocal = sno;
    %get only the calibration functions we want to test here
    if cropt_cal
        opt1 = 'calibration'; opt2 = 'ctd_cals'; get_cropt
        if exist('castopts','var') && isfield(castopts,'calstr')
            calstr = castopts.calstr;
        else
            continue
        end
    end

    %get the data from just this station, and rename e.g. upress to press
    clear d0
    iig = find(d.statnum==stnlocal);
    for vno = 1:length(udvars)
        d0.(udvars{vno}) = d.([udstr udvars{vno}])(iig);
    end
    d0.statnum = d.statnum(iig);
    h0.fldnam = fieldnames(d0)';
    h0.fldunt = repmat({' '},size(h0.fldnam));
    %paste in serial numbers
    if isfield(d,'sn_cond1') %assume if we have one we have all
        snfs = {'cond1' 'cond2' 'temp1' 'temp2' 'oxygen1' 'oxygen2'};
        h0.fldserial = repmat({' '},size(h0.fldnam));
        for fno = 1:length(snfs)
            h0.fldserial{strcmp(snfs{fno},h0.fldnam)} = num2str(d.(['sn_' snfs{fno}])(iig(1)));
        end
    end
    [dcal, hcal] = apply_calibrations(d0, h0, calstr, testcal, 'q');
    %put calibrated data from this station only back into d, re-prepending
    %the 'u' or 'd'
    for vno = 1:length(hcal.fldnam)
        d.([udstr hcal.fldnam{vno}])(iig) = dcal.(hcal.fldnam{vno});
    end

end

