function [oxygen_out C D]=mcoxyhyst(oxygen_sbe,time,press,H1in,H2in,H3in,sensor)
% [oxygen_out]=mcoxyhyst(oxygen_sbe,time,press,H1,H2,H3)
% [oxygen_out]=mcoxyhyst(oxygen_sbe,time,press,H1,H2,H3,sensor)
% [oxygen_out C D]=mcoxyhyst(oxygen_sbe,time,press,H1,H2,H3)
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
% overhaul by bak on dy040, following GDM on dy039. Need to allow pars to
% vary with depth. GDM allowed choice of two. This script allows pars to be
% defined as arbitrary functions of depth.
% H1 H2 H3 are now arrays. Default is single, passed-in
% value, uniform with pressure. Option is now to vary with depth. Should be
% fully backwards compatible.
% input argument sensor may be used in opt_cruise called by get_cropt

m_common % on and after dy040, identify cruise from m_setup
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING; scriptname = mfilename;

oxygen_out=oxygen_sbe;

D = nan(size(oxygen_sbe));
C = D;

kfirst = min(find(isfinite(oxygen_sbe)));
klastgood = kfirst; % keep track of most recent good cycle

oxygen_out(1) = oxygen_sbe(1)/1;

%default for cruises before dy040, and when nothing fancy is required
zz = zeros(size(D));
H1 = H1in + zz;
H2 = H2in + zz;
H3 = H3in + zz;

% now do fancy things on cruises that need it
%i.e. depth-varying parameters
get_cropt

D(kfirst)=1+H1(kfirst)*(exp(press(kfirst)/H2(kfirst))-1);

for k=kfirst+1:length(time)
    % bak: 23 jan 2010 need to be able to step over nans
    %     oxygen_out(k)=((oxygen_sbe(k)+(oxygen_out(k-1)*C*D))-(oxygen_sbe(k-1)*C))/D;
    % bak: 29 feb 2012 there are some nans in press after cleaning up raw
    %     file on jc069_064. raw file has spikes due to noisy telemetry
    %     through slip rings
    %     therefore oxygen is nan if either oxygen_sbe or press is nan
    
    if ~isfinite(oxygen_sbe(k)+press(k))
        oxygen_out(k) = nan; %already the case because of initialisation of oxygen_out
    else
        if press(k) < 0; press(k) = 0; end
        D(k)=1+H1(k)*(exp(press(k)/H2(k))-1);
        C(k)=exp(-1*(time(k)-time(klastgood))/H3(k));

        oxygen_out(k)=(oxygen_sbe(k) + oxygen_out(klastgood)*C(k)*D(k) - oxygen_sbe(klastgood)*C(k))/D(k);
        klastgood = k;
        
    end
end
return
