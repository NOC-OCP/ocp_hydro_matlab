% msbe35_01: load sbe35 data from one or more stations and write to
%     mstar file sbe35_cruise_01.nc
%
% Use: msbe35_01        and then respond with station number, or for station 16
%      stn = 16; msbe35_01;
%
% or for multiple stations use klist
%      klist = 1:5; msbe35_01;

mdocshow(mfilename, ['loads SBE35 ascii file(s) and writes to sbe35_' mcruise '_01.nc']);

m_common

% load sbe35 data
d = struct2cell(dir([mgetdir('M_SBE35') '/*.asc'])); file_list = d(1,:);
kount = 0;
alldata = {};
for kf = 1:length(file_list);
    fn = [root_sbe35 '/' file_list{kf}];
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

% unpick the values
numdata = length(alldata);
datnum = nan+ones(numdata,1);
bn = datnum;
tdiff = datnum;
val = datnum;
t90 = datnum;
kfields = {'bn' 'tdiff' 'val' 't90'};
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
    tdiff(kd) = str2num(data(41:46));
    val(kd) = str2num(data(53:61));
    t90(kd) = str2num(data(68:77));
end

if ~exist('klist','var')
    if ~exist(stn)
        minit
    end
    klist = stn; clear stn
end
klist = klist(:)';

%initialise
varnames = {'time' 'position' 'sampnum' 'tdiff' 'val' 'sbe35temp' 'sbe35temp_flag'};
varunits = {'seconds' 'on_rosette' 'number' 'number' 'number' 'degc90' 'woce_table_4.9'};
for vno = 1:length(varnames)
    d.(varnames{vno}) = [];
end

%loop through stations to get data and add to structure d
for kloop = klist
    
    stn = kloop; minit
    scriptname = 'castpars'; oopt = 'nnisk'; get_cropt
    
    % read the station dcs file to identify start and end of station
    infile1 = [mgetdir('M_CTD') '/dcs_' mcruise '_' stn_string];
    if exist(m_add_nc(infile1),'file') ~= 2
        msg = ['dcs file ' infile1 ' not found'];
        fprintf(MEXEC_A.Mfider,'%s\n',msg);
        return
    end
    [dd, hd] = mload(infile1,'time_start time_end');
    stn_start = datenum(hd.data_time_origin) + dd.time_start/86400;
    stn_end = datenum(hd.data_time_origin) + dd.time_end/86400;
    
    %append data from this station into structure d
    kok = find(datnum >= stn_start-15/1440 & datnum <= stn_end+15/1440);
    if ~isempty(kok)
        time = 86400*(datnum(kok)-datenum(hd.data_time_origin));
        [timesort, ksort, junk] = unique(time); %YLF JR15003 in case of duplicates (recorder not erased between casts)
        % repopulate time, just to be sure all data variables are sorted identically
        d.time = [d.time; 86400*(datnum(kok(ksort))-datenum(hd.data_time_origin))];
        d.position = [d.position; bn(kok(ksort))];
        d.sampnum = [d.sampnum; 100*stnlocal+position];
        d.tdiff = [d.tdiff; tdiff(kok(ksort))];
        d.val = [d.val; val(kok(ksort))];
        d.sbe35temp = [d.sbe35temp; t90(kok(ksort))];
        d.sbe35temp_flag = [d.sbe35temp_flag; 2+0*sbe35temp];
    end
    
end
scriptname = mfilename; oopt = 'sbe35flag'; get_cropt

% now save the data
dataname = ['sbe35_' mcruise '_01'];
otfile1 = [mgetdir('M_SBE35') '/' dataname];
flds = [varnames; varunits];
mfsave(otfile1, d, flds, '-merge', 'sampnum');

%timestring = ['[' sprintf('%d %d %d %d %d %d',hd.data_time_origin) ']'];
%%***