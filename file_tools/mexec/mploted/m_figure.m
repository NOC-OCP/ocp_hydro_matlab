%builtin('figure')
scrsz = get(0,'ScreenSize');
% bak on di346 jan 2010
% on some screens, this seem to result in the top of the fiugure being
% off-screen, so the figure can't then be moved and the matlab tools are
% invisible. Adjust figure down a bit.
% for example on w/s rapid, 7.5.0.338 (R2007b), the grey plotting part of the figure fills the
% 'position' not the entire figure window.
% builtin('figure','Position',[1 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2]);
builtin('figure','Position',[1 0.4*scrsz(4) 0.5*scrsz(3) 0.5*scrsz(4)]);



% routine by BAK to set better default line width and font size
%return
set(gcf,'defaultaxeslinewidth',2)
%return
set(gcf,'defaultlinelinewidth',2)
%return
set(gcf,'defaultaxesfontsize',14)
set(gcf,'defaulttextfontsize',14)
set(gcf,'defaultaxescolor',[.9 .9 .9])
