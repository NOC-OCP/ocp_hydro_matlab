function msam_checkbottles_02(stn,vnam1,vnam2,vnam3,vnam4,vnam5)
% function msam_checkbottles_02(stn,vnam1,vnam2,vnam3,vnam4,vnam5)
%
% (formerly bottle_inspectionall)
%
% add documentation***!!!
%
m_common
scriptname = 'msam_checkbottles_02';
minit



%%%%%%%%% get data %%%%%%%%%

fnctd = ['ctd_' mcruise '_' sprintf('%03d',stnlocal) '_psal'];
fnsam1 = ['sam_' mcruise '_' sprintf('%03d',stnlocal-2)];
fnsam2 = ['sam_' mcruise '_' sprintf('%03d',stnlocal-1)];
fnsam = ['sam_' mcruise '_' sprintf('%03d',stnlocal)];
fnsam3 = ['sam_' mcruise '_' sprintf('%03d',stnlocal+1)];
fnsam4 = ['sam_' mcruise '_' sprintf('%03d',stnlocal+2)];
fnsamall = ['sam_' mcruise '_all'];
fngrid = ['grid_' mcruise '_' section];
fndcs = ['dcs_' mcruise '_' sprintf('%03d',stnlocal)];

[dctd hctd] = mload(fnctd,'/');
[dsamall hsamall]  = mload(fnsamall,'/');
[dgrid hgrid]  = mload(fngrid,'/');
[ddcs hdcs] = mload(fndcs,'/');

dcstime1 = datenum(hdcs.data_time_origin) + ddcs.time_start/86400;
dcstime2 = datenum(hdcs.data_time_origin) + ddcs.time_bot/86400;
dcstime3 = datenum(hdcs.data_time_origin) + ddcs.time_end/86400;

ctdtime = datenum(hctd.data_time_origin) + dctd.time/86400;

kdown = find(ctdtime > dcstime1 & ctdtime < dcstime2);
kup = find(ctdtime > dcstime2 & ctdtime < dcstime3);


%distribute all sam data back into separate stations
ksam1 = find(dsamall.statnum == stnlocal-2);
ksam2 = find(dsamall.statnum == stnlocal-1);
ksam = find(dsamall.statnum == stnlocal);
ksam3 = find(dsamall.statnum == stnlocal+1);
ksam4 = find(dsamall.statnum == stnlocal+2);

sams = {'1' '2' '' '3' '4'}; % repopulate dsam1 to dsam4
for ks = 1:5
    samname = ['dsam' sams{ks}];
    kname = ['ksam' sams{ks}];
    fall = fieldnames(dsamall);
    cmd = ['ksamx = ' kname ';']; eval(cmd);
    if isempty(ksamx); continue; end
    for kf = 1:length(fall)
        cmd = [samname '.' fall{kf} ' = dsamall.' fall{kf} '(ksamx);']; eval(cmd)
    end
end

if ~isfield(dsam, 'botoxytemp'); dsam.botoxytemp = dsam.botoxytempa; end % jc159 cludge
dsam.bottle_qc_flag = 3+0*dsam.upress;


%optionally apply preliminary calibration functions (most relevant to get ctd and bottle oxygen close)
oopt = 'docals'; get_cropt
if dotcal
   scriptname = 'mctd_03'; oopt = 's_choice'; scriptname = 'msam_checkbottles_02';
   dctd.temp = temp_apply_cal(s_choice,stnlocal,dctd.press,0*dctd.press,dctd.temp);
end
if doccal
   scriptname = 'mctd_03'; oopt = 's_choice'; scriptname = 'msam_checkbottles_02';
   dctd.cond = cond_apply_cal(s_choice,stnlocal,dctd.press,0*dctd.press,dctd.temp,dctd.cond);
end
if doocal
   scriptname = 'mctd_03'; oopt = 'o_choice'; scriptname = 'msam_checkbottles_02';
   dctd.oxygen = oxy_apply_cal(o_choice,stnlocal,dctd.press,0*dctd.press,dctd.temp,dctd.oxygen);
end
if doccal | dotcal
   dctd.psal = gsw_SP_from_C(dctd.cond, dctd.temp, dctd.press);
   dctd.asal = gsw_SA_from_SP(dctd.psal, dctd.press, hctd.longitude, hctd.latitude);
   dctd.potemp = gsw_pt0_from_t(dctd.asal, dctd.temp, dctd.press);
end



%%%%%%%%% plot %%%%%%%%%

nsubs = nargin+2;

m0 = 5;
m1 = 7;
m2 = 10;

m_figure
scrsz = get(0,'ScreenSize');
set(gcf,'Position',[1 0.3*scrsz(4) 1.0*scrsz(3) 0.68*scrsz(4)])

subplot(1,nsubs,1)
vnam = 'psal';
kbadpsal = find(dsam.botpsalflag~=2);
kbadnisk = find(dsam.bottle_qc_flag~=2);
plot(dctd.psal(kdown),-dctd.press(kdown),'k-'); 
hold on; grid on;
title(['Stn ' sprintf('%03d',stnlocal)]);
xlabel('psal');
plot(dctd.psal(kup),-dctd.press(kup),'r-');
plot(dsam.botpsal,-dsam.upress,'b+','markersize',m1);
plot(dsam.botpsal(kbadpsal),-dsam.upress(kbadpsal),'k^','markersize',m2);
plot(dsam.botpsal(kbadnisk),-dsam.upress(kbadnisk),'rv','markersize',m2);
ax = axis; ax(3) = -7000; axis(ax);

subplot(1,nsubs,2)

kbadoxy = find(dsam.botoxyflag~=2);
kbadnisk = find(dsam.bottle_qc_flag~=2);

plot(dctd.oxygen(kdown),-dctd.press(kdown),'k-'); 
hold on; grid on;
title(['Stn ' sprintf('%03d',stnlocal)]);
xlabel('oxygen');
plot(dctd.oxygen(kup),-dctd.press(kup),'r-');
plot(dsam.botoxy,-dsam.upress,'b+','markersize',m1);
plot(dsam.botoxy(kbadoxy),-dsam.upress(kbadoxy),'k^','markersize',m2);
plot(dsam.botoxy(kbadnisk),-dsam.upress(kbadnisk),'rv','markersize',m2);
ax = axis; ax(3) = -7000; axis(ax);


subplot(1,nsubs,3)

kbadoxy = find(dsam.botoxyflag~=2);
kbadnisk = find(dsam.bottle_qc_flag~=2);
plot(dctd.potemp(kdown),-dctd.press(kdown),'k-'); 
hold on; grid on;
title(['Stn ' sprintf('%03d',stnlocal)]);
xlabel('potemp/botoxytemp/depths');
plot(dctd.potemp(kup),-dctd.press(kup),'r-');
plot(dsam.botoxytemp,-dsam.upress,'b+','markersize',m1);
plot(dsam.botoxytemp(kbadoxy),-dsam.upress(kbadoxy),'k^','markersize',m2);
plot(dsam.botoxytemp(kbadnisk),-dsam.upress(kbadnisk),'rv','markersize',m2);
plot(30+dsam.bottle_qc_flag,-dsam.upress,'k+','markersize',m1);
plot(30+dsam.bottle_qc_flag(kbadnisk),-dsam.upress(kbadnisk),'rv','markersize',m2);
ax = axis; ax(3) = -7000; axis(ax);
for klab = 1:24
    text(30+dsam.bottle_qc_flag(klab),-dsam.upress(klab),...
        sprintf('%d  ',dsam.position(klab)),'fontsize',14,'horizontalalignment','right','verticalalignment','middle')
end

if nsubs >= 4

subplot(1,nsubs,4)


d = getfield(dsam, vnam1);
if exist('dsam1','var') == 1; d1 = getfield(dsam1, vnam1); else; d1 = d+nan; end
if exist('dsam2','var') == 1; d2 = getfield(dsam2, vnam1); else; d2 = d+nan; end
if exist('dsam3','var') == 1; d3 = getfield(dsam3, vnam1); else; d3 = d+nan; end
if exist('dsam4','var') == 1; d4 = getfield(dsam4, vnam1); else; d4 = d+nan; end
dg = getfield(dgrid, vnam1);
if isfield(dsam,[vnam1 '_flag']); und = '_'; end
if isfield(dsam,[vnam1 'flag']); und = ''; end
dflag = getfield(dsam, [vnam1 und 'flag']);
if exist('dsam1','var') == 1; dflag1 = getfield(dsam1, [vnam1 und 'flag']); else; dflag1 = d+nan; end
if exist('dsam2','var') == 1; dflag2 = getfield(dsam2, [vnam1 und 'flag']); else; dflag2 = d+nan; end
if exist('dsam3','var') == 1; dflag3 = getfield(dsam3, [vnam1 und 'flag']); else; dflag3 = d+nan; end
if exist('dsam4','var') == 1; dflag4 = getfield(dsam4, [vnam1 und 'flag']); else; dflag4 = d+nan; end
kok1 = find(dflag1 == 2);
kok2 = find(dflag2 == 2);
kok3 = find(dflag3 == 2);
kok4 = find(dflag4 == 2);

kmat = find(dgrid.statnum == stnlocal);
kbad = find(dflag ~= 2);
kbadnisk = find(dsam.bottle_qc_flag~=2);
plot(dg(kmat),-dgrid.press(kmat),'r-'); 
hold on; grid on;
if ~isempty(kok1); plot(d1(kok1),-dsam1.upress(kok1),'ko','markersize',m0); end
if ~isempty(kok2); plot(d2(kok2),-dsam2.upress(kok2),'ko','markersize',m0); end
if ~isempty(kok3); plot(d3(kok3),-dsam3.upress(kok3),'co','markersize',m0); end
if ~isempty(kok4); plot(d4(kok4),-dsam4.upress(kok4),'co','markersize',m0); end
title(['Stn ' sprintf('%03d',stnlocal)]);
xlabel(vnam);
plot(d,-dsam.upress,'b+','markersize',m1);
plot(d(kbad),-dsam.upress(kbad),'k^','markersize',m2);
plot(d(kbadnisk),-dsam.upress(kbadnisk),'rv','markersize',m2);
ax = axis; ax(3) = -7000; axis(ax);

end

if nsubs >= 5


subplot(1,nsubs,5)

vnam = vnam2;
cmd = ['d = dsam.' vnam ';']; eval(cmd)
if exist('dsam1','var') == 1; cmd = ['d1 = dsam1.' vnam ';']; eval(cmd); else d1 = d+nan; end
if exist('dsam2','var') == 1; cmd = ['d2 = dsam2.' vnam ';']; eval(cmd); else d2 = d+nan; end
if exist('dsam3','var') == 1; cmd = ['d3 = dsam3.' vnam ';']; eval(cmd); else d3 = d+nan; end
if exist('dsam4','var') == 1; cmd = ['d4 = dsam4.' vnam ';']; eval(cmd); else d4 = d+nan; end
cmd = ['dg = dgrid.' vnam ';']; eval(cmd)
if isfield(dsam,[vnam '_flag']); und = '_'; end
if isfield(dsam,[vnam 'flag']); und = ''; end
cmd = ['dflag = dsam.' vnam und 'flag;']; eval(cmd)
if exist('dsam1','var') == 1; cmd = ['dflag1 = dsam1.' vnam und 'flag;']; eval(cmd); else dflag1 = d+nan; end
if exist('dsam2','var') == 1; cmd = ['dflag2 = dsam2.' vnam und 'flag;']; eval(cmd); else dflag2 = d+nan; end
if exist('dsam3','var') == 1; cmd = ['dflag3 = dsam3.' vnam und 'flag;']; eval(cmd); else dflag3 = d+nan; end
if exist('dsam4','var') == 1; cmd = ['dflag4 = dsam4.' vnam und 'flag;']; eval(cmd); else dflag4 = d+nan; end
kok1 = find(dflag1 == 2);
kok2 = find(dflag2 == 2);
kok3 = find(dflag3 == 2);
kok4 = find(dflag4 == 2);

kmat = find(dgrid.statnum == stnlocal);
kbad = find(dflag ~= 2);
kbadnisk = find(dsam.bottle_qc_flag~=2);
plot(dg(kmat),-dgrid.press(kmat),'r-'); 
hold on; grid on;
if ~isempty(kok1); plot(d1(kok1),-dsam1.upress(kok1),'ko','markersize',m0); end
if ~isempty(kok2); plot(d2(kok2),-dsam2.upress(kok2),'ko','markersize',m0); end
if ~isempty(kok3); plot(d3(kok3),-dsam3.upress(kok3),'co','markersize',m0); end
if ~isempty(kok4); plot(d4(kok4),-dsam4.upress(kok4),'co','markersize',m0); end
title(['Stn ' sprintf('%03d',stnlocal)]);
xlabel(vnam);
plot(d,-dsam.upress,'b+','markersize',m1);
plot(d(kbad),-dsam.upress(kbad),'k^','markersize',m2);
plot(d(kbadnisk),-dsam.upress(kbadnisk),'rv','markersize',m2);
ax = axis; ax(3) = -7000; axis(ax);

end

if nsubs >= 6


subplot(1,nsubs,6)

vnam = vnam3;
cmd = ['d = dsam.' vnam ';']; eval(cmd)
if exist('dsam1','var') == 1; cmd = ['d1 = dsam1.' vnam ';']; eval(cmd); else d1 = d+nan; end
if exist('dsam2','var') == 1; cmd = ['d2 = dsam2.' vnam ';']; eval(cmd); else d2 = d+nan; end
if exist('dsam3','var') == 1; cmd = ['d3 = dsam3.' vnam ';']; eval(cmd); else d3 = d+nan; end
if exist('dsam4','var') == 1; cmd = ['d4 = dsam4.' vnam ';']; eval(cmd); else d4 = d+nan; end
cmd = ['dg = dgrid.' vnam ';']; eval(cmd)
if isfield(dsam,[vnam '_flag']); und = '_'; end
if isfield(dsam,[vnam 'flag']); und = ''; end
cmd = ['dflag = dsam.' vnam und 'flag;']; eval(cmd)
if exist('dsam1','var') == 1; cmd = ['dflag1 = dsam1.' vnam und 'flag;']; eval(cmd); else dflag1 = d+nan; end
if exist('dsam2','var') == 1; cmd = ['dflag2 = dsam2.' vnam und 'flag;']; eval(cmd); else dflag2 = d+nan; end
if exist('dsam3','var') == 1; cmd = ['dflag3 = dsam3.' vnam und 'flag;']; eval(cmd); else dflag3 = d+nan; end
if exist('dsam4','var') == 1; cmd = ['dflag4 = dsam4.' vnam und 'flag;']; eval(cmd); else dflag4 = d+nan; end
kok1 = find(dflag1 == 2);
kok2 = find(dflag2 == 2);
kok3 = find(dflag3 == 2);
kok4 = find(dflag4 == 2);

kmat = find(dgrid.statnum == stnlocal);
kbad = find(dflag ~= 2);
kbadnisk = find(dsam.bottle_qc_flag~=2);
plot(dg(kmat),-dgrid.press(kmat),'r-'); 
hold on; grid on;
if ~isempty(kok1); plot(d1(kok1),-dsam1.upress(kok1),'ko','markersize',m0); end
if ~isempty(kok2); plot(d2(kok2),-dsam2.upress(kok2),'ko','markersize',m0); end
if ~isempty(kok3); plot(d3(kok3),-dsam3.upress(kok3),'co','markersize',m0); end
if ~isempty(kok4); plot(d4(kok4),-dsam4.upress(kok4),'co','markersize',m0); end
title(['Stn ' sprintf('%03d',stnlocal)]);
xlabel(vnam);
plot(d,-dsam.upress,'b+','markersize',m1);
plot(d(kbad),-dsam.upress(kbad),'k^','markersize',m2);
plot(d(kbadnisk),-dsam.upress(kbadnisk),'rv','markersize',m2);
ax = axis; ax(3) = -7000; axis(ax);

end

if nsubs >= 7

subplot(1,nsubs,7)

vnam = vnam4;
cmd = ['d = dsam.' vnam ';']; eval(cmd)
if exist('dsam1','var') == 1; cmd = ['d1 = dsam1.' vnam ';']; eval(cmd); else d1 = d+nan; end
if exist('dsam2','var') == 1; cmd = ['d2 = dsam2.' vnam ';']; eval(cmd); else d2 = d+nan; end
if exist('dsam3','var') == 1; cmd = ['d3 = dsam3.' vnam ';']; eval(cmd); else d3 = d+nan; end
if exist('dsam4','var') == 1; cmd = ['d4 = dsam4.' vnam ';']; eval(cmd); else d4 = d+nan; end
cmd = ['dg = dgrid.' vnam ';']; eval(cmd)
if isfield(dsam,[vnam '_flag']); und = '_'; end
if isfield(dsam,[vnam 'flag']); und = ''; end
cmd = ['dflag = dsam.' vnam und 'flag;']; eval(cmd)
if exist('dsam1','var') == 1; cmd = ['dflag1 = dsam1.' vnam und 'flag;']; eval(cmd); else dflag1 = d+nan; end
if exist('dsam2','var') == 1; cmd = ['dflag2 = dsam2.' vnam und 'flag;']; eval(cmd); else dflag2 = d+nan; end
if exist('dsam3','var') == 1; cmd = ['dflag3 = dsam3.' vnam und 'flag;']; eval(cmd); else dflag3 = d+nan; end
if exist('dsam4','var') == 1; cmd = ['dflag4 = dsam4.' vnam und 'flag;']; eval(cmd); else dflag4 = d+nan; end
kok1 = find(dflag1 == 2);
kok2 = find(dflag2 == 2);
kok3 = find(dflag3 == 2);
kok4 = find(dflag4 == 2);

kmat = find(dgrid.statnum == stnlocal);
kbad = find(dflag ~= 2);
kbadnisk = find(dsam.bottle_qc_flag~=2);
plot(dg(kmat),-dgrid.press(kmat),'r-'); 
hold on; grid on;
if ~isempty(kok1); plot(d1(kok1),-dsam1.upress(kok1),'ko','markersize',m0); end
if ~isempty(kok2); plot(d2(kok2),-dsam2.upress(kok2),'ko','markersize',m0); end
if ~isempty(kok3); plot(d3(kok3),-dsam3.upress(kok3),'co','markersize',m0); end
if ~isempty(kok4); plot(d4(kok4),-dsam4.upress(kok4),'co','markersize',m0); end
title(['Stn ' sprintf('%03d',stnlocal)]);
xlabel(vnam);
plot(d,-dsam.upress,'b+','markersize',m1);
plot(d(kbad),-dsam.upress(kbad),'k^','markersize',m2);
plot(d(kbadnisk),-dsam.upress(kbadnisk),'rv','markersize',m2);
ax = axis; ax(3) = -7000; axis(ax);


end

if nsubs >= 8

subplot(1,nsubs,8)

vnam = vnam5;
cmd = ['d = dsam.' vnam ';']; eval(cmd)
if exist('dsam1','var') == 1; cmd = ['d1 = dsam1.' vnam ';']; eval(cmd); else d1 = d+nan; end
if exist('dsam2','var') == 1; cmd = ['d2 = dsam2.' vnam ';']; eval(cmd); else d2 = d+nan; end
if exist('dsam3','var') == 1; cmd = ['d3 = dsam3.' vnam ';']; eval(cmd); else d3 = d+nan; end
if exist('dsam4','var') == 1; cmd = ['d4 = dsam4.' vnam ';']; eval(cmd); else d4 = d+nan; end
cmd = ['dg = dgrid.' vnam ';']; eval(cmd)
if isfield(dsam,[vnam '_flag']); und = '_'; end
if isfield(dsam,[vnam 'flag']); und = ''; end
cmd = ['dflag = dsam.' vnam und 'flag;']; eval(cmd)
if exist('dsam1','var') == 1; cmd = ['dflag1 = dsam1.' vnam und 'flag;']; eval(cmd); else dflag1 = d+nan; end
if exist('dsam2','var') == 1; cmd = ['dflag2 = dsam2.' vnam und 'flag;']; eval(cmd); else dflag2 = d+nan; end
if exist('dsam3','var') == 1; cmd = ['dflag3 = dsam3.' vnam und 'flag;']; eval(cmd); else dflag3 = d+nan; end
if exist('dsam4','var') == 1; cmd = ['dflag4 = dsam4.' vnam und 'flag;']; eval(cmd); else dflag4 = d+nan; end
kok1 = find(dflag1 == 2);
kok2 = find(dflag2 == 2);
kok3 = find(dflag3 == 2);
kok4 = find(dflag4 == 2);

kmat = find(dgrid.statnum == stnlocal);
kbad = find(dflag ~= 2);
kbadnisk = find(dsam.bottle_qc_flag~=2);
plot(dg(kmat),-dgrid.press(kmat),'r-'); 
hold on; grid on;
if ~isempty(kok1); plot(d1(kok1),-dsam1.upress(kok1),'ko','markersize',m0); end
if ~isempty(kok2); plot(d2(kok2),-dsam2.upress(kok2),'ko','markersize',m0); end
if ~isempty(kok3); plot(d3(kok3),-dsam3.upress(kok3),'co','markersize',m0); end
if ~isempty(kok4); plot(d4(kok4),-dsam4.upress(kok4),'co','markersize',m0); end
title(['Stn ' sprintf('%03d',stnlocal)]);
xlabel(vnam);
plot(d,-dsam.upress,'b+','markersize',m1);
plot(d(kbad),-dsam.upress(kbad),'k^','markersize',m2);
plot(d(kbadnisk),-dsam.upress(kbadnisk),'rv','markersize',m2);
ax = axis; ax(3) = -7000; axis(ax);


end

