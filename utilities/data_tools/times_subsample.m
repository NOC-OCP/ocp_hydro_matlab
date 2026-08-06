function dd = times_subsample(dd, tvar, stepfreq_force, tstep_resol);
% subsample and/or round to tstep_resol based on variable tvar in table dd
% used for downsampling e.g. gyro or anemometer data to e.g. 1 Hz
% rounding is useful for merging different streams that come in with
% slightly different timestamps, where the desired precision is given by
% tstep_resol

stepfreq = 1; 
if ~isempty(stepfreq_force)
    %what is the current normal sampling frequency
    dt = diff(dd.(tvar)); dt = dt(dt>0); 
    dt = mode(dt);
    stepfreq = max(round(1/dt),1); 
end
if ~isempty(tstep_resol)
    dd.(tvar) = round(dd.(tvar)/tstep_resol)*tstep_resol;
end
if stepfreq>1
    iits = 1:stepfreq:length(dd.(tvar));
    [~,iit] = unique(dd.(tvar)(iits),'stable');
    iit = iits(iit);
else
    [~,iit] = unique(dd.(tvar),'stable');
end
iit = iit(~isnan(dd.(tvar)(iit)));
dd = dd(iit,:);
