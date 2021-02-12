% mvad_03
%
% high level script to split out vmadcp on station data
% overhaul by bak on jc069 to make direct use of ctd dcs files for station
% start and end times
% further mod on jc069 by bak:
% allow three input arguments
% if the first argument is 'ctd', then pick up station number from ctd dcs
% file
% otherwise, pick up start and end times from a file called
% mcod_03_times
% for which the structure is, cast type followed by cast number followed by
% dates start and stop. eg to extract data from an hrp dive 3
% hrp02 3 [2012 2 8 01 26 00 ] [2012 2 8 02 05 00]
% cast stn start_time stop_time
%
% To run in a loop, define cast,stn,os before running script
%
% overhaul on jc159 bak 2 april 2018
% new scriptname mvad_03; previously mcod_03;
% new input and output directories as we move to the python version of
% codas.
%
% The work takes place in data/vmadcp/mproc
%
% selection of times controlled by data/vmadcp/mproc/mvad_03_mcruise_times.txt;
% format of times file as before, eg
% wait 04 [2018 03 02 01 14 31] [2018 03 02 03 14 31]
% wait 05 [2018 03 02 03 44 33] [2018 03 02 05 34 33]
% wait 06 [2018 03 02 06 24 33] [2018 03 02 09 34 33]
% wait 07 [2018 03 02 10 34 33] [2018 03 02 12 54 32]
% wait 08 [2018 03 02 14 04 33] [2018 03 02 16 34 33]
%
% Times around CTD stations can be indentified using mvad_list_station
%
% The above example was to select data while waiting 2 hours to collect
% VMADCP data on shallow stations.
%
% Then run
% cast = 'wait'; stn = 4; os = 150; mvad_03

mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

if exist('cast','var')
    m = ['Running script ' mfilename ' on cast type ' sprintf('%s',cast)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    cast = input('type cast type ','s');
end
castlocal = cast; clear cast; % so it doesnt persist
cast_string = sprintf('%s',castlocal);

if exist('stn','var')
    m = ['Running script ' mfilename ' on station ' sprintf('%03d',stn)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    stn = input('type stn number ');
end
stnlocal = stn; clear stn; % so it doesnt persist
stn_string = sprintf('%03d',stnlocal);

if exist('inst','var')
    m = ['Running script ' mfilename ' for VMADCP ' sprintf('%s',inst)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    inst = input('Enter instrument type: e.g. os150nb, os75nb, os150bb : ', 's');
end
instlocal = inst; clear inst; % so it doesnt persist

root_ctd = mgetdir('M_CTD');
root_vmadcp = mgetdir('M_VMADCP');

root_vmad = mgetdir('M_VMADCP');
infile = [root_vmad '/mproc/' instlocal '_' mcruise '_01.nc'];


% construct output filename;
% previous code did some fancy stuff using strtok; this does the same.
klastus = max(strfind(infile,'_'));
prefix = infile(1:klastus);
infile2 = [root_vmadcp '/mproc/mvad_03_' mcruise '_times.txt'];
otfile1 = [prefix cast_string '_' stn_string];
otfile2 = [prefix cast_string '_' stn_string '_ave'];
kslash = strfind(otfile1,'/');
dataname = otfile1((max(kslash)+1):end);

switch castlocal
    case 'ctd'
        % collect ctd times from dcs file in ctd directory
        
        prefix1 = [root_ctd '/dcs_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
        dcsfile = [prefix1 stn_string];
        if exist(m_add_nc(dcsfile),'file') ~= 2; return; end % quit if the ctd station doesn't exist
        [ddcs hdcs] = mload(dcsfile,'/');
        
        torgd = datenum(hdcs.data_time_origin);
        tstart = torgd+ddcs.time_start(1)/86400;
        tend = torgd+ddcs.time_end(1)/86400;
    otherwise
        % get times from mcod_03_times
        % bits of code to parse it robustly
        if exist(infile2,'file') ~= 2
            merr = [infile2 ' not found, but is required to define start and end times'];
            fprintf(MEXEC_A.Mfider,'%s\n',merr);
            return
        end
        fid = fopen(infile2,'r');
        while 1
            tline = fgetl(fid);
            if ~ischar(tline)
                merr = [cast_string ' ' stn_string ' not found in file ' infile2];
                fprintf(MEXEC_A.Mfider,'%s\n',merr)
                fclose(fid);
                return
            end
            % ensure spaces surround '[' and ']'
            tline = [tline ' ']; % ensure at least one character after final ']'
            kmat = strfind(tline,'[');
            for kll = fliplr(kmat) % start at the end
                tline = [tline(1:kll-1) ' [ ' tline(kll+1:end)];
            end
            kmat = strfind(tline,']');
            for kll = fliplr(kmat) % start at the end
                tline = [tline(1:kll-1) ' ] ' tline(kll+1:end)];
            end
            % remove outside and multiple spaces
            while strcmp(tline(1),' ') == 1
                tline(1) = [];
                if isempty(tline); break; end
            end
            while strcmp(tline(end),' ') == 1
                tline(end) = [];
                if isempty(tline); break; end
            end
            k = strfind(tline,'  ');
            while ~isempty(k)
                tline(k) = [];
                k = strfind(tline,'  ');
            end
            
            % now we can parse tline
            k = strfind(tline,' ');
            thiscast = tline(1:k-1);
            rest = sscanf(tline(k+1:end),'%d [ %d %d %d %d %d %d ] [ %d %d %d %d %d %d]');
            rest = rest(:)';
            thisstn = rest(1);
            if strcmp(thiscast,castlocal) & (thisstn == stnlocal)
                tstart = datenum(rest(2:7));
                tend = datenum(rest(8:13));
                m1 = [thiscast ' ' sprintf('%3d',thisstn) ' found'];
                m2 = ['start time ' datestr(tstart,31)];
                m3 = ['end time   ' datestr(tend,31)];
                fprintf(MEXEC_A.Mfidterm,'%s\n',' ',m1,m2,m3,' ')
                break
            end
        end
        fclose(fid);
end

% get time span of vmadcp file

[dadcp hadcp] = mload(infile,'/');
torga = datenum(hadcp.data_time_origin);
time = torga + dadcp.time(1,:)/86400;

% check ctd times contained in vmadcp

if tstart < min(time)
    merr = ['ctd start time ' sprintf('%s',datestr(tstart,31)) ' earlier than start of vmadcp data ' sprintf('%s',datestr(min(time),31))];
    fprintf(MEXEC_A.Mfider,'%s\n',merr)
    query = input('Type ''y'' to continue; anything else to exit ','s');
    if strcmp(query,'y')
    else
        return
    end
end

if tend > max(time)
    merr = ['ctd end time ' sprintf('%s',datestr(tend,31)) ' later than end of vmadcp data ' sprintf('%s',datestr(max(time),31))];
    fprintf(MEXEC_A.Mfider,'%s\n',merr)
    query = input('Type ''y'' to continue; anything else to exit ','s');
    if strcmp(query,'y')
    else
        return
    end
end

% times contained ok, find index of adcp times required

kok = find(time >=  tstart &  time <= tend);
if isempty(kok)
    merr = ['No ADCP data in file ' infile ' falls in time range of ' cast_string ' ' stn_string ];
    fprintf(MEXEC_A.Mfider,'%s\n',merr);
    return
end
colrange = [min(kok) max(kok)];

MEXEC_A.MARGS_IN = {
    infile
    otfile1
    '/'
    ' '
    ' '
    colrange
    ' '
    ' '
    };
mcopya


% fix dataname
MEXEC_A.MARGS_IN = {
    otfile1
    'y'
    '1'
    dataname
    ' '
    ' '
    };
mheadr


% average. Use time bin average as the time variable
MEXEC_A.MARGS_IN = {
    otfile1
    otfile2
    'f'
    'time'
    'c'
    '-1e10 1e10 2e10'
    'b'
    };
mavrge



