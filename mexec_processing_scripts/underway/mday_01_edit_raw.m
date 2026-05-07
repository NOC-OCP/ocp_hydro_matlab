function didedits = mday_01_edit_raw(abbrev, ydays, mtable)
%function didedits = mday_01_edit_raw(abbrev, ydays, mtable)
%
% abbrev (char) is the mexec short name prefix for the data stream
% ydays is a list of yearydays to operate on (merging into existing file if
% present); if empty will include all, but if not empty will only update
% the listed ydays
%
% follows mday_00_load. operating on one stream (instrument) at a time,
% loads appended raw file, does some automatic edits (see
% mday_01_default_autoedits) and applies (where not already done in the
% sensor or DAS) factory sensor calibrations (e.g. V to scientific units)
% and/or a priori offsets (e.g. adding transducer depth to the measured
% seafloor distance from the transducer) and saves to
% {abbrev}_{cruise}_all_edt.nc.
%
% based on work by bak and efw with revisions by epa dy113; extensively
% revised ylf sd025 and dy181

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
didedits = 0;

%definitions
ii = find(strcmp(abbrev,mtable.mstarpre));
rootdir = fullfile(MEXEC_G.mexec_data_root, mtable.mstardir{ii(1)});
infile = fullfile(rootdir, sprintf('%s_%s_all_raw.nc', abbrev, mcruise));
if ~exist(m_add_nc(infile),'file'); return; end
otfile = [infile(1:end-6) 'edt.nc'];
if exist(otfile,'file')
    didedits = 1; %always add days to file if it already exists
end
streamtype = mtable.paramtype{ii(1)};

%load
[d, h] = mload(infile,'/');

%limit to specified ydays
if ~isempty(ydays)
    ddays = ydays-1;
    uo = sprintf('days since %d-01-01 00:00:00',MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN);
    dd = m_commontime(d, 'time', h, uo);
    m = ismember(floor(dd),ddays);
    d = struct2table(d);
    d = table2struct(d(m,:),'ToScalar',true);
end
if isempty(d.time)
    fprintf(1,'none of specified ydays in file %s; skipping\n',infile)
    return
end

cpstr = '';

%%%%%%%%% correct and calibrate raw data %%%%%%%%%

% fix timestamp problems if known to occur with stream/data system
opt1 = 'uway_proc'; opt2 = 'time_problems'; get_cropt
if fixtimes
    [d, h, comment] = mday_01_fixtimes(d, h, check_mono);
    if ~isempty(comment)
        h.comment = [h.comment comment];
        didedits = 1;
    end
end

% factory/laboratory equations and coefficients for calibration/conversion
% from V/counts to physical units, where not already applied
opt1 = 'uway_proc'; opt2 = 'sensor_unit_conversions'; get_cropt
if isfield(so, 'calstr') && sum(cell2mat(struct2cell(so.docal)))
    [dcal, hcal] = apply_calibrations(d, h, so.calstr, so.docal, 'q');
    for no = 1:length(hcal.fldnam)
        sensor = hcal.fldnam{no};
        m = strcmp(sensor,h.fldnam);
        d.(sensor) = dcal.(sensor);
        h.fldunt(m) = {so.calunits.(sensor)};
        if isfield(so,'instsn') && isfield(so.instsn,sensor)
            if ~isfield(h,'fldserial')
                h.fldserial = repmat({' '},size(h.fldnam));
            end
            h.fldserial(m) = {so.instsn.(sensor)};
        end
    end
    if no>0
        h.comment = [h.comment hcal.comment];
        didedits = 1;
        fprintf(1,'converted units in %s\n',abbrev)
    end
end
% for bathymetry, if necessary apply speed of sound correction and/or
% xducer offset
if ismember(streamtype,{'sbm','mbm'})
    [d, h, comment] = mday_01_cordep(d, h, mtable,so);
    if ~isempty(comment)
        h.comment = [h.comment comment];
        didedits = 1;
        fprintf(1,'corrected for sound speed and/or transducer depth in %s\n',abbrev)
    end
end

% remove bad times, despike, remove out-of-range values, etc.
opt1 = 'uway_proc'; opt2 = 'rawedit'; get_cropt
if isfield(uopts,'badtimes')
    for no = 1:length(uopts.badtimes)
        vars = uopts.badtimes(no).vars;
        for vno = 1:length(vars)
            uopts.badtime.(vars{vno}) = uopts.badtimes(no).times;
        end
    end
end
%clean/edit
if ~isempty(uopts)
    [d, comment] = apply_autoedits(d, uopts);
    if ~isempty(comment)
        h.comment = [h.comment comment];
        didedits = 1;
        fprintf(1,'cleaned in %s\n',abbrev)
    end
end
%add dday variable
timestring = sprintf('days since %d-01-01 00:00:00',MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1));
d.dday = m_commontime(d, 'time', h, timestring);
d0 = d;
h.fldnam = [h.fldnam 'dday'];
h.fldunt = [h.fldunt timestring];
if isfield(h,'fldserial')
    h.fldserial = [h.fldserial ' '];
end
if handedit
    ddays = ydays-1;
    btol = 0.5/86400; %1/2 s
    edfile = fullfile(fileparts(otfile),'editlogs',[abbrev '_' mcruise]);
    if isempty(intersect(vars_to_ed,fieldnames(d)))
        warning('vars_to_ed not in file, using all')
        vars_to_ed = fieldnames(d);
    end
    [d, h] = uway_edit_by_day(d, h, edfile, ddays, btol, vars_to_ed);
end



%%%%%%%%% save %%%%%%%%
if didedits
    if exist(m_add_nc(otfile),'file')
        mfsave(otfile, d, h, '-merge', 'time');
    else
        mfsave(otfile, d, h);
    end
end


% ----------------------------------------------------
%%%%%%%%%% subfunctions %%%%%%%%%%
% ----------------------------------------------------

%%%%% fixtimes %%%%%
%
% [d, comment] = mday_01_fixtimes(d, abbrev);
%
% flag repeated times and (for selected streams) backward time jumps
% and non-finite times (is this required, or taken care of by mday_00_load
% tstep?)
function [d, h, comment] = mday_01_fixtimes(d, h, check_mono)

%%%%% check for repeated times and backward time jumps %%%%%
comment = '';
timvar = munderway_varname('timvar',h.fldnam,'s',1);

if ~isempty(timvar)
    iib = [];
    %repeated times
    deltat = d.(timvar)(2:end) - d.(timvar)(1:end-1);
    deltat = [1; deltat(:)];
    iib = [iib find(deltat==0 | ~isfinite(d.(timvar{no})))];
    %backwards time jumps
    if check_mono
        tflag = m_flag_monotonic(d.(timvar));
        iib = [iib tflag==0];
    end
    if ~isempty(iib)
        for no = 1:length(h.fldnam)
            d.(h.fldnam{no})(iib) = [];
        end
        if check_mono
            comment = [comment '\n repeated times and backwards time jumps removed'];
        else
            comment = [comment '\n repeated times removed'];
        end
    end
end




%%%%% cordep %%%%%
%
% [d, h, comment] = mday_01_cordep(d, h);
%
% for singlebeam echosounder, apply carter table soundspeed correction
% for either type of echosounder, apply transducer depth offset if
% necessary
function [d, h, comment] = mday_01_cordep(d, h, mtable, so)

m_common

depxdvar = munderway_varname('deptrefvar', h.fldnam, 's', 1);
depsfvar = munderway_varname('depsrefvar', h.fldnam, 's', 1);
depvar = munderway_varname('depvar', h.fldnam, 's', 1);
comment = [];

uncdeps = [];
if isfield(so, 'carter_cor')
    if isnumeric(so.carter_cor) && so.carter_cor==1
        uncdeps = {depxdvar,depsfvar,depvar};
    elseif iscell(so.carter_cor)
        uncdeps = so.carter_cor;
    end
end
if isfield(so, 'xducer_offset')
    xd = so.xducer_offset;
else
    xd = [];
end

if ~isempty(uncdeps)
    %find positions to use for carter correction
    opt1 = 'ship'; opt2 = 'datasys_best'; get_cropt
    m = strcmp(default_navstream,mtable.tablenames);
    navfile = fullfile(mgetdir(''), mtable.mstardir{m}, [mtable.mstarpre{m} '_' mcruise '_all_raw.nc']); %in case edt is not made yet, depending on order in list
    if exist(navfile,'file')
        [dn,hn] = mload(navfile,'/');
        latstr = munderway_varname('latvar', hn.fldnam, 1, 's');
        lonstr = munderway_varname('lonvar', hn.fldnam, 1, 's');
        dn.time = m_commontime(dn.time,hn,h);
        lon = interp1(dn.time, dn.(lonstr), d.time);
        lat = interp1(dn.time, dn.(latstr), d.time);

    else
        timvar = munderway_varname('timvar',h.fldnam,1,'s');
        dr = [min(d.(timvar)) max(d.(timvar))];
        dr = m_commontime(dr,h.fldunt(strcmp(timvar,h.fldnam)),'datenum');
        dn1 = dr(1); dn2 = dr(2);
        if strcmp(MEXEC_G.Mshipdatasystem, 'rvdas')
            pos = mrload(default_navstream,dn1,dn2);
        elseif strcmp(MEXEC_G.Mshipdatasystem, 'techsas')
            pos = mtload(default_navstream,dn1,dn2);
        elseif strcmp(MEXEC_G.Mshipdatasystem, 'scs')
            pos = msload(default_navstream,dn1,dn2);
        end
        lonvar = munderway_varname('lonvar',fieldnames(pos),1,'s');
        latvar = munderway_varname('latvar',fieldnames(pos),1,'s');
        ptimvar = munderway_varname('timvar',fieldnames(pos),1,'s');
        t = m_commontime(pos.(ptimvar),pos.varunits{strcmp(ptimvar,pos.varnames)},h.fldunt{strcmp(timvar,h.fldnam)});
        lon = interp1(t, pos.(lonvar), d.(timvar));
        lat = interp1(t, pos.(latvar), d.(timvar));

    end

    for no = 1:length(uncdeps)
        y = mcarter(lat, lon, d.(uncdeps{no}));
        if strcmp('uncdep',uncdeps{no})
            %rename
            d.depth = d.uncdep;
            h = m_append_header_fld(h, {'depth'}, {'m'}, 'uncdep');
            comment = [comment sprintf('\n depth = uncdep with carter table correction applied')];
        else
            %overwrite
            d.(uncdeps{no}) = y.cordep;
        end
    end
    comment = [comment sprintf('\n carter table correction applied to %s',strjoin(setdiff(uncdeps,{'uncdep'}),', '))];

end

if isempty(depsfvar)
    %calculate
    if ~isempty(xd)
        d.waterdepth = d.(depxdvar) + xd;
        comment = [comment sprintf('\n waterdepth = depth relative to transducer + constant transducer depth')];
    elseif ~isempty(depxdvar)
        xdvar = munderway_varname('xducerdepvar', h.fldnam, 's', 1);
        if ~isempty(xdvar)
            d.waterdepth = d.(depxdvar) + d.(xdvar);
            comment = [comment sprintf('\n waterdepth = depth relative to transducer + transducer depth time series')];
        end
    end
else
    %just rename
    d.waterdepth = d.(depsfvar); %***change naming at load stage so this is not necessary (depsf is default, others are dep_xd or dep_unknown)
end
if ~isfield(d,'waterdepth')
    warning('no way to calculate/identify waterdepth relative to surface for %s',abbrev)
elseif ~sum(strcmp('waterdepth',h.fldnam))
    h = m_append_header_fld(h, {'waterdepth'}, {'m'}, depsfvar);
end
