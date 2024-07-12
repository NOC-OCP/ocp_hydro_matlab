function run_proc_ladcp(stn,varargin)
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

clear cfg
opt1 = 'castpars'; opt2 = 'minit'; get_cropt
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
opt1 = 'outputs'; opt2 = 'ladcp'; get_cropt
opt1 = 'ladcp_proc'; get_cropt %required to set pattern for down- and up-looker files
infiled = fullfile(cfg.rawdir,cfg.dnpat);
infileu = fullfile(cfg.rawdir,cfg.uppat);
dopause = 0;
stn = stnlocal;

% first sync (if lad_syncscript found)
if isfield(MEXEC_G,'mexec_shell_scripts')
    css = fullfile(MEXEC_G.mexec_shell_scripts,'lad_syncscript');
    if exist(css,'file')
        system(css);
    end
end

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
else
    isdl = 1;
end

constraints_try = {'GPS' 'GPS_BT' 'GPS_BT_SADCP'};
if nargin>1 && strcmp(varargin{1},'sadcp-only')
    constraints_try = {'GPS_BT_SADCP'};
end

if sum(ismember(constraints_try,'GPS'))
    %first, only cast nav and pressure time series as constraints (from mout_1hzasc)
cfg.constraints = {'GPS'};
if isul
    cfg.orient = 'UL'; process_cast_cfgstr(stn, cfg);
    if dopause
        fprintf(1,['inspect ' cfg.orient '_%s' '/ plots, any key to continue\n'],cfg.constraints{:});
        pause
    end
end
if isdl
    cfg.orient = 'DL'; process_cast_cfgstr(stn, cfg);
    if dopause
        fprintf(1,['inspect ' cfg.orient '_%s' '/ plots, any key to continue\n'],cfg.constraints{:});
        pause
    end
    dlalone = 1;
%     if strcmp('MATLAB:colon:nonFiniteEndpoint',me.identifier) && strcmp('geterr',me.stack(1).name)
%         dlalone = 0;
%         warning('cast too shallow/bottom stop too long to have any good data in deepest ensemble');
%         warning(['geterr would fail to find btmi on line ' me.stack(1).line '; not processing downlooker alone']);
%     end
end

%DLUL
if isul && isdl
    cfg.orient = 'DLUL'; process_cast_cfgstr(stn, cfg);
    if dopause
        fprintf(1,['inspect ' cfg.orient '_%s' '/ plots, any key to continue\n'],cfg.constraints{:});
        pause
    end
end

%also bottom tracking, if cast was full-depth (and had down-looker)
if couldbt
    cfg.constraints = [cfg.constraints 'BT'];
    if isul && isdl
        cfg.orient = 'DLUL'; process_cast_cfgstr(stn, cfg);
        if dopause
            fprintf(1,['inspect ' cfg.orient '_%s' '/ plots, any key to continue\n'],cfg.constraints{:});
            pause
        end
    elseif isdl && dlalone
        cfg.orient = 'DL'; process_cast_cfgstr(stn, cfg);
        if dopause
            fprintf(1,['inspect ' cfg.orient '_%s' '/ plots, any key to continue\n'],cfg.constraints{:});
            pause
        end
    end
end
else
    cfg.orient = 'DLUL'; cfg.constraints = {'GPS' 'BT'};
end

%SADCP, if it's been processed and output to file for ladcp
spath = fullfile(mgetdir('M_LADCP'), 'ix', 'SADCP');
sfile = fullfile(spath, sprintf('os75nb_%s_ctd_%03d_forladcp.mat',mcruise,stn)); 
%***set type, as well as inst, in opt_cruise?
if exist(sfile,'file')
    cfg.f.sadcp = sfile;
    cfg.constraints = [cfg.constraints 'SADCP'];
    cfg.SADCP_inst = 'os75nb';
    process_cast_cfgstr(stn, cfg);
    if dopause
        fprintf(1,['inspect ' cfg.orient '_%s' '/ plots, any key to continue\n'],cfg.constraints{:});
        pause
    end
end

cd(cdir)
