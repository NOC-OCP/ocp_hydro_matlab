function data = hdata_flagnan(data, varargin);
% function data = hdata_flagnan(data);
% function data = hdata_flagnan(data, badflags);
% function data = hdata_flagnan(data, badflags, 'notwoce');
%
% for each field of data replace -999s with NaNs, 
% and make data fields and flag fields (*_flag), match
%
% assumes woce/exchange flag values unless optional input vector badflags
% is specified as well as input 'notwoce'; in this case, flags where data
% are -999 or NaN are set to min(badflags)
%
% data can be either a structure or a dataset
%
% YLF 2021/05

badflags = [4 9];
woceflags = 1;
if length(varargin)>0
    badflags = varargin{1};
    if length(varargin)>1 && strcmp(varargin{2}, 'notwoce')
        woceflags = 0;
    end
end
    
iie = [];
fnames = fieldnames(data);
vu = strcmp(fnames,'vars') | strcmp(fnames,'unts');
fnames(vu) = [];
for vno = 1:length(fnames)
    if ~contains(fnames{vno},'_flag') && isnumeric(data.(fnames{vno}))
        d = data.(fnames{vno});
        d(d<=-900) = NaN;
        iif = find(strcmp([fnames{vno} '_flag'], fnames));
        if sum(~isnan(d))==0 %no data; get rid of this field and its flag field (if any)
            if isstruct(data)
                data = rmfield(data, fnames{vno});
            else
                data.(fnames{vno}) = [];
            end
            iie = [iie vno];
            if ~isempty(iif)
                if isstruct(data)
                    data = rmfield(data, [fnames{vno} '_flag']);
                else
                    data.([fnames{vno} '_flag']) = [];
                end
                iie = [iie iif];
            end
        else %make data and flags match
            if ~isempty(iif)
                f = data.(fnames{iif});
                if woceflags
                    %assume flag and data both -999 (or NaN) means no sample
                    ii = find(isnan(d) & ~(f>0));
                    f(ii) = 9;
                    %assume data -999 (or NaN) and flag 2, 3, 5, 6 ought to be 4 (bad)
                    ii = find(isnan(d) & ismember(f, [2 3 5 6]));
                    f(ii) = 4;
                else
                    ii = find(isnan(d) & ~ismember(f,badflags));
                    f(ii) = min(badflags);
                end
                %now NaN everywhere that flag is bad (or missing)
                d(ismember(f, badflags)) = NaN;
                data.([fnames{vno} '_flag']) = f;
            end
            data.(fnames{vno}) = d;
        end
    end
end
if ~isempty(iie) && isfield(data, 'vars') && isfield(data, 'unts')
    data.vars(iie) = []; data.unts(iie) = [];
end

