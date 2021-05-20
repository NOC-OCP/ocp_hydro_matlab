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
infile = fullfile(root_ctd, [prefix stn_string '_raw_cleaned']);
if ~exist(m_add_nc(infile), 'file')
    infile = fullfile(root_ctd, [prefix stn_string '_raw']);
end
    
otfile = fullfile(root_ctd, [prefix stn_string '_24hz']);
copyfile(m_add_nc(infile), m_add_nc(otfile));
unix(['chmod 644 ' m_add_nc(otfile)]); % make file writeable

%which corrections to do?
scriptname = mfilename; oopt = 'raw_corrs'; get_cropt
scriptname = 'castpars'; oopt = 'oxyvars'; get_cropt
nox = size(oxyvars,1);

MEXEC_A.Mprog = mfilename;

%%%%% oxygen hysteresis and/or renaming oxygen variables %%%%%

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
        [d,hcal] = mloadq(infile, varsin);
        scriptname = mfilename; oopt = 'oxyrev'; get_cropt
        otfilestruct=struct('name',[otfile '.nc']);
        disp(['reversing oxy hyst for ' stn_string ', output to _rev'])
        for no = 1:nox
            oxy_unhyst = mcoxyhyst_reverse(getfield(d, oxyvars{no,1}), d.time, d.press, H1, H2, H3);
            vind = find(strcmp(oxyvars{no,1}, hcal.fldnam)); %same units
            datastruct = struct('name',[oxyvars{no,1} '_rev'], 'units',hcal.fldunt{vind}, 'data',oxy_unhyst);
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
        [d,hcal] = mloadq(infile,varsin);
        scriptname = mfilename; oopt = 'oxyhyst'; get_cropt
        %record whether a non-default calibration is set, for mstar comment
        if length(H1)>1 | length(H2)>1 | length(H3)>1
            ohtyp = 2;
        elseif max(abs(H_0-[H1 H2 H3]))>0
            ohtyp = 1;
        else
            ohtyp = 0;
        end
        otfilestruct=struct('name',[otfile '.nc']);
        disp(['applying oxy_hyst for ' stn_string ', output to'])
        disp(sprintf('%s ',oxyvars{:,2}))
        for no = 1:nox
            oxy_out = mcoxyhyst(getfield(d, [oxyvars{no,1} revstring]), d.time, d.press, H1, H2, H3);
            vind = find(strcmp(oxyvars{no,1}, hcal.fldnam)); %same units
            datastruct = struct('name',oxyvars{no,2}, 'units',hcal.fldunt{vind}, 'data',oxy_out);
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


%%%%% turbidity conversion from turbidity volts %%%%%

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


%%%%% sensor calibrations %%%%%

if tempcal | condcal | oxygencal | fluorcal | transmittancecal
    %if any are true, get whole list and test for which to apply below
    scriptname = mfilename; oopt = 'ctdcals'; get_cropt
    
    if size(calstr,1)>0
        
        %initialise
        [d0,h0] = mloadq(otfile, '/');
        clear dcal hcal
        hcal.fldnam = {}; hcal.fldunt = {}; hcal.comment = '';
        
        for sno = 1:size(calstr,1)
            
            iis = strfind(calmsg{sno,1},[' ' mcruise]);
            calsens = calmsg{sno,1}(1:iis-1);
            
            %figure out if this calstr should be applied, depending on flag set
            %above in oopt = 'raw_corrs' call to get_cropt
            if ~isempty(str2num(calsens(end)))
                calvar = calsens(1:end-1);
            else
                calvar = calsens;
            end
            eval(['docal = ' calvar 'cal;'])
            
            if docal
                %apply, and store in hcal
                fprintf(1,'\n%s\n\n',calstr{sno})
                eval([calstr{sno}]);
                ii = find(strcmp(calsens,h0.fldnam));
                hcal.fldnam = [hcal.fldnam calsens]; hcal.fldunt = [hcal.fldunt h0.fldunt(ii)];
                hcal.comment = [hcal.comment sprintf('calibration (%s) applied to %s using %s\n', calmsg{sno,2}, calsens, calstr{sno})];
            end
            
        end
        
        %if there were calibrations applied to any variables, save those back
        %to 24hz file (overwriting uncalibrated versions)
        if length(hcal.fldnam)>0
            mfsave(otfile, dcal, hcal, '-addvars');
        end
%         
    end
end
