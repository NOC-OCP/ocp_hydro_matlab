% mcsetd M_SCRIPTS; root_scripts = MEXEC_G.MEXEC_CWD;

scriptname = 'msec_plot_contrs'; % bak jc191 so can control adding things in cropt
mcd M_CTD;

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
section = '24n'; %dy040
% section = 'fs27n'; %dy040
% section = 'fs27n2'; %dy040
section = 'sr1b'; % jc211

%%%
 
% cmd = ['c = cdf_' section]; eval(cmd);
% cmd = ['c.ncfile.name = ''grid_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' section '''']; eval(cmd);
clear c
c.section = section; % bak jc191 use this field to pass into set_clev_col to enable cruise option control of contours per section
% bak jc191: control plot sizes from the section switch for all plots
% set defaults first. loplot1 is 1 per page; loplot2 is 2 per page etc
% can adjust in cruise opts

loplot1.org = [3 2]; % 1 per page, lower and upper
loplot1.size = [13.5 16.5];
upplot1.org = [3 19.5];
upplot1.size = [13.5 7];
loplot1.org = [3 2]; % 1 per page, lower and upper
loplot1.size = [13.5 9.5];
upplot1.org = [3 12.5];
upplot1.size = [13.5 3];

loplot2l.org = [2.5 1.5]; % 2 per page, left plots, lower and upper
upplot2l.org = [2.5 9.5];
loplot2r.org = [15.5 1.5]; % 2 per page, right plots, lower and upper
upplot2r.org = [15.5 9.5];
loplot2.size = [9 7];
upplot2.size = [9 4];



switch section
    case 'bc1'
        c.xlist = 'distrun';
        c.xax = [0 200];
        c.ntick(1) = 8;
        lolim = [4000 1000]; tyl = 6;
        uplim = [1200 0]; tyu = 6;
        c.ylist = 'press';
    case 'bc2'
        c.xlist = 'distrun';
        c.xax = [400 0];
        c.ntick(1) = 8;
        lolim = [4000 1000]; tyl = 6;
        uplim = [1200 0]; tyu = 6;
        c.ylist = 'press';
    case 'bc3'
        c.xlist = 'distrun';
        c.xax = [0 400];
        c.ntick(1) = 8;
        lolim = [4000 1000]; tyl = 6;
        uplim = [1200 0]; tyu = 6;
        c.ylist = 'press';
    case 'main'
        c.xlist = 'distrun';
        c.xax = [0 1200];
        c.xlist = 'longitude';
        c.xax = [-42 14];
        c.ntick(1) = 8;
        lolim = [6000 1000]; tyl = 5;
        uplim = [1200 0]; tyu = 6;
        c.ylist = 'press';
    case 'fc'
        c.xlist = 'distrun';
        c.xax = [0 100];
%         c.xlist = 'longitude';
%         c.xax = [-42 14];
        c.ntick(1) = 10;
        lolim = [1000 800]; tyl = 4;
        uplim = [800 0]; tyu = 8;
        c.ylist = 'press';
    case 'fs27n'
        cmd = ['c.ncfile.name1 = ''grid_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' 'fs27n' '''']; eval(cmd);
        cmd = ['c.ncfile.name2 = ''grid_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' 'fs27n' '''']; eval(cmd);
        cmd = ['c.ncfile.name = ''grid_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' 'fs27n' '''']; eval(cmd);
        c.xlist = 'longitude';
        c.xax = [-80 -79];
        c.ntick(1) = 5;
        lolim = [1000 0]; tyl = 5;
        uplim = [1000 0]; tyu = 5;
        c.ylist = 'press';
        c.labels = [0];
    case 'fs27n2'
        cmd = ['c.ncfile.name1 = ''ctd_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' 'fs27n2' '''']; eval(cmd);
        cmd = ['c.ncfile.name2 = ''ctd_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' 'fs27n2' '''']; eval(cmd);
        cmd = ['c.ncfile.name = ''ctd_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' 'fs27n2' '''']; eval(cmd);
        c.xlist = 'longitude';
        c.xax = [-80 -79];
        c.ntick(1) = 5;
        lolim = [6500 1000]; tyl = 11;
        uplim = [1000 0]; tyu = 8;
        c.ylist = 'press';
        c.labels = [0];
    case '24n'
        cmd = ['c.ncfile.name1 = ''grid_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' '24n' '''']; eval(cmd);
        cmd = ['c.ncfile.name2 = ''grid_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' '24n' '''']; eval(cmd);
        cmd = ['c.ncfile.name = ''grid_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' '24n' '''']; eval(cmd);
%         c.xlist = 'distrun';
%         c.xax = [0 1500];
        c.xlist = 'longitude';
        c.xax = [-80 -10];
        c.ntick(1) = 7;
        lolim = [6500 0]; tyl = 13;
        uplim = [1000 0]; tyu = 5;
        c.ylist = 'press';
        c.labels = [0];
    case 'a2a1all'
        cmd = ['c.ncfile.name1 = ''grid_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' 'labuplim' '''']; eval(cmd);
        cmd = ['c.ncfile.name2 = ''grid_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' 'laball' '''']; eval(cmd);
        cmd = ['c.ncfile.name = ''grid_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' 'laball' '''']; eval(cmd);
        c.xlist = 'latitude';
        c.xax = [58.5 60.5];
        c.ntick(1) = 4;
        lolim = [4000 500]; tyl = 7;
        uplim = [500 0]; tyu = 5;
        c.ylist = 'press';
        c.labels = [0];
    case 'labmain'
        cmd = ['c.ncfile.name1 = ''grid_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' 'osnapwuplim' '''']; eval(cmd);
        cmd = ['c.ncfile.name2 = ''grid_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' 'osnapwall' '''']; eval(cmd);
        cmd = ['c.ncfile.name = ''grid_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' 'osnapwall' '''']; eval(cmd);
        c.xlist = 'latitude';
        c.xax = [52 61];
        c.ntick(1) = 9;
        lolim = [4000 500]; tyl = 7;
        uplim = [500 0]; tyu = 5;
        c.ylist = 'press';
        c.labels = [0];
    case 'labsouthshelf'
        cmd = ['c.ncfile.name1 = ''grid_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' 'labuplim' '''']; eval(cmd);
        cmd = ['c.ncfile.name2 = ''grid_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' 'laball' '''']; eval(cmd);
        cmd = ['c.ncfile.name = ''grid_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' 'laball' '''']; eval(cmd);
        c.xlist = 'latitude';
        c.xax = [52 53];
        c.ntick(1) = 4;
        lolim = [4000 500]; tyl = 7;
        uplim = [500 0]; tyu = 5;
        c.ylist = 'press';
        c.labels = [0];
    case {'linec'}
        cmd = ['c.ncfile.name1 = ''ctd_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' 'linecuplim' '''']; eval(cmd);
        cmd = ['c.ncfile.name2 = ''ctd_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' 'linecall' '''']; eval(cmd);
        cmd = ['c.ncfile.name = ''ctd_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' 'linecall' '''']; eval(cmd);
        c.xlist = 'latitude';
        c.xax = [57.5 60.5];
        c.ntick(1) = 6;
        lolim = [4000 500]; tyl = 7;
        uplim = [500 0]; tyu = 5;
        c.ylist = 'press';
        c.labels = [0];
    case 'arc'
        cmd = ['c.ncfile.name1 = ''grid_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' 'arcuplim' '''']; eval(cmd);
        cmd = ['c.ncfile.name2 = ''grid_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' 'arcall' '''']; eval(cmd);
        cmd = ['c.ncfile.name = ''grid_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' 'arcall' '''']; eval(cmd);
        c.xlist = 'longitude';
        c.xax = [-49 -35];
        c.ntick(1) = 7;
        lolim = [4000 500]; tyl = 7;
        uplim = [500 0]; tyu = 5;
        c.ylist = 'press';
        c.labels = [0];
    case 'osnape'
        cmd = ['c.ncfile.name1 = ''grid_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' 'osnapeuplim' '''']; eval(cmd);
        cmd = ['c.ncfile.name2 = ''grid_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' 'osnapeall' '''']; eval(cmd);
        cmd = ['c.ncfile.name = ''grid_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' 'osnapeall' '''']; eval(cmd);
        c.xlist = 'longitude';
        c.xax = [-44 -4];
        c.ntick(1) = 10;
        lolim = [4000 500]; tyl = 7;
        uplim = [500 0]; tyu = 5;
        c.ylist = 'press';
        c.labels = [0];
    case 'eel'
        cmd = ['c.ncfile.name1 = ''grid_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' 'eeluplim' '''']; eval(cmd);
        cmd = ['c.ncfile.name2 = ''grid_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' 'eelall' '''']; eval(cmd);
        cmd = ['c.ncfile.name = ''grid_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' 'eelall' '''']; eval(cmd);
        c.xlist = 'distrun';
        c.xax = [0 1250];
        c.ntick(1) = 5;
        lolim = [4000 500]; tyl = 7;
        uplim = [500 0]; tyu = 5;
        c.ylist = 'press';
        c.labels = [0];
        
    case 'jc159_24s'
        cmd = ['c.ncfile.name1 = ''grid_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' '24s' '''']; eval(cmd);
        cmd = ['c.ncfile.name2 = ''grid_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' '24s' '''']; eval(cmd);
        cmd = ['c.ncfile.name = ''grid_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' '24s' '''']; eval(cmd);
        c.xlist = 'longitude';
        c.xax = [-42 14];
        c.ntick(1) = 8;
        lolim = [6000 500]; tyl = 11;
        uplim = [1000 0]; tyu = 5;
        c.ylist = 'press';
        c.labels = [0];
    case 'jc032_24s'
        cmd = ['c.ncfile.name1 = ''grid_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' '24s' '''']; eval(cmd);
        cmd = ['c.ncfile.name2 = ''grid_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' '24s' '''']; eval(cmd);
        cmd = ['c.ncfile.name = ''grid_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' '24s' '''']; eval(cmd);
        c.ncfile.name1 = '/local/users/pstar/jc032/jc032_fromship/ctd/grid_jc032_main.nc';
        c.ncfile.name2 = '/local/users/pstar/jc032/jc032_fromship/ctd/grid_jc032_main.nc';
        c.ncfile.name = '/local/users/pstar/jc032/jc032_fromship/ctd/grid_jc032_main.nc';
        c.xlist = 'longitude';
        c.xax = [-42 14];
        c.ntick(1) = 8;
        lolim = [6000 500]; tyl = 11;
        uplim = [1000 0]; tyu = 5;
        c.ylist = 'press';
        c.labels = [0];
        
    case 'jc032_ben'
        cmd = ['c.ncfile.name1 = ''grid_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' '24s' '''']; eval(cmd);
        cmd = ['c.ncfile.name2 = ''grid_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' '24s' '''']; eval(cmd);
        cmd = ['c.ncfile.name = ''grid_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' '24s' '''']; eval(cmd);
        c.ncfile.name1 = '/local/users/pstar/jc032/jc032_fromship/ctd/grid_jc032_main.nc';
        c.ncfile.name2 = '/local/users/pstar/jc032/jc032_fromship/ctd/grid_jc032_main.nc';
        c.ncfile.name = '/local/users/pstar/jc032/jc032_fromship/ctd/grid_jc032_main.nc';
        c.xlist = 'longitude';
        c.xax = [8 14];
        c.ntick(1) = 6;
        lolim = [6000 500]; tyl = 11;
        uplim = [1000 0]; tyu = 5;
        c.ylist = 'press';
        c.labels = [0];
        
    case 'sr1b'
        cmd = ['c.ncfile.name1 = ''ctd_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' 'sr1b' '''']; eval(cmd);
        cmd = ['c.ncfile.name2 = ''ctd_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' 'sr1b' '''']; eval(cmd);
        cmd = ['c.ncfile.name = ''ctd_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' 'sr1b' '''']; eval(cmd);
        c.xlist = 'latitude';
        c.xax = [-61 -54];
        c.ntick(1) = 7;
        lolim = [5000 0]; tyl = 10;
        uplim = [1000 0]; tyu = 5;
        c.ylist = 'press';
        c.labels = [0];
        
        
        
    otherwise
end

csave = c;

% plotlist = {'potemp' 'botoxy' 'totnit' 'dic' 'ctdoxy'};
% plotlist = {'botoxy' 'totnit' 'ctdoxy' 'potemp'};
% % plotlist = {'botoxy' 'totnit' 'ctdoxy' 'potemp' 'cfc11' 'f113' 'sf6'};
% % plotlist = { 'botoxy' 'totnit' 'dic'};
% plotlist = {'potemp' 'ctdoxy' 'botoxy' 'dic' 'totnit' 'cfc11' 'f113' 'ccl4'};
% plotlist = {'potemp' 'ctdoxy' 'botoxy' 'dic' 'totnit' 'cfc11' 'f113'};
% plotlist = {'cfc11' 'f113'};
% plotlist = {'potemp' 'botoxy' 'totnit' 'dic'};
plotlist = {'potemp1' 'psal1' 'ctdoxy1' 'botoxy1' 'silc1' 'totnit1' 'phos1' 'dic1' 'alk1' 'fluor1'  'potemp' 'botoxy' 'totnit' 'dic'};
plotlist = {'potemp1' 'psal1' 'ctdoxy1'};
% plotlist = {'potemp1' };
station_depth_width = 0;
bottle_depth_size = 0;
oopt = 'add_station_depths'; get_cropt;
oopt = 'add_bottle_depths'; get_cropt;

if ~isempty(strmatch('dic',plotlist,'exact'))
    c = csave;
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    
    c.newfigure = 'l';
    c.zlist = 'alk';
    c.plotorg = loplot2l.org; c.plotsize = loplot2.size;
    c.yax = lolim; c.ntick(2) = tyl;
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
    if (station_depth_width > 0); msec_add_station_depths; end
    if (bottle_depth_size > 0); msec_add_bottle_depths; end
    
    c.newfigure = 'none';
    c.plotorg = upplot2l.org; c.plotsize = upplot2.size;
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''JC211 SR1b Total Alkalinity (umol/kg)'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c);
    if (bottle_depth_size > 0); msec_add_bottle_depths; end
    
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    if isfield(c,'colorbarset'); c = rmfield(c,'colorbarset'); end
    
    c.newfigure = 'none';
    c.zlist = 'dic';
    c.plotorg = loplot2r.org; c.plotsize = loplot2.size;
    c.yax = lolim; c.ntick(2) = tyl;
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
    if (station_depth_width > 0); msec_add_station_depths; end
    if (bottle_depth_size > 0); msec_add_bottle_depths; end
    
    c.newfigure = 'none';
    c.plotorg = upplot2r.org; c.plotsize = upplot2.size;
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''JC211 SR1b DIC (umol/kg)'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c);    
    if (bottle_depth_size > 0); msec_add_bottle_depths; end
    
    cmd = ['print -dpsc ' section '_dic_alk.ps']; eval(cmd);
    cmd = ['print -dpng ' section '_dic_alk.png']; eval(cmd);
    
    
end

if ~isempty(strmatch('botoxy',plotlist,'exact'))
    
    %-------------
    % botoxy and silc
    c = csave;
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    
    c.newfigure = 'l';
    c.zlist = 'botoxy';
    c.plotorg = loplot2l.org; c.plotsize = loplot2.size;
    c.yax = lolim; c.ntick(2) = tyl;
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
    if (station_depth_width > 0); msec_add_station_depths; end
    if (bottle_depth_size > 0); msec_add_bottle_depths; end
    
    c.newfigure = 'none';
    c.plotorg = upplot2l.org; c.plotsize = upplot2.size;
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''JC211 SR1b Bottle oxygen (umol/kg)'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c);
    if (bottle_depth_size > 0); msec_add_bottle_depths; end
    
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    if isfield(c,'colorbarset'); c = rmfield(c,'colorbarset'); end
    
    c.newfigure = 'none';
    c.zlist = 'silc_per_kg';
    %c.zlist = 'silc';
    c.plotorg = loplot2r.org; c.plotsize = loplot2.size;
    c.yax = lolim; c.ntick(2) = tyl;
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
    if (station_depth_width > 0); msec_add_station_depths; end
    if (bottle_depth_size > 0); msec_add_bottle_depths; end
    
    c.newfigure = 'none';
    c.plotorg = upplot2r.org; c.plotsize = upplot2.size;
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''JC211 SR1b Silicate (umol/kg)'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c)
    if (bottle_depth_size > 0); msec_add_bottle_depths; end
    
    cmd = ['print -dpsc ' section '_ox_silc.ps']; eval(cmd);
    cmd = ['print -dpng ' section '_ox_silc.png']; eval(cmd);
end

if ~isempty(strmatch('totnit',plotlist,'exact'))
    %-------------
    % totnit and phos
    c = csave;
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    
    c.newfigure = 'l';
    c.zlist = 'totnit_per_kg';
    %c.zlist = 'totnit';
    c.plotorg = loplot2l.org; c.plotsize = loplot2.size;
    c.yax = lolim; c.ntick(2) = tyl;
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
    if (station_depth_width > 0); msec_add_station_depths; end
    if (bottle_depth_size > 0); msec_add_bottle_depths; end
    
    c.newfigure = 'none';
    c.plotorg = upplot2l.org; c.plotsize = upplot2.size;
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''JC211 SR1b NO2+NO3 (umol/kg)'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c);
    if (bottle_depth_size > 0); msec_add_bottle_depths; end
    
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    if isfield(c,'colorbarset'); c = rmfield(c,'colorbarset'); end
    
    c.newfigure = 'none';
    c.zlist = 'phos_per_kg';
    %c.zlist = 'phos';
    c.plotorg = loplot2r.org; c.plotsize = loplot2.size;
    c.yax = lolim; c.ntick(2) = tyl;
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
    if (station_depth_width > 0); msec_add_station_depths; end
    if (bottle_depth_size > 0); msec_add_bottle_depths; end
    
    c.newfigure = 'none';
    c.plotorg = upplot2r.org; c.plotsize = upplot2.size;
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''JC211 SR1b Phosphate (umol/kg)'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c);    
    if (bottle_depth_size > 0); msec_add_bottle_depths; end
    
    cmd = ['print -dpsc ' section '_totnit_phos.ps']; eval(cmd);
    cmd = ['print -dpng ' section '_totnit_phos.png']; eval(cmd);
    
    
end

if ~isempty(strmatch('potemp',plotlist,'exact'))
    %-------------
    % CTD temp and psal
    c = csave;
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    
    c.newfigure = 'l';
    c.zlist = 'potemp';
    c.plotorg = loplot2l.org; c.plotsize = loplot2.size;
    c.yax = lolim; c.ntick(2) = tyl;
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
    if (station_depth_width > 0); msec_add_station_depths; end
    
    c.newfigure = 'none';
    c.plotorg = upplot2l.org; c.plotsize = upplot2.size;
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''JC211 SR1b Potential temperature'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c);
    
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    if isfield(c,'colorbarset'); c = rmfield(c,'colorbarset'); end
    
    c.newfigure = 'none';
    c.zlist = 'psal';
    c.plotorg = loplot2r.org; c.plotsize = loplot2.size;
    c.yax = lolim; c.ntick(2) = tyl;
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
    if (station_depth_width > 0); msec_add_station_depths; end
    
    c.newfigure = 'none';
    c.plotorg = upplot2r.org; c.plotsize = upplot2.size;
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''JC211 SR1b Practical Salinity'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c);
    
    
    cmd = ['print -dpsc ' section '_potemp_psal.ps']; eval(cmd);
    cmd = ['print -dpng ' section '_potemp_psal.png']; eval(cmd);
end

if ~isempty(strmatch('ctdoxy',plotlist,'exact'))
    %-------------
    % CTD oxygen and fluor
    c = csave;
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    
    c.newfigure = 'l';
    c.zlist = 'oxygen';
    c.plotorg = loplot2l.org; c.plotsize = loplot2.size;
    c.yax = lolim; c.ntick(2) = tyl;
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
    if (station_depth_width > 0); msec_add_station_depths; end
    
    c.newfigure = 'none';
    c.plotorg = upplot2l.org; c.plotsize = upplot2.size;
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''JC211 SR1b CTD Oxygen (umol/kg)'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c);
    
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    if isfield(c,'colorbarset'); c = rmfield(c,'colorbarset'); end
    
    c.newfigure = 'none';
    c.zlist = 'fluor';
    c.plotorg = loplot2r.org; c.plotsize = loplot2.size;
    c.yax = lolim; c.ntick(2) = tyl;
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
    if (station_depth_width > 0); msec_add_station_depths; end

    c.newfigure = 'none';
    c.plotorg = upplot2r.org; c.plotsize = upplot2.size;
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''JC211 SR1b Fluor (raw)'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c);
    
    
    cmd = ['print -dpsc ' section '_ctdoxy_fluor.ps']; eval(cmd);
    cmd = ['print -dpng ' section '_ctdoxy_fluor.png']; eval(cmd);
end

if ~isempty(strmatch('cfc11',plotlist,'exact'))
    %-------------
    % CTD cfc11 cfc12
    c = csave;
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    
    c.newfigure = 'l';
    c.zlist = 'cfc11';
    c.plotorg = loplot2l.org; c.plotsize = loplot2.size;
    c.yax = lolim; c.ntick(2) = tyl;
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
    if (station_depth_width > 0); msec_add_station_depths; end
    if (bottle_depth_size > 0); msec_add_bottle_depths; end
    
    c.newfigure = 'none';
    c.plotorg = upplot2l.org; c.plotsize = upplot2.size;
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''JC211 SR1b CFC11 (pmol/kg)'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c);
    if (bottle_depth_size > 0); msec_add_bottle_depths; end
    
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    if isfield(c,'colorbarset'); c = rmfield(c,'colorbarset'); end
    
    c.newfigure = 'none';
    c.zlist = 'cfc12';
    c.plotorg = loplot2r.org; c.plotsize = loplot2.size;
    c.yax = lolim; c.ntick(2) = tyl;
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
    if (station_depth_width > 0); msec_add_station_depths; end
    if (bottle_depth_size > 0); msec_add_bottle_depths; end
    
    c.newfigure = 'none';
    c.plotorg = upplot2r.org; c.plotsize = upplot2.size;
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''JC211 SR1b CFC12 (pmol/kg)'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c)
    if (bottle_depth_size > 0); msec_add_bottle_depths; end
    
    cmd = ['print -dpsc ' section '_cfc11_cfc12.ps']; eval(cmd);
    cmd = ['print -dpng ' section '_cfc11_cfc12.png']; eval(cmd);
end

if ~isempty(strmatch('f113',plotlist,'exact'))
    %-------------
    % CTD f113 and sf6
    c = csave;
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    
    c.newfigure = 'l';
    c.zlist = 'f113';
    c.plotorg = loplot2l.org; c.plotsize = loplot2.size;
    c.yax = lolim; c.ntick(2) = tyl;
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
    if (station_depth_width > 0); msec_add_station_depths; end
    if (bottle_depth_size > 0); msec_add_bottle_depths; end
    
    c.newfigure = 'none';
    c.plotorg = upplot2l.org; c.plotsize = upplot2.size;
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''JC211 SR1b CFC113 (pmol/kg)'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c);
    if (bottle_depth_size > 0); msec_add_bottle_depths; end
    
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    if isfield(c,'colorbarset'); c = rmfield(c,'colorbarset'); end
    
    c.newfigure = 'none';
    c.zlist = 'sf6';
    c.plotorg = loplot2r.org; c.plotsize = loplot2.size;
    c.yax = lolim; c.ntick(2) = tyl;
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
    if (station_depth_width > 0); msec_add_station_depths; end
    if (bottle_depth_size > 0); msec_add_bottle_depths; end
    
    c.newfigure = 'none';
    c.plotorg = upplot2r.org; c.plotsize = upplot2.size;
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''JC211 SR1b SF6 (fmol/kg)'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c)
    if (bottle_depth_size > 0); msec_add_bottle_depths; end
    
    cmd = ['print -dpsc ' section '_f113_sf6.ps']; eval(cmd);
    cmd = ['print -dpng ' section '_f113_sf6.png']; eval(cmd);
end

if ~isempty(strmatch('ccl4',plotlist,'exact'))
    %-------------
    % CTD CCL4
    c = csave;
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    
    c.newfigure = 'l';
    c.zlist = 'ccl4';
    c.plotorg = loplot2l.org; c.plotsize = loplot2.size;
    c.yax = lolim; c.ntick(2) = tyl;
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
    if (station_depth_width > 0); msec_add_station_depths; end
    if (bottle_depth_size > 0); msec_add_bottle_depths; end
    
    c.newfigure = 'none';
    c.plotorg = upplot2l.org; c.plotsize = upplot2.size;
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''JC211 SR1b CCL4 (pmol/kg)'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c);
    if (bottle_depth_size > 0); msec_add_bottle_depths; end
    
%     if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
%     if isfield(c,'colorbarset'); c = rmfield(c,'colorbarset'); end
%     
%     c.newfigure = 'none';
%     c.zlist = 'ccl4';
%     c.plotorg = loplot2r.org; c.plotsize = loplot2.size;
%     c.yax = lolim; c.ntick(2) = tyl;
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
%     if (station_depth_width > 0); msec_add_station_depths; end
%     if (bottle_depth_size > 0); msec_add_bottle_depths; end
    
     
%     c.newfigure = 'none';
%     c.plotorg = upplot2r.org; c.plotsize = upplot2.size;
%     c.ctabskip = 0;
%     c.yax = uplim; c.ntick(2) = tyu;
%     c.ncfile.name = c.ncfile.name1;
%     c.xtickset = 'none';
%     c.filenameset = 'none';
%     c.xlabelset = 'none';
%     c.ylabelset = 'none';
%     c.colorbarset = 'none';
%     c.titleset = '''string'',''CCl4 (pmol/kg)'',''fontsize'',12,''fontweight'',''bold''';
%     c = mcontrnew(c)
%     if (bottle_depth_size > 0); msec_add_bottle_depths; end
    
    
    cmd = ['print -dpsc ' section '_ccl4.ps']; eval(cmd);
    cmd = ['print -dpng ' section '_ccl4.png']; eval(cmd);
end

%-------------
% tn and tp

% if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
% 
% c.newfigure = 'l';
% c.plotorg = loplot2l.org; c.plotsize = loplot2.size;
% c.zlist = 'tn';
% c.clev = [0:2:40];
% c.yax = lolim; c.ntick(2) = tyl;
% c = mcontrnew(c)
% 
% c.newfigure = 'none';
% c.plotorg = upplot2l.org; c.plotsize = upplot2.size;
% c.ctabskip = 0;
% c.yax = uplim; c.ntick(2) = tyu;
% c = mcontrnew(c)
% 
% if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
% 
% c.newfigure = 'none';
% c.plotorg = loplot2r.org; c.plotsize = loplot2.size;
% c.zlist = 'tp';
% c.clev = [0:.2:3];
% c.yax = lolim; c.ntick(2) = tyl;
% c = mcontrnew(c)
% 
% c.newfigure = 'none';
% c.plotorg = upplot2r.org; c.plotsize = upplot2.size;
% c.ctabskip = 0;
% c.yax = uplim; c.ntick(2) = tyu;
% c = mcontrnew(c)
% 
% 
% cmd = ['print -dpsc ' section '_tn_tp.ps']; eval(cmd);

%-------------
% don and dop

% if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
% 
% c.newfigure = 'l';
% c.plotorg = loplot2l.org; c.plotsize = loplot2.size;
% c.zlist = 'don';
% c.clev = [0:.5:10];
% c.yax = lolim; c.ntick(2) = tyl;
% c = mcontrnew(c)
% 
% c.newfigure = 'none';
% c.plotorg = upplot2l.org; c.plotsize = upplot2.size;
% c.ctabskip = 0;
% c.yax = uplim; c.ntick(2) = tyu;
% c = mcontrnew(c)
% 
% if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
% 
% c.newfigure = 'none';
% c.plotorg = loplot2l2.org; c.plotsize = loplot2.size;
% c.zlist = 'dop';
% c.clev = [0:.01:.15];
% c.yax = lolim; c.ntick(2) = tyl;
% c = mcontrnew(c)
% 
% c.newfigure = 'none';
% c.plotorg = upplot2r.org; c.plotsize = upplot2.size;
% c.ctabskip = 0;
% c.yax = uplim; c.ntick(2) = tyu;
% c = mcontrnew(c)
% 
% 
% cmd = ['print -dpsc ' section '_don_dop.ps']; eval(cmd);

if ~isempty(strmatch('potemp1',plotlist,'exact'))
    %-------------
    % CTD temp only
    c = csave;
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    if isfield(c,'colorbarset'); c = rmfield(c,'colorbarset'); end
    
    c.newfigure = 'p';
    c.zlist = 'potemp';
    c.plotorg = loplot1.org; c.plotsize = loplot1.size;
    c.yax = lolim; c.ntick(2) = tyl;
    c.ncfile.name = c.ncfile.name2;
    c.ytickset = '''fontsize'',14';
    c.xtickset = '''fontsize'',10';
    c.titleset = 'none';
    c.filenameset = 'none';
    c.xlabelset = '''fontsize'',14';
    c.ylabelset = '''fontsize'',14';
    c.dateset = 'none';
    c = set_clev_col(c);
    c.widths = .5;
    c.colorbarheight = 12;
    c = mcontrnew(c);
    if (station_depth_width > 0); msec_add_station_depths; end

    c.newfigure = 'none';
    c.plotorg = upplot1.org; c.plotsize = upplot1.size;
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''JC211 SR1b Potential temperature'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c);
    
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    if isfield(c,'colorbarset'); c = rmfield(c,'colorbarset'); end
    
 
    
    
    cmd = ['print -dpsc ' section '_potemp.ps']; eval(cmd);
    cmd = ['print -dpng ' section '_potemp.png']; eval(cmd);
end

if ~isempty(strmatch('psal1',plotlist,'exact'))
    %-------------
    % CTD psal only
    c = csave;
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    if isfield(c,'colorbarset'); c = rmfield(c,'colorbarset'); end
    
    c.newfigure = 'p';
    c.zlist = 'psal';
    c.plotorg = loplot1.org; c.plotsize = loplot1.size;
    c.yax = lolim; c.ntick(2) = tyl;
    c.ncfile.name = c.ncfile.name2;
    c.ytickset = '''fontsize'',14';
    c.xtickset = '''fontsize'',10';
    c.titleset = 'none';
    c.filenameset = 'none';
    c.xlabelset = '''fontsize'',14';
    c.ylabelset = '''fontsize'',14';
    c.dateset = 'none';
    c = set_clev_col(c);
    c.widths = .5;
    c.colorbarheight = 12;
    c = mcontrnew(c);
    if (station_depth_width > 0); msec_add_station_depths; end

    c.newfigure = 'none';
    c.plotorg = upplot1.org; c.plotsize = upplot1.size;
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''JC211 SR1b Practical Salinity'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c);
    
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    if isfield(c,'colorbarset'); c = rmfield(c,'colorbarset'); end
    
 
    
    
    cmd = ['print -dpsc ' section '_psal.ps']; eval(cmd);
    cmd = ['print -dpng ' section '_psal.png']; eval(cmd);
end


if ~isempty(strmatch('ctdoxy1',plotlist,'exact'))
    %-------------
    % CTD oxygen
    c = csave;
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    if isfield(c,'colorbarset'); c = rmfield(c,'colorbarset'); end
    
    c.newfigure = 'p';
    c.zlist = 'oxygen';
    c.plotorg = loplot1.org; c.plotsize = loplot1.size;
    c.yax = lolim; c.ntick(2) = tyl;
    c.ncfile.name = c.ncfile.name2;
    c.ytickset = '''fontsize'',14';
    c.xtickset = '''fontsize'',10';
    c.titleset = 'none';
    c.filenameset = 'none';
    c.xlabelset = '''fontsize'',14';
    c.ylabelset = '''fontsize'',14';
    c.dateset = 'none';
    c = set_clev_col(c);
    c.widths = .5;
    c.colorbarheight = 12;
    c = mcontrnew(c);
    if (station_depth_width > 0); msec_add_station_depths; end

    c.newfigure = 'none';
    c.plotorg = upplot1.org; c.plotsize = upplot1.size;
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''JC211 SR1b CTD oxygen'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c);
    
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    if isfield(c,'colorbarset'); c = rmfield(c,'colorbarset'); end
   
    
    cmd = ['print -dpsc ' section '_ctdoxy.ps']; eval(cmd);
    cmd = ['print -dpng ' section '_ctdoxy.png']; eval(cmd);
end

if ~isempty(strmatch('botoxy1',plotlist,'exact'))
    
    %-------------
    % botoxy only
    c = csave;
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    if isfield(c,'colorbarset'); c = rmfield(c,'colorbarset'); end
    
    c.newfigure = 'p';
    c.zlist = 'botoxy';
    c.plotorg = loplot1.org; c.plotsize = loplot1.size;
    c.yax = lolim; c.ntick(2) = tyl;
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
    if (station_depth_width > 0); msec_add_station_depths; end
    if (bottle_depth_size > 0); msec_add_bottle_depths; end
    
    c.newfigure = 'none';
    c.plotorg = upplot1.org; c.plotsize = upplot1.size;
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''JC211 SR1b Bottle oxygen (umol/kg)'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c);
    if (bottle_depth_size > 0); msec_add_bottle_depths; end
    
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    if isfield(c,'colorbarset'); c = rmfield(c,'colorbarset'); end
    
    cmd = ['print -dpsc ' section '_botoxy.ps']; eval(cmd);
    cmd = ['print -dpng ' section '_botoxy.png']; eval(cmd);
end

if ~isempty(strmatch('silc1',plotlist,'exact'))
    %-------------
    % silc only
    c = csave;
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    if isfield(c,'colorbarset'); c = rmfield(c,'colorbarset'); end
    
    c.newfigure = 'p';
    c.zlist = 'silc_per_kg';
    %c.zlist = 'silc';
    c.plotorg = loplot1.org; c.plotsize = loplot1.size;
    c.yax = lolim; c.ntick(2) = tyl;
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
    if (station_depth_width > 0); msec_add_station_depths; end
    if (bottle_depth_size > 0); msec_add_bottle_depths; end
    
    c.newfigure = 'none';
    c.plotorg = upplot1.org; c.plotsize = upplot1.size;
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''JC211 SR1b Silicate (umol/kg)'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c)
    if (bottle_depth_size > 0); msec_add_bottle_depths; end
    
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    if isfield(c,'colorbarset'); c = rmfield(c,'colorbarset'); end
    
    
    cmd = ['print -dpsc ' section '_silc.ps']; eval(cmd);
    cmd = ['print -dpng ' section '_silc.png']; eval(cmd);
end


if ~isempty(strmatch('totnit1',plotlist,'exact'))
    %-------------
    % totnit only
    c = csave;
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    if isfield(c,'colorbarset'); c = rmfield(c,'colorbarset'); end
    
    c.newfigure = 'p';
    c.zlist = 'totnit_per_kg';
    %c.zlist = 'totnit';
    c.plotorg = loplot1.org; c.plotsize = loplot1.size;
    c.yax = lolim; c.ntick(2) = tyl;
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
    if (station_depth_width > 0); msec_add_station_depths; end
    if (bottle_depth_size > 0); msec_add_bottle_depths; end
    
    c.newfigure = 'none';
    c.plotorg = upplot1.org; c.plotsize = upplot1.size;
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''JC211 SR1b NO2+NO3 (umol/kg)'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c);
    if (bottle_depth_size > 0); msec_add_bottle_depths; end
    
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    if isfield(c,'colorbarset'); c = rmfield(c,'colorbarset'); end
    cmd = ['print -dpsc ' section '_totnit.ps']; eval(cmd);
    cmd = ['print -dpng ' section '_totnit.png']; eval(cmd);
  
    
end
if ~isempty(strmatch('phos1',plotlist,'exact'))
    %-------------
    % phos only
    c = csave;
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    if isfield(c,'colorbarset'); c = rmfield(c,'colorbarset'); end

    c.newfigure = 'p';
    c.zlist = 'phos_per_kg';
    %c.zlist = 'phos';
    c.plotorg = loplot1.org; c.plotsize = loplot1.size;
    c.yax = lolim; c.ntick(2) = tyl;
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
    if (station_depth_width > 0); msec_add_station_depths; end
    if (bottle_depth_size > 0); msec_add_bottle_depths; end
    
    c.newfigure = 'none';
    c.plotorg = upplot1.org; c.plotsize = upplot1.size;
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''JC211 SR1b Phosphate (umol/kg)'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c);
    if (bottle_depth_size > 0); msec_add_bottle_depths; end
    
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    if isfield(c,'colorbarset'); c = rmfield(c,'colorbarset'); end
    
    cmd = ['print -dpsc ' section '_phos.ps']; eval(cmd);
    cmd = ['print -dpng ' section '_phos.png']; eval(cmd);
    
    
end

if ~isempty(strmatch('dic1',plotlist,'exact'))
    %-------------
    % dic only
    c = csave;
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    if isfield(c,'colorbarset'); c = rmfield(c,'colorbarset'); end
    
    c.newfigure = 'p';
    c.zlist = 'dic';
    c.plotorg = loplot1.org; c.plotsize = loplot1.size;
    c.yax = lolim; c.ntick(2) = tyl;
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
    if (station_depth_width > 0); msec_add_station_depths; end
    if (bottle_depth_size > 0); msec_add_bottle_depths; end
    
    c.newfigure = 'none';
    c.plotorg = upplot1.org; c.plotsize = upplot1.size;
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''JC211 SR1b DIC (umol/kg)'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c);
    if (bottle_depth_size > 0); msec_add_bottle_depths; end

    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    if isfield(c,'colorbarset'); c = rmfield(c,'colorbarset'); end
    cmd = ['print -dpsc ' section '_dic.ps']; eval(cmd);
    cmd = ['print -dpng ' section '_dic.png']; eval(cmd);
  
    
end

if ~isempty(strmatch('alk1',plotlist,'exact'))
    %-------------
    % alk only
    c = csave;
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    if isfield(c,'colorbarset'); c = rmfield(c,'colorbarset'); end
    
    c.newfigure = 'p';
    c.zlist = 'alk';
    c.plotorg = loplot1.org; c.plotsize = loplot1.size;
    c.yax = lolim; c.ntick(2) = tyl;
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
    if (station_depth_width > 0); msec_add_station_depths; end
    if (bottle_depth_size > 0); msec_add_bottle_depths; end
    
    c.newfigure = 'none';
    c.plotorg = upplot1.org; c.plotsize = upplot1.size;
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''JC211 SR1b Total Alkalinity (umol/kg)'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c);
    if (bottle_depth_size > 0); msec_add_bottle_depths; end
    
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    if isfield(c,'colorbarset'); c = rmfield(c,'colorbarset'); end
    cmd = ['print -dpsc ' section '_alk.ps']; eval(cmd);
    cmd = ['print -dpng ' section '_alk.png']; eval(cmd);
  
    
end

if ~isempty(strmatch('fluor1',plotlist,'exact'))
    %-------------
    % fluor only
    c = csave;
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    if isfield(c,'colorbarset'); c = rmfield(c,'colorbarset'); end
    
    c.newfigure = 'p';
    c.zlist = 'fluor';
    c.plotorg = loplot1.org; c.plotsize = loplot1.size;
    c.yax = lolim; c.ntick(2) = tyl;
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
    if (station_depth_width > 0); msec_add_station_depths; end
%     if (bottle_depth_size > 0); msec_add_bottle_depths; end
    
    c.newfigure = 'none';
    c.plotorg = upplot1.org; c.plotsize = upplot1.size;
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c.colorbarset = 'none';
    c.titleset = '''string'',''JC211 SR1b Chl Fluor (ug/l)'',''fontsize'',12,''fontweight'',''bold''';
    c = mcontrnew(c);
%     if (bottle_depth_size > 0); msec_add_bottle_depths; end
    
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    if isfield(c,'colorbarset'); c = rmfield(c,'colorbarset'); end
    cmd = ['print -dpsc ' section '_fluor.ps']; eval(cmd);
    cmd = ['print -dpng ' section '_fluor.png']; eval(cmd);
  
    
end




