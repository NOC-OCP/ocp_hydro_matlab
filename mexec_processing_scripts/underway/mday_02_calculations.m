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
        h.fldnam = [h.fldnam 'dum_e' 'dum_n'];
        h.fldunt = [h.fldunt 'dummy easting' 'dummy northing'];
        h.comment = [h.comment '\n easting and northing calculated from heading at 1 hz'];
        ngvars = [ngvars headvar];
    end

    switch datatype

        case 'bathy'
            depvar = munderway_varname('depvar',h.fldnam,1,'s');
            depsvar = munderway_varname('depsrefvar',h.fldnam,1,'s');
            deptvar = munderway_varname('deptrefvar',h.fldnam,1,'s');
            if isempty(depvar) && ~isempty(deptvar)
                d.waterdepth = d.(deptvar) + d.transduceroffset; %***
                h.fldnam = [h.fldnam 'waterdepth'];
                h.fldunt = [h.fldunt 'm'];
                depvar = munderway_varname('depvar',h.fldnam,1,'s');
                depsvar = munderway_varname('depsrefvar',h.fldnam,1,'s');
                deptvar = munderway_varname('deptrefvar',h.fldnam,1,'s');
            end
            depvar = union(depvar,union(depsvar,deptvar));
            if ~isempty(depvar)
                if ~iscell(depvar); depvar = {depvar}; end
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

        case 'atmos'

            if ~sum(strcmp('xcomponent',h.fldnam)) %***
                %compute x and y component (platform-relative) from speed
                %and (compass) direction
                ws = munderway_varname('rwindsvar',h.fldnam,1,'s');
                wd = munderway_varname('rwinddvar',h.fldnam,1,'s');
                if ~isempty(ws)
                    [d.xcomponent, d.ycomponent] = uvsd(d.(ws), d.(wd), 'sduv');
                    h.fldnam = [h.fldnam 'xcomponent' 'ycomponent'];
                    h.fldunt = [h.fldunt 'm/s' 'm/s']; %***
                end
            end
            %load smoothed bestnav, compute ship heading as a vector
            [dn, hn] = mload(fullfile(MEXEC_G.mexec_data_root, 'nav', ['bestnav_' MEXEC_G.MSCRIPT_CRUISE_STRING]),'/');
            headvar = munderway_varname('headvar', hn.fldnam, 1, 's');
            [headav_e, headav_n] = uvsd(ones(size(dn.(headvar))), dn.(headvar), 'sduv');
            %interpolate to wind file times
            headav = interp1(dn.dday, complex(headav_e, headav_n), dw.dday);
            %back to ship heading
            [~, merged_heading] = uvsd(real(headav), imag(headav), 'uvsd');
            relwind_direarth = mcrange(180+d.(wd)+merged_heading, 0, 360);
            [relwind_e, relwind_n] = uvsd(d.(ws), relwind_direarth, 'sduv');
            %ship velocity
            [shipv_e, shipv_n] = uvsd(dn.smg, dn.cmg, 'sduv');
            shipv = interp1(dn.dday, complex(shipv_e,shipv_n), dw.dday);
            %vector wind over earth
            d.truwind_e = relwind_e + real(shipv);
            d.truwind_n = relwind_n + imag(shipv);
            h.fldnam = [h.fldnam 'truwind_e' 'truwind_n'];
            h.fldunt = [h.fldunt 'm/s eastward' 'm/s northward'];
            h.comment = [h.comment '\n truwind calculated using average nav and heading data interpolated and added to 1Hz wind data'];
            ngvars = [ngvars ws wd];

    end

    [excv,iie] = intersect(h.fldnam, ngvars);
    if exist('gvars','var') && ~isempty(gvars)
        [ev,ii] = setdiff(h.fldnam, gvars);
        excv = [excv ev]; iie = [iie(:)' ii(:)'];
    end
    if ~isempty(excv)
        d = rmfield(d,excv);
        h.fldunt(iie) = []; h.fldnam(iie) = []; 
    end

    varargout{1} = gvars; varargout{2} = ngvars;


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
            delt(ii(2:end)) = diff(d.dday(ii)*86400);
            speed = 1000*dist./delt; %m/s
            ve = speed.*cos(ang*pi/180);
            vn = speed.*sin(ang*pi/180);
            [d.smg, d.cmg] = uvsd(ve, vn, 'uvsd');
            d.distrun = cumsum(dist);
            if ~sum(strcmp('heading',h.fldnam))
                h.fldnam = [h.fldnam 'heading'];
                h.fldunt = [h.fldunt 'degrees E of N'];
                h.comment = [h.comment '\n heading calculated from vector-averaged easting and northing'];
            end
            if ~sum(strcmp('smg',h.fldnam))
                h.fldnam = [h.fldnam 'smg' 'cmg' 'distrun'];
                h.fldunt = [h.fldunt 'm/s' 'degrees' 'km'];
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
                h.fldnam = [h.fldnam newdep];
                h.fldunt = [h.fldunt 'm'];
                d = rmfield(d,depbtvar); 
                h.fldunt(strcmp(depbtvar,h.fldnam)) = [];
                h.fldnam(strcmp(depbtvar,h.fldnam)) = [];
                comment = sprintf('\n %s has transducer offset applied', newdep);
            end
            if ~isempty(xducervar)
                d = rmfield(d,xducervar);
                h.fldunt(ismember(h.fldnam,xducervar)) = [];
                h.fldnam(ismember(h.fldnam,xducervar)) = [];
            end

        case 'ocean'

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
            %(re)calculate salinity
            cvar = munderway_varname('condvar', h.fldnam, 1, 's');
            tvar = munderway_varname('tempvar', h.fldnam, 1, 's');
            if ~isempty(cvar) && ~isempty(tvar)
                cu = h.fldunt{strcmp(cvar,h.fldnam)};
                if strcmp('mS/cm',cu) || strcmp('mS_per_cm',cu)
                    fac = 1;
                elseif strcmp('S/m',cu) || strcmp('S_per_m',cu)
                    fac = 10;
                else
                    warning('cond units %s not recognised, skipping calculating psal in %s',cu,abbrev)
                    fac = [];
                end
                if ~isempty(fac)
                    svar = munderway_varname('salvar', h.fldnam, 1, 's');
                    if isempty(svar)
                        svar = 'psal';
                    end
                    d.(svar) = gsw_SP_from_C(fac*d.(cvar),d.(tvar),0);
                    if ~isfield(d,svar)
                        h.fldnam = [h.fldnam svar];
                        h.fldunt = [h.fldunt 'pss-78'];
                    end
                    if ~exist('cpstr','var'); cpstr = ''; end
                    comment = sprintf('\n psal calculated from edited, averaged%s %s and %s',cpstr,cvar,tvar);
                end
            elseif isempty(tvar)
                warning('cond found but no temp to calculate psal in %s combined file',datatype)
            end

        case 'atmos'
            %recalculate wind speed and direction from averaged vectors
            [d.truwind_spd, d.truwind_dir] = uvsd(d.truwind_e, d.truwind_n, 'uvsd');
            h.fldnam = [h.fldnam 'truwind_spd' 'truwind_dir'];
            h.fldunt = [h.fldunt 'm_per_s' 'degrees counterclockwise of eastward']; %***
            comment = '\ntruwind calculated from vector-averaged components';

    end

    varargout{1} = comment;

end