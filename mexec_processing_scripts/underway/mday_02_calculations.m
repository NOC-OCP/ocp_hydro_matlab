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

%%%%%%%%%%%%%%%%%%%%%%%%%%%% pre %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(stage,'pre')

    if strcmp(gmethod,'meannum')
        %fill in the (few, hopefully) missing points first
        d.dday = round(d.dday*86400)/86400;
        if abs(mode(diff(d.dday*86400))-1)<1e-3 && (d.dday(end)-d.dday(1))*86400>length(d.dday)
            t0 = setdiff([ddays(1)*86400:(ddays(end)+1)*86400-1]',round(d.dday*86400));
            d.dday = [d.dday; t0/86400];
            [d.dday,ii] = sort(d.dday);
            for no = 1:length(h.fldnam)
                if ~strcmp(h.fldnam{no},'dday')
                    d.(h.fldnam{no}) = [d.(h.fldnam{no}); nan(length(t0),1)];
                    d.(h.fldnam{no}) = d.(h.fldnam{no})(ii);
                end
            end
        end
    end

    %this needs to be done for nav or wind
    headvar = munderway_varname('headvar',h.fldnam,1,'s');
    if ~isempty(headvar)
        %calculate dummy easting and northing in order to vector average
        [d.dum_e, d.dum_n] = uvsd(ones(size(d.(headvar))), d.(headvar), 'sduv');
        if ~sum(strcmp('dum_e',h.fldnam))
            h = m_append_header_fld(h, {'dum_e' 'dum_n'}, {'dummy easting' 'dummy northing'}, headvar);
            h.comment = [h.comment '\n easting and northing calculated from heading at 1 hz'];
        end
        ngvars = [ngvars headvar];
    end

    switch datatype

        case 'bathy'
            depvar = munderway_varname('depvar',h.fldnam,1,'s');
            depsvar = munderway_varname('depsrefvar',h.fldnam,1,'s');
            deptvar = munderway_varname('deptrefvar',h.fldnam,1,'s');
            if isempty(depvar) && ~isempty(deptvar)
                if ~sum(strcmp('waterdepth',h.fldnam))
                    d.waterdepth = d.(deptvar) + d.transduceroffset; %***
                    h = m_append_header_fld(h, {'waterdepth'}, {'m'}, depvar);
                    depvar = munderway_varname('depvar',h.fldnam,1,'s');
                    depsvar = munderway_varname('depsrefvar',h.fldnam,1,'s');
                    deptvar = munderway_varname('deptrefvar',h.fldnam,1,'s');
                end
            end
            if ~iscell(depvar); depvar = {depvar}; end
            if ~iscell(depsvar); depsvar = {depsvar}; end
            if ~iscell(deptvar); deptvar = {deptvar}; end
            depvar = union(depvar,union(depsvar,deptvar));
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

        case 'ocean'
            %put the surfmet radiation variables in atmos instead
            exc = {'parport' 'parstarboard' 'tirport' 'tirstarboard' 'humidity' 'airpressure' 'airtemperature'}; %***munderway_vars
            exc(~ismember(exc,h.fldnam)) = [];
            ngvars = [ngvars exc];

        case 'atmos'

            ws = munderway_varname('rwindsvar',h.fldnam,1,'s');
            wd = munderway_varname('rwinddvar',h.fldnam,1,'s');
            if ~isempty(ws)
                if ~sum(strcmp('xcomponent',h.fldnam)) %***
                    %compute x and y component (platform-relative) from speed
                    %and (compass) direction
                    [d.xcomponent, d.ycomponent] = uvsd(d.(ws), d.(wd), 'sduv');
                    h = m_append_header_fld(h, {'xcomponent' 'ycomponent'}, {'m/s' 'm/s'}, ws);
                end
                %load smoothed bestnav, compute ship heading as a vector
                [dn, hn] = mload(fullfile(MEXEC_G.mexec_data_root, 'nav', ['bestnav_' MEXEC_G.MSCRIPT_CRUISE_STRING]),'/');
                headvar = munderway_varname('headvar', hn.fldnam, 1, 's');
                [headav_e, headav_n] = uvsd(ones(size(dn.(headvar))), dn.(headvar), 'sduv');
                %interpolate to wind file times
                headav = interp1(dn.dday, complex(headav_e, headav_n), d.dday);
                %back to ship heading
                [~, merged_heading] = uvsd(real(headav), imag(headav), 'uvsd');
                relwind_direarth = mcrange(180+d.(wd)+merged_heading, 0, 360);
                [relwind_e, relwind_n] = uvsd(d.(ws), relwind_direarth, 'sduv');
                %ship velocity
                [shipv_e, shipv_n] = uvsd(dn.smg, dn.cmg, 'sduv');
                shipv = interp1(dn.dday, complex(shipv_e,shipv_n), d.dday);
                %vector wind over earth
                d.truwind_e = relwind_e + real(shipv);
                d.truwind_n = relwind_n + imag(shipv);
                if ~sum(strcmp('truwind_e',h.fldnam))
                    h = m_append_header_fld(h, {'truwind_e' 'truwind_n'}, {'m/s eastward' 'm/s northward'}, ws);
                    h.comment = [h.comment '\n truwind calculated using average nav and heading data interpolated and added to 1Hz wind data'];
                end
                ngvars = [ngvars ws wd 'xcomponent' 'ycomponent'];
            else
                exc = {'fluo' 'trans' 'flow' 'tempr' 'temph' 'conductivity' 'salinity'}; %***munderway_varname
                exc(~ismember(exc,h.fldnam)) = [];
                ngvars = [ngvars exc];
            end


    end

    [excv,iie] = intersect(h.fldnam, ngvars);
    if exist('gvars','var') && ~isempty(gvars)
        [ev,ii] = setdiff(h.fldnam, gvars);
        excv = [excv ev]; iie = [iie(:)' ii(:)'];
    end
    if ~isempty(excv)
        d = rmfield(d,excv);
        h.fldunt(iie) = []; h.fldnam(iie) = []; 
        if isfield(h, 'fldserial')
            h.fldserial(iie) = [];
        end
    end

    varargout{1} = gvars; varargout{2} = ngvars;


%%%%%%%%%%%%%%%%%%%%%%%%%%%% post %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(stage, 'post')

    comment = [];

    switch datatype

        case 'nav'
            % convert dummy easting and northing back to heading
            [~, d.heading] = uvsd(d.dum_e, d.dum_n, 'uvsd');
            varsrm = {'dum_e','dum_n'};
            d = rmfield(d,varsrm);
            m = ismember(h.fldnam,varsrm); h.fldnam(m) = []; h.fldunt(m) = []; h.fldserial(m) = [];
            % calculate speed, course, distrun
            latvar = munderway_varname('latvar', h.fldnam, 1 ,'s');
            lonvar = munderway_varname('lonvar', h.fldnam, 1, 's');
            dist = zeros(size(d.(latvar))); delt = dist; ang = nan+dist;
            ii = find(~isnan(d.(latvar)));
            [dist(ii(2:end)), ang(ii(2:end))] = sw_dist(d.(latvar)(ii), d.(lonvar)(ii), 'km');
            delt(ii(2:end)) = diff(d.dday(ii)*86400);
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
                    %apply to d, and don't save uncalibrated versions
                    d.([hcal.fldnam{no}]) = dcal.(hcal.fldnam{no});
                end
                if no>0
                    h.comment = [h.comment hcal.comment];
                end
            end

        case 'atmos'
            %recalculate wind speed and direction from averaged vectors
            [d.truwind_spd, d.truwind_dir] = uvsd(d.truwind_e, d.truwind_n, 'uvsd');
            if ~ismember(h.fldnam,'truwind_spd')
                h = m_append_header_fld(h, {'truwind_spd' 'truwind_dir'}, {'m_per_s' 'degrees counterclockwise of eastward'}, 'truwind_e');
            end
            comment = '\ntruwind calculated from vector-averaged components';

    end

    varargout{1} = comment;

end