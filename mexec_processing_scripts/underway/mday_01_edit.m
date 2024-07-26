function didedits = mday_01_edit(abbrev, ydays, mtable)
%function didedits = mday_01_edit(abbrev, ydays, mtable)
%
% abbrev (char) is the mexec short name prefix for the data stream
% ydays is a list of yearydays to operate on (merging into existing file if
% present); if empty will include all, but if not empty will only update
% the listed ydays
%
% operating on one stream (instrument) at a time, load appended file, do
% some automatic edits and apply factory sensor calibrations, and save to 
% {abbrev}_{cruise}_all_edt.nc
%
% later steps will combine multiple streams (instruments) and do additional
% calculations, averaging, and editing as well as cruise-specific
% calibration
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

ydays=[185:206]

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
% from V to physical units, where not already applied
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

% remove bad times, despike, remove out-of-range values, etc.
opt1 = 'uway_proc'; opt2 = 'rawedit'; get_cropt
timestring = sprintf('days since %d-01-01 00:00:00',MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1));
d.dday = m_commontime(d, 'time', h, timestring);
h.fldnam = [h.fldnam 'dday'];
h.fldunt = [h.fldunt timestring];
if ~isempty(uopts)
    [d, comment] = apply_autoedits(d, uopts);
    if ~isempty(comment)
        h.comment = [h.comment comment];
        didedits = 1;
        fprintf(1,'cleaned in %s\n',abbrev)
    end
end
if handedit
    ddays = ydays-1;
    edfile = fullfile(fileparts(otfile),'editlogs',[abbrev '_' mcruise]);
    [d, h] = edit_by_day(d, h, edfile, ddays, 1/2, vars_to_ed);
end

% speed of sound correction
if strcmp(streamtype,'sbm')
    [d, h, comment] = mday_01_cordep(d, h, mtable); 
    if ~isempty(comment)
        h.comment = [h.comment comment];
        didedits = 1;
        fprintf(1,'corrected for sound speed in %s\n',abbrev)
    end
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
function [d, h, comment] = mday_01_cordep(d, h, mtable)

m_common

depbtvar = munderway_varname('deptrefvar', h.fldnam, 's');
depsfvar = munderway_varname('depsrefvar', h.fldnam, 's');
depvar = munderway_varname('depvar', h.fldnam, 's');
depvars = union(union(depbtvar,depsfvar),depvar);

%find positions to use for carter correction
opt1 = 'ship'; opt2 = 'datasys_best'; get_cropt
m = strcmp(default_navstream,mtable.tablenames);
navfile = fullfile(mgetdir(''), mtable.mstardir{m}, [default_navstream '_' mcruise '_all_raw.nc']); %in case edt is not made yet, depending on order in list
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
    lon = interp1(pos.(ptimvar), pos.(lonvar), d.(timvar));
    lat = interp1(pos.(ptimvar), pos.(latvar), d.(timvar));

end

comment = [];
for no = 1:length(depvars)
    y = mcarter(lat, lon, d.(depvars{no}));
    if strcmp('uncdepth',depvars{no})
        %replace uncdepth with depth ***check not overwriting first?
        d.depth = y.cordep;
        d = rmfield(d,'uncdepth');
        h.fldunt(strcmp(h.fldnam,'uncdepth')) = [];
        h.fldnam(strcmp(h.fldnam,'uncdepth')) = [];
        %***h.fldinst
        h.fldnam = [h.fldnam 'depth'];
        h.fldunt = [h.fldunt 'm'];
    else
        %just overwrite, and add comment
        d.(depvars{no}) = y.cordep;
    end
    comment = [comment sprintf('\n carter table correction applied to %s',depvars{no})];
end

