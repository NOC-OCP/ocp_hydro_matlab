function [d, comment] = apply_autoedits(d, edopts)
% function [d, comment] = apply_autoedits(d, edopts)
%
% apply edits specified in edopts structure to data in structure d
% 
%
%   pumpsNaN -- for each parameter which is a field of edopts.pumpsNaN,
%     data are NaNed up to edopts.pumpsNaN.(parameter) time points after
%     pumps come (back) on -- this is mostly specific to the CTD, though
%     could be used for another series if a variable pumps were present
%     e.g. for 24 Hz CTD data,
%       edopts.pumpsNaN.temp1 = 12; % 0.5 s
%       edopts.pumpsNaN.oxy_sbe1 = 8*24; % 8 s
%       etc.
%   
%   rangelim -- for each parameter which is a field of edopts.rangelim,
%     data are NaNed outside of the range given by
%     edopts.rangelim.(parameter)
%     e.g. 
%     edopts.rangelim.temp1 = [-2 40];
%
%   despike -- for each parameter which is a field of edopts.despike,
%     each row in edopts.despike.{parameter}, [TH LEN],
%     successively applies median_despike to remove points that deviate by
%     more than TH from the median over LEN neighbouring non-NaN points
%     note this is not a standard deviation filter, instead TH is absolute,
%     e.g. 
%     edopts.despike.temp1 = [0.01 5; 0.01 5];
%       to edit temp1 by iterating twice with the same threshold of 0.01
%       degrees C deviation from the 5-point median
%
%   bad(var) -- for each parameter which is a field of edopts.bad(var),
%     data are masked where (var) is within the range(s) given by the rows
%     of edopts.bad(var).(parameter); in addition, if one of the rows is
%     [NaN NaN], parameter data are masked where (var) is NaN
%     in this example, CTD1 was blocked from scan 7380 to 7890 and 11500 to
%     13020, and in addition any time a T was marked as bad (by hand, or by
%     rangelim or despike above) the corresponding C and O should be NaNed 
%     too: 
%     also mask C and O wherever else T has been edited out (this could be 
%     by hand, or by rangelim above) for either CTD:  
%     edopts.badscan.temp1 = [7380 7890; 11500 13020];
%     edopts.badscan.cond1 = edopts.badscan.temp1;
%     edopts.badscan.oxy_sbe1 = edopts.badscan.temp1; 
%     edopts.badtemp1.cond1 = [NaN NaN];
%     edopts.badtemp1.oxy_sbe1 = [NaN NaN];
%     edopts.badtemp2.cond2 = [NaN NaN];
%     edopts.badtemp2.oxy_sbe2 = [NaN NaN];
%    
% also see ctd_proc, rawedit_auto and uway_proc, mday_01_clean_av cases for
%   information on edopts 
% 

comment = [];
fnd = fieldnames(d);

%edit out scans when pumps are off, plus expected recovery times
if isfield(edopts,'pumpsNaN') && isfield(d,'pumps')
    iip = find(d.pumps<1); n = length(d.pumps);
    fn = intersect(fieldnames(edopts.pumpsNaN),fnd);
    for no = 1:length(fn)
        delay = edopts.pumpsNaN.(fn{no});
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
if isfield(edopts,'rangelim')
    fn = intersect(fieldnames(edopts.rangelim),fnd);
    for no = 1:length(fn)
        r = edopts.rangelim.(fn{no});
        iir = find(d.(fn{no})<r(1) | d.(fn{no})>r(2));
        if ~isempty(iir)
            d.(fn{no})(iir) = NaN;
            % if ~isfield(d,[fn{no} '_flag'])
            %     d.([fn{no} '_flag']) = nan(size(d.(fn{no})));
            % end
            % d.([fn{no} '_flag'])(iir) = 7;
            comment = [comment '\n edited ' fn{no} ' values outside range [' num2str(r(1)) ' ' num2str(r(2)) ']'];
        end
    end
end


%despike
if isfield(edopts,'despike')
    fn = intersect(fieldnames(edopts.despike),fnd);
    for no = 1:length(fn)
        if strncmp(fn{no},'temp',4) && isfield(edopts,'redoctm') && ~edopts.redoctm
            warning('editing temperature in mctd_02 is risky; are you sure spikes are not large enough to need to redo CTM?')
        end
        t = edopts.despike.(fn{no});
        comment = [comment '\n despiked ' fn{no} ' using median_despike with successive thresholds '];
        for dno = 1:size(t,1)
            d0 = d.(fn{no});
            d.(fn{no}) = median_despike(d.(fn{no}), t(dno,2), t(dno,1), []);
            comment = [comment num2str(t(dno)) ' '];
            % d.([fn{no} '_flag'])(isnan(d.(fn{no})) & ~isnan(d0)) = 7;             
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
%   edopts.badtime.conductivity_raw = badtimes;
%   edopts.badtime.salinity_raw = badtimes;
%   edopts.badtime.temph_raw = badtimes;
% can also be used to NaN one variable where another is NaN, e.g. to apply
% any edits (automatic or manual) already made to temp1 to the other CTD1
% variables:  
%    edopts.badtemp1.cond1 = [NaN NaN];
%    edopts.badtemp1.oxy_sbe1 = [NaN NaN];
cfn = fieldnames(edopts);
iibp = find(strncmp('bad',cfn,3));
for bpno = 1:length(iibp)
    xvar = cfn{iibp(bpno)};
    if isfield(d,xvar(4:end))
        x = d.(xvar(4:end))(:).'; %badscan --> scan, etc.
        vars = intersect(fieldnames(edopts.(xvar)),fnd); %e.g. temp1, temp2,
        for vno = 1:length(vars)
            badranges = edopts.(xvar).(vars{vno});
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
    