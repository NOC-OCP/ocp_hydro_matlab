
        fid=fopen('lll','r');
        kount = 0;
        allv = [];
        alldn = {};
        while 1
            tline = fgetl(fid);
            if ~ischar(tline), break, end
            fprintf(1,'%s %s\n','Processing ',tline);
            h = m_read_header(tline);
            kount = kount+1;
            dn = h.dataname;
            dv = h.version;
            allv = [allv dv];
            alldn = [alldn {dn}];
%             if kount > 10; break; end
            
        end
        fclose(fid);
        
        dnu = unique(alldn);
        vmaxu = nan(size(dnu));
        
        for kl = 1:length(dnu)
            dn = dnu{kl};
            kmat = strmatch(dn,alldn);
            vmat = allv(kmat);
            vmaxu(kl) = max(vmat);
        end
        
        datanames = dnu;
        versions = vmaxu;
        
        save /local/users/pstar/jc159/mcruise/data/mexec_housekeeping/version datanames versions