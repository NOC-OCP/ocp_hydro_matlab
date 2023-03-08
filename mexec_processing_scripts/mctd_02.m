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
%     
%     apply_autoedits
%     (optionally) apply_ctd_celltm
%     mfsave
%     apply_oxyhyst
%     apply_calibrations

%%%%% setup %%%%%

m_common; MEXEC_A.mprog = mfilename;
opt1 = 'castpars'; opt2 = 'minit'; get_cropt
if MEXEC_G.quiet<=1; fprintf(1,'applying corrections/conversions (e.g. oxygen hysteresis), as set in get_cropt and opt_%s\n',mcruise); end

% resolve root directories for various file types
root_ctd = mgetdir('M_CTD');

prefix = ['ctd_' mcruise '_' stn_string];

cleanfile = fullfile(root_ctd, [prefix '_raw_cleaned.nc']);
infile1 = fullfile(root_ctd, [prefix '_raw.nc']);
infile0 = fullfile(root_ctd, [prefix '_raw_noctm.nc']);
otfile24 = fullfile(root_ctd, [prefix '_24hz']);

%figure out which file to start from
if exist(m_add_nc(infile0),'file')
    infile = infile0;
    castopts.redoctm = 1;
else
    infile = infile1;
    castopts.redoctm = 0;
end

%get edits to do
if exist('castopts','var')
    fn = fieldnames(castopts);
    ii = find(strncmp('bad',fn,3));
    castopts = rmfield(castopts,fn(ii));
    fn = intersect(fn,{'pumpsNaN';'rangelim';'despike'});
    castopts = rmfield(castopts,fn);
end
castopts.pumpsNaN.temp1 = 12;
castopts.pumpsNaN.temp2 = 12;
castopts.pumpsNaN.cond1 = 12;
castopts.pumpsNaN.cond2 = 12;
castopts.pumpsNaN.oxygen_sbe1 = 8*24;
castopts.pumpsNaN.oxygen_sbe2 = 8*24;
opt1 = mfilename; opt2 = 'rawedit_auto'; get_cropt

[d, h] = mloadq(infile,'/');
if min(d.press)<=-10 && (~isfield(castopts,'badpress') || ((isfield(castopts,'badtemp1') || isfield(castopts,'badtemp2')) && ~castopts.redoctm))
    m = {['negative pressures <-10 in ' infile]};
    if ~castopts.redoctm
        m = [m;
            'check d.press; if there are large spikes also affecting temperature, Ctrl-C'
            'here, edit mctd_01 case in opt_' mcruise ', and reprocess this station from _noctm; otherwise,'];
    end
    m = [m;
        'you may want to edit mctd_02 case (rawedit_auto) to remove large'
        'outlier values in pressure (and other variables) before the mctd_rawedit gui stage.'
        'Enter to continue.'];
    fprintf(1,'%s\n',m{:})
    pause
end


%%%%% edits and corrections, either producing or modifying _raw_cleaned file %%%%%

%automatic %***put in a warning that for oxygen scans selected in
%mctd_rawedit may be off by 6 s (if align done here)
[d, comment] = apply_autoedits(d, castopts);
didedits = 0;
if ~isempty(comment)
    h.comment = [h.comment comment];
    didedits = 1;
end

%reapply hand edits
edfilepat = fullfile(root_ctd,'editlogs',sprintf('mplxyed_*_ctd_%s_%03d',mcruise,stnlocal));
[d, comment] = apply_guiedits(d, 'scan', edfilepat, castopts.redoctm);
if ~isempty(comment)
    h.comment = [h.comment comment];
    didedits = 1;
end

%if we were editing _noctm file, apply align and celltm corrections now
if castopts.redoctm
    d.cond1 = apply_ctd_celltm(d.time, d.temp1, d.cond1);
    d.cond2 = apply_ctd_celltm(d.time, d.temp2, d.cond2);
    h.comment = [h.comment '\n cond corrected for cell thermal mass by ctd_apply_celltm'];
    opt1 = 'castpars'; opt2 = 'oxy_align'; get_cropt
    opt1 = 'castpars'; opt2 = 'oxyvars'; get_cropt
    for no = 1:length(oxyvars)
        d.(oxyvars{no}) = interp1(d.time, d.(oxyvars{no}), d.time+oxy_align);
    end
    h.comment = [h.comment '\n oxygen shifted by ' oxy_align ' s'];
    didedits = 1;
end

%save to _raw_cleaned if there were any changes
if didedits
    if exist(m_add_nc(cleanfile),'file')
        delete(cleanfile)
    end
    mfsave(cleanfile, d, h);
    rawfile_use = cleanfile;
else
    rawfile_use = infile;
end


%%%%% now do corrections to produce _24hz file %%%%%

copyfile(m_add_nc(rawfile_use), m_add_nc(otfile24));
system(['chmod 644 ' m_add_nc(otfile24)]); %in case this was _raw (not _raw_cleaned, which is not write-protected)

%which corrections to do?
castopts.dooxyrev = 0;
castopts.dooxyhyst = 1;
castopts.doturbV = 0;
castopts.dooxy1V = 0; %make 1 or 2 to use temp1 or temp2 to recalculate from voltage
castopts.dooxy2V = 0;
castopts.oxyrev.H1 = -0.033;
castopts.oxyrev.H2 = 5000;
castopts.oxyrev.H3 = 1450;
castopts.oxyhyst.H1 = -0.033;
castopts.oxyhyst.H2 = 5000;
castopts.oxyhyst.H3 = 1450;
castopts.H_0 = [castopts.oxyhyst.H1 castopts.oxyhyst.H2 castopts.oxyhyst.H3]; %this line stores defaults for later reference; don't change!
castopts.turbVpars = [3.343e-3 6.600e-2]; %from XMLCON for BBRTD-182, calibration date 6 Mar 17
opt1 = mfilename; opt2 = 'raw_corrs'; get_cropt
if castopts.dooxyrev
    if sum(sum(isnan(cell2mat(struct2cell(castopts.oxyrev)))))>0
        error('oxygen hysteresis reversal parameters have NaNs; check opt_%s', mcruise)
    end
else
    castopts = rmfield(castopts,'oxyrev');
end
if castopts.dooxyhyst
    try
        a = sum(sum(isnan(cell2mat(castopts.oxyhyst.H1)))) || sum(sum(isnan(cell2mat(castopts.oxyhyst.H2)))) || sum(sum(isnan(cell2mat(castopts.oxyhyst.H3))));
        if a
            error('oxygen hysteresis parameters have NaNs; check opt_%s', mcruise)
        end
    catch
    end
else
    castopts = rmfield(castopts,'oxyhyst');
end
if ~castopts.doturbV
    castopts = rmfield(castopts,'turbVpars');
end

%%%%% oxygen hysteresis and/or renaming oxygen variables %%%%%
[d, h] = mloadq(rawfile_use, '/');
if castopts.dooxy1V>0 && isfield(castopts,'oxy1Vcoefs')
    t = d.(['temp' num2str(castopts.dooxy1V)]);
    c = d.(['cond' num2str(castopts.dooxy1V)]);
    s = gsw_SP_from_C(c,t,d.press);
    d.oxygen_sbe1 = calculate_oxy_from_V(d.sbeoxyV1, d.time, d.press, t, s, castopts.oxy1Vcoefs);
    h.comment = [h.comment '\n oxygen_sbe1 recalculated from sbeoxyV1 using CTD' num2str(castopts.dooxy1V) ' '];
else
    castopts.dooxy1V = 0;
end
if castopts.dooxy2V>0 && isfield(castopts,'oxy2Vcoefs')
    d0 = d;
    t = d.(['temp' num2str(castopts.dooxy2V)]);
    c = d.(['cond' num2str(castopts.dooxy2V)]);
    s = gsw_SP_from_C(c,t,d.press);
    d.oxygen_sbe2 = mcoxy_from_V(d.sbeoxyV2, d.time, d.press, t, s, castopts.oxy2Vcoefs);
    h.comment = [h.comment '\n oxygen_sbe2 recalculated from sbeoxyV2 using CTD' num2str(castopts.dooxy2V) ' '];
end
if castopts.dooxyrev || castopts.dooxyhyst
    [dnew, hnew] = apply_oxyhyst(d, h, castopts);
else
    %just rename oxyvars(:,1) to oxyvars(:,2)
    opt1 = 'castpars'; opt2 = 'oxyvars'; get_cropt
    nox = size(oxyvars,1);
    clear dnew hnew
    for no = 1:nox
        dnew.(oxyvars{no,2}) = d.(oxyvars{no,1});
        kmatch = find(strcmp(oxyvars{no,1},h.fldnam));
        hnew.fldnam(no) = h.fldnam(kmatch);
        hnew.fldunt(no) = h.fldunt(kmatch);
        h.fldnam(kmatch) = hnew.fldnam(no); %now overwrite, for keep_vatts
    end
    hnew = keep_hvatts(hnew, h);
    hnew.comment = 'oxygen variables copied';
end

%%%%% turbidity conversion from turbidity volts %%%%%
if castopts.doturbV
    dnew.turbidity = (d.turbidityV-castopts.turbVpars(2))*castopts.turbVpars(1);
    hnew.fldnam = [hnew.fldnam 'turbidity'];
    hnew.fldunt = [hnew.fldunt 'm^-1/sr'];
    hnew.comment = [hnew.comment '\n turbidity converted from turbidity volts'];
    h.fldnam{strcmp('turbidityV',h.fldnam)} = 'turbidity';
    hnew = keep_hvatts(hnew, h);
end

%%%%% save the new or overwritten variables %%%%%
mfsave(otfile24, dnew, hnew, '-addvars');


%%%%% sensor calibrations %%%%%
opt1 = 'calibration'; opt2 = 'ctd_cals'; get_cropt
if isfield(castopts, 'calstr') && sum(cell2mat(struct2cell(castopts.docal)))

    %load data and initialise
    [d0,h0] = mloadq(otfile24, '/');
    if ~isfield(d0, 'statnum')
        d0.statnum = repmat(stnlocal, size(d0.scan));
    end

    %apply calibrations
    [dcal, hcal] = apply_calibrations(d0, h0, castopts.calstr, castopts.docal, 'q');
    hcal = keep_hvatts(hcal, h0);

    %if there were calibrations applied to any variables, save those back
    %to 24hz file (overwriting uncalibrated versions)
    if ~isempty(hcal.fldnam)
        mfsave(otfile24, dcal, hcal, '-addvars');
    end

end

