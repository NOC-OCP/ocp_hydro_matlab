function mday_02(varargin)
% function mday_02(mstarprefix,daynum)
%
% append daily file in directory determined by mstarprefix (using mgetdir
% to look up in MEXEC_G.MDIRLIST)
%
% char: mstarprefix is the prefix used in mstar filenames
% numeric: daynum is the day number 
%
% eg mday_02('gps',33)
% or
% eg mday_02('gps','33')

% arguments can be left blank so script will prompt the terminal
% arguments can be queued in MEXEC_A.MARGS_IN

m_common
m_margslocal
m_varargs

mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

m4 = 'Type name of mstar prefix for file names,           eg: gps   ';
mstarprefix = m_getinput(m4,'s');

m5 = 'Type day number of data to append,                   eg: 33   ';
reply = m_getinput(m5,'s');
cmd = ['daynum = ' reply ';']; eval(cmd);
day = daynum;

day_string = sprintf('%03d',daynum);
mdocshow(mfilename, ['appends ' mstarprefix '_' mcruise '_d' day_string '_edt.nc or _edt_av.nc to ' mstarprefix '_' mcruise '_01.nc']);

root_out = mgetdir(mstarprefix);
if exist(root_out,'dir') ~= 7
    % requested data stream/directory doesn't seem to exist
    m = ['Directory ' mstarprefix ' not found - skipping'];
    fprintf(MEXEC_A.Mfider,'%s\n',m);
    return
end

dataname = [mstarprefix '_' mcruise '_01'];
otfile = fullfile(mgetdir(mstarprefix), dataname);

apfile = fullfile(root_out, [dataname(1:end-2) 'd' day_string '_edt_av.nc']);
if ~exist(apfile,'file')
    apfile = fullfile(root_out, [dataname(1:end-2) 'd' day_string '_edt.nc']);
    if ~exist(apfile,'file')
        warning('None of the files proposed to append was found; no action');
        return
    end
end

%load data to be appended
[d,hnew] = mloadq(apfile,'/');

%headers
if exist(m_add_nc(otfile),'file')
    d0 = mload(otfile, 'time');
    if length(intersect(d.time,d0.time))>2 %in case 1 on each boundary?
        warning(['overwriting day ' day_string ' in appended file ' otfile]);
    end
end
hnew.comment = [];

%merge onto otfile
mfsave(otfile, d, hnew, '-merge', 'time');
