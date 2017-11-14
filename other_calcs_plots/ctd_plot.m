% ctd_plot: make diagnostic plots of the CTD data for archiving
%
% Use: mctd_plot        and then respond with station number, or for station 16
%      stn = 16; mctd_plot;

% written by ZB Szuts on 23.10.2009 for D344

scriptname = 'ctd_plot';

if exist('stn','var')
    m = ['Running script ' scriptname ' on station ' sprintf('%03d',stn)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);

stnlocal = stn;
clear stn % so that it doesn't persist


% define which file extension to use for plotting
plotext = '2db'

mcd('M_CTD'); % change working directory

prefix1 = ['ctd_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
plotfile = [prefix1 stn_string '_' plotext];


[d h] = mload(plotfile,'/') % load all variables
p = d;


pmax = ceil(max(p.press)/500)*500; % round to the nearest 500 db
plims = [0 pmax]; pticks = pmax/500;
tlims = [0 30];   tticks = 30/2.5;
slims = [34 38];  sticks = 0.2;


%% plot variables against depth
set(0,'defaulttextinterpreter','tex')

p.xlist = 'press';
p.ylist = 'potemp potemp2 psal psal2';
p.xax = plims;
p.yax = [tlims; tlims; slims; slims];
p.nxt = pticks;
p.nyt = [tticks tticks sticks sticks];
p.cols = 'krbgmcy';
p.widths = [1 1 1 1]*0.5;
p.plotsize = [20 14]; % otherwise the axis is too big, works with saveas(,,'pdf')

mplotxy_ctd(p,plotfile)

if ~exist([pwd '/pdf'],'dir')
  eval(['!mkdir ' pwd '/pdf'])
end

outfile = [pwd '/pdf/' plotfile '_plot_pres']
if exist(outfile,'file')
  disp('outfile already exists - delete it and run this script again')
else
  saveas(gcf,[outfile '.pdf'],'pdf')
  print(gcf,'-depsc',[outfile '.eps'])
end


if 1==0 % can't get two separate independent variables on the same
        % graph with mplotxy_ctd

  %% plot variables for TS plot
  p.newfigure = 'landscape';
  p.plotorg = [3 3];
  p.over = 0;
  p.xlist = 'psal';
  p.ylist = 'potemp';
  p.xax = [slims];
  p.yax = [tlims];
  p.nxt = [sticks];
  p.nyt = [tticks];
  %p.cols = 'krbgmcy';
  p.cols = 'k';
  p.widths = [1 1]*0.5;
  p.plotsize = [20 14]; % otherwise the axis is too big, works with saveas(,,'pdf')
  p = mplotxy(p,plotfile)

  p.over = 1;  %overplot next file in same panel; keep same axes handle
  p.xlist = 'psal2';
  p.ylist = 'potemp2';
  %p.cols = 'krbgmcy';
  p.cols = 'r';
  p = mplotxy(p,plotfile)

  outfile = [pwd '/pdf/' plotfile '_plot_ts.pdf']
  saveas(gcf,outfile,'pdf')

elseif 1==1 % do simply by hand

  if 1==0 % don't need vertical profiles
    f1 = figure;
    plot(p.potemp,p.press,'k-',p.potemp2,p.press,'r-')
    grid on, set(gca,'ydir','reverse'), orient tall
    xlabel('potemp')
    ylabel('pres')
    title('k=potemp, r=potemp2')

    f2 = figure;
    plot(p.psal,p.press,'k-',p.psal2,p.press,'r-')
    grid on, set(gca,'ydir','reverse'), orient tall
    xlabel('sal')
    ylabel('pres')
    title('k=psal, r=psal2')
  end

  f3 = figure;
  set(gcf,'defaultaxesfontsize',16)
  set(0,'defaulttextinterpreter','none')
  plot(p.psal,p.potemp,'k-',p.psal2,p.potemp2,'r-')
  grid on, orient landscape
  xlabel('sal')
  ylabel('potemp')
  title([plotfile ':   k=sensor 1, r=sensor 2'])

  outfile = [pwd '/pdf/' plotfile '_plot_ts']
  if exist(outfile,'file')
    disp('outfile already exists - delete it and run this script again')
  else
    saveas(gcf,[outfile '.pdf'],'pdf')
    print(gcf,'-depsc',[outfile '.eps'])
  end

  f4 = figure;
  set(gcf,'defaultaxesfontsize',16)
  set(0,'defaulttextinterpreter','none')
  plot(p.temp-p.temp2,p.press,'k-',...
       p.cond-p.cond2,p.press,'b-',...
       p.psal-p.psal2,p.press,'r-')
  grid on, orient tall, set(gca,'ydir','reverse')
  xlabel('temp-temp2 (k), psal-psal2 (r), cond-cond2 (b)')
  ylabel('pres (db)')
  title([plotfile])
  xlim([-1 1]*0.05)
  xlim([-1 1]*0.01)
  
  outfile = [pwd '/pdf/' plotfile '_plot_sensdiff']
  if exist(outfile,'file')
    disp('outfile already exists - delete it and run this script again')
  else
    saveas(gcf,[outfile '.pdf'],'pdf')
    print(gcf,'-depsc',[outfile '.eps'])
  end
  
  set(0,'defaulttextinterpreter','tex')

end
