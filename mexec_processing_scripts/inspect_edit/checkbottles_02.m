function nsubs = checkbottles_02(stn, varargin)
% function nsubs = checkbottles_02(stn,varargin)
% function checkbottles_02(stn,vnam1,vnam2,vnam3,vnam4,vnam5)
%
% (formerly bottle_inspectionall, then msam_checkbottles_02)
%
%
% plots psal, oxygen, potemp, and the other variables you name
%
% inputs:
%   stn, station number
%   [optional] testcal, structure determining whether to apply calibrations
%     from opt_cruise (set testcal.temp = 1 to apply temp calibration,
%     etc.) 
%   [optional] vnam1, vnam2, etc. names of variables to plot in addition to
%     botpsal, botoxy, and sbe35temp and botoxya_temp
%
% requires a gridded section file (mstar .mat)

m_common
opt1 = 'castpars'; opt2 = 'minit'; get_cropt

%subplots will be psal (and botpsal), oxygen (and botoxygen), and potemp (and botoxytemp and sbe35temp [if avail]),
%as well as the variable input names
vnams = {};
for no = 1:length(varargin)
    if isstruct(varargin{no})
        testcal = varargin{no};
    else
        vnams{no} = varargin{no};
    end
end
nsubs = length(vnams)+3; % = length(varargin)+3


%%%%%%%%% get data %%%%%%%%%

root_ctd = mgetdir('M_CTD');

fnctd = fullfile(root_ctd, ['ctd_' mcruise '_' sprintf('%03d',stnlocal) '_psal']);
fnsamall = fullfile(root_ctd, ['sam_' mcruise '_all']);
opt1 = 'msec_grid'; opt2 = 'sections_to_grid'; get_cropt
if exist('sections')
    section = sections{1}; 
else
    section = 'profiles_only';
end
opt1 = 'outputs'; opt2 = 'grid'; get_cropt
stnlist = intersect(stnlocal-2:stnlocal+2,kstns);
if length(stnlist)<5
    warning('fewer than 4 neighbouring stations in section list; skipping')
    return
end
fngrid = fullfile(root_ctd, ['grid_' mcruise '_' section '.mat']);
fndcs = fullfile(root_ctd, ['dcs_' mcruise '_' sprintf('%03d',stnlocal)]);

[dctd, hctd] = mload(fnctd,'/');
[dsamall, ~]  = mload(fnsamall,'/');
load(fngrid,'mgrid'); dgrid = mgrid; 
[ddcs, hdcs] = mload(fndcs,'/');

dcstime1 = m_commontime(ddcs,'time_start',hdcs,'datenum');
dcstime2 = m_commontime(ddcs,'time_bot',hdcs,'datenum');
dcstime3 = m_commontime(ddcs,'time_end',hdcs,'datenum');

ctdtime = m_commontime(dctd,'time',hctd,'datenum');

kdown = find(ctdtime > dcstime1 & ctdtime < dcstime2);
kup = find(ctdtime > dcstime2 & ctdtime < dcstime3);


%distribute all sam data back into separate stations
tall = struct2table(dsamall);
for ks = 1:5
    ms = tall.statnum==stnlist(ks);
    if ks==3
        if sum(ms)==0
            warning('no sample data for station %03d; skipping',stnlist(3))
            return
        end
        dsam = table2struct(tall(ms,:),'ToScalar',true);
    else
       eval(['dsam' num2str(ks) ' = table2struct(tall(ms,:),''ToScalar'',true);']);
    end
end

if ~isfield(dsam, 'botoxya_temp')
    if isfield(dsam, 'botoxytempa')
        dsam.botoxya_temp = dsam.botoxytempa; 
    elseif isfield(dsam, 'botoxytemp')
        dsam.botoxya_temp = dsam.botoxytemp;
    end
end 
if ~isfield(dsam, 'sbe35temp')
    dsam.sbe35temp = NaN+dsam.utemp; dsam.sbe35temp_flag = dsam.sbe35temp; 
end

%optionally apply preliminary calibration functions (most relevant to get ctd and bottle oxygen close)
testcal = [];
opt1 = 'calibration'; opt2 = 'ctd_cals'; get_cropt
if ~isempty(testcal) && isfield(castopts,'calstr')
    [dctd_c, hctd_c] = apply_calibrations(dctd, hctd, castopts.calstr, testcal);
    for no = 1:length(hctd_c.fldnam)
        dctd.(hctd_c.fldnam{no}) = dctd_c.(hctd_c.fldnam{no});
    end
    if castopts.docal.cond || castopts.docal.temp
        dctd.psal = gsw_SP_from_C(dctd.cond2, dctd.temp2, dctd.press);
        dctd.asal = gsw_SA_from_SP(dctd.psal2, dctd.press, hctd.longitude, hctd.latitude);
        dctd.potemp = gsw_pt0_from_t(dctd.asal, dctd.temp2, dctd.press);
    end
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

kbadnisk = find(dsam.niskin_flag==4); kqnisk = find(dsam.niskin_flag==3);

subplot(1,nsubs,1)
vnam = 'psal';
kbadpsal = find(dsam.botpsal_flag~=2);
kbadsbe35 = find(dsam.sbe35temp_flag~=2);
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

h = [h1; h2; h3]; ls = {'downcast'; 'upcast'; 'sample'};
if ~isempty(kbadpsal); ls = [ls; 'bad sample']; h = [h; h4]; end
if ~isempty(kbadnisk); ls = [ls; 'bad niskin']; h = [h; h5]; end
if ~isempty(kqnisk); ls = [ls; 'questionable nisk']; h = [h; h6]; end
if ~isempty(h)
    legend(h,ls,'location','best');
end

subplot(1,nsubs,2)

kbadoxy = find(dsam.botoxy_flag~=2 & dsam.botoxy_flag~=6);

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
xlabel('potemp/botoxytemp(b+)/sbe35temp(x)/nisks');
plot(dctd.potemp(kup),-dctd.press(kup),'r-');
plot(dsam.botoxya_temp,-dsam.upress,'b+','markersize',m1);
plot(dsam.botoxya_temp(kbadoxy),-dsam.upress(kbadoxy),'k^','markersize',m2);
plot(dsam.botoxya_temp(kbadnisk),-dsam.upress(kbadnisk),'rv','markersize',m2);
plot(dsam.botoxya_temp(kqnisk),-dsam.upress(kqnisk),'mv','markersize',m2);
plot(dsam.sbe35temp,-dsam.upress,'cx','markersize',m1);
plot(dsam.sbe35temp(kbadsbe35),-dsam.upress(kbadsbe35),'m<','markersize',m2);
plot(max([dsam.botoxya_temp+1;0])+dsam.niskin_flag,-dsam.upress,'k+','markersize',m1);
plot(max([dsam.botoxya_temp+1;0])+dsam.niskin_flag(kbadnisk),-dsam.upress(kbadnisk),'rv','markersize',m2);
plot(max([dsam.botoxya_temp+1;0])+dsam.niskin_flag(kqnisk),-dsam.upress(kqnisk),'mv','markersize',m2);
ylim(yl); xlim([-2 2+(max([dsam.upotemp;0; dsam.botoxya_temp])+max(dsam.niskin_flag))]); % bak on jc191 bug fix. scale needs to be based on potemp if there are no botoxytemps
for klab = 1:length(dsam.niskin_flag)
	     text(max([dsam.botoxya_temp+1;0;dsam.upotemp])+dsam.niskin_flag(klab),-dsam.upress(klab),...
        sprintf('%d  ',dsam.position(klab)),'fontsize',14,'horizontalalignment','right','verticalalignment','middle')
end


% now add the other variables whose names were provided as input

for veno = 1:nsubs-3

   vnam = vnams{veno};
   
   d = dsam.(vnam);
   if exist('dsam1','var') == 1; d1 = dsam1.(vnam); else; d1 = d+nan; end
   if exist('dsam2','var') == 1; d2 = dsam2.(vnam); else; d2 = d+nan; end
   if exist('dsam3','var') == 1; d3 = dsam3.(vnam); else; d3 = d+nan; end
   if exist('dsam4','var') == 1; d4 = dsam4.(vnam); else; d4 = d+nan; end
   dg = dgrid.(vnam);
   clear und flagname
   if isfield(dsam,[vnam '_flag']); und = '_'; end
   if isfield(dsam,[vnam 'flag']); und = ''; end
   dflag = dsam.([vnam und 'flag']);
   if exist('dsam1','var') == 1; dflag1 = dsam1.([vnam und 'flag']); else; dflag1 = d+nan; end
   if exist('dsam2','var') == 1; dflag2 = dsam2.([vnam und 'flag']); else; dflag2 = d+nan; end
   if exist('dsam3','var') == 1; dflag3 = dsam3.([vnam und 'flag']); else; dflag3 = d+nan; end
   if exist('dsam4','var') == 1; dflag4 = dsam4.([vnam und 'flag']); else; dflag4 = d+nan; end
   if exist('und','var') == 1
       flagname = [vnam und 'flag']; % we managed to match the flag var
   end
   % Now handle some other special cases
   if strcmp(vnam,'silc_per_kg'); flagname = 'silc_flag'; end
   if strcmp(vnam,'phos_per_kg'); flagname = 'phos_flag'; end
   if strcmp(vnam,'totnit_per_kg'); flagname = 'totnit_flag'; end
   
   if exist('flagname','var') ~= 1
       fprintf(2,'\n\n %s %s %s \n\n\n','No flagname found for variable ',vnam,' remove it from the list and try again');
       error();
   end
   
   dflag = dsam.(flagname); 
   if exist('dsam1','var') == 1; dflag1 = dsam1.(flagname); else; dflag1 = d+nan; end
   if exist('dsam2','var') == 1; dflag2 = dsam2.(flagname); else; dflag2 = d+nan; end
   if exist('dsam3','var') == 1; dflag3 = dsam3.(flagname); else; dflag3 = d+nan; end
   if exist('dsam4','var') == 1; dflag4 = dsam4.(flagname); else; dflag4 = d+nan; end
   kok1 = find(dflag1 == 2);
   kok2 = find(dflag2 == 2);
   kok3 = find(dflag3 == 2);
   kok4 = find(dflag4 == 2);

   kmat = find(dgrid.statnum == stnlocal);
   kbad = find(dflag ~= 2 & dflag~=6);

   subplot(1,nsubs,veno+3)

   plot(dg(kmat),-dgrid.press(kmat),'r-'); 
   hold on; grid on;
   if ~isempty(kok1); plot(d1(kok1),-dsam1.upress(kok1),'ko','markersize',m0); end
   if ~isempty(kok2); plot(d2(kok2),-dsam2.upress(kok2),'cs','markersize',m0); end %2 stations before % jc191 k and m are earlier, c and r are later
   if ~isempty(kok3); plot(d3(kok3),-dsam3.upress(kok3),'ms','markersize',m0); end
   if ~isempty(kok4); plot(d4(kok4),-dsam4.upress(kok4),'ro','markersize',m0); end %2 stations after
   if veno==nsubs-4; title(['kc (left), b Stn ' sprintf('%03d',stnlocal) ' mr (right)']); end
   xlabel(vnam,'interpreter','none');
   plot(d,-dsam.upress,'b+','markersize',m1);
   plot(d(kbad),-dsam.upress(kbad),'k^','markersize',m2);
   plot(d(kbadnisk),-dsam.upress(kbadnisk),'rv','markersize',m2);
   plot(d(kqnisk),-dsam.upress(kqnisk),'mv','markersize',m2);
   ylim(yl)

end

for no = 1:nsubs; subplot(1,nsubs,no); ylim([-500 0]); end
disp('enter to continue')
pause
for no = 1:nsubs; subplot(1,nsubs,no); ylim(yl); end
cont = input('k for keyboard or enter to continue\n','s');
if strcmp(cont,'k')
    keyboard
else
    return
end


