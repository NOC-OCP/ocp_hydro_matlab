% mctd_04:
%
% inputs: wk_dvars_ (from mctd_03),
%         dcs_
%
% extract downcast and upcast data from 24hz file with derived vars
%          (psal etc.) using index information in dcs file;
%          optionally loopedit;
%          sort, average to 2 dbar;
%          interpolate gaps;
%          calculate depth and (re)calculate potemp.
%
% outputs: _2db, _2up: 2-dbar-averaged down- and upcast respectively
%
% Use: mctd_04        and then respond with station number, or for station 16
%      stn = 16; mctd_04;
%
% calls:
%     mloadq
%     grid_profile
%     mfsave
% and via get_cropt:
%     setdef_cropt_cast (castpars and mctd_04 cases)

opt1 = 'castpars'; opt2 = 'minit'; get_cropt
if MEXEC_G.quiet<=1; fprintf(1,'averaging from 24 hz to 2 dbar in ctd_%s_%s_2db.nc (downcast) and ctd_%s_%s_2up.nc (upcast)\n',mcruise,stn_string,mcruise,stn_string); end

root_ctd = mgetdir('M_CTD');

infile = fullfile(root_ctd, ['ctd_' mcruise '_' stn_string '_24hz']);
dcsfile = fullfile(root_ctd, ['dcs_' mcruise '_' stn_string]);
otfile1d = fullfile(root_ctd, ['ctd_' mcruise '_' stn_string '_2db']);
otfile1u = fullfile(root_ctd, ['ctd_' mcruise '_' stn_string '_2up']);

MEXEC_A.Mprog = mfilename;

%%%%% determine where to break cast into down and up segments %%%%%

[dd, hd] = mloadq(dcsfile,'statnum','dc24_start','dc24_bot','dc24_end','scan_end',' ');
if isempty(strfind(hd.comment,'manual')) && isempty(strfind(hd.comment,'inspected'))
    warning('using automatically detected cast start/bottom/end')
end
%***code to calculate dc24 from dc and scan if there is no dc24?***
% allow for the possibility that the dcs file contains many stations
kf = find(dd.statnum == stnlocal);
dcstart = dd.dc24_start(kf);
dcbot = dd.dc24_bot(kf);
dcend = dd.dc24_end(kf);

minlen = 60*24; minbins = 5; %require at least 1 minute and 10 dbar to make a profile

if dcbot-dcstart>=minlen; isdown = 1; end
if dcend-dcbot>=minlen; isup = 1; end
if ~isdown && ~isup
    warning('neither down nor up cast is longer than %d minutes; skipping', round(minlen/24))
    return
end


%%%%% determine what variables will go in 2 dbar averaged files %%%%%
%%%%% copy for downcast and upcast %%%%%

[d, h] = mload(infile, '/');
[var_copycell,~,iiv] = intersect(mcvars_list(1),h.fldnam);

%use oxy_end to NaN that many seconds before dcs scan_start
opt1 = 'castpars'; opt2 = 'oxy_align'; get_cropt
if oxy_end==1
    opt1 = 'castpars'; opt2 = 'oxyvars'; get_cropt
    oe = d.scan>=dd.scan_end-24*oxy_align;
    for no = 1:size(oxyvars,1)
        d.(oxyvars{no})(oe) = NaN;
    end
    d.oxygen(oe) = NaN;
    h.comment = [h.comment 'edited out last ' num2str(oxy_align*24) ' scans from oxygen\n'];
end


%%%%% separate downcast and upcast ranges %%%%%
clear dn up
hn = h;
hn.fldnam = {}; hn.fldunt = {};
for vno = 1:length(var_copycell)
    if isdown
        dn.(var_copycell{vno}) = d.(var_copycell{vno})(dd.dc24_start:dd.dc24_bot);
    end
    if isup
        up.(var_copycell{vno}) = d.(var_copycell{vno})(dd.dc24_bot:dd.dc24_end);
    end
    hn.fldnam = [hn.fldnam var_copycell{vno}];
    hn.fldunt = [hn.fldunt h.fldunt{iiv(vno)}];
end



%%%%% optionally loopedit downcast %%%%%
if isdown
    doloopedit = 0;
    ptol = 0.08; %default is not to apply, but this would be the default value if you did
    spdtol = 0.24; %default value from SBE program
    opt1 = mfilename; opt2 = 'doloopedit'; get_cropt
    if doloopedit
        vars_other = setdiff(var_copycell, {'press'});
        disp(['applying loopediting for ' otfile1d])
        dn.press = m_loopedit(dn.press, 'ptol', ptol, 'spdtol', spdtol);
        for vno = 1:length(vars_other)
            dn.(vars_other{vno})(isnan(dn.press)) = NaN;
            commentd = sprintf('loopediting applied to downcast using ptol %f, spdtol %f\n',ptol,spdtol);
        end
    else
        commentd = '';
    end
end

%%%%% grid to 2 dbar %%%%%
pg = [0:2:1e4]';
maxfill2db = 0;
opt1 = mfilename; opt2 = 'interp2db'; get_cropt
clear g2opts
g2opts.int = [-1 1]; %interval for bins
g2opts.grid_extrap = [0 0]; %discard empty bins
g2opts.postfill = maxfill2db; %fill after gridding?
g2opts.ignore_nan = 1;
g2opts.bin_partial = 1; %use bins with data in only one half
if isdown
    dn2 = grid_profile(dn, 'press', pg, 'lfitbin', g2opts);
    if sum(~isnan(dn2.press))<minbins
        isdown = 0;
    end
end
if isup
    up2 = grid_profile(up, 'press', pg, 'lfitbin', g2opts);
    if sum(~isnan(up2.press))<minbins
        isup = 0;
    end
end
if ~isdown && ~isup
    warning('neither down nor up cast has enough good data; skipping')
    return
end
hn.comment = 'gridded to 2 dbar using grid_profile method lfitbin\n';
if maxfill2db>0
    if isfinite(maxfill2db)
        hn.comment = [hn.comment 'gaps up to ' num2str(maxfill2db) ' in 2 dbar filled using linear interpolation\n'];
    else
        hn.comment = [hn.comment 'gaps in 2 dbar filled using linear interpolation\n'];
    end
end


%%%%% add or recalculate depth and potemp %%%%%

if isdown
    iigd = find(dn2.press>-1.495);
    dn2.depth = NaN+dn2.press; dn2.depth(iigd) = -gsw_z_from_p(dn2.press(iigd),h.latitude);
end
if isup
    iigu = find(up2.press>-1.495);
    up2.depth = NaN+up2.press; up2.depth(iigu) = -gsw_z_from_p(up2.press(iigu),h.latitude);
end
hn.fldnam = [hn.fldnam 'depth']; hn.fldunt = [hn.fldunt 'metres'];

if isdown
    dn2.potemp = NaN+dn2.press; dn2.potemp(iigd) = gsw_pt0_from_t(dn2.asal(iigd), dn2.temp(iigd), dn2.press(iigd));
    dn2.potemp1 = NaN+dn2.press; dn2.potemp1(iigd) = gsw_pt0_from_t(dn2.asal1(iigd), dn2.temp1(iigd), dn2.press(iigd));
    dn2.potemp2 = NaN+dn2.press; dn2.potemp2(iigd) = gsw_pt0_from_t(dn2.asal2(iigd), dn2.temp2(iigd), dn2.press(iigd));
end
if isup
    up2.potemp = NaN+up2.press; up2.potemp(iigu) = gsw_pt0_from_t(up2.asal(iigu), up2.temp(iigu), up2.press(iigu));
    up2.potemp2 = NaN+up2.press; up2.potemp2(iigu) = gsw_pt0_from_t(up2.asal2(iigu), up2.temp2(iigu), up2.press(iigu));
    up2.potemp1 = NaN+up2.press; up2.potemp1(iigu) = gsw_pt0_from_t(up2.asal1(iigu), up2.temp1(iigu), up2.press(iigu));
end
if ~sum(strcmp('potemp',hn.fldnam))
    hn.fldnam = [hn.fldnam 'potemp']; hn.fldunt = [hn.fldunt 'degc90'];
    hn.fldnam = [hn.fldnam 'potemp1']; hn.fldunt = [hn.fldunt 'degc90'];
    hn.fldnam = [hn.fldnam 'potemp2']; hn.fldunt = [hn.fldunt 'degc90'];
end

hn.comment = [hn.comment 'depth and potemp calculated using gsw\n'];


%%%%% save %%%%%

if isdown
    hnd = hn;
    hnd.comment = [commentd hnd.comment];
    mfsave(otfile1d, dn2, hnd);
end

if isup
    hnu = hn;
    mfsave(otfile1u, up2, hnu);
end