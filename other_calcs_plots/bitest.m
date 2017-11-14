function bottle_inspection(snum,vnam1,vnam2,vnam3,vnam4,vnam5)
m_common

section = '24n';
section = '20wc';
% vnam2 = 'dic';
% vnam1 = 'alk';
nsubs = nargin+2;

m0 = 5;
m1 = 7;
m2 = 10;

fnctd = ['ctd_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' sprintf('%03d',snum) '_psal'];
fnsam1 = ['sam_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' sprintf('%03d',snum-2)];
fnsam2 = ['sam_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' sprintf('%03d',snum-1)];
fnsam = ['sam_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' sprintf('%03d',snum)];
fnsam3 = ['sam_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' sprintf('%03d',snum+1)];
fnsam4 = ['sam_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' sprintf('%03d',snum+2)];
fngrid = ['grid_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' section];
fndcs = ['dcs_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' sprintf('%03d',snum)];

clear dsam1 dsam2 dsam3 dsam4 hsam1 hsam2 hsam3 hsam4
[dctd hctd] = mload(fnctd,'/');
if exist(m_add_nc(fnsam1),'file') == 2; [dsam1 hsam1]  = mload(fnsam1,'/'); end
if exist(m_add_nc(fnsam2),'file') == 2; [dsam2 hsam2]  = mload(fnsam2,'/'); end
[dsam hsam]  = mload(fnsam,'/');
if exist(m_add_nc(fnsam3),'file') == 2; [dsam3 hsam3]  = mload(fnsam3,'/'); end
if exist(m_add_nc(fnsam4),'file') == 2; [dsam4 hsam4]  = mload(fnsam4,'/'); end
[dgrid hgrid]  = mload(fngrid,'/');
[ddcs hdcs] = mload(fndcs,'/');

dcstime1 = datenum(hdcs.data_time_origin) + ddcs.time_start;
dcstime2 = datenum(hdcs.data_time_origin) + ddcs.time_bot;
dcstime3 = datenum(hdcs.data_time_origin) + ddcs.time_end;

ctdtime = datenum(hctd.data_time_origin) + dctd.time;

kdown = find(ctdtime > dcstime1 & ctdtime < dcstime2);
kup = find(ctdtime > dcstime2 & ctdtime < dcstime3);

m_figure
scrsz = get(0,'ScreenSize');
set(gcf,'Position',[1 0.3*scrsz(4) 1.0*scrsz(3) 0.68*scrsz(4)])

subplot(1,nsubs,1)
vnam = 'psal';
kbadpsal = find(dsam.botpsalflag~=2);
kbadnisk = find(dsam.bottle_qc_flag~=2);
plot(dctd.psal(kdown),-dctd.press(kdown),'k-'); 
hold on; grid on;
title(['Stn ' sprintf('%03d',snum)]);
xlabel('psal');
plot(dctd.psal(kup),-dctd.press(kup),'r-');
plot(dsam.botpsal,-dsam.upress,'b+','markersize',m1);
plot(dsam.botpsal(kbadpsal),-dsam.upress(kbadpsal),'k^','markersize',m2);
plot(dsam.botpsal(kbadnisk),-dsam.upress(kbadnisk),'rv','markersize',m2);;
ax = axis; ax(3) = -7000; axis(ax);

subplot(1,nsubs,2)

kbadoxy = find(dsam.botoxyflag~=2);
kbadnisk = find(dsam.bottle_qc_flag~=2);
plot(dctd.oxygen(kdown),-dctd.press(kdown),'k-'); 
hold on; grid on;
title(['Stn ' sprintf('%03d',snum)]);
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
title(['Stn ' sprintf('%03d',snum)]);
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

if nsubs < 4; return; end

subplot(1,nsubs,4)


vnam = vnam1;
cmd = ['d = dsam.' vnam ';']; eval(cmd)
if exist('dsam1','var') == 1; cmd = ['d1 = dsam1.' vnam ';']; eval(cmd); else d1 = d+nan; end
if exist('dsam2','var') == 1; cmd = ['d2 = dsam2.' vnam ';']; eval(cmd); else d2 = d+nan; end
if exist('dsam3','var') == 1; cmd = ['d3 = dsam3.' vnam ';']; eval(cmd); else d3 = d+nan; end
if exist('dsam4','var') == 1; cmd = ['d4 = dsam4.' vnam ';']; eval(cmd); else d4 = d+nan; end
cmd = ['dg = dgrid.' vnam ';']; eval(cmd)
cmd = ['dflag = dsam.' vnam 'flag;']; eval(cmd)
if exist('dsam1','var') == 1; cmd = ['dflag1 = dsam1.' vnam 'flag;']; eval(cmd); else dflag1 = d+nan; end
if exist('dsam2','var') == 1; cmd = ['dflag2 = dsam2.' vnam 'flag;']; eval(cmd); else dflag2 = d+nan; end
if exist('dsam3','var') == 1; cmd = ['dflag3 = dsam3.' vnam 'flag;']; eval(cmd); else dflag3 = d+nan; end
if exist('dsam4','var') == 1; cmd = ['dflag4 = dsam4.' vnam 'flag;']; eval(cmd); else dflag4 = d+nan; end
kok1 = find(dflag1 == 2);
kok2 = find(dflag2 == 2);
kok3 = find(dflag3 == 2);
kok4 = find(dflag4 == 2);

kmat = find(dgrid.statnum == snum);
kbad = find(dflag ~= 2);
kbadnisk = find(dsam.bottle_qc_flag~=2);
plot(dg(kmat),-dgrid.press(kmat),'r-'); 
hold on; grid on;
if ~isempty(kok1); plot(d1(kok1),-dsam1.upress(kok1),'ko','markersize',m0); end
if ~isempty(kok2); plot(d2(kok2),-dsam2.upress(kok2),'ko','markersize',m0); end
if ~isempty(kok3); plot(d3(kok3),-dsam3.upress(kok3),'co','markersize',m0); end
if ~isempty(kok4); plot(d4(kok4),-dsam4.upress(kok4),'co','markersize',m0); end
title(['Stn ' sprintf('%03d',snum)]);
xlabel(vnam);
plot(d,-dsam.upress,'b+','markersize',m1);
plot(d(kbad),-dsam.upress(kbad),'k^','markersize',m2);
plot(d(kbadnisk),-dsam.upress(kbadnisk),'rv','markersize',m2);
ax = axis; ax(3) = -7000; axis(ax);

if nsubs < 5; return; end


subplot(1,nsubs,5)

vnam = vnam2;
cmd = ['d = dsam.' vnam ';']; eval(cmd)
if exist('dsam1','var') == 1; cmd = ['d1 = dsam1.' vnam ';']; eval(cmd); else d1 = d+nan; end
if exist('dsam2','var') == 1; cmd = ['d2 = dsam2.' vnam ';']; eval(cmd); else d2 = d+nan; end
if exist('dsam3','var') == 1; cmd = ['d3 = dsam3.' vnam ';']; eval(cmd); else d3 = d+nan; end
if exist('dsam4','var') == 1; cmd = ['d4 = dsam4.' vnam ';']; eval(cmd); else d4 = d+nan; end
cmd = ['dg = dgrid.' vnam ';']; eval(cmd)
cmd = ['dflag = dsam.' vnam '_flag;']; eval(cmd)
if exist('dsam1','var') == 1; cmd = ['dflag1 = dsam1.' vnam '_flag;']; eval(cmd); else dflag1 = d+nan; end
if exist('dsam2','var') == 1; cmd = ['dflag2 = dsam2.' vnam '_flag;']; eval(cmd); else dflag2 = d+nan; end
if exist('dsam3','var') == 1; cmd = ['dflag3 = dsam3.' vnam '_flag;']; eval(cmd); else dflag3 = d+nan; end
if exist('dsam4','var') == 1; cmd = ['dflag4 = dsam4.' vnam '_flag;']; eval(cmd); else dflag4 = d+nan; end
kok1 = find(dflag1 == 2);
kok2 = find(dflag2 == 2);
kok3 = find(dflag3 == 2);
kok4 = find(dflag4 == 2);

kmat = find(dgrid.statnum == snum);
kbad = find(dflag ~= 2);
kbadnisk = find(dsam.bottle_qc_flag~=2);
plot(dg(kmat),-dgrid.press(kmat),'r-'); 
hold on; grid on;
if ~isempty(kok1); plot(d1(kok1),-dsam1.upress(kok1),'ko','markersize',m0); end
if ~isempty(kok2); plot(d2(kok2),-dsam2.upress(kok2),'ko','markersize',m0); end
if ~isempty(kok3); plot(d3(kok3),-dsam3.upress(kok3),'co','markersize',m0); end
if ~isempty(kok4); plot(d4(kok4),-dsam4.upress(kok4),'co','markersize',m0); end
title(['Stn ' sprintf('%03d',snum)]);
xlabel(vnam);
plot(d,-dsam.upress,'b+','markersize',m1);
plot(d(kbad),-dsam.upress(kbad),'k^','markersize',m2);
plot(d(kbadnisk),-dsam.upress(kbadnisk),'rv','markersize',m2);
ax = axis; ax(3) = -7000; axis(ax);

if nsubs < 6; return; end


subplot(1,nsubs,6)

vnam = vnam3;
cmd = ['d = dsam.' vnam ';']; eval(cmd)
if exist('dsam1','var') == 1; cmd = ['d1 = dsam1.' vnam ';']; eval(cmd); else d1 = d+nan; end
if exist('dsam2','var') == 1; cmd = ['d2 = dsam2.' vnam ';']; eval(cmd); else d2 = d+nan; end
if exist('dsam3','var') == 1; cmd = ['d3 = dsam3.' vnam ';']; eval(cmd); else d3 = d+nan; end
if exist('dsam4','var') == 1; cmd = ['d4 = dsam4.' vnam ';']; eval(cmd); else d4 = d+nan; end
cmd = ['dg = dgrid.' vnam ';']; eval(cmd)
cmd = ['dflag = dsam.' vnam '_flag;']; eval(cmd)
if exist('dsam1','var') == 1; cmd = ['dflag1 = dsam1.' vnam '_flag;']; eval(cmd); else dflag1 = d+nan; end
if exist('dsam2','var') == 1; cmd = ['dflag2 = dsam2.' vnam '_flag;']; eval(cmd); else dflag2 = d+nan; end
if exist('dsam3','var') == 1; cmd = ['dflag3 = dsam3.' vnam '_flag;']; eval(cmd); else dflag3 = d+nan; end
if exist('dsam4','var') == 1; cmd = ['dflag4 = dsam4.' vnam '_flag;']; eval(cmd); else dflag4 = d+nan; end
kok1 = find(dflag1 == 2);
kok2 = find(dflag2 == 2);
kok3 = find(dflag3 == 2);
kok4 = find(dflag4 == 2);

kmat = find(dgrid.statnum == snum);
kbad = find(dflag ~= 2);
kbadnisk = find(dsam.bottle_qc_flag~=2);
plot(dg(kmat),-dgrid.press(kmat),'r-'); 
hold on; grid on;
if ~isempty(kok1); plot(d1(kok1),-dsam1.upress(kok1),'ko','markersize',m0); end
if ~isempty(kok2); plot(d2(kok2),-dsam2.upress(kok2),'ko','markersize',m0); end
if ~isempty(kok3); plot(d3(kok3),-dsam3.upress(kok3),'co','markersize',m0); end
if ~isempty(kok4); plot(d4(kok4),-dsam4.upress(kok4),'co','markersize',m0); end
title(['Stn ' sprintf('%03d',snum)]);
xlabel(vnam);
plot(d,-dsam.upress,'b+','markersize',m1);
plot(d(kbad),-dsam.upress(kbad),'k^','markersize',m2);
plot(d(kbadnisk),-dsam.upress(kbadnisk),'rv','markersize',m2);
ax = axis; ax(3) = -7000; axis(ax);

if nsubs < 7; return; end

subplot(1,nsubs,7)

vnam = vnam4;
cmd = ['d = dsam.' vnam ';']; eval(cmd)
if exist('dsam1','var') == 1; cmd = ['d1 = dsam1.' vnam ';']; eval(cmd); else d1 = d+nan; end
if exist('dsam2','var') == 1; cmd = ['d2 = dsam2.' vnam ';']; eval(cmd); else d2 = d+nan; end
if exist('dsam3','var') == 1; cmd = ['d3 = dsam3.' vnam ';']; eval(cmd); else d3 = d+nan; end
if exist('dsam4','var') == 1; cmd = ['d4 = dsam4.' vnam ';']; eval(cmd); else d4 = d+nan; end
cmd = ['dg = dgrid.' vnam ';']; eval(cmd)
cmd = ['dflag = dsam.' vnam '_flag;']; eval(cmd)
if exist('dsam1','var') == 1; cmd = ['dflag1 = dsam1.' vnam '_flag;']; eval(cmd); else dflag1 = d+nan; end
if exist('dsam2','var') == 1; cmd = ['dflag2 = dsam2.' vnam '_flag;']; eval(cmd); else dflag2 = d+nan; end
if exist('dsam3','var') == 1; cmd = ['dflag3 = dsam3.' vnam '_flag;']; eval(cmd); else dflag3 = d+nan; end
if exist('dsam4','var') == 1; cmd = ['dflag4 = dsam4.' vnam '_flag;']; eval(cmd); else dflag4 = d+nan; end
kok1 = find(dflag1 == 2);
kok2 = find(dflag2 == 2);
kok3 = find(dflag3 == 2);
kok4 = find(dflag4 == 2);

kmat = find(dgrid.statnum == snum);
kbad = find(dflag ~= 2);
kbadnisk = find(dsam.bottle_qc_flag~=2);
plot(dg(kmat),-dgrid.press(kmat),'r-'); 
hold on; grid on;
if ~isempty(kok1); plot(d1(kok1),-dsam1.upress(kok1),'ko','markersize',m0); end
if ~isempty(kok2); plot(d2(kok2),-dsam2.upress(kok2),'ko','markersize',m0); end
if ~isempty(kok3); plot(d3(kok3),-dsam3.upress(kok3),'co','markersize',m0); end
if ~isempty(kok4); plot(d4(kok4),-dsam4.upress(kok4),'co','markersize',m0); end
title(['Stn ' sprintf('%03d',snum)]);
xlabel(vnam);
plot(d,-dsam.upress,'b+','markersize',m1);
plot(d(kbad),-dsam.upress(kbad),'k^','markersize',m2);
plot(d(kbadnisk),-dsam.upress(kbadnisk),'rv','markersize',m2);
ax = axis; ax(3) = -7000; axis(ax);


if nsubs < 8; return; end

subplot(1,nsubs,8)

vnam = vnam5;
cmd = ['d = dsam.' vnam ';']; eval(cmd)
if exist('dsam1','var') == 1; cmd = ['d1 = dsam1.' vnam ';']; eval(cmd); else d1 = d+nan; end
if exist('dsam2','var') == 1; cmd = ['d2 = dsam2.' vnam ';']; eval(cmd); else d2 = d+nan; end
if exist('dsam3','var') == 1; cmd = ['d3 = dsam3.' vnam ';']; eval(cmd); else d3 = d+nan; end
if exist('dsam4','var') == 1; cmd = ['d4 = dsam4.' vnam ';']; eval(cmd); else d4 = d+nan; end
cmd = ['dg = dgrid.' vnam ';']; eval(cmd)
cmd = ['dflag = dsam.' vnam '_flag;']; eval(cmd)
if exist('dsam1','var') == 1; cmd = ['dflag1 = dsam1.' vnam '_flag;']; eval(cmd); else dflag1 = d+nan; end
if exist('dsam2','var') == 1; cmd = ['dflag2 = dsam2.' vnam '_flag;']; eval(cmd); else dflag2 = d+nan; end
if exist('dsam3','var') == 1; cmd = ['dflag3 = dsam3.' vnam '_flag;']; eval(cmd); else dflag3 = d+nan; end
if exist('dsam4','var') == 1; cmd = ['dflag4 = dsam4.' vnam '_flag;']; eval(cmd); else dflag4 = d+nan; end
kok1 = find(dflag1 == 2);
kok2 = find(dflag2 == 2);
kok3 = find(dflag3 == 2);
kok4 = find(dflag4 == 2);

kmat = find(dgrid.statnum == snum);
kbad = find(dflag ~= 2);
kbadnisk = find(dsam.bottle_qc_flag~=2);
plot(dg(kmat),-dgrid.press(kmat),'r-'); 
hold on; grid on;
if ~isempty(kok1); plot(d1(kok1),-dsam1.upress(kok1),'ko','markersize',m0); end
if ~isempty(kok2); plot(d2(kok2),-dsam2.upress(kok2),'ko','markersize',m0); end
if ~isempty(kok3); plot(d3(kok3),-dsam3.upress(kok3),'co','markersize',m0); end
if ~isempty(kok4); plot(d4(kok4),-dsam4.upress(kok4),'co','markersize',m0); end
title(['Stn ' sprintf('%03d',snum)]);
xlabel(vnam);
plot(d,-dsam.upress,'b+','markersize',m1);
plot(d(kbad),-dsam.upress(kbad),'k^','markersize',m2);
plot(d(kbadnisk),-dsam.upress(kbadnisk),'rv','markersize',m2);
ax = axis; ax(3) = -7000; axis(ax);



