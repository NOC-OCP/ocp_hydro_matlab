function pout = gaussfit2(x,y,ztype)

% jc069: fit gaussian
% make first guess at half width depend on vertical coordinate
% options are press, gamma, sigma1

defwidth = [100 .1 .1]; % default widths for each coordinate type

if nargin == 2
    ztype = 'press'; % default
end

[ymax kmax] = max(y);

p(1) = ymax; % max value
p(3) = x(kmax); % depth of max value

switch ztype
    case 'press'
        p(2) = defwidth(1);
        p(4) = defwidth(1);
    case 'gamma'
        p(2) = defwidth(2);
        p(4) = defwidth(2);
    case 'sigma1'
        p(2) = defwidth(3);
        p(4) = defwidth(3);
    otherwise
        merr = ['vertical coordinate ' ztype ' not recognised in gaussfit function'];
        fprintf(2,'\n\n%s\n\n\n',merr)
        pout = [0 0 0];
        return
end


 pout = fminsearch(@gaussian_resid2,p,[],x,y);

