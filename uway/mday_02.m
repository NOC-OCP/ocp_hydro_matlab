function mday_02(varargin)
% function mday_02(M_OUT,mstarprefix,daynum)
%
% append daily file in directory M_OUT
%
% char: M_OUT is the output directory, identified by abbreviation in m_setup
% char: mstarprefix is the prefix used in mstar filenames
% numeric: daynum is the day number 
%
% eg mday_02('M_GPS','gps',33)
% or
% eg mday_02('M_GPS','gps','33')

% arguments can be left blank so script will prompt the terminal
% arguments can be queued in MEXEC_A.MARGS_IN

m_common
m_margslocal
m_varargs

scriptname = 'mday_02';
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

m1 = 'Type name of output directory abbreviation,       eg; M_GPS   ';
reply = m_getinput(m1,'s');
MEXEC_A.MARGS_IN_LOCAL_OLD = MEXEC_A.MARGS_IN_LOCAL;
root_dir = mgetdir(reply);
MEXEC_A.MARGS_IN_LOCAL = MEXEC_A.MARGS_IN_LOCAL_OLD;
M_OUT = reply;

m4 = 'Type name of mstar prefix for file names,           eg: gps   ';
mstarprefix = m_getinput(m4,'s');

m5 = 'Type day number of data to append,                   eg: 33   ';
reply = m_getinput(m5,'s');
cmd = ['daynum = ' reply ';']; eval(cmd);
day = daynum;

day_string = sprintf('%03d',daynum);
mdocshow(scriptname, ['appends ' mstarprefix '_' mcruise '_d' day_string '_edt.nc to ' mstarprefix '_' mcruise '_01.nc']);

root_out = mgetdir(M_OUT);
if exist(root_out,'dir') ~= 7
    % requested data stream/directory doesn't seem to exist
    m = ['Directory ' M_OUT ' not found - skipping'];
    fprintf(MEXEC_A.Mfider,'%s\n',m);
    return
end

prefix1 = [mstarprefix '_' mcruise '_'];
infile1 = [root_out '/' prefix1 '01'];
infile2 = [root_out '/' prefix1 'd' day_string];
infile3 = [root_out '/' prefix1 'd' day_string '_edt'];
infile4 = [root_out '/' prefix1 'd' day_string '_raw'];
wkfile = ['wk_' scriptname '_' datestr(now,30)];

apfilename = infile2;
if ~exist(m_add_nc(apfilename),'file')
    apfilename = infile3;
    if ~exist( m_add_nc(apfilename),'file')
        apfilename = infile4;
        if ~exist( m_add_nc(apfilename),'file')
            m = 'None of the possible files propose to append was found';
            m2 = infile2;
            m3 = infile3;
            m4 = infile4;
            fprintf(MEXEC_A.Mfider,'%s\n','',m,m2,m3,m4)
            return
    
       end
    end
end

dataname = [prefix1 '01'];

%YLF added jr17001 to check for row vs column vector
[d,h] = mload(apfilename,'/'); s = size(d.time);
if s(1)==1; vdir = 'r'; else; vdir = 'c'; end

MEXEC_A.MARGS_IN_1 = {
   wkfile
   dataname
   't'
};
MEXEC_A.MARGS_IN_2 = {
   infile1 % current accumulated file. This is first file offered to mapend unless the file doesn't exist
   apfilename
   ''
};
if ~exist(m_add_nc(infile1),'file')
    MEXEC_A.MARGS_IN_2(1) = []; % can't offer infile1 first if it doesn't exist.
end
MEXEC_A.MARGS_IN_3 = {
   '/'
   vdir
};
MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN_1 ; MEXEC_A.MARGS_IN_2 ; MEXEC_A.MARGS_IN_3];
mapend

unix(['/bin/mv ' m_add_nc(wkfile) ' ' m_add_nc(infile1)]);


