% Evaluate the sum of squares of the residuals between a set of data
% x, y and the function p(1)*exp(-0.5((x-p(3))/p(2))^2) e.g 
% between y and a gaussian with amplitude p(1), 
% mean width p(2) and maximum at p(3).
% Minimizing fitgaussian, e.g. using 
% [p, fval, exitflag]= fminsearch(@fitgaussian,p,[],x,y)
% finds values of p for best fit gaussian to the data.

function y=gaussian_eval(p,x)
y = p(1).*exp(-0.5.*((x-p(3))./p(2)).^2);

