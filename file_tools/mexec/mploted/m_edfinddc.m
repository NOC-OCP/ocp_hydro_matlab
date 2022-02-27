function kfind = mfind_dc(pdfin)
% function kfind = mfind_dc(pdfin)

m_common
global x1 x2 r1 r2 c1 c2

pdfot = pdfin;
ha = gca;

m1 = 'Select data area with crosshairs and mouse click';
fprintf(MEXEC_A.Mfidterm,'%s\n',m1,' ');

[xa ya] = ginput(1);
hx = plot([0 1],[ya ya],'c--','linewidth',2);
hy = plot([xa xa],[0 1],'c--','linewidth',2);
[xb yb] = ginput(1);
xl = [xa xb];
yl = [ya yb];
set(hx,'xdata',[nan nan]);
set(hy,'ydata',[nan nan]);
hbox = plot([xa xb xb xa xa],[ya ya yb yb ya],'c--','linewidth',2);
% [xl yl] = ginput(2);


xl = sort(xl(:)');
yl = sort(yl(:)');


xr = pdfin.xax(2)-pdfin.xax(1);
yr = pdfin.yax(:,2)-pdfin.yax(:,1);

xldata = pdfin.xax(1) + xr*xl;

yax = pdfin.yax;
numy = size(yax,1);
for k = 1:numy
    yldata(k,:) = yax(k,1) + (yax(k,2)-yax(k,1))*yl;
end

%turn x and y var lists to numbers
h = m_read_header(pdfin.ncfile);
xnumlist = m_getvlist(pdfin.xlist,h);
ynumlist = m_getvlist(pdfin.ylist,h);

xnum = xnumlist(1);
xname = h.fldnam{xnum};
x = nc_varget(pdfin.ncfile.name,xname,[r1-1 c1-1],[r2-r1+1,c2-c1+1]);
x = reshape(x,1,numel(x));

% fiddle with the x data if x is a time variable
% if x is not a timevariable, time_scale == 0
global fstruct
time_scale = fstruct.time_scale;
if isfield(fstruct,'time_start_do'); time_start_do = fstruct.time_start_do; end
if isfield(fstruct,'time_start'); time_start = fstruct.time_start; end
xscale = fstruct.xscale;


switch time_scale
    % recall that 
    % x contains the data in days or seconds after the data_time_origin; 
    % xscale will convert to days after data_time_origin is required.
    % time_start_do is the time of the start time in days after the data_time_origin
    % case 0 is when x is not a time variable
    % In other cases x is a time variable and we control the scaling of x
    case 0
    case 1
        xunits = 'seconds after start time';
        x = 86400*(xscale*x-time_start_do);
    case 2
        xunits = 'minutes after start time';
        x = 1440*(xscale*x-time_start_do);
    case 3
        xunits = 'hours after start time';
        x = 24*(xscale*x-time_start_do);
    case 4
        xunits = 'days after start time';
        x = 1*(xscale*x-time_start_do);
    case 9
        t0 = datevec(time_start);
        y0 = t0(1);
        x = 1 + xscale*x + datenum(h.data_time_origin) - datenum([y0 1 1 0 0 0]);
    otherwise
end

numy = length(ynumlist);
yname = {}; y = [];
for k =1:numy
    ykname = h.fldnam{ynumlist(k)};
    yname = [yname ; ykname];
    yk = nc_varget(pdfin.ncfile.name,ykname,[r1-1 c1-1],[r2-r1+1,c2-c1+1]);
    yk = reshape(yk,1,numel(yk)); % reshape to rows
    y = [y; yk];
end

for k = 1:numy
    %     kfind{k} = find((xldata(1) < x) & (x < xldata(2)) & (yldata(k,1) < y(k,:)) & (y(k,:) < yldata(k,2)));
    kfind{k} = find(((x-xldata(1)).*(x-xldata(2)) < 0) & ((yldata(k,1)-y(k,:)).*(yldata(k,2)-y(k,:)) < 0));
end

return

