function mctd_compare_sensors(param, ref_sns, compare_sns, klist)
%
% compare, and look for offsets (or scale factors) between different C (or
% O) sensors, as a function of potential temperature and pressure (or
% potential temperature and salinity), with background gradients/variance
% as context?? 
%
% can be used as another check in addition to mctd_checkplots; to check the
% results of applying calibrations; or to estimate an adjustment to apply
% to data from one sensor to make it line up better with the others (e.g.
% if calibration data are not available for all sensors)

% check input s/ns
if ~isempty(intersect(ref_sns, compare_sns))
    error('ref_sns and compare_sns must not overlap')
end
load(fullfile(mgetdir('M_CTD'),'sensor_groups.mat'),'sn_list','sng')
sn_list = sn_list.(param);
a = union(ref_sns,compare_sns);
if ~isempty(setdiff(a,sn_list))
    disp(setdiff(a,sn_list))
    error('above S/Ns not found in sensor_groups.mat')
end
if ~isempty(setdiff(sn_list,a))
    warning('S/Ns being ignored:')
    disp(setdiff(sn_list,a))
end

%load all data and put in either reference or compare data structures
pg = [1:2:8000]';
dref.potemp = NaN+zeros(length(pg),length(klist)*3); %***
dref.psal = dref.potemp;
if strcmp(param,'oxygen')
    dooxy = 1;
    dref.oxygen = dref.potemp;
else
    dooxy = 0;
end
dcomp = dref;
nref = 1; ncomp = 1;
for kloop = klist
    infile = fullfile(mgetdir('M_CTD'),sprintf('ctd_%s_%03d_2db',mcruise,kloop));
    [d,h] = mload(infile,'press temp1 temp2 cond1 cond2 oxygen1 oxygen2');
    [~,ia,ib] = intersect(pg,d.press);
    s1 = h.fldserial(strcmp([param '1'],'h.fldnam'));
    if ismember(s1, ref_sns)
        dref.potemp(ia,nref) = d.potemp1(ib);
        dref.psal(ia,nref) = d.psal1(ib);
        if dooxy; dref.oxygen(ia,nref) = d.oxygen1(ib); end
        nref = nref+1;
    elseif ismember(s1, comp_sns)
        dcomp.potemp(ia,ncomp) = d.potemp1(ib);
        dcomp.psal(ia,ncomp) = d.psal1(ib);
        if dooxy; dcomp.oxygen(ia,nref) = d.oxygen1(ib); end
        ncomp = ncomp+1;
    end
    s2 = h.fldserial(strcmp([param '2'],'h.fldnam'));
    if ismember(s2, ref_sns)
        dref.potemp(ia,nref) = d.potemp2(ib);
        dref.psal(ia,nref) = d.psal2(ib);
        if dooxy; dref.oxygen(ia,nref) = d.oxygen2(ib); end
        nref = nref+1;
    elseif ismember(s2, comp_sns)
        dcomp.potemp(ia,ncomp) = d.potemp2(ib);
        dcomp.psal(ia,ncomp) = d.psal2(ib);
        if dooxy; dcomp.oxygen(ia,nref) = d.oxygen2(ib); end
        ncomp = ncomp+1;
    end
end
iip = find(~isnan(dref.potemp) | ~isnan(dcomp.potemp));
dref.potemp(:,nref+1:end) = []; dref.psal(:,nref+1:end) = []; if dooxy; dref.oxygen(:,nref+1:end) = []; end
dcomp.potemp(:,nref+1:end) = []; dcomp.psal(:,nref+1:end) = []; if dooxy; dcomp.oxygen(:,nref+1:end) = []; end

% now use hydro_tools? ***

% compare
if dooxy

    scatter(dref.potemp,-pg,)

else

end

