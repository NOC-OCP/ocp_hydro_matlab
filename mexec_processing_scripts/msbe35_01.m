% msbe35_01: load sbe35 data from one or more stations and write to
%     mstar file sbe35_cruise_01.nc, as well as pasting into
%     sam_cruise_all.nc
%
% Use: stn = 16; msbe35_01;
%
% or for multiple stations use klist
%      klist = 1:5; msbe35_01;

scriptname = 'castpars'; oopt = 'minit'; get_cropt
if MEXEC_G.quiet<=1; fprintf(1,'loading SBE35 ascii file(s) to write to sbe35_%s_01.nc and sam_%s_all.nc\n',mcruise,mcruise); end

% load sbe35 data
root_sbe35 = mgetdir('M_SBE35');
scriptname = mfilename; oopt = 'sbe35file'; get_cropt
ds = dir(fullfile(root_sbe35, sbe35file));
file_list = {ds.name};
kount = 0;
alldata = {}; statnum = [];
for kf = 1:length(file_list)
    fn = fullfile(root_sbe35, file_list{kf});
    iis = strfind(file_list{kf},'.asc')+[-3:-1];
    fid2 = fopen(fn,'r');
    while 1
        str = fgetl(fid2);
        if ~ischar(str); break; end % fgetl has returned -1 as a number
        strlen = length(str);
        % on jr281, the data lines have 77 characters. Discard anything
        % else
        if strlen ~= 77; continue; end % data are in 77 byte lines
        kount = kount+1;
        alldata = [alldata; str];
        statnum = [statnum; str2double(file_list{kf}(iis))]; %not used finally, but may be used by opt_cruise
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
    dd = str2double(data(5:6));
    mon = data(8:10);
    mo = strmatch(mon,months);
    yyyy = str2double(data(12:15));
    hms = data(18:25);
    hh = str2double(hms(1:2));
    mm = str2double(hms(4:5));
    ss = str2double(hms(7:8));
    datnum(kd) = datenum([yyyy mo dd hh mm ss]);
    bn(kd) = str2double(data(32:33));
    tdiff(kd) = str2double(data(41:46));
    val(kd) = str2double(data(53:61));
    t90(kd) = str2double(data(68:77));
end
scriptname = mfilename; oopt = 'sbe35_datetime_adj'; get_cropt

%initialise
varnames = {'time' 'position' 'sampnum' 'tdiff' 'val' 'sbe35temp' 'sbe35temp_flag' 'statnum'};
varunits = {'seconds' 'on.rosette' 'number' 'number' 'number' 'degc90' 'woce_table_4.9' 'number'};
clear ds
for vno = 1:length(varnames)
    ds.(varnames{vno}) = [];
end

%loop through stations to get data and add to structure ds
files = dir(fullfile(mgetdir('M_CTD'), ['dcs_' mcruise '_*.nc']));
for fno = 1:length(files)

    infile1 = fullfile(mgetdir('M_CTD'), files(fno).name);
    stnlocal = str2double(infile1(end-5:end-3));
    scriptname = 'castpars'; oopt = 'nnisk'; get_cropt
    
    % read the station dcs file to identify start and end of station
    if exist(m_add_nc(infile1),'file') ~= 2
        msg = ['dcs file ' infile1 ' not found'];
        fprintf(MEXEC_A.Mfider,'%s\n',msg);
        return
    end
    hd = m_read_header(infile1);
    if sum(strcmp('time_start',hd.fldnam)) && sum(strcmp('time_end',hd.fldnam))
        
        [dd, hd] = mloadq(infile1,'time_start time_end');
        stn_start = datenum(hd.data_time_origin) + dd.time_start/86400;
        stn_end = datenum(hd.data_time_origin) + dd.time_end/86400;
        
        %append data from this station into structure d
        kok = find(datnum >= stn_start-15/1440 & datnum <= stn_end+15/1440);
        if ~isempty(kok)
            time = 86400*(datnum(kok)-datenum(hd.data_time_origin));
            [timesort, ksort, junk] = unique(time); %YLF JR15003 in case of duplicates (recorder not erased between casts)
            % repopulate time, just to be sure all data variables are sorted identically
            ds.time = [ds.time; 86400*(datnum(kok(ksort))-datenum(hd.data_time_origin))];
            ds.position = [ds.position; bn(kok(ksort))];
            ds.tdiff = [ds.tdiff; tdiff(kok(ksort))];
            ds.val = [ds.val; val(kok(ksort))];
            ds.sbe35temp = [ds.sbe35temp; t90(kok(ksort))];
            ds.sbe35temp_flag = [ds.sbe35temp_flag; 2+zeros(length(ksort),1)];
            ds.statnum = [ds.statnum; stnlocal+zeros(length(ksort),1)];
        end
        
    end
    
end
ds.sampnum = 100*ds.statnum+ds.position;
scriptname = mfilename; oopt = 'sbe35flag'; get_cropt
%***bottle not fired won't be in list, so nan must be bad
ds.sbe35temp_flag(isnan(ds.sbe35temp)&ds.sbe35temp_flag<4) = 4; 

% now save the data
clear hnew
dataname = ['sbe35_' mcruise '_01'];
otfile1 = fullfile(mgetdir('M_SBE35'), dataname);
hnew.fldnam = varnames; hnew.fldunt = varunits; hnew.dataname = dataname;
hnew.comment = ['files ' sprintf('%s ', file_list{:})]; %***
MEXEC_A.Mprog = mfilename;
mfsave(otfile1, ds, hnew, '-merge', 'sampnum');

%and update sam_cruise_all file
otfile2 = fullfile(mgetdir('M_CTD'), ['sam_' mcruise '_all']);
hnew = rmfield(hnew, 'dataname');
hnew.comment = ['SBE35 data from sbe35_' mcruise '_01.nc'];
MEXEC_A.Mprog = mfilename;
mfsave(otfile2, ds, hnew, '-merge', 'sampnum');
