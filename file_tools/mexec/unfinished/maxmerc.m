function p2 = maxmerc(p)
% function p2 = axmerc(p)
%
% Inspect an mexec pdf or cdf and adjust the plotsize so that the axes
% have mercator scaling
%
% After use, simply replot the figure using the output pdf or cdf
%
% Shrink whichever dimension of the plot is required to achieve mercator
% axis scaling
% If there are multiple y variables, assume latitude is the first of them.
%
% Example, if posmvpos.nc contains data from the posmvpos stream
% 
% MEXEC_A.MARGS_IN = {'posmvpos.nc'    'lon'    'lat'};
% p = mplotxy % p contains the description of a plot
% p2 = maxmerc(p) % p2 is a copy of p, with plotsize set for mercator
%                 % scaling of axes
% mplotxy(p2)

m_common

if nargin ~= 1
    m = 'function maxmerc requires precisely one argument';
    fprintf(MEXEC_A.Mfider,'%s\n','',m,'')
    return
end

p2 = p;

delx = p.xax(2) - p.xax(1);
dely = p.yax(1,2) - p.yax(1,1);
latmid = (p.yax(1,2) + p.yax(1,1))/2;

wx = p.plotsize(1);
wy = p.plotsize(2);


x_equiv = delx*cos(pi*latmid/180);
y_equiv = dely;

scalex = wx/x_equiv; % present scale in cm per unit of equivalent latitude
scaley = wy/y_equiv; % present scale in cm per unit of equivalent latitude

if scalex > scaley
    %     reduce x size
    p2.plotsize = [x_equiv*scaley wy];
else
    %     reduce y size
    p2.plotsize = [wx y_equiv*scalex];
end

return





