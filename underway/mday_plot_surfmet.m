function pdf = mday_plot(day)
% function mday_plot(day)
%
% Function to spew out all the daily plots of surface meteorological data.
% (wind speed, wind direction, temperature, humidity)
%
% NB: need to copy '_raw.nc' files to '_edit.nc' files
% (or edit daystring below)
%
% Last updated: HP 04/01/10

cruise = 'di368'

today = sprintf('%02d',day);
tomorrow = sprintf('%02d',day+1);
daystr = sprintf('%03d',day);
ext = '_edit' % or 'raw'
ext = '_raw' % or 'raw'

m_setup

% met data plot

%% Generic settings
pdf.time_var='time'
pdf.xlist='time'
pdf.plotsize=[9,6]
pdf.time_scale=3
pdf.xax = [0 24];
pdf.startdc = [day 0 0 0];
pdf.stopdc = [day+1 0 0 0];


pdf.plotorg=[4,12]
pdf.ylist='humid'
pdf.yax=[20 100]
% pdf.ntick = [25 10]
pdf.ntick = [12 10]
pdf=mplotxy(pdf,[MEXEC_G.mexec_data_root '/met/surfmet/met_' cruise '_d' daystr...
                                 ext '.nc'])


pdf.ylist='airtemp'
pdf.yax=[10 30]
pdf.newfigure='none'
pdf.plotorg=[17,12]
pdf=mplotxy(pdf,[MEXEC_G.mexec_data_root '/met/surfmet/met_' cruise '_d' daystr... 
                                         ext '.nc'])

pdf.ylist='speed'
pdf.yax=[-1 29]
pdf.newfigure='none'
pdf.plotorg=[4,3]
pdf=mplotxy(pdf,[MEXEC_G.mexec_data_root '/met/surfmet/met_' cruise '_d' daystr ...
                                          ext '.nc'])

pdf.ylist='direct'
pdf.yax=[0 360]
pdf.newfigure='none'
pdf.plotorg=[17,3]
pdf.symbols = {'+'}
pdf.styles = {' '}
pdf=mplotxy(pdf,[MEXEC_G.mexec_data_root '/met/surfmet/met_' cruise '_d' daystr  ...
                                          ext '.nc'])

