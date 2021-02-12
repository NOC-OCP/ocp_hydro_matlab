function axmerc2

% Shrink whichever dimension of the plot is required to achieve mercator axis scaling

ax = axis;
u = get(gca,'units');
set(gca,'units','centimeters');
pos = get(gca,'position');
wx = pos(3); % width x
wy = pos(4); % width y


delx = ax(2) - ax(1);
dely = ax(4) - ax(3);
latmid = (ax(3)+ax(4))/2;

x_equiv = delx*cos(pi*latmid/180);
y_equiv = dely;

scalex = wx/x_equiv; % present scale in cm per unit of equivalent latitude
scaley = wy/y_equiv; % present scale in cm per unit of equivalent latitude

if scalex > scaley
    %     reduce x size
    pos = [pos(1) pos(2) x_equiv*scaley wy];
else
    %     reduce y size
    pos = [pos(1) pos(2) wx y_equiv*scalex];
end
set(gca,'position',pos);
set(gca,'units',u);

return
