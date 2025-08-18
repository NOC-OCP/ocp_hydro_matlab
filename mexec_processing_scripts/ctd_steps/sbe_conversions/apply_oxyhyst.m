function [dnew, hnew] = apply_oxyhyst(d, h, co, varargin)
%reverse and/or apply oxygen hysteresis correction to _raw_cleaned file,
%producing _24hz file

nvar = 0;
hnew.comment = '';
m = strncmp('oxygen',h.fldnam,6);
ovars = h.fldnam(m);
ounts = h.fldunt(m);
osns = h.fldserial(m);
hnew.fldnam = {}; hnew.fldunt = {}; hnew.fldserial = {};

if co.dooxyrev
    %calculate the oxygen hysteresis reversed variables
    for no = 1:length(ovars)
        on = ['oxyrev' osns{no}];
        if ~isfield(co,on)
            on = 'oxyrev';
        end
        if size(co.(on).H3,2)==2
            co.(on).H3 = interp1(co.(on).H3(:,1),co.(on).H3(:,2),d.press);
        end
        dnew.([ovars{no} '_rev']) = mcoxyhyst_reverse(d.(ovars{no}), d.time, d.press, co.(on).H1, co.(on).H2, co.(on).H3);
        hnew.fldnam = [hnew.fldnam [ovars{no} '_rev']];
        hnew.fldunt = [hnew.fldunt ounts{no}];
        hnew.fldserial = [hnew.fldserial osns{no}];
    end
    hnew.comment = [hnew.comment '\n reversed oxygen hysteresis'];
    revstring = '_rev'; %if dooxyhyst will apply to _rev variables
else
    revstring = '';
end

if co.dooxyhyst
    for no = 1:length(ovars)
        on = ['oxyhyst' osns{no}];
        if ~isfield(co,on)
            on = 'oxyhyst';
        end
        vin = [ovars{no} revstring];
        vot = ovars{no};
        if size(co.(on).H3,2)==2
            co.(on).H3 = interp1(co.(on).H3(:,1),co.(on).H3(:,2),d.press);
        end
        dnew.(vot) = mcoxyhyst(d.(vin), d.time, d.press, co.(on).H1, co.(on).H2, co.(on).H3);
        hnew.fldnam = [hnew.fldnam vot];
        hnew.fldunt = [hnew.fldunt ounts{no}];
        hnew.fldserial = [hnew.fldserial osns{no}];
        %record whether a non-default calibration is set, for mstar comment
        if length(co.(on).H1)>1 || length(co.(on).H2)>1 || length(co.(on).H3)>1
            ohtyp(no) = 2;
        elseif max(abs(co.H_0-[co.(on).H1 co.(on).H2 co.(on).H3]))>0
            ohtyp(no) = 1;
        else
            ohtyp(no) = 0;
        end
    end
    ohtyp = max(ohtyp);
    if ohtyp>0
        %and add comments to file
        hnew.comment = [hnew.comment '\n oxygen hysteresis correction different from SBE default applied'];
        if ohtyp == 2
            hnew.comment = [hnew.comment ' (depth-varying)'];
        end
    end
end
