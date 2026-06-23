function pdfot = m_niceticks(pdfin)
% function pdfot = m_niceticks(pdfin)

pdfot = pdfin;
ha = gca;

xl = get(ha,'xlim');
yl = get(ha,'ylim');

xr = pdfin.xax(2)-pdfin.xax(1);
yr = pdfin.yax(:,2)-pdfin.yax(:,1);

xlnew = pdfin.xax(1) + xr*xl;

pdfot.ntick = [10 10];
pdfot.xax = m_autolims(xlnew,pdfot.ntick(1));

yax = pdfin.yax;
numy = size(yax,1);

for k = 1:numy
    yaxnew(k,:) = yax(k,1) + (yax(k,2)-yax(k,1))*yl;
    yaxnew2(k,:) = m_autolims(yaxnew(k,:),pdfot.ntick(2));
end
pdfot.yax = yaxnew2;

pdfot.ncfile.noflagcheck = 1;
pdfot = m_edplot(pdfot);
return

