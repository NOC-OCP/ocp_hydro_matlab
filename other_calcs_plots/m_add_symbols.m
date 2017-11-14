function p = m_add_symbols(p,x,y,s,symstr)
col = p.colortable;

col2 = 1-.2*(1-col);
p.colortable = col2;

% p.yax(1) = 5000;

if p.newplot == 1
    p = mcontrnew(p);
    gca = p.mainplot_gca_handle;
    axes(gca)
end

% bak on jr281, add symbols, in this case tracer concentration, to a
% mexec contour plot
% p is pdf for mexec contour plot
% x is x-value (can be array)
% y is y-value
% s is size is s is -1, default size will be used


x0 = p.xax(1);
x1 = p.xax(2);

y0 = p.yax(1);
y1 = p.yax(2);

xscale = (x-x0)/(x1-x0); % normalise for plotting
yscale = (y-y0)/(y1-y0); 

xscale(xscale<0) = 0;
xscale(xscale>1) = 1;
yscale(yscale<0) = 0;
yscale(yscale>1) = 1;

% keyboard
% axes(p.gca); % set plot to be main contour plot, not the colorbar

if isempty(s)
    plot(xscale, yscale, symstr)
else
    for kl = 1:length(xscale)
        plot(xscale(kl),yscale(kl),symstr,'markersize',s(kl));
    end
end

% keyboard



return