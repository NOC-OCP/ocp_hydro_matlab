function params = mout_columns_defaults(params)
% params = mout_columns_defaults(params)
%
% set some parameters for writting to csv
% for bodc and exch types, some user-supplied settings (in input arguments)
% may be overwritten, but generally the user-supplied settings will be used
% where available, and defaults set below otherwise

m_common
if ~isfield(params,'vars_exclude'); params.vars_exclude = {}; end
opt1 = 'outputs'; opt2 = params.out; get_cropt %vars_exclude, header, etc.

% defaults about header and footer
if ~isfield(params,'autoheader')
    if strcmp(params.out,'mstar')
        params.autoheader = 1;
    else
        params.autoheader = 0;
    end
end
switch params.out
    case 'exch'
        params.footer = 'END_DATA';
        %params.varsh***
    case 'bodc'
        params.varsh = {};
    case 'mstar'
        if ~isfield(params,'varsh')
            params.varsh = {'mstar_string', '%s', ' '
                'dataname', '%s', ' '
                'version', '%d', ' '
                'platform_type', '%s', ' '
                'platform_identifier', '%s', ' '
                'platform_number', '%s', ' '
                'water_depth_metres', '%d', ' '
                'latitude', '%9.5f', ' '
                'longitude', '%9.5f', ' '
                'comment', '%s', ' '
                'last_update_string', '%s', ' '};
            params.varsh = params.varsh(:,[1 3 1 2]);
            if strcmp(params.in,'sam')
                %no header depth, lat, lon for multi-station file
                params.varsh = params.varsh([1:6 10:11],:);
            end
        end
end

% defaults (or requirements) about variables and units
[exvars, varsh] = m_exch_vars_list(params.in);
exvars = exvars(:,[3 1 2 4]); %mstar name, exch name, exch units, format string
if ~isempty(params.vars_exclude)
    exvars = exvars(~ismember(exvars(:,1),vars_exclude),:); %mstar name or exch name?
end
switch params.out
    case 'exch'
        params.varsh = varsh;
        for no = 1:size(vars_rename,1)
            m = strcmp(vars_rename{no,1},params.vars_units(:,1));
            if sum(m); params.vars_units{m,1} = vars_rename{no,2}; end
            vars_rename{no,1} = [vars_rename{no,1} '_FLAG_W'];
            m = strcmp(vars_rename{no,1},params.vars_units(:,1));
            if sum(m); params.vars_units{m,1} = vars_rename{no,2}; end
        end
        if strcmp(params.in,'sam')
            params.extras.expocode = expocode;
            params.extras.sect_id = sect_id;
            params.extras.castno = 1;
        else
            params.extrah.expocode = expocode;
            params.extrah.sect_id = sect_id;
            params.extrah.castno = 1;
            params.header = [params.header; sprintf('%s %d', 'NUMBER_HEADERS = ', size(params.varsh,1)+1)];
        end
        params.sep = ', ';
    case 'bodc'
        params.datetimeform = 'dd/mm/yy HH:MM';
        params.sep = ', ';
        params.extras.blank = ' ';
        params.vars_units = {'statnum', 'SiteID', ' ', '%3d'
            'datetime', 'Start Date (UTC)', '[dd/mm/yyyy hh:mm]', '%s'
            'blank', 'End Date (UTC)', '[dd/mm/yy hh:mm]', '%s'
            'ulatitude', 'Start Latitude', '[+N -S] 3-decimal places', '%5.3f'
            'ulongitude', 'Start Longitude', '[+E -W] 3-decimal places', '%6.3f'
            'blank', 'End Latitude', '[+N -S] 3-decimal places', '%5.3f'
            'blank', 'End Longitude', '[+E -W] 3-decimal places', '%6.3f'
            'stndepth', 'Water Depth', 'm', '%4.1f'
            'blank', 'EventID', ' ', '%s'
            'niskin', 'SampleID/Bottle Reference', ' ', '%d'
            'udepth', 'Sample Depth', 'm', '%4.0f'
            'position', 'Rosette Position/Bottle Number', ' ', '%d'
            'blank', 'Bottle Firing Sequence', ' ', '%s'
            'niskin_flag', 'Niskin Bottle Flag', ' ', '%d'
            };
        ii = find(strcmp('CTDPRS',exvars(:,2))); %everything before this is exchange-format headers
        for no = ii:size(exvars,1)
            if ~contains(exvars(no,1),'flag')
                %flu = 'woce_4.9'; if contains(exvars(no,1),'niskin'); flu = 'woce_4.8'; end
                flu = ' '; 
                f = {[exvars{no,1} '_flag'], [exvars{no,2} ' Flag'], flu, '%d'};
                s = {'blank', [exvars{no,2} ' Standard Deviation'], exvars{no,3}, '%s'};
                params.vars_units = [params.vars_units; exvars(no,:); s; f];
            end
        end
        params.lastblank = 0;
    case 'mstar'
        params.sep = ', ';
end

% defaults about which stations to use
if ~isfield(params,'stnlist')
    switch params.in
        case 'sam'
            params.stnlist = -1; %all come from sam_all file
        case 'ctd'
            %all available stations
            d = dir(fullfile(mgetdir(params.in),sprintf('%s_%s_*%s.nc',params.in,mcruise,params.suf)));
            d = replace({d.name},[params.in '_' mcruise '_'],'');
            d = cell2mat(d(:));
            params.stnlist = str2num(d(:,1:3))';
    end
end
params.stnlist = params.stnlist;

% defaults about gridding
if strcmp(params.in,'ctd')
    if isfield(params,'dobin') && params.dobin
        params.suf = '_24hz';
    else
        params.dobin = 0;
    end
    if strcmp(params.in,'ctd') && ~isfield(params,'bin_size')
        params.bin_size = 2; params.bin_units = 'dbar';
    end
    if ~isfield(params,'suf')
        % use the input file already gridded as specified -- but don't
        % overwrite input, in case we want to redo the gridding
        if params.bin_size==2 && strcmp(params.bin_units,'dbar')
            params.suf = '_2db';
        elseif params.bin_size==1 && strcmp(params.bin_units,'hz')
            params.suf = '_psal';
        else
            params.suf = '_24hz';
            if params.bin_size~=24 || ~strcmp(params.bin_units,'hz')
                params.dobin = 1; %will need to regrid
            end
        end
    end
    if params.dobin
        switch params.bin_units
            case 'hz'
                params.gvar = 'time';
                if ~isfield(params,'gmethod')
                    params.gmethod = 'meannum';
                end
                if ~isfield(params,'gopts')
                    params.gopts.num = params.bin_size*24;
                    params.gopts.grid_ends = [0 0];
                end
            case {'dbar','m'}
                if strcmp(params.bin_units,'m')
                    params.gvar = 'depth';
                else
                    params.gvar = 'press';
                end
                if ~isfield(params,'xg')
                    params.xg = [0:params.bin_size:1e4]';
                end
                if ~isfield(params,'gopts')
                    params.gopts.grid_ends = [0 0];
                end
        end
    end
end
if params.autoheader
    if params.dobin
        params.header = [params.header; sprintf('(averaged to %d %s from %s.nc file',params.bin_size,params.bin_units,params.suf)];
    else
        params.header = [params.header; sprintf('from %s.nc file',params.suf)];
    end
end

% defaults about filenames
if ~isfield(params,'ddir')
    params.ddir = mgetdir(params.in);
end
switch params.out
    case 'exch'
        if strcmp(params.in,'sam')
            params.csvpre = sprintf('%s_hy1',expocode);
            params.csvpost = '';
        else
            params.csvpre = sprintf('%s_00',expocode);
            params.csvpost = '_0001_ct1';
        end
    case {'bodc','mstar'}
        if ~isfield(params,'csvpre')
            params.csvpre = sprintf('%s_ctd_samples',mcruise);
        end
        if ~isfield(params,'csvpost')
            params.csvpost = '';
        end
end

