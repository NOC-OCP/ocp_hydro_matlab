function d = hdata_flagnan(d, varargin)
% function d = hdata_flagnan(d);
% function d = hdata_flagnan(d, 'parameter', value);
%
% 1) for each sample field/column of structure/table/dataset d, replace
%   -999s with NaNs. some fields are skipped: by default, if addflags (see
%   below) is set to 1 (default), the skipped fields are sampnum, statnum,
%   station, niskin, position, press, upress, depth and udepth; all other
%   fields not ending in _flag are treated as sample fields, and optional
%   input argument vars_exclude is a cell array list of additional fields
%   to ignore (e.g. {'sbe35temp'}). if addflags is set to 0, every field
%   (and only those fields) with a corresponding _flag field, except
%   niskin, is treated as a sample field 
% 2) for each corresponding flag field (*_flag), replace -999s or NaNs with
%   9, or if there is no flag field create it with values of 2 or 9 for
%   non-NaN or NaN sample values, respectively (unless optional input 
%   addflags is set to 0).  
% 3) make sample and flag fields consistent with each other and with
%   niskin_flag (if this is a field in d), using nisk_badflags 
%   (default: [3 4 9]) and sam_missflags (default: [9 1 5]), such that:  
%     where niskin_flag is a member of nisk_badflags, sample values are
%       NaNed and flag values other than sam_missflags(1) are replaced by
%       sam_missflags(end); 
%     where sample values are NaN but corresponding flags are not in
%       sam_missflags, flags are replaced by sam_missflags(end).
%   default values come from woce tables 4.8 and 4.9 and the assumption
%     that only not-sampled, not-analysed, and not-reported values are NaN,
%     while questionable and bad values are still reported. If you want to
%     also NaN "bad" samples, for instance, set sam_missflags = [9 1 4 5]
% 4) depending on optional input keepemptyvars, either: 
%    1: do nothing,
%    0 (default): remove flag fields that are all 9s, and their associated
%    sample fields, or 
%    -1: remove flag fields that are all 9s and sample fields that are all
%      NaNs (whether or not they are linked; so for instance if you have
%      not-analysed data outstanding, the parameter column could be removed
%      and only the flag column kept)
% 5) depending on optional input keepemptysamps, either: 
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

%optional inputs
for no = 1:2:length(varargin)
    eval([varargin{no} ' = varargin{no+1};'])
end
if ~ismember(keepemptyvars,[-1 0 1])
    keepemptyvars = 0;
end

if addflags
    skipvars = {'sampnum' 'statnum' 'station' 'niskin' 'position' 'press' 'upress' 'depth' 'udepth'};
else
    skipvars = {'niskin'};
end
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
    if ~endsWith(fnames{no},'_flag')
        snames = [snames fnames{no}];
    end
end
fnames = setdiff(fnames, snames);

%replace -999s in flags
for no = 1:length(fnames)
    flag = d.(fnames{no});
    flag(flag<-900) = 9;
    d.(fnames{no}) = flag;
end

%replace -999s in data and add flags if necessary
for no = 1:length(snames)
    sam = d.(snames{no});
    sam(sam<-900) = NaN;
    d.(snames{no}) = sam;
    fn = [snames{no} '_flag'];
    
    if ~ismember(fn,fnames)
        if addflags
            flag = 9+zeros(size(sam));
            flag(~isnan(sam)) = 2;
            d.(fn) = flag;
            fnames = [fnames; fn];
        end
    else
        flag = d.(fn);
        flag(isnan(sam) & isnan(flag)) = 9;
        d.(fn) = flag;
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
            anysam = anysam | flag<sam_missflags(1);
        end
    end
    
    for no = 1:length(snames)
        sam = d.(snames{no});
        sam(niskbad) = NaN;
        d.(snames{no}) = sam;
    end
    
end

for no = 1:length(snames)
    
    %match sample flags and data, where both exist
    if isfield(d, [snames{no} '_flag'])
        flag = d.([snames{no} '_flag']);
        sam = d.(snames{no});
        mf = ismember(flag,sam_missflags);
        flag(isnan(sam) & ~mf) = sam_missflags(end);
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
    %discard empty rows

    fn = fieldnames(d);
    for fno = 1:length(fn)
        d.(fn{fno}) = d.(fn{fno})(anysam);
    end
    
end
