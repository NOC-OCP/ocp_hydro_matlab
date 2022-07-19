function pdf = mday_plot_surftsg(day)
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

daystr = sprintf('%03d',day);
ext = '_edit' % or 'raw'

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

 pdf.ylist='cond'
 pdf.yax = [5.0 5.8]
 pdf.plotorg=[5 11]
 pdf=mplotxy(pdf,[MEXEC_G.mexec_data_root '/met/surftsg/met_tsg_' cruise '_d'...
                                    daystr ext '.nc'])
% 
 pdf.newfigure='none'
 pdf.ylist='fluo'
 pdf.yax=[0.0 0.2]
 pdf.plotorg=[22,11]
 pdf=mplotxy(pdf,[MEXEC_G.mexec_data_root '/met/surftsg/met_tsg_' cruise '_d'...
                                   daystr ext '.nc'])
% 
 pdf.newfigure='none'
 pdf.ylist='trans'
 pdf.yax=[0.0 5.0]
 pdf.plotorg=[5,2]
 pdf=mplotxy(pdf,[MEXEC_G.mexec_data_root '/met/surftsg/met_tsg_' cruise '_d'...
                                  daystr ext '.nc'])
%


% On Di346 temp_h is the temperature of the underway water 
% measured in the instrument housing (where conductivity is calculated)
% newfigure
 pdf.newfigure = 'p'
 pdf.ylist='temp_h'
 pdf.yax=[18 23]
 pdf.plotorg=[5,2]
 pdf=mplotxy(pdf,[MEXEC_G.mexec_data_root '/met/surftsg/met_tsg_' cruise '_d'...
                                  daystr ext '.nc'])

 
% On Di346 temp_r is the real (remote) SST
 pdf.newfigure = 'none'
 pdf.ylist='temp_r'
 pdf.yax=[18 23]
 pdf.plotorg=[22,2]
 pdf=mplotxy(pdf,[MEXEC_G.mexec_data_root '/met/surftsg/met_tsg_' cruise '_d'...
                                   daystr ext '.nc'])

