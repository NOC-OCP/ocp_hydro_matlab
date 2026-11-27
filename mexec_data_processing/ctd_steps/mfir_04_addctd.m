function mfir_04_addctd(stn)
% mfir_04_addctd: merge ctd upcast data including time onto fir file
%   and optionally, if set in opt_cruise,
%     merge additional information onto fir file:
%       1) standard deviation during the bottle stop (p within 1 m of
%         firing-time p) from psal file
%       2) background gradient in 5 m around bottle stop from 2up file
%       3) downcast data at bottle firing neutral density (first smooth and
%         match 2 dbar up- and down-cast data on neutral density, then
%         interpolate shifted downcast data to upcast Niskin firing
%         pressures

m_common
opt1 = 'setup'; opt2 = 'pfiles'; run(MEXEC_G.opt_cruise)
if ~exist(m_add_nc(pfiles.ctd_nisk),'file')
    warning('station %s fir file not found; skipping',stn_string)
    return
end
if MEXEC_G.quiet<=1; fprintf(1,'adds CTD data corresponding to Niskin closures to %s\n', pfiles.ctd_nisk); end

var_copycell = mcvars_to_average(2); %which variables to copy from 24hz CTD file
% remove any vars from copy list that aren't available in the input file
[var_copycell, var_copystr] = mvars_in_file(var_copycell, pfiles.ctd_1hz);
if ~sum(strcmp('scan',var_copycell)); var_copystr = ['scan ' var_copystr]; end

%load and average data
opt1 = 'ctd_proc'; opt2 = 'fir_fill'; run(MEXEC_G.opt_cruise)
[dfir, ~] = mload(pfiles.ctd_nisk,'scan',' ');
[dc, hc] = mload(pfiles.ctd_1hz,'/');
m = ismember(hc.fldnam,[var_copycell 'scan']);
dc = struct2table(dc);
dc.Properties.VariableNames = hc.fldnam;
dc = table2struct(dc(:,m),'ToScalar',true);
hc.fldnam = hc.fldnam(m);
hc.fldunt = hc.fldunt(m);
if isfield(hc,'fldserial')
    hc.fldserial = hc.fldserial(m);
end
dc = grid_1D(dc, 'scan', dfir.scan, firmethod, firopts);

%this will go into sam_all file, so use cruise time origin, not cast time origin
timunt = ['seconds since ' MEXEC_G.data_time_origin_string];
dc.time = m_commontime(dc,'time',hc,timunt);
hc.fldunt{strncmp(hc.fldnam,'time',4)} = timunt;

%copy and rename (for upcast) selected variables
clear dnew hnew
hnew.latitude = hc.latitude; hnew.longitude = hc.longitude; hnew.water_depth_metres = hc.water_depth_metres;
[~,~,ii] = intersect(var_copycell,hc.fldnam,'stable');
hnew.fldnam = cellfun(@(x) ['u' x], hc.fldnam(ii),'UniformOutput',false);
hnew.fldunt = hc.fldunt(ii);
hnew.fldserial = hc.fldserial(ii);
dnew = struct2table(dc);
dnew = dnew(:,ii);
dnew.Properties.VariableNames = hnew.fldnam;
dnew = table2struct(dnew,'ToScalar',true);
hnew.comment = hc.comment;

MEXEC_A.Mprog = mfilename;
mfsave(pfiles.ctd_nisk, dnew, hnew, '-addvars');

opt1 = 'ctd_proc'; opt2 = 'fir_extra'; run(MEXEC_G.opt_cruise)
if fir_extra
    if MEXEC_G.quiet<=1; fprintf(1,'adds bottle stop background gradient, standard deviation, and gamma_n-matched downcast data to fir_%s_%s.nc\n', mcruise, stn_string); end

    if ~exist(pfiles.ctd_1hz,'file') || ~exist(pfiles.ctd_2db_up,'file')
        warning('missing 1hz or 2up file for cast %s',stn_string)
        return
    end
    [up,~] = mloadq(pfiles.ctd_2db_up,'/');

    fpress = dnew.upress; ftime = dnew.utime; ftu = hnew.fldunt(strcmp(hnew.fldnam,'utime'));
    clear dnew hnew
    hnew.fldnam = {}; hnew.fldunt = {};
    hnew.comment = [];

    %stdev from 1hz psal file, and gradient from 2up file
    clear std1 grads
    for sno = 1:length(fpress)
        gp1 = min(up.press(up.press>=fpress(sno)+2.5));
        gp2 = max(up.press(up.press<=fpress(sno)-2.5));
        if isempty(gp1) || isempty(gp2)
            grads.temp(sno,1) = NaN;
            grads.cond(sno,1) = NaN;
            grads.oxy(sno,1) = NaN;
        else
            gii1 = find(up.press==gp1); gii2 = find(up.press==gp2);
            grads.temp(sno,1) = (up.temp(gii2)-up.temp(gii1))/(gp2-gp1);
            grads.cond(sno,1) = (up.cond(gii2)-up.cond(gii1))/(gp2-gp1);
            grads.oxy(sno,1) = (up.oxy(gii2)-up.oxy(gii1))/(gp2-gp1);
        end
        %***replace with code to actually identify bottle stops (check existing
        %code for winch analysis or m_moorproc_toolbox)
        ii = find(abs(dc.press-fpress(sno))<1 & abs(dc.scan-dfir.scan(sno))<24*60*20);
        std1.temp(sno,1) = m_nanstd(dc.temp(ii));
        std1.cond(sno,1) = m_nanstd(dc.cond(ii));
        std1.oxy(sno,1) = m_nanstd(dc.oxy(ii));
    end
    dnew.grad_temp = grads.temp; dnew.grad_cond = grads.cond; dnew.grad_oxy = grads.oxy;
    hnew.fldnam = [hnew.fldnam 'grad_temp' 'grad_cond' 'grad_oxy'];
    hnew.fldunt = [hnew.fldunt 'degC/dbar' 'psu/dbar' 'umol/kg/dbar'];
    hnew.comment = [hnew.comment '\n gradients over surrounding 5m from 2up file'];
    dnew.std1_temp = std1.temp; dnew.std1_cond = std1.cond; dnew.std1_oxy = std1.oxy;
    hnew.fldnam = [hnew.fldnam 'std1_temp' 'std1_cond' 'std1_oxy'];
    hnew.fldunt = [hnew.fldunt 'degC' 'psu' 'umol/kg'];
    hnew.comment = [hnew.comment '\n stdev at bottle stops from psal (1hz) file'];

    var_copycell = mcvars_to_average(2);
    if exist(pfiles.ctd_2db_dn,'file')
        [dn,hd] = mloadq(pfiles.ctd_2db_dn,'/');
        [var_copycell, ~] = mvars_in_file(var_copycell, dfile);

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
            y = dn.(var_copycell{vno})(iigd(id));
            x = pg-dpn;
            m = ~isnan(x); %***do more than warn if interpolating over nans?
            dnew.(['d' var_copycell{vno}]) = interp1(x(m), y(m), fpress);
            hnew.fldnam = [hnew.fldnam ['d' var_copycell{vno}]];
            hnew.fldunt = [hnew.fldunt hd.fldunt(vmsk)];
        end
        dnew.dtime = ftime; %keep as bottle firing time
        hnew.fldunt(strcmp('dtime',hnew.fldnam)) = ftu;
        hnew.comment = [hnew.comment '\n downcast data matched on neutral density (smoothed using heaveND.m)'];

        %save
        mfsave(pfiles.ctd_nisk, dnew, hnew, '-addvars');
    end
end

