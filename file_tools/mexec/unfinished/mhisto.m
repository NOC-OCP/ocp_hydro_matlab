function mhisto(varargin)

% plot histogram

m_common
m_margslocal
m_varargs

MEXEC_A.Mprog = 'mhisto';
if ~MEXEC_G.quiet; m_proghd; end


fn = m_getfilename; % this uses the optional argument if there is one
ncfile.name = fn;
ncfile = m_ismstar(ncfile); %check it is an mstar file and that it is not open

h = m_read_header(ncfile);
if ~MEXEC_G.quiet; m_print_header(h); end


m_figure
while 1 > 0
    m = 'Type variable name or number to display (return to finish):      ';
    var = m_getinput(m,'s');
    if strcmp(' ',var) == 1; break; end
    varnum = m_getvlist(var,h);
    vdata = nc_varget(ncfile.name,h.fldnam{varnum});
    vr = reshape(vdata,1,numel(vdata));
    lwr = min(vr);
    upr = max(vr);
    step = (upr-lwr)/20;

    m = 'Type limits for histogram (start end [step]) (return for default)  ';
    reply = m_getinput(m,'s');
    if strcmp(' ',reply) == 1
        % don't change lwr:step:upr
    else
        cmd = ['lims = [' reply '];']; %convert char response to number
        eval(cmd);
        lwr = lims(1);
        upr = lims(2);
        if length(lims) == 2;
            step = (upr-lwr)/20;
        else
            step = lims(3);
        end
    end

    edges = lwr:step:upr;
    vr = reshape(vr,1,numel(vr));
    vd = vr(find(vr >=lwr & vr <= upr));
    meanvd = mean(vd);
    sdevvd = std(vd);
    numvd = length(vd);
    mdianvd = median(vd);
    n = histc(vr,edges);
    bar(edges,n,'histc');
    
    ha = gca;
    set(ha,'position',[.1 .15 .7 .7]);

    ax = axis;
    xr = ax(2)-ax(1); % xrange
    yr = ax(4)-ax(3); % y ranges


    plot_title = [h.dataname '  <vers>  ' sprintf('%d',h.version)];
    hh = title(plot_title); set(hh,'interpreter','none');

    str = datestr(now,31);
    dateposx = ax(1) + 0 * xr;
    dateposy = ax(3) + 1.02 * yr(1);
    hh = text(dateposx,dateposy,str); %position normalised on xax and yax scales
    set(hh,'verticalalignment','bottom')
    
    stats = sprintf('    median: %f   mean: %f   sd: %f   number: %d',mdianvd,meanvd,sdevvd,numvd)
    str = [MEXEC_A.Mprog stats];
    progposx = ax(1) + 0 * xr;
    progposy = ax(3) + 1.1 * yr(1);
    hh = text(progposx,progposy,str); %position normalised on xax and yax scales
    set(hh,'verticalalignment','bottom')

%     hh = xlabel(h.fldnam{varnum}); set(hh,'interpreter','none');
%     hh = ylabel('number'); set(hh,'interpreter','none');

    % x label
strx = h.fldnam{varnum};
strxu = ['(' m_remove_outside_spaces(h.fldunt{varnum}) ')'];
xlabx = .5;
xlaby = -0.06;
xlabxu = .5;
xlabyu = -0.12;

xlabx = ax(1) + xr * xlabx;
xlaby = ax(3) + yr(1) * xlaby;
hh = text(xlabx,xlaby,strx); %position normalised on xax and yax scales
set(hh,'verticalalignment','top', 'horizontalalignment','center')
set(hh,'interpreter','none')
xlabxu = ax(1) + xr * xlabxu;
xlabyu = ax(3) + yr(1) * xlabyu;
hh = text(xlabxu,xlabyu,strxu); %position normalised on xax and yax scales
set(hh,'verticalalignment','top', 'horizontalalignment','center')
set(hh,'interpreter','none')



% strings for y variables
clear ystr;

xshift = -0.12;
yshift = 1;

xshift = ax(1) + xr * xshift;
yshift = ax(3) + yr(1) * yshift;

ystr = 'number per bin';
hh = text(xshift,yshift,ystr);
set(hh,'verticalalignment','top','horizontalalignment','right','rotation',90);




end

return



