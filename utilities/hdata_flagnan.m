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
%   non-NaN or NaN sample values, respectively. If d is a table,
%   Properties.VariableUnits for the new flag field is set to optional
%   input flagu (default 'woce_4.9')
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
flagu = 'woce_4.9'; %***same for ctd?
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

skipvars = {'sampnum' 'statnum' 'station' 'niskin' 'position' 'press' 'upress' 'depth' 'udepth' 'scan' 'time' 'utime' 'pumps'};
if istable(d)
    typ = 1;
    skipvars = [skipvars 'Properties' 'Row' 'Variables'];
elseif isstruct(d)
    typ = 2;
    d = struct2table(d);
else
    typ = 3;
    d = dataset2table(d);
end
if exist('vars_exclude','var')
    skipvars = [skipvars vars_exclude];
end

if isscalar(sam_missflags)
    sam_missflags = [NaN sam_missflags];
end

%get separate lists of sample and flag variables
snames = d.Properties.VariableNames;
snames = setdiff(snames, skipvars);
fnames = snames(cellfun(@(x) endsWith(x,'flag'),snames));
snames = setdiff(snames, fnames);

%replace -999s in flags
keepf = true(size(fnames));
for no = 1:length(fnames)
    if isnumeric(d.(fnames{no}))
        flag = d.(fnames{no});
        if isnan(nanval(1))
            m = isnan(flag);
        else
            m = flag==nanval(1);
        end
        flag(m) = 9;
        d.(fnames{no}) = flag;
    else
        keepf(no) = 0;
    end
end
fnames = fnames(keepf);

%replace -999s in data and add flags if necessary (also add their names to
%fnames)
keeps = true(size(snames));
for no = 1:length(snames)
    if isnumeric(d.(snames{no}))
        sam = d.(snames{no});
        if isnan(nanval(1))
            m = isnan(sam);
        else
            m = sam==nanval(1);
        end
        sam(m) = nanval(2);
        d.(snames{no}) = sam;
        fn = [snames{no} '_flag'];
        if ~ismember(fn,fnames)
            %some backwards compatibility
            ii = find(strcmp([snames{no} 'flag'],fnames));
            if ~isempty(ii)
                d.(fn) = d.(fnames{ii});
                if typ==1; d.Properties.VariableUnits{end} = flagu; end
                fnames{ii} = fn;
            end
        end
        
        if ~ismember(fn,fnames)
            if addflags
                flag = 9+zeros(size(sam));
                if isnan(nanval(2))
                    m = ~isnan(sam);
                else
                    m = sam~=nanval(2);
                end
                flag(m) = 2;
                d.(fn) = flag;
                if typ==1; d.Properties.VariableUnits{end} = flagu; end
                fnames = [fnames fn];
            end
        else
            flag = d.(fn);
            if isnan(nanval(2))
                m1 = isnan(sam);
            else
                m1 = sam==nanval(2);
            end
            if sum(isnan(nanval))
                m2 = ismember(flag,nanval) | isnan(flag);
            else
                m2 = ismember(flag,nanval);
            end
            flag(m1 & m2) = 9;
            d.(fn) = flag;
            if typ==1; d.Properties.VariableUnits{end} = flagu; end
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
        if isnan(nanval(1))
            m = isnan(d.(skipvars{no}));
        else
            m = d.(skipvars{no})==nanval(1);
        end
        d.(skipvars{no})(m) = nanval(2);
    end
end

%apply niskin_flags to samples and their flags
if isfield(d, 'niskin_flag')
    niskbad = ismember(d.niskin_flag, nisk_badflags);
    fnames = setdiff(fnames, {'niskin_flag'});
    
    for no = 1:length(fnames)
        if ~strcmp(fnames{no}(1),'u') && ~strcmp(fnames{no},'sbe35temp_flag')
            flag = d.(fnames{no});
            flag(niskbad & flag~=sam_missflags(1)) = sam_missflags(end);
            d.(fnames{no}) = flag;
        end
    end
    
    for no = 1:length(snames)
        if ~strcmp(snames{no}(1),'u') && ~strcmp(snames{no},'sbe35temp')
            sam = d.(snames{no});
            sam(niskbad) = nanval(2);
            d.(snames{no}) = sam;
        end
    end

end

varn = d.Properties.VariableNames;
for no = 1:length(snames)
    
    %match sample flags and data, where both exist
    sfname = [snames{no} '_flag'];
    if sum(strcmp(sfname,varn))
        flag = d.(sfname);
        sam = d.(snames{no});
        mf = ismember(flag,sam_missflags);
        if isnan(nanval(2))
            m = isnan(sam);
        else
            m = sam==nanval(2);
        end
        flag(m & ~mf) = sam_missflags(end);
        sam(mf) = nanval(2);
        d.(sfname) = flag;
        d.(snames{no}) = sam;
        
        if keepemptyvars==-1
            %if all missing, get rid of column
            if sum(~isnan(sam))==0
                d.(snames{no}) = [];
            end
        end
        
    end
    
end

if keepemptyvars<1
    for no = 1:length(fnames)
        if sum(d.(fnames{no})~=9)==0
            d(:,fnames{no}) = [];
            if keepemptyvars==0
                %didn't remove data column above, but flags are all 9 so
                %remove now
                d(:,fnames{no}(1:end-5)) = [];
            end
        end
    end
end

if keepemptyrows==0 && ~isempty(fnames)     
    %check for rows with no good data
    m = ismember(d.Properties.VariableNames,fnames);
    a = sum(d(:,m)~=sam_missflags(1),2); a = a.sum>0;
    d = d(a,:);
end

if typ==2
    d = table2struct(d,'ToScalar',true);
elseif typ==3
    d = table2dataset(d);
end

