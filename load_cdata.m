%script called by gridhsec to load and combine ctd data from file_listc
%using parse_load_hdata
%arrange onto 2D grid, sort by station number as specified, remove depths
%with no good data, and make list of variables to map (not including
%coordinate or flag variables)

%variables to load
if isfield(info, 'vnuc')
    vnuc = info.vnuc;
else
    if isfield(info, 'vnu')
        vnuc = info.vnu;
    else
        vnuc = dataset('File','varnamesunits_lookup.csv', 'Delimiter', ',');
    end
    vnuc.hvar = replace(vnuc.hvar,"ctdtmp","temp");
    vnuc.hvar = replace(vnuc.hvar,"ctdsal","psal");
    vnuc.hvar = replace(vnuc.hvar,"ctdoxy","oxygen");
end

disp(['loading ' num2str(length(file_listc)) ' ctd files'])
tic
if isfield(info, 'statnum')
    cdata = parse_load_hdata(file_listc, vnuc, 'predir', info.ctddir, 'badflags', info.cbadflags, 'statnums', info.statnum, 'expocode', info.expocode);
else
    cdata = parse_load_hdata(file_listc, vnuc, 'predir', info.ctddir, 'badflags', info.cbadflags, 'expocode', info.expocode);
end
toc
disp('ctd loaded')

%do some QC
ii = find(cdata.psal<20 | cdata.psal>40);
if length(ii)>0
    cdata.psal(ii) = NaN;
    if isfield(cdata, 'psal_flag')
        cdata.psal_flag(ii) = 4;
    end
end
ii = find(cdata.oxygen<100 | cdata.oxygen>500);
if length(ii)>0
    cdata.oxygen(ii) = NaN;
    if isfield(cdata, 'oxygen_flag')
        cdata.oxygen_flag(ii) = 4;
    end
end

%take coordinate variables out of list of variables
iil = [];
for cno = 1:length(coordv)
    iil = [iil find(strcmp(coordv{cno}, cdata.vars))];
end
cdata.vars(iil) = []; cdata.unts(iil) = [];

%sort by station number
cdata0 = cdata;
if isfield(info, 'statind')
    [~,ia,ib] = intersect(info.statind, cdata.statnum);
    [a,ia2] = sort(ia); ib = ib(ia2);
    s = info.statind(ia(ia2));
else
    [s,ib] = unique(cdata.statnum(~isnan(cdata.statnum)));
end
cdata.lon = cdata.lon(ib)'; cdata.lat = cdata.lat(ib)';
%and align variable matrix columns onto 2D grid
p = unique(cdata.press(~isnan(cdata.press)));
[n1,~] = size(cdata.temp);
for vno = 1:length(cdata.vars)
    d = cdata.(cdata.vars{vno});
    if size(d,1)==n1
        dg = NaN+zeros(length(p), length(s));
        for sno = 1:length(s)
            iis = find(cdata.statnum==s(sno));
            [~,ipa,ipb] = intersect(cdata.press(iis),p);
            dg(ipb,sno) = d(iis(ipa));
        end
        cdata.(cdata.vars{vno}) = dg;
    end
end
cdata.statnum = s(:)';
cdata.press = p;

%discard depths with no good data
iig = find(sum(~isnan(cdata.temp),2)>0);
for vno = 1:length(cdata.vars)
    d = cdata.(cdata.vars{vno});
    if size(d,1)==length(p)
        cdata.(cdata.vars{vno}) = d(iig,:);
    end
end
cdata.press = p(iig);
disp('ctd arranged')

%take flag variables out of list of variables to map
iil = find(contains(cdata.vars, '_flag'));
cdata.vars(iil) = []; cdata.unts(iil) = [];
