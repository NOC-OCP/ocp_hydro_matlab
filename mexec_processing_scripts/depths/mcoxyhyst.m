function [oxygen_out, Cvec, Dvec]=mcoxyhyst(oxygen_sbe,time,press,H1,H2,H3)
% [oxygen_out, Cvec, Dvec]=mcoxyhyst(oxygen_sbe,time,press,H1,H2,H3)
%
% gdm on di346
% function to apply an adjustment for hysteresis in the oxygen sensor
% the algorithm is the one used by SeaBird from April 2009 to correct for
% hysteresis. oxygen_sbe should not have been processed using the
% hysteresis correction before input here.
%
% the default values and ranges or the constants are:
% H1     -0.033     [-0.02 to -0.05]
% H2      5000
% H3      1450      [1200  to  2000]
%
% However H1, H2, H3 can be vectors the same size as the other input variables

%replicate any scalar parameters
zz = zeros(size(oxygen_sbe));
if length(H1)<length(zz); H1 = H1 + zz; end
if length(H2)<length(zz); H2 = H2 + zz; end
if length(H3)<length(zz); H3 = H3 + zz; end

press(press<0) = 0; %***
iig = find(isfinite(press+oxygen_sbe));
kfirst = min(iig);

%initialise
oxygen_out = NaN + zz; 
oxygen_out(kfirst) = oxygen_sbe(kfirst);
klastgood = kfirst; % keep track of most recent good cycle
Cvec = NaN + zz; Dvec = Cvec;

for k=iig(2):length(time) %***or only iig(2:end)?
    
    D = 1 + H1(k)*(exp(press(k)/H2(k))-1); Dvec(k) = D;
    C = exp(-(time(k)-time(klastgood))/H3(k)); Cvec(k) = C;
    
    oxygen_out(k) = (oxygen_sbe(k) + oxygen_out(klastgood)*C*D - oxygen_sbe(klastgood)*C)/D;
    klastgood = k;
    
end
return
