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
mdocshow(mfilename, ['appends ' mstarprefix '_' mcruise '_d' day_string '_edt.nc to ' mstarprefix '_' mcruise '_01.nc']);

root_out = mgetdir(mstarprefix);
if exist(root_out,'dir') ~= 7
    % requested data stream/directory doesn't seem to exist
    m = ['Directory ' mstarprefix ' not found - skipping'];
    fprintf(MEXEC_A.Mfider,'%s\n',m);
    return
end

dataname = [mstarprefix '_' mcruise '_01'];

apfile = [root_out '/' dataname(1:end-2) 'd' day_string '.nc'];
if ~exist(apfile,'file')
    apfile = [root_out '/' dataname(1:end-2) 'd' day_string '_edt.nc'];
    if ~exist(apfile,'file')
        apfile = [root_out '/' dataname(1:end-2) 'd' day_string '_raw.nc'];
        error('None of the files proposed to append was found; no action');
    end
end

%load data
[d,h] = mload(apfile,'/');

%headers
if exist(otfile,'file')
    hnew.fldnam = h.fldnam; hnew.fldunt = h.fldunt; hnew.comment = h.comment;
    d0 = mload(otfile, 'time');
    if length(intersect(d.time,d0.time))>2 %in case 1 on each boundary?
        warning(['overwriting day ' daynum ' in appended file ' otfile]);
    end
else
    hnew = h; 
end
hnew.dataname = dataname;

%merge onto otfile
mfsave(otfile, d, hnew, '-merge', 'time');
