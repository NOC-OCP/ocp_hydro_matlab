% mcod_03
% gdm on di346 edited to run as a script for convenience
% 'os' is specified to work for 75 or 150; and directorys are also resolved
% automatically
% high level script to split out on station data
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

scriptname = 'mcod_03';

if exist('cast','var')
    m = ['Running script ' scriptname ' on cast type ' sprintf('%s',cast)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    cast = input('type cast type ','s');
end
castlocal = cast; clear cast; % so it doesnt persist
cast_string = sprintf('%s',castlocal);

if exist('stn','var')
    m = ['Running script ' scriptname ' on station ' sprintf('%03d',stn)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    stn = input('type stn number ');
end
stnlocal = stn; clear stn; % so it doesnt persist
stn_string = sprintf('%03d',stnlocal);

if exist('os','var')
    m = ['Running script ' scriptname ' for OS ' sprintf('%d',os)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    os = input('Enter OS type: 75 or 150 ');
end
oslocal = os; clear os; % so it doesnt persist

root_ctd = mgetdir('M_CTD');
root_vmadcp = mgetdir('M_VMADCP');

cmd=['cd ' MEXEC_G.MSCRIPT_CRUISE_STRING '_os' sprintf('%d',oslocal)];eval(cmd);

infile=['os' sprintf('%d',oslocal) '_' MEXEC_G.MSCRIPT_CRUISE_STRING 'nnx_01'];

% construct output filename; 
% previous code did some fancy stuff using strtok; this does the same.
klastus = max(strfind(infile,'_'));
prefix = infile(1:klastus);
infile2 = [root_vmadcp '/mcod_03_times'];
otfile1 = [prefix cast_string '_' stn_string];
otfile2 = [prefix cast_string '_' stn_string '_ave'];

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
                m3 = ['end time   ' datestr(tstart,31)];
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




%--------------------------------

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
%--------------------------------
% gdm on di346 edited to fix up the dataname for the new variable 
%--------------------------------
% 2010-01-17 06:20:25
% mheadr
% calling history, most recent first
%    mheadr in file: mheadr.m line: 49
% input files
% Filename os75_di346nnx_007.nc   Data Name :  os75_di346nnx_01 <version> 7 <site> di346_atsea
% output files
% Filename os75_di346nnx_007.nc   Data Name :  os75_di346nnx_007 <version> 1 <site> di346_atsea

MEXEC_A.MARGS_IN = {
otfile1
'y'
'1'
otfile1
' '
' '
};
mheadr
%--------------------------------


% average. Use time bin average as the time variable
%--------------------------------
% 2012-02-04 14:51:42
% mavrge
% calling history, most recent first
%    mavrge in file: mavrge.m line: 324
% input files
% Filename os75_jc069nnx_stn001.nc   Data Name :  os150_jc069nnx_01 <version> 8 <site> jc069_atsea
% output files
% Filename gash.nc   Data Name :  os150_jc069nnx_01 <version> 13 <site> jc069_atsea
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
%--------------------------------


