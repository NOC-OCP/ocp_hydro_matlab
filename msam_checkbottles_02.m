function msam_checkbottles_02(stn, varargin)
% function msam_checkbottles_02(stn,varargin)
% function msam_checkbottles_02(stn,vnam1,vnam2,vnam3,vnam4,vnam5)
%
% (formerly bottle_inspectionall)
%
%
% plots psal, oxygen, potemp, and the other variables you name
%
% input arguments after stn are strings naming variables in
% sam_cruise_all.nc
%

m_common
scriptname = 'msam_checkbottles_02';
minit

%subplots will be psal (and botpsal), oxygen (and botoxygen), and potemp (and botoxytemp and sbe35temp [if avail]),
%as well as the variable input names
nsubs = nargin+2; % = length(varargin)+3
for no = 1:length(varargin)
    vnams{no} = varargin{no};
end


%%%%%%%%% get data %%%%%%%%%

root_ctd = mgetdir('M_CTD');

fnctd = [root_ctd '/ctd_' mcruise '_' sprintf('%03d',stnlocal) '_psal'];
fnsamall = [root_ctd '/sam_' mcruise '_all'];
oopt = 'section'; get_cropt
fngrid = [root_ctd '/grid_' mcruise '_' section];
fndcs = [root_ctd '/dcs_' mcruise '_' sprintf('%03d',stnlocal)];

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
ksam1 = find(dsamall.statnum == stnlist(1));
ksam2 = find(dsamall.statnum == stnlist(2));
ksam = find(dsamall.statnum == stnlist(3));
ksam3 = find(dsamall.statnum == stnlist(4));
ksam4 = find(dsamall.statnum == stnlist(5));

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

if ~isfield(dsam, 'botoxytemp') & isfield(dsam, 'botoxytempa'); dsam.botoxytemp = dsam.botoxytempa; end % jc159 cludge
if ~isfield(dsam, 'sbe35temp'); dsam.sbe35temp = NaN+dsam.utemp; dsam.sbe35temp_flag = dsam.sbe35temp; end

%optionally apply preliminary calibration functions (most relevant to get ctd and bottle oxygen close)
oopt = 'docals'; get_cropt
if dotcal
   scriptname = 'mctd_03'; oopt = 's_choice'; get_cropt; scriptname = 'msam_checkbottles_02';
   dctd.temp = temp_apply_cal(s_choice,stnlocal,dctd.press,0*dctd.press,dctd.temp);
end
if doccal
   scriptname = 'mctd_03'; oopt = 's_choice'; get_cropt; scriptname = 'msam_checkbottles_02';
   dctd.cond = cond_apply_cal(s_choice,stnlocal,dctd.press,0*dctd.press,dctd.temp,dctd.cond);
end
if doocal
   scriptname = 'mctd_03'; oopt = 'o_choice'; get_cropt; scriptname = 'msam_checkbottles_02';
   dctd.oxygen = oxy_apply_cal(o_choice,stnlocal,dctd.press,0*dctd.press,dctd.temp,dctd.oxygen);
end
if doccal | dotcal
   dctd.psal = gsw_SP_from_C(dctd.cond, dctd.temp, dctd.press);
   dctd.asal = gsw_SA_from_SP(dctd.psal, dctd.press, hctd.longitude, hctd.latitude);
   dctd.potemp = gsw_pt0_from_t(dctd.asal, dctd.temp, dctd.press);
end



%%%%%%%%% plot %%%%%%%%%

%marker sizes
m0 = 5;
m1 = 7;
m2 = 10;
yl = [-7000 0];
yl = [-ceil(max(dctd.press(~isnan(dctd.potemp)))) 0];

m_figure
scrsz = get(0,'ScreenSize');
set(gcf,'Position',[1 0.4*scrsz(4) 0.9*scrsz(3) 0.5*scrsz(4)])

kbadnisk = find(dsam.bottle_qc_flag==4); kqnisk = find(dsam.bottle_qc_flag==3);

subplot(1,nsubs,1)
vnam = 'psal';
kbadpsal = find(dsam.botpsalflag~=2);
kbadsbe35 = find(dsam.sbe35temp~=2);
h1 = plot(dctd.psal(kdown),-dctd.press(kdown),'m--'); 
hold on; grid on;
title(['Stn ' sprintf('%03d',stnlocal)]);
xlabel('psal');
h2 = plot(dctd.psal(kup),-dctd.press(kup),'r-');
h3 = plot(dsam.botpsal,-dsam.upress,'b+','markersize',m1);
h4 = plot(dsam.botpsal(kbadpsal),-dsam.upress(kbadpsal),'k^','markersize',m2);
h5 = plot(dsam.botpsal(kbadnisk),-dsam.upress(kbadnisk),'rv','markersize',m2);
h6 = plot(dsam.botpsal(kqnisk),-dsam.upress(kqnisk),'mv','markersize',m2);
ylim(yl)

ls = {};
if ~isempty(kbadpsal); ls = [ls; 'bad sample']; end
if ~isempty(kbadnisk); ls = [ls; 'bad niskin']; end
if ~isempty(kqnisk); ls = [ls; 'questionable nisk']; end
legend([h4 h5 h6],ls,'location','best');

subplot(1,nsubs,2)

kbadoxy = find(dsam.botoxyflag~=2);

plot(dctd.oxygen(kdown),-dctd.press(kdown),'m--'); 
hold on; grid on;
title(['Stn ' sprintf('%03d',stnlocal)]);
xlabel('oxygen');
plot(dctd.oxygen(kup),-dctd.press(kup),'r-');
plot(dsam.botoxy,-dsam.upress,'b+','markersize',m1);
plot(dsam.botoxy(kbadoxy),-dsam.upress(kbadoxy),'k^','markersize',m2);
plot(dsam.botoxy(kbadnisk),-dsam.upress(kbadnisk),'rv','markersize',m2);
plot(dsam.botoxy(kqnisk),-dsam.upress(kqnisk),'mv','markersize',m2);
ylim(yl)

subplot(1,nsubs,3)

plot(dctd.potemp(kdown),-dctd.press(kdown),'m--'); 
hold on; grid on;
title(['Stn ' sprintf('%03d',stnlocal)]);
xlabel('potemp/botoxytemp/depths');
plot(dctd.potemp(kup),-dctd.press(kup),'r-');
plot(dsam.botoxytemp,-dsam.upress,'b+','markersize',m1);
plot(dsam.botoxytemp(kbadoxy),-dsam.upress(kbadoxy),'k^','markersize',m2);
plot(dsam.botoxytemp(kbadnisk),-dsam.upress(kbadnisk),'rv','markersize',m2);
plot(dsam.botoxytemp(kqnisk),-dsam.upress(kqnisk),'mv','markersize',m2);
plot(dsam.sbe35temp,-dsam.upress,'c+','markersize',m1);
plot(dsam.sbe35temp(kbadsbe35),-dsam.upress(kbadsbe35),'m<','markersize',m2);
plot(max([dsam.botoxytemp+1;0])+dsam.bottle_qc_flag,-dsam.upress,'k+','markersize',m1);
plot(max([dsam.botoxytemp+1;0])+dsam.bottle_qc_flag(kbadnisk),-dsam.upress(kbadnisk),'rv','markersize',m2);
plot(max([dsam.botoxytemp+1;0])+dsam.bottle_qc_flag(kqnisk),-dsam.upress(kqnisk),'mv','markersize',m2);
ylim(yl); xlim([-2 max([dsam.botoxytemp+1;0]+1)])
for klab = 1:24
    text(max([dsam.botoxytemp+1;0])+dsam.bottle_qc_flag(klab),-dsam.upress(klab),...
        sprintf('%d  ',dsam.position(klab)),'fontsize',14,'horizontalalignment','right','verticalalignment','middle')
end


% now add the other variables whose names were provided as input

for veno = 1:nsubs-3

   vnam = vnams{veno};
   
   d = getfield(dsam, vnam);
   if exist('dsam1','var') == 1; d1 = getfield(dsam1, vnam); else; d1 = d+nan; end
   if exist('dsam2','var') == 1; d2 = getfield(dsam2, vnam); else; d2 = d+nan; end
   if exist('dsam3','var') == 1; d3 = getfield(dsam3, vnam); else; d3 = d+nan; end
   if exist('dsam4','var') == 1; d4 = getfield(dsam4, vnam); else; d4 = d+nan; end
   dg = getfield(dgrid, vnam);
   if isfield(dsam,[vnam '_flag']); und = '_'; end
   if isfield(dsam,[vnam 'flag']); und = ''; end
   dflag = getfield(dsam, [vnam und 'flag']);
   if exist('dsam1','var') == 1; dflag1 = getfield(dsam1, [vnam und 'flag']); else; dflag1 = d+nan; end
   if exist('dsam2','var') == 1; dflag2 = getfield(dsam2, [vnam und 'flag']); else; dflag2 = d+nan; end
   if exist('dsam3','var') == 1; dflag3 = getfield(dsam3, [vnam und 'flag']); else; dflag3 = d+nan; end
   if exist('dsam4','var') == 1; dflag4 = getfield(dsam4, [vnam und 'flag']); else; dflag4 = d+nan; end
   kok1 = find(dflag1 == 2);
   kok2 = find(dflag2 == 2);
   kok3 = find(dflag3 == 2);
   kok4 = find(dflag4 == 2);

   kmat = find(dgrid.statnum == stnlocal);
   kbad = find(dflag ~= 2);

   subplot(1,nsubs,veno+3)

   plot(dg(kmat),-dgrid.press(kmat),'r-'); 
   hold on; grid on;
   if ~isempty(kok1); plot(d1(kok1),-dsam1.upress(kok1),'ko','markersize',m0); end
   if ~isempty(kok2); plot(d2(kok2),-dsam2.upress(kok2),'ko','markersize',m0); end %2 stations before
   if ~isempty(kok3); plot(d3(kok3),-dsam3.upress(kok3),'co','markersize',m0); end
   if ~isempty(kok4); plot(d4(kok4),-dsam4.upress(kok4),'co','markersize',m0); end %2 stations after
   title(['Stn ' sprintf('%03d',stnlocal)]);
   xlabel(vnam);
   plot(d,-dsam.upress,'b+','markersize',m1);
   plot(d(kbad),-dsam.upress(kbad),'k^','markersize',m2);
   plot(d(kbadnisk),-dsam.upress(kbadnisk),'rv','markersize',m2);
   plot(d(kqnisk),-dsam.upress(kqnisk),'mv','markersize',m2);
   ylim(yl)

end

%pause
for no = 1:nsubs; subplot(1,nsubs,no); ylim([-500 0]); end
pause
for no = 1:nsubs; subplot(1,nsubs,no); ylim(yl); end


