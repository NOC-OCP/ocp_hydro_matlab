function pdfot = m_refresh(pdfin)
% function pdfot = m_refresh(pdfin)

close
pdfin.ncfile.noflagcheck = 1;
pdfot = m_edplot(pdfin);
return

