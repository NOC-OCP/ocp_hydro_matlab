function pdf = mday_plot(varargin)
% function mday_plot(day)
%
% Function to spew out all the daily plots of TSG data.
% (FSI tsg data logged in data/met/surftsg
%  Seabird tsg data logged in data/tsg/ on Di346)
%
% NB: need to copy '_raw.nc' files to '_edit.nc' files
% (or edit daystring below)
%
% Last updated: HP 07/01/10

cruise = 'di346';

if (length(varargin)==0)
  daystring='001'
else
  daystring=['d00' int2str(varargin{1}(1)) '_edit']
end

m_setup

%% Generic settings
                 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  TSG (Falmouth Scientific Inc)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%% Generic settings
pdf.time_var='time'
pdf.xlist='time'
pdf.plotsize=[14,6]
pdf.time_scale=3

 %pdf.ylist='salin'
 %pdf.yax=[25 40]
 pdf.ylist='cond'
 pdf.yax=[5.2 5.6]
 pdf.plotorg=[5 11]
 pdf=mplotxy(pdf,[MEXEC_G.MEXEC_DATA_ROOT '/tsg/tsg_' cruise '_' daystring '.nc'])
% 
 pdf.newfigure='none'
 pdf.ylist='sndspeed'
 pdf.yax=[1530 1540]
 pdf.plotorg=[22,11]
 pdf=mplotxy(pdf,[MEXEC_G.MEXEC_DATA_ROOT '/tsg/tsg_' cruise '_' daystring '.nc'])
% 
 pdf.newfigure='none'
 pdf.ylist='salin'
 pdf.yax=[36 37]
 pdf.plotorg=[5,2]
 pdf=mplotxy(pdf,[MEXEC_G.MEXEC_DATA_ROOT '/tsg/tsg_' cruise '_' daystring '.nc'])
%


% On Di346 temp_h is the temperature of the underway water 
% measured in the instrument housing (where conductivity is calculated)
% newfigure
 pdf.newfigure = 'p'
 pdf.ylist='temp_h'
 pdf.yax=[23 26]
 pdf.plotorg=[5,2]
 pdf=mplotxy(pdf,[MEXEC_G.MEXEC_DATA_ROOT '/tsg/tsg_' cruise '_' daystring '.nc'])

 
% On Di346 temp_r is the real (remote) SST
 pdf.newfigure = 'none'
 pdf.ylist='temp_r'
 pdf.yax=[23 26]
 pdf.plotorg=[22,2]
 pdf=mplotxy(pdf,[MEXEC_G.MEXEC_DATA_ROOT '/tsg/tsg_' cruise '_' daystring '.nc'])

