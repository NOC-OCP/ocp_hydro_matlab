function [oxygen_unhyst]=mcoxyhyst_reverse(oxygen_hyst,time,press,H1,H2,H3)
% function [oxygen_unhyst]=mcoxyhyst_reverse(oxygen_hyst,time,press,H1,H2,H3)
%
% gdm on di346
% function to reverse the adjustment for hysteresis in the oxygen sensor
% applied by SeaBird 
% 
% the default values and ranges or the constants are:
% H1     -0.033     [-0.02 to -0.05]
% H2      5000      
% H3      1450      [1200  to  2000]

% DAS changed to deal with absent data but note this could give slightly different results from original data as 
% the sbe software may deal with absent data differently
% YLF updated to eliminate redundant code
%

%replicate any scalar parameters
zz = zeros(size(oxygen_sbe));
if length(H1)<length(zz); H1 = H1 + zz; end
if length(H2)<length(zz); H2 = H2 + zz; end
if length(H3)<length(zz); H3 = H3 + zz; end

press(press<0) = 0; 
iig = find(isfinite(press+oxygen_hyst));
kfirst = min(iig);

%initialise
oxygen_unhyst = NaN + zz; 
oxygen_unhyst(kfirst) = oxygen_sbe(kfirst);
klastgood = kfirst; % keep track of most recent good cycle

for k = iig(2:end)
    
    D = 1 + H1(k)*(exp(press(k)/H2(k))-1);
    C = exp(-(time(k)-time(klastgood))/H3(k));
    
	oxygen_unhyst(k) = D*(oxygen_hyst(k) - C*oxygen_hyst(klastgood)) + C*oxygen_unhyst(klastgood);
    klastgood = k;
    
end
