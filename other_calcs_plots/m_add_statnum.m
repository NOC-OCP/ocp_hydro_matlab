function [hline ht] = m_add_statnum(slat,slon,lcol,lwid,llen,lphi,ftxt,fcol,fsize,horal,vertal)

% bak on jr281
% add a station number to a track plot.
% arguments are
% lat and lon of station
% line colour, width, length and angle, anticlockwise from east
% length is fraction of x and y axes length;
% text string to be added
% font color and size
% horizontal alignment of text 
%
% eg m_add_statnum(lat,lon,'r',1,0.06,100,'txt','r',10,'center','bottom')
%
% bak on jr302: return handles for line and number


ax = axis;
axy = ax(4)-ax(3);
axx = ax(2)-ax(1);
degrad = pi/180;
dely = llen*sin(lphi*degrad)*axy;
delx = llen*cos(lphi*degrad)*axx;

lcol2 = [lcol '-'];

hline = plot([slon slon+delx],[slat slat+dely],lcol2,'linewidth',lwid);

ht = text(slon+delx,slat+dely,ftxt);
set(ht,'fontsize',fsize,'color',fcol,'HorizontalAlignment',horal,'VerticalAlignment',vertal);

