function ctd_apply_oxyhyst(filename, castopts)
%reverse and/or apply oxygen hysteresis correction to _raw_cleaned file,
%producing _24hz file

m_common; MEXEC_A.mprog = mfilename;

scriptname = 'castpars'; oopt = 'oxyvars'; get_cropt
nox = size(oxyvars,1);

if castopts.dooxyrev
    %calculate oxy_rev, the oxygen hysteresis reversed variables, and
    %add to otfile
    varsin = [];
    for no = 1:nox
        varsin = [varsin ' ' oxyvars{no,1}];
    end
    varsin = ['press time' varsin];
    [d,hcal] = mloadq(filename, varsin);
    otfilestruct = struct('name',[filename '.nc']);
    disp(['reversing oxy hyst for ' stn_string ', output to _rev'])
    %if there was only one sensor, or if some params were kept default,
    %they might be scalars
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
        oxy_unhyst = mcoxyhyst_reverse(d.(oxyvars{no,1}), d.time, d.press, castopts.oxyrev.H1{no}, castopts.oxyrev.H2{no}, castopts.oxyrev.H3{no});
        thisvar = strcmp(oxyvars{no,1}, hcal.fldnam); %same units
        datastruct = struct('name',[oxyvars{no,1} '_rev'], 'units',hcal.fldunt{thisvar}, 'data',oxy_unhyst);
        m_write_variable(otfilestruct, datastruct);
    end
    revstring = '_rev'; %if dooxyhyst will apply to _rev variables
else
    revstring = ''; %if dooxyhyst will apply to original variables
end

if dooxyhyst
    %calculate the variables with oxygen hysteresis applied, and add to
    %otfile
    varsin = [];
    for no = 1:nox
        %start from reversed variables if set above, otherwise
        %(revstring is empty) start from sbe variables
        varsin = [varsin ' ' oxyvars{no,1} revstring];
    end
    varsin = ['press time' varsin];
    [d,hcal] = mloadq(filename,varsin);
    otfilestruct=struct('name',[filename '.nc']);
    disp(['applying oxy_hyst for ' stn_string ', output to'])
    fprintf('%s \n',oxyvars{:,2})
    %if there was only one sensor, or if some params were kept default,
    %they might be scalars
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
        %record whether a non-default calibration is set, for mstar comment
        if length(castopts.oxyhyst.H1{no})>1 || length(castopts.oxyhyst.H2{no})>1 || length(castopts.oxyhyst.H3{no})>1
            ohtyp(no) = 2;
        elseif max(abs(castopts.oxyhyst.H_0-[castopts.oxyhyst.H1{no} castopts.oxyhyst.H2{no} castopts.oxyhyst.H3{no}]))>0
            ohtyp(no) = 1;
        else
            ohtyp(no) = 0;
        end
        oxy_out = mcoxyhyst(d.([oxyvars{no,1} revstring]), d.time, d.press, castopts.oxyhyst.H1{no}, castopts.oxyhyst.H2{no}, castopts.oxyhyst.H3{no});
        thisvar = strcmp(oxyvars{no,1}, hcal.fldnam); %same units
        datastruct = struct('name',oxyvars{no,2}, 'units',hcal.fldunt{thisvar}, 'data',oxy_out);
        m_write_variable(otfilestruct, datastruct);
    end
    ohtyp = max(ohtyp);
    if ohtyp>0
        %and add comments to file
        comment = 'oxygen hysteresis correction different from SBE default applied';
        if ohtyp == 2
            comment = [comment ' (depth-varying)'];
        end
        m_add_comment(otfilestruct, comment);
    end
    
end
