%compare geostrophic velocity, sadcp velocity, and ladcp velocity

mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

%which stations
load ctd_mat lon lat stns %***

%***load ladcp from combined file instead

%load ladcp and sadcp
lpre = '/local/users/pstar/cruise/data/ladcp/uh/pro/jc1802/ladcp/proc/matprof/h/';
spre = '/local/users/pstar/cruise/data/vmadcp/mproc/';
ldz = 20;
luv = zeros(323, length(stns)); ln = luv; lshr = luv(1:end-1,:); lns = lshr;
lgd = zeros(6, length(stns));
suv1 = luv; suv2 = suv1;

for sno = 1:length(stns)
   stn_string = sprintf('%03d', stns(sno));

   %load ladcp
   fnamed = [lpre 'j' stn_string '_02.mat'];
   fnameu = [lpre 'j' stn_string '_03.mat'];
   if exist(fnamed, 'file')
      ld = load(fnamed);
      luv(:,sno) = luv(:,sno) + complex(ld.su_mn_i, ld.sv_mn_i);
      ln(:,sno) = ln(:,sno) + ld.sm_mn_i;
      uvz = diff(complex(ld.su_dn_i(ld.sm_mn_i), ld.sv_dn_i(ld.sm_mn_i)))/ldz/2+diff(complex(ld.su_up_i(ld.sm_mn_i), ld.sv_dn_i(ld.sm_mn_i)))/ldz/2;
      ii = find(ld.sm_mn_i(1:end-1)+ld.sm_mn_i(2:end)==2);
      lshr(ii,sno) = lshr(ii,sno) + uvz;
      lns(:,sno) = lns(:,sno) + double(ld.sm_mn_i(1:end-1)==1 & ld.sm_mn_i(2:end)==1);
      lgd(1, sno) = sum(ld.sm_mn_i); lgd(2, sno) = sum(ld.sm_dn_i); lgd(3, sno) = sum(ld.sm_up_i);
   end
   if exist(fnameu, 'file')
      lu = load(fnameu);
      luv(:,sno) = luv(:,sno) + complex(lu.su_mn_i, lu.sv_mn_i);
      ln(:,sno) = ln(:,sno) + lu.sm_mn_i;
      uvz = diff(complex(lu.su_dn_i(lu.sm_mn_i), lu.sv_dn_i(lu.sm_mn_i)))/ldz/2+diff(complex(lu.su_up_i(lu.sm_mn_i), lu.sv_dn_i(lu.sm_mn_i)))/ldz/2;
      ii = find(lu.sm_mn_i(1:end-1)+lu.sm_mn_i(2:end)==2);
      lshr(ii,sno) = lshr(ii,sno) + uvz;
      lns(:,sno) = lns(:,sno) + double(lu.sm_mn_i(1:end-1)==1 & lu.sm_mn_i(2:end)==1);
      lgd(4, sno) = sum(lu.sm_mn_i); lgd(5, sno) = sum(lu.sm_dn_i); lgd(6, sno) = sum(lu.sm_up_i);
   end

   %load sadcp
   fnames1 = [spre 'os150_' mcruise '_wait_' stn_string '_ave.nc'];
   fnames2 = [spre 'os75_' mcruise '_wait_' stn_string '_ave.nc'];
   if ~exist(fnames1, 'file')
      cast = 'wait'; os = 150; stn = stns(sno); mvad_03
   end
   if exist(fnames1, 'file')
      [d,h] = mload(fnames1, '/');
      suv1(:,sno) = suv1(:,sno) + interp1(d.depth, complex(d.uabs, d.vabs), d_samp);
   end
   if 0
   if ~exist(fnames2, 'file')
      cast = 'wait'; os = 75; stn = stns(sno); mvad_03
   end
   if exist(fnames2, 'file')
      [d,h] = mload(fnames2, '/');
      suv2(:,sno) = suv2(:,sno) + interp1(d.depth, complex(d.uabs, d.vabs), d_samp);
   end
   end
   
%   keyboard
   
end

suv(:,:,1) = suv1; suv(:,:,2) = suv2; suv = m_nanmean(suv, 3);
luv = luv./ln; luv(ln==0) = NaN;
lshr = lshr./lns; lshr(lns==0) = NaN;
%clear ln lns

keyboard

%load ctd data
load ctd_mat potemp psal pg %***

%vertical average to 20 dbar
[np, ns] = size(psal);
np = floor(np/10);
pg = nanmean(reshape(pg(1:l*10),10,l))';
psal = squeeze(nanmean(reshape(psal(1:l*10,:),10,l,ns)));
potemp = squeeze(nanmean(reshape(potemp(1:l*10,:),10,l,ns)));

%geostrophic shear (using gsw routines)
SA = gsw_SA_from_SP(psal, pg, lon, lat);
CT = gsw_CT_from_pt(SA, potemp);
p_ref = 5;
[phi, gvel, lonm, latm, ang, dst] = gshr(lon, lat, SA, CT, pg, p_ref);

