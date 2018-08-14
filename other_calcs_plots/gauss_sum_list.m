mcd ctd
gauss_fn = 'gauss_sum.mat';
load(gauss_fn);

num_stns = length(pcentre1);

kpr = stnlocal;
fprintf(MEXEC_A.Mfidterm,'%s\n',' stn  pcen  pwid    amp  resid    gcen    gwid    inv     pcen pwid2 pwid3    amp  resid    gcen    gwid');

kskip = [ 3 4 5 6 7 8 9 10 11 12 13 17 28 32 37 40:42 44:46 48:50 52:54 56:58 60:61 ];
kprok = [];
for kpr = 1:num_stns
    if ~isempty(find(kpr == kskip)); continue; end
    kprok = [kprok kpr];
    fprintf(MEXEC_A.Mfidterm,'%4d %5.0f %5.0f %6.3f %6.3f %7.3f %7.3f',kpr,pcentre1(kpr),pwidth1(kpr),amplitude1(kpr),residual1(kpr),gamcentre1(kpr),gamwidth1(kpr))
    inv1 = amplitude1(kpr)*pwidth1(kpr);
    fprintf(MEXEC_A.Mfidterm,' %6.1f',inv1)
    fprintf(MEXEC_A.Mfidterm,'\n')
%     fprintf(MEXEC_A.Mfidterm,'    %5.0f %5.0f %5.0f %6.3f %6.3f %7.3f %7.3f\n',pcentre2(kpr),pwidth2(kpr),pwidth3(kpr),amplitude2(kpr),residual2(kpr),gamcentre2(kpr),gamwidth2(kpr))
end
