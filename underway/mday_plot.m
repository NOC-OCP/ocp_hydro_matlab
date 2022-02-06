function pdf = mday_plot(varargin)
% function mday_plot(day)
%
% Function to spew out all the plots we are interested in each day.
%

if (length(varargin)==0)
  daystring='01'
else
  daystring=['d' int2str(varargin{1}(1)) '_raw']
end

m_setup

% met data plot

%% Generic settings
pdf.time_var='time'
pdf.xlist='time'
pdf.plotsize=[14,6]
pdf.time_scale=3

pdf.plotorg=[5,11]
pdf.ylist='humid'
pdf.yax=[40 80]
pdf=mplotxy(pdf,fullfile(MEXEC_G.MEXEC_DATA_ROOT, 'met/surfmet/met_di344_' daystring '.nc']))

pdf.ylist='airtemp'
pdf.yax=[10 35]
pdf.newfigure='none'
pdf.plotorg=[22,11]
pdf=mplotxy(pdf,fullfile(MEXEC_G.MEXEC_DATA_ROOT, 'met/surfmet/met_di344_' daystring '.nc']))

pdf.ylist='speed'
pdf.yax=[0 30]
pdf.newfigure='none'
pdf.plotorg=[5,2]
pdf=mplotxy(pdf,fullfile(MEXEC_G.MEXEC_DATA_ROOT, 'met/surfmet/met_di344_' daystring '.nc']))

pdf.ylist='direct'
pdf.yax=[0 360]
pdf.newfigure='none'
pdf.plotorg=[22,2]
pdf=mplotxy(pdf,fullfile(MEXEC_G.MEXEC_DATA_ROOT, 'met/surfmet/met_di344_' daystring '.nc']))

%%%%%%%%Ashtech

if (length(varargin)==0)
  daystring='01'
else
  daystring=['d' int2str(varargin{1}(1)) '_edt']
end

pdf=[]

%% Generic settings
pdf.time_var='time'
pdf.xlist='time'
pdf.plotsize=[14,6]
pdf.time_scale=3

pdf.plotorg=[5,11]
pdf.ylist='head_ash'
pdf.yax=[0 360]
pdf=mplotxy(pdf,fullfile(MEXEC_G.MEXEC_DATA_ROOT, 'nav/ash/ash_di344_' daystring '.nc']))

pdf.ylist='head_gyr'
pdf.yax=[0 360]
pdf.newfigure='none'
pdf.plotorg=[22,11]
pdf=mplotxy(pdf,fullfile(MEXEC_G.MEXEC_DATA_ROOT, 'nav/ash/ash_di344_' daystring '.nc']))

pdf.ylist='pitch'
pdf.yax=[-5 5]
pdf.newfigure='none'
pdf.plotorg=[5,2]
pdf=mplotxy(pdf,fullfile(MEXEC_G.MEXEC_DATA_ROOT, 'nav/ash/ash_di344_' daystring '.nc']))

pdf.ylist='roll'
pdf.yax=[-5 5]
pdf.newfigure='none'
pdf.plotorg=[22,2]
pdf=mplotxy(pdf,fullfile(MEXEC_G.MEXEC_DATA_ROOT, 'nav/ash/ash_di344_' daystring '.nc']))


%%%%%%%%GPS4000

if (length(varargin)==0)
  daystring='01'
else
  daystring=['d' int2str(varargin{1}(1)) '_raw']
end

pdf=[]

%% Generic settings
pdf.xlist='long'
pdf.plotsize=[28,12]
pdf.time_scale=0

pdf.plotorg=[5,2]
pdf.ylist='lat'
pdf.symbols={'.'}
pdf.styles={''}
pdf=mplotxy(pdf,fullfile(MEXEC_G.MEXEC_DATA_ROOT, 'nav/gps4000/pos_di344_' daystring '.nc']))


pdf=[]

%% Generic settings
pdf.time_var='time'
pdf.xlist='time'
pdf.plotsize=[14,6]
pdf.time_scale=3

pdf.plotorg=[5,11]
pdf.ylist='long'
pdf.yax=[-15 -16]
pdf=mplotxy(pdf,fullfile(MEXEC_G.MEXEC_DATA_ROOT, 'nav/gps4000/pos_di344_' daystring '.nc']))

pdf.ylist='lat'
pdf.yax=[28.4 28.6]
pdf.newfigure='none'
pdf.plotorg=[22,11]
pdf=mplotxy(pdf,fullfile(MEXEC_G.MEXEC_DATA_ROOT, 'nav/gps4000/pos_di344_' daystring '.nc']))

pdf.ylist='alt'
pdf.yax=[-50 50]
pdf.newfigure='none'
pdf.plotorg=[5,2]
pdf=mplotxy(pdf,fullfile(MEXEC_G.MEXEC_DATA_ROOT, 'nav/gps4000/pos_di344_' daystring '.nc']))

pdf.ylist='prec'
pdf.yax=[0 5]
pdf.newfigure='none'
pdf.plotorg=[22,2]
pdf=mplotxy(pdf,fullfile(MEXEC_G.MEXEC_DATA_ROOT, 'nav/gps4000/pos_di344_' daystring '.nc']))

%%%%%%%%TSG

if (length(varargin)==0)
  daystring='01'
else
  daystring=['d' int2str(varargin{1}(1)) '_raw']
end

pdf=[]

%% Generic settings
pdf.xlist='long'
pdf.plotsize=[28,12]
pdf.time_scale=0

pdf=[]

%% Generic settings
pdf.time_var='time'
pdf.xlist='time'
pdf.plotsize=[14,6]
pdf.time_scale=3

pdf.plotorg=[5 11]
pdf.ylist='salin'
pdf.yax=[25 40]
pdf=mplotxy(pdf,fullfile(MEXEC_G.MEXEC_DATA_ROOT, 'tsg/tsg_di344_' daystring '.nc']))

pdf.ylist='sndspeed'
pdf.yax=[1530 1540]
pdf.newfigure='none'
pdf.plotorg=[22,11]
pdf=mplotxy(pdf,fullfile(MEXEC_G.MEXEC_DATA_ROOT, 'tsg/tsg_di344_' daystring '.nc']))

pdf.ylist='temp_h'
pdf.yax=[23 26]
pdf.newfigure='none'
pdf.plotorg=[5,2]
pdf=mplotxy(pdf,fullfile(MEXEC_G.MEXEC_DATA_ROOT, 'tsg/tsg_di344_' daystring '.nc']))

pdf.ylist='temp_r'
pdf.yax=[23 26]
pdf.newfigure='none'
pdf.plotorg=[22,2]
pdf=mplotxy(pdf,fullfile(MEXEC_G.MEXEC_DATA_ROOT, 'tsg/tsg_di344_' daystring '.nc']))

