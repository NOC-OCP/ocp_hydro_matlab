%builtin('figure')
scrsz = get(0,'ScreenSize');

% modified by ZBS on 22.10.2009 to make a smaller axis for export

%builtin('figure','Position',[1 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2]);
builtin('figure');

% routine by BAK to set better default line width and font size
%return
set(gcf,'defaultaxeslinewidth',2)
%return
set(gcf,'defaultlinelinewidth',2)
%return
set(gcf,'defaultaxesfontsize',16)
set(gcf,'defaulttextfontsize',16)

