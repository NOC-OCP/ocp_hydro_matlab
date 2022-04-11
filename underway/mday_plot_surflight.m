function pdf = mday_plot(day)
% function mday_plot(day)
%
% Function to spew out all daily plots of surface light data.
% (pressure, PAR(port), PAR(starboard), TIR(port), TIR(starboard) )
%
% where PAR = Photosynthetically Active Radiation
%       TIR = Total Incoming Radiation
%
% NB: need to copy '_raw.nc' files to '_edit.nc' files
% (or edit daystring below)
%
% Last updated: HP 06/01/10

cruise = 'di346';

daystr = sprintf('%03d',day);
ext = '_edit' % or 'raw'

m_setup

% met data plot

%%%% press 
%%%% ppar
%%%% spar
%%%% ptir
%%%% stir

%% Generic settings
pdf.time_var='time'
pdf.xlist='time'
pdf.plotsize=[14,6]
pdf.time_scale=3

pdf.plotorg=[5,11]
pdf.ylist='press'
pdf.yax=[990 1040]
pdf=mplotxy(pdf,[MEXEC_G.mexec_data_root '/met/surflight/met_light_' cruise '_d'...
                                            daystr ext '.nc']);

pdf.plotorg=[5 11]
pdf.ylist='ppar'
pdf.yax=[-100 1000]
pdf=mplotxy(pdf,[MEXEC_G.mexec_data_root '/met/surflight/met_light_' cruise '_d'...
                                            daystr ext '.nc']);
 
pdf.newfigure='none'
pdf.plotorg=[22 11]
pdf.ylist='spar'
pdf.yax=[-100 1000]
pdf=mplotxy(pdf,[MEXEC_G.mexec_data_root '/met/surflight/met_light_' cruise '_d'...
                                            daystr ext '.nc']);

pdf.newfigure='none'
pdf.plotorg=[5 2]
pdf.ylist='ptir'
pdf.yax=[-100 1000]
pdf=mplotxy(pdf,[MEXEC_G.mexec_data_root '/met/surflight/met_light_' cruise '_d' ...
                                            daystr ext '.nc']);

pdf.newfigure='none'
pdf.plotorg=[22 2]
pdf.ylist='stir'
pdf.yax=[-100 1000]
pdf=mplotxy(pdf,[MEXEC_G.mexec_data_root '/met/surflight/met_light_' cruise '_d'...
                                            daystr ext '.nc'])
