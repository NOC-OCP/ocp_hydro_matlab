% mctd_02b: oxygen hysteresis and other corrections to raw file (or
% raw_cleaned file)
%
% Use: mctd_02b        and then respond with station number, or for station 16
%      stn = 16; mctd_02;
%
% uses parameters set in mexec_processing_scripts/cruise_options/opt_${cruise}

minit;
mdocshow(mfilename, ['makes corrections/conversions (for instance for oxygen hysteresis), as set in get_cropt and opt_' mcruise '.m) and writes to ctd_' mcruise '_' stn_string '_24hz.nc']);

% resolve root directories for various file types
root_ctd = mgetdir('M_CTD');

prefix = ['ctd_' mcruise '_'];

%figure out which file to start from
infile = [root_ctd '/' prefix stn_string '_raw_cleaned'];
if ~exist(m_add_nc(infile), 'file')
    infile = [root_ctd '/' prefix stn_string '_raw'];
end

otfile = [root_ctd '/' prefix stn_string '_24hz'];
unix(['/bin/cp ' m_add_nc(infile) ' ' m_add_nc(otfile)])
unix(['chmod 644 ' m_add_nc(otfile)]); % make file writeable

%which corrections to do?
scriptname = mfilename; oopt = 'raw_corrs'; get_cropt
scriptname = 'castpars'; oopt = 'oxyvars'; get_cropt
nox = size(oxyvars,1);


%oxygen hysteresis and/or renaming oxygen variables
if dooxyrev | dooxyhyst
    
    if dooxyrev
        %calculate oxy_rev, the oxygen hysteresis reversed variables, and
        %add to otfile
        scriptname = mfilename; oopt = 'oxyrev'; get_cropt
        varsin = [];
        for no = 1:nox
            varsin = [varsin ' ' oxyvars{no,1}];
        end
        varsin = ['press time' varsin];
        [d,h] = mloadq(infile, varsin);
        scriptname = mfilename; oopt = 'oxyrev'; get_cropt
        otfilestruct=struct('name',[otfile '.nc']);
        disp(['reversing oxy hyst for ' stn_string ', output to _rev'])
        for no = 1:nox
            oxy_unhyst = mcoxyhyst_reverse(getfield(d, oxyvars{no,1}), d.time, d.press, H1, H2, H3);
            vind = find(strcmp(oxyvars{no,1}, h.fldnam)); %same units
            datastruct = struct('name',[oxyvars{no,1} '_rev'], 'units',h.fldunt{vind}, 'data',oxy_unhyst);
            m_write_variable(otfilestruct, datastruct);
        end
        revstring = '_rev'; %if dooxyhyst will apply to _rev variables
    else
        revstring = ''; %if dooxyhyst will apply to original variables
    end
    
    if dooxyhyst
        %calculate the variables with oxygen hysteresis applied, and add to
        %otfile
        scriptname = mfilename; oopt = 'oxyhyst'; get_cropt
        %record whether a non-default calibration is set, for mstar comment
        if length(H1)>1 | length(H2)>1 | length(H3)>1
            ohtyp = 2;
        elseif max(abs(H_0-[H1 H2 H3]))>0
            ohtyp = 1;
        else
            ohtyp = 0;
        end
        varsin = [];
        for no = 1:nox
            %start from reversed variables if set above, otherwise
            %(revstring is empty) start from sbe variables
            varsin = [varsin ' ' oxyvars{no,1} revstring];
        end
        varsin = ['press time' varsin];
        [d,h] = mloadq(infile,varsin);
        scriptname = mfilename; oopt = 'oxyhyst'; get_cropt
        otfilestruct=struct('name',[otfile '.nc']);
        disp(['applying oxy_hyst for ' stn_string ', output to'])
        disp(sprintf('%s ',oxyvars{:,2}))
        for no = 1:nox
            oxy_out = mcoxyhyst(getfield(d, [oxyvars{no,1} revstring]), d.time, d.press, H1, H2, H3);
            vind = find(strcmp(oxyvars{no,1}, h.fldnam)); %same units
            datastruct = struct('name',oxyvars{no,2}, 'units',h.fldunt{vind}, 'data',oxy_out);
            m_write_variable(otfilestruct, datastruct);
        end
        if ohtyp>0
            %and add comments to file
            if ohtyp == 1
                comment = 'oxygen hysteresis correction different from SBE default applied';
            elseif ohtyp == 2
                comment = [comment ' (depth-varying)'];
            end
            ncfile.name = m_add_nc(infile);
            m_add_comment(ncfile,comment);
        end
        
    end
    
else
    %just rename oxyvars(:,1) to oxyvars(:,2)
    hin = m_read_header(otfile); % get var names and units in file
    snames_units = {};
    for no = 1:nox
        kmatch = strmatch(oxyvars{no,1},hin.fldnam,'exact'); %to use the same units
        if length(kmatch)==1
            snames_units = [snames_units; oxyvars{no,1}; oxyvars{no,2}; hin.fldunt{kmatch}];
        end
    end
    MEXEC_A.MARGS_IN = {otfile; 'y'; '8'; snames_units; '-1'; '-1'}; %***check this is correct
    mheadr
    
end


%turbidity conversion from turbidity volts
if doturbV
    disp(['computing turbidity from turbidity volts for ' stn_string])
    scriptname = mfilename; oopt = 'turbVpars'; get_cropt
    MEXEC_A.MARGS_IN = {
        otfile
        'y'
        'turbidity'
        'turbidityV'
        sprintf('y = (x1-%f)*%f;', turbVpars(2), turbVpars(1))
        ' '
        'm^-1/sr'
        ' '
        };
    mcalib2;
end
