function didedits = mday_01_edit(abbrev, days, mtable)
%function didedits = mday_01_edit(abbrev, days, mtable)
%
% abbrev (char) is the mexec short name prefix for the data stream
% days is a list of yeardays to operate on (merging into existing file if
% present); if empty will include all, but if not empty will only update
% the listed days
%
% load appended file, do some automatic edits and (find and) apply manual
% edits, calculate some derived variables (psal, easting and northing),
% save to {abbrev}_{cruise}_all_edt.nc   
%
% based on work by bak and efw with revisions by epa dy113; extensively
% revised ylf sd025 

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
didedits = 0;

%definitions
ii = find(strcmp(abbrev,mtable.mstarpre)); 
rootdir = fullfile(MEXEC_G.mexec_data_root, mtable.mstardir{ii(1)});
infile = fullfile(rootdir, sprintf('%s_%s_all_raw.nc', abbrev, mcruise));
if ~exist(m_add_nc(infile),'file'); return; end
otfile = [infile(1:end-6) 'edt.nc'];
streamtype = mtable.paramtype{ii(1)};

%load
[d, h] = mload(infile,'/');
%limit to specified days
if ~isempty(days)
    yd = m_commontime(d,'time',h,['days since ' num2str(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1)) '-01-01 00:00:00']) + 1;
    m = ismember(floor(yd),days);
    d = struct2table(d);
    d = table2struct(d(m,:),'ToScalar',true);
end
if isempty(d.time)
    disp('none of specified days in file %s; skipping',infile)
    return
end

comment = [];


%%%%%%%%% calibrate, rename, and combine (linearly) variables %%%%%%%%%

% adjust: factory calibration coefficients and other units conversions
sensorcals = []; sensors_to_cal = {}; xducer_offset = [];
opt1 = 'uway_proc'; opt2 = 'sensor_unit_conversions'; get_cropt
if ~isempty(sensorcals) || ~isempty(xducer_offset)
    [d, h, comment] = mday_01_fcal(d, h, abbrev, sensorcals, sensors_to_cal, xducer_offset); %factory calibrations as specified in opt_cruise
end
if ~isempty(comment)
    h.comment = [h.comment comment];
    didedits = 1;
end
if strcmp(streamtype,'sbm')
    % adjust: speed of sound correction and converting
    % depth-from-transducer to depth-from-surface
    [d, h, comment] = mday_01_cordep(d, h); 
end
if ~isempty(comment)
    h.comment = [h.comment comment];
    didedits = 1;
end

% adjust: cruise-specific calibrations
if strcmp(streamtype, 'met')
    condvar = munderway_varname('condvar', h.fldnam, 1, 's');
    salvar = munderway_varname('salvar', h.fldnam, 1, 's');
    temphvar = munderway_varname('temphvar', h.fldnam, 1, 's');

    if ~isempty(salvar) && ~isempty(condvar) && ~isempty(tempvar)
        d.(salvar)(isnan(d.(condvar)+d.temphvar)) = NaN;
        opt1 = 'uway_proc'; opt2 = 'tsg_cals'; get_cropt
        cpstr = '';

        if isfield(uo, 'calstr') && sum(cell2mat(struct2cell(uo.docal)))
            [dcal, hcal] = apply_calibrations(d, h, uo.calstr, uo.docal, 'q');
            for no = 1:length(hcal.fldnam)
                d.([hcal.fldnam{no} '_uncal']) = d.([hcal.fldnam{no}]);
                m = strcmp(hcal.fldnam{no},h.fldnam);
                h.fldnam = [h.fldnam [hcal.fldnam{no} '_uncal']];
                h.fldunt = [h.fldunt h.fldunt{m}];
                if isfield(h,'fldinst')
                    h.fldinst = [h.fldinst h.fldinst{m}];
                end
                d.(hcal.fldnam{no}) = dcal.(hcal.fldnam{no});
            end
            if ~isempty(hcal.fldnam)
                didedits = 1;
                h.comment = [h.comment hcal.comment];
                if sum(strncmp('temp',hcal.fldnam,4)) || sum(strncmp('cond',hcal.fldnam,4))
                    cpstr = ', calibrated';
                end
            end
        end
        
    end

end




%%%%%%%%% edit out bad data %%%%%%%%%
%apply automatic edits (e.g. bad time ranges), as set in opt_cruise
uopts = mday_01_default_autoedits(h);
opt1 = 'uway_proc'; opt2 = abbrev; get_cropt
[d, comment] = apply_autoedits(d, uopts);
if ~isempty(comment)
    h.comment = [h.comment comment];
    didedits = 1;
end

%reapply hand edits
edfilepat = fullfile(rootdir,'editlogs',sprintf('%s_*',abbrev));
[d, comment] = apply_guiedits(d, 'time', edfilepat);
if ~isempty(comment)
    h.comment = [h.comment comment];
    didedits = 1;
else
    time0 = d.time;
    d.time = m_commontime(d.time,h,['days since ' datestr([MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1) 1 1 0 0 0],'yyyy-mm-dd HH:MM:SS')]);
    [d, comment] = apply_guiedits(d, 'time', edfilepat, 0, 1/86400);
    d.time = time0;
    if ~isempty(comment)
        h.comment = [h.comment comment];
        didedits = 1;
    end
end


% calculate new (or replacement) variables

%easting and northing
headvar = munderway_varname('headvar', h.fldnam, 1, 's');
if ~isempty(headvar)
    [d.dum_e, d.dum_n] = uvsd(ones(size(d.(headvar))), d.(headvar), 'sduv');
    h.fldnam = [h.fldnam 'dum_e' 'dum_n']; h.fldunt = [h.fldunt 'dummy easting' 'dummy northing'];
    h.comment = '\n easting and northing calculated from heading at 1 hz';
    didedits = 1;
end

%salinity
cvar = munderway_varname('condvar', h.fldnam, 1, 's');
svar = munderway_varname('salvar', h.fldnam, 1, 's');
if ~isempty(cvar) && isempty(svar)
    tvar = munderway_varname('tempvar', h.fldnam, 1, 's');
    if isempty(tvar)
        warning('cond found but no temp to calculate psal in %s',abbrev)
    else
        cu = h.fldunt{strcmp(cvar,h.fldnam)};
        if strcmp('mS/cm',cu)
            fac = 1;
        elseif strcmp('S/m',cu)
            fac = 10;
        else
            warning('cond units %s not recognised, skipping calculating psal in %s',cu,abbrev)
            fac = [];
        end
        if ~isempty(fac)
            d.psal = gsw_SP_from_C(fac*d.(cvar),d.(tvar),0);
            h.fldnam = [h.fldnam 'psal'];
            h.fldunt = [h.fldunt 'pss-78'];
            h.comment = [h.comment '\n psal calculated from edited%s %s and %s',cpstr,cvar,tvar];
            didedits = 1;
        end
    end
end

%save
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
% and non-finite times 
function [d, comment] = mday_01_fixtimes(d,abbrev)

%%%%% check for repeated times and backward time jumps %%%%%
comment = '';

%repeated times
deltat = d.time(2:end)-d.time(1:end-1);
deltat = [1; deltat(:)];
iib = find(deltat==0 | ~isfinite(d.time));
if ~isempty(iib)
    for no = 1:length(h.fldnam)
        d.(h.fldnam{no})(iib) = [];
        comment = [comment '\n repeated times removed'];
    end
end

%***old scs/techsas code, update?
if ismember(abbrev,{'gys', 'gyr', 'gyro_s', 'gyropmv', 'posmvpos'})
    %work on the latest file, which already be an edited version; always output to otfile
    tflag = m_flag_monotonic(d.time); 
    mb = tflag==0;
    if sum(mb)
        comment = [comment '\n backwards time jumps removed'];
        fn = fieldnames(d);
        if strcmp(abbrev, 'posmvpos')
            ii = 1:9;
        else
            ii = 1:2;
        end
        for no = ii
            d.(fn{no})(mb) = NaN;
        end
    end
end

%%%%% default range limits and despiking settings %%%%%
% uopts = mday_01_default_autoedits(h)
% 
% define by variable type and apply to variable names in each category
% actually found in h
% 
function uopts = mday_01_default_autoedits(h)

uopts.despike.dep = [10 5 3];

uopts.rangelim.pitch = [-5 5];
uopts.rangelim.roll = [-7 7];
uopts.rangelim.trans = [0 105];

uvar.head = [0 360];
uvar.lon = [-181 181];
uvar.lat = [-91 91];
uvar.airtemp = [-50 50];
uvar.humid = [0.1 110];
uvar.rwindd = [-0.1 360.1];
uvar.twindd = [-0.1 360.1];
uvar.rwinds = [-0.001 200];
uvar.twinds = [-0.001 200];
uvar.airpres = [0.01 1500];
uvar.ppar = [-10 1500];
uvar.ptir = uvar.ppar;
uvar.spar = uvar.ppar;
uvar.stir = uvar.ppar;
uvar.sst = [-2 50];
uvar.temp = uvar.sst;
uvar.cond = [0 10];
uvar.multib = [20 1e4];
uvar.singleb = uvar.multib;

fn = fieldnames(uvar);
for pno = 1:length(fn)
    n = munderway_varname([fn{pno} 'var'],h.fldnam); n = n{1};
    for nno = 1:length(n)
        uopts.rangelim.(n{nno}) = uvar.(fn{pno});
    end
end


%%%%% cordep %%%%%
%
% [d, h, comment] = mday_01_cordep(d, h);
%
% for singlebeam echosounder, apply transducer offset and carter table
% soundspeed correction
function [d, h, comment] = mday_01_cordep(d, h)

m_common
comment = '';

%convert from depth relative to transducer (if necessary)
depbtvar = munderway_varname('deptrefvar', h.fldnam, 1, 's');
depsfvar = munderway_varname('depsrefvar', h.fldnam, 1, 's');
depvar = munderway_varname('depvar', h.fldnam, 1, 's');
xducervar = munderway_varname('xducerdepvar', h.fldnam, 1, 's');
if ~isempty(depbtvar) && ~isempty(xducervar) && isempty(depvar)
    d.waterdepth = d.(depvar) + d.(xducervar);
    h.fldnam = [h.fldnam 'waterdepth'];
    h.fldunt = [h.fldunt 'metres'];
    comment = '\n waterdepth has transducer offset applied';
elseif ~isempty(depsfvar)
    d.waterdepth = d.(depsfvar);
    h.fldnam = [h.fldnam 'waterdepth'];
    h.fldunt = [h.fldunt 'metres'];
    comment = ['\n waterdepth rennamed from ' depsfvar];
    d = rmfield(d,depsfvar);
    h.fldunt(strcmp(depsfvar,h.fldnam)) = [];
    h.fldnam(strcmp(depsfvar,h.fldnam)) = [];
end

%carter correction
opt1 = 'ship'; opt2 = 'datasys_best'; get_cropt
navfile = fullfile(mgetdir(default_navstream), [default_navstream '_' mcruise '_all_raw.nc']); %in case edt is not made yet, depending on order in list
if exist(navfile,'file')

    [dn,hn] = mload(navfile,'/');
    latstr = munderway_varname('latvar', hn.fldnam, 1, 's');
    lonstr = munderway_varname('lonvar', hn.fldnam, 1, 's');
    lon = dn.(lonstr);
    lat = dn.(latstr);

    dn.time = m_commontime(dn.time,hn,h);
    lon = interp1(dn.time, lon, d.time);
    lat = interp1(dn.time, lat, d.time);

else
    warning('no pos file for day with %d found, using current position to select carter area for echosounder correction',floor(d.time(1)))
    navname = default_navstream;
    if strcmp(MEXEC_G.Mshipdatasystem, 'rvdas')
        pos = mrlast(navname); lon = pos.longitude; lat = pos.latitude; clear pos
    elseif strcmp(MEXEC_G.Mshipdatasystem, 'techsas')
        pos = mtlast(navname); lon = pos.long; lat = pos.lat; clear pos
    elseif strcmp(MEXEC_G.Mshipdatasystem, 'scs')
        pos = mslast(navname); lon = pos.long; lat = pos.lat; clear pos
    end
end

if isfield(d,'waterdepth')
    y = mcarter(lat, lon, d.waterdepth);
elseif isfield(d,'uncdepth')
    y = mcarter(lat, lon, d.uncdepth);
    d = rmfield(d,'uncdepth');
    h.fldunt(strcmp(h.fldnam,'uncdepth')) = [];
    h.fldnam(strcmp(h.fldnam,'uncdepth')) = [];
end
d.waterdepth = y.cordep;
h.fldnam = [h.fldnam 'waterdepth'];
h.fldunt = [h.fldunt 'meters'];
comment = [comment '\n carter table correction applied to waterdepth\n'];


%%%%% fcal %%%%%
%
% [d, h, comment] = mday_01_fcal(d, h, abbrev, sensorcals, sensors_to_cal, xducer_offset);
%
% apply factory calibrations to underway sensors reported in voltage 
% units, or apply other conversions such as adding a constant transducer
% offset to depth relative to transducer
function [d, h, comment] = mday_01_fcal(d, h, abbrev, sensorcals, sensors_to_cal, xducer_offset)

comment = '';

if ~isempty(sensorcals)

    fn = fieldnames(sensorcals);
    [vars,iic,~] = intersect(fn,h.fldnam,'stable');

    for m = 1:length(vars)
        mv = strncmp(vars{m},h.fldnam,length(sensors_to_cal{m}));
        iir = strfind(h.fldnam{mv},'_raw');
        if isempty(iir)
            d.([h.fldnam{mv} '_raw']) = d.(h.fldnam{mv});
            h.fldnam = [h.fldnam [h.fldnam{mv} '_raw']];
            h.fldunt = [h.fldunt h.fldunt{mv}];
        end
        sensorraw = [vars{m} '_raw'];
        x1 = d.(sensorraw);
        eval(sensorcals.(fn{iic(m)}));
        d.(vars{m}) = y;
        if ~strcmp('/',sensorunits(fn{iic(m)}))
            h.fldunt{mv} = sensorunits(fn{iic(m)});
        end
    end
    if ~isempty(vars)
        comment = [comment '\n coefficients in cruise options file applied'];
    end

end

if ~isempty(xducer_offset)
    ma = strcmp(abbrev,h.fldnam);
    mt = strcmp([abbrev '_t'],h.fldnam);
    if ~sum(ma) && sum(mt) %***
        d.(abbrev) = d.([abbrev '_t']) + xducer_offset;
        h.fldnam = [h.fldnam abbrev];
        h.fldunt = [h.fldunt h.fldunt(iit)];
        comment = [comment '\n ' abbrev ' calculated by adding xducer_offset from cruise options file to ' abbrev '_t'];
    end
end

% windspeed_ms from speed 'y = x1*1852/3600' % 'y=x1*0.512' % bim used 0.512 on jc032, but the correct answer is (BAK thinks) 0.5144444

