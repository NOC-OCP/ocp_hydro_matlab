function station_summary(varargin)
% makes summary file 
%
% statnum
% time start, bottom, end
% cordep
% maxp
% maxwire
% ht off (min(altim))
% date yymmdd
% dayofyear
% pos start bottom end
% ht off (watdep-dpth(maxp))
% num diff bottle depths
% num niskin bottles sampled for each param set
% salt
% o2
% nuts
% cfc
% co2
% comments
%
% revised by BAK aug 2010 to try to make it generic to all cruises, so
% non-measured parameters are skipped harmlessly. Also, wireout var name is
% picked up from file.
%
% ylf jc145 revised to set non-standard sample names and how to count them in opt_cruise
%
% ylf dy146 revised for optional input (list) stations_to_reload 
% and to run best_station_depths (formerly populate_station_depths)

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
if nargin>0
    stations_to_reload = varargin{1};
end
timestring = ['seconds since ' datestr(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN,'yyyy-mm-dd HH:MM:SS')];

%variables, units, how to group samples for counting
%names, units, fill values, table headers, formats for printing to table
%rows with empty units are for table only, rows with empty
%header/formats are for .nc file only, rows with header
%column -1 are printed before the rest, with header column
%+1 after
%if last column is not a format string the row must have
%code to print it under case sum_special_print
vars = {
    'statnum'      'number'    -999  'stn '            '%03d '
    'time_start'   'seconds'   -999  -1                ''
    'time_bottom'  'seconds'   -999  'yy/mm/dd     '   'special'
    'time_end'     'seconds'   -999  1                 ''
    'lat'          'degN'      -999  'lat deg min '    'special'
    'lon'          'degE'      -999  'lon deg min '    'special'
    'cordep'       'metres'    -999  'cordep'          '  %4.0f'
    'maxd'         'metres'    -999  'maxd'            '%4.0f'
    'minalt'       'metres'    -9    'minalt'          '   %2.0f'
    'resid'        'metres'    -9    'resid'           ' %4.0f '
    'maxw'         'metres'    -999  'maxw'            '%4.0f'
    'maxp'         'metres'    -999  'maxp'            '%4.0f'
    'ndepths'      'number'     0    'ndpths'          '    %2d'
    };
snames = {'nsal'};
sgrps = {{'botpsal'}}; % salt
opt1 = 'outputs'; opt2 = 'summary'; get_cropt %set vars, snames, sgrps
for no = 1:length(snames)
    if contains(snames{no},'_shore')
        vars = [vars; {snames{no} 'number' 0 snames{no}(1:end-6) '  %2d'}];
    else
        vars = [vars; {snames{no} 'number' 0 snames{no} '  %2d'}];
    end
end
%find list of processed stations
root_ctd = mgetdir('ctd');
root_sum = mgetdir('sum');
dataname = ['station_summary_' mcruise '_all'];
otfile2 = fullfile(root_sum, dataname);

d = dir(fullfile(root_ctd, ['ctd_' mcruise '_*_psal.nc'])); d = {d.name}; d = cell2mat(d(:));

%which stations
stnall = str2num(d(:,length(mcruise)+[6:8]));
stnmiss = [];
stnadd = [];
opt1 = mfilename; opt2 = 'sum_stn_list'; get_cropt
stnset = setdiff(stnall,stnmiss); stnset = stnset(:)'; %these are stations to include with ctd data
stnall = unique([stnset(:); stnadd(:)]); stnall = stnall(:)'; %these are stations to include with or without ctd data

if exist('stations_to_reload','var')
    stnall = intersect(stnall, stations_to_reload);
end

%%%%% load data and save to mstar file %%%%%
if ~isempty(stnall)

    %initialise
    a = zeros(size(stnall));
    for no = 1:size(vars,1)
        if isnumeric(vars{no,3})
            eval(sprintf('%s = a+%f;', vars{no,1}, vars{no,3}));
        end
    end
    statnum = stnall;

    %get information from files
    disp('loading')
    fnsam = fullfile(root_ctd, ['sam_' mcruise '_all']);
    clear dsam
    if exist(m_add_nc(fnsam),'file') == 2
        dsam0 = mloadq(fnsam,'/');
    end
    for k = 1:length(statnum)
        stnstr = sprintf('%03d',statnum(k));

        %lat, lon, ctd depths and altimeter
        fnsal = fullfile(root_ctd, ['ctd_' mcruise '_' stnstr '_psal']);
        if exist(m_add_nc(fnsal),'file')
            [dpsal, hpsal] = mloadq(fnsal,'/');
            lat(k) = hpsal.latitude;
            lon(k) = hpsal.longitude;
            maxp(k) = max(dpsal.press);
            maxd(k) = sw_dpth(maxp(k),lat(k));
            if isfield(dpsal, 'altimeter')
                minalt(k) = min(dpsal.altimeter(find(dpsal.press>(maxp(k)-30))));
            else
                minalt(k) = NaN;
            end
        end

        %winch
        root_win = mgetdir('M_CTD_WIN');
        fnwin = fullfile(root_win, ['win_' mcruise '_' stnstr]);
        if exist(m_add_nc(fnwin),'file') == 2
            h3 = m_read_header(fnwin);
            cabname = munderway_varname('cabvar',h3.fldnam,1,'s');
            [dwin, ~] = mloadq(fnwin,cabname,'/');
            maxw(k) = max(dwin.(cabname));
        end

        %cast start, bottom, end times
        fndcs = fullfile(root_ctd, ['dcs_' mcruise '_' stnstr]);
        if exist(m_add_nc(fndcs),'file')
            [ddcs, h4] = mloadq(fndcs,'/');
            time_start(k) = m_commontime(ddcs.time_start,'time_start',h4,timestring);
            time_bottom(k) = m_commontime(ddcs.time_bot,'time_bot',h4,timestring);
            time_end(k) = m_commontime(ddcs.time_end,'time_end',h4,timestring);
        end

        %samples
        if exist('dsam0','var')
            iis = find(dsam0.statnum==statnum(k));
            dsam.upress = dsam0.upress(iis);
            if isfield(dsam0,'wireout')
                dsam.wireout = dsam0.wireout(iis);
                ndepths(k) = mctd_count_depths(dsam,1);
            end
            for sgno = 1:length(snames)
                sgrp = sgrps{sgno};
                if ~isempty(strfind(snames{sgno},'_shore'))
                    fv = 1;
                else
                    fv = [2 3 6];
                end
                log_all = [];
                for fno = 1:length(sgrp)
                    if isfield(dsam0, [sgrp{fno} '_flag'])
                        a = double(ismember(dsam0.([sgrp{fno} '_flag'])(iis),fv));
                    elseif isfield(dsam0, sgrp{fno})
                        a = double(~isnan(dsam0.(sgrp{fno})(iis)));
                    else
                        a = NaN;
                    end
                    log_all = [log_all sum(a(:))];
                    if sum(isnan(log_all))>0
                        warning(['not all sample types in sgrps found for ' snames{sgno}]);
                    end
                    log_all = max(log_all);
                    if ~isnan(log_all)
                        eval([snames{sgno} '(k) = log_all;'])
                    end
                end
            end
        end

        disp(stnall(k))
    end

    opt1 = mfilename; opt2 = 'sum_edit'; get_cropt; %edit depths, times, etc. not captured from CTD data
    bestdeps = best_station_depths(stnall);
    [~,ia,ib] = intersect(statnum,bestdeps(:,1));
    cordep(ia) = bestdeps(ib,2);
    minalt((cordep-maxd)>99) = -9;
    resid = maxd+minalt-cordep;
    resid(cordep==-999 | maxd==-999 | minalt==-9) = -999;


    %%%%% write to mstar .nc file %%%%%

    clear hnew ds
    hnew.dataname = dataname;
    hnew.fldnam ={}; hnew.fldunt = {};
    for k = 1:size(vars,1)
        if ~isempty(vars{k,2})
            ds.(vars{k,1}) = eval(vars{k,1});
            hnew.fldnam = [hnew.fldnam vars{k,1}];
            hnew.fldunt = [hnew.fldunt vars{k,2}];
        end
    end
    opt1 = 'mstar'; get_cropt
    if docf
        m = strncmp('time_',hnew.fldnam,5);
        hnew.fldunt(m) = timestring;
        hnew.data_time_origin = [];
    else
        hnew.data_time_origin = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN;
    end
    mfsave(otfile2, ds, hnew, '-merge', 'statnum');

else

    disp('not regenerating station_summary file, just loading and printing table');
    ds = mloadq(fullfile(root_sum, ['station_summary_' mcruise '_all']),'/');
    fn = fieldnames(ds);
    for k = 1:length(fn)
        eval([fn{no} ' = ds.(fn{no});']);
    end

end

%other info, like event number, station names, comments (strings can't
%be saved as mstar variables)
opt1 = mfilename; opt2 = 'sum_extras'; get_cropt


%%%%% write to ascii file %%%%%

%reload file in case we only added some stations in workspace
[ds, ~] = mloadq(otfile2,'/');
ds.time_start = m_commontime(ds.time_start,timestring,'datenum');
ds.time_bottom = m_commontime(ds.time_bottom,timestring,'datenum');
ds.time_end = m_commontime(ds.time_end,timestring,'datenum');
stnall = unique(ds.statnum);

stnlistname = fullfile(root_sum, ['station_summary_' mcruise '_all.csv']);
fid = fopen(stnlistname,'w');

% list headings
for cno = 1:length(vars)
    if ~isempty(vars{cno,5}) && ~isnumeric(vars{cno,4})
        fprintf(fid, '%s, ', vars{cno,4});
    end
end
fprintf(fid, '%s\n', ' ');

for k = 1:length(stnall)

    extraline = 0;
    for cno = 1:length(vars)
        if isnumeric(vars{cno,4}) && vars{cno,4}==-1 %line before
            svar = special_print(ds,vars,cno,k);
            opt1 = mfilename; opt2 = 'sum_special_print'; get_cropt
            fprintf(fid, '%s, ', svar);
            extraline = 1;
        end
    end
    if extraline; fprintf(fid, '%s\n', ' '); end

    for cno = 1:length(vars)
        if ~isempty(vars{cno,5})
            if isempty(strfind(vars{cno,5},'%'))
                svar = special_print(ds,vars,cno,k);
                opt1 = mfilename; opt2 = 'sum_special_print'; get_cropt
                fprintf(fid, '%s, ', svar);
            else
                dk = ds.(vars{cno,1})(k);
                if iscell(dk)
                    fprintf(fid, [vars{cno,5} ', '], dk{:});
                else
                    fprintf(fid, [vars{cno,5} ', '], dk);
                end
            end
        end
    end
    fprintf(fid, '%s\n', ' ');

    extraline = 0;
    for cno = 1:length(vars)
        if isnumeric(vars{cno,4}) && vars{cno,4}==1 %line after
            svar = special_print(ds,vars,cno,k);
            opt1 = mfilename; opt2 = 'sum_special_print'; get_cropt
            fprintf(fid, '%s, ', svar);
            extraline = 1;
        end
    end
    if extraline; fprintf(fid, '%s\n', ' '); end

end

fclose(fid);

function svar = special_print(ds,vars,cno,k)
switch vars{cno,1}
    case 'time_start'
        ii = find(strcmp('time_bottom',vars(:,1))); ii = 1:ii-1;
        co = 0;
        for pcno = 1:length(ii)
            co = co + length(vars{ii(pcno),4});
        end
        svar = [repmat(' ',1,co-1) ',' datestr(ds.time_start(k), ' yy/mm/dd HHMM ')];
    case 'time_bottom'
        svar = datestr(ds.time_bottom(k), 'yy/mm/dd HHMM');
    case 'time_end'
        ii = find(strcmp('time_bottom',vars(:,1))); ii = 1:ii-1;
        co = 0;
        for pcno = 1:length(ii)
            co = co + length(vars{ii(pcno),4});
        end
        svar = [repmat(' ',1,co-1) ',' datestr(ds.time_end(k), ' yy/mm/dd HHMM')];
    case 'lat'
        latd = floor(abs(ds.lat(k))); latm = 60*(abs(ds.lat(k))-latd); if latm>=59.995; latm = 0; latd = latd+1; end
        if ds.lat(k)>=0; lath = 'N'; else; lath = 'S'; end
        svar = sprintf('%02d %06.3f %s ', latd, latm, lath);
    case 'lon'
        lond = floor(abs(ds.lon(k))); lonm = 60*(abs(ds.lon(k))-lond); if lonm>=59.995; lonm = 0; lond = lond+1; end
        if ds.lon(k)>=0; lonh = 'E'; else; lonh = 'W'; end
        svar = sprintf('%03d %06.3f %s', lond, lonm, lonh);
end
