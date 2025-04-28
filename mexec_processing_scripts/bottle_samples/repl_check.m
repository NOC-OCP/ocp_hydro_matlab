function repl_check(samtyp, d, th, stn_start)
%
% plot replicate samples and flag deviations over th
% comparison will be done in terms of ratio or difference depending on
% samtyp
%

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

thp = th*5;
svars = 'sampnum statnum position';
switch samtyp
    case 'chl'
        svars = [svars ' ufluo upress'];
        svar = 'ufluo';
        vara = 'chla'; varb = 'chlb'; varc = 'chlc';
        flga = 'chla_flag'; flgb = 'chlb_flag'; flgc = 'chlc_flag';
        useratio = 1; %***
    case 'oxy'
        svars = [svars ' uoxygen upress'];
        svar = 'uoxygen';
        vara = 'botoxya_per_l'; varb = 'botoxyb_per_l'; varc = 'botoxyc_per_l';
        flga = 'botoxya_flag'; flgb = 'botoxyb_flag'; flgc = 'botoxyc_flag';
        bunit = 'umol/L';
        useratio = 1;
    case 'nut'
        %***subplots for different variables below? 
            dnew.press = nan+dnew.sampnum; [~,ia,ib] = intersect(dnew.sampnum,dsam.sampnum); 
            dnew.press(ia) = dsam.upress(ib);
            vars = fieldnames(dnew);
            vars = vars(contains(vars,'_flag'));
            vars = cellfun(@(x) x(1:end-6),vars,'UniformOutput',false);
            vars = unique(vars);
            figure(1); clf
            for vno = 1:length(vars)
                sa = [vars{vno} 'a_per_l'];
                sb = [vars{vno} 'b_per_l'];
                iiq = find(abs(dnew.(sa)./dnew.(sb)-1)>orth);
                subplot(1,length(vars),vno)
                plot(dnew.(sa),-dnew.press,'.',dnew.(sa)(~isnan(dnew.(sb))),-dnew.press(~isnan(dnew.(sb))),'o',dnew.(sb),-dnew.press,'s',dnew.(sa)(iiq),-dnew.press(iiq),'x',dnew.(sb)(iiq),-dnew.press(iiq),'+')
            end
            dnew = rmfield(dnew,'press');

    otherwise
        useratio = 0;
end

if useratio
        %ratio
        m0 = abs(d.(vara)./d.(varb)-1)>th;
        q = [d.(vara) d.(varb)];
        qf = [d.(flga) d.(flgb)];
        if isfield(d,varc)
            m0 = m0 | abs(d.(varc)./d.(vara)-1)>th | abs(d.(varc)./d.(varb)-1)>th;
            q = [q d.(varc)]; qf = [qf d.(flgc)];
        end
else
        %difference***
end

if sum(m0)
    qb = q; qb(qf~=4) = NaN;
    qq = q; qq(qf~=3) = NaN;
    q = q(m0,:);
    qq = qq(m0,:);
    qb = qb(m0,:);
    samp0 = d.sampnum(m0);
    [ds,hs] = mloadq(fullfile(mgetdir('ctd'),sprintf('sam_%s_all.nc',mcruise)),svars);
    [~,ia,ib] = intersect(d.sampnum,ds.sampnum);
    [~,ia0,ib0] = intersect(samp0,ds.sampnum);

    figure(1); clf
    y = repmat(ds.(svar)(ib0),1,size(q,2)); nr = length(ia);
    if useratio
    r = d.(vara)(ia)./ds.uoxygen(ib);
    rint = [d.(vara)(ia)*(1-thp) d.(vara)(ia)*(1+thp)]./repmat(ds.(svar)(ib),1,2);    
    hl = plot([d.sampnum(ia) d.sampnum(ia)]',rint',...
        ds.sampnum(ib0),qb./y,'x', ds.sampnum(ib0),qq./y,'+',...
        d.sampnum(ia),r,'.b', ds.sampnum(ib0),q(ia0,:)./y,'o');
    ylabel('oxygen bot/ctd'); xlabel('sampnum'); grid
    legend(hl([1 end-3:end]),['+/-' num2str(thp) ' factor on bottle value'],'all (a)','a','b','c','location','southwest');
    set(hl(1:nr),'color',[.5 .5 .5]); set(hl(nr+1:end-4),'color',[0 0 0])
    else
    end
    title('flagged bad x, questionable +')
    c = input('k for keyboard or enter to continue  ','s');
    if strcmp(c,'k'); keyboard; end

end
