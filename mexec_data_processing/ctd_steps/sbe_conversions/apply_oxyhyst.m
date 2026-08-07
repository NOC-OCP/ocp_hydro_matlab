function [dnew, hnew] = apply_oxyhyst(d, h, oco)
%reverse and/or apply oxygen hysteresis correction to _raw_cleaned file,
%producing _24hz file
%
% fields of co are hyst_{oxyvar} to apply coefficients H1, H2, H3 to
% oxyvar, and optionally hrev_{ovar} to first reverse the existing
% correction

hnew.comment = '';

hvar = fieldnames(oco);
rvar = hvar;
hvar = hvar(strncmp(hvar,'hyst',4));
rvar = rvar(strncmp(rvar,'hrev',4));

hnew.fldnam = cell(1,length(hvar)); hnew.fldunt = hnew.fldnam; hnew.fldserial = hnew.fldnam;
for vno = 1:length(hvar)
    hv = hvar{vno};
    rv = replace(hv,'hyst','hrev');
    ov = replace(hvar{vno},'hyst_','');
    if ismember(rvar,rv)
        %first reverse
        if size(oco.(rv).H3,2)==2; oco.(rv).H3 = interp1(oco.(rv).H3(:,1),oco.(rv).H3(:,2),d.press); end
        d.(ov) = mcoxyhyst_reverse(d.(ov), d.time, d.press, oco.(rv).H1, oco.(rv).H2, oco.(rv).H3);
        hnew.comment = [hnew.comment '\nreversed oxygen hysteresis on ' ov];
    end
    %now apply (new) hyst
    if size(oco.(hv).H3,2)==2; oco.(hv).H3 = interp1(oco.(hv).H3(:,1),oco.(hv).H3(:,2),d.press); end
    dnew.(ov) = mcoxyhyst(d.(ov), d.time, d.press, oco.(hv).H1, oco.(hv).H2, oco.(hv).H3);
    %record whether a non-default calibration is set, for mstar comment
    if length(oco.(hv).H1)>1 || length(oco.(hv).H2)>1 || length(oco.(hv).H3)>1
        ohtyp(vno) = 2;
    elseif max(abs(oco.H_0-[oco.(hv).H1 oco.(hv).H2 oco.(hv).H3]))>0
        ohtyp(vno) = 1;
    else
        ohtyp(vno) = 0;
    end
    ohtyp = max(ohtyp);
    if ohtyp>0
        %and add comments to file
        hnew.comment = [hnew.comment '\noxygen hysteresis correction different from SBE default applied to ' hv];
        if ohtyp == 2
            hnew.comment = [hnew.comment ' (depth-varying)'];
        end
    else
        hnew.comment = [hnew.comment '\nSBE default oxygen hysteresis applied to ' hv];
    end
    hnew.fldnam{vno} = ov;
    m = strcmp(h.fldnam,ov);
    hnew.fldunt{vno} = h.fldunt{m};
    hnew.fldserial{vno} = h.fldserial{m};
end
