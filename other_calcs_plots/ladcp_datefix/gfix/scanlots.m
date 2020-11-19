
inst = '75';
for kblock = 1:41
    block = sprintf('%03d',kblock);
    close
    m_figure
    orient landscape
    printfn = ['clockoff_' inst '_' block];

    for kseq  = 0:8


        zz = scanenx(inst,block,kseq);
        
        if isempty(zz); continue; end

        pcfracs = zz.pctimesraw - floor(zz.pctimesraw);
        utcfrac = zz.utcfraclast;
        pcoff = zz.pcoff;

        codasmed = m_nanmedian(pcoff);

        offcalc = mcrange(86400*(pcfracs-utcfrac),-43200,43200);
        subplot(3,3,kseq+1)
        plot(offcalc,'k','linewidth',2);
        hold on; grid on;
        plot(pcoff,'r','linewidth',1);
        title({['OS' inst ' Block ' block ' seq ' sprintf('%3d',kseq)];['median is ' sprintf('%6.1f',codasmed)]})
        axis([0 7000 -200 209]);
        cmd = ['print -dpsc ' printfn]; eval(cmd);

    end

end