function mday_01_clean_append(abbrev,root_out,day)
%function mday_01_clean_append(abbrev,root_out,day)
%
% abbrev (char) is the mexec short name prefix for the data stream
% day (char or numeric) is the day number
%
% the output with all edits and calibrations applied goes to
% abbrev_day_edt.nc
%
% updated by bak for jr195 2009-sep-17 for scs/techsas interface
% extensively revised by bak at noc aug 2010; hopefully integrates
% SCS&techsas streams with suitable switches and traps
%
% Created by efw to organise mday_00_clean.m to be (a little) more
% like mday_00_get_all.m
%
% Revised ylf jc145 to remove redundancy and cases for streams with no action
% and to add additional cases, incorporating actions formerly in m${stream}_01 files
%
% The possible edits include checking for out-of-range values, but
% instrument calibrations, which may vary by ship/cruise, are applied
% separately***
%
% revised ylf dy105 to check for various variable names (requiring similar transformations) in the header
%
% revised epa dy113 to apply factory calibrations to uncalibrated underway
% variables, as specified in the option file. On Discovery, this applies to
% fluorometer and transmissometer in met_tsg, and all radiometers in surflight
%
% revised ylf sd025 to work in workspace and end with merging edited
% variables into concatenated file (skipping the daily _edt files) 

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

day_string = sprintf('%03d',day);
if MEXEC_G.quiet<=1; fprintf(1,'performing any automatic cleaning/editing/averaging on %s_%s_d%s_raw.nc\n',abbrev,mcruise,day_string); end

prefix = [abbrev '_' mcruise '_d' day_string];
infile = fullfile(root_out, [prefix '_raw']);
if ~exist(m_add_nc(infile))
    return
end
[d,h] = mloadq(infile,'/');

%do special cruise-specific edits
opt1 = mfilename; opt2 = 'pre_edit_uway'; get_cropt

% edit names and units: this should now be done in mrrename_varsunits
% (and similar functions should be created for techsas and scs)

% fix some things
d = mday_01_fixtimes(d, abbrev); %repeated times and backwards jumps
if strcmp(abbrev,'cnav')
    %this re-parses degrees/minutes, hasn't been necessary since ***
    [d, h] = mday_01_cnavfix(d, h);
end

% data range edits, time range edits, and despiking ***pumpsNaN could also
% be useful for tsg, but maybe the recovery time is more variable than for
% ctd?
uopts = mday_01_default_autoedits;
opt1 = mfilename; opt2 = 'dayedit_auto'; get_cropt %override defaults or set specific bad time ranges
[d, comment] = apply_autoedits(d, uopts);
if ~isempty(comment)
    h.comment = [h.comment comment];
end

% apply adjustments
opt1 = 'calibrations'; opt2 = 'sensor_factory_cals'; get_cropt
if ~isempty(sensorcals) || ~isempty(xducer_offset)
    [d, h] = mday_01_fcal(d, h, abbrev); %factory calibrations as specified in opt_cruise
end
if sum(strcmp(abbrev, {'sim' 'ea600m' 'ea600' 'singleb' 'em122' 'multib'}))
    [d, h] = mday_01_cordep(d, h, abbrev); %apply transducer offset and (for singleb) carter table soundspeed correction, go from depth_uncor to depth
end

%now append
dataname = [abbrev '_' mcruise '_01'];
otfile = fullfile(mgetdir(abbrev), dataname);
if exist(m_add_nc(otfile),'file')
    d0 = mload(otfile,'time');
    if length(intersect(d.time,d0.time))>2
        warning(['overwriting day ' day_string ' in appended file ' otfile])
    end
end
mfsave(otfile, d, h, '-merge', 'time');


%%%%%%%%%% subfunctions %%%%%%%%%%

function d = mday_01_fixtimes(d,abbrev)
% flag repeated times and (for selected streams) backward time jumps
% and non-finite times 

%%%%% check for repeated times and backward time jumps %%%%%

%repeated times
deltat = d.time(2:end)-d.time(1:end-1);
deltat = [1; deltat(:)];
iib = find(deltat==0 | ~isfinite(d.time));
if ~isempty(iib)
    for no = 1:length(h.fldnam)
        d.(h.fldnam{no})(iib) = [];
    end
end

if ismember(abbrev,{'gys', 'gyr', 'gyro_s', 'gyropmv', 'posmvpos'})
    %work on the latest file, which already be an edited version; always output to otfile
    tflag = m_flag_monotonic(d.time); 
    mb = tflag==0;
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


function uopts = mday_01_default_autoedits
%default range limits and despiking settings 
uopts.despike.depth_below_xducer = [10 5 3];

uopts.rangelim.head = [0 360]; 
uopts.rangelim.head_ash = uopts.rangelim.head;
uopts.rangelim.heading = uopts.rangelim.head;
uopts.rangelim.headingtrue = uopts.rangelim.head;
uopts.rangelim.pitch = [-5 5];
uopts.rangelim.roll = [-7 7];
uopts.rangelim.mrms = [1e-5 1e-2];
uopts.rangelim.brms =[1e-5 0.1];
uopts.rangelim.lon = [-181 181]; 
uopts.rangelim.long = uopts.rangelim.lon;
uopts.rangelim.longitude = uopts.rangelim.lon;
uopts.rangelim.lat = [-91 91];
uopts.rangelim.latitude = uopts.rangelim.lat;
uopts.rangelim.airtemp = [-50 50]; 
uopts.rangelim.airtemperature = uopts.rangelim.airtemp;
uopts.rangelim.humid = [0.1 110]; 
uopts.rangelim.humidity = uopts.rangelim.humid;
uopts.rangelim.winddirection = [-0.1 360.1]; 
uopts.rangelim.direct = uopts.rangelim.winddirection;
uopts.rangelim.windspeed = [-0.001 200]; 
uopts.rangelim.speed = uopts.rangelim.windspeed;
uopts.rangelim.airpressure = [0.01 1500];
uopts.rangelim.pres = uopts.rangelim.airpressure;
uopts.rangelim.ppar = [-10 1500]; 
uopts.rangelim.ptir = uopts.rangelim.ppar;
uopts.rangelim.spar = uopts.rangelim.ppar;
uopts.rangelim.stir = uopts.rangelim.ppar;
uopts.rangelim.parport = uopts.rangelim.ppar;
uopts.rangelim.parstarboard = uopts.rangelim.ppar;
uopts.rangelim.tirport = uopts.rangelim.ppar;
uopts.rangelim.tirstarboard = uopts.rangelim.ppar;
uopts.rangelim.sstemp = [-2 50]; 
uopts.ranglelim.temp_h = uopts.rangelim.sstemp;
uopts.ranglelim.temp_r = uopts.rangelim.sstemp;
uopts.ranglelim.temp_m = uopts.rangelim.sstemp;
uopts.ranglelim.tstemp = uopts.rangelim.sstemp;
uopts.ranglelim.temp_housing = uopts.rangelim.sstemp;
uopts.ranglelim.temp_remote = uopts.rangelim.sstemp;
uopts.rangelim.cond = [0 10];
uopts.rangelim.conductivity = uopts.rangelim.cond;
uopts.rangelim.trans = [0 105]; 
uopts.rangelim.depth = [20 1e4]; 
uopts.rangelim.swath_depth = uopts.rangelim.depth;
uopts.rangelim.waterdepth = uopts.rangelim.depth;
uopts.rangelim.depth_below_xducer = uopts.rangelim.depth;


function [d, h] = mday_01_cnavfix(d, h)
% function [d, h] = mday_01_cnavfix(d, h);

if max(mod(abs([d.lat(:);d.long(:)])*100,100))<=61
    
    if std(d.lat)<.1 && std(d.lon)<.1 % ship hasn't moved much
        warning('Cannot determine whether or not to apply cnav fix. Not applying.');
        
    else
        if MEXEC_G.quiet<=1; fprintf(1,'applying cnav fix to cnav_%s_d%s_raw.nc\n',mcruise,day_string); end
        sensors_to_cal={'lat','long'};
        for m = 1:length(sensors_to_cal)
            no = sensors_to_cal{m};
            nn = [sensors_to_cal{m} '_raw'];
            ii = find(strcmp(no,h.fldnam));
            d.(nn) = d.(no);
            h.fldnam = [h.fldnam nn];
            h.fldunt = [h.fldunt h.fldunt(ii)];
            d.(no) = cnav_fix(d.(no));
        end
    end
    
else
    if MEXEC_G.quiet<=1; fprintf(1,'cnav fix not required for cnav_%s_d%s_raw.nc; no action\n',mcruise,day_string); end
end

function [d, h] = mday_01_cordep(d, h, abbrev)
% function [d, h] = mday_01_cordep(d, h, abbrev);
%%%%% apply transducer offset (if found) and carter table %%%%%
%%%%% soundspeed correction (if needed) to bathymetry %%%%%

m_common

%convert from depth relative to transducer (if necessary)
if sum(strcmpi('transduceroffset',h.fldnam)) && ~sum(strcmpi('waterdepth',h.fldnam))
    d.waterdepth = d.depth_below_xducer + d.transduceroffset;
    h.fldnam = [h.fldnam 'waterdepth'];
    h.fldunt = [h.fldunt 'metres'];
end

%carter correction
if sum(strcmp(abbrev,{'ea600' 'ea640' 'singleb'}))

    navname = MEXEC_G.default_navstream; navdir = mgetdir(navname);
    navfile = fullfile(navdir, [navname '_' mcruise '_d' day_string '_raw.nc']);
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
        warning(['no pos file for day ' day_string ' found, using current position to select carter area for echosounder correction'])
        if strcmp(MEXEC_G.Mshipdatasystem, 'techsas')
            pos = mtlast(navname); lon = pos.long; lat = pos.lat; clear pos
        elseif strcmp(MEXEC_G.Mshipdatasystem, 'scs')
            pos = mslast(navname); lon = pos.long; lat = pos.lat; clear pos
        end
    end

    y = mcarter(lat, lon, d.waterdepth);
    d.waterdepth = y.cordep;

end

function [d, h] = mday_01_fcal(d, h, abbrev, sensorcals, xducer_offset)
% function [d, h] = mday_01_fcal(d, h, abbrev);
%%%%% apply factory calibrations to uncalibrated (still in voltage units) underway sensors - from cruise option file %%%%%

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
end

if ~isempty(xducer_offset)
    ma = strcmp(abbrev,h.fldnam);
    mt = strcmp([abbrev '_t'],h.fldnam);
    if ~sum(ma) && sum(mt) %***
        d.(abbrev) = d.([abbrev '_t']) + xducer_offset;
        h.fldnam = [h.fldnam abbrev];
        h.fldunt = [h.fldunt h.fldunt(iit)];
        h.comment = [h.comment '\n ' abbrev ' calculated by adding xducer_offset specified in opt_' mcruise ' to ' abbrev '_t'];
    end
end

% windspeed_ms from speed 'y = x1*1852/3600' % 'y=x1*0.512' % bim used 0.512 on jc032, but the correct answer is (BAK thinks) 0.5144444


