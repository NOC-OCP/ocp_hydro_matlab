%wrapper script for LADCP IX processing with different constraints
%always process up and downlooker separately to check beam
%quality***(though does this work for really shallow cast?)
%but only process together if it's deep enough***, otherwise DL is version
%of record

mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
clear cfg
isul = 1; %set this to 0 if you don't have one***make cruise option

%only cast nav and pressure time series as constraints (from mout_1hzasc)
cfg.constraints = {'GPS'};

%UL
if isul
    infileu = sprintf('/local/users/pstar/cruise/data/ladcp/ix/raw/%03d/%03dUL000.000',stn,stn);
    if ~exist(infileu,'file')
        warning(['no uplooker file ' infileu ' found; try sync again if you expect one; return to continue'])
        pause
    end
    if exist(infileu,'file')
        cfg.orient = 'UL'; process_cast_cfgstr(stn, cfg);
    else
        isul = 0;
    end
end

infiled = sprintf('/local/users/pstar/cruise/data/ladcp/ix/raw/%03d/%03dDL000.000',stn,stn);
if ~exist(infiled,'file')
    warning(['no downlooker file ' infiled ' found; try sync again if you expect one; return to continue'])
    pause
end
if exist(infiled,'file')

    %DL
    try
        cfg.orient = 'DL'; process_cast_cfgstr(stn, cfg);
        dlalone = 1;
    catch me
        if strcmp('MATLAB:colon:nonFiniteEndpoint',me.identifier) & strcmp('geterr',me.stack(1).name)
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
    end
    
end

%also bottom tracking, if cast was full-depth
scriptname = 'castpars'; oopt = 'shortcasts'; get_cropt
if ~ismember(stn, shortcasts)
%     disp('inspect figures then any key to continue, adding BT as a constraint'); pause
    cfg.constraints = [cfg.constraints 'BT'];
    if dlalone
        cfg.orient = 'DL'; process_cast_cfgstr(stn, cfg);
    end
    if isul
        cfg.orient = 'DLUL'; process_cast_cfgstr(stn, cfg);
    end    
end

%SADCP, if it's been processed and output to file for ladcp
sfile = sprintf('%s/mproc/os75nb_%s_ctd_%03d_forladcp.mat',mgetdir('M_VMADCP'),mcruise,stn);
if exist(sfile,'file')
%     disp('inspect figures then any key to continue, adding SADCP as a constraint'); pause
    cfg.constraints = [cfg.constraints 'SADCP'];
    cfg.SADCP_inst = 'os75nb';
    if isul
        cfg.orient = 'DLUL'; process_cast_cfgstr(stn, cfg);
    elseif dlalone
        cfg.orient = 'DL'; process_cast_cfgstr(stn, cfg);
    end
end




%load ladcp/ix/UL_GPS/processed/073/073; dr73u = dr;
%plot(dr73u.u_do,-dr73u.z,dr73u.u_up,-dr73u.z,dr73u.u_shear_method,-dr73u.z)
%xlim([-1 1]*.2)

