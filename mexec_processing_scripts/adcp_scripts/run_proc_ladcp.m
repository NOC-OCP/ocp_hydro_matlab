function run_proc_ladcp(klist,varargin)
%
% to run all processing versions (with available constraints):
% run_proc_ladcp(stn)
%
% to run only dlul_gps_bt_sadcp: 
% run_proc_ladcp(stn,'sadcp')
%
%wrapper script for LADCP IX processing with different constraints
%always process up and downlooker separately to check beam
%quality***(though does this work for really shallow cast?)
%but only process together if it's deep enough***, otherwise DL is version
%of record


if isempty(which('getinv'))
    error('LADCP processing functions not on path; try running m_setup again')
end
cdir = pwd;
m_common; mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
if isfield(MEXEC_G,'mexec_shell_scripts')
    css = fullfile(MEXEC_G.mexec_shell_scripts,'lad_syncscript');
    if exist(css,'file'); dosync = 1; else; dosync = 0; end
end
constraints_try = {{'GPS'}; {'GPS' 'BT'}; {'GPS' 'BT' 'SADCP'}};
if ~isempty(varargin) && strcmp(varargin{1},'sadcp-only')
    constraints_try = constraints_try(end);
end

klist = klist(:)';
for no = 1:14
    cfg0.figh(no) = figure(no);
end

for stn = 1:length(klist)

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
    cfg.p.magdec_source = 1;
    %cfg.p.edit_mask_dn_bins = 1;
    %cfg.p.edit_mask_up_bins = 1;
    cfg.p.orig = 0; % save original data or not
    isul = 1; %is there an uplooker? process it first on its own
    cfg.rawdir = fullfile(mgetdir('ladcp'),'rawdata',cfg.stnstr);
    cfg.pdir_root = fullfile(mgetdir('ladcp'),'ix');
    cfg.p.ambiguity = 4.0; %this one is not used?
    %cfg.p.vlim = 4.0; %this one is***require setting in opt_cruise
    %SADCP, if it's been processed and output to file for ladcp
    %***set type, as well as inst, in opt_cruise?opt1 = 'outputs'; opt2 = 'ladcp'; get_cropt
    opt1 = 'outputs'; opt2 = 'ladcp'; get_cropt %cfg.f
    opt1 = 'ladcp_proc'; get_cropt %required to set pattern for down- and up-looker files
    infiled = fullfile(cfg.rawdir,cfg.dnpat);
    infileu = fullfile(cfg.rawdir,cfg.uppat);
    dopause = 0;
    stn = stnlocal;
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

    for cno = 1:length(constraints_try)
        cfg.constraints = constraints_try{cno};
        if isscalar(cfg.constraints)
            %process DL and UL separately, if possible, just for the
            %nav+pressure (GPS) constraint
            if isdl
                cfg.orient = 'DL'; process_cast_cfgstr(stn, cfg); lpause(cfg,dopause);
            end
            if isul
                cfg.orient = 'UL'; process_cast_cfgstr(stn, cfg); lpause(cfg,dopause);
            end
        end
        if ismember({'BT'},cfg.constraints) && ~couldbt
            if length(cfg.constraints)>2
                cfg.constraints = setdiff(cfg.constraints,{'BT'}); %GPS SADCP
            else
                continue
            end
        end
        if ismember({'SADCP'},cfg.constraints)
            if exist(sfile,'file')
                cfg.f.sadcp = sfile;
                cfg.SADCP_inst = 'os75nb';
            else
                continue
            end
        end
        %for other constraints, ideally process together, otherwise DL
        %only, otherwise UL only
        if isul && isdl
            cfg.orient = 'DLUL'; process_cast_cfgstr(stn, cfg); lpause(cfg,dopause);
        elseif isdl
            cfg.orient = 'DL'; process_cast_cfgstr(stn, cfg); lpause(cfg,dopause);
        else
            cfg.orient = 'UL'; process_cast_cfgstr(stn, cfg); lpause(cfg,dopause);
        end

    end

end
cd(cdir)

function lpause(cfg,dopause)
            if dopause
                fprintf(1,['inspect ' cfg.orient '_%s' '/ plots, any key to continue\n'],cfg.constraints{:});
                pause
            end

