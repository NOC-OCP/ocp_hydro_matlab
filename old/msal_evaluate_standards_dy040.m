% bak on jr281
% assess offset for guildline autosal
% look for drifts of instrument or possible batch to batch offsets
% tweaked on jr302: bak jun 2014
%
% format for standards file is
% 
%  999001    1.99961 
%  999003    1.99984 
%  999004    1.99982 
%  999005    1.99982 
%  999006    1.99981 
%  999007    1.99985 
%  999008    1.99986 
%  999009    1.99984 
%
% standards extracted from file using msal_get_standards.m
% 
% dy040 bak add third column which is flag; this can be used to identify
% questionable standards in teh csv file, just as for questionable samples.
%
% 999001    1.999360 3
% 999002    1.999363 3
% 999003    1.999356 3
% 999005    1.999350 2
%


mcd M_BOT_SAL
mcd('M_CTD'); % change working directory

% add batches here. These numbers are good for all cruises.
p151 = 1.99994;
p153 = 1.99958;
p154 = 1.99980;
p155 = 1.99962;
p156 = 1.99968;
p158 = 1.99940;
p161 = 1.99974;

standards_fn = ['sal_' MEXEC_G.MSCRIPT_CRUISE_STRING '_standards.txt'];

standards = load(standards_fn);
std = standards(:,1)-999000;
val = standards(:,2);

% dy040 bak 1 dec 2016; New Year's Day 2016; start carrying standards flags
if size(standards,2) < 3
    standards = [standards 2+0*standards(:,2)]; % set flags to 2 or nan, if not previously set
end
flags = standards(:,3);

ksize = 300;
allstd = nan(ksize,1);
allval = allstd;
allbatch = allstd;
alldiff = allstd;
alllabel = allstd;
allflags = allstd;

allstd(:,1) = 1:ksize;
allval(std) = val;
allflags(std) = flags;

applied = [];

markercols = 'rrrrrrrr';

switch MEXEC_G.MSCRIPT_CRUISE_STRING
    case 'jr281'
        batches = [155 154 153];
        plotcols = 'krb';
        plotsym = '+++';
        k155 = [1 15 16 17 19 29 30 31 49:59];
        k154 = [2:14 18 20:28 32:48 71];
        k153 = [60:70];
        % record the adjustment applied to stations, recorded by standard number. This could overlap. [start stop adjustment*1e5];
        applied(1,1:3) = [1 36 -3]; % stations up to 66, tsg crates up to 3
        applied(2,1:3) = [36 71 -2]; %stations 67 and after; tsg crates 4 and after;
    case 'jr302'
        batches = [156];
        plotcols = 'krb';
        plotsym = '+++';
        k156 = [1 4 5 7:68 72:300];
    case 'jr306'
        batches = [156];
        plotcols = 'krb';
        plotsym = '+++';
        k155 = [1:3];
        k156 = [4:300];
    case 'dy040'
        batches = [158];
        plotcols = 'krb';
        markercols = 'rkr';
        plotsym = '+++';
        k158 = [1:150];
%         applied(1,1:3) = [1 50 0];
%         applied(2,1:3) = [51 150 0];
    case 'jc159'
        batches = [161];
        plotcols = 'krb';
        markercols = 'rkr';
        plotsym = '+++';
        k161 = [1:150];
        applied(1,1:3) = [1 10 0];
        applied(2,1:3) = [11 150 0];
    otherwise
        return
end

for kb = 1:length(batches)
    cmd = ['allbatch(k' sprintf('%03d',batches(kb)) ') = ' sprintf('%03d',batches(kb)) ';']; eval(cmd); % fix on jc159, previously hardwired to 153
    cmd = ['alllabel(k' sprintf('%03d',batches(kb)) ') = p' sprintf('%03d',batches(kb)) ';']; eval(cmd);
end

diff = alllabel-allval;

diff = diff*1e5;

m_figure

titstr1 = [MEXEC_G.MSCRIPT_CRUISE_STRING ' salinity standards'];
titstr2 = [];

if ~isempty(applied)
    for ka = 1:size(applied,1)
        plot(applied(ka,1:2),[applied(ka,3) applied(ka,3)],'k-','linewidth',1);
        hold on; grid on
    end
end

for kb = 1:length(batches)
    cmd = ['kuse = k' sprintf('%03d',batches(kb)) ';']; eval(cmd)
    colstr = [plotcols(kb) plotsym(kb)];
    plot(allstd(kuse),diff(kuse),colstr);
    hold on; grid on;
    
    % dy040 identify standards with flags not equal to 2
    pflag = allflags(kuse);
    kq = find(pflag~=2);
    znan = zeros(size(diff(kuse)));
    znan(kq) = nan; % zeros, but forced to nan where flag is not 2
    
    plot(allstd(kuse(kq)),diff(kuse(kq)),'c^','markersize',10);
    
    diff_filt = round(filter_bak(ones(1,21),diff(kuse)+znan));
    klast = max(find(isfinite(diff(kuse))));
    if klast < length(diff(kuse)); diff_filt(klast+1:end) = nan; end % tidy up diff_filt bak dy040
    
    plot(allstd(kuse),diff_filt,'k-');
    plot(allstd(kuse),diff(kuse)-diff_filt,'r+');
    plot(allstd(kuse(kq)),diff(kuse(kq))-diff_filt(kq),'c^','markersize',10);

    titstr2 = [titstr2 ' P' sprintf('%03d',batches(kb)) ' (' colstr ') '];
    
    % write out fitted adjustment
    fnout = ['salinity_standards_adjustments_P' sprintf('%03d',batches(kb)) '_' MEXEC_G.MSCRIPT_CRUISE_STRING '.txt'];
    
    fid = fopen(fnout,'w');
    fprintf(fid,'%8s %4s\n','standard','adj');
    for kloop = 1:length(kuse)
        fprintf(fid,'%8d %4d\n',allstd(kuse(kloop)),diff_filt(kloop));
    end
    fclose(fid);
end


ax = axis;
ax(3:4) = [-25 25];
axis(ax);

titstr = {titstr1; titstr2};


title(titstr)
xlabel('standard number')
ylabel('adjustment indicated to guildline ratio')

psfile = ['salinity_standards_' MEXEC_G.MSCRIPT_CRUISE_STRING '_01.ps'];
cmd = ['print -dpsc ' psfile]; eval(cmd)

return % bak on dy040 not using next plot yet. 1 dec 2016

m_figure

titstr1 = [MEXEC_G.MSCRIPT_CRUISE_STRING ' salinity standards'];
titstr2 = [];

if ~isempty(applied)
    for ka = 1:size(applied,1)
        plot(applied(ka,1:2),[applied(ka,3) applied(ka,3)],'k-','linewidth',1);
        hold on; grid on
    end
end

for kb = 1:length(batches)
    cmd = ['kuse = k' sprintf('%03d',batches(kb)) ';']; eval(cmd)
    colstr = [plotcols(kb) plotsym(kb)];
    plot(allstd(kuse),1e5*(allval(kuse)-1.999),colstr);
    hold on; grid on;
    
    titstr2 = [titstr2 ' P' sprintf('%03d',batches(kb)) ' (' colstr ') '];
end


ax = axis;
pzero = 1e5*(p158-1.999);
ax(3:4) = [-25 25]+pzero;
axis(ax);
plot(ax(1:2),pzero+0*ax(1:2),'k-');

titstr = {titstr1; titstr2};


title(titstr)
xlabel('standard number')
ylabel('guildline ratio')

psfile = ['salinity_standards_' MEXEC_G.MSCRIPT_CRUISE_STRING '_02.ps'];
cmd = ['print -dpsc ' psfile]; eval(cmd)



