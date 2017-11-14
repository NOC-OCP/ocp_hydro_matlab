d = mtload('posmvpos',0,now-1/1440,'long lat')

m_figure

plot(d.long,d.lat)
axmerc2
title('jc069')
grid on