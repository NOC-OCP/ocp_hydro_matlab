% mcsetd M_SCRIPTS; root_scripts = MEXEC_G.MEXEC_CWD;

mcd M_CTD;
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

% some hardwiring from jc032 removed di346
root_scripts = [MEXEC_G.MEXEC_DATA_ROOT '/MEXEC.mexec_processing_scripts'];
% load([root_scripts '/cdfs'],'clog')
% load([root_scripts '/cdfs'])

% section = 'bc1'; % jc032
% section = 'bc2'; % jc032
% section = 'bc3'; % jc032
%  section = 'main';
% section = 'fc'; % di346
section = '24n'; % di346
section = 'labsouthshelf'; % jr302
section = 'labmain';
% section = 'a2a1all';
% section = 'arc'; % jr302
section = 'osnape'
% section = 'eel'
% section = 'lineb';
% section = 'linec';
section = 'jc159_24s';
% section = 'jc032_24s';
% section = 'jc032_ben';

%%%
 
% cmd = ['c = cdf_' section]; eval(cmd);
% cmd = ['c.ncfile.name = ''grid_' mcruise '_' section '''']; eval(cmd);
clear c
switch section
    case 'bc1'
        c.xlist = 'distrun';
        c.xax = [0 200];
        c.ntick(1) = 8;
        lower = [4000 1000]; tyl = 6;
        upper = [1200 0]; tyu = 6;
        c.ylist = 'press';
    case 'bc2'
        c.xlist = 'distrun';
        c.xax = [400 0];
        c.ntick(1) = 8;
        lower = [4000 1000]; tyl = 6;
        upper = [1200 0]; tyu = 6;
        c.ylist = 'press';
    case 'bc3'
        c.xlist = 'distrun';
        c.xax = [0 400];
        c.ntick(1) = 8;
        lower = [4000 1000]; tyl = 6;
        upper = [1200 0]; tyu = 6;
        c.ylist = 'press';
    case 'main'
        c.xlist = 'distrun';
        c.xax = [0 1200];
        c.xlist = 'longitude';
        c.xax = [-42 14];
        c.ntick(1) = 8;
        lower = [6000 1000]; tyl = 5;
        upper = [1200 0]; tyu = 6;
        c.ylist = 'press';
    case 'fc'
        c.xlist = 'distrun';
        c.xax = [0 100];
%         c.xlist = 'longitude';
%         c.xax = [-42 14];
        c.ntick(1) = 10;
        lower = [1000 800]; tyl = 4;
        upper = [800 0]; tyu = 8;
        c.ylist = 'press';
    case '24n'
%         c.xlist = 'distrun';
%         c.xax = [0 1500];
        c.xlist = 'longitude';
        c.xax = [-80 -10];
        c.ntick(1) = 7;
        lower = [6400 400]; tyl = 6;
        upper = [800 0]; tyu = 8;
        c.ylist = 'press';
    case 'a2a1all'
        cmd = ['c.ncfile.name1 = ''grid_' mcruise '_' 'labupper' '''']; eval(cmd);
        cmd = ['c.ncfile.name2 = ''grid_' mcruise '_' 'laball' '''']; eval(cmd);
        cmd = ['c.ncfile.name = ''grid_' mcruise '_' 'laball' '''']; eval(cmd);
        c.xlist = 'latitude';
        c.xax = [58.5 60.5];
        c.ntick(1) = 4;
        lower = [4000 500]; tyl = 7;
        upper = [500 0]; tyu = 5;
        c.ylist = 'press';
        c.labels = [0];
    case 'labmain'
        cmd = ['c.ncfile.name1 = ''grid_' mcruise '_' 'osnapwupper' '''']; eval(cmd);
        cmd = ['c.ncfile.name2 = ''grid_' mcruise '_' 'osnapwall' '''']; eval(cmd);
        cmd = ['c.ncfile.name = ''grid_' mcruise '_' 'osnapwall' '''']; eval(cmd);
        c.xlist = 'latitude';
        c.xax = [52 61];
        c.ntick(1) = 9;
        lower = [4000 500]; tyl = 7;
        upper = [500 0]; tyu = 5;
        c.ylist = 'press';
        c.labels = [0];
    case 'labsouthshelf'
        cmd = ['c.ncfile.name1 = ''grid_' mcruise '_' 'labupper' '''']; eval(cmd);
        cmd = ['c.ncfile.name2 = ''grid_' mcruise '_' 'laball' '''']; eval(cmd);
        cmd = ['c.ncfile.name = ''grid_' mcruise '_' 'laball' '''']; eval(cmd);
        c.xlist = 'latitude';
        c.xax = [52 53];
        c.ntick(1) = 4;
        lower = [4000 500]; tyl = 7;
        upper = [500 0]; tyu = 5;
        c.ylist = 'press';
        c.labels = [0];
    case {'linec'}
        cmd = ['c.ncfile.name1 = ''ctd_' mcruise '_' 'linecupper' '''']; eval(cmd);
        cmd = ['c.ncfile.name2 = ''ctd_' mcruise '_' 'linecall' '''']; eval(cmd);
        cmd = ['c.ncfile.name = ''ctd_' mcruise '_' 'linecall' '''']; eval(cmd);
        c.xlist = 'latitude';
        c.xax = [57.5 60.5];
        c.ntick(1) = 6;
        lower = [4000 500]; tyl = 7;
        upper = [500 0]; tyu = 5;
        c.ylist = 'press';
        c.labels = [0];
    case 'arc'
        cmd = ['c.ncfile.name1 = ''grid_' mcruise '_' 'arcupper' '''']; eval(cmd);
        cmd = ['c.ncfile.name2 = ''grid_' mcruise '_' 'arcall' '''']; eval(cmd);
        cmd = ['c.ncfile.name = ''grid_' mcruise '_' 'arcall' '''']; eval(cmd);
        c.xlist = 'longitude';
        c.xax = [-49 -35];
        c.ntick(1) = 7;
        lower = [4000 500]; tyl = 7;
        upper = [500 0]; tyu = 5;
        c.ylist = 'press';
        c.labels = [0];
    case 'osnape'
        cmd = ['c.ncfile.name1 = ''grid_' mcruise '_' 'osnapeupper' '''']; eval(cmd);
        cmd = ['c.ncfile.name2 = ''grid_' mcruise '_' 'osnapeall' '''']; eval(cmd);
        cmd = ['c.ncfile.name = ''grid_' mcruise '_' 'osnapeall' '''']; eval(cmd);
        c.xlist = 'longitude';
        c.xax = [-44 -4];
        c.ntick(1) = 10;
        lower = [4000 500]; tyl = 7;
        upper = [500 0]; tyu = 5;
        c.ylist = 'press';
        c.labels = [0];
    case 'eel'
        cmd = ['c.ncfile.name1 = ''grid_' mcruise '_' 'eelupper' '''']; eval(cmd);
        cmd = ['c.ncfile.name2 = ''grid_' mcruise '_' 'eelall' '''']; eval(cmd);
        cmd = ['c.ncfile.name = ''grid_' mcruise '_' 'eelall' '''']; eval(cmd);
        c.xlist = 'distrun';
        c.xax = [0 1250];
        c.ntick(1) = 5;
        lower = [4000 500]; tyl = 7;
        upper = [500 0]; tyu = 5;
        c.ylist = 'press';
        c.labels = [0];
    case 'jc159_24s'
        cmd = ['c.ncfile.name1 = ''grid_' mcruise '_' '24s' '''']; eval(cmd);
        cmd = ['c.ncfile.name2 = ''grid_' mcruise '_' '24s' '''']; eval(cmd);
        cmd = ['c.ncfile.name = ''grid_' mcruise '_' '24s' '''']; eval(cmd);
%         c.xlist = 'distrun';
%         c.xax = [0 1200];
        c.xlist = 'longitude';
        c.xax = [-42 14];
        c.ntick(1) = 8;
        lower = [6000 500]; tyl = 11;
        upper = [1000 0]; tyu = 5;
        c.ylist = 'press';
        c.labels = [0];
    case 'jc032_24s'
        cmd = ['c.ncfile.name1 = ''grid_' mcruise '_' '24s' '''']; eval(cmd);
        cmd = ['c.ncfile.name2 = ''grid_' mcruise '_' '24s' '''']; eval(cmd);
        cmd = ['c.ncfile.name = ''grid_' mcruise '_' '24s' '''']; eval(cmd);
        c.ncfile.name1 = '/local/users/pstar/jc032/jc032_fromship/ctd/grid_jc032_main.nc';
        c.ncfile.name2 = '/local/users/pstar/jc032/jc032_fromship/ctd/grid_jc032_main.nc';
        c.ncfile.name = '/local/users/pstar/jc032/jc032_fromship/ctd/grid_jc032_main.nc';
        %         c.xlist = 'distrun';
        %         c.xax = [0 1200];
        c.xlist = 'longitude';
        c.xax = [-42 14];
        c.ntick(1) = 8;
        lower = [6000 500]; tyl = 11;
        upper = [1000 0]; tyu = 5;
        c.ylist = 'press';
        c.labels = [0];

    case 'jc032_ben'
        cmd = ['c.ncfile.name1 = ''grid_' mcruise '_' '24s' '''']; eval(cmd);
        cmd = ['c.ncfile.name2 = ''grid_' mcruise '_' '24s' '''']; eval(cmd);
        cmd = ['c.ncfile.name = ''grid_' mcruise '_' '24s' '''']; eval(cmd);
        c.ncfile.name1 = '/local/users/pstar/jc032/jc032_fromship/ctd/grid_jc032_main.nc';
        c.ncfile.name2 = '/local/users/pstar/jc032/jc032_fromship/ctd/grid_jc032_main.nc';
        c.ncfile.name = '/local/users/pstar/jc032/jc032_fromship/ctd/grid_jc032_main.nc';
        %         c.xlist = 'distrun';
        %         c.xax = [0 1200];
        c.xlist = 'longitude';
        c.xax = [8 14];
        c.ntick(1) = 6;
        lower = [6000 500]; tyl = 11;
        upper = [1000 0]; tyu = 5;
        c.ylist = 'press';
        c.labels = [0];

        
    otherwise
end

csave = c;

plotlist = {'potemp' 'botoxy' 'totnit' 'dic' 'ctdoxy'};
plotlist = {'botoxy' 'totnit' 'ctdoxy' 'potemp'};
% plotlist = {'botoxy' 'totnit' 'ctdoxy' 'potemp' 'cfc11' 'f113' 'sf6'};
% plotlist = { 'botoxy' 'totnit' 'dic'};
plotlist = {'potemp' 'ctdoxy' 'botoxy' 'dic' 'totnit' 'cfc11' 'f113' 'sf6'};
% plotlist = {'sf6' };

if ~isempty(strmatch('dic',plotlist,'exact'))
    c = csave;
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    
    c.newfigure = 'l';
    c.zlist = 'alk';
    c.plotorg = [2.5 1.5]; c.plotsize = [9 7];
    c.yax = lower; c.ntick(2) = tyl;
    c.ncfile.name = c.ncfile.name2;
    c.ytickset = '''fontsize'',14';
    c.xtickset = '''fontsize'',10';
    c.titleset = 'none';
    c.filenameset = 'none';
    c.xlabelset = '''fontsize'',14';
    c.ylabelset = '''fontsize'',14';
    c.dateset = 'none';
    c = set_clev_col(c);
    c.widths = 1;
    c.colorbarheight = 12;
    c = mcontrnew(c);
    
    c.newfigure = 'none';
    c.plotorg = [2.5 9.5]; c.plotsize = [9 4];
    c.ctabskip = 0;
    c.yax = upper; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''Total Alkalinity'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c);
    
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    if isfield(c,'colorbarset'); c = rmfield(c,'colorbarset'); end
    
    c.newfigure = 'none';
    c.zlist = 'dic';
    c.plotorg = [15.5 1.5]; c.plotsize = [9 7];
    c.yax = lower; c.ntick(2) = tyl;
    c.ncfile.name = c.ncfile.name2;
    c.ytickset = '''fontsize'',14';
    c.xtickset = '''fontsize'',10';
    c.titleset = 'none';
    c.filenameset = 'none';
    c.xlabelset = '''fontsize'',14';
    c.ylabelset = '''fontsize'',14';
    c.ylabelset = 'none';
    c.dateset = 'none';
    c = set_clev_col(c);
    c.ctabskip = 1;
    c = mcontrnew(c);
    
    c.newfigure = 'none';
    c.plotorg = [15.5 9.5]; c.plotsize = [9 4];
    c.ctabskip = 0;
    c.yax = upper; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''DIC'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c);    
    
    cmd = ['print -dpsc ' section '_co2.ps']; eval(cmd);
    
    
end

if ~isempty(strmatch('botoxy',plotlist,'exact'))
    
    %-------------
    % botoxy and silc
    c = csave;
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    
    c.newfigure = 'l';
    c.zlist = 'botoxy';
    c.plotorg = [2.5 1.5]; c.plotsize = [9 7];
    c.yax = lower; c.ntick(2) = tyl;
    c.ncfile.name = c.ncfile.name2;
    c.ytickset = '''fontsize'',14';
    c.xtickset = '''fontsize'',10';
    c.titleset = 'none';
    c.filenameset = 'none';
    c.xlabelset = '''fontsize'',14';
    c.ylabelset = '''fontsize'',14';
    c.dateset = 'none';
    c = set_clev_col(c);
    c.widths = 1;
    c.colorbarheight = 12;
    c = mcontrnew(c);
    
    c.newfigure = 'none';
    c.plotorg = [2.5 9.5]; c.plotsize = [9 4];
    c.ctabskip = 0;
    c.yax = upper; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''Bottle oxygen'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c)
    
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    if isfield(c,'colorbarset'); c = rmfield(c,'colorbarset'); end
    
    c.newfigure = 'none';
    c.zlist = 'silc';
    c.plotorg = [15.5 1.5]; c.plotsize = [9 7];
    c.yax = lower; c.ntick(2) = tyl;
    c.ncfile.name = c.ncfile.name2;
    c.ytickset = '''fontsize'',14';
    c.xtickset = '''fontsize'',10';
    c.titleset = 'none';
    c.filenameset = 'none';
    c.xlabelset = '''fontsize'',14';
    c.ylabelset = '''fontsize'',14';
    c.ylabelset = 'none';
    c.dateset = 'none';
    c = set_clev_col(c);
    c.ctabskip = 1;
    c = mcontrnew(c);
    
    c.newfigure = 'none';
    c.plotorg = [15.5 9.5]; c.plotsize = [9 4];
    c.ctabskip = 0;
    c.yax = upper; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''Silicate (umol/kg)'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c)
    
    
    cmd = ['print -dpsc ' section '_ox_silc.ps']; eval(cmd);
end

if ~isempty(strmatch('totnit',plotlist,'exact'))
    %-------------
    % totnit and phos
    c = csave;
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    
    c.newfigure = 'l';
    c.zlist = 'totnit';
    c.plotorg = [2.5 1.5]; c.plotsize = [9 7];
    c.yax = lower; c.ntick(2) = tyl;
    c.ncfile.name = c.ncfile.name2;
    c.ytickset = '''fontsize'',14';
    c.xtickset = '''fontsize'',10';
    c.titleset = 'none';
    c.filenameset = 'none';
    c.xlabelset = '''fontsize'',14';
    c.ylabelset = '''fontsize'',14';
    c.dateset = 'none';
    c = set_clev_col(c);
    c.widths = 1;
    c.colorbarheight = 12;
    c = mcontrnew(c);
    
    c.newfigure = 'none';
    c.plotorg = [2.5 9.5]; c.plotsize = [9 4];
    c.ctabskip = 0;
    c.yax = upper; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''NO2+NO3'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c);
    
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    if isfield(c,'colorbarset'); c = rmfield(c,'colorbarset'); end
    
    c.newfigure = 'none';
    c.zlist = 'phos';
    c.plotorg = [15.5 1.5]; c.plotsize = [9 7];
    c.yax = lower; c.ntick(2) = tyl;
    c.ncfile.name = c.ncfile.name2;
    c.ytickset = '''fontsize'',14';
    c.xtickset = '''fontsize'',10';
    c.titleset = 'none';
    c.filenameset = 'none';
    c.xlabelset = '''fontsize'',14';
    c.ylabelset = '''fontsize'',14';
    c.ylabelset = 'none';
    c.dateset = 'none';
    c = set_clev_col(c);
    c.ctabskip = 1;
    c = mcontrnew(c);
    
    c.newfigure = 'none';
    c.plotorg = [15.5 9.5]; c.plotsize = [9 4];
    c.ctabskip = 0;
    c.yax = upper; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''Phosphate'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c);    
    
    cmd = ['print -dpsc ' section '_totnit_phos.ps']; eval(cmd);
    
    
end

if ~isempty(strmatch('potemp',plotlist,'exact'))
    %-------------
    % CTD temp and psal
    c = csave;
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    
    c.newfigure = 'l';
    c.zlist = 'potemp';
    c.plotorg = [2.5 1.5]; c.plotsize = [9 7];
    c.yax = lower; c.ntick(2) = tyl;
    c.ncfile.name = c.ncfile.name2;
    c.ytickset = '''fontsize'',14';
    c.xtickset = '''fontsize'',10';
    c.titleset = 'none';
    c.filenameset = 'none';
    c.xlabelset = '''fontsize'',14';
    c.ylabelset = '''fontsize'',14';
    c.dateset = 'none';
    c = set_clev_col(c);
    c.widths = 1;
    c.colorbarheight = 12;
    c = mcontrnew(c);
    
    c.newfigure = 'none';
    c.plotorg = [2.5 9.5]; c.plotsize = [9 4];
    c.ctabskip = 0;
    c.yax = upper; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''Potential temperature'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c);
    
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    if isfield(c,'colorbarset'); c = rmfield(c,'colorbarset'); end
    
    c.newfigure = 'none';
    c.zlist = 'psal';
    c.plotorg = [15.5 1.5]; c.plotsize = [9 7];
    c.yax = lower; c.ntick(2) = tyl;
    c.ncfile.name = c.ncfile.name2;
    c.ytickset = '''fontsize'',14';
    c.xtickset = '''fontsize'',10';
    c.titleset = 'none';
    c.filenameset = 'none';
    c.xlabelset = '''fontsize'',14';
    c.ylabelset = '''fontsize'',14';
    c.ylabelset = 'none';
    c.dateset = 'none';
    c = set_clev_col(c);
    c.ctabskip = 1;
    c = mcontrnew(c);
    
    c.newfigure = 'none';
    c.plotorg = [15.5 9.5]; c.plotsize = [9 4];
    c.ctabskip = 0;
    c.yax = upper; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''Practical Salinity'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c);
    
    
    cmd = ['print -dpsc ' section '_potemp_psal.ps']; eval(cmd);
end

if ~isempty(strmatch('ctdoxy',plotlist,'exact'))
    %-------------
    % CTD oxygen and fluor
    c = csave;
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    
    c.newfigure = 'l';
    c.zlist = 'oxygen';
    c.plotorg = [2.5 1.5]; c.plotsize = [9 7];
    c.yax = lower; c.ntick(2) = tyl;
    c.ncfile.name = c.ncfile.name2;
    c.ytickset = '''fontsize'',14';
    c.xtickset = '''fontsize'',10';
    c.titleset = 'none';
    c.filenameset = 'none';
    c.xlabelset = '''fontsize'',14';
    c.ylabelset = '''fontsize'',14';
    c.dateset = 'none';
    c = set_clev_col(c);
    c.widths = 1;
    c.colorbarheight = 12;
    c = mcontrnew(c);
    
    c.newfigure = 'none';
    c.plotorg = [2.5 9.5]; c.plotsize = [9 4];
    c.ctabskip = 0;
    c.yax = upper; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''Oxygen (umol/kg)'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c)
    
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    if isfield(c,'colorbarset'); c = rmfield(c,'colorbarset'); end
    
    c.newfigure = 'none';
    c.zlist = 'fluor';
    c.plotorg = [15.5 1.5]; c.plotsize = [9 7];
    c.yax = lower; c.ntick(2) = tyl;
    c.ncfile.name = c.ncfile.name2;
    c.ytickset = '''fontsize'',14';
    c.xtickset = '''fontsize'',10';
    c.titleset = 'none';
    c.filenameset = 'none';
    c.xlabelset = '''fontsize'',14';
    c.ylabelset = '''fontsize'',14';
    c.ylabelset = 'none';
    c.dateset = 'none';
    c = set_clev_col(c);
    c.ctabskip = 1;
    c = mcontrnew(c);
    
    c.newfigure = 'none';
    c.plotorg = [15.5 9.5]; c.plotsize = [9 4];
    c.ctabskip = 0;
    c.yax = upper; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''Fluor (raw)'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c)
    
    
    cmd = ['print -dpsc ' section '_ctdoxy_fluor.ps']; eval(cmd);
end

if ~isempty(strmatch('cfc11',plotlist,'exact'))
    %-------------
    % CTD cfc11 cfc12
    c = csave;
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    
    c.newfigure = 'l';
    c.zlist = 'cfc11';
    c.plotorg = [2.5 1.5]; c.plotsize = [9 7];
    c.yax = lower; c.ntick(2) = tyl;
    c.ncfile.name = c.ncfile.name2;
    c.ytickset = '''fontsize'',14';
    c.xtickset = '''fontsize'',10';
    c.titleset = 'none';
    c.filenameset = 'none';
    c.xlabelset = '''fontsize'',14';
    c.ylabelset = '''fontsize'',14';
    c.dateset = 'none';
    c = set_clev_col(c);
    c.widths = 1;
    c.colorbarheight = 12;
    c = mcontrnew(c);
    
    c.newfigure = 'none';
    c.plotorg = [2.5 9.5]; c.plotsize = [9 4];
    c.ctabskip = 0;
    c.yax = upper; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''CFC11 (pmol/kg)'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c)
    
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    if isfield(c,'colorbarset'); c = rmfield(c,'colorbarset'); end
    
    c.newfigure = 'none';
    c.zlist = 'cfc12';
    c.plotorg = [15.5 1.5]; c.plotsize = [9 7];
    c.yax = lower; c.ntick(2) = tyl;
    c.ncfile.name = c.ncfile.name2;
    c.ytickset = '''fontsize'',14';
    c.xtickset = '''fontsize'',10';
    c.titleset = 'none';
    c.filenameset = 'none';
    c.xlabelset = '''fontsize'',14';
    c.ylabelset = '''fontsize'',14';
    c.ylabelset = 'none';
    c.dateset = 'none';
    c = set_clev_col(c);
    c.ctabskip = 1;
    c = mcontrnew(c);
    
    c.newfigure = 'none';
    c.plotorg = [15.5 9.5]; c.plotsize = [9 4];
    c.ctabskip = 0;
    c.yax = upper; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''CFC 12 (pmol/kg)'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c)
    
    cmd = ['print -dpsc ' section '_cfc11_cfc12.ps']; eval(cmd);
end

if ~isempty(strmatch('f113',plotlist,'exact'))
    %-------------
    % CTD f113 and ccl4
    c = csave;
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    
    c.newfigure = 'l';
    c.zlist = 'f113';
    c.plotorg = [2.5 1.5]; c.plotsize = [9 7];
    c.yax = lower; c.ntick(2) = tyl;
    c.ncfile.name = c.ncfile.name2;
    c.ytickset = '''fontsize'',14';
    c.xtickset = '''fontsize'',10';
    c.titleset = 'none';
    c.filenameset = 'none';
    c.xlabelset = '''fontsize'',14';
    c.ylabelset = '''fontsize'',14';
    c.dateset = 'none';
    c = set_clev_col(c);
    c.widths = 1;
    c.colorbarheight = 12;
    c = mcontrnew(c);
    
    c.newfigure = 'none';
    c.plotorg = [2.5 9.5]; c.plotsize = [9 4];
    c.ctabskip = 0;
    c.yax = upper; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''CFC113 (pmol/kg)'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c)
    
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    if isfield(c,'colorbarset'); c = rmfield(c,'colorbarset'); end
    
    c.newfigure = 'none';
    c.zlist = 'ccl4';
    c.plotorg = [15.5 1.5]; c.plotsize = [9 7];
    c.yax = lower; c.ntick(2) = tyl;
    c.ncfile.name = c.ncfile.name2;
    c.ytickset = '''fontsize'',14';
    c.xtickset = '''fontsize'',10';
    c.titleset = 'none';
    c.filenameset = 'none';
    c.xlabelset = '''fontsize'',14';
    c.ylabelset = '''fontsize'',14';
    c.ylabelset = 'none';
    c.dateset = 'none';
    c = set_clev_col(c);
    c.ctabskip = 1;
    c = mcontrnew(c);
    
    c.newfigure = 'none';
    c.plotorg = [15.5 9.5]; c.plotsize = [9 4];
    c.ctabskip = 0;
    c.yax = upper; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''CCl4 (pmol/kg)'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c)
    
    cmd = ['print -dpsc ' section '_f113_ccl4.ps']; eval(cmd);
end

if ~isempty(strmatch('sf6',plotlist,'exact'))
    %-------------
    % CTD SF6
    c = csave;
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    
    c.newfigure = 'l';
    c.zlist = 'sf6';
    c.plotorg = [2.5 1.5]; c.plotsize = [9 7];
    c.yax = lower; c.ntick(2) = tyl;
    c.ncfile.name = c.ncfile.name2;
    c.ytickset = '''fontsize'',14';
    c.xtickset = '''fontsize'',10';
    c.titleset = 'none';
    c.filenameset = 'none';
    c.xlabelset = '''fontsize'',14';
    c.ylabelset = '''fontsize'',14';
    c.dateset = 'none';
    c = set_clev_col(c);
    c.widths = 1;
    c.colorbarheight = 12;
    c = mcontrnew(c);
    
    c.newfigure = 'none';
    c.plotorg = [2.5 9.5]; c.plotsize = [9 4];
    c.ctabskip = 0;
    c.yax = upper; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''SF6 (pmol/kg)'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c)
    
%     if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
%     if isfield(c,'colorbarset'); c = rmfield(c,'colorbarset'); end
%     
%     c.newfigure = 'none';
%     c.zlist = 'ccl4';
%     c.plotorg = [15.5 1.5]; c.plotsize = [9 7];
%     c.yax = lower; c.ntick(2) = tyl;
%     c.ncfile.name = c.ncfile.name2;
%     c.ytickset = '''fontsize'',14';
%     c.xtickset = '''fontsize'',10';
%     c.titleset = 'none';
%     c.filenameset = 'none';
%     c.xlabelset = '''fontsize'',14';
%     c.ylabelset = '''fontsize'',14';
%     c.ylabelset = 'none';
%     c.dateset = 'none';
%     c = set_clev_col(c);
%     c.ctabskip = 1;
%     c = mcontrnew(c);
%     
%     c.newfigure = 'none';
%     c.plotorg = [15.5 9.5]; c.plotsize = [9 4];
%     c.ctabskip = 0;
%     c.yax = upper; c.ntick(2) = tyu;
%     c.ncfile.name = c.ncfile.name1;
%     c.xtickset = 'none';
%     c.filenameset = 'none';
%     c.xlabelset = 'none';
%     c.ylabelset = 'none';
%     c.colorbarset = 'none';
%     c.titleset = '''string'',''CCl4 (pmol/kg)'',''fontsize'',12,''fontweight'',''bold''';
%     c = mcontrnew(c)
    
    cmd = ['print -dpsc ' section '_sf6.ps']; eval(cmd);
end

%-------------
% tn and tp

% if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
% 
% c.newfigure = 'l';
% c.plotorg = [2.5 1.5]; c.plotsize = [9 7];
% c.zlist = 'tn';
% c.clev = [0:2:40];
% c.yax = lower; c.ntick(2) = tyl;
% c = mcontrnew(c)
% 
% c.newfigure = 'none';
% c.plotorg = [2.5 10]; c.plotsize = [9 4];
% c.ctabskip = 0;
% c.yax = upper; c.ntick(2) = tyu;
% c = mcontrnew(c)
% 
% if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
% 
% c.newfigure = 'none';
% c.plotorg = [15.5 1.5]; c.plotsize = [9 7];
% c.zlist = 'tp';
% c.clev = [0:.2:3];
% c.yax = lower; c.ntick(2) = tyl;
% c = mcontrnew(c)
% 
% c.newfigure = 'none';
% c.plotorg = [15.5 10]; c.plotsize = [9 4];
% c.ctabskip = 0;
% c.yax = upper; c.ntick(2) = tyu;
% c = mcontrnew(c)
% 
% 
% cmd = ['print -dpsc ' section '_tn_tp.ps']; eval(cmd);

%-------------
% don and dop

% if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
% 
% c.newfigure = 'l';
% c.plotorg = [2.5 1.5]; c.plotsize = [9 7];
% c.zlist = 'don';
% c.clev = [0:.5:10];
% c.yax = lower; c.ntick(2) = tyl;
% c = mcontrnew(c)
% 
% c.newfigure = 'none';
% c.plotorg = [2.5 10]; c.plotsize = [9 4];
% c.ctabskip = 0;
% c.yax = upper; c.ntick(2) = tyu;
% c = mcontrnew(c)
% 
% if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
% 
% c.newfigure = 'none';
% c.plotorg = [15.5 1.5]; c.plotsize = [9 7];
% c.zlist = 'dop';
% c.clev = [0:.01:.15];
% c.yax = lower; c.ntick(2) = tyl;
% c = mcontrnew(c)
% 
% c.newfigure = 'none';
% c.plotorg = [15.5 10]; c.plotsize = [9 4];
% c.ctabskip = 0;
% c.yax = upper; c.ntick(2) = tyu;
% c = mcontrnew(c)
% 
% 
% cmd = ['print -dpsc ' section '_don_dop.ps']; eval(cmd);

