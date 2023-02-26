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

udvars = {'press' 'time' 'temp1' 'temp2' 'psal1' 'psal2' 'cond1' 'cond2' 'oxygen1' 'oxygen2' 'fluor'};

if isempty(calstr)
    cropt_cal = 1;
else
    cropt_cal = 0;
    %modify calstr (which won't change) so it applies to e.g. utemp1 as
    %function of upress, etc.
    fn = fieldnames(calstr);
    for no = 1:fn
        s = calstr.(fn{no}).(mcruise);
        for vno = 1:length(udvars)
            s = replace(s,udvars{vno},[udstr udvars{vno}]);
        end
        calstr.([udstr fn{no}]).(mcruise) = s;
    end
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
        %modify calstr so it applies to e.g. utemp1 as function of upress, etc.
        fn = fieldnames(calstr);
        for no = 1:fn
            s = calstr.(fn{no}).(mcruise);
            for vno = 1:length(udvars)
                s = replace(s,udvars{vno},[udstr udvars{vno}]);
            end
            calstr.([udstr fn{no}]).(mcruise) = s;
        end
    end

    %get the data from just this station
    clear d0
    iig = find(d.statnum==stnlocal);
    for vno = 1:length(udflds)
        d0.([udstr udflds{vno}]) = d.([udstr udflds{vno}])(iig);
    end
    d0.statnum = d.statnum(iig);
    [dcal, hcal] = apply_calibrations(d0, h, calstr, testcal, 'q');
    %put calibrated data from this station only back into d
    for vno = 1:length(hcal.fldnam)
        d.(hcal.fldnam{vno})(iig) = dcal.(hcal.fldnam{vno});
    end

end

%rename back
for no = 1:length(uflds)-3
    if ~usedn
        d.(['u' uflds{no}]) = d.(uflds{no});
    else
        d.(['d' uflds{no}]) = d.(uflds{no});
    end
end


