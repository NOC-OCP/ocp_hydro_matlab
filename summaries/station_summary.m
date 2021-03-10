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

mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

%variables, units, how to group samples for counting
scriptname = mfilename; oopt = 'sum_varsams'; get_cropt %set vars, snames, sgrps, sashore, snames_shore
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

d = struct2cell(dir([root_ctd '/ctd_' mcruise '_*_psal.nc'])); d = cell2mat(d(1,:)');

%which stations
stnall = str2num(d(:,length(mcruise)+[6:8]));
scriptname = mfilename; oopt = 'sum_stn_list'; get_cropt
stnset = setdiff(stnall,stnmiss); stnset = stnset(:)'; %these are stations to include with ctd data
stnall = unique([stnset(:); stnadd(:)]); stnall = stnall(:)'; %these are stations to include with or without ctd data

%other info, like event number, station names, comments
scriptname = mfilename; oopt = 'sum_extras'; get_cropt

%%%%% load data and save to mstar file %%%%%
if ~exist('reload','var'); reload = 1; end
if reload
    
    if sum(strcmp('maxw',vars(:,1)))
        %figure out winch variable
        root_win = mgetdir('M_CTD_WIN');
        [a, b] = unix(['ls ' root_win '/' 'win_' mcruise '_???.nc']);
        knc = strfind(b,'.nc');
        if isempty(knc)
            m = 'No winch files found';
            fprintf(MEXEC_A.Mfider,'%s\n',m)
            return
        end
        fnwin = b(1:knc+2); % first winch file name
        h = m_read_header(fnwin);
        cabname = mvarname_find({'cablout' 'cableout' 'winch_cable_out'},h.fldnam);
        if isempty(cabname)
            m1 = ['No match for winch cable out in file '];
            m2 = [fnwin];
            m3 = 'exiting';
            fprintf(MEXEC_A.Mfider,'%s\n',m1,m2,m3)
            return
        end
    end
    
    %initialise
    a = zeros(max(stnall),1); % bak on jc159 30 March 2018 has to be max (stnset) not size(stnset) so we can address by station number
    for no = 1:size(vars,1)
        if isnumeric(vars{no,3})
            eval(sprintf('%s = a+%f;', vars{no,1}, vars{no,3}));
        end
    end
    statnum(stnall) = stnall;
    
    %get information from files
    disp('loading')
    fnsam = [root_ctd '/sam_' mcruise '_all'];
    clear dsam
    if exist(m_add_nc(fnsam),'file') == 2
        dsam0 = mloadq(fnsam,'/');
    end
    for k = stnset
        stnstr = sprintf('%03d',k);
        
        %lat, lon, depths and altimeter
        fnsal = [root_ctd '/ctd_' mcruise '_' stnstr '_psal'];
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
        
        %winch
        fnwin = [root_win '/win_' mcruise '_' stnstr];
        if exist(m_add_nc(fnwin),'file') == 2
            [dwin, h3] = mloadq(fnwin,cabname,'/');
            maxw(k) = max(dwin.(cabname));
        end
        
        %cast start, bottom, end times
        fndcs = [root_ctd '/dcs_' mcruise '_' stnstr ];
        [ddcs, h4] = mloadq(fndcs,'/');
        time_start(k) = datenum(h4.data_time_origin) + ddcs.time_start/86400;
        time_bottom(k) = datenum(h4.data_time_origin) + ddcs.time_bot/86400;
        time_end(k) = datenum(h4.data_time_origin) + ddcs.time_end/86400;
        
        %samples
        if exist('dsam0','var')
            iis = find(dsam0.statnum==k);
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
                    if sum(isnan(log_all))>0; warning(['not all sample types in sgrps found for ' snames{sgno}]); end
                    log_all = max(log_all);
                    if ~isnan(log_all)
                        eval([snames{sgno} '(k) = log_all;'])
                    end
                end
            end
        end
        
        disp(k)
    end
    
    scriptname = mfilename; oopt = 'sum_edit'; get_cropt; %edit depths, times, etc. not captured from CTD data
    
    %when not close enough to bottom to detect on altimeter
    load([mgetdir('ctd_dep') '/station_depths_' mcruise]);
    [~,ia,ib] = intersect(statnum,bestdeps(:,1));
    cordep(ia) = bestdeps(ib,2);
    minalt((cordep-maxd)>99) = -9;
    resid = maxd+minalt-cordep;
    resid(cordep==-999 | maxd==-999 | minalt==-9) = -999;
    
    
    %%%%% write to mstar .nc file %%%%%
    
    clear hnew ds
    hnew.dataname = ['station_summary_' mcruise '_all'];
    hnew.fldnam ={}; hnew.fldunt = {};
    otfile2 = [root_sum '/' hnew.dataname];
    for k = 1:size(vars,1)
        if ~isempty(vars{k,2})
            eval(['ds.(vars{k,1}) = ' vars{k,1} ';']);
            hnew.fldnam = [hnew.fldnam vars{k,1}];
            hnew.fldunt = [hnew.fldunt vars{k,2}];
        end
    end
    ds.time_start = (ds.time_start - datenum(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN))*86400;
    ds.time_bottom = (ds.time_bottom - datenum(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN))*86400;
    ds.time_end = (ds.time_end - datenum(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN))*86400;
    mfsave(otfile2, ds, hnew);
    
else
    
    disp('not regenerating station_summary file, just loading and printing table; clear reload or set to 0 to change this');
    ds = mload([root_sum '/station_summary_' mcruise '_all'],'/');
    fn = fieldnames(ds);
    for k = 1:length(fn)
        eval([fn{no} ' = ds.(fn{no});']);
    end
    
end


%%%%% write to ascii file %%%%%

stnlistname = [root_sum '/station_summary_' mcruise '_all.txt'];
fid = fopen(stnlistname,'w');

% list headings
for cno = 1:length(vars)
    if ~isempty(vars{cno,5}) && ~isnumeric(vars{cno,4})
        fprintf(fid, '%s ', vars{cno,4});
    end
end
fprintf(fid, '%s\n', ' ');

for k = stnall
    
    extraline = 0;
    for cno = 1:length(vars)
        if isnumeric(vars{cno,4}) && vars{cno,4}==-1 %line before
            scriptname = mfilename; oopt = 'sum_special_print'; get_cropt
            fprintf(fid, '%s ', svar);
            extraline = 1;
        end
    end
    if extraline; fprintf(fid, '%s\n', ' '); end
    
    for cno = 1:length(vars)
        if ~isempty(vars{cno,5})
            if isempty(strfind(vars{cno,5},'%'))
                scriptname = mfilename; oopt = 'sum_special_print'; get_cropt
                fprintf(fid, '%s ', svar);
            else
                eval(['dk = ' vars{cno,1} '(k);'])
                if iscell(dk)
                    fprintf(fid, [vars{cno,5} ' '], dk{:});
                else
                    fprintf(fid, [vars{cno,5} ' '], dk);
                end
            end
        end
    end
    fprintf(fid, '%s\n', ' ');
    
    extraline = 0;
    for cno = 1:length(vars)
        if isnumeric(vars{cno,4}) && vars{cno,4}==1 %line after
            scriptname = mfilename; oopt = 'sum_special_print'; get_cropt
            fprintf(fid, '%s ', svar);
            extraline = 1;
        end
    end
    if extraline; fprintf(fid, '%s\n', ' '); end

end

fclose(fid);

