function dg = grid_profile(d, gridvar, gridvec, method, varargin)
% dg = grid_profile(d, gridvar, gridvec, method, varargin);
% dg = grid_profile(d, gridvar, gridvec, 'medbin');
% dg = grid_profile(d, gridvar, gridvec, 'medint', 'int', [below above]);
% dg = grid_profile(d, gridvar, gridvec, 'smhan', 'len', len);
%
% grids variables in d (structure or table) based on field/variable gridvar
%   (string) using one of the following methods: 
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
% if d is a structure and d.(gridvar) is 1xM, other fields in d can be 1xM
%   or NxM; if d.(gridvar) is Mx1, other fields in d can be Mx1 or MxN;
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
%for which methods do we calculate output dg.(gridvar) rather than assigning based on gridvec?
calcgms = {'meanbin','medbin','meannum'};

%separate out non-numeric or non-matching variables, convert remainder to
%columns and table if necessary 
if isstruct(d)
    s = size(d.(gridvar));
    fn = fieldnames(d);
    %find dimensions, make gridvar be column vector for now
    if s(1)==1
        intype = 'rowstr';
        for fno = 1:length(fn)
            if size(d.(fn{fno}),2)==s(2) && isnumeric(d.(fn{fno}))
                d.(fn{fno}) = d.(fn{fno})';
            else
                d0.(fn{fno}) = d.(fn{fno});
                d = rmfield(d,fn{fno});
            end
        end
    elseif s(2)==1
        intype = 'colstr';
        for fno = 1:length(fn)
            if size(d.(fn{fno}),1)==s(1) && isnumeric(d.(fn{fno}))
                d.(fn{fno}) = d.(fn{fno});
            else
                d0.(fn{fno}) = d.(fn{fno});
                d = rmfield(d,fn{fno});
            end
        end
    else
        error('field %s must be a vector',gridvar)
    end
    d = struct2table(d);
elseif istable(d)
    intype = 'tabl';
    m = strcmp('double',d.Properties.VariableTypes);
    if sum(~m)
        d0 = table2struct(d(:,~m),'ToScalar',true);
        d = d(:,m);
    end
end
if exist('d0','var')
    warning('skipping non-numeric variables or those whose sizes do not match %s:',gridvar)
    disp(fieldnames(d0)')
end

if ~contains(method,'num')
    %exclude any NaNs in d.(gridvar)
    d = rmmissing(d,'DataVariables',{gridvar});
    %and any rows where every other variable is nan
    d = rmmissing(d,'DataVariables',setdiff(d.Properties.VariableNames,gridvar),'MinNumMissing',size(d,2)-1);
end

%convert data to be gridded to matrix
gridin = d.(gridvar); 
if ~ismember(method, calcgms)
    %don't grid, assign as gridvec later
    d.(gridvar) = [];
end
data = d{:,:};

%fill NaNs if specified
if prefill>0
    data = gp_fillgaps(data, gridin, prefill);
end

%set up gridding coordinate from gridvec
gridvec = gridvec(:);
switch method
    case 'meannum'
        nav = floor(length(d.(gridvar))/num);
        gridvec = mean(reshape(d.(gridvar)(1:num*nav),[num nav]));
    case {'meanbin' 'medbin' 'lfitbin'}
        %bin edges
        ge = [gridvec(1:end-1) gridvec(2:end)];
        mk = true(size(ge(:,1)));
        me1 = ge(:,2)<min(d.(gridvar));
        me2 = ge(:,1)>max(d.(gridvar));
        if grid_ends(1)==0
            mk = mk & ~me1;
        end
        if grid_ends(2)==0
            mk = mk & ~me2;
        end
        ge = ge(mk, :);
        mg = mk(~me1 & ~me2);
        gridvec = mean(ge,2);
    case {'medint' 'meanint'}
        %bin edges
        ge = [gridvec+int(1) gridvec+int(2)];
        mk = true(size(ge(:,1)));
        me1 = ge(:,2)<min(d.(gridvar));
        me2 = ge(:,1)>max(d.(gridvar));
        if grid_ends(1)==0
            mk = mk & ~me1;
        end
        if grid_ends(2)==0
            mk = mk & ~me2;
        end
        ge = ge(mk, :); gridvec = gridvec(mk);
        mg = mk(~me1 & ~me2);
        %now that we've set up the bin edges can use binav below
        method = [method(1:end-3) 'bin'];
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
end

%grid
switch method
    case {'meanbin' 'medbin' 'lfitbin'}
        datag = nan(size(ge,1),size(data,2));
        datag(mg,:) = gp_binav(data, gridin, ge(mg,:), method(1:end-3), 'ignore_nan', ignore_nan, 'bin_partial', bin_partial);
        data = datag; clear datag
    case 'meannum'
        cdim = size(data,2);
        data = reshape(data(1:num*nav,:),[num nav cdim]);
        if ignore_nan
            data = mean(data,'omitmissing');
        else
            data = mean(data);
        end
        data = permute(data, [2 3 1]);
    case {'linterp' 'smhan'}
        datag = nan(length(gridvec),size(data,2));
        datag(mg,:) = gp_smooth(data, gridin, gridvec(mg), method, 'ignore_nan', ignore_nan);
        data = datag; clear datag
end
% put back into table
n0 = size(d,1); n1 = size(data,1);
if n0>n1
    d = d(1:size(data,1),:);
elseif n0<n1
    d = paddata(d, n1);
end
d{:,:} = data;
if ismember(method, calcgms)
    gridvec = d.(gridvar);
end

% fill ends if specified
if profile_extrap(1)==1
    data = gp_fillgaps(data, 'first');
end
if profile_extrap(2)==1
    data = gp_fillgaps(data, 'last');
end
if postfill>0
    data = gp_fillgaps(data, gridvec, postfill);
end
d{:,:} = data;
d.(gridvar) = gridvec;


%put gridded data back into original shape and type
switch intype
    case 'colstr'
        dg = table2struct(d,'ToScalar',true);
    case 'rowstr'
        fn = d.Properties.VariableNames;
        for fno = 1:length(fn)
            dg.(fn{fno}) = d.(fn{fno}).';
        end
    case 'tabl'
        dg = d;
end
%put back non-gridded irregular fields
if exist('d0','var')
    fn = fieldnames(d0);
    for fno = 1:length(fn)
        dg.(fn{sno}) = d0.(fn{sno});
    end
end


