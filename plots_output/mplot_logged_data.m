function stat = mplot_logged_data(file,plot_list)
% stat = function plot_logged_data(file)
%
% Function to provide a quick and dirty plot of the data in a
% netcdf file. 
%
% Written by dham on D344

% Executing a unix find command to produce a full path to a
% matching file.
m_setup;

[stat, path]=system(['find ' MEXEC_G.mexec_data_root ' -name ' file]);

path=strtrim(path)

% Grab the full list of datasets and other info from the file.
info = nc_info(strtrim(path));

for i=1:size(plot_list)
  x=nc_varget(path, plot_list(i).x);
  y=nc_varget(path, plot_list(i).y);
  plot (x,y)
  xlabel('plot_list(i).x')
  ylabel('plot_list(i).y')
end
