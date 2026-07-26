function adcp_process(klist,constraints_try,varargin)
%
% to run with all available constraints:
% run_proc_ladcp(stn,{'GPS' 'BT' 'SADCP'})
% if sadcp not available
% run_proc_ladcp(stn,{'GPS' 'BT'})
%
% to run each intermediate step (gps-only, gps+bt, then all 3):
% run_proc_ladcp(stn,{'GPS' 'BT' 'SADCP'},'incr')
%
% to also run dl and ul separately with gps constraints:
% run_proc_ladcp(stn,{'GPS' 'BT' 'SADCP'},'incr','sepdlul')
%
% or to run all constraints but also separate dl and ul:
% run_proc_ladcp(stn,{'GPS' 'BT' 'SADCP'},'','sepdlul')
%
%wrapper script for LADCP IX processing with different constraints
%always process up and downlooker separately to check beam
%quality***(though does this work for really shallow cast?)
%but only process together if it's deep enough***, otherwise DL is version
%of record

%add option to call mvad_station_av***

if nargin>4 && strcmp(varargin{3},'pause')
    dopause = 1;
else
    dopause = 0;
end

if isempty(which('getinv'))
    error('LADCP processing functions not on path; try running m_setup again')
end
cdir = pwd;
m_common; mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
if isfield(MEXEC_G,'mexec_shell_scripts')
    css = fullfile(MEXEC_G.mexec_shell_scripts,'lad_syncscript');
    if exist(css,'file'); dosync = 1; else; dosync = 0; end
end

klist = klist(:)';
for no = 1:14
    cfg0.figh(no) = figure(no);
end
doincr = 0; dosep = 0;
if nargin>2
    if strcmp(varargin{1},'incr')
        doincr = 1;
    end
    if nargin>3
        if strcmp(varargin{2},'sepdlul')
            dosep = 1;
        end
    end
end

for stn = klist

    % configuration defaults and cruise-specific options
    cfg = cfg0;
    opt1 = 'ctd_proc'; opt2 = 'minit'; get_cropt
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
    if dosync; system(css); dosync = 0; end

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
    cfg.constraints = constraints_try;
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
        cfg.orient = 'DLUL'; process_cast_cfgstr(stn, cfg); lpause(cfg, dopause);
    elseif isdl
        cfg.orient = 'DL'; process_cast_cfgstr(stn, cfg); lpause(cfg, dopause);
    else
        cfg.orient = 'UL'; process_cast_cfgstr(stn, cfg); lpause(cfg, dopause);
    end

    if doincr
        %now run with one less
        cfg.constraints(end) = [];
        if isfield(cfg,'SADCP_inst') && ~sum(ismember(cfg.constraints,'SADCP'))
            cfg = rmfield(cfg,'SADCP_inst');
            cfg.f = rmfield(cfg.f,'sadcp');
        end
        while ~isempty(cfg.constraints)
            process_cast_cfgstr(stn, cfg); lpause(cfg,dopause)
            cfg.constraints(end) = [];
        end
    end

    if dosep && isdl && isul
        %run last (least) set of constraints with dl and ul separately (if
        %both aren't present for this cast, this is unnecessary)
        cfg.orient = 'DL'; process_cast_cfgstr(stn, cfg); lpause(cfg, dopause);
        cfg.orient = 'UL'; process_cast_cfgstr(stn, cfg); lpause(cfg, dopause);
    end

end
cd(cdir)

function lpause(cfg, dopause)
if dopause
    fprintf(1,['inspect ' cfg.orient '_%s' '/ plots, any key to continue\n'],cell2mat(cfg.constraints));
    pause
end

