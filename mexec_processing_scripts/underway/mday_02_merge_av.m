function mday_02_merge_av(datatype, ydays, mtable, varargin)
% mday_02_merge_av(datatype, ydays, mtable)
%
% ydays is in yearday
% merge data from multiple inputs/instruments

if nargin>3
    regrid = varargin{1};
else
    regrid = 1;
end

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
dto = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN;
timestring = ['days since ' datestr(dto,'yyyy-mm-dd HH:MM:SS')];

if regrid
    ngvars = {'utctime'}; %never grid this
    gvars = {}; %by default grid all other variables

    %define input and output files
    switch datatype
        case 'nav'
            opt1 = 'ship'; opt2 = 'datasys_best'; get_cropt
            source = {'position'; 'heading'; 'attitude'};
            streams = {default_navstream; default_hedstream; default_attstream};
            required = [1 1 0];
            otfile = ['bestnav_' mcruise '.nc'];
            tavp = 30; %30 s
            gmethod = 'meanbin';
        case 'bathy'
            source = {'sbm'; 'mbm'};
            streams = {'ea640_sddpt'; 'em122_kidpt'};
            required = [0 0];
            otfile = ['bathy_' mcruise '.nc'];
            tavp = 5*60; % 5 min
            gmethod = 'medbin';
        case 'tsg'
            source = {'surfmet';'sbe45';'sbe38'};
            streams = {'surfmet_sfuwy'; 'sbe45_nanan'; 'sbe38dk_sbe38'};
            required = [1 1 0]; %***make cruise-specific
            otfile = ['surfocn_' mcruise '.nc'];
            tavp = 60; % 1 min
            gmethod = 'meanbin';
        case 'wind'
            source = {'surfmet'; 'windsonic'; 'position'};
            streams = {'surfmet_sfmet'; 'windsonic_windsonic'; default_navstream};
            required = [0 1 1];
            otfile = ['truewind_' mcruise '.nc'];
            tavp = 30; % 30 s
            gmethod = 'meanbin';
    end
    %***check for multiple streams from same inst? not important at this
    %stage, all will be in corresponding mstar file
    filepre = cell(size(streams));
    for fno = 1:length(streams)
        m = strcmp(streams{fno},mtable.tablename);
        filepre{fno} = fullfile(mgetdir(mtable.mstardir{m}), mtable.mstarpre{m});
    end
    otfile = fullfile(fileparts(filepre{1}),otfile);

    %gridding parameters
    opt1 = 'uway_proc'; opt2 = 'uway_av'; get_cropt
    tavp = round(tavp); tav2 = round(tavp/2);
    tg = ydays(1)-tav2/86400:tavp:ydays(end)+1+(tav2-1)/86400;
    opts.ignore_nan = 1;
    opts.grid_ends = [1 1];
    opts.postfill = tavp; %***
    opts.bin_partial = 0;

    %load multiple files, either edt (if found) or raw, and merge to common
    %time grid, saving along the way
    found = ones(size(required));
    for fno = 1:length(filepre)
        infile = [filepre{fno} '_' mcruise '_all_edt.nc'];
        if ~exist(infile,'file')
            infile = [filepre{fno} '_' mcruise '_all_raw.nc'];
            if ~exist(infile,'file')
                if required(fno)
                    error('no file found for %s',filepre{fno})
                else
                    found(fno) = 0;
                    warning('no file found for %s*, skipping',filepre{fno})
                    continue
                end
            end
        end
        [d, h] = mload(infile,'/');

        %prepare
        timvar = munderway_varname('timvar',h.fldnam,1,'s');
        d.(timvar) = m_commontime(d, timvar, h, timestring);
        [d, h, gvars, ngvars] = mday_02_prepare_to_average(d, h, gvars, ngvars, source{fno});

        %grid
        dg = grid_profile(d, 'time', tg, gmethod, opts);
        dg.time = tg(1:end-1)+tg(2:end);

        %save
        h.dataname = [dataype '_' mcruise '_combined_av'];
        h.comment = sprintf('\n %s from %s, % over bins of width %s s',source{fno},infile,gmethod(1:end-2),num2str(tavp));
        mfsave(otfile, dg, h, '-merge', 'time')

    end
    if ~sum(found)
        warning('no files to load for %s, skipping',datatype)
        return
    end
    clear dg h d tg

end 

% load and QC combined data
[dg, hg] = mload(otfile,'/');

% calibrate/adjust existing variables and calculate additional variables
[dg, hg, comment] = mday_02_postaveraging(dg, hg, datatype);
if ~isempty(comment)
    hg.comment = [hg.comment comment];
end

%edit
opt1 = 'uway_proc'; opt2 = 'avedit'; get_cropt
if ~isempty(uopts)
    % autoedits (e.g. if A depends on B, remove A when B is bad)
    [dg, comment] = apply_autoedits(dg, uopts);
    if ~isempty(comment)
        hg.comment = [hg.comment comment];
    end
end
if handedit
    ddays = ydays-1;
    edfile = fullfile(fileparts(otfile),'editlogs',[datatype '_' mcruise]);
    dg.dday = dg.time;
    [dg, hg] = edit_by_day(dg, hg, edfile, ddays, (tavp/2)/86400);
end


%save again
mfsave(otfile, dg, hg);



% ---------------------------------------------------------------------
% %%%%%%%%% subfunctions %%%%%%%%%
% ---------------------------------------------------------------------

function [d, h, gvars, ngvars] = mday_02_prepare_to_average(d, h, gvars, ngvars, source)
% [d, h, gvars, ngvars] = mday_02_prepare_to_average(d, h, gvars, ngvars);
%
% calculate additional before gridding
%
% for heading, compute easting and northing (for averaging)
%
% for bathymetry, append source to water depth variable names (same names
%   used by different instruments)
%
% for all, remove from d and h any variables not to be gridded

headvar = munderway_varname('headvar',h.fldnam,1,'s');
if ~isempty(headvar)
    %calculate dummy easting and northing in order to vector average
    [d.dum_e, d.dum_n] = uvsd(ones(size(d.(headvar))), d.(headvar), 'sduv');
    h.fldnam = [h.fldnam 'dum_e' 'dum_n']; 
    h.fldunt = [h.fldunt 'dummy easting' 'dummy northing'];
    h.fldinst = [h.fldinst ' ' ' '];
    h.comment = [h.comment '\n easting and northing calculated from heading at 1 hz'];
    ngvars = [ngvars headvar];
end

depvar = munderway_varname('depvar',h.fldnam,1,'s');
depvar = union(depvar,munderway_varname('depsrefvar',h.fldnam,1,'s'));
depvar = union(depvar,munderway_varname('deptrefvar',h.fldnam,1,'s'));
if ~isempty(depvar)
    %append source, because singlebeam and multibeam may have the same
    %variable names
    for no = 1:length(depvar)
        on = depvar{no}; nn = [on '_' source];
        d.(nn) = d.(on); 
        h.fldnam(strcmp(on,h.fldnam)) = {nn};
    end
    d = rmfield(d,depvar);
    d = orderfields(d,h.fldnam);
    %ngvars = [ngvars xducerdepvar]; %***combine before this to avoid
    %gridding this too?
end

[excv,iie] = intersect(h.fldnam, ngvars);
if exist('gvars','var')
    [ev,ii] = setdiff(h.fldnam, gvars);
    excv = [excv ev]; iie = [iie ii];
end
if ~isempty(excv)
    d = rmfield(d,excv);
    h.fldunt(iie) = []; h.fldnam(iie) = []; h.fldinst(iie) = [];
end


%%%%%%%% combine %%%%%%%%
%
% [d, h, didedits] = mday_02_postaveraging(d, h, abbrev, mtables);
%
% working on edited (cleaned), gridded (time-averaged) d, if variables in d
% are suitable, do one of the following: 
%
%   from easting and northing, compute heading; from lat and lon, compute
%   speed, course, and distrun
%
%   from conductivity and temperature, compute salinity
%
%   from water depth relative to transducer and transducer offset, compute
%     water depth relative to surface
function [dg, hg, comment] = mday_02_postaveraging(dg, hg, datatype, streams, ngvars)

comment = [];

switch datatype

    case 'nav'
        % convert dummy easting and northing back to heading
        headvar = ngvars{end}; %this was added on by prepare_to_average
        [~, dg.(headvar)] = uvsd(dg.dum_e, dg.dum_n, 'uvsd');
        % calculate speed, course, distrun
        latvar = munderway_varname('latvar', hg.fldnam, 1 ,'s');
        lonvar = munderway_varname('lonvar', hg.fldnam, 1, 's');
        [dist, ang] = sw_dist(dg.(latvar), dg.(lonvar), 'km');
        delt = diff(dg.time);
        speed = 1000*dist./delt;
        ve = zeros(size(dg.(latvar))); vn = ve;
        ve(2:end) = speed.*cos(ang*pi/180);
        vn(2:end) = speed.*sin(ang*pi/180);
        [dg.smg, dg.cmg] = uvsd(ve, vn, 'uvsd');
        dist(isnan(dist)) = 0; %***
        dg.distrun = [0; cumsum(dist)];
        hg.fldnam = [hg.fldnam 'smg' 'cmg' 'distrun'];
        hg.fldunt = [hg.fldunt 'm/s' 'degrees' 'km'];
        hg.fldinst = [hg.fldinst repmat({default_navstream},1,3)];
        hg.comment = [hg. comment '\n speed, course over ground, and distance run calculated from (vector-)averaged data'];

    case 'bathy'
        opt1 = 'uway_proc'; opt2 = 'bathy_grid'; get_cropt
        if exist('zbathy','var') && ~isempty(zbathy)
            [dn, hn] =  mloadq(fullfile(mgetdir(default_navstream),sprintf('bestnav_%s',mcruise)),'/');
            %dn.time = m_commontime(dn, 'time', hn, timestring); %already the same
            lonvar = munderway_varname('lonvar',hn.fldnam,1,'s');
            latvar = munderway_varname('latvar',hn.fldnam,1,'s');
            lon = interp1(dn.time,dn.(lonvar),dg.time);
            lat = interp1(dn.time,dn.(latvar),dg.time);
            clear dn hn
            xbathy = [xbathy-360 xbathy]; zbathy = [zbathy zbathy];
            iix = find(xbathy>=min(lon)-1 & xbathy<=max(lon)+1);
            iiy = find(ybathy>=min(lat)-1 & ybathy<=max(lat)+1);
            bathymap = interp2(xbathy(iix),ybathy(iiy),zbathy(iiy,iix),lon,lat);
            xbathy = xbathy(iix); ybathy = ybathy(iiy);
            clear lon lat iix iiy
        end
        %water depth relative to surface
        xducervar = munderway_varname('xducerdepvar', h.fldnam, 1, 's');
        depbtvar = munderway_varname('deptrefvar', h.fldnam, 1, 's');
        if ~isempty(depbtvar) && ~isempty(xducervar)
            newdep = setdiff({'waterdepth','waterdepthfromsurface'},h.fldnam);
            if isempty(newdep)
                warning('%s already contains both waterdepth and waterdepthfromsurface, skipping recalculation from depth relative to transducer',abbrev)
            else
                newdep = newdep{1};
            end
            d.(newdep) = d.(depbtvar) + d.(xducervar);
            h.fldnam = [h.fldnam newdep];
            h.fldunt = [h.fldunt 'm'];
            comment = sprintf('\n %s has transducer offset applied', newdep);
        end

    case 'met'
        
        if contains(streams,'tsg')
            %calibrate
            opt1 = 'uway_proc'; opt2 = 'tsg_cals'; get_cropt
            if isfield(uo, 'calstr') && sum(cell2mat(struct2cell(uo.docal)))
                [dcal, hcal] = apply_calibrations(dg, hg, uo.calstr, uo.docal, 'q');
                for no = 1:length(hcal.fldnam)
                    %apply to d, and don't save uncalibrated versions
                    dg.([hcal.fldnam{no}]) = dcal.(hcal.fldnam{no});
                end
                if no>0
                    hg.comment = [hg.comment hcal.comment];
                end
            end
        end
        %salinity
        cvar = munderway_varname('condvar', hg.fldnam, 1, 's');
        tvar = munderway_varname('tempvar', hg.fldnam, 1, 's');
        if ~isempty(cvar) && ~isempty(tvar)
            cu = hg.fldunt{strcmp(cvar,hg.fldnam)};
            if strcmp('mS/cm',cu)
                fac = 1;
            elseif strcmp('S/m',cu)
                fac = 10;
            else
                warning('cond units %s not recognised, skipping calculating psal in %s',cu,abbrev)
                fac = [];
            end
            if ~isempty(fac)
                svar = munderway_varname('salvar', hg.fldnam, 1, 's');
                if isempty(svar)
                    svar = 'psal';
                end
                dg.(svar) = gsw_SP_from_C(fac*dg.(cvar),dg.(tvar),0);
                hg.fldnam = [hg.fldnam svar];
                hg.fldunt = [hg.fldunt 'pss-78'];
                comment = sprintf('\n psal calculated from edited, averaged%s %s and %s',cpstr,cvar,tvar);
            end
        elseif isempty(tvar)
            warning('cond found but no temp to calculate psal in %s combined file',datatype)
        end

    case 'wind'

end
