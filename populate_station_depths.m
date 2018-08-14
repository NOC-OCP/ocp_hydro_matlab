function bestdeps = populate_station_depths()
% function bestdeps = populate_station_depths()
% Prepare a .mat file with station depths for use in mdep_01
% bak on jr281 April 2013
%
% depths should be in corrected metres.
%
% populate a file called 'station_depths_cruise.mat' with a single
% array of depths, one per station number. Missing stations have a NaN as a
% placeholder
%
% depths can be obtained from a text file (with or without header); 
% IX-processed LADCP .mat files; or CTD data
% 
% Best results are from LADCP processing combining LADCP and CTD data
%
%
% ylf edited jr16002 and jc145 to include code for different ways to get depth,
% depending on settings in opt_cruise
% depmeth = 1 (default): load from a two-column text file of [stn dep]
% depmeth = 2: load from text file with header
% depmeth = 3: calculate from CTD depth and altimeter reading (will load and update station_depths.mat)
% depmeth = 4: load from IX LADCP .mat file, creating or updating existing station_depths .mat file

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING; scriptname = mfilename; 

root_ctddep = mgetdir('M_CTD_DEP');
root_ctd = mgetdir('M_CTD');

oopt = 'fnin'; get_cropt %depmeth, and fnin if depmeth is 1 or 2
if depmeth==3
   fnin = [root_ctd '/ctd_' mcruise '_'];
elseif depmeth==4
   fnin = [root_ctd '/ctd_' mcruise '*_raw.nc'];
end

%load depths file if it already exists, figure out which stations need to
%be added
fn = dir([root_ctd '/ctd_' mcruise '_*_raw.nc']);
stns = struct2cell(fn); stns = cell2mat(stns(1,:)'); stns = str2num(stns(:,end-9:end-7));
fnot = [root_ctddep '/station_depths_' mcruise '.mat'];
if exist(fnot, 'file')
   disp(['loading ' fnot]); load(fnot, 'bestdeps');
else
   bestdeps = NaN+zeros(max(stns),2); bestdeps(stns,1) = stns; 
end
stns = setdiff(stns, bestdeps(:,1));
if ~isempty(stns) % add more rows for new stations
   bestdeps = [bestdeps; [stns NaN+zeros(length(stns),1)]];
   [stns, ii] = sort(bestdeps(:,1)); bestdeps = bestdeps(ii,:);
end
ii0 = find(isnan(bestdeps(:,2))); 

%try preferred method, then cruise options, then method 3

bestdeps = get_deps(bestdeps, depmeth, fnin);

oopt = 'bestdeps'; get_cropt %modify any of the depths

ii = find(isnan(bestdeps(:,2))); 
if ~isempty(ii)
   fnin = [root_ctd '/ctd_' mcruise '_'];
   bestdeps = get_deps(bestdeps, 3, fnin);
end
oopt = 'bestdeps'; get_cropt % modify any of the depths

ii = find(isnan(bestdeps(:,1))); bestdeps(ii,:) = [];

save(fnot, 'bestdeps')

if ~isempty(ii0)
   disp('new depths:')
   disp(round(bestdeps(ii0,:)))
   disp('ok?'); pause
end



function bestdeps = get_deps(bestdeps, depmeth, fnin);

root_ctd = mgetdir('M_CTD');

switch depmeth

   case 1 % load from two-column text file

      a1 = load(fnin);
      a2 = bestdeps; a2(~isnan(bestdeps(:,2)),1) = NaN;
      [c,ii1,ii2] = intersect(a1(:,1), bestdeps(:,1));
      bestdeps(ii2,2) = a1(ii1,2);

   case 2 % load from text file with header
   
      fidin = fopen(fnin,'r');
      l1 = fgetl(fidin); % need to read a line of headers off the top
      a4 = fscanf(fidin,'%f %f %f %f');
      a4 = reshape(a4,ncol,numel(a4)/ncol)';
      fclose(fidin);
      dcol = 4; %***
      a1 = a4(:,[1 dcol]);
      a2 = bestdeps; a2(~isnan(bestdeps(:,2)),1) = NaN;
      [c,ii1,ii2] = intersect(a1(:,1), bestdeps(:,1));
      bestdeps(ii2,2) = a1(ii1,2);

   case 3 % calculate from CTD depth and altimeter, creating or updating existing station_depths .mat file

      ii = find(isnan(bestdeps(:,2))); 
      for no = 1:length(ii) % try to fill these in from 1hz files
         fn = [fnin sprintf('%03d', bestdeps(ii(no),1)) '_1hz.nc'];
         if exist(fn)
            [d, h] = mload(fn, '/');
            if ~isfield(d, 'depSM'); d.depSM = filter_bak(ones(1,21), sw_dpth(d.press, d.latitude)); end
            [max_dep,bot_ind] = max(d.depSM); % Find cast max depth
            % Average altimeter and CTD depth for 30 seconds around max depth
            ctd_bot = nanmean(d.depSM(bot_ind-15:bot_ind+15));
            % Eliminate altim readings >20m (unlikely when CTD at bottom)
            altim_select = d.altimeter(bot_ind-15:bot_ind+15); altim_select(altim_select>20) = NaN; alt_bot = nanmean(altim_select);
            bestdeps(ii(no),2) = alt_bot + ctd_bot;
         end
      end
   
   case 4 % load from IX LADCP .mat files, creating or updating existing station_depths .mat file

      root_ladcp = mgetdir('M_IX');
      fn = dir(fnin);
      stns = struct2cell(fn); stns = cell2mat(stns(1,:)');
      stn_string = stns(:,end-9:end-7); stns = str2num(stn_string);
      stns = intersect(stns, bestdeps(isnan(bestdeps(:,2)),1));
      for no = 1:length(stns)
         stn_string = sprintf('%03d', stns(no));
         lf = [root_ladcp '/DL_GPS/processed/' stn_string '/' stn_string '.mat'];
         if exist(lf)
	        load(lf, 'p');
            bestdeps(bestdeps(:,1)==stns(no),2) = round(p.zbottom);
         end
      end

end

