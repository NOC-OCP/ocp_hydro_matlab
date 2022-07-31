% Load in CTD data shallower than set depth () from all stations available
% and convert data format to be comparable with tsg data

if ~exist('root_ctd', 'var')
    root_ctd = mgetdir('M_CTD');
end 


% generate list of all station files processed to date
if ~exist('updownboth', 'var')
    prompt = 'Which cast would you like to use (up, down or both)?'
    updownboth = string(input(prompt))
end

if strcmp(updownboth,'up')
    ctd_infile_wc = m_add_nc(fullfile(root_ctd, ['ctd_' mcruise '*_2up']));
    ctd_infile_list = dir(ctd_infile_wc);
elseif strcmp(updownboth, 'down')
    ctd_infile_wc = m_add_nc(fullfile(root_ctd, ['ctd_' mcruise '*_2db']));
    ctd_infile_list = dir(ctd_infile_wc);
elseif strcmp(updownboth, 'both')
    ctd_infile_wc1 = m_add_nc(fullfile(root_ctd, ['ctd_' mcruise '*_2db']));
    ctd_infile_wc2 = m_add_nc(fullfile(root_ctd, ['ctd_' mcruise '*_2up']));
    ctd_infile_list = [dir(ctd_infile_wc1) dir(ctd_infile_wc2)];
else 
    %prompt = 'Which cast would you like to use (up, down or both)? Please select "up" OR "down" OR "both"'
    %updownboth = string(input(prompt))
    updownboth = 'down'
    fprintf(1, 'Setting updownboth to %s.', updownboth)
    ctd_infile_wc = m_add_nc(fullfile(root_ctd, ['ctd_' mcruise '*_2db']));
    ctd_infile_list = dir(ctd_infile_wc);

end

% ctd_infile_list = dir(ctd_infile_wc);

% set max depth of CTD cast desired
max_comp_depth = 10; %m
fprintf(1,'Max comparison depth is set to %s m. Change max_comp_depth to alter this. \n', max_comp_depth)


stn2date_proc = [];
ds_i_all = [];
ds_i_all_shallowest = [];
ds_i_all_5m = []; %specifically 5m as this is similar to TSG intake depth
% create emptry structure from any time info needed from nc attributes
ds_h_date_time_origin_jday = [];
ds_all_ind_start = 1;
ds_all_ind_end = 1;

for i=1:length(ctd_infile_list)
    ctd_infile_stni = ctd_infile_list(i).name;
    
    infilei = fullfile(root_ctd, ctd_infile_stni);
    
    % obtain station number string
    stni = extract(extract(infilei, '_'+digitsPattern(3)+'_'), digitsPattern(3));
    

    % check that the file exists for each of these stations (IE the data has
    % had basic CTD data processing scripts run to remove start/end and spikes)
    if exist(m_add_nc(infilei), 'file')
        stn2date_proc = [stn2date_proc stni];

        % load in data from each CTD station 
        [d, h] = mload(infilei, '/');
        
        % trim this data to only include data < set depth 
        suitable_depths_ind = find(d.depth<max_comp_depth);
        min_depth_ind = find(d.depth==min(d.depth));
        depth_ind_5m = find(abs(d.depth-5)==min(abs(d.depth-5))); %find measurement nearest 5m
        %realistically if you change this from 5 everything should work BUT
        %varname will be wrong

        % eventually want fnames to just be those relevant to salinity / lat /
        % lon / time / depth
        fnames = fieldnames(d);
        
        ds_i = [];
        ds_i_shallowest = [];
        ds_i_5m = [];
    
        for ii=1:length(fnames)
            f=fnames{ii};
            ds_i.(f) = d.(f)(suitable_depths_ind);
            ds_i_shallowest.(f) = d.(f)(min_depth_ind);
            ds_i_5m.(f) = d.(f)(depth_ind_5m);
        end
        
        % Calculate julian day 
        % something is going wrong with conversion from seconds to juldays
        % f time as decials all seem too small...
        ds_h_date_time_origin_jday_i = day(datetime(h.data_time_origin), 'dayofyear') + h.data_time_origin(4)/24+h.data_time_origin(5)/(24*60)+h.data_time_origin(6)/(24*60*60);
        ds_h_date_time_origin_jday = [ds_h_date_time_origin_jday, ds_h_date_time_origin_jday_i];

        if isfield(ds_i, 'time') % if ds_i_all has a time field)
            ds_i.time_jul = ds_i.time/(60*60*24) + ds_h_date_time_origin_jday_i;
            ds_i_shallowest.time_jul = ds_i_shallowest.time/(60*60*24) + ds_h_date_time_origin_jday_i;
            ds_i_5m.time_jul = ds_i_5m.time/(60*60*24) + ds_h_date_time_origin_jday_i;
        end


        % simplify to 2d array with only time and salinity??

        
        % append into structure/array/dict with all stations
        if i==1 
            for ii=1:length(fnames)
                f=fnames{ii};
                ds_i_all.(f)=[ds_i.(f)];
                ds_i_all_shallowest.(f) = [ds_i_shallowest.(f)];
                ds_i_all_5m.(f) = [ds_i_5m.(f)];
            end
            
            % add julian date field to structure
            ds_i_all.time_jul=[ds_i.time_jul];
            ds_i_all_shallowest.time_jul=[ds_i_shallowest.time_jul];
            ds_i_all_5m.time_jul=[ds_i_5m.time_jul];

        else 
            for ii=1:length(fnames)
                f=fnames{ii};
                ds_i_all.(f)=[ds_i_all.(f); ds_i.(f)];
                ds_i_all_shallowest.(f) = [ds_i_all_shallowest.(f); ds_i_shallowest.(f)];
                ds_i_all_5m.(f) = [ds_i_all_5m.(f); ds_i_5m.(f)];

            end
            % add julian date field to structure
            ds_i_all.time_jul=[ds_i_all.time_jul; ds_i.time_jul];
            ds_i_all_shallowest.time_jul=[ds_i_all_shallowest.time_jul; ds_i_shallowest.time_jul];
            ds_i_all_5m.time_jul=[ds_i_all_5m.time_jul; ds_i_5m.time_jul];

        end

    else 
        warning('File %s not found, skipping',infilei);
    end


end


