function [d, h, varargout] = mday_02_calculations(d, h, stage, datatype, varargin)
%
% calculations when combining variables from multiple instruments
%
% [d, h, gvars, ngvars] = mday_02_calculations(d, h, 'pre', gvars, ngvars, source);
%   calculate additional quantities before gridding:
%     for heading, compute easting and northing (for averaging)
%     for bathymetry, append source to water depth variable names (same names
%       used by different instruments)
%     for all, remove from d and h any variables not to be gridded
%     input d is a structure but output d is a table
%
% [dg, h, comment] = mday_02_calculations(dg, h, 'post', datatype);
%   working on edited (cleaned), gridded (time-averaged) d:
%     from easting and northing, compute heading; from lat and lon, compute
%       speed, course, and distrun
%     from conductivity and temperature, compute salinity
%     from water depth relative to transducer and transducer offset, compute
%       water depth relative to surface

m_common

if strcmp(stage,'pre')
    gvars = varargin{1}; ngvars = varargin{2};
    source = varargin{3};
    gmethod = varargin{4};
    ddays = varargin{5};
end

tgvar = sprintf('time_s_%d',MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1));
timestring = ['seconds since ' datestr(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN,'yyyy-mm-dd HH:MM:SS')];

%%%%%%%%%%%%%%%%%%%%%%%%%%%% pre %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(stage,'pre')

    d = struct2table(d);
    d.Properties.VariableUnits = h.fldunt;
    d = addprop(d,{'VariableSerials'},{'variable'});
    d.Properties.CustomProperties.VariableSerials = h.fldserial;

    %regularise time units
    timvar0 = munderway_varname('timvar',d.Properties.VariableNames,1,'s');
    m = strcmp(timvar0,d.Properties.VariableNames);
    timunt0 = d.Properties.VariableUnits{m};
    if ~strcmp(timunt0, timestring)
        d(:,m) = m_commontime(d(:,m), timunt0, timestring);
    end
    d.Properties.VariableNames{m} = tgvar;
    if strcmp(gmethod,'meannum')
        %convert to regular 1-Hz grid, subsampling (in case initial processing
        %did not) and/or filling in missing points as necessary
        %discard extra (same to the nearest second) samples
        [timesec,ii] = unique(round(d.(tgvar)));
        d = d(ii,:);
        %fill in missing points with nans
        t0 = [floor(ddays(1))*86400:ceil(ddays(end))*86400-1]';
        if length(t0)>length(timesec)
            dat = d{:,:};
            [~,ia,ib] = intersect(t0,timesec);
            datr = nan(length(t0),size(dat,2));
            datr(ia,:) = dat(ib,:);
            d = paddata(d, length(t0));
            d{:,:} = datr;
            d.(tgvar) = t0;
        else
            d.(tgvar) = timesec;
        end
    end

    %this needs to be done for nav or wind
    headvar = munderway_varname('headvar',d.Properties.VariableNames,1,'s');
    if ~isempty(headvar)
        %calculate dummy easting and northing in order to vector average
        [d.dum_e, d.dum_n] = uvsd(ones(size(d.(headvar))), d.(headvar), 'sduv');
        if ~sum(strcmp('dum_e',d.Properties.VariableNames))
            d.Properties.VariableUnits(end-1:end) = {'easting', 'northing'};
            d.Properties.CustomProperties.VariableSerials(end-1:end) = d.Properties.CustomProperties.VariableSerials(strcmp(headvar,d.Properties.VariableNames));
        end
        comment = 'easting and northing calculated from heading at 1 hz';
        if ~contains(h.comment, comment)
            h.comment = [h.comment '\n ' comment];
        end
        ngvars = [ngvars headvar];
    end

    switch datatype

        case 'bathy'
            depvar = munderway_varname('depvar',d.Properties.VariableNames,1,'s');
            depsvar = munderway_varname('depsrefvar',d.Properties.VariableNames,1,'s');
            deptvar = munderway_varname('deptrefvar',d.Properties.VariableNames,1,'s');
            if isempty(depvar) && ~isempty(deptvar)
                if ~sum(strcmp('waterdepth',d.Properties.VariableNames))
                    d.waterdepth = d.(deptvar) + d.transduceroffset; %***
                    d.Properties.VariableUnits(end) = {'m'};
                    d.Properties.CustomProperties.VariableSerials(end) = d.Properties.CustomProperties.VariableSerials(strcmp(deptvar,d.Properties.VariableNames));
                    depvar = munderway_varname('depvar',d.Properties.VariableNames,1,'s');
                    depsvar = munderway_varname('depsrefvar',d.Properties.VariableNames,1,'s');
                    deptvar = munderway_varname('deptrefvar',d.Properties.VariableNames,1,'s');
                end
            end
            if ~iscell(depvar); depvar = {depvar}; end
            if ~iscell(depsvar); depsvar = {depsvar}; end
            if ~iscell(deptvar); deptvar = {deptvar}; end
            depvar = union(depvar,union(depsvar,deptvar));
            if ~isempty(depvar)
                %append source, because singlebeam and multibeam may have the same
                %variable names
                m = ismember(d.Properties.VariableNames,depvar);
                d.Properties.VariableNames(m) = cellfun(@(x) [x '_' source],d.Properties.VariableNames(m),'UniformOutput',false);
                d(:,strcmp(depvar,d.Properties.VariableNames)) = [];
                %ngvars = [ngvars xducerdepvar]; %***combine before this to avoid
                %gridding this too?
            end

        case 'ocean'
            %put the surfmet radiation variables in atmos instead
            ngvars = [ngvars,intersect(d.Properties.VariableNames,{'parport' 'parstarboard' 'tirport' 'tirstarboard' 'humidity' 'airpressure' 'airtemperature'})];
            %rename _raw variables***in later cruises this is not
            %necessary/done earlier?
            d.Properties.VariableNames = cellfun(@(x) replace(x,'_raw',''),d.Properties.VariableNames,'UniformOutput',false);

        case 'atmos'

            ws = munderway_varname('rwindsvar',d.Properties.VariableNames,1,'s');
            wd = munderway_varname('rwinddvar',d.Properties.VariableNames,1,'s');
            if ~isempty(ws)
                if ~sum(strcmp('xcomponent',d.Properties.VariableNames)) %***
                    %compute x and y component (platform-relative) from speed
                    %and (compass) direction
                    [d.xcomponent, d.ycomponent] = uvsd(d.(ws), d.(wd), 'sduv');
                    d.Properties.VariableUnits(end-1:end) = {'m/s'};
                    d.Properties.CustomProperties.VariableSerials(end-1:end) = d.Properties.CustomProperties.VariableSerials(strcmp(ws,d.Properties.VariableNames));
                end
                %load smoothed bestnav, compute ship heading as a vector
                [dn, hn] = mload(fullfile(mgetdir('sum'),['bestnav_' MEXEC_G.MSCRIPT_CRUISE_STRING]), '/');
                headvar = munderway_varname('headvar', hn.fldnam, 1, 's');
                [headav_e, headav_n] = uvsd(ones(size(dn.(headvar))), dn.(headvar), 'sduv');
                %interpolate to wind file times
                headav = interp1(dn.(tgvar), complex(headav_e, headav_n), d.(tgvar));
                %back to ship heading
                [~, merged_heading] = uvsd(real(headav), imag(headav), 'uvsd');
                relwind_direarth = mcrange(180+d.(wd)+merged_heading, 0, 360);
                [relwind_e, relwind_n] = uvsd(d.(ws), relwind_direarth, 'sduv');
                %ship velocity
                [shipv_e, shipv_n] = uvsd(dn.smg, dn.cmg, 'sduv');
                shipv = interp1(dn.(tgvar), complex(shipv_e,shipv_n), d.(tgvar));
                %vector wind over earth
                d.truwind_e = relwind_e + real(shipv);
                d.truwind_n = relwind_n + imag(shipv);
                if ~sum(strcmp('truwind_e',h.fldnam))
                    d.Properties.VariableUnits(end-1:end) = {'m/s eastward' 'm/s northward'};
                    d.Properties.CustomProperties.VariableSerials(end-1:end) = d.Properties.CustomProperties.VariableSerials(strcmp(ws,d.Properties.VariableNames));
                    comment = 'truwind calculated using average nav and heading data interpolated and added to 1Hz wind data';
                    if ~contains(h.comment, comment); h.comment = [h.comment '\n ' comment]; end
                end
                ngvars = [ngvars ws wd 'xcomponent' 'ycomponent'];
            else
                %handle the surface ocean variables in ocean instead
                ngvars = [ngvars intersect(d.Properties.VariableNames, {'fluo' 'trans' 'flow' 'tempr' 'temph' 'conductivity' 'salinity'})]; %***munderway_varname
            end


    end

    %exclude variables in ngvars
    [excv,~] = intersect(d.Properties.VariableNames, ngvars);
    %and those not in gvars
    if exist('gvars','var') && ~isempty(gvars)
        [ev,~] = setdiff(d.Properties.VariableNames, gvars);
        excv = unique([excv ev]); 
    end
    if ~isempty(excv)
        d(:,ismember(d.Properties.VariableNames,excv)) = [];
    end

    %match h back to d.Properties
    h.fldnam = d.Properties.VariableNames;
    h.fldunt = d.Properties.VariableUnits;
    h.fldserial = d.Properties.CustomProperties.VariableSerials;


    %%%%%%%%%%%%%%%%%%%%%%%%%%%% post %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(stage, 'post')

    comment = [];

    switch datatype

        case 'nav'
            % convert dummy easting and northing back to heading
            [~, d.heading] = uvsd(d.dum_e, d.dum_n, 'uvsd');
            % calculate speed, course, distrun
            latvar = munderway_varname('latvar', h.fldnam, 1 ,'s');
            lonvar = munderway_varname('lonvar', h.fldnam, 1, 's');
            dist = zeros(size(d.(latvar))); delt = dist; ang = nan+dist;
            ii = find(~isnan(d.(latvar)));
            [dist(ii(2:end)), ang(ii(2:end))] = sw_dist(d.(latvar)(ii), d.(lonvar)(ii), 'km');
            delt(ii(2:end)) = diff(d.(tgvar)(ii)*86400);
            speed = 1000*dist./delt; %m/s
            ve = speed.*cos(ang*pi/180);
            vn = speed.*sin(ang*pi/180);
            [d.smg, d.cmg] = uvsd(ve, vn, 'uvsd');
            d.distrun = cumsum(dist);
            if ~sum(strcmp('heading',h.fldnam))
                h = m_append_header_fld(h, {'heading'}, {'degrees E of N'}, lonvar);
                h.comment = [h.comment '\n heading calculated from vector-averaged easting and northing'];
            end
            if ~sum(strcmp('smg',h.fldnam))
                h = m_append_header_fld(h, {'smg' 'cmg' 'distrun'}, {'m/s' 'degrees' 'km'}, lonvar);
                h.comment = [h. comment '\n speed, course over ground, and distance run calculated from vector-averaged data'];
            end

        case 'bathy'
            opt1 = 'uway_proc'; opt2 = 'bathy_grid'; get_cropt
            if exist('zbathy','var') && ~isempty(zbathy)
                [dn, h] =  mloadq(fullfile(mgetdir(default_navstream),sprintf('bestnav_%s',mcruise)),'/');
                %dn.time = m_commontime(dn, 'time', h, timestring); %already the same
                lonvar = munderway_varname('lonvar',h.fldnam,1,'s');
                latvar = munderway_varname('latvar',h.fldnam,1,'s');
                lon = interp1(dn.time,dn.(lonvar),d.time);
                lat = interp1(dn.time,dn.(latvar),d.time);
                clear dn h
                xbathy = [xbathy-360 xbathy]; zbathy = [zbathy zbathy];
                iix = find(xbathy>=min(lon)-1 & xbathy<=max(lon)+1);
                iiy = find(ybathy>=min(lat)-1 & ybathy<=max(lat)+1);
                bathymap = interp2(xbathy(iix),ybathy(iiy),zbathy(iiy,iix),lon,lat);
                xbathy = xbathy(iix); ybathy = ybathy(iiy);
                clear lon lat iix iiy
                %***
            end
            %water depth relative to surface
            xducervar = munderway_varname('xducerdepvar', h.fldnam, 1, 's');
            depbtvar = munderway_varname('deptrefvar', h.fldnam, 1, 's');
            if ~isempty(depbtvar) && ~isempty(xducervar)
                newdep = setdiff({'waterdepth','waterdepthfromsurface'},h.fldnam);
                if isempty(newdep)
                    warning('%s already contains both waterdepth and waterdepthfromsurface, skipping recalculation from depth relative to transducer',source)
                else
                    newdep = newdep{1};
                end
                d.(newdep) = d.(depbtvar) + d.(xducervar);
                if ~ismember(h.fldnam,newdep)
                    h = m_append_header_fld(h, {newdep}, {'m'}, depbtvar);
                end
                d = rmfield(d,depbtvar);
                m = strcmp(depbtvar,h.fldnam);
                h.fldunt(m) = []; h.fldnam(m) = [];
                if isfield(h, 'fldserial'); h.fldserial(m) = []; end
                comment = sprintf('\n %s has transducer offset applied', newdep);
            end
            if ~isempty(xducervar)
                d = rmfield(d,xducervar);
                m = ismember(h.fldnam,xducervar);
                h.fldunt(m) = []; h.fldnam(m) = [];
                if isfield(h, 'fldserial'); h.fldserial(m) = []; end
            end

        case 'ocean'

            %(re)calculate salinity (to not double-apply any calibration)
            cvar = munderway_varname('condvar', h.fldnam, 1, 's');
            tvar = munderway_varname('tempvar', h.fldnam, 1, 's');
            if ~isempty(cvar) && ~isempty(tvar)
                cu = h.fldunt{strcmp(cvar,h.fldnam)};
                if strcmp('mS/cm',cu) || strcmp('mS_per_cm',cu)
                    fac = 1;
                elseif strcmp('S/m',cu) || strcmp('S_per_m',cu)
                    fac = 10;
                else
                    warning('cond units %s not recognised, skipping calculating psal in %s',cu,datatype)
                    fac = [];
                end
                if ~isempty(fac)
                    svar = munderway_varname('salvar', h.fldnam, 1, 's');
                    if isempty(svar)
                        svar = 'psal';
                    end
                    d.(svar) = gsw_SP_from_C(fac*d.(cvar),d.(tvar),0);
                    if ~ismember(h.fldnam,svar)
                        h = m_append_header_fld(h, {svar}, {'pss-78'}, cvar);
                    else
                        su = h.fldunt{strcmp(svar,h.fldnam)};
                        if isempty(su) || strcmp(' ',su) || strcmp('json_empty',su)
                            h.fldunt{strcmp(svar,h.fldnam)} = 'pss-78';
                        end
                    end
                    if ~exist('cpstr','var'); cpstr = ''; end
                    comment = sprintf('\n psal calculated from edited, averaged%s %s and %s',cpstr,cvar,tvar);
                end
            elseif isempty(tvar)
                warning('cond found but no temp to calculate psal in %s combined file',datatype)
            end
            %calibrate
            opt1 = 'uway_proc'; opt2 = 'tsg_cals'; get_cropt
            if isfield(uo, 'calstr') && sum(cell2mat(struct2cell(uo.docal)))
                [dcal, hcal] = apply_calibrations(d, h, uo.calstr, uo.docal, 'q');
                for no = 1:length(hcal.fldnam)
                    %apply to d, but save uncalibrated versions in case calibration changes
                    cname = [hcal.fldnam{no} '_cal'];
                    d.(cname) = dcal.(hcal.fldnam{no});
                    if ~ismember(h.fldnam,cname)
                        h.fldnam = [h.fldnam cname];
                        h.fldunt = [h.fldunt h.fldunt(strcmp(hcal.fldnam{no},h.fldnam))];
                        if isfield(h,'fldserial')
                            h.fldserial = [h.fldserial h.fldserial(strcmp(hcal.fldnam{no},h.fldnam))];
                        end
                    end
                end
                if no>0
                    h.comment = [h.comment hcal.comment];
                end
            end

        case 'atmos'
            %recalculate wind speed and direction from averaged vectors
            if isfield(d,'truwind_e')
                [d.truwind_spd, d.truwind_dir] = uvsd(d.truwind_e, d.truwind_n, 'uvsd');
                if ~ismember(h.fldnam,'truwind_spd')
                    h = m_append_header_fld(h, {'truwind_spd' 'truwind_dir'}, {'m_per_s' 'degrees counterclockwise of eastward'}, 'truwind_e');
                end
                comment = '\ntruwind calculated from vector-averaged components';
            end

    end

    varargout{1} = comment;

end