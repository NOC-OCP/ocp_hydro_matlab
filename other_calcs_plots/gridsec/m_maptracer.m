function ygrid = m_maptracer(statnumgrid,sgrid,tgrid,pgrid,yname,yfname)

% bak on jc032; mcalc subroutine; quite a few things hardwired
%
% yname is name of tracer to grid out of sam file;
% yfname is name of tracer flag. If 'none' then use all y data
%
% function ygrid = m_maptracer(statnumgrid,sgrid,tgrid,pgrid,yname,yfname)
%
m_common
scriptname = mfilename;
root_ctd = mgetdir('M_CTD');
samfn = [root_ctd '/sam_' MEXEC_G.MSCRIPT_CRUISE_STRING '_all' ];

    MEXEC_A.MARGS_IN = MEXEC_A.MARGS_IN_LOCAL; % get back the queue of responses
    MEXEC_A.MARGS_IN = [samfn '/' MEXEC_A.MARGS_IN(:)' ]; % must use MEXEC_A.MARGS_IN because we are calling mheader which is a 'main' program

% [d h] = mload(samfn,'/');
[d h] = mload;

stdpres = [0 5 25 50 75 100 175 250 375 500 ...
    625 750 875 1000 1250 1500 1750 2000 2250 2500 ...
    2750 3000 3250 3500 3750 4000 4250 4500 4750 ...
    5000 5250 5500 5750 6000];
% stdpres = [0 50 100 175 250 375 500 ...
%     625 750 875 1000 1250 1500 1750 2000 2250 2500 ...
%     2750 3000 3250 3500 3750 4000 4250 4500 4750 ...
%     5000 5250 5500 5750 6000 6250 6500]; % add 6250 and 6500 di346
% stdpres = [0:100:1000 1000:20:2000]; % jc069
stdpres = unique(stdpres);
plev = 1:length(stdpres);

statnum = d.statnum;
sampnum = d.sampnum;
p = d.upress;
t = d.utemp;
th = d.upotemp;
psal = d.upsal;
pl = interp1(stdpres,plev,p); % assign a plevel to each bottle

% yname = 'botoxy';

clear s
% identify the tracer data
cmd = ['y = d.' yname ';']; eval(cmd);

if strcmp(yfname,'none')
    yflag = 2+0*y;
else
    cmd = ['yflag = d.' yfname ';']; eval(cmd);
end
flaglim = 2; % highest flag to be used for gridding
s.xlim = 1; % width of gridding window, measured in statnum
s.zlim = 4; % vertical extent of gridding window measured in plev
% pgrid = 10:20:4000;
% stnlist = 23:44;
% 
% ktest = find(statnum == 30 & 4000 > p & p > 1500); % test points
% ktest = find(statnum >= 1 ); % test points


testfit = nan+y;

% group stations that can be used together for gridding
oopt = 'kstatgroups'; get_cropt

%now distribute the sample numbers into sets corresponding to the station
%groups 
for kount = 1:length(kstatgroups)
    ks = kstatgroups{kount};
    kall = [];
    for kount2 = ks
        kadd = find(statnum == kount2);
        kall = [kall ;kadd];
    end
    kdcgroups{kount} = kall;
end

% pack reference data into structure s
s.statnum = statnum;
s.pl = pl;
s.p = p;
s.t = t;
s.s = psal;
s.y = y;
s.yf = yflag; s.yf(s.yf > flaglim) = nan; % mask data with flag > 2
s.kdcgroups = kdcgroups;
s.kstatgroups = kstatgroups;

% g contains output at a grid point
% identify that point.


action = 'grid';
mm = [action ' ' yname ' ' yfname];
fprintf(MEXEC_A.Mfidterm,'%s\n',mm);
% action = 'self'
% action = 'self_omit_stn'
% action = 'self_include_all'

s.action = action; % save for switch in mapping subroutine;
switch action
    case {'self' 'self_omit_stn' 'self_include_all'};
        yot = nan+s.p;
        for k = 1:length(p) % each point in the ref data
            g.p = s.p(k);
            g.statnum = s.statnum(k);
            g.s = s.s(k);
            g.t = s.t(k);
            g.pl = s.pl(k);
            g = bakmap2(g,s);
            yot(k) = g.fit;
        end
        resid = y-yot;
        y_iqr = iqr(resid+0*s.yf); % s.yf is nan for excluded flags
        fprintf(MEXEC_A.Mfidterm,'%s %10.4f\n','iqr is ' ,y_iqr);
        kquestion = find(abs(resid+0*s.yf) > 3*y_iqr);
        ot = [sampnum s.p y yot s.yf resid];
        sprintf('%7d %7.1f %10.4f %10.4f %3d %10.4f\n',ot(kquestion,:)')
    case 'grid'
        %         p = pgrid(:);
        %         yotall = nan+ones(length(p),length(stnlist));
        yotall = nan+pgrid;
        
        % bak on jc159 26 march 2018; modify so the horizontal
        % weighting is based on index in statnumgrid rather than
        % just statnum; carry statnumgrid and index in grid of all samples into mapping
        g.statnumgrid = statnumgrid;
        s.statnumindex = nan + s.statnum;
        g.statlist = statnumgrid(1,:); % stations in grid
        % find index of all reference points in statlist
        for kref = 1:length(s.statnum);
            ki = find(g.statlist == s.statnum(kref));
            if isempty(ki); continue; end
            if length(ki) > 1
                fprintf(2,'\n%s\n\n','Problem in m_maptracer: the station number of a sample to be used for gridding was not uniquely found in the station set');
                error('exiting');
            end
            s.statnumindex(kref) = ki;
        end
        % end of mod 26 march 2018.
        
        for kx = 1:size(pgrid,1)
            for ky = 1:size(pgrid,2)
% % % % %             kstn = stnlist(kount);
% % % % %             stnstr = sprintf('%03d',kstn);
% % % % %             ctdfn = [root_ctd '/' 'ctd_jc032_' stnstr '_2db.nc']; % load ctd data for this station
% % % % %                             %  ctd data are required so we know density at the target mapping point
% % % % %             if exist(ctdfn,'file') ~=2; 
% % % % %                 m = ['Required CTD file ' fn ' does not exist'];
% % % % %                 fprintf(MEXEC_A.Mfider,'%s\n',' ',m,' ');
% % % % %                 return; 
% % % % %             end
% % % % %             [dctd h] = mload(ctdfn,'press temp psal',' ');
% % % % %             psal = interp1(dctd.press,dctd.psal,p);
% % % % %             t = interp1(dctd.press,dctd.temp,p);
% % % % %             yot = nan+p;
% % % % %             for k = 1:length(p)
                g.p = pgrid(kx,ky);
                g.statnum = statnumgrid(kx,ky);
                g.s = sgrid(kx,ky);
                g.t = tgrid(kx,ky);
                g.pl = interp1(stdpres,plev,g.p); % assign a plevel to the test point. This is used for weighting
                g = bakmap2(g,s);
                yotall(kx,ky) = g.fit;
            end
% % % % %             yotall(:,kount) = yot(:);
        end
        yot = yotall;
        ygrid =yot;
    otherwise
        %nothing to do
end


function g = bakmap2(g,s)
    g.fit = nan;
    pref = g.p;
    sig = sw_pden(s.s,s.t,s.p,pref)-1000; % recalculate sigma for the reference pressure of the test point
    sigref = sw_pden(g.s,g.t,g.p,pref)-1000; % measure sig relative to test point.
    if isnan(sigref); g.fit = nan; return; end
    
    sk = g.statnum; % station number of the test point
    
    %sort out section range
    % After this ksec contains the data cycle numbers of the tracer data
    % that lie in the required section
    for jsec = 1:length(s.kstatgroups)
        if ~isempty(find(s.kstatgroups{jsec} == sk)); ksec = s.kdcgroups{jsec}; end
    end


    plk = g.pl; % this is the plevel of the test point
    %x = s.statnum-sk;
    % bak on jc159 26 march 2018; station separation for weight calculated
    % from index in station grid rather than just station number.
    skindex = find(g.statlist == sk);
    if length(skindex) ~= 1
        fprintf(2,'\n%s\n\n','Problem in m_maptracer: a station to be used for gridding does not occur uniquely in the station set');
        error('exiting');
    end
    x = s.statnumindex-skindex;
    % end of mod
    z = s.pl-plk;
    kpoints = find(-s.xlim <= x & x <= s.xlim ...
                 & -s.zlim <= z & z <= s.zlim ...
                 & isfinite(s.y + sig + s.yf) ...
        ); % these are the points within xlim stations an zlim levels.

    kuse = kpoints;
%     kuse = setdiff(kuse,k);
    kuse = intersect(kuse,ksec);% only carry points forward if they're in the right station group
    if isempty(kuse); return; end

    nu = length(kuse);
    sigu = sig(kuse); sigu = sigu(:)-sigref;
    yu = s.y(kuse); yu = yu(:);
    xu = x(kuse); xu = xu(:);
    zu = z(kuse); zu = zu(:);
    
    %weights
    w = ones(nu,1);
    dist = sqrt(xu.*xu+zu.*zu);
    w = exp(-dist);
    switch s.action
        case 'self'
            w(dist==0) = 0; % omit point from self-test
        case 'self_omit_stn'
            w(xu==0) = 0;
        case 'self_include_all'
            % do not change weights
        otherwise
    end

    V = [ones(nu,1) sigu sigu.*sigu];% sigu.*sigu.*sigu];
    wrep = repmat(w,1,size(V,2)); % weights
    yw = w.*yu;
    Vw = wrep.*V;
    [Q,R] = qr(Vw,0);
    poly = R\(Q'*yw);
    
    g.fit = poly(1); % mapped data on y points
    
    %%%% bak on jc159 24 March 2018
    % do not allow extrapolation; output is nan if the density of the test
    % point is not bracketed by density of samples being used.
    if min(sigu(w~=0))*max(sigu(w~=0)) > 0 % test point is not bracketed by points with non-zero weight; make result be nan.
        g.fit = nan;
    end
    %%%%
    return

%     resid = yu-V*poly;

%     myfigure
%     plot(y(kpoints),sig(kpoints),'k+')
%     hold on; grid on
%     plot(V*poly,sig(kuse),'r+')
%     plot(o(k),sig(k),'mo')



