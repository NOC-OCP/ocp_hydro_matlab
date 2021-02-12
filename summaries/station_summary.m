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

%find list of processed stations
root_ctd = mgetdir('M_CTD');
d = struct2cell(dir([root_ctd '/ctd_' mcruise '_???_psal.nc'])); d = cell2mat(d(1,:)');
stnall = str2num(d(:,length(mcruise)+[6:8]));
scriptname = mfilename; oopt = 'sum_stn_list'; get_cropt
stnset = setdiff(stnall,stnmiss); stnset = stnset(:)'; %these are stations to include with ctd data
stnall = unique([stnset(:); stnadd(:)]); stnall = stnall(:)'; %these are stations to include with or without ctd data

%variables and formats
vars = {'statnum' 'number' -999 '%03d'
    'time_start' 'seconds' -999 '%f'
    'time_bottom' 'seconds' -999
    'time_end' 'seconds' -999
    'lat' 'deg min' -999
    'lon' 'deg min' -999
    'cordep' 'metres' -999
    'maxd' 'metres' -999
    'minalt' 'metres' -9
    'resid' 'metres' -9
    'maxw' 'metres' -999
    'maxp' 'metres' -999
    'ndpths' 'number' -9};
[c,ia,ib] = intersect(varnames,vars(:,1)); %***
scriptname = mfilename; oopt = 'sum_varsams'; get_cropt %set snames, sgrps and sashore, groupings for counting samples of nuts, cfcs, etc.
vars = [vars(ib,:); [snames repmat({'number'},length(snames),1) repmat(-9,length(snames),1) repmat('%d',length(snames),1)]];
    fprintf(fid,' %2d %05.2f %s %3d %05.2f %s', latd, latm, l1, lond, lonm, l2);

cordep(cordep == -999) = -99999;
resid(resid == -999) = -99999;
maxp(maxp == -999) = -99999;
maxd(maxd == -999) = -99999;
minalt(minalt == -9) = -99999;

%%%%% load data %%%%%

%winch variable
root_win = mgetdir('M_CTD_WIN');
[a b] = unix(['ls ' root_win '/' 'win_' mcruise '_???.nc']);
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
    m1 = ['No match for ''' cablook1 ' & ' cablook2 ''' as wireout variable in file '];
    m2 = [fnwin];
    m3 = 'exiting';
    fprintf(MEXEC_A.Mfider,'%s\n',m1,m2,m3)
    cabname = ' ';
    return
end

%get information from files
a = NaN+ones(max(stnall),1); % bak on jc159 30 March 2018 has to be max (stnset) not size(stnset) so we can address by station number
a9 = -9 + zeros(size(a)); % bak on jc159 initialise with  -9.
a999 = -999 + zeros(size(a)); % bak on jc159 initialise with  -9.
vars = {'statnum' 'lat' 'lon' 'dns' 'dnb' 'dne'};
vars9 = {'minalt'};
vars999 = {'maxp' 'maxd' 'maxw' 'resid' 'cordep'};
statnum = a; lat = a; lon = a;
maxp = a999; maxd = a999;
maxw = a999;
minalt = a9;
resid = a999;
dns = a; dnb = a; dne = a;
cordep = a999;
ndpths = zeros(max(stnset),1);
nopt = zeros(max(stnset),size(sgrps,1));
if sum(sashore); nopt_shore = nopt; end

statnum(stnall) = stnall;

for k = stnset
    stnstr = sprintf('%03d',k);

    fnsal = [root_ctd '/ctd_' mcruise '_' stnstr '_psal'];
    fndcs = [root_ctd '/dcs_' mcruise '_' stnstr ];
    fnwin = [root_win '/' 'win_' mcruise '_' stnstr];
    fnsam = [root_ctd '/sam_' mcruise '_' stnstr];
    
    [dpsal hpsal] = mload(fnsal,'/');
    lat(k) = hpsal.latitude;
    lon(k) = hpsal.longitude;
    maxp(k) = max(dpsal.press);
    maxd(k) = sw_dpth(maxp(k),lat(k));
    if isfield(dpsal, 'altimeter')
       minalt(k) = min(dpsal.altimeter(find(dpsal.press>(maxp(k)-30))));
    else
       minalt(k) = NaN;
    end

    if exist(m_add_nc(fnwin)) == 2
        [dwin h3] = mload(fnwin,cabname,'/');
        maxw(k) = max(getfield(dwin, cabname));
    end

    % bak on jc069. On towyo stations there may be no sam file
    if exist(m_add_nc(fnsam),'file') == 2
        [dsam h4] = mload(fnsam,'/');
        
        if isfield(dsam,'wireout'); ndpths(k) = mctd_count_depths(dsam,1); end
        if isfield(dsam,'botpsal'); nsal(k) = sum(ismember(dsam.botpsalflag, [2 3 6])); nsal = nsal(:); end % bak jc191  count flag of 2, 3 or 6; 6 == mean of replicate; 5 == not reported.
        %loop through groups of non-standard samples
        for sgno = 1:size(sgrps,1)
            sgrp = sgrps{sgno};
            ii = find(isfield(dsam, sgrp)); %which of the sample var names in sgrps are actually in sam file
            if length(ii)<size(sgrp,2); warning('not all sample types in sgrps found'); end
            log_all = [];
            if sashore(sgno); log_all1 = []; end
            for fno = 1:length(ii)
                s = [sgrp{ii(fno)} '_flag']; if ~isfield(dsam, s); s = [sgrp{ii(fno)} 'flag']; end
                if isfield(dsam, s)
                    a = ismember(getfield(dsam, s), [2 3 6]); log_all = [log_all a(:)]; % bak jc191  count flag of 2, 3 or 6; 6 == mean of replicate
                    if sashore(sgno); 
                        a = getfield(dsam, s)==1; 
                        log_all1 = [log_all1 a(:)]; 
                    end
                else
                    a = ~isnan(getfield(dsam, sgrp{ii(fno)})); log_all = [log_all a(:)]; 
                end
            end
            nopt(k,sgno) = sum(max(log_all,[],2)); %or just sum(sum) to count total samples?
            if sashore(sgno); nopt_shore(k,sgno) = sum(max(log_all1,[],2)); end
        end
    end


    cordep(k) = hpsal.water_depth_metres;

    [ddcs h4] = mload(fndcs,'/');
    dns(k) = datenum(h4.data_time_origin) + ddcs.time_start/86400;
    dnb(k) = datenum(h4.data_time_origin) + ddcs.time_bot/86400;
    dne(k) = datenum(h4.data_time_origin) + ddcs.time_end/86400;

end

for no = 1:size(snames,1)
   eval([snames{no} ' = nopt(:,no);'])
end
if sum(sashore); for no = 1:size(sashore,1)
   eval([snames_shore{no} ' = nopt_shore(:,no);'])
end; end

scriptname = mfilename; oopt = 'sum_edit'; get_cropt; %edit depths, times, etc. not captured from CTD data

resid = maxd+minalt-cordep;
ii = find((cordep-maxd) > 99); minalt(ii) = -9; resid(ii) = -999; %can't expect altimeter to detect bottom
ii = find(cordep == -999); resid(ii) = -999; % no resid if cordep undefined
ii = find(maxd == -999); resid(ii) = -999; % no resid if maxd undefined
ii = find(minalt == -9); resid(ii) = -999; % no resid if minalt undefined

comments = cell(max(stnall),1); % bak fix jc159 30 March 2018; If stnall = [1 2 3 5] then size(stnall) is 4 but we need comments ot be of size 5 so we can prepare comments by station number rather than by index in stnall
scriptname = mfilename; oopt = 'sum_comments'; get_cropt

%write to ascii file
root_sum = mgetdir('M_SUM');
stnlistname = [root_sum '/station_summary_' mcruise '_all.txt'];
fid = fopen(stnlistname,'w');

ewidth = 4; nwidth = 10; % each width must allow for one space to follow
pad = '                                                           ';
eventhead = [pad 'Ev '];  % event number and header are right justified in width ewidth
eventhead = eventhead(end-ewidth+1:end);
namehead = ['Waypoint' pad]; % waypoint name and header are left justified in width nwidth, with a space after, but truncated to nwidth
namehead = [namehead(1:nwidth-1) ' '];
namehead = namehead(1:nwidth);

% list headings
fprintf(fid,'%s%s%3s %8s %4s',eventhead,namehead, 'stn', 'yy/mo/dd', 'hhmm');
fprintf(fid,' %10s %11s', 'dg min lat', 'dg min lon');
fprintf(fid,' %4s', varnames{7:end});
fprintf(fid,'  %s\n','Comments');

for k = stnall
    
    [eventnum,statname] = parse_ctd_event_name(k); % jc211, BAS western core box events % need to set default width of event and name fields to zero. Set to desired length in cropt
    pade = pad(1:ewidth); padn = pad(1:nwidth);
    stringe = [pad sprintf('%03d ',eventnum)]; stringe = stringe(end-ewidth+1:end);
    stringn = [statname pad]; 
    stringn = [stringn(1:nwidth-1) ' '];
    stringn = stringn(1:nwidth);

    
    ss = datestr(dns(k),'yy/mm/dd HHMM');
    sb = datestr(dnb(k),'yy/mm/dd HHMM');
    se = datestr(dne(k),'yy/mm/dd HHMM');
    fprintf(fid,'\n%s%s%3s %s\n',pade,padn,'', ss); % pad the timestart line
    fprintf(fid,'%s%s%03d %s',stringe,stringn,k,sb);

    l1 = 'N'; if lat(k) < 0; l1 = 'S'; end
    l2 = 'E'; if lon(k) < 0; l2 = 'W'; end
    latk = abs(lat(k));
    latd = floor(latk);
    latm = 60*(latk-latd); if latm >= 59.995; latm = 0; latd = latd+1; end% prevent write of 60.00 minutes
    lonk = abs(lon(k));
    lond = floor(lonk);
    lonm = 60*(lonk-lond); if lonm >= 59.995; lonm = 0; lond = lond+1; end% prevent write of 60.00 minutes
    fprintf(fid,' %2d %05.2f %s %3d %05.2f %s', latd, latm, l1, lond, lonm, l2);

    for no = 7:length(varnames)
       % jc159 bak30 march 2018; width of field is width of var name,
       % minimum 4.
       vn = varnames{no};
       eval(['data = ' vn '(k);']);
       fwid = max(4,length(vn));
       form = sprintf('%s%d%s',' %',fwid,'.0f');
       fprintf(fid, form, data);
    end

    fprintf(fid,'  %s',comments{k});
    fprintf(fid,'\n');

    fprintf(fid,'%s%s%3s %s \n',pade,padn,'',se); % pad the timeend line

end

fclose(fid);



%write to mstar .nc file

prefix1 = ['station_summary_' mcruise '_'];
otfile2 = [root_sum '/' prefix1 'all'];
dataname = [prefix1 'all'];

% sorting out units for msave
varnames_units = {};
for k = 1:length(varnames)
    varnames_units = [varnames_units; varnames(k)];
    varnames_units = [varnames_units; {'/'}];
    varnames_units = [varnames_units; varunits(k)];
end

timestring = ['[' sprintf('%d %d %d %d %d %d',MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN) ']'];

time_start = 86400*(dns-datenum(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN));
time_bottom = 86400*(dnb-datenum(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN));
time_end = 86400*(dne-datenum(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN));

MEXEC_A.MARGS_IN_1 = {
    otfile2
    };
MEXEC_A.MARGS_IN_2 = varnames(:);
MEXEC_A.MARGS_IN_3 = {
    ' '
    ' '
    '1'
    dataname
    '/'
    '2'
    MEXEC_G.PLATFORM_TYPE
    MEXEC_G.PLATFORM_IDENTIFIER
    MEXEC_G.PLATFORM_NUMBER
    '/'
    '4'
    timestring
    '/'
    '8'
    };
MEXEC_A.MARGS_IN_4 = varnames_units(:);
MEXEC_A.MARGS_IN_5 = {
    '-1'
    '-1'
    };
MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN_1; MEXEC_A.MARGS_IN_2; MEXEC_A.MARGS_IN_3; MEXEC_A.MARGS_IN_4; MEXEC_A.MARGS_IN_5];
msave

