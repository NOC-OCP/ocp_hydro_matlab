% generic version on jr281 April 2013, shoul dbe adapted for future cruises
% with cruise case switches
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

% revised by BAK aug 2010 to try to make it generic to all cruises, so
% non-measured parameters are skipped harmlessly. Also, wireout var name is
% picked up from file.

% bak on jc069, use switch/case below to avoid columns for non-measured
% parameters
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

mcsetd('M_CTD_WIN'); rootwin = MEXEC_G.MEXEC_CWD;
mcd('M_CTD');

% root = '/noc/ooc/wp13/jc032_fromship/ctd/';
% root = '/local/users/pstar/cruise/data/ctd/';
mcsetd('M_CTD'); root = MEXEC_G.MEXEC_CWD; % bak 18 aug 2010

% wireout_var = 'cablout'; % di 346
% work out the wireout variable name from a station file
% bak at noc 18 aug 2010
% pick up wireout name from file
mcsetd('M_CTD_WIN'); root_win = MEXEC_G.MEXEC_CWD;
% [a b] = unix('ls /noc/ooc/drake/di346_temp/data/ctd/WINCH/win_di346_???.nc')
[a b] = unix(['ls ' root_win '/' 'win_' MEXEC_G.MSCRIPT_CRUISE_STRING '_???.nc']);
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

% stnset = [1:47 49:118];
% stnset = [81:118];
% stnset = [1:64 200 65:100 202 101:135];
% stnset = 1:29;
stnall = 1:899; %jc069 we can now try all stations, since missing stations will be skipped; avoid stations numbered over 900, which are often used for tests and gash
% stnall = 122:122; % jr281 
% stnmiss = [10 17 28 32]; % jc069 vmp only
%stnmiss = [235:999]; % bak jc069 missing stations should be taken care of inside the k loop; leave this syntax here in case its needed in the future
stnmiss = [200:999]; % bak jc069 missing stations should be taken care of inside the k loop; leave this syntax here in case its needed in the future
stnset = setdiff(stnall,stnmiss);

array_size = 1; % must exceed highest station number
array_size = max([array_size max(stnset)]);
e = nan+ones(array_size,1);
statnum = e; lat = e; lon = e;
maxp = e; maxd = e;
maxw = e;
minalt = e;
dns = e; dnb = e; dne = e;
cordep = e;
ndpths = e;
npsal = e; noxy = e; nnut = e; nco2 = e; ncfc = e; nco2_shore = e; nch4 = e; % jr302 nco2_shore are samples to be analysed ashore
comments = cell(array_size,1);

for k = stnset
    statnum(k) = k;
    stnstr = sprintf('%03d',k);

    vlist = 'press altimeter /';

    fn2db = [root '/ctd_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' stnstr '_2db'];
    fnpsal = [root '/ctd_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' stnstr '_psal'];
    fndcs = [root '/dcs_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' stnstr '_pos'];
    fndcs = [root '/dcs_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' stnstr ];
    fnwin = [ rootwin '/' 'win_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' stnstr];
%     fnwin = [root '/WINCH' '/' 'win_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' stnstr];
    fnsam = [root '/sam_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' stnstr];

    % bak on jc069  2 mar 2012;
    % test for existence of 2db file. if not there, skip. 
    % this avoids needing to enter files to skip over. (eg VMP-only
    % stations on jc069.
    
    if exist(m_add_nc(fn2db),'file') ~= 2; stnmiss = [stnmiss k]; continue; end % keep for later k loop
    
    [d2db h1] = mload(fn2db,vlist,'/');
    [dpsal h2] = mload(fnpsal,vlist,'/');
    if exist(m_add_nc(fnwin)) == 2
        [dwin h3] = mload(fnwin,cabname,'/');
        cmd = ['dwin.cableout = dwin.' cabname ';']; eval(cmd);
    else
        dwin.cableout = nan;
    end
    % bak on jc069. On towyo stations there may be no sam file
    if exist(m_add_nc(fnsam),'file') == 2
        [dsam h4] = mload(fnsam,'/');
    else
        dsam = []; h4 = [];
    end

    lat(k) = h1.latitude;
    lon(k) = h1.longitude;
    p = dpsal.press;
    dpth = sw_dpth(p(:),lat(k));
    alt = dpsal.altimeter;
    maxp(k) = max(dpsal.press);
    maxd(k) = sw_dpth(maxp(k),lat(k));

    minalt(k) = min(alt(find(p>(maxp(k)-30))));
    maxw(k) = max(dwin.cableout);

    cordep(k) = h1.water_depth_metres;
        
% % % % %     % bak on jc069 cludge
% % % % %     load('/local/users/pstar/jc069/data/station_depths/bestdeps');
% % % % %     cordep(k) = bestdeps(k);

    [ddcs h4] = mload(fndcs,'/');
    dns(k) = datenum(h4.data_time_origin) + ddcs.time_start/86400;
    dnb(k) = datenum(h4.data_time_origin) + ddcs.time_bot/86400;
    dne(k) = datenum(h4.data_time_origin) + ddcs.time_end/86400;

    % now analyse sam file

    % bak on jc069: surely zero is more logical for the number of depths if no bottle wireouts are
    % found. certainly this is the required answer for stations where no
    % bottles were closed and no sam file was created.
%     if isfield(dsam,'wireout'); ndpths(k) = length(unique(dsam.wireout(~isnan(dsam.wireout)))); else ndpths(k) = nan; end
    if isfield(dsam,'wireout'); ndpths(k) = length(unique(dsam.wireout(~isnan(dsam.wireout)))); else ndpths(k) = 0; end
    if isfield(dsam,'botpsal'); npsal(k) = sum(~isnan(dsam.botpsal)); else npsal(k) = 0; end
    if isfield(dsam,'botoxy'); noxy(k) = sum(~isnan(dsam.botoxy)); else noxy(k) = 0; end

    log_all = [];
    if isfield(dsam,'silc'); logical_silc = ~isnan(dsam.silc); log_all = [log_all logical_silc(:)]; end
    if isfield(dsam,'phos'); logical_phos = ~isnan(dsam.phos); log_all = [log_all logical_phos(:)]; end
    if isfield(dsam,'totnit'); logical_totnit = ~isnan(dsam.totnit); log_all = [log_all logical_totnit(:)]; end
    logical_nut = max(log_all,[],2);
    nnut(k) = sum(logical_nut); % zero if log_all is empty % should be robust even if all nuts are undefined

    %     if isfield(dsam,'dic'); nco2(k) = sum(~isnan(dsam.dic) | ~isnan(dsam.alk)); else nco2(k) = 0; end
    var_list = {'dic' 'alk'};
    klogall = []; % bug fixed by bak on jr302; previously the code only found the number of samples of the last variable in the list
    klog1all = []; % to count samples with flag = 1
    for klist = 1:length(var_list)
        varname = var_list{klist};
        if isfield(dsam,varname)
            cmd = ['klog = ~isnan(dsam.' varname ');']; eval(cmd);
            cmd = ['klog1 = (dsam.' varname '_flag == 1);']; eval(cmd);
            if isempty(klogall)
                klogall = klog; % first time
            else
                klogall = klogall|klog; % the or will be cumulative round the loop, so in the end we know about all the var names
            end
            if isempty(klog1all)
                klog1all = klog1; % first time
            else
                klog1all = klog1all|klog1; % the or will be cumulative round the loop, so in the end we know about all the var names
            end
        end
    end
    nco2(k) = sum(klogall);
    nco2_shore(k) = sum(klog1all);

    % bak on jc069: need to allow for any collection of cfc variables; this
    % syntax can be copied to the nuts group or carbon group if needed
    %     if isfield(dsam,'cfc11'); ncfc(k) = sum(~isnan(dsam.cfc11) | ~isnan(dsam.cfc12) | ~isnan(dsam.sf6) | ~isnan(dsam.f113) | ~isnan(dsam.ccl4)); else ncfc(k) = 0; end
    var_list = {'cfc11' 'cfc12' 'f113' 'sf6' 'ccl4' 'sf5cf3' 'cfc13'};
    klogall = []; % bug fixed by bak on jr302; previously the code only found the number of samples of the last variable in the list
    for klist = 1:length(var_list)
        varname = var_list{klist};
        if isfield(dsam,varname)
            cmd = ['klog = ~isnan(dsam.' varname ');']; eval(cmd);
            if isempty(klogall)
                klogall = klog; % first time
            else
                klogall = klogall|klog; % the or will be cumulative round the loop, so in the end we know about all the var names
            end
        end
    end
    ncfc(k) = sum(klogall);
    
    % jr302 ch4 and n2o
    var_list = {'ch4' 'n2o' };
    klogall = []; % bug fixed by bak on jr302; previously the code only found the number of samples of the last variable in the list
    for klist = 1:length(var_list)
        varname = var_list{klist};
        if isfield(dsam,varname)
            cmd = ['klog = ~isnan(dsam.' varname ');']; eval(cmd);
            if isempty(klogall)
                klogall = klog; % first time
            else
                klogall = klogall|klog; % the or will be cumulative round the loop, so in the end we know about all the var names
            end
        end
    end
    nch4(k) = sum(klogall);

end

switch cruise
    case 'jc069'
        % comments{1} = 'First station';
        comments{37} = 'towyo 1';
        for ki = 40:43; comments{ki} = 'towyo 2';end
        for ki = 44:47; comments{ki} = 'towyo 3';end
        for ki = 48:51; comments{ki} = 'towyo 4';end
        for ki = 52:55; comments{ki} = 'towyo 5';end
        for ki = 56:59; comments{ki} = 'towyo 6';end
        for ki = 60:62; comments{ki} = 'towyo 7';end
        for ki = 76:78; comments{ki} = 'towyo 8';end
        for ki = 79; comments{ki} = 'Mooring site';end
        for ki = 80:94; comments{ki} = 'sr1b';end
        for ki = 95:100; comments{ki} = 'A21';end
    case 'jr281'
        comments{1} = 'Test station';
        for ki = 2:33; comments{ki} = 'sr1b'; end
        for ki = [8 10 12 14 17 19 24 28]; comments{ki} = [comments{ki} ', float']; end % correct these numbers
        for ki = 34:66; comments{ki} = 'Orkney Passage'; end
        for ki = 35; comments{ki} = [comments{ki} ', aborted']; end
        for ki = 67:92; comments{ki} = 'A23'; end
        for ki = 93:112; comments{ki} = 'N Scotia Ridge'; end
        for ki = 113:122; comments{ki} = 'Arg. Basin'; end
        for ki = 123:128; comments{ki} = 'F. Trough'; end
    case 'jr302'
        for ki = 3:53; comments{ki} = 'OSNAP-W'; end
        for ki = 3:16; comments{ki} = 'OSNAP-W; shelf'; end
        for ki = 54:62; comments{ki} = 'A-B arc'; end
        for ki = [62 71:76]; comments{ki} = 'B-C arc'; end
        for ki = [94:101]; comments{ki} = 'C-D arc'; end
        for ki = [41:53]; comments{ki} = 'OSNAP-W; Line A'; end
        for ki = [63:70]; comments{ki} = 'Line B'; end
        for ki = [101:109]; comments{ki} = 'Line C'; end
        for ki = [77:94]; comments{ki} = 'OSNAP-E; Line D'; end
        for ki = [110:160]; comments{ki} = 'OSNAP-E'; end
        for ki = [161:161]; comments{ki} = 'OSNAP-E/EEL'; end
        for ki = [162:198]; comments{ki} = 'EEL'; end
        for ki = [199:999]; comments{ki} = 'OSNAP-E/EEL'; end
        comments{1} = 'Test station 1';
        comments{2} = 'Test station 2';
        comments{20} = 'Shallow; CH4/N2O only';
        comments{25} = 'Shallow; CH4/N2O only';
        comments{29} = 'Shallow; CH4/N2O only';
        comments{35} = 'Shallow; CH4/N2O only';
        comments{39} = 'Shallow; CH4/N2O only';
        comments{44} = 'Shallow; CH4/N2O only';
        comments{58} = 'Shallow; CH4/N2O only';
        comments{70} = 'Shallow; CH4/N2O only';
        comments{22} = 'Repeat of Test 2';
        comments{34} = 'CFC bottle blank; CFCs and O2 only';
        comments{41} = 'Offshore start of line A';
        comments{51} = 'No samples; taps open; repeated at 052';
        comments{53} = 'Inshore end of line A';
        comments{54} = 'Start A-B arc; No samples; CTD only; repeat of 041';
        comments{62} = 'End A-B arc';
        comments{63} = 'Inshore start of line B';
        comments{69} = 'Deepest station on line B';
        comments{71} = 'Start B-C arc';
        comments{76} = 'End B-C arc';
        comments{78} = 'Inshore start of line D';
        comments{77} = 'OSNAP-E; Line D';
        comments{94} = 'Branch to C-D arc';
        comments{101} = 'Offshore start of line C; repeat of 076';
        comments{109} = 'Inshore end of line C';
        comments{110} = 'OSNAP-E; repeat of 093';
        comments{111} = 'OSNAP-E; repeat of 094';
        comments{161} = 'OSNAP-E/EEL junction';
        comments{199} = 'OSNAP-E/EEL junction; repeat of 161';
        comments{234} = 'OSNAP-E/EEL final station';
    case 'dy040'
        for ki = 1; comments{ki} = 'Test station; DeepTow'; end
        for ki = 2:15; comments{ki} = 'Florida St with samples'; end
        for ki = 2; comments{ki} = 'Florida St with samples; CTD wire; no LADCP'; end
        for ki = 3:4; comments{ki} = 'Shallow; no LADCP'; end
        for ki = 6; comments{ki} = 'Termination failed; repeated as 007'; end
        for ki = 16:21; comments{ki} = 'Florida St CTDO/LADCP only'; end
        for ki = 22:24; comments{ki} = 'Florida St CTDO only; no LADCP'; end
        for ki = 25; comments{ki} = 'Start main section'; end
        for ki = 37; comments{ki} = 'Last before Nassau'; end
        for ki = 38; comments{ki} = 'Repeat 037; no samples; DeepTow until 054'; end
        for ki = 54; comments{ki} = 'Last with DeepTow'; end
        for ki = 55; comments{ki} = 'Swap to CTD wire'; end
        for ki = 63; comments{ki} = 'CFC Bottle blanks'; end
        for ki = 75:80; comments{ki} = 'Deep stations; some instruments off package'; end
        for ki = 87; comments{ki} = 'CTD landed on seabed; CTD wire kinked'; end
        for ki = 88; comments{ki} = 'DeepTow until XXX'; end
        for ki = 97; comments{ki} = 'CTD landed on seabed'; end
        for ki = 99; comments{ki} = 'CTD acquisition failed; Final 20m upcast lost'; end
        for ki = 101; comments{ki} = 'Unclear water depth'; end
        for ki = 106; comments{ki} = 'CTD parked in hangar'; end
        for ki = 109; comments{ki} = 'CTD parked in hangar'; end
        for ki = 110; comments{ki} = 'Depth > 6000; Not full depth;'; end
        for ki = 123; comments{ki} = 'CFC bottle blanks; not full depth;'; end
    otherwise
end

resid = maxd+minalt-cordep;
stnlistname = [MEXEC_G.MSCRIPT_CRUISE_STRING '_station_list'];
fid = fopen(stnlistname,'w');

% bak on jc069
% heading list
fprintf(fid,'%3s %8s %4s','stn','yy/mo/dd','hhmm');
fprintf(fid,' %10s %11s','dg min lat',' dg min lon');
fprintf(fid,'%s','  cdep  maxd  alt   res  wire  pres  nd');
switch cruise
    case 'jc069'
        fprintf(fid,'%s',' sal')
        fprintf(fid,'%s',' cfc')
    case 'jr281'
        fprintf(fid,'%s',' sal')
        fprintf(fid,'%s',' cfc')
    case 'jr302'
        fprintf(fid,'%s',' sal')
        fprintf(fid,'%s',' oxy')
        fprintf(fid,'%s',' nut')
        fprintf(fid,'%s',' car   ')
        fprintf(fid,'%s',' cfc')
        fprintf(fid,'%s',' ch4')
    case 'jr306'
        fprintf(fid,'%s',' sal')
    case 'dy040'
        fprintf(fid,'%s',' sal')
        fprintf(fid,'%s',' oxy')
        fprintf(fid,'%s',' nut')
        fprintf(fid,'%s',' car')
        fprintf(fid,'%s',' cfc')
    otherwise
        fprintf(fid,'%s',' sal')
        fprintf(fid,'%s',' oxy')
        fprintf(fid,'%s',' nut')
        fprintf(fid,'%s',' car')
        fprintf(fid,'%s',' cfc')
end
fprintf(fid,'%s\n','  Comments')

%jc069, need to refine stnset, since it wasn't set at start of prog
% remove any stations that were skipped in the earlier k loop
stnset = setdiff(stnall,stnmiss);

for k = stnset
    ss1 = datestr(dns(k),'yy/mm/dd'); ss2 = datestr(dns(k),'HHMM');
    sb1 = datestr(dnb(k),'yy/mm/dd'); sb2 = datestr(dnb(k),'HHMM');
    se1 = datestr(dne(k),'yy/mm/dd'); se2 = datestr(dne(k),'HHMM');
    stnstr = sprintf('%03d',k);
    h1 = 'N'; if lat(k) < 0; h1 = 'S'; end
    h2 = 'E'; if lon(k) < 0; h2 = 'W'; end
    latk = abs(lat(k));
    latd = floor(latk);
    latm = 60*(latk-latd);
    if latm >= 59.995; latm = 0; latd = latd+1; end% prevent write of 60.00 minutes
    lonk = abs(lon(k));
    lond = floor(lonk);
    lonm = 60*(lonk-lond);
    if lonm >= 59.995; lonm = 0; lond = lond+1; end% prevent write of 60.00 minutes

    fprintf(fid,'\n');
    fprintf(fid,'%3s %8s %4s\n','',ss1,ss2);
    fprintf(fid,'%3s %8s %4s',stnstr,sb1,sb2);
%     fprintf(fid,' %2d %05.2f %s %2d %05.2f %s',latd,latm,h1,lond,lonm,h2);
    fprintf(fid,' %2d %05.2f %s %3d %05.2f %s',latd,latm,h1,lond,lonm,h2); % jr281 allow 3 digits for longitude, just in case
    % cludge on jc069
    if cordep(k)-maxd(k) > 99; minalt(k) = -9; resid(k) = -999; end% can't expect altimeter to detect bottom
    switch cruise
        case 'jc069'
            if ~isempty(find(k == [41 46 47 54 55 76 86 ])); minalt(k) = -9; resid(k) = -999; end % altimeter didnt find bottom
            if k == 50; minalt(k) = 65; resid(k) = maxd(k)+minalt(k)-cordep(k); end % altimeter height off taken from deck unit log sheet
            if k == 56; minalt(k) = 58; resid(k) = maxd(k)+minalt(k)-cordep(k); end % altimeter height off taken from deck unit log sheet
            if k == 73; minalt(k) = 95; resid(k) = maxd(k)+minalt(k)-cordep(k); end % altimeter height off taken from deck unit log sheet
        case 'jr281'
            % stns 35 and 122 originally hardwired here, but now set in
            % populate_station_depths.m and inserted in file headers
            %             if k == 35; cordep(k) = 3443; minalt(k) = -9; resid(k) = -999; end % aborted. cordep from CTD deck unit log
            %             if k == 122; cordep(k) = 6059; minalt(k) = -9; resid(k) = -999; end % only went to 2500 for tracer. cordep from CTD deck unit log
        case 'jr302'
%             resid(k) = -999; % initially no cordeps
        case 'dy040'
            if k == 25; minalt(k) = 69; resid(k) = maxd(k)+minalt(k)-cordep(k); end % altimeter height off inspected in CTD data
            if k == 27; minalt(k) = 89; resid(k) = -999; end % ht off from ladcp
            if k == 101; minalt(k) = 495; resid(k) = -999; end % no bottom found by altimeter or ladcp; ht off from bathy & CTD depth
            if k == 107; minalt(k) = 35; resid(k) = maxd(k)+minalt(k)-cordep(k); end % altimeter height off inspected in CTD data
            if k == 109; minalt(k) = 40; resid(k) = -999; end % ht off from ladcp
            if k == 110; minalt(k) = 304; resid(k) = -999; end % no bottom found by altimeter or ladcp; ht off from bathy & CTD depth
            if k == 111; minalt(k) = 70; resid(k) = -999; end % ht off from ladcp
            if k == 112; minalt(k) = 72; resid(k) = -999; end % ht off from ladcp
            if k == 116; minalt(k) = 56; resid(k) = -999; end % ht off from ladcp
            if k == 123; minalt(k) = 268; resid(k) = -999; end % no bottom found by altimeter or ladcp; ht off from bathy & CTD depth

        otherwise
    end
    fprintf(fid,'  %4.0f',cordep(k));
    fprintf(fid,'  %4.0f',maxd(k));
    fprintf(fid,'  %3.0f',minalt(k));
    fprintf(fid,'  %4.0f',resid(k));
    fprintf(fid,'  %4.0f',maxw(k));
    fprintf(fid,'  %4.0f',maxp(k));
    fprintf(fid,'  %2.0f',ndpths(k));
    switch cruise % which bottle analyses may be present ?
        
        case 'jc069'
            fprintf(fid,'  %2.0f',npsal(k));
            fprintf(fid,'  %2.0f',ncfc(k));
        case 'jr281'
            fprintf(fid,'  %2.0f',npsal(k));
            fprintf(fid,'  %2.0f',ncfc(k));
        case 'jr302'
            fprintf(fid,'  %2.0f',npsal(k));
            fprintf(fid,'  %2.0f',noxy(k));
            fprintf(fid,'  %2.0f',nnut(k));
            if nco2_shore(k)>0
                fprintf(fid,'  %2.0f%s%2.0f',nco2(k),'/',nco2_shore(k));
            else
                fprintf(fid,'  %2.0f   ',nco2(k));
            end
            fprintf(fid,'  %2.0f',ncfc(k));
            fprintf(fid,'  %2.0f',nch4(k));
        case 'jr306'
            fprintf(fid,'  %2.0f',npsal(k));
        case 'dy040'
            fprintf(fid,'  %2.0f',npsal(k));
            fprintf(fid,'  %2.0f',noxy(k));
            fprintf(fid,'  %2.0f',nnut(k));
            fprintf(fid,'  %2.0f',nco2(k));
            fprintf(fid,'  %2.0f',ncfc(k));
        otherwise
            fprintf(fid,'  %2.0f',npsal(k));
            fprintf(fid,'  %2.0f',noxy(k));
            fprintf(fid,'  %2.0f',nnut(k));
            fprintf(fid,'  %2.0f',nco2(k));
            fprintf(fid,'  %2.0f',ncfc(k));
    end
    fprintf(fid,'  %s',comments{k});
    fprintf(fid,'\n');
    fprintf(fid,'%3s %8s %4s\n','',se1,se2);

end

fclose(fid);

prefix1 = ['station_summary_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];

otfile2 = [prefix1 'all'];

dataname = [prefix1 'all'];

switch cruise % which bottle analyses may be present ?
    case 'jr302'
        varnames={'statnum' 'time_start' 'time_bottom' 'time_end' 'lat' 'lon' 'cordep' 'maxd' 'minalt' 'resid' 'maxw' 'maxp' 'ndpths' 'npsal' 'noxy' 'nnut' 'nco2' 'nco2_shore' 'ncfc'};
        varunits={'number' 'seconds' 'seconds' 'seconds' 'degrees' 'degrees' 'metres' 'metres' 'metres' 'metres' 'metres' 'dbar' 'number' 'number' 'number' 'number' 'number' 'number' 'number'};
    case 'jr306'
        varnames={'statnum' 'time_start' 'time_bottom' 'time_end' 'lat' 'lon' 'cordep' 'maxd' 'minalt' 'resid' 'maxw' 'maxp' 'ndpths' 'npsal'};
        varunits={'number' 'seconds' 'seconds' 'seconds' 'degrees' 'degrees' 'metres' 'metres' 'metres' 'metres' 'metres' 'dbar' 'number' 'number'};
    case 'dy040'
        varnames={'statnum' 'time_start' 'time_bottom' 'time_end' 'lat' 'lon' 'cordep' 'maxd' 'minalt' 'resid' 'maxw' 'maxp' 'ndpths' 'npsal' 'noxy' 'nnut' 'nco2' 'ncfc'};
        varunits={'number' 'seconds' 'seconds' 'seconds' 'degrees' 'degrees' 'metres' 'metres' 'metres' 'metres' 'metres' 'dbar' 'number' 'number' 'number' 'number' 'number' 'number'};
    otherwise
        varnames={'statnum' 'time_start' 'time_bottom' 'time_end' 'lat' 'lon' 'cordep' 'maxd' 'minalt' 'resid' 'maxw' 'maxp' 'ndpths' 'npsal' 'noxy' 'nnut' 'nco2' 'ncfc'};
        varunits={'number' 'seconds' 'seconds' 'seconds' 'degrees' 'degrees' 'metres' 'metres' 'metres' 'metres' 'metres' 'dbar' 'number' 'number' 'number' 'number' 'number' 'number'};
end

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

%--------------------------------
% 2009-03-09 20:49:09
% msave
% input files
% Filename    Data Name :   <version>  <site>
% output files
% Filename oxy_jc032_001.nc   Data Name :  oxy_jc032_001 <version> 1 <site> jc032MEXEC_A.MARGS_IN_1 = {
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
%--------------------------------



% % % % mcd M_CTD
% % % %
% % % % wdepall = load('wdeplist');
% % % %
% % % % [d h] = mload('dcs_jc032_all','/');
% % % %
% % % % nstat = length(d.statnum);
% % % %
% % % % fprintf(MEXEC_A.Mfidterm,'%s\n',' ');
% % % % fprintf(MEXEC_A.Mfidterm,'%s\n','RRS James Cook Cruise JC032');
% % % % fprintf(MEXEC_A.Mfidterm,'%s\n','Station list up to 20 March 2009');
% % % % fprintf(MEXEC_A.Mfidterm,'%s\n','Principal Scientist B King, b.king@noc.soton.ac.uk');
% % % % fprintf(MEXEC_A.Mfidterm,'%s\n',' ');
% % % % fprintf(MEXEC_A.Mfidterm,'%s\n','CTD parameters are');
% % % % fprintf(MEXEC_A.Mfidterm,'%s\n',' ');
% % % % fprintf(MEXEC_A.Mfidterm,'%s\n','pressure');
% % % % fprintf(MEXEC_A.Mfidterm,'%s\n','conductivity');
% % % % fprintf(MEXEC_A.Mfidterm,'%s\n','temperature');
% % % % fprintf(MEXEC_A.Mfidterm,'%s\n','dissolved oxygen');
% % % % fprintf(MEXEC_A.Mfidterm,'%s\n','lowered ADCP');
% % % % fprintf(MEXEC_A.Mfidterm,'%s\n',' ');
% % % % fprintf(MEXEC_A.Mfidterm,'%s\n','Discrete bottle samples will be analysed for');
% % % % fprintf(MEXEC_A.Mfidterm,'%s\n',' ');
% % % % fprintf(MEXEC_A.Mfidterm,'%s\n','salinity');
% % % % fprintf(MEXEC_A.Mfidterm,'%s\n','dissolved oxygen');
% % % % fprintf(MEXEC_A.Mfidterm,'%s\n','nitrate');
% % % % fprintf(MEXEC_A.Mfidterm,'%s\n','phosphate');
% % % % fprintf(MEXEC_A.Mfidterm,'%s\n','silicate');
% % % % fprintf(MEXEC_A.Mfidterm,'%s\n','total alkalinity');
% % % % fprintf(MEXEC_A.Mfidterm,'%s\n','dissolved inorganic carbon');
% % % % fprintf(MEXEC_A.Mfidterm,'%s\n','CFC-11');
% % % % fprintf(MEXEC_A.Mfidterm,'%s\n','CFC-12');
% % % % fprintf(MEXEC_A.Mfidterm,'%s\n','CFC-113');
% % % % fprintf(MEXEC_A.Mfidterm,'%s\n','Carbon Tetrachloride');
% % % % fprintf(MEXEC_A.Mfidterm,'%s\n','Sulphur Hexafluoride');
% % % % fprintf(MEXEC_A.Mfidterm,'%s\n',' ');
% % % %
% % % %
% % % % % m1 = ['Stn Time_start        Lat          Lon         Water     Max'];
% % % % % m2 = ['Stn Time_bottom       deg min      deg min     depth   pressure'];
% % % % % m3 = ['Stn Time_end                                    (m)     (dbar)'];
% % % % m1 = ['Stn Time_start        Lat          Lon         Water     Max'];
% % % % m2 = ['Stn Time_bottom       deg min      deg min     depth  ctd depth'];
% % % % m3 = ['Stn Time_end                                    (m)      (m)'];
% % % %
% % % % fprintf(MEXEC_A.Mfidterm,'%s\n%s\n%s\n\n',m1,m2,m3)
% % % %
% % % % posall = nan+zeros(nstat,2);
% % % %
% % % % for kstn = 1:nstat
% % % %
% % % %     % get water depth from listing extracted from ldeo software
% % % %     k_ind = find(wdepall(:,1) == kstn);
% % % %     wdep = wdepall(k_ind,2);
% % % %
% % % %
% % % %     % obtain nav from dfinfo
% % % %     vname = 'time_bot';
% % % %     % allow for the possibility that the dcs file contains many stations
% % % %     time_bot = d.time_bot(kstn);
% % % %     [yyyy mo dd hh mm ss dayofyear] = m_time_to_ymdhms(vname,time_bot,h);
% % % %     rvstime = sprintf('%02d%03d%02d%02d%02d',yyyy-2000,dayofyear,hh,mm,ss);
% % % %     cmd = ['ssh pstar@' MEXEC_G.Mrsh_machine ' posinfo -t ' rvstime ' -d ' MEXEC_G.Mrvs_navfile];
% % % %     [uMEXEC.status uresult] = unix(cmd);
% % % %     %uresult =
% % % %     %09 067 09:18:10  -36.330892  -53.498287
% % % %     latstr = uresult(16:27); latbot = str2num(latstr);
% % % %     lonstr = uresult(28:end); lonbot = str2num(lonstr);
% % % %
% % % %     posall(kstn,1:2) = [latbot lonbot];
% % % %
% % % %     m1 = sprintf('%03d',d.statnum(kstn));
% % % %
% % % %
% % % %     %times
% % % %     time_start = d.time_start(kstn);
% % % %     [yyyy mo dd hh mm ss dayofyear] = m_time_to_ymdhms(vname,time_start,h);
% % % %     m2 = sprintf('%04d%s%02d%s%02d %02d%s%02d',yyyy,'/',mo,'/',dd,hh,':',mm);
% % % %     time_bot = d.time_bot(kstn);
% % % %     [yyyy mo dd hh mm ss dayofyear] = m_time_to_ymdhms(vname,time_bot,h);
% % % %     m3 = sprintf('%04d%s%02d%s%02d %02d%s%02d',yyyy,'/',mo,'/',dd,hh,':',mm);
% % % %     time_end = d.time_end(kstn);
% % % %     [yyyy mo dd hh mm ss dayofyear] = m_time_to_ymdhms(vname,time_end,h);
% % % %     m4 = sprintf('%04d%s%02d%s%02d %02d%s%02d',yyyy,'/',mo,'/',dd,hh,':',mm);
% % % %
% % % %
% % % %     %max pressure and depth
% % % %     m5 = sprintf('    %4.0f',d.press_bot(kstn));
% % % %     maxctddep = sw_dpth(d.press_bot(kstn),latbot);
% % % %     m5a = sprintf('    %4.0f',maxctddep);
% % % %
% % % %     % reformat lat and lon
% % % % %     lat = d.lat_bot(kstn);
% % % %     lat = latbot;
% % % %     latdeg = fix(lat);
% % % %     latmin = abs(60*(lat-latdeg));
% % % %     m6 = sprintf('%4d %6.3f',latdeg,latmin);
% % % % %     lon = d.lon_bot(kstn);
% % % %     lon = lonbot;
% % % %     londeg = fix(lon);
% % % %     lonmin = abs(60*(lon-londeg));
% % % %     m7 = sprintf('%4d %6.3f',londeg,lonmin);
% % % %
% % % %
% % % %     % format water depth
% % % %     water_dep = wdep;
% % % %     m8 = sprintf('  %4d',water_dep);
% % % %
% % % %     fprintf(MEXEC_A.Mfidterm,'%s %s\n',m1,m2)
% % % %     fprintf(MEXEC_A.Mfidterm,'%s %s %s %s %s %s\n',m1,m3,m6,m7,m8,m5a)
% % % %     fprintf(MEXEC_A.Mfidterm,'%s %s\n\n',m1,m4)
% % % %
% % % % end
