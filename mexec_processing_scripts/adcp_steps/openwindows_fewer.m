% open LADCP windows spread over the dislay
%
% test how large the dislay is

if (get(0, 'screensize') == [1 1 1 1])  % No Display
   return
end

dis.child=get(0,'children');

if ~isempty(dis.child)
	disp(' found windows, >>close all, will clear all windows ')
        for n=1:length(dis.child)
         figure(dis.child(n)), clf
        end
        pause(0.01)
else

  dis.screensize=get(0,'screensize');
  dis.dy=20;
  dis.dxmul=1;
  dis.dymul=1;
  dis.dxf=[1.5 2];
  if dis.screensize(3)>dis.screensize(4)*2
 % wide screen 2nd monitor?
   disp(' detected wide screen or 2nd monitor')
   dis.dxmul=3/4.5;
   dis.dy=80;
   dis.dxf=[2 2.7];
  end
  if dis.screensize(3)<dis.screensize(4)
 % tall screen 2nd monitor?
   disp(' detected tall screen or 2nd monitor')
   dis.dxmul=1.2;
   dis.dymul=0.7;
   dis.dy=30;
   dis.dxf=[1.5 2];
  end
 

% put them on the right hand side
   dis.windowdx=fix(dis.screensize(3)/3*dis.dxmul);
   dis.windowdxs=fix(dis.screensize(3)/4*dis.dxmul);
   dis.windowdys=fix(dis.screensize(4)/3*dis.dymul);
   dis.windowdym=fix(dis.screensize(4)/2*dis.dymul);
   dis.windowdyl=fix(dis.screensize(4)/1.5*dis.dymul);
% 
  saveplot_all = p.saveplot;
  if isfield(p,'saveplot_pdf'); saveplot_all = union(saveplot_all,p.saveplot_pdf); end
  if isfield(p,'saveplot_png'); saveplot_all = union(saveplot_all,p.saveplot_png); end
  dis.large=intersect([1],saveplot_all);
  dis.medium=intersect([2,4],saveplot_all);
  dis.small=intersect([3,5:7 9:10,12:13],saveplot_all);
  dis.warn=11;
% 
  dis.x0=(dis.screensize(3)-dis.windowdx-2);
  dis.x1=(dis.screensize(3)-dis.dxf(1)*dis.windowdx);
  dis.x2=(dis.screensize(3)-dis.dxf(2)*dis.windowdx);
  
  dis.Y0=dis.screensize(4)-80;

  dis.Y=dis.Y0-dis.windowdys;
  for n=1:length(dis.small)
	 figure(dis.small(n));
	 set(dis.small(n),'Position',...
	     [dis.x2 dis.Y dis.windowdxs dis.windowdys]);
         dis.Y=dis.Y-dis.dy;
  end
   
  dis.Y=dis.Y0-dis.windowdym;
  for n=1:length(dis.medium)
	 figure(dis.medium(n));
	 set(dis.medium(n),'Position',...
	     [dis.x1 dis.Y dis.windowdx dis.windowdym]);
         dis.Y=dis.Y-dis.dy*1.5; 
  end
   
  dis.Y=dis.Y0-dis.windowdyl;
  for n=1:length(dis.large)
	 figure(dis.large(n));
	 set(dis.large(n),'Position',...
	     [dis.x0 dis.Y dis.windowdx dis.windowdyl]);
         dis.Y=dis.Y-dis.dy*2;
  end

  dis.Y=dis.Y0-dis.windowdys;
  figure(dis.warn(1))
	 set(dis.warn(1),'Position',...
	     [50 dis.Y dis.windowdx dis.windowdys]);
	     
end

pause(0.1)
