function mcod_stn_out(cast,statnum,os)

% bak jc069

% os is numeric 75 or 150
% cast could be 'ctd' (text string so includes quotes, or on jc069 could be
% hrp02, eg
% mcod_stn_out('hrp02',kstn,thisos)
% mcod_stn_out('ctd',1,75)


m_common

if ischar(statnum); 
    statnum = str2num(statnum); % variables come in as char if simply typed on the command line
end 

kstn = statnum;
stn_string = sprintf('%03d',kstn);
oslocal = os;
osstr = sprintf('%d',oslocal);

[MEXEC.status currentdir] = unix('pwd'); 
mcd ('M_VMADCP');

cmd=['cd ' MEXEC_G.MSCRIPT_CRUISE_STRING '_os' sprintf('%d',oslocal)];eval(cmd);

% construct input filename; 
prefix = ['os' osstr '_' MEXEC_G.MSCRIPT_CRUISE_STRING 'nnx_' ];
infile = [prefix cast '_' stn_string '_ave'];

if exist(m_add_nc(infile)) ~= 2; cmd = ['cd ' currentdir]; eval(cmd); return; end

[da ha] = mload(infile,'/');

torg = datenum(ha.data_time_origin);
time = torg+da.time_bin_average/86400;
uabs = da.uabs;
vabs = da.vabs;
lon = da.lon;
lat = da.lat;
depth = da.depth;
uabs_stddev = da.uabs_bin_std;
vabs_stddev = da.vabs_bin_std;
uabs_num = da.uabs_bin_number;
vabs_num = da.vabs_bin_number;


cmd = ['save os' osstr '_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' cast '_' stn_string,' time depth uabs vabs lon lat uabs_stddev vabs_stddev uabs_num vabs_num'];eval(cmd);

cmd = ['cd ' currentdir]; eval(cmd);
