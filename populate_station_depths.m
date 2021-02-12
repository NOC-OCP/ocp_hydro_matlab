function bestdeps = populate_station_depths()
% function bestdeps = populate_station_depths()
% Prepare a .mat file with station depths for use in mdep_01
% bak on jr281 April 2013%
%
% populate a file called 'station_depths_cruise.mat' with a single
% array, bestdeps = [statnum depth]. Missing stations have a NaN as a
% placeholder
%
% tries to do this using specified depth_source
%
% depth_source = 'file': load from a text file
%     either csv with column headers including statnum and depth
%     or two columns no header, first column is statnum, second depth
% depth_source = 'ctd': calculate from CTD depth and altimeter reading (will load and update station_depths.mat)
% depth_source = 'ladcp': load from IX LADCP .mat file, creating or updating existing station_depths .mat file
% depth_source = 'bathy': load from sim/ea600 bathymetry file
%
% Best results are from LADCP processing (depth_source=4) combining LADCP and CTD data

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

%find statnums with ctd data
fn = dir([mgetdir('M_CTD') '/ctd_' mcruise '_*_raw.nc']);
stns = struct2cell(fn); stns = cell2mat(stns(1,:)'); stns = str2num(stns(:,end-9:end-7));
if sum(stns==0)
    stnind = stns+1;
else
    stnind = stns;
end

%output file of depths
fnot = [mgetdir('M_CTD_DEP') '/station_depths_' mcruise '.mat'];

%load this if it already exists and extend if necessary, otherwise set up empty array
if exist(fnot, 'file')
    disp(['loading ' fnot]); load(fnot, 'bestdeps');
    ns = max(stns)-max(bestdeps(:,1));
    if ns>0
        bestdeps = [bestdeps; [[max(bestdeps(:,1))+1:max(stns)]' NaN+zeros(ns,1)]];
    end
else
    bestdeps = NaN+zeros(max(stnind),2); bestdeps(stnind,1) = stns;
end

%which stations need depths
ii0 = find(isnan(bestdeps(:,2)));
scriptname = mfilename; oopt = 'depth_recalc'; get_cropt
if length(recalcdepth_stns)>0
    ii0 = unique([ii0; find(ismember(bestdeps(:,1),recalcdepth_stns))]);
end
bestdeps(ii0,2) = NaN;

%preferred method(s) for calculating depths
scriptname = mfilename; oopt = 'depth_source'; get_cropt

%apply in order
for sno = 1:length(depth_source)
    if (strcmp(depth_source{sno},'file') & exist(fnintxt, 'file'))
        fnin = fnintxt;
    else
        fnin = [];
    end
    bestdeps(ii0,:) = get_deps(bestdeps(ii0,:), depth_source{sno}, fnin);
end

%finally look to cruise options for any changes
scriptname = mfilename; oopt = 'bestdeps'; get_cropt
if length(replacedeps)>0
    [c,ia,ib] = intersect(replacedeps(:,1), bestdeps(:,1));
    if length(ia)<size(replacedeps(:,1)); error(['replacedeps repeats stations; check opt_' mcruise]); end
    bestdeps(ib,2) = replacedeps(ia,2);
end

save(fnot, 'bestdeps')


function bestdeps = get_deps(bestdeps, depth_source, fnin);

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

iif = find(isnan(bestdeps(:,2)));

switch depth_source
        
    case 'file' % load from text file
        
        try
            dsd = dataset('File',fnin,'Delimiter',',');
            fnam = dsd.Properties.VarNames;
            if sum(strcmp('statnum',fname))==0 | sum(strcmp('depth',fnam))==0
                error;
            else
                deps = [dsd.statnum dsd.depth]; %two-column format
            end
        catch
            deps = load(fnin);
        end
        [c,ii1,ii2] = intersect(deps(:,1), bestdeps(iif,1));
        bestdeps(iif(ii2),2) = deps(ii1,2);
        
    case 'ctd' % calculate from CTD depth and altimeter
        
        for no = 1:length(iif) % try to fill these in from 1hz files
            fn = sprintf('%s/ctd_%s_%03d_psal.nc', mgetdir('M_CTD'), mcruise, bestdeps(iif(no),1));
            if exist(fn)
                [d, h] = mloadq(fn, '/');
                if ~isfield(d, 'depSM'); d.depSM = filter_bak(ones(1,21), sw_dpth(d.press, h.latitude)); end
                [max_dep,bot_ind] = max(d.depSM); % Find cast max depth
                % Average altimeter and CTD depth for 30 seconds around max depth
                ii = bot_ind-15:bot_ind+15;
                if min(ii)>0 & max(ii)<=length(d.depSM)
                    ctd_bot = nanmean(d.depSM(bot_ind-15:bot_ind+15));
                    % Eliminate altim readings >20m (unlikely when CTD at bottom)
                    altim_select = d.altimeter(bot_ind-15:bot_ind+15); altim_select(altim_select>20) = NaN; alt_bot = nanmean(altim_select);
                    bestdeps(iif(no),2) = alt_bot + ctd_bot;
                end
            end
        end
        
    case 'ladcp' % load from IX LADCP .mat files
        
        for no = 1:length(iif)
            lf = sprintf('%s/DLUL_GPS/processed/%03d/%03d.mat', mgetdir('M_IX'),bestdeps(iif(no),1),bestdeps(iif(no),1));
            if ~exist(lf, 'file')
                lf = sprintf('%s/DL_GPS/processed/%03d/%03d.mat', mgetdir('M_IX'),bestdeps(iif(no),1),bestdeps(iif(no),1));
            end
            if exist(lf, 'file')
                load(lf, 'p');
                bestdeps(iif(no),2) = round(p.zbottom);
            end
        end
        
    case 'bathy'
        
        simvar = mvarname_find({'ea600' 'sim'},MEXEC_G.MDIRLIST(:,1));
        if length(simvar)>0
            fileb = [mgetdir(simvar) '/' simvar '_' mcruise '_01.nc'];
            if exist(fileb,'file')
                [db,hb] = mloadq(fileb,'/');
                for no = 1:length(iif)
                    fn = sprintf('%s/dcs_%s_%03d.nc',mgetdir('M_CTD'),mcruise,bestdeps(iif(no)));
                    [ddcs,hdcs] = mloadq(fn,'/');
                    btim = m_commontime(db.time, hb.data_time_origin, hdcs.data_time_origin); %put into dcs file time origin
                    bestdeps(iif(no),2) = interp1(btim,db.depth,ddcs.time_bot);
                end
            end
        end
        
end

