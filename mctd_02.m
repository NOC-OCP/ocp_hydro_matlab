% mctd_02: 
%
% input: _raw_cleaned if it exists; otherwise _raw_noctm if it exists;
%     otherwise _raw
%
% apply automatic edits to raw file;
% apply align and celltm corrections if set in opt_cruise; 
% apply oxygen hysteresis and other corrections to raw file (or
% raw_cleaned file)
%
% output: _raw_cleaned and _24hz
%
% Use: mctd_02b        and then respond with station number, or for station 16
%      stn = 16; mctd_02;
%
% calls: 
%     mcalib2
%     mctd_rawedit
%     m_write_variable
%     m_add_comment
%     mheadr
%     mfsave

m_common; MEXEC_A.mprog = mfilename;
scriptname = 'castpars'; oopt = 'minit'; get_cropt
mdocshow(mfilename, ['makes corrections/conversions (for instance for oxygen hysteresis), as set in get_cropt and opt_' mcruise '.m) and writes to ctd_' mcruise '_' stn_string '_24hz.nc']);

% resolve root directories for various file types
root_ctd = mgetdir('M_CTD');

prefix = ['ctd_' mcruise '_' stn_string];

infile = fullfile(root_ctd, [prefix '_raw_cleaned.nc']);
infile1 = fullfile(root_ctd, [prefix '_raw.nc']);
infile0 = fullfile(root_ctd, [prefix '_raw_noctm.nc']);
otfile1 = infile;
otfile2 = fullfile(root_ctd, [prefix stn_string '_24hz']);

%figure out which file to start from
if exist(infile, 'file') && exist(infile0, 'file')
    m = {'both _raw_noctm and _raw_cleaned exist, so will start from _raw_cleaned;'
        'if mctd_01 has just been rerun with redoctm set, remove _raw_cleaned file'
        'now to start from _raw_noctm instead.'
        'return to continue'};
    fprintf(MEXEC_A.Mfider,'%s\n',m{:})
    pause
end
redoctm = 0; isrc = 1;
if ~exist(infile,'file')
    isrc = 0;
    if ~exist(infile0,'file')
        infile = infile1; %start from _raw
    else
        infile = infile0; %start from _raw_noctm
        redoctm = 1;
    end
end    

copyfile(m_add_nc(infile), m_add_nc(otfile1));
system(['chmod 644 ' m_add_nc(otfile1)]);


%do automatic edits
scriptname = mfilename; oopt = 'rawedit_auto'; get_cropt
if redoctm
    %edit out scans when pumps are off, plus expected recovery times
    if length(pvars)>0
        MEXEC_A.MARGS_IN = {otfile1; 'y'};
        for no = 1:size(pvars,1)
            pmstring = sprintf('y = x1; pmsk = repmat([1:length(x2)], %d+1, 1)+repmat([-%d:0]'', 1, length(x2)); pmsk(pmsk<1) = 1; pmsk = sum(1-x2(pmsk),1); y(find(pmsk)) = NaN;', pvars{no,2}, pvars{no,2});
            MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; pvars{no,1}; [pvars{no,1} ' pumps']; pmstring; ' '; ' '];
            disp(['will edit out pumps off times plus ' num2str(pvars{no,2}) ' scans from ' pvars{no}])
        end
        MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; ' '];
        mcalib2; end
end
if ~isrc && (~isempty(sevars) || ~isempty(revars) || ~isempty(dsvars))
    warning('you appear to be applying automatic edits without having inspected the raw file')
    %pause
end
rawedit_nogui = 1; mctd_rawedit %all the rest: sevars, revars, dsvars
MEXEC_A.Mprog = mfilename; %reset

%align and celltm if necessary
if redoctm
    MEXEC_A.MARGS_IN = {
        otfile1
        'y'
        'cond1'
        'time temp1 cond1'
        'y = ctd_apply_celltm(x1,x2,x3);'
        ' '
        ' '
        'cond2'
        'time temp2 cond2'
        'y = ctd_apply_celltm(x1,x2,x3);'
        ' '
        ' '
        };
    scriptname = 'castpars'; oopt = 'oxy_align'; get_cropt
    for no = 1:length(ovars)
        MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN;
            ovars{no}
            ['time ' ovars{no}]
            sprintf('y = interp1(x1,x2,x1+%d);',oxy_align)
            ' '
            ' '
            ];
    end
    MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; ' '];
    mcalib2
end

%%%%% end of work on _raw* file %%%%%


%%%%% now do corrections to produce _24hz file %%%%%

copyfile(m_add_nc(otfile1), m_add_nc(otfile2));

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
        [d,hcal] = mloadq(otfile2, varsin);
        scriptname = mfilename; oopt = 'oxyrev'; get_cropt
        otfilestruct=struct('name',[otfile2 '.nc']);
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
        [d,hcal] = mloadq(otfile2,varsin);
        scriptname = mfilename; oopt = 'oxyhyst'; get_cropt
        %record whether a non-default calibration is set, for mstar comment
        if length(H1)>1 | length(H2)>1 | length(H3)>1
            ohtyp = 2;
        elseif max(abs(H_0-[H1 H2 H3]))>0
            ohtyp = 1;
        else
            ohtyp = 0;
        end
        otfilestruct=struct('name',[otfile2 '.nc']);
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
    hin = m_read_header(otfile2); % get var names and units in file
    snames_units = {};
    for no = 1:nox
        kmatch = strmatch(oxyvars{no,1},hin.fldnam,'exact'); %to use the same units
        if length(kmatch)==1
            snames_units = [snames_units; oxyvars{no,1}; oxyvars{no,2}; hin.fldunt{kmatch}];
        end
    end
    MEXEC_A.MARGS_IN = {otfile2; 'y'; '8'; snames_units; '-1'; '-1'}; %***check this is correct
    mheadr
    
end


%%%%% turbidity conversion from turbidity volts %%%%%
if doturbV
    disp(['computing turbidity from turbidity volts for ' stn_string])
    scriptname = mfilename; oopt = 'turbVpars'; get_cropt
    MEXEC_A.MARGS_IN = {
        otfile2
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
scriptname = mfilename; oopt = 'ctdcals'; get_cropt
if exist('calstr', 'var') && (docal.temp || docal.cond || docal.oxygen || docal.fluor || docal.transmittance)
    
    %load data and initialise
    [d0,h0] = mloadq(otfile2, '/');
    if ~isfield(d0, 'statnum')
        d0.statnum = repmat(stnlocal, size(d0.scan));
    end
    
    %apply calibrations %***t first etc?
    [dcal, hcal] = ctd_apply_cal(d0, h0, docal, calstr);
    
    %if there were calibrations applied to any variables, save those back
    %to 24hz file (overwriting uncalibrated versions)
    if length(hcal.fldnam)>0
        mfsave(otfile2, dcal, hcal, '-addvars');
    end
    
end
