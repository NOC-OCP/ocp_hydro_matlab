function y_sm = smss(x, y, xs, varargin);
% function y_sm = smss(x, y, xs, parameter, value);
%
% smooths or averages and resamples y from x to xs, using specified method
%
% output:
%   y_sm, MxN
%
% inputs:
%    x, Lx1
%    y, LxN
%    xs, Mx1
%    parameter value pairs:
%       'smethod':
%          'lfitmid' [default]
%          'lfitdel'
%          'smhan'
%       'init_extrap':
%          'surf' to fill missing values at beginning of each y column with
%             first good value in that column
%       'bin_extrap':
%          0 [default]
%          1 (for lfitmid and lfitdel, fit and predict in xs bins with data on
%            only one side of xs, e.g. x = [0:2:24], xs = [5:5:30], extrap = 0
%            will return NaN for last 2 points; extrap = 1 will return NaN for
%            last point)
%
% see stations_to_line for use

%defaults
smethod = 'lfitmid';
len = (x(2)-x(1))*10;
bin_extrap = 0;

%assign any parameter value pairs
for no = 1:2:length(varargin)
    eval([varargin{no} ' = varargin{' num2str(no+1) '};'])
end


%if specified, fill to surface
if exist('init_extrap','var') && strncmp(init_extrap, 'surf', 4)
    jj = find(isnan(y(1,:)) & sum(~isnan(y))>0); if ~isempty(jj); y0 = y; end
    for no = 1:length(jj)
        iib = find(isnan(y(:, jj(no))));
        d = diff(iib); iid = find(d>1); if ~isempty(iid); iib = iib(1:iid(1)); end
        nb = length(iib);
        y(iib, jj(no)) = repmat(y(iib(end)+1, jj(no)), nb, 1);
    end
    if ~isempty(jj); disp('extrap to surf'); end
end


%now smooth/average
n = size(y);

if strncmp(smethod, 'lfit', 4) %same procedure except different xse
    
    y_sm = NaN+zeros([length(xs) n(2:end)]);
    xs = xs(:); x = x(:);
    a = repmat(x, 1, size(y,2)); a(isnan(y)) = NaN;
    
    if strcmp(smethod, 'lfitmid') %use linear fits to y in bins divided midway between xs
        xse = [[xs(1)-(xs(2)-xs(1))/2; .5*(xs(1:end-1)+xs(2:end))] [.5*(xs(1:end-1)+xs(2:end)); xs(end)+(xs(end)-xs(end-1))/2]];
    elseif strcmp(smethod, 'lfitdel') %use linear fits to y in bins of length len centered at xs
        xse = [xs-len/2 xs+len/2];
    end
    
    for no = 1:length(xs)
        iix = find(x>=xse(no,1) & x<xse(no,2));
        if length(iix)>1
            for no2 = 1:n(2)
                if bin_extrap
                    iig = iix(find(~isnan(y(iix,no2))));
                else
                    iig = iix;
                end
                if sum(~isnan(y(iig,no2)))>0
                    b = [ones(length(iig),1) x(iig)]\y(iig,no2);
                    y_sm(no, no2) = b(1)+b(2)*xs(no);
                end
            end
        end
    end
    
elseif strcmp(smethod, 'smhan') %smooth with hanning window of length len, then subsample at xs
    dx = x(2)-x(1);
    nw = (round(len/dx)/2)*2-1; %e-folding length is about len/3
    a = sm_hanning(y, nw, 1);
    y_sm = interp1(x, a, xs);
    
end