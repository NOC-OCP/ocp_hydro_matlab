% mctd_02:
%
% apply automatic edits to raw file (_raw_cleaned if it exists, otherwise
% _raw_noctm, otherwise _raw),
% apply align and celltm corrections if set in opt_cruise,
% apply oxygen hysteresis and other corrections to raw (or raw_cleaned)
% file
%
% output: _raw_cleaned and _24hz
%
% Use: mctd_02        and then respond with station number, or for station 16
%      stn = 16; mctd_02;
%
% calls:
%     mcalib2
%     mctd_rawedit
%     m_write_variable
%     m_add_comment
%     mheadr
%     mfsave

%%%%% setup %%%%%

m_common; MEXEC_A.mprog = mfilename;
scriptname = 'castpars'; oopt = 'minit'; get_cropt
mdocshow(mfilename, ['makes corrections/conversions (for instance for oxygen hysteresis), as set in get_cropt and opt_' mcruise '.m) and writes to ctd_' mcruise '_' stn_string '_24hz.nc']);

% resolve root directories for various file types
root_ctd = mgetdir('M_CTD');

prefix = ['ctd_' mcruise '_' stn_string];

cleanfile = fullfile(root_ctd, [prefix '_raw_cleaned.nc']);
infile1 = fullfile(root_ctd, [prefix '_raw.nc']);
infile0 = fullfile(root_ctd, [prefix '_raw_noctm.nc']);
otfile24 = fullfile(root_ctd, [prefix stn_string '_24hz']);

%figure out which file to start from
if exist(cleanfile, 'file') && exist(infile0, 'file')
    m = {'both _raw_noctm and _raw_cleaned exist, so will start from _raw_cleaned;'
        'if mctd_01 has just been rerun with redoctm set, remove _raw_cleaned file'
        'now to start from _raw_noctm instead.'
        'return to continue'};
    fprintf(MEXEC_A.Mfider,'%s\n',m{:})
    pause
end
redoctm = 0;
if ~exist(cleanfile, 'file')
    if ~exist(infile0, 'file')
        infile = infile1; %start from _raw
    else
        infile = infile0; %start from _raw_noctm
        redoctm = 1;
    end
    copyfile(m_add_nc(infile), m_add_nc(cleanfile));
    system(['chmod 644 ' m_add_nc(cleanfile)]);
    didedits = 0;
else
    infile = cleanfile; %start from _raw_cleaned
    didedits = 1; %record: have already done some before (e.g. in mctd_rawedit?***)
end


%%%%% automatic edits, producing or modifying _raw_cleaned file %%%%%

scriptname = mfilename; oopt = 'rawedit_auto'; get_cropt
didedits = didedits + ctd_apply_autoedits(cleanfile, castopts);
MEXEC_A.Mprog = mfilename; %reset
if didedits==0
    delete(m_add_nc(cleanfile))
    filename = infile1;
    if redoctm
        copyfile(m_add_nc(infile0), m_add_nc(infile1))
    end
else
    filename = cleanfile;
end

%if we were editing _noctm file, apply align and celltm corrections now
if redoctm
    ctd_apply_align_celltm(filename);
    MEXEC_A.Mprog = mfilename;
end

system(['chmod 444 ' m_add_nc(filename)]);


%%%%% now do corrections to produce _24hz file %%%%%

copyfile(m_add_nc(filename), m_add_nc(otfile24));

%which corrections to do?
scriptname = mfilename; oopt = 'raw_corrs'; get_cropt

%%%%% oxygen hysteresis and/or renaming oxygen variables %%%%%
if dooxyrev || dooxyhyst
    ctd_apply_oxyhyst(otfile24, castopts)
    MEXEC_A.Mprog = mfilename;
else
    scriptname = 'castpars'; oopt = 'oxyvars'; get_cropt
    nox = size(oxyvars,1);
    %just rename oxyvars(:,1) to oxyvars(:,2)
    hin = m_read_header(otfile2); % get var names and units in file
    snames_units = cell(3,nox);
    n = 0;
    for no = 1:nox
        kmatch = strcmp(oxyvars{no,1},hin.fldnam); %to use the same units
        if length(kmatch)==1
            n = n+1;
            snames_units(:,n) = {oxyvars{no,1}; oxyvars{no,2}; hin.fldunt{kmatch}};
        end
    end
    snames_units = snames_units(:,1:n);
    MEXEC_A.MARGS_IN = {otfile24; 'y'; '8'; snames_units(:); '-1'; '-1'}; %***check this is correct
    mheadr
    
end


%%%%% turbidity conversion from turbidity volts %%%%%
if doturbV
    disp(['computing turbidity from turbidity volts for ' stn_string])
    scriptname = mfilename; oopt = 'turbVpars'; get_cropt
    MEXEC_A.MARGS_IN = {
        otfile24
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
if isfield(castopts, 'calstr') && sum(cell2mat(struct2cell(castopts.docal)))
    
    %load data and initialise
    [d0,h0] = mloadq(otfile24, '/');
    if ~isfield(d0, 'statnum')
        d0.statnum = repmat(stnlocal, size(d0.scan));
    end
    
    %apply calibrations %***t first etc?
    [dcal, hcal] = ctd_apply_cals(d0, h0, castopts.docal, castopts.calstr);
    
    %if there were calibrations applied to any variables, save those back
    %to 24hz file (overwriting uncalibrated versions)
    if ~isempty(hcal.fldnam)
        mfsave(otfile24, dcal, hcal, '-addvars');
    end
    
end
