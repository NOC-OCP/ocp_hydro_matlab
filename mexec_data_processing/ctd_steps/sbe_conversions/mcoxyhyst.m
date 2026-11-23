function [oxygen_out, Cvec, Dvec]=mcoxyhyst(oxygen_sbe,time,press,H1,H2,H3)
% [oxygen_out, Cvec, Dvec]=mcoxyhyst(oxygen_sbe,time,press,H1,H2,H3)
%
% gdm on di346
% function to apply an adjustment for hysteresis in the oxygen sensor to
% oxygen_sbe (umol/kg), following SBE AN64-3 rev.1/2024:
% D = 1 + H1*(exp(p(i)/H2)-1)
% C = exp(-(time(i)-time(i-1))/H3)
%
% to avoid all data after an edited/outlier point being contaminated (or
% nan), indices i are taken from the set of non-nan oxygen_sbe values (so 
% sometimes the time interval is > 1/24 s). this method introduces its own
% error, larger the larger the gaps are
%
% oxygen_sbe should not have been processed using the
% hysteresis correction before input here (or if it was, this should have
% been reversed using mcoxyhyst_reverse)
%
% the default values and suggested ranges of the constants are:
% H1     -0.033     [-0.02 to -0.05] amplitude of correction
% H2      5000                       curvature function constant
% H3      1450      [1200  to  2000] time constant (s)
%
% the code allows H1, H2, H3 to be vectors the same size as the other input
% variables

press(press<0) = 0; %***
iig = find(isfinite(press+oxygen_sbe)); iig = iig(:)';
if max(diff(iig))>24*10 %***what threshold
    warning('oxygen hysteresis correction being applied with gaps > 10 s in oxygen sbe!!!!')
    warning('!!!!!!!!')
elseif max(diff(iig))>24 %***what threshold?
    warning('oxygen hysteresis correction being applied with gaps > 1 s in oxygen_sbe')
end

%initialise
oxygen_out = nan(size(oxygen_sbe));
oxygen_out(iig(1)) = oxygen_sbe(iig(1));
iiout = iig(2:end); %this is where we will calculate adjusted values, using original values at these points ...
iiglastgood = iig(1:end-1); %... and both original and adjusted values at these points

%tile any scalar parameters
zz = zeros(size(oxygen_sbe));
if length(H1)<length(zz); H1 = H1 + zz; end
if length(H2)<length(zz); H2 = H2 + zz; end
if length(H3)<length(zz); H3 = H3 + zz; end
%D and C for each point in iiout
Dvec = 1 + H1(iiout).*(exp(press(iiout)./H2(iiout))-1);
Cvec = exp(-(time(iiout)-time(iiglastgood))./H3(iiout));

klastgood = iig(1); % keep track of most recent good cycle
for no = 1:length(iiout)
    %step through; each modification depends on (modified) previous oxygen
    %value 
    k = iiout(no);
    oxygen_out(k) = (oxygen_sbe(k) + oxygen_out(klastgood)*Cvec(no)*Dvec(no) - oxygen_sbe(klastgood)*Cvec(no))/Dvec(no);
    klastgood = k;
end
