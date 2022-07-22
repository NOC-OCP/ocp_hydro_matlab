% mctd_02:
%
% apply automatic edits to raw file (_raw_cleaned if it exists, otherwise
% _raw_noctm, otherwise _raw),
% apply align and celltm corrections if set in opt_cruise,
% apply oxygen hysteresis and other corrections to raw (or raw_cleaned)
% file
% and applies calibrations if set in opt_cruise
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
if MEXEC_G.quiet<=1; fprintf(1,'applying corrections/conversions (e.g. oxygen hysteresis), as set in get_cropt and opt_%s\n',mcruise); end

% resolve root directories for various file types
root_ctd = mgetdir('M_CTD');

prefix = ['ctd_' mcruise '_' stn_string];

cleanfile = fullfile(root_ctd, [prefix '_raw_cleaned.nc']);
infile1 = fullfile(root_ctd, [prefix '_raw.nc']);
infile0 = fullfile(root_ctd, [prefix '_raw_noctm.nc']);
otfile24 = fullfile(root_ctd, [prefix '_24hz']);

%figure out which file to start from
if exist(cleanfile, 'file') && exist(infile0, 'file')
    m = {'both _raw_noctm and _raw_cleaned exist, so will start from _raw_cleaned;'
        'if mctd_01 has just been rerun with redoctm set, remove _raw_cleaned file'
        'now to start from _raw_noctm instead.'
        'return to continue'};
    fprintf(MEXEC_A.Mfider,'%s\n',m{:});
    pause
end
castopts.redoctm = 0;
if ~exist(cleanfile, 'file')
    if ~exist(infile0, 'file')
        infile = infile1; %start from _raw
    else
        infile = infile0; %start from _raw_noctm
        castopts.redoctm = 1;
    end
    didedits = 0;
else
    infile = cleanfile; %start from _raw_cleaned
end


%%%%% automatic edits, either producing or modifying _raw_cleaned file %%%%%

scriptname = mfilename; oopt = 'rawedit_auto'; get_cropt
[d, h] = mloadq(infile, '/');
[d, comment] = apply_autoedits(d, castopts);
didedits = 0;
if ~isempty(comment)
    h.comment = [h.comment comment];
    didedits = 1;
end

%if we were editing _noctm file, apply align and celltm corrections now
if castopts.redoctm
    d.cond1 = apply_ctd_celltm(d.time, d.temp1, d.cond1);
    d.cond2 = apply_ctd_celltm(d.time, d.temp2, d.cond2);
    h.comment = [h.comment; '\n cond corrected for cell thermal mass by ctd_apply_celltm'];
    scriptname = 'castpars'; oopt = 'oxy_align'; get_cropt
    for no = 1:length(ovars)
        d.(ovars{no}) = interp1(d.time, d.(ovars{no}), d.time+oxy_align);
    end
    h.comment = [h.comment '\n oxygen shifted by ' oxy_align ' s'];
    didedits = 1;
end

if didedits
    mfsave(cleanfile, d, h);
    rawfile_use = cleanfile;
else
    rawfile_use = infile;
end

%%%%% now do corrections to produce _24hz file %%%%%

copyfile(m_add_nc(rawfile_use), m_add_nc(otfile24));
system(['chmod 644 ' m_add_nc(otfile24)]); %in case this was _raw (not _raw_cleaned, which is not write-protected)

%which corrections to do?
scriptname = mfilename; oopt = 'raw_corrs'; get_cropt

%%%%% oxygen hysteresis and/or renaming oxygen variables %%%%%
[d, h] = mloadq(rawfile_use, '/');
if castopts.dooxyrev || castopts.dooxyhyst
    [dnew, hnew] = apply_oxyhyst(d, h, castopts);
else
    %just rename oxyvars(:,1) to oxyvars(:,2)
    scriptname = 'castpars'; oopt = 'oxyvars'; get_cropt
    nox = size(oxyvars,1);
    clear dnew hnew
    for no = 1:nox
        dnew.(oxyvars{no,2}) = d.(oxyvars{no,1});
        kmatch = find(strcmp(oxyvars{no,1},h.fldnam));
        hnew.fldnam(no) = h.fldnam(kmatch);
        hnew.fldunt(no) = h.fldunt(kmatch);
    end
    hnew.comment = 'oxygen variables copied';
end

%%%%% turbidity conversion from turbidity volts %%%%%
if castopts.doturbV
    dnew.turbidity = (d.turbidityV-castopts.turbVpars(2))*castopts.turbVpars(1);
    hnew.fldnam = [hnew.fldnam 'turbidity'];
    hnew.fldunt = [hnew.fldunt 'm^-1/sr'];
    hnew.comment = [hnew.comment '\n turbidity converted from turbidity volts'];
end

%%%%% save the new or overwritten variables %%%%%
mfsave(otfile24, dnew, hnew, '-addvars');


%%%%% sensor calibrations %%%%%
scriptname = mfilename; oopt = 'ctdcals'; get_cropt
if isfield(castopts, 'calstr')

    %select calibrations to apply and put in calstr
    calstr = select_calibrations(castopts.docal, castopts.calstr);
    
    if ~isempty(calstr)

        %load data and initialise
        [d0,h0] = mloadq(otfile24, '/');
        if ~isfield(d0, 'statnum')
            d0.statnum = repmat(stnlocal, size(d0.scan));
        end

        %apply calibrations
        [dcal, hcal] = apply_calibrations(d0, h0, calstr);

        %if there were calibrations applied to any variables, save those back
        %to 24hz file (overwriting uncalibrated versions)
        if ~isempty(hcal.fldnam)
            mfsave(otfile24, dcal, hcal, '-addvars');
        end

    end

end
