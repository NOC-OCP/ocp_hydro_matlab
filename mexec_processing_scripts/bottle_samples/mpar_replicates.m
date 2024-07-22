function [d, hnew] = mpar_replicates(ds, tabdatavars, mstarvars, units)
% [d, hnew] = mpar_replicates(ds, tabdatavars, mstarvars, units)
%
% ds is a table including columns sampnum, (tabdatavar), and flag
%
% for each tabdatavar, renames to mstarvar, adds units, separates and
% renames replicates, makes flags consistent, and puts into a structure and
% header suitable for writing to mstar-format .nc files
%


hnew.fldnam = {'sampnum' 'statnum' 'position'};
hnew.fldunt = {'number' 'number' 'on.rosette'};
[d.sampnum, iia, ~] = unique(ds.sampnum, 'stable');

% calculate statnum and position in case they don't already exist
d.statnum = floor(d.sampnum/100); d.position = d.sampnum-d.statnum*100;

ds_fn = ds.Properties.Variablenames;
va = [mstarvar 'a'];
fa = [mstarvar 'a_flag'];

if sum(strcmp(tabdatavar,ds_fn))
    d.botoxya_per_l = ds.(tabdatavar)(iia);
    hnew.fldnam = [hnew.fldnam va fa];
    hnew.fldunt = [hnew.fldunt unit 'woce_9.4'];
else
    error('no %s in input',tabdatavar)
end
if sum(strcmp('flag',ds_fn))
    d.(fa) = ds.flag(iia);
else
    d.(fa) = 2+zeros(size(d.(va));
    d.(fa)(isnan(d.(va))) = 5; %assume if there is a line in the file it's because a sample was drawn
end

if sum(strcmp('fix_temp',ds_fn))
    d.botoxya_temp = ds.fix_temp(iia);
    hnew.fldnam = [hnew.fldnam 'botoxya_temp'];
    hnew.fldunt = [hnew.fldunt 'degC'];
end

iib = setdiff(1:length(ds.sampnum),iia);
%***add code to handle duplicates in different columns on same line? 
if ~isempty(iib) 
    d.botoxyb_per_l = NaN+d.botoxya_per_l;
    d.botoxyb_temp = d.botoxyb_per_l;
    d.botoxyb_flag = 9+zeros(size(d.sampnum));
    [~,ii,iid] = intersect(ds.sampnum(iib),d.sampnum);
    d.botoxyb_per_l(iid) = ds.conc_o2(iib(ii));
    d.botoxyb_temp(iid) = ds.fix_temp(iib(ii));
    d.botoxyb_flag(iid) = ds.flag(iib(ii));
    hnew.fldnam = [hnew.fldnam 'botoxyb_per_l' 'botoxyb_temp' 'botoxyb_flag'];
    hnew.fldunt = [hnew.fldunt 'umol/L' 'degC' 'woce_9.4'];
    iic = setdiff(1:length(ds.sampnum),[iia' iib(ii)]);
    if ~isempty(iic)
        d.botoxyc_per_l = NaN+d.botoxya_per_l;
        d.botoxyc_temp = d.botoxyc_per_l;
        d.botoxyc_flag = 9+zeros(size(d.sampnum));
        [~,ii,iid] = intersect(ds.sampnum(iic),d.sampnum);
        d.botoxyc_per_l(iid) = ds.conc_o2(iic(ii));
        d.botoxyc_temp(iid) = ds.fix_temp(iic(ii));
        d.botoxyc_flag(iid) = ds.flag(iic(ii));
        hnew.fldnam = [hnew.fldnam 'botoxyc_per_l' 'botoxyc_temp' 'botoxyc_flag'];
        hnew.fldunt = [hnew.fldunt 'umol/L' 'degC' 'woce_9.4'];
    end
end
