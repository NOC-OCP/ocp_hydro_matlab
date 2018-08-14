% mwin_03: merge winch wireout onto fir file
%
% Use: mwin_03        and then respond with station number, or for station 16
%      stn = 16; mwin_03;

scriptname = 'mwin_03';
minit
mdocshow(scriptname, ['adds winch data from bottle firing times to fir_' mcruise '_' stn_string '.nc']);

% resolve root directories for various file types
root_win = mgetdir('M_CTD_WIN');
root_ctd = mgetdir('M_CTD');

prefix1 = ['fir_' mcruise '_'];
prefix2 = ['win_' mcruise '_'];

infile1 = [root_ctd '/' prefix1 stn_string '_time'];
infile2 = [root_win '/' prefix2 stn_string];
otfile2 = [root_ctd '/' prefix1 stn_string '_winch'];

% scan input file to extract winch cable out variable name

cablook1 = 'cab'; % should match 'cablout' (techsas) or 'winch_cable_out' (scs) or 'cableout'
cablook2 = 'out'; % should match 'cablout' (techsas) or 'winch_cable_out' (scs) or 'cableout'
h_in = m_read_header(infile2);
kmat = [];
for kloopscr = 1:length(h_in.fldnam);
    kmat1 = findstr(h_in.fldnam{kloopscr},cablook1);
    kmat2 = findstr(h_in.fldnam{kloopscr},cablook2);
    if ~isempty(kmat1) & ~isempty(kmat2) %this variable matches both searches
        kmat = [kmat kloopscr];
    end
end
if isempty(kmat)
    m1 = ['No match for ''' cablook1 ' & ' cablook2 ''' as wireout variable in file '];
    m2 = [infile2];
    m3 = 'exiting';
    fprintf(MEXEC_A.Mfider,'%s\n',m1,m2,m3)
    cabname = ' ';
    return
elseif length(kmat) > 1
    m1 = ['More than one variable found whose name matches ''' cablook1 ' & ' cablook2 ''' in file'];
    m2 = [infile2];
    m3 = ' '; for kloopscr = 1:length(kmat); m3 = [m3 ' ' h_in.fldnam{kmat(kloopscr)}]; end
    m4 = ['Specify variable name here : '];
    fprintf(MEXEC_A.Mfider,'%s\n',m1,m2,m3)
    cabname = m_getinput(m4,'s');
else % just one match
    cabname = h_in.fldnam{kmat};
end

%--------------------------------
% 2009-01-26 12:12:35
% mmerge
% input files
% Filename fir_jr193_016_time.nc   Data Name :  fir_jr193_016 <version> 17 <site> bak_macbook
% Filename WINCH/win_jr193_016.nc   Data Name :  win19316 <version> 1 <site> pexec_jc
% output files
% Filename fir_jr193_016_winch.nc   Data Name :  fir_jr193_016 <version> 18 <site> bak_macbook
MEXEC_A.MARGS_IN = {

otfile2
infile1
'/'
'time'
infile2
'time'
cabname
'f'
};
mmerge
%--------------------------------

%--------------------------------
% 2009-01-26 12:12:36
% mheadr
% input files
% Filename fir_jr193_016_winch.nc   Data Name :  fir_jr193_016 <version> 18 <site> bak_macbook
% output files
% Filename fir_jr193_016_winch.nc   Data Name :  fir_jr193_016 <version> 19 <site> bak_macbook
MEXEC_A.MARGS_IN = {
otfile2
'y'
'8'
cabname
'wireout'
'metres'
'-1'
'-1'
};
mheadr
%--------------------------------

get_cropt; %fix_string

if isempty(fix_string); return; end

% bak on jr302 jun 2014: fix some wireouts not captured in SCS
%--------------------------------
% 2014-06-22 17:16:01
% mcalib
% calling history, most recent first
%    mcalib in file: mcalib.m line: 91
% input files
% Filename fir_jr302_065_winch.nc   Data Name :  fir_jr302_065_bl <version> 10 <site> jr302_atsea
% output files
% Filename fir_jr302_065_winch.nc   Data Name :  fir_jr302_065_bl <version> 11 <site> jr302_atsea
MEXEC_A.MARGS_IN = {
otfile2
'y'
'wireout'
fix_string
' '
' '
' '
};
mcalib
%--------------------------------

