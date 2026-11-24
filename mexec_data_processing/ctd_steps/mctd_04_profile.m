function mctd_04_profile(stn)
% mctd_04:
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
% and via run(MEXEC_G.opt_cruise):
%     setdef_cropt_cast (ctd_proc and mctd_04 cases)

m_common; 
if MEXEC_G.quiet<=1; fprintf(1,'averaging from original resolution to 2 dbar in ctd_%s_%s_2db.nc (downcast) and ctd_%s_%s_2up.nc (upcast)\n',mcruise,stn_string,mcruise,stn_string); end

opt1 = 'setup'; opt2 = 'pfiles'; run(MEXEC_G.opt_cruise)
filer = replace(pfiles.ctd_cleancal,'stn_string',stn_string);
file2d = replace(pfiles.ctd_2db_dn,'stn_string',stn_string);
file2u = replace(pfiles.ctd_2db_up,'stn_string',stn_string);
dcsfile = replace(pfiles.ctd_castcut,'stn_string',stn_string);

%%%%% determine where to break cast into down and up segments %%%%%

[dd, hd] = mload(dcsfile,'statnum','dcr_start','dcr_bot','dcr_end','scan_end',' ');
if isempty(strfind(hd.comment,'manual')) && isempty(strfind(hd.comment,'inspected'))
    warning('using automatically detected cast start/bottom/end')
end
%***code to calculate dcr from dc and scan if there is no dcr?***
% allow for the possibility that the dcs file contains many stations
kf = find(dd.statnum == stn);
dcstart = dd.dcr_start(kf);
dcbot = dd.dcr_bot(kf);
dcend = dd.dcr_end(kf);

opt1 = 'ctd_proc'; opt2 = 'ctd_infiles'; run(MEXEC_G.opt_cruise)
minlent = 2*60; minlenp = 10; %require at least 2 minutes and 10 dbar to make a profile
if dcbot-dcstart>=minlent*infiles.ctd_raw_hz; isdown = true; else; isdown = false; end
if dcend-dcbot>=minlent*infiles.ctd_raw_hz; isup = true; else; isup = false; end
if ~isdown && ~isup
    warning('neither down nor up cast is longer than %d minutes; skipping', round(minlen/24/60))
    return
end

[d, h] = mload(filer, '/');
opt1 = 'ctd_proc'; opt2 = 'profiles'; run(MEXEC_G.opt_cruise)
pg = (g2opts.pbin/2:g2opts.pbin:max(d.press)+g2opts.pbin/2)';

opt1 = 'ctd_proc'; opt2 = 'raw_edits_corrs'; run(MEXEC_G.opt_cruise)
%use oxy_align to NaN that many seconds before dcs scan_start
if co.oxy_align>0
    opt1 = 'ctd_proc'; opt2 = 'ctd_infiles'; run(MEXEC_G.opt_cruise)
    oe = d.scan>=dd.scan_end-infiles.ctd_raw_hz*co.oxy_align;
    oxyvars = h.fldnam(strncmp(h.fldnam,'oxy',3));
    for no = 1:size(oxyvars,1)
        d.(oxyvars{no})(oe) = NaN;
    end
    d.oxygen(oe) = NaN;
    commentstr = ['edited out last ' num2str(co.oxy_align*infiles.ctd_raw_hz) ' scans from oxygen'];
    if ~contains(h.comment, commentstr); h.comment = [h.comment '\n ' commentstr]; end
end
% d.oxy1_2 = interp1(d.time,d.oxy1,d.time+2);
% d.oxy1_3 = interp1(d.time,d.oxy1,d.time+3);
% d.oxy2_2 = interp1(d.time,d.oxy2,d.time+2);
% d.oxy2_3 = interp1(d.time,d.oxy2,d.time+3);
% var_copycell = [var_copycell 'oxy1_2' 'oxy1_3' 'oxy2_2' 'oxy2_3'];
% h.fldnam = [h.fldnam 'oxy1_2' 'oxy1_3' 'oxy2_2' 'oxy2_3'];
% h.fldunt = [h.fldunt 'umol/kg' 'umol/kg' 'umol/kg' 'umol/kg'];
% iiv = [iiv' 55:58]';

%%%%% determine what variables will go in 2 dbar averaged files %%%%%
[var_copycell,~,iiv] = intersect(mcvars_to_average(1),h.fldnam);

%%%%% separate downcast and upcast ranges %%%%%
clear dn up
hn = h;
hn.fldnam = {}; hn.fldunt = {};
for vno = 1:length(var_copycell)
    if isdown
        dn.(var_copycell{vno}) = d.(var_copycell{vno})(dd.dcr_start:dd.dcr_bot);
    end
    if isup
        up.(var_copycell{vno}) = d.(var_copycell{vno})(dd.dcr_bot:dd.dcr_end);
    end
    hn.fldnam = [hn.fldnam var_copycell{vno}];
    hn.fldunt = [hn.fldunt h.fldunt{iiv(vno)}];
end
if isdown & max(dn.press)-min(dn.press)<minlenp
        isdown = false;
end
if isup & max(up.press)-min(up.press)<minlenp
    isup = false;
end
   
%%%%% optionally loopedit downcast %%%%%
if isdown
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

%%%%% grid to 2 (or other) dbar %%%%%
if isdown
    dn2 = grid_1D(dn, 'press', pg, 'lfitbin', g2opts);
    if sum(~isnan(dn2.press))<minlenp/g2opts.pbin
        isdown = 0;
    end
    [dn2, hn] = copy_sensor(dn2, hn, stn);
end
if isup
    up2 = grid_1D(up, 'press', pg, 'lfitbin', g2opts);
    if sum(~isnan(up2.press))<minlenp/g2opts.pbin
        isup = 0;
    end
    [up2, ~] = copy_sensor(up2, hn, stn);
end
if ~isdown && ~isup
    warning('neither down nor up cast has enough good data; skipping')
    return
end
commentstr = 'gridded to 2 dbar using grid_profile method lfitbin';
if ~contains(hn.comment, commentstr); hn.comment = [hn.comment '\n ' commentstr]; end
if g2opts.postfill>0
    if isfinite(g2opts.postfill)
        commentstr = ['gaps up to ' num2str(g2opts.postfill) ' in 2 dbar filled using linear interpolation'];
    else
        commentstr = 'gaps in 2 dbar filled using linear interpolation';
    end
end
if ~contains(hn.comment, commentstr); hn.comment = [hn.comment '\n ' commentstr]; end

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
    dn2.potemp1 = NaN+dn2.press; dn2.potemp1(iigd) = gsw_pt0_from_t(dn2.asal1(iigd), dn2.temp1(iigd), dn2.press(iigd));
    dn2.potemp2 = NaN+dn2.press; dn2.potemp2(iigd) = gsw_pt0_from_t(dn2.asal2(iigd), dn2.temp2(iigd), dn2.press(iigd));
end
if isup
    up2.potemp2 = NaN+up2.press; up2.potemp2(iigu) = gsw_pt0_from_t(up2.asal2(iigu), up2.temp2(iigu), up2.press(iigu));
    up2.potemp1 = NaN+up2.press; up2.potemp1(iigu) = gsw_pt0_from_t(up2.asal1(iigu), up2.temp1(iigu), up2.press(iigu));
end
if ~sum(strcmp('potemp',hn.fldnam))
    hn.fldnam = [hn.fldnam 'potemp']; hn.fldunt = [hn.fldunt 'degc90'];
    hn.fldnam = [hn.fldnam 'potemp1']; hn.fldunt = [hn.fldunt 'degc90'];
    hn.fldnam = [hn.fldnam 'potemp2']; hn.fldunt = [hn.fldunt 'degc90'];
end
hn = keep_hvatts(hn, h);

commentstr = 'depth and potemp calculated using gsw';
if ~contains(hn.comment, commentstr); hn.comment = [hn.comment commentstr]; end

%%%%% save %%%%%

if isdown
    hnd = hn;
    if ~contains(hnd.comment,commentd); hnd.comment = [commentd; '\n'; hnd.comment]; end
    mfsave(file2d, dn2, hnd);
end

if isup
    hnu = hn;
    mfsave(file2u, up2, hnu);
end
