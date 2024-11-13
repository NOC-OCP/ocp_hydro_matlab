function pdfot = mzoom(varargin)
% function pdfot = mzoom(varargin)

m_common
m_margslocal
m_varargs

m = 'Type pdf for initial plot; Type c/r for none: ';
pdfin = m_getinput(m,'v');
if ~isstruct(pdfin); pdfin = []; end


close
pdfin.ncfile.noflagcheck = 1;
MEXEC_A.MARGS_IN_LOCAL_OLD = MEXEC_A.MARGS_IN_LOCAL;
pdfot = m_edplot(pdfin);
MEXEC_A.MARGS_IN_LOCAL = MEXEC_A.MARGS_IN_LOCAL_OLD;
ha = gca;

m1 = 'Select zoom area with crosshairs and mouse click';
m2 = 'Click outside lower left and upper right of plot area to zoom out';
fprintf(MEXEC_A.Mfidterm,'%s\n',m1,m2,' ');

[xl yl] = ginput(2);

m = 'Attempt to create ''nice'' tick values ? Enter y(default) or n: ';
autolim = 1;
var = m_getinput(m,'s');
if strcmp('n',var) == 1; autolim = 0; end

xl = sort(xl(:)');
yl = sort(yl(:)');

% Identify the zoom out case
if (xl(1) < 0) & (xl(2) > 1) & (yl(1) < 0) & (yl(2) > 1)
    xl = [-1 2];
    yl = [-1 2];
end

% xl = get(ha,'xlim');
% yl = get(ha,'ylim');

xr = pdfin.xax(2)-pdfin.xax(1);
yr = pdfin.yax(:,2)-pdfin.yax(:,1);
pdfot.ntick = [10 10];

xlnew = pdfin.xax(1) + xr*xl;
if (autolim == 1) 
    pdfot.xax = m_autolims(xlnew,pdfot.ntick(1));
else
    pdfot.xax = xlnew;
end
if (pdfin.xax(2) < pdfin.xax(1)) & (pdfot.xax(2) > pdfot.xax(1))
    pdfot.xax = fliplr(pdfot.xax);
end

yax = pdfin.yax;
numy = size(yax,1);
for k = 1:numy
    yaxnew(k,:) = yax(k,1) + (yax(k,2)-yax(k,1))*yl;
    if (autolim == 1)
        yaxnew2(k,:) = m_autolims(yaxnew(k,:),pdfot.ntick(2));
    else
        yaxnew2(k,:) = yaxnew(k,:);
    end
end
pdfot.yax = yaxnew2;
for k = 1:numy
    if (pdfin.yax(k,2) < pdfin.yax(k,1)) & (pdfot.yax(k,2) > pdfot.yax(k,1))
        pdfot.yax(k,:) = fliplr(pdfot.yax(k,:));
    end
end

close
pdfot.ncfile.noflagcheck = 1;
pdfot = m_edplot(pdfot);
return

