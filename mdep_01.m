% mdep_01: read water depth for ctd cast from station_summary_cruise_all.nc
%     produced by best_station_depths based on (as specified by
%     opt_cruise) some or all of ldeo ladcp, combined ctd altimeter and
%     depth readings, or depths noted in text file or specified in
%     opt_cruise
%
% Use: mdep_01        and then respond with station number, or for station 16
%      stn = 16; mdep_01;

scriptname = 'castpars'; oopt = 'minit'; get_cropt
mdocshow(mfilename, ['adds water depth from station_depths/station_depths_' mcruise '.mat to all the files for station ' stn_string]);

% resolve root directories for various file types
root_win = mgetdir('M_CTD_WIN');
root_sal = mgetdir('M_BOT_SAL');
root_ctd = mgetdir('M_CTD');
root_sum = mgetdir('sum');

deps_fn = fullfile(root_sum, ['station_summary_' mcruise '_all.nc']);
[d,h] = mloadq(deps_fn,'/');
iis = find(d.statnum==stnlocal);

if length(iis)==0
    warning([deps_fn ' does not contain depth for station ' stn_string '; not adding depth to any .nc files'])
else
    if length(iis)>1 & length(unique(bestdeps(iis,2)))>1
       warning([deps_fn ' contains more than one depth for station ' stn_string '; using first one'])
    end
    iis = iis(1);
    
   clear fn
   n = 1;
   fn{n} = fullfile(root_ctd, ['dcs_' mcruise '_' stn_string]); n = n+1;

   fn{n} = fullfile(root_ctd, ['ctd_' mcruise '_' stn_string '_raw']); n = n+1;
   fn{n} = fullfile(root_ctd, ['ctd_' mcruise '_' stn_string '_raw_cleaned']); n = n+1;
   fn{n} = fullfile(root_ctd, ['ctd_' mcruise '_' stn_string '_24hz']); n = n+1;
   fn{n} = fullfile(root_ctd, ['ctd_' mcruise '_' stn_string '_psal']); n = n+1;
   fn{n} = fullfile(root_ctd, ['ctd_' mcruise '_' stn_string '_2db']); n = n+1;
   fn{n} = fullfile(root_ctd, ['ctd_' mcruise '_' stn_string '_2up']); n = n+1;

   fn{n} = fullfile(root_win, ['win_' mcruise '_' stn_string]); n = n+1;
   fn{n} = fullfile(root_ctd, ['fir_' mcruise '_' stn_string]); n = n+1;


   for kfile = 1:length(fn)
       if exist(m_add_nc(fn{kfile}),'file')
           try
               mputdep(fn{kfile},d.cordep(iis))
           catch me
               warning(me.message)
           end
       end
   end
   
end
