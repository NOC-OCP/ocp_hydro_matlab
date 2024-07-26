function [d, comment] = apply_autoedits(d, castopts)
% function [d, comment] = apply_autoedits(d, castopts)
%
% apply edits specified in castops structure to data in structure d
% 
%
%   pumpsNaN -- for each parameter which is a field of castopts.pumpsNaN,
%     data are masked up to castopts.pumpsNaN.(parameter) time points after
%     pumps come (back) on -- this is mostly specific to the CTD, though
%     could be used for another series if a variable pumps were present
%     e.g. for 24 Hz CTD data,
%       castopts.pumpsNaN.temp1 = 12; % 0.5 s
%       castopts.pumpsNaN.oxygen_sbe1 = 8*24; % 8 s
%       etc.
%   
%   rangelim -- for each parameter which is a field of castopts.rangelim,
%     data are masked outside of the range given by
%     castopts.rangelim.(parameter)
%     e.g. 
%     castopts.rangelim.temp1 = [-2 40];
%
%   bad(var) -- for each parameter which is a field of castopts.bad(var),
%     data are masked where (var) is within the range(s) given by the rows
%     of castopts.bad(var).(parameter); in addition, if one of the rows is
%     [NaN NaN], parameter data are masked where (var) is NaN
%     e.g. to mask selected ranges of scans where CTD1 was blocked, and to
%     also mask C and O wherever else T has been edited out (e.g. by hand,
%     or by rangelim) for either CTD: 
%     castopts.badscan.temp1 = [7380 7890; 11500 13020];
%     castopts.badscan.cond1 = castopts.badscan.temp1;
%     castopts.badscan.oxygen_sbe1 = castopts.badscan.temp1; 
%     castopts.badtemp1.cond1 = [NaN NaN];
%     castopts.badtemp1.oxygen_sbe1 = [NaN NaN];
%     castopts.badtemp2.cond2 = [NaN NaN];
%     castopts.badtemp2.oxygen_sbe2 = [NaN NaN];
%    
%   despike -- for each parameter which is a field of castopts.despike,
%     data are masked using a 5-point median despiker with the threshold
%     (or succession of thresholds) given by castopts.despike.(parameter);
%     if length(castopts.despike.(parameter))>1 the thresholds are applied
%     iteratively; note thresholds are absolute, not relative
%     e.g.
%     castopts.despike.cond1 = [0.01 0.01];
%     to iterate twice with the same threshold of 0.01 mS/cm deviation from
%     the 5-point median
%
% also see ctd_proc, rawedit_auto and uway_proc, mday_01_clean_av cases for
%   information on castopts 
% 

comment = [];
fnd = fieldnames(d);

%edit out scans when pumps are off, plus expected recovery times
if isfield(castopts,'pumpsNaN') && isfield(d,'pumps')
    iip = find(d.pumps<1); n = length(d.pumps);
    fn = intersect(fieldnames(castopts.pumpsNaN),fnd);
    for no = 1:length(fn)
        delay = castopts.pumpsNaN.(fn{no});
        if delay>0 && round(delay)==delay
            iib = repmat(iip(:),1,delay+1) + repmat(0:delay,length(iip),1);
            iib = unique(iib(:));
            iib = setdiff(iib,isnan(d.(fn{no})));
            iib = iib(iib<=n);
            if ~isempty(iib)
                d.(fn{no})(iib) = NaN;
                comment = [comment '\n edited out pumps off times plus ' num2str(delay) ' scans from ' fn{no}];
            end
        else
            warning(['skipping pumpsNaN for ' fn{no}]);
        end
    end
end

%remove out of range values
if isfield(castopts,'rangelim')
    fn = intersect(fieldnames(castopts.rangelim),fnd);
    for no = 1:length(fn)
        r = castopts.rangelim.(fn{no});
        iir = find(d.(fn{no})<r(1) | d.(fn{no})>r(2));
        if ~isempty(iir)
            d.(fn{no})(iir) = NaN;
            comment = [comment '\n edited ' fn{no} ' values outside range [' num2str(r(1)) ' ' num2str(r(2)) ']'];
        end
    end
end

% formerly scanedit (for additional bad scan ranges)
% now can also/alternately be applied using time or any other variable
% (e.g. press) as the indicative variable
%   example (to edit two time ranges out of three tsg variables, where tsg
%   time is in datenum form):                 
%   badtimes = [datenum(2022,7,1) datenum(2022,7,12,14,6,0); ...
%               datenum(2022,7,28,12,28,0) datenum(2022,7,28,17,20,0)];
%   castopts.badtime.conductivity_raw = badtimes;
%   castopts.badtime.salinity_raw = badtimes;
%   castopts.badtime.temph_raw = badtimes;
% can also be used to NaN one variable where another is NaN, e.g. to apply
% any edits (automatic or manual) already made to temp1 to the other CTD1
% variables:  
%    castopts.badtemp1.cond1 = [NaN NaN];
%    castopts.badtemp1.oxygen_sbe1 = [NaN NaN];
cfn = fieldnames(castopts);
iibp = find(strncmp('bad',cfn,3));
for bpno = 1:length(iibp)
    xvar = cfn{iibp(bpno)};
    if isfield(d,xvar(4:end))
        x = d.(xvar(4:end))(:).'; %badscan --> scan, etc.
        vars = intersect(fieldnames(castopts.(xvar)),fnd); %e.g. temp1, temp2,
        for vno = 1:length(vars)
            badranges = castopts.(xvar).(vars{vno});
            mn = isnan(badranges(:,1)); %handle NaNs separately
            badranges(mn,:) = [];
            mb = sum(x>=badranges(:,1) & x<=badranges(:,2), 1)>0;
            if sum(mn)
                mb = mb | isnan(x);
            end
            nn = sum(isnan(d.(vars{vno})));
            d.(vars{vno})(mb) = NaN;
            if sum(isnan(d.(vars{vno})))>nn
                comment = [comment '\n edited out ranges of ' xvar ' from ' vars{vno}];
            end
        end
    end
end
    
%despike
if isfield(castopts,'despike')
    fn = intersect(fieldnames(castopts.despike),fnd);
    for no = 1:length(fn)
        if strncmp(fn{no},'temp',4) && isfield(castopts,'redoctm') && ~castopts.redoctm
            warning('editing temperature in mctd_02 is risky; are you sure spikes are not large enough to need to redo CTM?')
        end
        t = castopts.despike.(fn{no});
        comment = [comment '\n despiked ' fn{no} ' using median_despike with successive thresholds '];
        for dno = 1:length(t)
            d.(fn{no}) = median_despike(d.(fn{no}), t(dno));
            comment = [comment num2str(t(dno)) ' '];
        end
    end
end

