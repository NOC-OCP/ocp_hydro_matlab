% mcsetd M_SCRIPTS; root_scripts = MEXEC_G.MEXEC_CWD;

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

%%%
 
% cmd = ['c = cdf_' section]; eval(cmd);
% cmd = ['c.ncfile.name = ''grid_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' section '''']; eval(cmd);
clear c
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
        lolim = [6500 1000]; tyl = 11;
        uplim = [1000 0]; tyu = 8;
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
        lolim = [6500 1000]; tyl = 11;
        uplim = [1000 0]; tyu = 8;
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
        
    otherwise
end

csave = c;

plotlist = {'potemp' 'botoxy' 'totnit' 'dic' 'ctdoxy'};
% plotlist = {'botoxy' 'totnit' 'ctdoxy' 'potemp'};
% % plotlist = {'botoxy' 'totnit' 'ctdoxy' 'potemp' 'cfc11' 'f113' 'sf6'};
% % plotlist = { 'botoxy' 'totnit' 'dic'};
% plotlist = {'potemp' 'dic'};
% plotlist = {'potemp'};

if ~isempty(strmatch('dic',plotlist,'exact'))
    c = csave;
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    
    c.newfigure = 'l';
    c.plotorg = [2.5 1.5]; c.plotsize = [9 6];
    c.zlist = 'alk';
    c.clev = [2250:20:2500 2320];
    c.yax = lolim; c.ntick(2) = tyl;
    c.ncfile.name = c.ncfile.name2;
    c.ytickset = '''fontsize'',14';
    c.xtickset = '''fontsize'',10';
    c.titleset = 'none';
    c.filenameset = 'none';
    c.xlabelset = '''fontsize'',14';
    c.ylabelset = '''fontsize'',14';
    c.dateset = 'none';c = mcontrnew(c)
    
    c.newfigure = 'none';
    c.plotorg = [2.5 7.5]; c.plotsize = [9 6];
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.titleset = '''string'',''TA'',''fontsize'',12,''fontweight'',''bold''';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c = mcontrnew(c)
    
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    
    c.newfigure = 'none';
    c.plotorg = [15.5 1.5]; c.plotsize = [9 6];
    c.zlist = 'dic';
    c.clev = [ 2050:20:2250];
    c.yax = lolim; c.ntick(2) = tyl;
    c.ncfile.name = c.ncfile.name2;
    c.ytickset = '''fontsize'',14';
    c.xtickset = '''fontsize'',10';
    c.titleset = 'none';
    c.filenameset = 'none';
    c.xlabelset = '''fontsize'',14';
    c.ylabelset = '''fontsize'',14';
    c = mcontrnew(c)
    
    c.newfigure = 'none';
    c.plotorg = [15.5 7.5]; c.plotsize = [9 6];
    c.yax = uplim; c.ntick(2) = tyu;
    c.ctabskip = 0;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.titleset = '''string'',''DIC'',''fontsize'',12,''fontweight'',''bold''';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c = mcontrnew(c)
    
    
    cmd = ['print -dpsc ' section '_co2.ps']; eval(cmd);
    
    
end

if ~isempty(strmatch('botoxy',plotlist,'exact'))
    
    %-------------
    % botoxy and silc
    c = csave;
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    
    c.newfigure = 'l';
    c.plotorg = [2.5 1.5]; c.plotsize = [9 6];
    c.zlist = 'botoxy';
    c.clev = [150:10:300];
    c.yax = lolim; c.ntick(2) = tyl;
    c.ncfile.name = c.ncfile.name2;
    c.ytickset = '''fontsize'',14';
    c.xtickset = '''fontsize'',10';
    c.titleset = 'none';
    c.filenameset = 'none';
    c.xlabelset = '''fontsize'',14';
    c.ylabelset = '''fontsize'',14';
    c.dateset = 'none';
    c = mcontrnew(c)
    
    c.newfigure = 'none';
    c.plotorg = [2.5 7.5]; c.plotsize = [9 6];
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.titleset = '''string'',''Bottle oxygen'',''fontsize'',12,''fontweight'',''bold''';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c = mcontrnew(c)
    
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    
    c.newfigure = 'none';
    c.plotorg = [15.5 1.5]; c.plotsize = [9 6];
    c.zlist = 'silc';
    c.clev = [1 2 5 0:10:50 60 50:20:130];
    c.yax = lolim; c.ntick(2) = tyl;
    c.ncfile.name = c.ncfile.name2;
    c.ytickset = '''fontsize'',14';
    c.xtickset = '''fontsize'',10';
    c.titleset = 'none';
    c.filenameset = 'none';
    c.xlabelset = '''fontsize'',14';
    c.ylabelset = '''fontsize'',14';
    c.dateset = 'none';
    c = mcontrnew(c)
    
    c.newfigure = 'none';
    % c.plotorg = [15.5 10]; c.plotsize = [9 6];
    c.plotorg = [15.5 7.5]; c.plotsize = [9 6];
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.titleset = '''string'',''Silicate'',''fontsize'',12,''fontweight'',''bold''';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c = mcontrnew(c)
    
    
    cmd = ['print -dpsc ' section '_ox_silc.ps']; eval(cmd);
end

if ~isempty(strmatch('totnit',plotlist,'exact'))
    %-------------
    % totnit and phos
    c = csave;
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    
    c.newfigure = 'l';
    c.plotorg = [2.5 1.5]; c.plotsize = [9 6];
    c.zlist = 'totnit';
    c.clev = [0:2:40];
    c.yax = lolim; c.ntick(2) = tyl;
    c.ncfile.name = c.ncfile.name2;
    c.ytickset = '''fontsize'',14';
    c.xtickset = '''fontsize'',10';
    c.titleset = 'none';
    c.filenameset = 'none';
    c.xlabelset = '''fontsize'',14';
    c.ylabelset = '''fontsize'',14';
    c.dateset = 'none';
    c = mcontrnew(c);
    
    c.newfigure = 'none';
    c.plotorg = [2.5 7.5]; c.plotsize = [9 6];
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.titleset = '''string'',''NO2+NO3'',''fontsize'',12,''fontweight'',''bold''';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c = mcontrnew(c);
    
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    
    c.newfigure = 'none';
    c.plotorg = [15.5 1.5]; c.plotsize = [9 6];
    c.zlist = 'phos';
    c.clev = [0:.2:3];
    c.yax = lolim; c.ntick(2) = tyl;
    c.ncfile.name = c.ncfile.name2;
    c.ytickset = '''fontsize'',14';
    c.xtickset = '''fontsize'',10';
    c.titleset = 'none';
    c.filenameset = 'none';
    c.xlabelset = '''fontsize'',14';
    c.ylabelset = '''fontsize'',14';
    c.dateset = 'none';
    c = mcontrnew(c);
    
    c.newfigure = 'none';
    c.plotorg = [15.5 7.5]; c.plotsize = [9 6];
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.titleset = '''string'',''Phosphate'',''fontsize'',12,''fontweight'',''bold''';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c = mcontrnew(c);    
    
    cmd = ['print -dpsc ' section '_totnit_phos.ps']; eval(cmd);
    
    
end

if ~isempty(strmatch('potemp',plotlist,'exact'))
    %-------------
    % CTD temp and psal
    c = csave;
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    
    c.newfigure = 'l';
    c.plotorg = [2.5 1.5]; c.plotsize = [9 6];
    c.zlist = 'potemp';
    c.clev =  [0 .25 .5 1 2 2.5 3 3.5 4:1:10 12:3:25 1.6];
    c.yax = lolim; c.ntick(2) = tyl;
    c.ncfile.name = c.ncfile.name2;
    c.ytickset = '''fontsize'',14';
    c.xtickset = '''fontsize'',10';
    c.titleset = 'none';
    c.filenameset = 'none';
    c.xlabelset = '''fontsize'',14';
    c.ylabelset = '''fontsize'',14';
    c.dateset = 'none';
    c = mcontrnew(c);
    
    c.newfigure = 'none';
    c.plotorg = [2.5 7.5]; c.plotsize = [9 6];
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.titleset = '''string'',''Potential temperature'',''fontsize'',12,''fontweight'',''bold''';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c = mcontrnew(c);
    
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    
    c.newfigure = 'none';
    c.plotorg = [15.5 1.5]; c.plotsize = [9 6];
    c.zlist = 'psal';
    c.clev = [ 34.88 34.96 33:.5:34 34:.1:35.5 35.5:.5:38];
    c.yax = lolim; c.ntick(2) = tyl;
    c.ncfile.name = c.ncfile.name2;
    c.ytickset = '''fontsize'',14';
    c.xtickset = '''fontsize'',10';
    c.titleset = 'none';
    c.filenameset = 'none';
    c.xlabelset = '''fontsize'',14';
    c.ylabelset = '''fontsize'',14';
    c.dateset = 'none';
    c = mcontrnew(c);
    
    c.newfigure = 'none';
    c.plotorg = [15.5 7.5]; c.plotsize = [9 6];
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.titleset = '''string'',''Practical Salinity'',''fontsize'',12,''fontweight'',''bold''';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c = mcontrnew(c);
    
    
    cmd = ['print -dpsc ' section '_potemp_psal.ps']; eval(cmd);
end

if ~isempty(strmatch('ctdoxy',plotlist,'exact'))
    %-------------
    % CTD oxygen and fluor
    c = csave;
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    
    c.newfigure = 'l';
    c.plotorg = [2.5 1.5]; c.plotsize = [9 6];
    c.zlist = 'oxygen';
    c.clev = [150:10:300];
    c.yax = lolim; c.ntick(2) = tyl;
    c.ncfile.name = c.ncfile.name2;
    c.ncfile.name = c.ncfile.name2;
    c.ytickset = '''fontsize'',14';
    c.xtickset = '''fontsize'',10';
    c.titleset = 'none';
    c.filenameset = 'none';
    c.xlabelset = '''fontsize'',14';
    c.ylabelset = '''fontsize'',14';
    c.dateset = 'none';
    c = mcontrnew(c);
    
    c.newfigure = 'none';
    c.plotorg = [2.5 7.5]; c.plotsize = [9 6];
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c.ncfile.name = c.ncfile.name1;
    c.xtickset = 'none';
    c.titleset = '''string'',''CTD oxygen'',''fontsize'',12,''fontweight'',''bold''';
    c.filenameset = 'none';
    c.xlabelset = 'none';
    c.ylabelset = 'none';
    c = mcontrnew(c);
    
%     if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
%     
%     c.newfigure = 'none';
%     c.plotorg = [15.5 1.5]; c.plotsize = [9 6];
%     c.zlist = 'fluor';
%     c.clev = [0:.03:.25 ];
%     c.yax = lolim; c.ntick(2) = tyl;
%     c.ncfile.name = c.ncfile.name2;
%     c = mcontrnew(c)
%     
%     c.newfigure = 'none';
%     c.plotorg = [15.5 7.5]; c.plotsize = [9 6];
%     c.ctabskip = 0;
%     c.yax = uplim; c.ntick(2) = tyu;
%     c.ncfile.name = c.ncfile.name1;
%     c = mcontrnew(c)
    
    
    cmd = ['print -dpsc ' section '_ctdoxy_fluor.ps']; eval(cmd);
end

if ~isempty(strmatch('cfc11',plotlist,'exact'))
    %-------------
    % CTD cfc11 cfc12
    c = csave;
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    
    c.newfigure = 'l';
    c.plotorg = [2.5 1.5]; c.plotsize = [9 6];
    c.zlist = 'cfc11';
    c.clev = [0.01 0.02 0:0.05:.2 .5 1:.5:4 4:1:8];
    c.yax = lolim; c.ntick(2) = tyl;
    c = mcontrnew(c)
    
    c.newfigure = 'none';
    c.plotorg = [2.5 7.5]; c.plotsize = [9 6];
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c = mcontrnew(c)
    
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    
    c.newfigure = 'none';
    c.plotorg = [15.5 1.5]; c.plotsize = [9 6];
    c.zlist = 'cfc12';
    c.clev = [ 0.01 0.02 0:0.05:.2 .5 1 1.5:.1:2 2:.2:4];
    c.yax = lolim; c.ntick(2) = tyl;
    c = mcontrnew(c)
    
    c.newfigure = 'none';
    c.plotorg = [15.5 7.5]; c.plotsize = [9 6];
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c = mcontrnew(c)
    
    
    cmd = ['print -dpsc ' section '_cfc11_cfc12.ps']; eval(cmd);
end

if ~isempty(strmatch('f113',plotlist,'exact'))
    
    %-------------
    % CTD f113 & ccl4
    
    c = csave;
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    
    c.newfigure = 'l';
    c.plotorg = [2.5 1.5]; c.plotsize = [9 6];
    c.zlist = 'f113';
    c.clev = [ 0.005 0:.01:.05 .1:.025:.4 ];
    c.yax = lolim; c.ntick(2) = tyl;
    c = mcontrnew(c)
    
    c.newfigure = 'none';
    c.plotorg = [2.5 7.5]; c.plotsize = [9 6];
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c = mcontrnew(c)
    
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    
    c.newfigure = 'none';
    c.plotorg = [15.5 1.5]; c.plotsize = [9 6];
    c.zlist = 'ccl4';
    c.clev = [0:.1:.5 1:.5:5 5:2:15];
    c.yax = lolim; c.ntick(2) = tyl;
    c = mcontrnew(c)
    
    c.newfigure = 'none';
    c.plotorg = [15.5 7.5]; c.plotsize = [9 6];
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c = mcontrnew(c)
    
    
    cmd = ['print -dpsc ' section '_f113_ccl4.ps']; eval(cmd);
end

if ~isempty(strmatch('sf6',plotlist,'exact'))
    %-------------
    % CTD sf6
    
    c = csave;
    if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    
    c.newfigure = 'l';
    c.plotorg = [2.5 1.5]; c.plotsize = [9 6];
    c.zlist = 'sf6';
    c.clev = [0 .01 .02:.02:.1 .1:.05:.2 .2:.2:3.4 .7 ];
    c.yax = lolim; c.ntick(2) = tyl;
    c = mcontrnew(c)
    
    c.newfigure = 'none';
    c.plotorg = [2.5 7.5]; c.plotsize = [9 6];
    c.ctabskip = 0;
    c.yax = uplim; c.ntick(2) = tyu;
    c = mcontrnew(c)
    
    % % if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
    % %
    % % c.newfigure = 'none';
    % % c.plotorg = [15.5 1.5]; c.plotsize = [9 6];
    % % c.zlist = 'ccl4';
    % % c.clev = [0:.5:3];
    % % c.yax = lolim; c.ntick(2) = tyl;
    % % c = mcontrnew(c)
    % %
    % % c.newfigure = 'none';
    % % c.plotorg = [15.5 10]; c.plotsize = [9 6];
    % % c.ctabskip = 0;
    % % c.yax = uplim; c.ntick(2) = tyu;
    % % c = mcontrnew(c)
    
    
    cmd = ['print -dpsc ' section '_sf6.ps']; eval(cmd);
end

%-------------
% tn and tp

% if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
% 
% c.newfigure = 'l';
% c.plotorg = [2.5 1.5]; c.plotsize = [9 6];
% c.zlist = 'tn';
% c.clev = [0:2:40];
% c.yax = lolim; c.ntick(2) = tyl;
% c = mcontrnew(c)
% 
% c.newfigure = 'none';
% c.plotorg = [2.5 10]; c.plotsize = [9 6];
% c.ctabskip = 0;
% c.yax = uplim; c.ntick(2) = tyu;
% c = mcontrnew(c)
% 
% if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
% 
% c.newfigure = 'none';
% c.plotorg = [15.5 1.5]; c.plotsize = [9 6];
% c.zlist = 'tp';
% c.clev = [0:.2:3];
% c.yax = lolim; c.ntick(2) = tyl;
% c = mcontrnew(c)
% 
% c.newfigure = 'none';
% c.plotorg = [15.5 10]; c.plotsize = [9 6];
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
% c.plotorg = [2.5 1.5]; c.plotsize = [9 6];
% c.zlist = 'don';
% c.clev = [0:.5:10];
% c.yax = lolim; c.ntick(2) = tyl;
% c = mcontrnew(c)
% 
% c.newfigure = 'none';
% c.plotorg = [2.5 10]; c.plotsize = [9 6];
% c.ctabskip = 0;
% c.yax = uplim; c.ntick(2) = tyu;
% c = mcontrnew(c)
% 
% if isfield(c,'colortable'); c = rmfield(c,'colortable'); end
% 
% c.newfigure = 'none';
% c.plotorg = [15.5 1.5]; c.plotsize = [9 6];
% c.zlist = 'dop';
% c.clev = [0:.01:.15];
% c.yax = lolim; c.ntick(2) = tyl;
% c = mcontrnew(c)
% 
% c.newfigure = 'none';
% c.plotorg = [15.5 10]; c.plotsize = [9 6];
% c.ctabskip = 0;
% c.yax = uplim; c.ntick(2) = tyu;
% c = mcontrnew(c)
% 
% 
% cmd = ['print -dpsc ' section '_don_dop.ps']; eval(cmd);

