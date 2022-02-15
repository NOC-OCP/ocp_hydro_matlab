function [dz] = heaveND(dn_psal,dn_temp,up_psal,up_temp,pdn);
% Calculate amount of heave (dz) as the change in pressure of neutral density levels between up and down casts
% Note dp is up pressure minus down pressure
% Note that function gamma_n is eos80_legacy_gamma_n
% Inputs are:
%  - dn_psal,dn_temp,  practical salinity and in-situ temperature of downcast
%  - up_psal,up_temp,  practical salinity and in-situ temperature of upcast
%  - both up and down profiles are given at pressures pdn
% Should also input lat and lon but for the moment only using for RAPID so have these fixed parameters
%
% DAS 2021

% Note impose dz = 0 at top and bottom

% Possibly arbitrary choice of filters
% Output is a wieighted sum of the two filtered values
% Weights change linearly 0 to 1 between pressures 0 and ptrans
dpf1    =  25;
dpf2    = 100;
ptrans = 3000;
dmix =  0.005;  % Change of density in upper mixed layer
idebug = 0;     % Chnage to 1 when testing

% Actual lat and lon not important as we are not comparing neutral density from different 
% locations but should change this if use elsewhere
lon0 = -50; lat0 = 26; 

% Calculate neutral density
dn_nd = gamma_n(dn_psal',dn_temp',pdn',lon0,lat0);
up_nd = gamma_n(up_psal',up_temp',pdn',lon0,lat0);
dn_nd = dn_nd';up_nd = up_nd';
	
% Avoid extrapolation or NaNs 
ilo = up_nd < min(dn_nd);  up_nd(ilo) = min(dn_nd);
ihi = up_nd > max(dn_nd);  up_nd(ihi) = max(dn_nd);
[dn_sort,isort] = sort(dn_nd);
pup = interp1(dn_nd(isort),pdn(isort),up_nd);
dz0 = pup-pdn(isort); 

% If there is an upper mixed layer
imix_dn = find(dn_nd < min(dn_nd) + dmix);
imix_up = find(up_nd < min(up_nd) + dmix);
imixS = 1:max([imix_dn imix_up]);
dz0(imixS) = 0;
fprintf(1,'(heaveND) Depth upper mixed layer: %5.0f db \n',pdn(imixS(end)))

% If there is an bottom mixed layer
imix_dn = find(dn_nd > max(dn_nd) - dmix/3);
imix_up = find(up_nd > max(up_nd) - dmix/3);
imixB = min([imix_dn imix_up]):length(pdn);
dz0(imixB) = 0;
fprintf(1,'(heaveND) Depth bottom mixed layer: %5.0f db \n',max(pdn)-pdn(imixB(1)))

% Now filter 
[pf1,df1] = das_filt(pdn,dz0,dpf1);
[pf2,df2] = das_filt(pdn,dz0,dpf2);

% Enforce 0 at top and the bottom
pf10 = [0 pf1 max(pdn)];
df10 = [0 df1 0];
pf20 = [0 pf2 max(pdn)];
df20 = [0 df2 0];
dz1  = interp1(pf10,df10,pdn);
dz2  = interp1(pf20,df20,pdn);

% Now blend the two filtered series
w1 = max(0,(ptrans-pdn)/ptrans);
w2 = 1-w1;
dz = w1.*dz1 + w2.*dz2;

% Hope it is all ok ! but let's check there is no absent data
icheck = sum(isnan(dz));
if icheck > 0
	fprintf(1,'Somethings wrong in heaveND %d NaNs \n',icheck)
end

if idebug == 1
	figure
	plot(pdn,dz1,'b')
	hold on;grid on
	plot(pdn,dz2,'r')
	plot(pdn,dz,'k','LineWidth',2)
end
	