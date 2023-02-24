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
opt1 = 'castpars'; opt2 = 'cast_groups'; get_cropt
cfg.stnstr = stn_string;
clear p
p.cruise_id = mcruise;
p.ladcp_station = stnlocal;
if ismember(stnlocal,shortcasts)
    p.btrk_mode = 0;
    p.getdepth = 1;
else
    p.btrk_mode = 2;
    %p.btrk_ts = 30;
end
p.magdec_source = 1;
%p.edit_mask_dn_bins = 1;
%p.edit_mask_up_bins = 1;
p.orig = 0; % save original data or not
isul = 1;
cfg.p = p;
cfg.pdir_root = fullfile(mgetdir('ladcp'),'ix');
cfg.rawdir = fullfile(cfg.pdir_root,'raw',cfg.stnstr);
opt1 = 'outputs'; opt2 = 'ladcp'; get_cropt
opt1 = 'ladcp_proc'; get_cropt
cfg.f = f;
dopause = 0;
stn = stnlocal;

%first, only cast nav and pressure time series as constraints (from mout_1hzasc)
cfg.constraints = {'GPS'};

%UL
if isul
    infileu = fullfile(mgetdir('M_IX'), 'raw', cfg.stnstr, sprintf('%sUL000.000',cfg.stnstr));
    if ~exist(infileu,'file')
        warning(['no uplooker file ' infileu ' found'])
        if dopause
            warning(['try sync again if you expect one; return to continue'])
            pause
        end
    end
    if exist(infileu,'file')
        cfg.orient = 'UL'; process_cast_cfgstr(stn, cfg);
        if dopause
            fprintf(1,['inspect ' cfg.orient '_%s' '/ plots, any key to continue\n'],cfg.constraints{:});
            pause
        end
    else
        isul = 0;
    end
end

infiled = fullfile(mgetdir('M_IX'), 'raw', cfg.stnstr, sprintf('%sDL000.000',cfg.stnstr));
if ~exist(infiled,'file')
    warning(['no downlooker file ' infiled ' found; try sync again if you expect one; return to continue'])
    if dopause
        pause
    end
end
if exist(infiled,'file')

    %DL
    try
        cfg.orient = 'DL'; process_cast_cfgstr(stn, cfg);
        if dopause
            fprintf(1,['inspect ' cfg.orient '_%s' '/ plots, any key to continue\n'],cfg.constraints{:});
            pause
        end
        dlalone = 1;
    catch me
        if strcmp('MATLAB:colon:nonFiniteEndpoint',me.identifier) && strcmp('geterr',me.stack(1).name)
            dlalone = 0;
            warning('cast too shallow/bottom stop too long to have any good data in deepest ensemble');
            warning(['geterr would fail to find btmi on line ' me.stack(1).line '; not processing downlooker alone']);
        else
            throw(me)
        end
    end

    %DLUL
    if isul
        cfg.orient = 'DLUL'; process_cast_cfgstr(stn, cfg);
        if dopause
            fprintf(1,['inspect ' cfg.orient '_%s' '/ plots, any key to continue\n'],cfg.constraints{:});
            pause
        end
    end

end

%also bottom tracking, if cast was full-depth
if ~ismember(stn, shortcasts)
    cfg.constraints = [cfg.constraints 'BT'];
    if dlalone
        cfg.orient = 'DL'; process_cast_cfgstr(stn, cfg);
        if dopause
            fprintf(1,['inspect ' cfg.orient '_%s' '/ plots, any key to continue\n'],cfg.constraints{:});
            pause
        end
    end
    if isul
        cfg.orient = 'DLUL'; process_cast_cfgstr(stn, cfg);
        if dopause
            fprintf(1,['inspect ' cfg.orient '_%s' '/ plots, any key to continue\n'],cfg.constraints{:});
            pause
        end
    end
end

if 0
    %SADCP, if it's been processed and output to file for ladcp
    sfile = fullfile(mgetdir('M_LADCP'), 'SADCP', sprintf('os75nb_%s_%03d_forladcp.mat',mcruise,stn));
    if exist(sfile,'file')
        cfg.constraints = [cfg.constraints 'SADCP'];
        cfg.SADCP_inst = 'os75nb';
        if isul
            cfg.orient = 'DLUL'; process_cast_cfgstr(stn, cfg);
            if dopause
                fprintf(1,['inspect ' cfg.orient '_%s' '/ plots, any key to continue\n'],cfg.constraints{:});
                pause
            end
        elseif dlalone
            cfg.orient = 'DL'; process_cast_cfgstr(stn, cfg);
            if dopause
                fprintf(1,['inspect ' cfg.orient '_%s' '/ plots, any key to continue\n'],cfg.constraints{:});
                pause
            end
        end
    end
end

cd(cdir)

%load ladcp/ix/UL_GPS/processed/073/073; dr73u = dr;
%plot(dr73u.u_do,-dr73u.z,dr73u.u_up,-dr73u.z,dr73u.u_shear_method,-dr73u.z)
%xlim([-1 1]*.2)

