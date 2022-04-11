function y = m_nanprctile(x,pc,dim)

% function y = m_nanprctile(x,pc,[dim]); % version of prctile to avoid stats toolbox
%
% Can be used in a matlab session or called from mcalib or mcalc, or in
% other mexec functions
%
% In this function, columns with zero non-NaN values returns NaN for all
%   percentiles.
% This function allows -inf and inf, because they behave sensibly in the
%   call to Matlab 'sort'.
% It is allowable for a value at a percentile to be -inf or inf.
% If a percentile value is calculated where the input data are inf,
%   the result will depend on the behaviour of the Matlab interp1q function
% A special loop is used for finding the median percentile = 50,
%   called only when isequal(pc,50) returns logical 1.
%   This fast median loop goes direct to the middle of an odd number of 
%   values, regardless of its neighbours. If the value neighbouring the 
%   median is inf, then the result of calling this function with pc = 50 
%   may not be the same as calling the function with pc = [50 50], 
%   because in the first case we execute the fast median loop and in the 
%   second case we use the interp1q branch.
%
% The meaning of percentiles is taken from the Matlab prctile function,
%  so this version should give the same output as that function.
%
% INPUT:
%   x: data to be processed; can be N-Dimensional
%   pc: 1-D array of percentiles at which x is to be evalauted
%   dim: dimension of x used for direction of processing
%        If dim is not specified, the first non-unity dimension is used.
%        If all dimensions are unity, dim defaults to 1
%
% OUTPUT:
%   y: Often has the same number of dimensions as x
%      The dimension number dim is collapsed to length 1.
%      Since a call is made to the Matlab 'sum' function,
%      if dim > 2 and if dim is the last dimension, then
%      the resulting dimension of length 1 is squeezed.
%
% EXAMPLES:
%   y = m_nanprctile(x,1);
%   y = m_nanprctile(x,2);
%
% UPDATED:
%   Initial version BAK 2008-10-17 at NOC used call to matlab prctile
%   Rewritten    by BAK 2009-08-11 on macbook to avoid stats toolbox calls
%   Error handling by BAK 2009-08-11 on macbook
%   Help updated by BAK 2009-08-11 on macbook
%

if nargin <2
    % must give at least 2 arguments, data x and percentiles, pc
    error('mexec:m_nanprctile:not_2_arguments','\n%s %d %s\n','Require at least 2 arguments; only',nargin,'provided');
end


if nargin <3
    dim = min(find(size(x)~=1)); % default is first non-unity dimension
    if isempty(dim), dim = 1; end
end

sizexin = size(x); % keep a note of data input dimensions
ndimsx = length(sizexin);
% If the user has requested a dimension larger than the
% natural dimension of x, pad the size array
if dim > ndimsx
    sizex = [sizexin ones(1,dim-ndimsx)];
else
    sizex = sizexin;
end

% only permute if working dimension is not first dimension
if dim > 1
    perm = [dim:length(sizex) 1:dim-1];
    x = permute(x,perm); % permute the requested dimension to 'first'
    sizexperm = sizex(perm); % permute the lengths of each dimension
else
    sizexperm = sizex;
end

nrows = sizexperm(1); % now we're working along the first dimension of the permuted array
ncols = prod(sizexperm)/nrows; % this is the product of the remaining dimensions

x = reshape(x,nrows,ncols); % reshape all dimensions not being worked along to 'columns'

% create empty y
y = nan+ones(length(pc),ncols);

% scan over each 'column'
for kloop = 1:ncols
    xcol = x(:,kloop);
    xcol(isnan(xcol)) = [];
    if isempty(xcol)
        y(1:length(pc),kloop) = nan;
    else
        xcol = sort(xcol);
        nx = length(xcol);
        if isequal(pc,50) % make the median faster. In this case we're
            %             asking for a single value, the median.
            %             If the value neighbouring the median is inf, then the result
            %             of calling this function with pc = 50 may not be the same as
            %             calling the function with pc = [50 50], because in the first
            %             case we execute the fast median loop and in the second case
            %             we use the interp1q branch.
            if rem(nx,2) == 1 % nx is odd
                y(1,kloop) = xcol((nx+1)/2); % length of pc = 1 because only doing median
            else         % nx is even
                y(1,kloop) = (xcol(nx/2) + xcol(nx/2+1))/2;
            end
        else
            % follow algorithm for percentiles defined in Matlab prctile
            % function in Matlab stats toolbox
            xi = [0 1:nx nx]; % xi is index of the sorted x values
            xi = xi-0.5;
            xi = 100*xi/nx;
            xi(1) = 0; xi(end) = 100; % first and last values replicated to define zero and 100 percentiles
            xi = xi(:);
            xcol = [xcol(1) ; xcol ; xcol(end)];
            y(1:length(pc),kloop) = interp1q(xi,xcol,pc(:));
        end
    end
end

sizey = sizexperm; % y must eventually have the same size as the permuted x,
% except in the first dimension, where y will have as many values as there
% were requested percentiles.
sizey(1) = length(pc);
y = reshape(y,sizey); % reshape the collapsed dimensions back to original shape

if dim > 1
    y = ipermute(y,perm); % undo permutation
end

return
