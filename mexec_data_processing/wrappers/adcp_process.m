function adcp_process(klist, types, varargin)
%
% wrapper script for processing LADCP and/or SADCP for stations in klist
% types is {'ladcp', 'sadcp'} or a subset
% optional arguments are parameter-value pairs:
%   'ladcp_constraints' is {'GPS', 'BT', 'SADCP'} (default) or a subset
%   'ladcp_pause' is 0 (default) or 1 to pause after each version of ladcp
%     processing
%   'ladcp_incr' is 1 (default) to apply each constraint incrementally
%     (i.e. in example above run process_cast with 'GPS', with 'GPS' &
%     'BT', and with 'GPS', 'BT', & 'SADCP')
%    'ladcp_sepud' is 1 (default) to process the up- and down-looker
%      separately *as well as together* (ignored if there is only one
%      instrument)
%
%always process up and downlooker separately to check beam
%quality***(though does this work for really shallow cast?)
%but only process together if it's deep enough***, otherwise DL is version
%of record

%add option to call mvad_station_av***

m_common
ladcp_pause = 0;
ladcp_constraints = {'GPS','BT','SADCP'};
ladcp_incr = 1;
ladcp_sepud = 1;
for no = 1:2:nargin-2
    eval([varargin{no} ' = varargin{no+1};'])
end

%first vmadcp
if ismember('sadcp',types)


end


%then ladcp
if ismember('ladcp',types) 
    if isempty(which('getinv'))
        error('LADCP processing functions not on path; try running m_setup again')
    end

    cdir = pwd;
    if isfield(MEXEC_G,'mexec_shell_scripts')
        css = fullfile(MEXEC_G.mexec_shell_scripts,'data_to_ws','lad_syncscript.sh');
        if exist(css,'file'); dosync = 1; else; dosync = 0; end
    end

    klist = klist(:)';
    for no = 1:14
        cfg0.figh(no) = figure(no);
    end

    for stn = klist

        % configuration defaults and cruise-specific options
        cfg = cfg0;
        opt1 = 'setup'; opt2 = 'minit'; get_cropt
        opt1 = 'setup'; opt2 = 'procfiles'; get_cropt
        cfg.stnstr = stn_string;
        cfg.p.cruise_id = mcruise;
        cfg.p.ladcp_station = stnlocal;
        if exist('shortcasts','var') && ismember(stnlocal,shortcasts)
            cfg.p.btrk_mode = 0;
            cfg.p.getdepth = 1;
            couldbt = 0;
        else
            couldbt = 1;
            cfg.p.btrk_mode = 2;
            %cfg.p.btrk_ts = 30;
        end
        opt1 = 'adcp_proc'; get_cropt %cfg and set pattern for down- and up-looker files
        infiled = fullfile(cfg.rawdir,cfg.dnpat);
        infileu = fullfile(cfg.rawdir,cfg.uppat);
        %stn = stnlocal;
        % first sync (if lad_syncscript found) -- just once per call
        if dosync; system(['bash ' css]); dosync = 0; end

        % find out which raw files we have
        if isul
            if isempty(dir(infileu))
                warning('opt_%s says there should be an uplooker but file\n %s\n not found; maybe not yet synced?',mcruise,infileu)
                isul = 0;
            end
        end
        if isempty(dir(infiled))
            warning('no downlooker file %s\n maybe not yet synced?',infiled)
            isdl = 0;
            couldbt = 0;
        else
            isdl = 1;
        end
        if ~isdl && ~isul; continue; end

        %limit constraints
        cfg.constraints = ladcp_constraints;
        if ~isdl || ~couldbt
            cfg.constraints = setdiff(cfg.constraints,'BT');
        end
        if ~isfield(cfg.f,'sadcp') || ~exist(cfg.f.sadcp,'file')
            cfg.constraints = setdiff(cfg.constraints,'SADCP');
        else
            cfg.SADCP_inst = SADCP_inst;
        end

        %first run with all
        if isul && isdl
            cfg.orient = 'DLUL'; process_cast_cfgstr(stn, cfg); lpause(cfg, ladcp_pause);
        elseif isdl
            cfg.orient = 'DL'; process_cast_cfgstr(stn, cfg); lpause(cfg, ladcp_pause);
        else
            cfg.orient = 'UL'; process_cast_cfgstr(stn, cfg); lpause(cfg, ladcp_pause);
        end

        if ladcp_incr
            %now run with one less
            cfg.constraints(end) = [];
            if isfield(cfg,'SADCP_inst') && ~sum(ismember(cfg.constraints,'SADCP'))
                cfg = rmfield(cfg,'SADCP_inst');
                cfg.f = rmfield(cfg.f,'sadcp');
            end
            while ~isempty(cfg.constraints)
                process_cast_cfgstr(stn, cfg); lpause(cfg,ladcp_pause)
                cfg.constraints(end) = [];
            end
        end

        if ladcp_sepud && isdl && isul
            %run last (least) set of constraints with dl and ul separately (if
            %both aren't present for this cast, this is unnecessary)
            cfg.orient = 'DL'; process_cast_cfgstr(stn, cfg); lpause(cfg, ladcp_pause);
            cfg.orient = 'UL'; process_cast_cfgstr(stn, cfg); lpause(cfg, ladcp_pause);
        end

    end
    cd(cdir)
end

function lpause(cfg, ladcp_pause)
if ladcp_pause
    fprintf(1,['inspect ' cfg.orient '_%s' '/ plots, any key to continue\n'],cell2mat(cfg.constraints));
    pause
end

