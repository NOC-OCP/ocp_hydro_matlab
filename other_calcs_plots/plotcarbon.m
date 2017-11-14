mcd ctd

s  = mload('sam_di346_all','/');

m_figure
vars = {'dic' 'upotemp'}
vars = {'dic' 'udens'}
vars = {'dic' 'upress'}
s.udens = sw_dens(s.upsal,s.utemp,s.upress);
for kstn = 1:45
    kmat = find(s.statnum == kstn);
    cmd = ['x = s.' vars{1} ';']; eval(cmd);
    cmd = ['y = s.' vars{2} ';']; eval(cmd);
    x = x(kmat); 
    y = y(kmat);
    kok = isfinite(x+y);
   plot(x(kok),-y(kok),'+-'); hold on; grid on;
end