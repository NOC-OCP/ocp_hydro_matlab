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
    for no = 1:nox
        oxy_unhyst = mcoxyhyst_reverse(d.(oxyvars{no,1}), d.time, d.press, castopts.oxyrev.H1, castopts.oxyrev.H2, castopts.oxyrev.H3);
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
    %record whether a non-default calibration is set, for mstar comment
    if length(castopts.oxyhyst.H1)>1 || length(castopts.oxyhyst.H2)>1 || length(castopts.oxyhyst.H3)>1
        ohtyp = 2;
    elseif max(abs(castopts.oxyhyst.H_0-[castopts.oxyhyst.H1 castopts.oxyhyst.H2 castopts.oxyhyst.H3]))>0
        ohtyp = 1;
    else
        ohtyp = 0;
    end
    otfilestruct=struct('name',[filename '.nc']);
    disp(['applying oxy_hyst for ' stn_string ', output to'])
    fprintf('%s \n',oxyvars{:,2})
    for no = 1:nox
        oxy_out = mcoxyhyst(d.([oxyvars{no,1} revstring]), d.time, d.press, castopts.oxyhyst.H1, castopts.oxyhyst.H2, castopts.oxyhyst.H3);
        thisvar = strcmp(oxyvars{no,1}, hcal.fldnam); %same units
        datastruct = struct('name',oxyvars{no,2}, 'units',hcal.fldunt{thisvar}, 'data',oxy_out);
        m_write_variable(otfilestruct, datastruct);
    end
    if ohtyp>0
        %and add comments to file
        comment = 'oxygen hysteresis correction different from SBE default applied';
        if ohtyp == 2
            comment = [comment ' (depth-varying)'];
        end
        m_add_comment(otfilestruct, comment);
    end
    
end
