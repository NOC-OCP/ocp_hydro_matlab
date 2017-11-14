function [oxygen_out]=mcoxyhyst_mod(oxygen_sbe,time,press,hyst_pars,hyst_pars_deep);
% [oxygen_out]=mcoxyhyst(oxygen_sbe,time,press,H1,H2,H3)
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
% generally these should be passed as hyst_pars
% much deep hysteresis remains at depth with these parameters so others
% work better. 
% on dy039 we used hyst_pars_deep = [-0.033 4200 5000]
% if you use these parameters on the whole water column, you throw out the
% shallower values so best to relax back to the default parameters. 
% I found 2000 dbar a good threshold.
% GDM, DY039

oxygen_out=oxygen_sbe;

kfirst = min(find(isfinite(oxygen_sbe)));
klastgood = kfirst; % keep track of most recent good cycle

for k=kfirst+1:length(time)
    % bak: 23 jan 2010 need to be able to step over nans
    %     oxygen_out(k)=((oxygen_sbe(k)+(oxygen_out(k-1)*C*D))-(oxygen_sbe(k-1)*C))/D;
    % bak: 29 feb 2012 there are some nans in press after cleaning up raw
    %     file on jc069_064. raw file has spikes due to noisy telemetry
    %     through slip rings
    %     therefore oxygen is nan if eitehr oxygen_sbe or press is nan
    if isnan(oxygen_sbe(k)+press(k))
        oxygen_out(k) = nan; %already the case because of initialisation of oxygen_out
    else
        if press(k) < 0;
            press(k) = 0;
        elseif press(k)>2000
            D=1+hyst_pars_deep(1)*(exp(press(k)/hyst_pars_deep(2))-1);
            C=exp(-1*(time(k)-time(klastgood))/hyst_pars_deep(3));
            oxygen_out(k)=((oxygen_sbe(k)+(oxygen_out(klastgood)*C*D))-(oxygen_sbe(klastgood)*C))/D;
            klastgood = k;
        else
            D=1+hyst_pars(1)*(exp(press(k)/hyst_pars(2))-1);
            C=exp(-1*(time(k)-time(klastgood))/hyst_pars(3));
            oxygen_out(k)=((oxygen_sbe(k)+(oxygen_out(klastgood)*C*D))-(oxygen_sbe(klastgood)*C))/D;
            klastgood = k;
        end
    end
end;
