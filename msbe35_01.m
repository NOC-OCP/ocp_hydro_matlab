% msbe35_01: load sbe35 data
%
% Use: msbe35_01        and then respond with station number, or for station 16
%      stn = 16; msbe35_01;

% bak on jr281 21 March 2013
%
% ylf modified jr15003 to deal with (by ignoring) duplicates (in case the recorder wasn't cleared between casts)

scriptname = 'msbe35_01';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
oopt = '';

if ~exist('stn','var')
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
stnlocal = stn; clear stn % so that it doesn't persist

mdocshow(scriptname, ['loads SBE35 ascii files listed in lsbe and writes to sbe35_' cruise '_' stn_string.nc']);

root_ctd = mgetdir('M_CTD');
root_sbe35 = mgetdir('M_SBE35');
prefix1 = ['dcs_' cruise '_'];
prefix2 = ['sbe35_' cruise '_'];

infile1 = [root_ctd '/' prefix1 stn_string];
otfile1 = [root_sbe35 '/' prefix2 stn_string];
otdataname = [prefix2 stn_string];

% read the station dcs file to identify start and end of station
if exist(m_add_nc(infile1),'file') ~= 2
    msg = ['dcs file ' infile1 ' not found'];
    fprintf(MEXEC_A.Mfider,'%s\n',msg);
    return
end
[dd hd] = mload(infile1,'/');

stn_start = datenum(hd.data_time_origin) + dd.time_start/86400;
stn_end = datenum(hd.data_time_origin) + dd.time_end/86400;

% load sbe35 data
d = struct2cell(dir('*.asc')); file_list = d(1,:);
% load all data then find the data for this station

kount = 0;
alldata = {};

% now load the file contents
for kf = 1:length(file_list);
    
    fn = file_list{kf};
    
    fid2 = fopen(fn,'r');
    while 1
        str = fgetl(fid2);
        if ~ischar(str); break; end % fgetl has returned -1 as a number
        strlen = length(str);
        % on jr281, the data lines have 77 characters. Discard anything
        % else
        if strlen ~= 77; continue; end % data are in 77 byte lines
        kount = kount+1;
        alldata = [alldata ; str];
    end
    
    
    fclose(fid2);
    
end

% end of loading file contents

% unpick the values. At this stage I don't know whether the format might
% vary from cruise to cruise
numdata = length(alldata); % number of data lines

datnum = nan+ones(numdata,1);
bn = datnum;
diff = datnum;
val = datnum;
t90 = datnum;

kfields = {'bn' 'diff' 'val' 't90'};
months = {'Jan' 'Feb' 'Mar' 'Apr' 'May' 'Jun' 'Jul' 'Aug' 'Sep' 'Oct' 'Nov' 'Dec'}; % guess at month names

for kd = 1:numdata
    data = alldata{kd};
    dd = str2num(data(5:6));
    mon = data(8:10);
    mo = strmatch(mon,months);
    yyyy = str2num(data(12:15));
    hms = data(18:25);
    hh = str2num(hms(1:2));
    mm = str2num(hms(4:5));
    ss = str2num(hms(7:8));
    datnum(kd) = datenum([yyyy mo dd hh mm ss]);
    bn(kd) = str2num(data(32:33));
    diff(kd) = str2num(data(41:46));
    val(kd) = str2num(data(53:61));
    t90(kd) = str2num(data(68:77));
    
end

% now need to identify station based on time, and write the data.
kok = find(datnum >= stn_start-15/1440 & datnum <= stn_end+15/1440); % bak on jr302 allow 15 mins each end because time stamps in SBE35 data are 4 mins in error

if isempty(kok)
    time = nan+zeros(24,1);
    position = 1:24; position = position(:);
    sampnum = 100*stnlocal+position;
    diff = time;
    val = time;
    sbe35temp = time;
    sbe35flag = 9 + zeros(24,1);
else
    time = 86400*(datnum(kok)-datenum(hd.data_time_origin));
    %[timesort ksort] = sort(time);
    [timesort ksort junk] = unique(time); %YLF JR15003 in case of duplicates (recorder not erased between casts)
    % repopulate time, just to be sure all data variables are sorted
    % identically
    time = 86400*(datnum(kok(ksort))-datenum(hd.data_time_origin));
    position = bn(kok(ksort));
    sampnum = 100*stnlocal+position;
    diff = diff(kok(ksort));
    val = val(kok(ksort));
    sbe35temp = t90(kok(ksort));
    sbe35flag = 2+0*sbe35temp;
    oopt = 'flag'; get_cropt
end

% now save the data

varnames = {'time' 'position' 'sampnum' 'diff' 'val' 'sbe35temp' 'sbe35flag'};
varunits = {'seconds' 'on.rosette' 'number' 'number' 'number' 'degc90' 'woce_table_4.9'};

% sorting out units for msave

varnames_units = {};
for k = 1:length(varnames)
    varnames_units = [varnames_units; varnames(k)];
    varnames_units = [varnames_units; {'/'}];
    varnames_units = [varnames_units; varunits(k)];
end

timestring = ['[' sprintf('%d %d %d %d %d %d',hd.data_time_origin) ']'];


%--------------------------------
MEXEC_A.MARGS_IN_1 = {
    otfile1
    };
MEXEC_A.MARGS_IN_2 = varnames(:);
MEXEC_A.MARGS_IN_3 = {
    ' '
    ' '
    '1'
    otdataname
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


