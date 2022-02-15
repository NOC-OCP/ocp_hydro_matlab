function [dnew, hnew] = mctd_apply_oxyhyst(d, h, castopts)
%reverse and/or apply oxygen hysteresis correction to _raw_cleaned file,
%producing _24hz file

scriptname = 'castpars'; oopt = 'oxyvars'; get_cropt
nox = size(oxyvars,1); 

nvar = 0;
hnew.comment = '';

if castopts.dooxyrev
    %calculate oxy_rev, the oxygen hysteresis reversed variables
    if ~iscell(castopts.oxyrev.H1)
        castopts.oxyrev.H1 = repmat({castopts.oxyrev.H1},nox,1);
    end
    if ~iscell(castopts.oxyrev.H2)
        castopts.oxyrev.H2 = repmat({castopts.oxyrev.H2},nox,1);
    end
    if ~iscell(castopts.oxyrev.H3)
        castopts.oxyrev.H3 = repmat({castopts.oxyrev.H3},nox,1);
    end
    for no = 1:nox
        thisvar = find(strcmp(oxyvars{no,1}, h.fldnam)); %same units
        hnew.fldnam{nvar+no} = [oxyvars{no,1} '_rev'];
        hnew.fldunt(nvar+no) = h.fldunt(thisvar);
        dnew.(hnew.fldnam{nvar+no}) = mcoxyhyst_reverse(d.(oxyvars{no,1}), d.time, d.press, castopts.oxyrev.H1{no}, castopts.oxyrev.H2{no}, castopts.oxyrev.H3{no});
        hnew.comment = [hnew.comment 'reversed oxygen hysteresis\n '];
        %datastruct = struct('name',[oxyvars{no,1} '_rev'], 'units',hcal.fldunt{thisvar}, 'data',oxy_unhyst);
        %m_write_variable(otfilestruct, datastruct);
    end
    revstring = '_rev'; %if dooxyhyst will apply to _rev variables
else
    revstring = ''; %if dooxyhyst will apply to original variables
end
if exist(hnew,'var')
    nvar = length(hnew.fldnam);
end

if dooxyhyst
    %calculate the variables with oxygen hysteresis applied
    if ~iscell(castopts.oxyrev.H1)
        castopts.oxyhyst.H1 = repmat({castopts.oxyhyst.H1},nox,1);
    end
    if ~iscell(castopts.oxyrev.H2)
        castopts.oxyhyst.H2 = repmat({castopts.oxyhyst.H2},nox,1);
    end
    if ~iscell(castopts.oxyrev.H3)
        castopts.oxyhyst.H3 = repmat({castopts.oxyhyst.H3},nox,1);
    end
    for no = 1:nox
        var0 = [oxyvars{no,1} revstring];
        thisvar = find(strcmp(var0, h.fldnam));
        hnew.fldnam{nvar+no} = oxyvars{no,2};
        hnew.fldunt(nvar+no) = h.fldunt(thisvar);
        dnew.(oxyvars{no,2}) = mcoxyhyst(d.(var0), d.time, d.press, castopts.oxyhyst.H1{no}, castopts.oxyhyst.H2{no}, castopts.oxyhyst.H3{no});
        %record whether a non-default calibration is set, for mstar comment
        if length(castopts.oxyhyst.H1{no})>1 || length(castopts.oxyhyst.H2{no})>1 || length(castopts.oxyhyst.H3{no})>1
            ohtyp(no) = 2;
        elseif max(abs(castopts.oxyhyst.H_0-[castopts.oxyhyst.H1{no} castopts.oxyhyst.H2{no} castopts.oxyhyst.H3{no}]))>0
            ohtyp(no) = 1;
        else
            ohtyp(no) = 0;
        end
    end
    ohtyp = max(ohtyp);
    if ohtyp>0
        %and add comments to file
        hnew.comment = [hnew.comment 'oxygen hysteresis correction different from SBE default applied'];
        if ohtyp == 2
            hnew.comment = [hnew.comment ' (depth-varying)'];
        end
    end
    
end
