function d = hdata_flagnan(d, varargin)
% function d = hdata_flagnan(d);
% function d = hdata_flagnan(d, 'parameter', value);
%
% 1) for each field/column of structure/table/dataset d, replace
%   -999s with NaNs (default) or use optional input nanval to replace
%   nanval(1) with nanval(2).  
% 2) for each flag field (*_flag), replace -999s or NaNs with 9
% 3) unless optional input addflags is set to 0, for each sample field,
%   that is fields not ending in _flag and not in the list {sampnum,
%   statnum, station, niskin, position, press, upress, depth, udepth, scan,
%   time, pumps} or in optional input vars_exclude (default {}), if there
%   is no corresponding flag field, create it with values of 2 or 9 for
%   non-NaN or NaN sample values, respectively. 
% 4) make sample and flag fields consistent with each other and with
%   niskin_flag (if this is a field in d), using nisk_badflags
%   (default: [3 4 9]) and sam_missflags (default: [9 1 5]), such that:
%     where niskin_flag is a member of nisk_badflags, sample values are
%       NaNed and flag values other than sam_missflags(1) are replaced by
%       sam_missflags(end);
%     where sample values are NaN but corresponding flags are not in
%       sam_missflags, flags are replaced by sam_missflags(end).
%   default values come from woce tables 4.8 and 4.9 and the assumption
%     that only not-sampled (9), not-analysed (1), and not-reported (5) are
%     NaNed, while questionable and bad values are still reported. If you
%     want to also NaN "bad" samples (flag 4), for instance, set 
%     sam_missflags = [9 1 4 5] 
% 5) depending on optional input keepemptyvars, either:
%    1: do nothing,
%    0 (default): remove flag fields that are all 9s, and their associated
%    sample fields, or
%    -1: remove flag fields that are all 9s and sample fields that are all
%      NaNs (whether or not they are linked; so for instance if you have
%      not-analysed data outstanding, the parameter column could be removed
%      and only the flag column kept)
% 6) depending on optional input keepemptyrows, either:
%    1 (default): do nothing,
%    0: remove, from every field, rows where none of the considered flag
%      fields have values other than sam_missflags(1)
%
%
% YLF 2021/05

%default: use woce flags
nisk_badflags = [3 4 9]; %for niskins: leaked, misfired, did not sample
sam_missflags = [9 1 5]; %for samples: did not sample, not yet analysed, not reported
%default: get rid of empty fields
keepemptyvars = 0;
%default: keep rows with no samples collected
keepemptyrows = 1;
%default: add flag fields where not present
addflags = 1;
%default: replace -999 with nan
nanval = [-999 NaN];

%optional inputs
for no = 1:2:length(varargin)
    eval([varargin{no} ' = varargin{no+1};'])
end
if ~ismember(keepemptyvars,[-1 0 1])
    keepemptyvars = 0;
end

skipvars = {'sampnum' 'statnum' 'station' 'niskin' 'position' 'press' 'upress' 'depth' 'udepth' 'scan' 'time' 'pumps'};
if istable(d)
    skipvars = [skipvars 'Properties' 'Row' 'Variables'];
end
if exist('vars_exclude','var')
    skipvars = [skipvars vars_exclude];
end

if length(sam_missflags)==1
    sam_missflags = [NaN sam_missflags];
end

%get separate lists of sample and flag variables
fnames = fieldnames(d);
fnames = setdiff(fnames, skipvars);
snames = {};
for no = 1:length(fnames)
    if ~endsWith(fnames{no},'flag')
        snames = [snames fnames{no}];
    end
end
fnames = setdiff(fnames, snames);

%replace -999s in flags
keepf = true(size(fnames));
for no = 1:length(fnames)
    if isnumeric(d.(fnames{no}))
        flag = d.(fnames{no});
        flag(flag==nanval(1)) = 9;
        d.(fnames{no}) = flag;
    else
        keepf(no) = 0;
    end
end
fnames = fnames(keepf);

%replace -999s in data and add flags if necessary
keeps = true(size(snames));
for no = 1:length(snames)
    if isnumeric(d.(snames{no}))
        sam = d.(snames{no});
        sam(sam==nanval(1)) = nanval(2);
        d.(snames{no}) = sam;
        fn = [snames{no} '_flag'];
        if ~ismember(fn,fnames)
            %some backwards compatibility
            ii = find(strcmp([snames{no} 'flag'],fnames));
            if ~isempty(ii)
                d.(fn) = d.(fnames{ii});
                fnames{ii} = fn;
            end
        end
        
        if ~ismember(fn,fnames)
            if addflags
                flag = 9+zeros(size(sam));
                flag(sam~=nanval(2)) = 2;
                d.(fn) = flag;
                fnames = [fnames; fn];
            end
        else
            flag = d.(fn);
            flag(sam==nanval(2) & ismember(flag,nanval)) = 9;
            d.(fn) = flag;
        end
    else
        keeps(no) = 0;
    end
end
snames = snames(keeps);

%also replace -999s in skipvars
skipvars = setdiff(skipvars,{'Properties' 'Row' 'Variables'});
for no = 1:length(skipvars)
    if isfield(d,skipvars{no})
        d.(skipvars{no})(d.(skipvars{no})==nanval(1)) = nanval(2);
    end
end

%apply niskin_flags to samples and their flags
if keepemptyrows==0
    anysam = false(size(d.sampnum));
end
if isfield(d, 'niskin_flag')
    niskbad = ismember(d.niskin_flag, nisk_badflags);
    fnames = setdiff(fnames, {'niskin_flag'});
    
    for no = 1:length(fnames)
        flag = d.(fnames{no});
        flag(niskbad & flag~=sam_missflags(1)) = sam_missflags(end);
        d.(fnames{no}) = flag;
        if keepemptyrows==0
            anysam = anysam | flag~=sam_missflags(1);
        end
    end
    
    for no = 1:length(snames)
        sam = d.(snames{no});
        sam(niskbad) = nanval(2);
        d.(snames{no}) = sam;
    end
    
end

for no = 1:length(snames)
    
    %match sample flags and data, where both exist
    if isfield(d, [snames{no} '_flag'])
        flag = d.([snames{no} '_flag']);
        sam = d.(snames{no});
        mf = ismember(flag,sam_missflags);
        flag(sam==nanval(2) & ~mf) = sam_missflags(end);
        sam(mf) = NaN;
        d.([snames{no} '_flag']) = flag;
        d.(snames{no}) = sam;
        
        if keepemptyvars==-1
            %if all missing, get rid of column
            if sum(~isnan(sam))==0
                d = rmfield(d, snames{no});
            end
        end
        
    end
    
end

if keepemptyvars<1
    %check flag fields for discard
    
    for no = 1:length(fnames)
        if sum(d.(fnames{no})~=9)==0
            d = rmfield(d, fnames{no});
            
            if keepemptyvars==0
                %didn't remove data column above, but flags are all 9 so
                %remove now
                d = rmfield(d, fnames{no}(1:end-5));
            end
            
        end
    end
    
end

if keepemptyrows==0 && sum(anysam)<length(anysam)
    %discard empty rows from every (numeric) field
    
    fn = fieldnames(d);
    for fno = 1:length(fn)
        if isnumeric(d.(fn{fno}))
            d.(fn{fno}) = d.(fn{fno})(anysam);
        end
    end
    
end
