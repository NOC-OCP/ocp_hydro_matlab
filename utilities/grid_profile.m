function dg = grid_profile(d, gridvar, gridvec, method, varargin)
% dg = grid_profile(d, gridvar, gridvec, method, varargin);
% dg = grid_profile(d, gridvar, gridvec, 'medbin');
% dg = grid_profile(d, gridvar, gridvec, 'medint', 'int', [below above]);
% dg = grid_profile(d, gridvar, gridvec, 'smhan', 'len', len);
%
% grids variables in d (structure) based on field gridvar (string) using
%   one of the following methods: 
% 'meanbin': means of data in (contiguous) bins with edges gridvec
% 'medbin': as above but median
% 'meannum': means of each num-points segment (starting from the first
%   point). note: if data are regularly-spaced such that the same number of
%   input points go into each bin (e.g. averaging 24-hz series with no
%   missing times to 1-hz), this is much more efficient than meanbin!    
% 'lfitbin': prediction, at midpoints of bins, of linear fit to data in
%   (contiguous) bins with edges gridvec
% 'medint': median of data in intervals around gridvec, specified by input
%   'int' (see below)
% 'meanint': as above but mean
% 'linterp': linearly interpolate
% 'smhan': smooth using hanning filter (see below), linearly interpolate to
%   gridvec 
%
% variable inputs can be parameter-value pairs or fields in a structure (or
%     some of both)
% inputs required depending on method: 
%   num (scalar), for method 'meannum': number of points in each average
%   int (tuple), for method 'medint' or 'meanint': range [lower upper]
%   around  each element of gridvec (in gridvar-units) over which to
%   compute median/mean
% len (scalar), for method 'smhan': length (points) for hanning filter
%
% optional inputs for multiple methods:
%   prefill (default 0) whether to fill data gaps by linear interpolation
%     before averaging/fitting/smoothing: 
%     0 to do nothing, positive integer to fill gaps of up to prefill
%     gridvar-units (e.g. you supply 2 dbar data, gridvar = 'press',
%     prefill = 20 will fill gaps up to 20 dbar, not 20 points = 40 dbar),
%     inf to fill  gaps of any length 
%   ignore_nan (default 0) whether to use only non-NaN data:
%     0 to keep NaNs, 1 to exclude them before averaging/fitting/smoothing
%     (ignore_nan and prefill partially overlap; be careful you don't
%     override the behaviour you set with prefill by setting ignore_nan)
%   bin_partial (default 1) whether to include averages/fits for bins with
%     data in only one half (applies to '*bin' and '*int' methods)
%     1 to keep, 0 to NaN them
%   grid_ends (default [1 1]) how to treat any bins at [start end] of
%     profile with no gridvar values:
%     1 to keep (filled with NaNs), 0 to discard
%   profile_extrap (default [0 0]) how to (subsequently) treat bins at
%     [start end] of profile with no gridded data values: 
%     0 to leave NaN, 1 to fill with nearest good gridded value
%   postfill (default 0) as for prefill but for gaps in gridded profile
%     data
%
% d.(gridvar) must be a vector
% when d.(gridvar) is 1xM, other fields in d can be 1xM or NxM
% when d.(gridvar) is Mx1, other fields in d can be Mx1 or MxN
%   fields of different size will be skipped (left as-is)
%
% dg.(gridvar) depends on method: 
%   'meanbin' or 'medbin': the average (mean or median) of d.(gridvar)
%     points in each bin
%   'lfitbin': the midpoints of ge
%   'medint' or 'smhan': ge
%
% partially based on mexec merge_avmed (bak, ylf)
%
% calls gp_binav or gp_smooth, and optionally gp_fillgaps
%
% despite the name, this can be used for time series as well as profiles
%
% ylf dy146


%defaults
prefill = 0;
ignore_nan = 0;
bin_partial = 1;
grid_ends = [1 1];
profile_extrap = [0 0];
postfill = 0;

%parse optional inputs
ino = 1;
while ino<=length(varargin)
    if isstruct(varargin{ino})
        fn = fieldnames(varargin{ino});
        for fno = 1:length(fn)
            eval([fn{fno} ' = varargin{ino}.(fn{fno});'])
        end
        ino = ino+1;
    else
        eval([varargin{ino} ' = varargin{ino+1};'])
        ino = ino+2;
    end
end

if strcmp(method,'lfitbin') && bin_partial
    warning('fitting in partial bins is not recommended!')
end

%variables to grid
fn = fieldnames(d);
if sum(strcmp(method, {'lfitbin' 'medint' 'meanint' 'linterp' 'smhan' 'meannum'}))
    %skip fitting to self (set as centers later)
    fn = setdiff(fn, gridvar);
end
nvar = length(fn);

%find dimensions, make gridvar be column vector for now
if size(d.(gridvar),1)==1
    isrow = 1;
    d.(gridvar) = d.(gridvar)';
else
    isrow = 0;
end
gridvec = gridvec(:);

switch method
    case 'meannum'
        nav = floor(length(d.(gridvar))/num);
    otherwise
        %exclude any NaNs in gridvar
        iib = find(isnan(d.(gridvar)));
        if ~isempty(iib)
            for vno = 1:nvar
                if isrow
                    d.(fn{vno})(:,iib) = [];
                else
                    d.(fn{vno})(iib,:) = [];
                end
            end
            d.(gridvar)(iib) = [];
        end
        clear iib
end


%set up gridding coordinate from gridvec, and save output gridvar
switch method
    case {'meanbin' 'medbin' 'lfitbin' 'medint' 'meanint'}
        %bin edges
        if strcmp(method(end-2:end),'int')
            ge = [gridvec+int(1) gridvec+int(2)];
        else
            ge = [gridvec(1:end-1) gridvec(2:end)];
        end
        method = replace(method, 'int', 'bin'); %now that we've set up the bin edges, treat *int method the same as *bin
        if grid_ends(1)==0
            %exclude completely empty bins on the low end
            ge = ge(ge(:,2)>=min(d.(gridvar)),:);
        end
        if grid_ends(2)==0
            %exclude completely empty bins on the high end
            ge = ge(ge(:,1)<=max(d.(gridvar)),:);
        end
        gridvec = mean(ge,2);
        dg.(gridvar) = gridvec;
        if ~isrow; dg.(gridvar) = dg.(gridvar)'; end        
        %even if empty bins at end(s) were kept, don't bother running them
        %through gridder
        mg = gridvec>=min(d.(gridvar)) & gridvec<=max(d.(gridvar));
    case {'linterp' 'smhan'}
        mk = true(size(gridvec));
        me1 = gridvec<min(d.(gridvar));
        me2 = gridvec>max(d.(gridvar));
        if grid_ends(1)==0
            mk = mk & ~me1;
        end
        if grid_ends(2)==0
            mk = mk & ~me2;
        end
        gridvec = gridvec(mk);
        mg = mk(~me1 & ~me2);
        dg.(gridvar) = gridvec;
    case 'meannum'
        dg.(gridvar) = mean(reshape(d.(gridvar)(1:num*nav),[num nav]));
        if ~isrow; dg.(gridvar) = dg.(gridvar)'; end
end
ngv = length(gridvec);


%initialise gridded fields and concatenated data, and check size of input
%variables
ng_in = length(d.(gridvar));
usevar = true(1,nvar);
data = []; datainds = [];
for vno = 1:nvar
    s = size(d.(fn{vno}));
    if isrow
        if s(2)~=ng_in
            if isnumeric(d.(fn{vno}))
                warning('size [%d %d] of variable %s does not match length %d of gridding variable %s; skipping.', s(1), s(2), fn{vno}, ng_in, gridvar)
            end
            usevar(vno) = 0;
            continue
        end
        dg.(fn{vno}) = NaN+zeros(s(1),ngv);
        data = [data d.(fn{vno}).'];
        datainds = [datainds repmat(vno,1,size(d.(fn{vno}),1))];
    else
        if s(1)~=ng_in
            if isnumeric(d.(fn{vno}))
                warning('size [%d %d] of variable %s does not match length %d of gridding variable %s; skipping.', s(1), s(2), fn{vno}, ng_in, gridvar)
            end
            usevar(vno) = 0;
            continue
        end
        dg.(fn{vno}) = NaN+zeros(ngv,s(2));
        data = [data d.(fn{vno})];
        datainds = [datainds repmat(vno,1,size(d.(fn{vno}),2))];
    end
end
skipvar = find(~usevar);
usevar = find(usevar);

%fill NaNs if specified
if prefill>0
    data = gp_fillgaps(data, d.(gridvar), prefill);
end

%grid
switch method
    case {'meanbin' 'medbin' 'lfitbin'}
        datag = nan(size(ge,1),size(data,2));
        datag(mg,:) = gp_binav(data, d.(gridvar), ge(mg,:), method(1:end-3), 'ignore_nan', ignore_nan, 'bin_partial', bin_partial);
        data = datag; clear datag
    case 'meannum'
        cdim = size(data,2);
        data = reshape(data(1:num*nav,:),[num nav cdim]);
        if ignore_nan
            data = permute(mean(data, 'omitmissing'), [2 3 1]);
        else
            data = permute(mean(data), [2 3 1]);
        end
    case {'linterp' 'smhan'}
        datag = nan(length(gridvec),size(data,2));
        datag(mg,:) = gp_smooth(data, d.(gridvar), gridvec(mg), method, 'ignore_nan', ignore_nan);
        data = datag; clear datag
end

% fill ends if specified
if profile_extrap(1)==1
    data = gp_fillgaps(data, 'first');
end
if profile_extrap(2)==1
    data = gp_fillgaps(data, 'last');
end
if postfill>0
    data = gp_fillgaps(data, dg.(gridvar), postfill);
end

%separate data into variables and transpose if necessary
for vno = usevar
    vm = datainds==vno;
    if isrow
        dg.(fn{vno}) = data(:,vm).';
    else
        dg.(fn{vno}) = data(:,vm);
    end
end
%transpose gridvar if necessary
if isrow && size(dg.(gridvar),1)>1
    dg.(gridvar) = dg.(gridvar).';
elseif ~isrow && size(dg.(gridvar),2)>1
    dg.(gridvar) = dg.(gridvar).';
end

for sno = skipvar
    dg.(fn{sno}) = d.(fn{sno});
end

