function mvad_for_ladcp(cast,statnum,inst)
%function mvad_for_ladcp(cast,statnum,inst)

% bak jc069

% inst is string '75nb', '150bb', etc.
% cast could be 'ctd' (text string so includes quotes, or on jc069 could be
% hrp02, eg
% mcod_stn_out('hrp02',kstn,thisos)
% mcod_stn_out('ctd',1,75)


m_common

scriptname = 'mvad_for_ladcp';
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

if ischar(statnum);
    statnum = str2num(statnum); % variables come in as char if simply typed on the command line
end

kstn = statnum;
stn_string = sprintf('%03d',kstn);

root_vmadcp = mgetdir('M_VMADCP');

% construct input filename;
prefix = [inst '_' mcruise];
%infile = [root_vmadcp '/mproc/' prefix '_' cast '_' stn_string '_ave'];
infile = [root_vmadcp '/mproc/' prefix '_' cast '_' stn_string]; % CV

if exist(m_add_nc(infile)) ~= 2; return; end

[da ha] = mload(infile,'/');

%torg = datenum(ha.data_time_origin);
%time = torg+da.time_bin_average/86400;
%uabs = da.uabs;
%vabs = da.vabs;
%lon = da.lon;
%lat = da.lat;
%depth = da.depth;
%uabs_stddev = da.uabs_bin_std;
%vabs_stddev = da.vabs_bin_std;
%uabs_num = da.uabs_bin_number;
%vabs_num = da.vabs_bin_number;

% BEGIN ----- CV 2018/11/17 : edit to get the right variable names and time
% for LDEO_IX_12
tim_sadcp = da.decday(1,:) + julian(ha.data_time_origin(1),ha.data_time_origin(2),ha.data_time_origin(3));
lat_sadcp = da.lat(1,:);
lon_sadcp = da.lon(1,:);
u_sadcp   = da.uabs*1e-2; % cm/s to m/s
v_sadcp   = da.vabs*1e-2; % cm/s to m/s
z_sadcp   = da.depth(:,1);
% END ------- CV 2018/11/17

save([root_vmadcp '/mproc/' inst '_' mcruise '_' cast '_' stn_string '_forladcp'], 'tim_sadcp', 'z_sadcp', 'u_sadcp', 'v_sadcp', 'lon_sadcp', 'lat_sadcp');
