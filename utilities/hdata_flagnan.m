function data = hdata_flagnan(data, varargin)
% function data = hdata_flagnan(data);
% function data = hdata_flagnan(data, badflags);
% function data = hdata_flagnan(data, badflags, 'notwoce');
% function data = hdata_flagnan(data, vars_exclude);
% function data = hdata_flagnan(data, vars_exclude, 'keepempty');
%
% for each data field of structure data (except those in vars_exclude, if
% specified) replace -999s with NaNs, and make data fields and flag fields
% (*_flag), match 
% 
% optional input vector badflags (default [3 4 9]) sets which flag values
% should be accompanied by NaNs
%
% assumes woce flag values (table 4.9) unless both badflags and 'notwoce'
% are in inputs; in this case, flags where data are -999 or NaN are set to
% min(badflags)
%
% by default, variables with no non-NaN data, and their corresponding
% flags, will be removed; to suppress this include 'keepempty' in inputs
%
% by default, sampnum, statnum, niskin, and position are excluded from this
% checking; specify additional variables to exclude in input vars_exclude
%
% optional input arguments can be in any order
%
% data can be a structure, a dataset, or a table
%
% YLF 2021/05

badflags = [3 4 9]; %for niskins: leaked, misfired, did not sample
woceflags = 1;
keepempty = 0;
vars_exclude = {'sampnum' 'statnum' 'niskin' 'position'};
for no = 1:length(varargin)
    if ischar(varargin{no})
        if strcmp(varargin{no}, 'notwoce')
            woceflags = 0;
        elseif strcmp(varargin{no}, 'keepempty')
            keepempty = 1;
        end
    elseif iscell(varargin{no})
        vars_exclude = [vars_exclude varargin{no}];
    else
        badflags = varargin{no};
    end
end

%data variables to consider    
fnames = fieldnames(data);
fnames = setdiff(fnames, vars_exclude); 

%niskin flags are applied not to niskins but to other fields
if isfield(data, 'niskin_flag') && woceflags
    %NaN all samples from leaking (3), badly-closed (4) or unused (9) Niskins
    iinf = ismember(data.niskin_flag,[3 4 9]); 
else
    iinf = [];
end

%loop through data fields
for vno = 1:length(fnames)
    if ~contains(fnames{vno},'_flag') && isnumeric(data.(fnames{vno})) %data field

        d = data.(fnames{vno});
        d(d<=-900) = NaN;
        iif = find(strcmp([fnames{vno} '_flag'], fnames)); %flag field

        if ~keepempty && ~sum(~isnan(d)) 
            %no data; get rid of this field and its flag field
            if isstruct(data)
                data = rmfield(data, fnames{vno});
                if ~isempty(iif)
                    data = rmfield(data, [fnames{vno} '_flag']);
                end
            else
                data.(fnames{vno}) = [];
                if ~isempty(iif)
                    data.([fnames{vno} '_flag']) = [];
                end
            end
            continue %to next variable
        end

        if isempty(iif)
            %add flag field
            data.([fnames{vno} '_flag']) = NaN+data.(fnames{vno});
            fnames{length(fnames)+1} = [fnames{vno} '_flag']; 
            iif = length(fnames); %***does this work on tables?
        end

        %modify flags to match data
        f = data.(fnames{iif});
        if woceflags
            %sample flags of 2 (good), 3 (questionable), 6 (mean of
            %replicates) ought to have non-nan data; if not, assume flag
            %should be 4 (bad)
            f(isnan(d) & ismember(f, [2 3 6])) = 4;
            %if data is nan and flag is nan (or -999), assume that means 9
            %(no sample) [though it could also mean 5 (not reported)]
            f(isnan(d) & ~(f>0)) = 9;
            %if data is non-nan and flag is nan (or -999), assume good
            f(~isnan(d) & ~(f>0)) = 2;
        else
            f(isnan(d) & ~ismember(f,badflags)) = min(badflags);
        end

        %now NaN everywhere that flag is bad
        d(ismember(f, badflags)) = NaN;
        %and where niskin is flagged
        if ~isempty(iinf) && sum(iinf)
            d(iinf) = NaN;
            f(iinf & f<9) = 4;
        end
        
        data.(fnames{vno}) = d;
        data.([fnames{vno} '_flag']) = f;

    end
end

