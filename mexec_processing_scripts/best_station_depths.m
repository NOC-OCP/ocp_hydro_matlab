function bestdeps = best_station_depths(stns,varargin)
% function bestdeps = best_station_depths(stns)
% function bestdeps = best_station_depths(stns,depth_source)
%
% find station depths for stations stns (default: all with a ctd*raw.nc
%     file, or as specified in opt_cruise)
% using specified depth source or sources (cell array) 
%        (default: {'ladcp' 'ctd'}, or as specified in opt_cruise)
%     depth_source = 'file': load from a text file
%         either csv with column headers including statnum and depth
%         or two columns no header, first column is statnum, second depth
%     depth_source = 'ctd': calculate from CTD depth and altimeter reading
%     depth_source = 'ladcp': load from IX LADCP .mat files
%     depth_source = 'bathy': load from sim/ea600 bathymetry file
%
% Where LADCP data are available and processed in combination with CTD
%     data, that gives the best results 

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

if isempty(stns)
    %find statnums with ctd data
    fn = dir(fullfile(mgetdir('M_CTD'), ['ctd_' mcruise '_*_raw*.nc']));
    stns = struct2table(fn).name;
    stns = unique(cellfun(@(x) str2double(x(length(mcruise)+[6:8])), stns));
else
    stns = stns(:);
end

%preferred method(s) for calculating depths
if nargin>1
    depth_source = varargin{1};
else
    if MEXEC_G.ix_ladcp
        depth_source = {'ladcp', 'ctd'}; %ladcp if present, then fill with ctd press+altimeter
    else
        depth_source = {'ctd'};
    end
end
opt1 = 'castpars'; opt2 = 'bestdeps'; get_cropt

if ~iscell(depth_source)
    depth_source = {depth_source};
end

%set up
bestdeps = [stns NaN+zeros(length(stns),3)];

%apply in order
ii0 = 1:length(stns); %first try filling all rows using depth_source{1}
for sno = 1:length(depth_source)
    if (strcmp(depth_source{sno},'file') && exist(fnintxt, 'file'))
        fnin = fnintxt;
    else
        fnin = [];
    end
    bestdeps(ii0,:) = get_deps(bestdeps(ii0,:), depth_source{sno}, fnin);
    ii00 = ii0;
    ii0 = find(isnan(bestdeps(:,2))); %these didn't get a value, so try next depth_source
    ii = setdiff(ii00, ii0); bestdeps(ii,4) = sno; %mark the ones that did work
end

%finally look to cruise options for any changes
replacedeps = []; stnmiss = [];  replacealt = [];
xducer_offset = 0; iscor = 0;
opt1 = 'castpars'; opt2 = 'bestdeps'; get_cropt  % inserted by bak en705 24 jul 2023; If you don't get_cropt here, replacedeps is empty

if ~isempty(stnmiss)
    bestdeps(ismember(bestdeps(:,1),stnmiss),:) = [];
end
if ~isempty(replacedeps)
    [~,ia,ib] = intersect(replacedeps(:,1), bestdeps(:,1));
    y.cordep = replacedeps(ia,2);
    if ~iscor
        sd = replacedeps(ia,:) + xducer_offset;
        %apply carter correction for these
        [dsum,~] = mload(fullfile(mgetdir('sum'),sprintf('station_summary_%s_all.nc',mcruise)),'lat lon statnum ');
        [~,ic,id] = intersect(sd(:,1),dsum.statnum);
        if length(ic)<length(ia)
            warning('position not found in summary/not applying carter correction for some stations')
        else
            y = mcarter(dsum.lat(id), dsum.lon(id), sd(ic,2));
        end
    end
    bestdeps(ib,2) = y.cordep;
end
if ~isempty(replacealt)
    [~,ia,ib] = intersect(replacealt(:,1), bestdeps(:,1));
    bestdeps(ib,3) = replacealt(:,2);
end


function bestdeps = get_deps(bestdeps, depth_source, fnin)

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

iif = find(isnan(bestdeps(:,2)+bestdeps(:,3)));

switch depth_source
        
    case 'file' % load from text file
        
        try
            dsd = dataset('File',fnin,'Delimiter',',');
            fnam = dsd.Properties.VarNames;
            if sum(strcmp('statnum',fname))==0 || sum(strcmp('depth',fnam))==0
                error;
            else
                deps = [dsd.statnum dsd.depth]; %two-column format
            end
        catch
            deps = load(fnin);
        end
        [~,ii1,ii2] = intersect(deps(:,1), bestdeps(iif,1));
        bestdeps(iif(ii2),2) = deps(ii1,2);
        if size(deps,2)>2
            bestdepts(iif(ii2),3) = deps(ii1,3);
        end
        
    case 'ctd' % calculate from CTD depth and altimeter
        
        for no = 1:length(iif) % try to fill these in from 1hz files
            fn = fullfile(mgetdir('M_CTD'), sprintf('ctd_%s_%03d_psal.nc', mcruise, bestdeps(iif(no),1)));
            if exist(fn,'file')
                [d, h] = mloadq(fn, '/');
                if ~isfield(d,'altimeter'); warning(['no altimeter record in ' fn]); continue; end
                dd = mloadq(fullfile(mgetdir('ctd'),sprintf('dcs_%s_%03d.nc',mcruise,bestdeps(iif(no),1))),'/');
                d.press = d.press(d.scan>=dd.scan_start & d.scan<=dd.scan_end);
                d.altimeter = d.altimeter(d.scan>=dd.scan_start & d.scan<=dd.scan_end);
                if ~isfield(d, 'depSM'); d.depSM = filter_bak(ones(1,21), sw_dpth(d.press, h.latitude)); end
                [~,bot_ind] = max(d.depSM); % Find cast max depth
                % Average altimeter and CTD depth for 30 seconds around max depth
                ii = bot_ind-15:bot_ind+15;
                if min(ii)>0 && max(ii)<=length(d.depSM)
                    ctd_bot = m_nanmean(d.depSM(bot_ind-15:bot_ind+15));
                    % Eliminate altim readings >20m (unlikely when CTD at bottom)
                    altim_select = d.altimeter(bot_ind-15:bot_ind+15); altim_select(altim_select>30) = NaN; 
                    bestdeps(iif(no),3) = m_nanmean(altim_select);
                    bestdeps(iif(no),2) = bestdeps(iif(no),3) + ctd_bot;
                end
            end
        end
        
    case 'ladcp' % load from IX LADCP .mat files
        
        for no = 1:length(iif)
            lf = fullfile(mgetdir('M_IX'), 'DLUL_GPS_BT', 'processed', sprintf('%03d.mat',bestdeps(iif(no),1)));
            if ~exist(lf,'file')
                lf = fullfile(mgetdir('M_IX'), 'DL_GPS_BT', 'processed', sprintf('%03d.mat',bestdeps(iif(no),1)));
                if ~exist(lf,'file')
                    lf = fullfile(mgetdir('M_IX'), 'DLUL_GPS_BT', 'processed', sprintf('%03d', bestdeps(iif(no),1)), sprintf('%03d.mat',bestdeps(iif(no),1)));
                    if ~exist(lf, 'file')
                        lf = fullfile(mgetdir('M_IX'), 'DL_GPS_BT', 'processed', sprintf('%03d', bestdeps(iif(no),1)), sprintf('%03d.mat',bestdeps(iif(no),1)));
                    end
                end
            end
            if exist(lf, 'file')
                load(lf, 'p');
                bestdeps(iif(no),2) = round(p.zbottom);
            else
                warning('no ladcp with BT for %03d',bestdeps(iif(no),1))
            end
        end
        
    case 'bathy'
        
        simvar = munderway_varname('singlebvar',MEXEC_G.MDIRLIST(:,1)',1,'s');
        if ~isempty(simvar)
            fileb = fullfile(mgetdir(simvar), [simvar '_' mcruise '_01.nc']);
            if exist(fileb,'file')
                [db,hb] = mloadq(fileb,'/');
                for no = 1:length(iif)
                    fn = fullfile(mgetdir('M_CTD'), sprintf('dcs_%s_%03d.nc',mcruise,bestdeps(iif(no))));
                    if exist(fn, 'file')
                        [ddcs, hdcs] = mloadq(fn,'/');
                        btim = m_commontime(db, 'time', hb, hdcs); %put into dcs file time base
                        iig = find(~isnan(db.depth));
                        bestdeps(iif(no),2) = interp1(btim(iig),db.depth(iig),ddcs.time_bot);
                        dt = btim(iig)-ddcs.time_bot; dt = [min(dt(dt>0)) max(dt(dt<0))];
                        if max(dt)>3600
                            warning(['interpolating ea600 over >1 hour gap for ' num2str(bestdeps(iif(no)))])
                        end
                    end
                end
            end
        end
        
end

