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
%     mcalib2
%     mcopya
%     msort
%     mavrg
%     minterp
%     mcalc
% and via get_cropt:
%     setdef_cropt_cast (castpars and mctd_04 cases)

scriptname = 'castpars'; oopt = 'minit'; get_cropt
mdocshow(mfilename, ['averages from 24 hz to 2 dbar in ctd_' mcruise '_' stn_string '_2db.nc (downcast) and _2up.nc (upcast)']);

root_ctd = mgetdir('M_CTD');

wscriptname = mfilename;
wkfile_dvars = fullfile(root_ctd, ['wk_dvars_' mcruise '_' stn_string]);
dcsfile = fullfile(root_ctd, ['dcs_' mcruise '_' stn_string]);
otfile1d = fullfile(root_ctd, ['ctd_' mcruise '_' stn_string '_2db']);
otfile1u = fullfile(root_ctd, ['ctd_' mcruise '_' stn_string '_2up']);
wkfile1d = ['wk1d_' wscriptname '_' datestr(now,30)];
wkfile1u = ['wk1u_' wscriptname '_' datestr(now,30)];
wkfile2d = ['wk2d_' wscriptname '_' datestr(now,30)];
wkfile2u = ['wk2u_' wscriptname '_' datestr(now,30)];
wkfile3d = ['wk3d_' wscriptname '_' datestr(now,30)];
wkfile3u = ['wk3u_' wscriptname '_' datestr(now,30)];

if exist(m_add_nc(wkfile_dvars),'file') ~= 2
    mess = ['File ' m_add_nc(wkfile_dvars) ' not found, rerun mctd_03b?'];
    fprintf(MEXEC_A.Mfider,'%s\n',mess)
    return
end

MEXEC_A.Mprog = mfilename;

%%%%% determine where to break cast into down and up segments %%%%%

[d h] = mloadq(dcsfile,'statnum','dc24_start','dc24_bot','dc24_end',' ');
% allow for the possibility that the dcs file contains many stations
kf = find(d.statnum == stnlocal);
dcstart = d.dc24_start(kf);
dcbot = d.dc24_bot(kf);
dcend = d.dc24_end(kf);
copystr = {[sprintf('%d',round(dcstart)) ' ' sprintf('%d',round(dcbot))]};
copystrup = {[sprintf('%d',round(dcbot)) ' ' sprintf('%d',round(dcend))]};


%%%%% determine what variables will go in 2 dbar averaged files %%%%%
%%%%% copy those from wkfile4 (24 hz data with added vars) to working files %%%%%
%%%%% for downcast and upcast %%%%%

h = m_read_header(wkfile_dvars);
[var_copycell,~,iiv] = intersect(mcvars_list(1),h.fldnam);

%working on temporary files
MEXEC_A.Mhistory_skip = 1;

%use oxy_end to NaN that many seconds before dcs scan_start
scriptname = 'castpars'; oopt = 'oxy_align'; get_cropt
if oxy_end==1
    scriptname = 'castpars'; oopt = 'oxyvars'; get_cropt
    dd = mloadq(dcsfile,'scan_end');
    MEXEC_A.MARGS_IN = {wkfile_dvars; 'y'};
    for no = 1:size(oxyvars,1)
        MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN
            oxyvars{no,2}
            [oxyvars{no,2} ' scan']
            sprintf('y = x1; y(x2>=%d) = NaN;',dd.scan_end-24*oxy_align)
            ' '
            ' '];
    end
    MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN
        'oxygen'
        'oxygen scan'
        sprintf('y = x1; y(x2>=%d) = NaN;',dd.scan_end-24*oxy_align)
        ' '
        ' '];
    disp(['will edit out last ' num2str(oxy_end*24) ' scans from oxygen'])
    MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; ' '];
    mcalib2
end

%%%%% separate downcast and upcast ranges %%%%%
[d,h] = mload(wkfile_dvars, '/');
clear dn up hn
hn.fldnam = {}; hn.fldunt = {};
for vno = 1:length(var_copycell)
    dn.(var_copycell{vno}) = d.(var_copycell{vno})(dd.dc24_start:dd.dc24_bot);
    up.(var_copycell{vno}) = d.(var_copycell{vno})(dd.dc24_bot:dd.dc24_end);
    hn.fldnam = [hn.fldnam var_copycel{vno}];
    hn.fldunt = [hn.fldunt h.fldunt{iiv(vno)}];
end

vars_other = setdiff(var_copycell, {'press'});

%%%%% optionally loopedit downcast %%%%%
scriptname = mfilename; oopt = 'doloopedit'; get_cropt
if doloopedit
    disp(['applying loopediting for ' otfile1d])
    dn.press = m_loopedit(dn.press, 'ptol', ptol, 'spdtol', spdtol);
    for vno = 1:length(vars_other)
        dn.(vars_other{vno})(isnan(dn.press)) = NaN;
        commentd = sprintf('loopediting applied to downcast using ptol %f, spdtol %f\n',ptol,spdtol);
    end
else
    commentd = '';
end

%%%%% sort by pressure and average to 2 dbar %%%%%
pedges = [0:2:1e4];
dn2 = grid_cast_segment(dn, 'press', pedges);
up2 = grid_cast_segment(up, 'press', pedges);
hn.comment = 'bin averaged to 2 dbar using grid_cast_segment\n';

%%%%% interpolate to fill in gaps %%%%%
scriptname = mfilename; oopt = 'interp2db'; get_cropt
if interp2db
    nd = length(dn2.press);
    nu = length(up2.press);
    for vno = 1:length(vars_other)
        iig = find(~isnan(dn2.(vars_other{vno}))); iib = setdiff(1:nd,iig);
        dn2.(vars_other{vno})(iib) = interp1(dn2.press(iig), dn2.(vars_other{vno})(iig), dn2.press(iib));
        iig = find(~isnan(up2.(vars_other{vno}))); iib = setdiff(1:nu,iig);
        up2.(vars_other{vno})(iib) = interp1(up2.press(iig), up2.(vars_other{vno})(iig), up2.press(iib));
    end
    hn.comment = [hn.comment 'gaps in 2 dbar filled using linear interpolation\n'];
end

%%%%% add potemp %%%%%

iigd = find(dn2.press>-1.495);
iigu = find(up2.press>-1.495);

dn2.depth = NaN+dn2.press; dn2.depth(iigd) = -gsw_z_from_p(dn2.press(iigd),h.latitude);
up2.depth = NaN+up2.press; up2.depth(iigu) = -gsw_z_from_p(up2.press(iigu),h.latitude);
hn.fldnam = [hn.fldnam 'depth']; hn.fldunt = [hn.fldunt 'metres'];

dn2.potemp = NaN+dn2.press; dn2.potemp(iigd) = gsw_pt0_from_t(dn2.asal(iigd), dn2.temp(iigd), dn2.press(iigd));
up2.potemp = NaN+up2.press; up2.potemp(iigu) = gsw_pt0_from_t(up2.asal(iigu), up2.temp(iigu), up2.press(iigu));
hn.fldnam = [hn.fldnam 'potemp']; hn.fldunt = [hn.fldunt 'degc90'];

dn2.potemp1 = NaN+dn2.press; dn2.potemp1(iigd) = gsw_pt0_from_t(dn2.asal1(iigd), dn2.temp1(iigd), dn2.press(iigd));
up2.potemp2 = NaN+up2.press; up2.potemp2(iigu) = gsw_pt0_from_t(up2.asal2(iigu), up2.temp2(iigu), up2.press(iigu));
hn.fldnam = [hn.fldnam 'potemp1']; hn.fldunt = [hn.fldunt 'degc90'];

dn2.potemp2 = NaN+dn2.press; dn2.potemp2(iigd) = gsw_pt0_from_t(dn2.asal2(iigd), dn2.temp2(iigd), dn2.press(iigd));
up2.potemp1 = NaN+up2.press; up2.potemp1(iigu) = gsw_pt0_from_t(up2.asal1(iigu), up2.temp1(iigu), up2.press(iigu));
hn.fldnam = [hn.fldnam 'potemp2']; hn.fldunt = [hn.fldunt 'degc90'];

hn.comment = [hn.comment 'depth and potemp calculated using gsw\n'];

%%%%% save %%%%%

%now working on files to keep
MEXEC_A.Mhistory_skip = 0;

hnd = hn;
if ~isempty(commentd)
    hnd.comment = [commentd hnd.commentd];
end
mfsave(otfile1, dn2, hnd);

hnu = hn;
mfsave(otfile2, up2, hnu);


delete(m_add_nc(wkfile_dvars));
