[ds hs] = mload('sam_jc159_all.nc','/');
kchl = find(ds.botchla_flag ~= 9);
stns = d.statnum(kchl);
stns = unique(stns);

for kstn = stns(:)'
    stnstr = sprintf('%03d',kstn);
    [dc hc] = mload(['ctd_jc159_' stnstr '_psal.nc'],'/');
    [dd hd] = mload(['dcs_jc159_' stnstr ],'/');
    kdown = find(dc.scan >= dd.scan_start & dc.scan <= dd.scan_bot);
    kup = find(dc.scan >= dd.scan_bot & dc.scan <= dd.scan_end);
    figure(101)
    clf
    plot(dc.fluor(kdown),dc.potemp(kdown),'k-');
    hold on; grid on
    plot(dc.fluor(kup),dc.potemp(kup),'r-');
    set(gca,'YLim',[15 30]);
    xl = get(gca,'XLim');
    kuse = find(ds.statnum == kstn & ds.botchla_flag ~= 9);
    for kl = 1:length(kuse)
        plot(xl*0.9,ds.upotemp(kuse(kl)) + 0*xl,'c-');
    end
    title(stnstr)
    keyboard
    
end