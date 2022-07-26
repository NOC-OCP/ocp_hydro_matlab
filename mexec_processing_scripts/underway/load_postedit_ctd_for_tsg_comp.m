% Load in CTD data shallower than set depth () from all stations available
% and convert data format to be comparable with tsg data

root_ctd = mgetdir('M_CTD');

% generate array of all stations completed to date
stn2date_all

% check that the file exists for each of these stations (IE the data has
% had basic CTD data processing scripts run to remove start/end and spikes)

for stni = stn2date_all
    % load in data from each CTD station 
    
    % trim this data to only include data < set depth 
    max_comp_depth = 10 %m

    % simply to 2d array with only time and salinity

    % append into structure/array/dict with all stations


end


