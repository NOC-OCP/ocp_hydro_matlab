function [d, comment] = ctd_apply_autoedits(d, castopts)

comment = [];

%edit out scans when pumps are off, plus expected recovery times
if isfield(castopts,'pumpsNaN')
    iip = find(d.pumps<1);
    fn = fieldnames(castopts.pumpsNaN);
    for no = 1:length(fn)
        delay = castopts.pumpsNaN.(fn{no});
        if delay>0 && round(delay)==delay
            iib = repmat(iip(:),1,delay+1) + repmat(0:delay+1,length(iip),1);
            iib = unique(iib(:));
            iib = setdiff(iib,isnan(d.(fn{no})));
            if ~isempty(iib)
                d.(fn{no})(iib) = NaN;
                comment = [comment '\n edited out pumps off times plus ' num2str(delay) ' scans from ' fn{no}];
            end
        else
            warning(['skipping pumpsNaN for ' fn{no}]);
        end
    end
end

%scanedit (for additional bad scan ranges)
if isfield(castopts,'badscans')
    fn = fieldnames(castopts.badscans);
    for no = 1:length(fn)
        s = castopts.badscans.(fn{no});
        iis = find(d.scan>=s(1) & d.scan<=s(2));
        iis = setdiff(iis,isnan(d.(fn{no})));
        if ~isempty(iis)
            d.(fn{no})(iis) = NaN;
            comment = [comment '\n edited out scans from ' num2str(s(1)) ' to ' num2str(s(2)) ' from ' fn{no}];
        end
    end
end
    
%remove out of range values
if isfield(castopts,'rangelim')
    fn = fieldnames(castopts.rangelim);
    for no = 1:length(fn)
        if strncmp(fn{no},'temp')
            warning('editing temperature in mctd_02 is risky; are you sure spikes are not large enough to need to restart mctd_01 with redoctm?')
        end
        r = castopts.rangelim.(fn{no});
        iir = find(d.(fn{no})<r(1) | d.(fn{no})>r(2));
        if ~isempty(iir)
            d.(fn{no})(iir) = NaN;
            comment = [comment '\n edited ' fn{no} ' values outside range [' num2str(r(1)) ' ' num2str(r(2)) ']'];
        end
    end
end

%despike
if isfield(castopts,'despike')
    fn = fieldnames(castopts.despike);
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
