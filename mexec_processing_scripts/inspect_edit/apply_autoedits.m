function [d, comment] = apply_autoedits(d, castopts)
% function [d, comment] = apply_autoedits(d, castopts)
% apply edits specified in castops structure to data in structure d
% 
% see setdef_cropt_cast mctd_02 case and setdef_cropt_uway
% mtsg_medav_clean_cal case for information on castopts 
% 

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

%formerly scanedit (for additional bad scan ranges)
%now could also/alternately be applied to times or any other variable
cfn = fieldnames(castopts);
iibp = find(strncmp('bad',cfn,3));
for bpno = 1:length(iibp)
    xvar = cfn{iibp(bpno)};
    if strcmp(xvar(end),'s') %it's badscans, badtimes, etc.
        bads = castopts.(xvar);
        x = d.(xvar(4:end-1))(:).'; %badscans --> scan, etc.
        vars = fieldnames(bads);
        for vno = 1:length(vars)
            badranges = bads.(vars{vno});
            mb = sum(x>=badranges(:,1) & x<=badranges(:,2),1)>0;
            %disp(vars{vno})
            nn = sum(isnan(d.(vars{vno})));
            d.(vars{vno})(mb) = NaN;
            if sum(isnan(d.(vars{vno})))>nn
                comment = [comment '\n edited out ranges of ' xvar 's from ' vars{vno}];
            end
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
