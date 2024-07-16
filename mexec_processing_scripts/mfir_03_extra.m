function mfir_03_extra(stn)
% mfir_03_extra: 
%     merge additional information onto fir file:
%       1) standard deviation during the bottle stop (p within 1 m of
%         firing-time p) from psal file 
%       2) background gradient in 5 m around bottle stop from 2up file
%       3) downcast data at bottle firing neutral density (first smooth and
%         match 2 dbar up- and down-cast data on neutral density, then
%         interpolate shifted downcast data to upcast Niskin firing
%         pressures 
%     
% Use: mfir_03_extra        and then respond with station number, or for station 16
%      stn = 16; mfir_03d;

m_common
opt1 = 'castpars'; opt2 = 'minit'; get_cropt
if MEXEC_G.quiet<=1; fprintf(1,'adds bottle stop background gradient, standard deviation, and gamma_n-matched downcast data to fir_%s_%s.nc\n', mcruise, stn_string); end

root_ctd = mgetdir('M_CTD');
infilef = fullfile(root_ctd, ['fir_' mcruise '_' stn_string]);
otfilef = infilef;
if ~exist(m_add_nc(infilef),'file')
    infilef = [infilef '_ctd'];
    if ~exist(m_add_nc(infilef),'file')
        warning('fir file not found for cast %s',stn_string)
        return
    end
end
[df,hf] = mloadq(infilef,'upress','scan','utime',' ');

infile1 = fullfile(root_ctd, ['ctd_' mcruise '_' stn_string '_psal.nc']);
infiled = fullfile(root_ctd, ['ctd_' mcruise '_' stn_string '_2db.nc']); 
infileu = fullfile(root_ctd, ['ctd_' mcruise '_' stn_string '_2up.nc']);
if ~exist(infile1,'file') || ~exist(infileu,'file')
    warning('missing psal or 2up file for cast %s',stn_string)
    return
end
[d1,~] = mloadq(infile1,'/');
[up,~] = mloadq(infileu,'/');

clear dnew hnew
hnew.fldnam = {}; hnew.fldunt = {};
hnew.comment = [];

%stdev from 1hz psal file, and gradient from 2up file
clear std1 grads
for sno = 1:length(df.upress)
    gp1 = min(up.press(up.press>=df.upress(sno)+2.5));
    gp2 = max(up.press(up.press<=df.upress(sno)-2.5));
    if isempty(gp1) || isempty(gp2)
        grads.temp(sno,1) = NaN;
        grads.cond(sno,1) = NaN;
        grads.oxygen(sno,1) = NaN;
    else
        gii1 = find(up.press==gp1); gii2 = find(up.press==gp2);
        grads.temp(sno,1) = (up.temp(gii2)-up.temp(gii1))/(gp2-gp1);
        grads.cond(sno,1) = (up.cond(gii2)-up.cond(gii1))/(gp2-gp1);
        grads.oxygen(sno,1) = (up.oxygen(gii2)-up.oxygen(gii1))/(gp2-gp1);
    end
    %***replace with code to actually identify bottle stops (check existing
    %code)
    ii = find(abs(d1.press-df.upress(sno))<1 & abs(d1.scan-df.scan(sno))<24*60*20);
    std1.temp(sno,1) = m_nanstd(d1.temp(ii));
    std1.cond(sno,1) = m_nanstd(d1.cond(ii));
    std1.oxygen(sno,1) = m_nanstd(d1.oxygen(ii));
end
dnew.grad_temp = grads.temp; dnew.grad_cond = grads.cond; dnew.grad_oxygen = grads.oxygen;
hnew.fldnam = [hnew.fldnam 'grad_temp' 'grad_cond' 'grad_oxygen'];
hnew.fldunt = [hnew.fldunt 'degC/dbar' 'psu/dbar' 'umol/kg/dbar'];
hnew.comment = [hnew.comment '\n gradients over surrounding 5m from 2up file'];
dnew.std1_temp = std1.temp; dnew.std1_cond = std1.cond; dnew.std1_oxygen = std1.oxygen;
hnew.fldnam = [hnew.fldnam 'std1_temp' 'std1_cond' 'std1_oxygen'];
hnew.fldunt = [hnew.fldunt 'degC' 'psu' 'umol/kg'];
hnew.comment = [hnew.comment '\n stdev at bottle stops from psal (1hz) file'];

var_copycell = mcvars_list(2);
if exist(infiled,'file')
    [dn,hd] = mloadq(infiled,'/');
    [var_copycell, var_copystr] = mvars_in_file(var_copycell, infiled);

    %get down and up T and S on common pressure grid (from 2 dbar data)
    iigd = find(~isnan(dn.temp+dn.psal));
    iigu = find(~isnan(up.temp+up.psal));
    [pg,id,iu] = intersect(dn.press(iigd),up.press(iigu));
    if length(pg)<10
        return
    end
    dn_psal = dn.psal(iigd(id));
    dn_temp = dn.temp(iigd(id));
    up_psal = up.psal(iigu(iu));
    up_temp = up.temp(iigu(iu));

    %call heaveND to find pressure offsets to make filtered up gamma match dn gamma
    dpn = heaveND(dn_psal,dn_temp,up_psal,up_temp,pg,hd.longitude,hd.latitude);
    if ~sum(~isnan(dpn))
        return
    end
    
    %interpolate downcast data from pg-dpn back to upress
    for vno = 1:length(var_copycell)
        vmsk = strcmp(var_copycell{vno},hd.fldnam);
        dnew.(['d' var_copycell{vno}]) = interp1(pg-dpn, dn.(var_copycell{vno})(iigd(id)), df.upress);
        hnew.fldnam = [hnew.fldnam ['d' var_copycell{vno}]];
        hnew.fldunt = [hnew.fldunt hd.fldunt(vmsk)];
    end
    dnew.dtime = df.utime; %keep as bottle firing time
    hnew.fldunt(strcmp('dtime',hnew.fldnam)) = hf.fldunt(strcmp('utime',hf.fldnam));
    hnew.comment = [hnew.comment '\n downcast data matched on neutral density (smoothed using heaveND.m)'];

    %save
    mfsave(otfilef, dnew, hnew, '-addvars');
end
