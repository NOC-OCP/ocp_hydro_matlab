function gvelbot = mcbotref(gvel)

% make geost vel rel to deepest non-nan level

for kloop1 = 1:size(gvel,2)

    gv = gvel(:,kloop1);
    kmax = max(find(~isnan(gv)));
    klev = kmax;
    gv = gv-gv(klev);
    gvelbot(:,kloop1) = gv;

end
