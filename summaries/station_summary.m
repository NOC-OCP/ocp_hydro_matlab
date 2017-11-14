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

scriptname = 'station_summary';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
oopt = '';

oopt = 'optsams'; get_cropt %set snames, sgrps and sashore, groupings for counting samples of nuts, cfcs, etc.
oopt = 'varnames'; get_cropt %set names of variables to output

root_win = mgetdir('M_CTD_WIN');
root_ctd = mgetdir('M_CTD');
root_sum = mgetdir('M_SUM');


% bak at noc 18 aug 2010
% pick up wireout name from file
[a b] = unix(['ls ' root_win '/' 'win_' cruise '_???.nc']);
knc = strfind(b,'.nc');
if isempty(knc)
    m = 'No winch files found';
    fprintf(MEXEC_A.Mfider,'%s\n',m)
    return
end
fnwin = b(1:knc+2); % first winch file name
% now scan files until a  matching var is found
cablook1 = 'cab'; % should match 'cablout' (techsas) or 'winch_cable_out' (scs) or 'cableout'
cablook2 = 'out'; % should match 'cablout' (techsas) or 'winch_cable_out' (scs) or 'cableout'
h_in = m_read_header(fnwin);
kmat = [];
for kloopscr = 1:length(h_in.fldnam);
    kmat1 = findstr(h_in.fldnam{kloopscr},cablook1);
    kmat2 = findstr(h_in.fldnam{kloopscr},cablook2);
    if ~isempty(kmat1) & ~isempty(kmat2) %this variable matches both searches
        kmat = [kmat kloopscr];
    end
end
if isempty(kmat)
    m1 = ['No match for ''' cablook1 ' & ' cablook2 ''' as wireout variable in file '];
    m2 = [fnwin];
    m3 = 'exiting';
    fprintf(MEXEC_A.Mfider,'%s\n',m1,m2,m3)
    cabname = ' ';
    return
elseif length(kmat) > 1
    m1 = ['More than one variable found whose name matches ''' cablook1 ' & ' cablook2 ''' in file'];
    m2 = [fnwin];
    m3 = ' '; for kloopscr = 1:length(kmat); m3 = [m3 ' ' h_in.fldnam{kmat(kloopscr)}]; end
    m4 = ['Specify variable name here : '];
    fprintf(MEXEC_A.Mfider,'%s\n',m1,m2,m3)
    cabname = m_getinput(m4,'s');
else % just one match
    cabname = h_in.fldnam{kmat};
end


%ylf jc145 find list of processed stations
d = struct2cell(dir([root_ctd '/ctd_' cruise '_*2db.nc'])); d = cell2mat(d(1,:)');
stnall = str2num(d(:,length(cruise)+[6:8]));
oopt = 'stnmiss'; get_cropt
stnset = setdiff(stnall,stnmiss); stnset = stnset(:)';


%get information from files

a = NaN+ones(length(stnset),1);
statnum = a; lat = a; lon = a;
maxp = a; maxd = a;
maxw = a;
minalt = a;
dns = a; dnb = a; dne = a;
cordep = a;
ndpths = zeros(length(stnset),1);
nopt = zeros(length(stnset),size(sgrps,1));
if sum(sashore); nopt_shore = nopt; end

for k = stnset
    stnstr = sprintf('%03d',k);
    statnum(k) = k;

    fn2db = [root_ctd '/ctd_' cruise '_' stnstr '_2db'];
    fnsal = [root_ctd '/ctd_' cruise '_' stnstr '_psal'];
    fndcs = [root_ctd '/dcs_' cruise '_' stnstr ];
    fnwin = [root_win '/' 'win_' cruise '_' stnstr];
    fnsam = [root_ctd '/sam_' cruise '_' stnstr];

    [d2db h1] = mload(fn2db,'/');
    lat(k) = h1.latitude;
    lon(k) = h1.longitude;

    [dpsal h2] = mload(fnsal,'/');
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

        if isfield(dsam,'wireout'); ndpths(k) = length(unique(dsam.wireout(~isnan(dsam.wireout)))); end
        if isfield(dsam,'botpsal'); nsal(k) = sum(~isnan(dsam.botpsal)); end

	%loop through groups of non-standard samples
	for sgno = 1:size(sgrps,1)
	   ii = find(isfield(dsam, sgrps(sgno,2:end)));
	   log_all = [];
	   if sashore(sgno); log_all1 = []; end
	   for fno = 1:length(ii)
	      log_all = [log_all ~isnan(getfield(dsam, sgrps(sgno,ii(fno)+1)))];
	      if sashore(sgno); log_all1 = [log_all1 getfield(dsam, [sgrps(sgno,ii(fno)+1) '_flag'])==1]; end
	   end
	   nopt(k,sgno) = sum(max(log_all,[],2)); %or just sum(sum) to count total samples?
	   if sashore(sgno); nopt_shore(k,sgno) = sum(max(log_all1,[],2)); end
	end
    end


    oopt = 'cordep'; get_cropt;

    [ddcs h4] = mload(fndcs,'/');
    dns(k) = datenum(h4.data_time_origin) + ddcs.time_start/86400;
    dnb(k) = datenum(h4.data_time_origin) + ddcs.time_bot/86400;
    dne(k) = datenum(h4.data_time_origin) + ddcs.time_end/86400;

end
resid = maxd+minalt-cordep;
ii = find(cordep-maxd)>99; minalt(ii) = -9; resid(ii) = -999; %can't expect altimeter to detect bottom

oopt = 'comments'; get_cropt


%write to ascii file

stnlistname = [root_sum '/' cruise '_station_list'];
fid = fopen(stnlistname,'w');

% list headings
fprintf(fid,'%3s %8s %4s ', 'stn', 'yy/mo/dd', 'hhmm');
fprintf(fid,'%10s %11s ', 'dg min lat', 'dg min lon');
fprintf(fid,'%s ', 'cdep  maxd  alt   res  wire  pres  nd');
fprintf(fid, '%s ', varnames{:});
fprintf(fid,'%s\n','  Comments')

for k = stnset

    ss = datestr(dns(k),'yy/mm/dd HHMM');
    sb = datestr(dnb(k),'yy/mm/dd HHMM');
    se = datestr(dne(k),'yy/mm/dd HHMM');
    fprintf(fid,'\n%3s %s \n', '', ss);
    fprintf(fid,'%03d %s ', k, sb);

    l1 = 'N'; if lat(k) < 0; l1 = 'S'; end
    l2 = 'E'; if lon(k) < 0; l2 = 'W'; end
    latk = abs(lat(k));
    latd = floor(latk);
    latm = 60*(latk-latd); if latm >= 59.995; latm = 0; latd = latd+1; end% prevent write of 60.00 minutes
    lonk = abs(lon(k));
    lond = floor(lonk);
    lonm = 60*(lonk-lond); if lonm >= 59.995; lonm = 0; lond = lond+1; end% prevent write of 60.00 minutes
    fprintf(fid,'%2d %05.2f %s %3d %05.2f %s ', latd, latm, l1, lond, lonm, l2);

    oopt = 'altdep'; get_cropt
    for no = 7:length(varnames)
       eval(['data = ' varnames{no} '(k);']);
       fprintf(fid, '%4.0f  ', data);
    end

    fprintf(fid,'  %s',comments{k});
    fprintf(fid,'\n');

%    fprintf(fid,'%3s %8s %4s\n','',se1,se2);

end

fclose(fid);


%write to mstar .nc file

prefix1 = ['station_summary_' cruise '_'];
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
keyboard
msave

