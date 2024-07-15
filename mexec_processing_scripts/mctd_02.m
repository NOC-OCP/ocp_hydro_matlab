function mctd_02(stn)
% mctd_02:
%
% apply automatic edits to raw or _raw_noctm file; if working from
%   _raw_noctm, apply align and celltm coorections as set in opt_cruise;
% save as _raw_cleaned
% then apply oxygen hysteresis and calibrations, again as set in
%   opt_cruise;
% save as _24hz
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
clear co
if exist(m_add_nc(infile0),'file')
    infile = infile0;
    co.redoctm = 1;
else
    infile = infile1;
    co.redoctm = 0;
end

%get default and cruise-(/station-)specific edits to do
opt1 = 'ctd_proc'; opt2 = 'rawedit_auto'; get_cropt

[d, h] = mloadq(infile,'/');
if min(d.press)<=-10 && (~isfield(co,'badpress') || ((isfield(co,'badtemp1') || isfield(co,'badtemp2')) && ~co.redoctm))
    m = {['negative pressures <-10 in ' infile ' may be a problem for GSW functions.']};
    if ~co.redoctm
        m = [m;
            'check d.press; if there are large spikes also affecting temperature, Ctrl-C'
            'here, edit ctd_proc, redoctm case in opt_' mcruise ', and reprocess this station from _noctm; otherwise,'];
    end
    m = [m;
        'you may want to edit ctd_proc, rawedit_auto case of opt_' mcruise ' to remove large'
        'outlier values in pressure (and other variables) before the mctd_rawedit gui stage.'
        'Enter to continue.'];
    fprintf(1,'%s\n',m{:})
    pause
end


%%%%% edits and corrections, either producing or modifying _raw_cleaned file %%%%%

%automatic %***put in a warning that for oxygen scans selected in
%mctd_rawedit may be off by 6 s (if align done here)
[d, comment] = apply_autoedits(d, co);
didedits = 0;
if ~isempty(comment)
    h.comment = [h.comment comment];
    didedits = 1;
end

%reapply hand edits
edfilepat = fullfile(root_ctd,'editlogs',sprintf('mplxyed_*_ctd_%s_%03d',mcruise,stn));
[d, comment] = apply_guiedits(d, 'scan', edfilepat, [co.redoctm stn]);
if ~isempty(comment)
    h.comment = [h.comment comment];
    didedits = 1;
end

%if we were editing _noctm file, apply align and celltm corrections now
if co.redoctm
    d.cond1 = apply_ctd_celltm(d.time, d.temp1, d.cond1);
    d.cond2 = apply_ctd_celltm(d.time, d.temp2, d.cond2);
    h.comment = [h.comment '\n cond corrected for cell thermal mass by ctd_apply_celltm'];
    opt1 = 'castpars'; opt2 = 'oxy_align'; get_cropt
    opt1 = 'castpars'; opt2 = 'oxyvars'; get_cropt
    for no = 1:size(oxyvars,1)
        d.(oxyvars{no}) = interp1(d.time, d.(oxyvars{no}), d.time+oxy_align);
    end
    h.comment = [h.comment '\n oxygen shifted by ' num2str(oxy_align) ' s'];
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

%which corrections to do?
co.dooxyrev = 0;
co.dooxyhyst = 1;
co.doturbV = 0;
co.dooxy1V = 0; %make 1 or 2 to use temp1 or temp2 to recalculate from voltage
co.dooxy2V = 0;
clear oxyrev oxyhyst
opt1 = 'ctd_proc'; opt2 = 'raw_corrs'; get_cropt
if co.dooxyrev
    if sum(sum(isnan(cell2mat(struct2cell(oxyrev)))))>0
        error('oxygen hysteresis reversal parameters have NaNs; check opt_%s', mcruise)
    end
    co.oxyrev = oxyrev;
else
    oxyrev = [];
end
if co.dooxyhyst
    try
        a = sum(sum(isnan(cell2mat(oxyhyst.H1)))) || sum(sum(isnan(cell2mat(oxyhyst.H2)))) || sum(sum(isnan(cell2mat(oxyhyst.H3))));
        if a
            error('oxygen hysteresis parameters have NaNs; check opt_%s', mcruise)
        end
    catch
    end
    co.oxyhyst = oxyhyst;
else
    oxyhyst = [];
end
if co.doturbV
    co.turbVpars = turbVpars;
else
    turbVpars = [];
end

%%%%% oxygen hysteresis and/or renaming oxygen variables %%%%%
[d, h] = mloadq(rawfile_use, '/');
if co.dooxy1V>0 && isfield(co,'oxy1Vcoefs')
    t = d.(['temp' num2str(co.dooxy1V)]);
    c = d.(['cond' num2str(co.dooxy1V)]);
    s = gsw_SP_from_C(c,t,d.press);
    d.oxygen_sbe1 = calculate_oxy_from_V(d.sbeoxyV1, d.time, d.press, t, s, co.oxy1Vcoefs);
    h.comment = [h.comment '\n oxygen_sbe1 recalculated from sbeoxyV1 using CTD' num2str(co.dooxy1V) ' '];
else
    co.dooxy1V = 0;
end
if co.dooxy2V>0 && isfield(co,'oxy2Vcoefs')
    d0 = d;
    t = d.(['temp' num2str(co.dooxy2V)]);
    c = d.(['cond' num2str(co.dooxy2V)]);
    s = gsw_SP_from_C(c,t,d.press);
    d.oxygen_sbe2 = calculate_oxy_from_V(d.sbeoxyV2, d.time, d.press, t, s, co.oxy2Vcoefs);
    h.comment = [h.comment '\n oxygen_sbe2 recalculated from sbeoxyV2 using CTD' num2str(co.dooxy2V) ' '];
end
if co.dooxyrev || co.dooxyhyst
    [dnew, hnew] = apply_oxyhyst(d, h, co);
    fn = fieldnames(dnew);
    for no = 1:length(fn)
        d.(fn{no}) = dnew.(fn{no});
        m = strcmp(fn{no},h.fldnam);
        if ~sum(m)
            h.fldnam = [h.fldnam fn(no)];
            h.fldunt = [h.fldunt hnew.fldunt(m)];
            h.fldserial = [h.fldserial hnew.fldserial(m)];
        end
    end
end
%rename oxyvars(:,1) to oxyvars(:,2)
opt1 = 'castpars'; opt2 = 'oxyvars'; get_cropt
nox = size(oxyvars,1);
for no = 1:nox
    d.(oxyvars{no,2}) = d.(oxyvars{no,1});
    d = rmfield(d,oxyvars{no,1});
    m = strcmp(oxyvars{no,1},h.fldnam);
    h.fldnam(m) = oxyvars(no,2);
end
d = orderfields(d, h.fldnam);

%%%%% turbidity conversion from turbidity volts %%%%%
if co.doturbV
    d.turbidity = (d.turbidityV-co.turbVpars(2))*co.turbVpars(1);
    d = rmfield(d,'turbidityV');
    hnew.comment = [hnew.comment '\n turbidity converted from turbidity volts'];
    h.fldnam{strcmp('turbidityV',h.fldnam)} = 'turbidity';
    d = orderfields(d,h.fldnam);
end

%%%%% save %%%%%
mfsave(otfile24, d, h);


%%%%% sensor calibrations %%%%%
opt1 = 'ctd_proc'; opt2 = 'ctd_cals'; get_cropt
if isfield(co, 'calstr') && sum(cell2mat(struct2cell(co.docal)))

    %load data and initialise
    [d0,h0] = mloadq(otfile24, '/');
    if ~isfield(d0, 'statnum')
        d0.statnum = repmat(stn, size(d0.scan));
    end

    %apply calibrations
    ddu = ['days since ' num2str(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1)) '-01-01 00:00:00'];
    d0.dday = m_commontime(d0,'time',h0,ddu);
    h0.fldnam = [h0.fldnam 'dday']; h0.fldunt = [h0.fldunt ddu]; h0.fldserial = [h0.fldserial ' '];
    [dcal, hcal] = apply_calibrations(d0, h0, co.calstr, co.docal, 'q');
    hcal = keep_hvatts(hcal, h0);

    %if there were calibrations applied to any variables, save those back
    %to 24hz file (overwriting uncalibrated versions)
    if ~isempty(hcal.fldnam)
        mfsave(otfile24, dcal, hcal, '-addvars');
    end

end

