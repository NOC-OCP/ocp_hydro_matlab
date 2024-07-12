function [d, comment] = apply_autoedits(d, castopts)
% function [d, comment] = apply_autoedits(d, castopts)
% apply edits specified in castops structure to data in structure d
% 
% see mctd_02 and mday_01_clean_av cases for information on castopts
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
        if strncmp(fn{no},'temp',4)
            warning('editing temperature in mctd_02 is risky; are you sure spikes are not large enough to need to restart mctd_01 with redoctm?')
        end
        t = castopts.despike.(fn{no});
        comment = [comment '\n despiked ' fn{no} ' using median_despike with successive thresholds '];
        for dno = 1:length(t)
            d.(fn{no}) = median_despike(d.(fn{no}), t(dno));
            comment = [comment num2str(t(dno)) ' '];
        end
    end
end

