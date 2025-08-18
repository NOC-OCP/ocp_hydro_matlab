function repl_check(samtyp, dsam, th)
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
        bunit = 'umol/L'; %***
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
        dnew.press = nan+dnew.sampnum; [~,ia,ictd] = intersect(dnew.sampnum,dsam.sampnum);
        dnew.press(ia) = dsam.upress(ictd);
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
        useratio = 1; %***
    otherwise
        useratio = 0;
end
if ~contains(svars,svar)
    %need to load svar
    svars = [svars ' ' svar];
end

%which sample replicates do we need to check?
if useratio
    %ratio over threshold
    mchk = abs(dsam.(varb)./dsam.(vara)-1)>th;
    if isfield(dsam,varc)
        mchk = mchk | abs(dsam.(varc)./dsam.(vara)-1)>th | abs(dsam.(varc)./dsam.(varb)-1)>th;
    end
else
    %difference over threshold
    mchk = abs(dsam.(varb) - dsam.(vara))>th;
    if isfield(dsam,varc)
        mchk = abs(dsam.(varc) - dsam.(vara))>th | abs(dsam.(varc) - dsam.(varb))>th;
    end
end

if sum(mchk)

    %get matching CTD data
    [dctd,~] = mloadq(fullfile(mgetdir('ctd'),sprintf('sam_%s_all.nc',mcruise)),svars);
    [~,isam,ictd] = intersect(dsam.sampnum,dctd.sampnum);

    %arrange as columns
    sam = [dsam.(vara) dsam.(varb)]; samf = [dsam.(flga) dsam.(flgb)];
    if isfield(dsam,varc)
        sam = [sam dsam.(varc)]; samf = [samf dsam.(flgc)];
    end
    ctd = repmat(dctd.(svar),1,size(sam,2));
    if useratio
        y = sam(isam,:)./ctd(ictd,:);
    else
        y = sam(isam,:) - ctd(ictd,:);
    end

    %NaN based on flags
    pbad = sam; pbad(samf~=4) = NaN; %bad
    pque = sam; pque(samf~=3) = NaN; %questionable
    sam = sam(mchk,:);
    pque = pque(mchk,:);
    pbad = pbad(mchk,:);
    samp0 = dsam.sampnum(mchk);
    
    [~,ia0,ib0] = intersect(samp0,dctd.sampnum);edit 
%'DisplayName'
    figure(1); clf
    ctd = repmat(dctd.(svar)(ib0),1,size(sam,2)); nr = length(ia);
    if useratio
        r = dsam.(vara)(ia)./dctd.uoxygen(ictd);
        rint = [dsam.(vara)(ia)*(1-thp) dsam.(vara)(ia)*(1+thp)]./repmat(dctd.(svar)(ictd),1,2);
        hl = plot([dsam.sampnum(ia) dsam.sampnum(ia)]',rint',...
            dctd.sampnum(ib0),pbad./ctd,'x', dctd.sampnum(ib0),pque./ctd,'+',...
            dsam.sampnum(ia),r,'.b', dctd.sampnum(ib0),sam(ia0,:)./ctd,'o');
        ylabel('oxygen bot/ctd'); xlabel('sampnum'); grid
        legend(hl([1 end-3:end]),['+/-' num2str(thp) ' factor on bottle value'],'all (a)','a','b','c','location','southwest');
        set(hl(1:nr),'color',[.5 .5 .5]); set(hl(nr+1:end-4),'color',[0 0 0])
    else
    end
    title('flagged bad x, questionable +')
    c = input('k for keyboard or enter to continue  ','s');
    if strcmp(c,'k'); keyboard; end

end
