% mcfc_02: paste cfc data into sam file

scriptname = 'msf5plot';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

if exist('stn','var')
    m = ['Running script ' scriptname ' on station ' sprintf('%03d',stn)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    stn = input('type stn number ');
end
% stn_string = sprintf('%03d',stn);
stnlocal = stn;
clear stn % so that it doesn't persist

root_cfc = mgetdir('M_BOT_CFC');
root_ctd = mgetdir('M_CTD');


numstations = length(stnlocal);
cols = 'krbmcccccccccccccccccccccccccccccccccccccccccc';

ps_suffix = [];
title_str2 = 'colours';

for kloop2 = 1:numstations
    stn_string = sprintf('%03d',stnlocal(kloop2));
    ps_suffix = [ps_suffix '_' stn_string];
    col = cols(kloop2); % color for plotting this station

    prefix1 = ['ctd_' cruise '_'];
    prefix2 = ['sam_' cruise '_'];

    infile1 = [root_ctd '/' prefix1 stn_string '_2db'];
    infile2 = [root_ctd '/' prefix2 stn_string];

    otfile = [root_ctd '/sf5_' cruise '_' stn_string];

    if exist(m_add_nc(infile1),'file') ~= 2
        return
    end
    [dctd hctd] = mload(infile1,'/');
    [dsam hsam] = mload(infile2,'/');

    samp = dsam.sampnum;
    p = dsam.upress;
    t = dsam.utemp;
    s = dsam.upsal;
    sf5 = dsam.sf5cf3;
    sf5flag = dsam.sf5cf3_flag;

    kbad = find(sf5flag ~= 2);
    p(kbad) = [];
    t(kbad) = [];
    s(kbad) = [];
    sf5(kbad) = [];
    samp(kbad) = [];


    sigma1 = sw_pden(s,t,p,1000)-1000;

    gamman = gamma_n(s,t,p,hctd.longitude,hctd.latitude);

    sig1 = sw_pden(dsam.upsal,dsam.utemp,dsam.upress,1000)-1000;
    gamn = gamma_n(dsam.upsal,dsam.utemp,dsam.upress,hctd.longitude,hctd.latitude);

    messdata = [sprintf('%5s  %4s  %6s  %6s  %6s  %6s  %6s %6s %6s','samp','wire','press','potemp','psal','sig1','gam_n','sf5cf3','flag')];
    fprintf(1,'\n%s\n\n',messdata);

    for kloop = 1:length(dsam.upsal)
        messdata = [sprintf('%5d  %4.0f  %6.1f  %6.3f  %6.3f  %6.3f  %6.3f  %6.3f %6d',...
            dsam.sampnum(kloop),dsam.wireout(kloop),dsam.upress(kloop),dsam.upotemp(kloop),...
            dsam.upsal(kloop),sig1(kloop),gamn(kloop),dsam.sf5cf3(kloop),dsam.sf5cf3_flag(kloop))];
        fprintf(1,'%s\n',messdata);
    end


    % [samp(:) p(:)/1000 t(:) s(:) sigma1(:) gamman(:) sf5(:)]

    lat = hctd.latitude;
    lon = hctd.longitude;
    time = datenum(hctd.data_time_origin);
    % cmd = ['save ' otfile ' p t s sf5 lat lon time']; eval(cmd)

    title_str1 = [MEXEC_G.MSCRIPT_CRUISE_STRING ' station ' ps_suffix];
    title_str2 = [title_str2 ' ' col];
    title_str = {title_str1; title_str2};

    if kloop2 == 1
        figure
    end

    subplot(2,2,1)
    plot(sf5,gamman,[col '+-']);
    hold on; grid on;
    ax = axis;
    tracerlim = ax(1:2);
    axis([tracerlim 27.6 28.1])
    axis ij
    xlabel('sf5cf3 fmol/l');
    ylabel('gamma N')
    h221 = title(title_str);
    set(h221,'interpreter','none');
    plot(tracerlim,[27.905 27.905],'k-')


    subplot(2,2,2)
    plot(sf5,sigma1,[col '+-']);
    hold on; grid on;
    axis([tracerlim 32 32.5])
    axis ij
    xlabel('sf5cf3 fmol/l');
    ylabel('sigma 1')
    h222 = title(title_str);
    set(h222,'interpreter','none');
    plot(tracerlim,[32.332 32.332],'k-')

    subplot(2,2,3);
    plot(sf5,-p,[col '+-'])
    hold on; grid on;
    axis_press = [-2500 0];
    axis([tracerlim axis_press])
    xlabel('sf5cf3 fmol/l');
    ylabel('pressure')
    h223 = title(title_str);
    set(h223,'interpreter','none');


    % subplot(2,2,3)
    % plot(sf5,-p,'+-')
    % hold on; grid on;
    % subplot(2,2,4)
    % plot(sf5,-p,'+-')
    % hold on; grid on;
end

if numstations == 1
    
    ctdp = dctd.press;
    ctds = dctd.psal;
    ctdt = dctd.temp;
    ctdlat = hctd.latitude;
    ctdlon = hctd.longitude;
    ctdgam = gamma_n(ctds(:),ctdt(:),ctdp(:),ctdlon,ctdlat);
    
    
    % fit the data and add the fit to the plot
    switch cruise
        case 'jr281'
            presscut = 300;
            if (stnlocal >= 30)
                presscut = 150;
            end
            if (stnlocal >= 30)
                axis_press = [-1000 0];
            end
            if (stnlocal >= 93)
                presscut = 500;
                axis_press = [-2500 0];
            end
        otherwise
            presscut = 300;
    end
    kgood = find(dsam.sf5cf3_flag == 2 & dsam.sf5cf3 >= 0 & dsam.upress > presscut);
    
    xbase = 0:2:2500;

    xx = dsam.upress(kgood);
    yy = dsam.sf5cf3(kgood);
    clear mess
    if exist('numwid','var') ~=1; numwid = 1; end
    switch numwid
        case 1
            gaussp = gaussfit(xx,yy,'press');
            gaussp(4) = gaussp(2); % for convenience elsewhere
            gamlims = interp1(ctdp,ctdgam,[gaussp(3)-gaussp(2) gaussp(3) gaussp(3)+gaussp(2)]);
            yresid = yy-gaussian_eval(gaussp,xx);
            residstd = std(yresid);
            yfit = gaussian_eval(gaussp,xbase);
            gbase = interp1(ctdp,ctdgam,xbase);
        case 2
            gaussp = gaussfit2(xx,yy,'press');
            gamlims = interp1(ctdp,ctdgam,[gaussp(3)-gaussp(2) gaussp(3) gaussp(3)+gaussp(4)]);
            yresid = yy-gaussian_eval2(gaussp,xx);
            residstd = std(yresid);
            yfit = gaussian_eval2(gaussp,xbase);
            gbase = interp1(ctdp,ctdgam,xbase);
            mess{5} = ['width2      : ' sprintf('%7.0f',gaussp(4))];
    end

    subplot(2,2,1)
    plot(yfit,gbase,'r-')

    subplot(2,2,3)
    plot(yfit,-xbase,'r-')
    axis([tracerlim axis_press])

    
    mess{1} = ['centre      : ' sprintf('%7.0f',gaussp(3))];
    mess{2} = ['width       : ' sprintf('%7.0f',gaussp(2))];
    mess{3} = ['amplitude   : ' sprintf('%7.2f',gaussp(1))];
    mess{4} = ['residual    : ' sprintf('%7.3f',residstd)];
    mess{length(mess)+1} = ['gamwidth    : ' sprintf('%7.3f',(gamlims(3)-gamlims(1))/2)];
    mess{length(mess)+1} = ['gamcentre   : ' sprintf('%7.3f',gamlims(2))];
    fprintf(1,'%s\n',mess{:});
    tx = .98;
    ty = .95;
    tyd = -.08;
    for kloop = 1:length(mess)
        ht = text(0,0,mess{kloop});
        set(ht,'units','normalized');
        set(ht,'HorizontalAlignment','right');
        set(ht,'position',[tx ty]);
        set(ht,'color','k');
        ty = ty + tyd;
    end

end

psname = ['sf5_' MEXEC_G.MSCRIPT_CRUISE_STRING ps_suffix '.ps'];
figname = ['sf5_' MEXEC_G.MSCRIPT_CRUISE_STRING ps_suffix '.fig'];

cmd = ['print -dpsc ' psname]; eval(cmd);

gauss_fn = 'gauss_sum.mat';
varlist = {'pcentre1' 'pwidth1' 'pwidth2' 'pwidth3' 'amplitude1' 'residual1' 'gamcentre1' 'gamwidth1' 'pcentre2'  'amplitude2' 'residual2' 'gamcentre2' 'gamwidth2'};
numv = length(varlist);
if exist(gauss_fn,'file') == 2
    load('gauss_sum.mat');
else
   for kv = 1:numv
       cmd = [varlist{kv} ' = [];']; eval(cmd)
   end
end

% extend arrays
num_extra = stnlocal - length(pcentre1);
pad = nan+ones(num_extra,1);

for kv = 1:numv
    cmd = [varlist{kv} ' = [ ' varlist{kv} ' ; pad];']; eval(cmd)
end

if numwid == 1
    pcentre1(stnlocal) = gaussp(3);
    pwidth1(stnlocal) = gaussp(2);
    amplitude1(stnlocal) = gaussp(1);
    residual1(stnlocal) = residstd;
    gamcentre1(stnlocal) = gamlims(2);
    gamwidth1(stnlocal) = (gamlims(3)-gamlims(1))/2;
end
if numwid == 2
    pcentre2(stnlocal) = gaussp(3);
    pwidth2(stnlocal) = gaussp(2);
    pwidth3(stnlocal) = gaussp(4);
    amplitude2(stnlocal) = gaussp(1);
    residual2(stnlocal) = residstd;
    gamcentre2(stnlocal) = gamlims(2);
    gamwidth2(stnlocal) = (gamlims(3)-gamlims(1))/2;
end

varlist_str = [];
for kv = 1:numv
    varlist_str = [varlist_str ' ' varlist{kv}];
end
cmd = ['save ' gauss_fn ' ' varlist_str ]; eval(cmd)

kpr = stnlocal;
fprintf(MEXEC_A.Mfidterm,'%s\n',' stn  pcen  pwid    amp  resid    gcen    gwid');
fprintf(MEXEC_A.Mfidterm,'%4d %5.0f %5.0f %6.3f %6.3f %7.3f %7.3f',kpr,pcentre1(kpr),pwidth1(kpr),amplitude1(kpr),residual1(kpr),gamcentre1(kpr),gamwidth1(kpr))
fprintf(MEXEC_A.Mfidterm,'\n')
% fprintf(MEXEC_A.Mfidterm,'%5.0f %5.0f %5.0f %8.3f %8.3f %8.3f %8.3f\n',pcentre2(kpr),pwidth2(kpr),pwidth3(kpr),amplitude2(kpr),residual2(kpr),gamcentre2(kpr),gamwidth2(kpr))

