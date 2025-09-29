function repl_check(dbot, compare_params, varargin)
% repl_check(dbot, compare_params)
% repl_check(dbot, compare_params, ctd_compare_params)
%
% from table dbot, plot replicate samples and flag deviations over
% threshold specified in samcth, comparing in terms of ratio (replB/replA,
% etc.) or difference (replB-replA, etc.) as specified
% for oxy, sal, chl CTD data from bottle firing times from the sam_ file
% will also be compared (ufluor/chla, or upsal-botpsala, etc.)
% and if mapped data exist ***
%

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

%to determine which variables to check, look for those with corresponding
%*_flag variables (these were added earlier in msam_load)
v = dbot.Properties.VariableNames;
mf = cellfun(@(x) endsWith(x,'_flag'), v);
vflg = v(mf); %flag variable names
vbot = cellfun(@(x) x(1:end-5), vflg, 'UniformOutput', false); %bottle variable names
%for backwards compatibility in case we have e.g. botoxya_per_l,
%botoxya_flag, botoxyb_per_l, botoxyb_flag, etc.
upl = 0;
if ~isempty(setdiff(vbot, v))
    vbot = cellfun(@(x) [x '_per_l'], vbot, 'UniformOutput', false);
    upl = 1;
    if ~isempty(setdiff(vbot, v))
        error('replicate name pattern not recognised')
    end
end

%do we have replicates?
if upl
    vbases = unique(cellfun(@(x) x(1:end-1),vbot,'UniformOutput',false)); %***upl***
    %are there *b_per_l variables with corresponding *a_per_l variables?
    mb = cellfun(@(x) contains(x,'b_per_l'), vbot);
    vba = cellfun(@(x) replace(x,'b_per_l','a_per_l'), vbot(mb), 'UniformOutput', false);
else
    vbases = unique(cellfun(@(x) x(1:end-1),vbot,'UniformOutput',false)); %***upl***
    %are there *b variables with corresponding *a variables?
    mb = cellfun(@(x) strcmp(x(end),'b'), vbot);
    vba = cellfun(@(x) [x(1:end-1) 'a'], vbot(mb), 'UniformOutput', false);
end
vbotr = sum(ismember(vba, vbot));
if ~vbotr
    fprintf(1,'no replicates for %s, skipping',samtyp)
    return
end

%cvars and cvar are CTD variables to load from sam_ file
cvars = 'sampnum statnum position upress';
switch samtyp
    case 'sal'
        cvar = 'upsal';
        useratio = 0;
    case 'oxy'
        cvar = 'uoxygen';
        useratio = 1;
    case 'chl'
        cvar = 'ufluor';
        useratio = 1; %***
    case 'nut'
        cvar = '';
        useratio = 1; %***
end
if ~isempty(cvar) && ~contains(cvars,cvar)
    %need to load svar
    cvars = [cvars ' ' cvar];
end
[dctd,hctd] = mloadq(fullfile(mgetdir('ctd'),sprintf('sam_%s_all.nc',mcruise)),cvars);
dctd = struct2table(dctd);%,'AsArray',true);
[~,~,ib] = intersect(dctd.Properties.VariableNames,hctd.fldnam);
dctd.Properties.VariableUnits = hctd.fldunt(ib);
[~,isam,ictd] = intersect(dbot.sampnum,dctd.sampnum);
%uvars and uvar are underway variables to load from ***
%***

repl_compare(dbot, vbases)

function repl_compare(dbot, vbases)

%plot parameters
%colors
if useratio
    t = '/bottle A -1';
    ti = ['(bottle B+/-' num2str(th*100) '%)/bottle A -1'];
else
    t = '-bottle A';
    ti = ['bottle B+/-' num2str(th) '-bottle A'];
end
alph = 'ABCDEFGHIJKLMNOP';

%loop through parameters with replicates
for vno = 1:length(vbases)
    vbase = vbases{vno};
    m = strncmp(vbase,v,length(vbase));
    mv = m & ismember(v,vbot); %variable names that start with vbase
    mf = m & ismember(v,vflg);

    f = dbot{:,mf}; %flags for all replicates -- names are in alphabetical order so this should match
    d = dbot{:,mv}; d(f~=2) = NaN; %all replicates with good data
    d3 = dbot{:,mv}; d3(f~=3) = NaN; %questionable ones
    nr = sum(mv)-1;
    %compare all other replicates to 'a' replicate
    sama = repmat(d(:,1),1,nr);
    if useratio
        dbc = d(:,2:end)./sama-1;
        dbc3 = d3(:,2:end)./sama-1;
        if th<1
            eint = [d(:,2)*(1-th) d(:,2)*(1+th)]./repmat(sama(:,1),1,2)-1;
        else
            eint = [d(:,1)/th d(:,2)*th]./repmat(sama(:,1),1,2)-1;
        end
    else
        dbc = d(:,2:end) - sama;
        dbc3 = d3(:,2:end) - sama;
        eint = [d(:,2)-th d(:,2)+th] - repmat(sama(:,1),1,2);
    end
    mchk = sum(dbc<eint(:,1) | dbc>eint(:,2), 2);

    if ~sum(mchk)
        fprintf(1,'all %s replicates agree within %f',vbase,th)
        continue
    end

    if ~isempty(cvar)
        ds = sama+NaN;
        %compare sensor data to 'a' replicate
        if useratio
            ds(isam) = dctd.(cvar)(ictd)./sama(isam)-1;
        else
            ds(isam) = dctd.(cvar)(ictd) - sama(isam);
        end
    end

    %plot all the comparisons
    x = dbot.sampnum;
    [mc, mu, ms] = m_sampnum(x);

    if sum(mc)
        figure(1); clf
        if isempty(cvar)
            hl0 = plot(NaN,NaN);
        else
            hl0 = plot(x(mc), ds(mc), '<', 'color', [.8 .8 1], 'DisplayName', 'CTD vs bottle A'); hold on
        end
        hli = plot([x(mc) x(mc)]', eint(mc,:)', 'color', [.3 .3 .3], 'DisplayName', ti); hold on
        hl3 = plot(x(mc), dbc3(mc,:), 'o');
        hl = plot(x(mc), dbc(mc,:), 'o');
        set([hl0; hl3; hl],'linestyle','none')
        for no = 1:nr
            set(hl(no), 'DisplayName', ['bottle ' alph(no+1) t]);
            set(hl3(no), 'markerfacecolor', get(hl3(no), 'color'));
        end
        hlq = plot(x(mchk&mc), dbc(mchk&mc,:), '.r');
        legend([hl0; hli(1); hl])
        grid on; title(['Niskin ' samtyp])
    end
    if sum(mu)
        figure(2); clf
        hli = plot([x(mu) x(mu)]', eint(mu,:)', 'color', [.3 .3 .3], 'DisplayName', ti); hold on
        hl3 = plot(x(mu), dbc3(mu,:), 'o');
        hl = plot(x(mu), dbc(mu,:), 'o');
        for no = 1:nr
            set(hl(no), 'color', cmap(no,:), 'DisplayName', ['bottle ' alph(no+1) t]);
            set(hl3(no), 'color', cmap3(no,:), 'markerfacecolor', cmap3(no,:));
        end
        hlq = plot(x(mchk&mu), dbc(mchk&mu,:), '.r');
        legend([hli; hl])
        grid on; title(['UCSW ' samtyp])
    end
    if sum(ms)
        figure(3); clf
        hli = plot([x(ms) x(ms)]', eint(ms,:)', 'color', [.3 .3 .3], 'DisplayName', ti); hold on
        hl = plot(x(ms), dbc(ms,:), 'o');
        for no = 1:nr
            set(hl(no), 'color', cmap(no,:)', 'DisplayName', ['bottle ' alph(no+1) t]);
        end
        hlq = plot(x(mchk&ms), dbc(mchk&ms,:), '.r');
        legend([hli; hl])
        grid on; title(['(sub)standard ' samtyp])
    end

    c = 'p';
    while strcmp(c,'p') || strcmp(c,'k')
        c = input('p to print list of differing replicates, k for keyboard or enter to continue  ','s');
        if strcmp(c,'p')
            %display mismatched replicates
            disp('sampnum, deviating replicate values, flags')
            disp([dbot.sampnum(mchk) dbot(:,mv) dbot(:,mf)])
        elseif strcmp(c,'k')
            keyboard
        end
    end

end
