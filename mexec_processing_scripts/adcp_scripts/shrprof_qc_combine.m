pre = '/local/users/pstar/cruise/data/ladcp/uh/pro/jc1802/ladcp/proc/matprof/h/';

fnamesd = dir([pre 'j*_02.mat']);

nz = 323; ns = length(fnamesd);
dz = 20;
nmin = 10; %minimum number of pings per bin to keep

cmap = [0 0 1; 0 .6 .5; 1 0 0; 1 .5 0];

%com0 = complex(0);
%uv_nofill = repmat(NaN+i*NaN, nz, ns); uv_0shrfill = uv_nofill; uv_linshrfill = uv_nofill;
%stns = NaN+zeros(1, ns);

for no = 83:length(fnamesd)

   stn = str2num(fnamesd(no).name(2:4));
   if stn<=125
   stns(no) = stn; 

   %load down- and up-looker data
   load([pre fnamesd(no).name])
   z = -d_samp;
   fnameu = sprintf('j%03d_03.mat', stns(no));
   if exist([pre fnameu], 'file')
      upl = load([pre fnameu]);
   else
      upl = [];
   end
   
   %convert back to shear (reverse cumsum with first difference)
   uvz_d = diff([com0; complex(su_dn_i, sv_dn_i)])/dz;
   uvz_u = diff([com0; complex(su_up_i, sv_up_i)])/dz;
   if ~isempty(upl)
      uuvz_d = diff([com0; complex(upl.su_dn_i, upl.sv_dn_i)])/dz;
      uuvz_u = diff([com0; complex(upl.su_up_i, upl.sv_up_i)])/dz;
   else
      uuvz_d = zeros(nz, 1); uuvz_u = uuvz_d;
   end
   
   %mask more, first based on a minimum pings threshold
   mdn = sm_dn_i & sn_dn_i>=nmin;
   mup = sm_up_i & sn_up_i>=nmin;
   if ~isempty(upl)
      umdn = upl.sm_dn_i & upl.sn_dn_i>=nmin;
      umup = upl.sm_up_i & upl.sn_up_i>=nmin;
   end

   %now use gui to check and modify mask
   notdone = 1; nrep = 0;
   while notdone & nrep<5
      figure(1); clf; clear hl
      ssc = 1e4;
      subplot(121)
      hl(1:2,1) = plot(ssc*abs(uvz_d(mdn)), z(mdn), sn_dn_i(mdn), z(mdn)); grid; title(['downcast ' num2str(stns(no))]); hold on
      subplot(122)
      hl(3:4,1) = plot(ssc*abs(uvz_u(mup)), z(mup), sn_up_i(mup), z(mup)); grid; title(['upcast ' num2str(stns(no))]); hold on
      set(hl(1,1), 'color', cmap(1,:)); set(hl(2,1), 'color', (cmap(1,:)+.5)/1.5);
      set(hl(3,1), 'color', cmap(2,:)); set(hl(4,1), 'color', (cmap(2,:)+.5)/1.5);
      if ~isempty(upl)
         subplot(121)
         hl(1:2,2) = plot(ssc*abs(uuvz_d(umdn)), z(umdn), upl.sn_dn_i(umdn), z(umdn));
         subplot(122)
         hl(3:4,2) = plot(ssc*abs(uuvz_u(umup)), z(umup), upl.sn_up_i(umup), z(umup));
         set(hl(1,2), 'color', cmap(3,:)); set(hl(2,2), 'color', (cmap(3,:)+.5)/1.5);
         set(hl(3,2), 'color', cmap(4,:)); set(hl(4,2), 'color', (cmap(4,:)+.5)/1.5);
      end
      subplot(121); xlim([0 max(abs(uvz_d(mdn)))*ssc*1.1]); xlabel('shear (10^{-4} m/s), N')
      subplot(122); xlim([0 max(abs(uvz_u(mup)))*ssc*1.1]); xlabel('shear (10^{-4} m/s), N')
      set(hl([1 3],:), 'marker', '.', 'markersize', 16, 'linewidth', 1)
      set(hl([2 4],:), 'linestyle', '--')
%      subplot(121); legend([hl(1:2,1);hl(1:2,2)], 'downlook', 'N_{down}', 'uplook', 'N_{up}', 'location', 'southeast')
%      subplot(122); legend([hl(3:4,1);hl(3:4,2)], 'downlook', 'N_{down}', 'uplook', 'N_{up}', 'location', 'southeast')
      subplot(121); disp('select blue downlooker downcast points to mask out (enter to continue)'); y = []; [x,y] = ginput;
      if ~isempty(y)
         [d, ii] = min(abs(repmat(y',nz,1)-repmat(z,1,length(y))));
         plot(ssc*abs(uvz_d(ii)), z(ii), 'ok');
         cont = input('1 to mask out circles, 0 to cancel ');
         if cont; mdn(ii) = 0; end
      end
      if ~isempty(upl)
         subplot(121); disp('select red uplooker downcast points to mask out (enter to continue)'); y = []; [x,y] = ginput;
         if ~isempty(y)
	    [d, ii] = min(abs(repmat(y',nz,1)-repmat(z,1,length(y))));
            plot(ssc*abs(uuvz_d(ii)), z(ii), 'sk');
            cont = input('1 to mask out squares, 0 to cancel ');
            if cont; umdn(ii) = 0; end
	 end
      end
      subplot(122); disp('select teal downlooker upcast points to mask out (enter to continue)'); y = []; [x,y] = ginput;
      if ~isempty(y)
         [d, ii] = min(abs(repmat(y',nz,1)-repmat(z,1,length(y))));
         plot(ssc*abs(uvz_u(ii)), z(ii), 'ok');
         cont = input('1 to mask out circles, 0 to cancel ');
         if cont; mup(ii) = 0; end
      end
      if ~isempty(upl)
         subplot(122); disp('select orange uplooker upcast points to mask out (enter to continue)'); y = []; [x,y] = ginput;
         if ~isempty(y)
	    [d, ii] = min(abs(repmat(y',nz,1)-repmat(z,1,length(y))));
            plot(ssc*abs(uuvz_u(ii)), z(ii), 'sk');
            cont = input('1 to mask out squares, 0 to cancel ');
            if cont; umup(ii) = 0; end
	 end
      end
      nrep = nrep+1; if nrep==5; disp('stopping gui selection at 5 iterations'); end
      notdone = input('repeat gui selection (1) or finish (0)?');
   end
   
   %weighted average shear with the new masks
   nd = sn_dn_i.*double(mdn);
   nu = sn_up_i.*double(mup);
   if ~isempty(upl)
      und = upl.sn_dn_i.*double(umdn);
      unu = upl.sn_up_i.*double(umup);
   else
      und = zeros(nz, 1);
      unu = zeros(nz, 1);
   end
   uvz = (uvz_d.*nd + uvz_u.*nu + uuvz_d.*und + uuvz_u.*unu)./(nd + nu + und + unu);

   %n and mask for average
   n = nd + nu + und + unu;
   m = (mdn | mup);
   if ~isempty(upl)
      m = (m | umdn | umup);
   end
   
   %integrate to relative velocity with different filling methods
   iig = find(m); iib = setdiff([1:nz], iig);

   %no filling (except at the top--assume a slab mixed layer)
   uvz0 = uvz; uvz0(iib) = NaN+i*NaN; uvz0(1:iig(1)-1) = com0;
   uv_nofill(:,no) = cumsum(uvz0);

   %fill with zero shear (this might be similar to original as shear does seem to go to zero when n does)
   uvz0 = uvz; uvz0(iib) = 0; uvz0(iig(end)+1:end) = NaN+i*NaN;
   uv_0shrfill(:,no) = cumsum(uvz0);

   %fill with linearly-interpolated shear (but zero at the top)
   uvz0 = uvz; uvz0(iib) = interp1(iig, uvz0(iig), iib); uvz0(1:iig(1)-1) = com0;
   uv_linshrfill(iig(1):end,no) = cumsum(uvz0(iig(1):end));

   end
end

save /local/users/pstar/cruise/data/ladcp/vel_from_shr.mat uv*fill z stns

