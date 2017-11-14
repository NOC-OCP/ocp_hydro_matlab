function [xa ya] = m_arrow(x,y,len,dir,head)

% Return the x and y coordinates of a plottable arrow
% All values in natural units of x and y plot
% len and head are the length in y-units. The arrow
% will be constructed in the y-direction and then
% rotated by dir degrees, clockwise from the y axis.
% If head is not specified, it defaults to 1/6 of the arrow length.

if nargin < 5; head = len/6; end

x1 = x;
y1 = y;

x2 = x1;
y2 = y1+len;

x3 = x2+head/2;
y3 = y2-head;

x4 = x3-head;
y4 = y3;

x5 = x2;
y5 = y2;

xa = [x1 x2 x3 x4 x5];
ya = [y1 y2 y3 y4 y5];

xoff = xa-x1;
yoff = ya-y1;

ang = dir*pi/180;
c = cos(ang);
s = sin(ang);
rot = [c s; -s c];

new = rot*[xoff;yoff];

xa = x1 + new(1,:);
ya = y1 + new(2,:);

return