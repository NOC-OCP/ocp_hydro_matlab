% script called by (LDEO_IX) process_cast and begin_processing_step
% begin_processing_step evaluates eval_expr, then calls this, then
% evaluates eval_expr again...

m_common
% use opt_cruise file to set all parameters?
opt1 = 'adcp_proc'; opt2 = 'ladcp_files'; run(MEXEC_G.opt_cruise)

% file and constraints settings (set the first time they are needed)
% to determine which constraints and which instruments are being processed,
% uses f.subdir which is passed to process_cast in 4th input argument 
% eval_expr: process_cast(stn, 1, 0, ['f.subdir = ''' subdir ''';'])
if exist('f','var') && isfield(f,'subdir') && (~isfield(f,'res') || length(f.res)<2)
    %ladcp input(s)
    s = strsplit(f.subdir,'_');
    list_ladcpfiles
    switch s{1}
        case 'UL'
            f.ladcpdo = fullfile(rawdir,infileu.name);
        case 'DL'
            f.ladcpdo = fullfile(rawdir,infiled.name);
        case 'DLUL'
            f.ladcpdo = fullfile(rawdir,infiled.name);
            f.ladcpup = fullfile(rawdir,infileu.name);
    end
    if ismember('BT',s(2:end))
        ps.botfac = 1;
    else
        ps.botfac = 0;
    end
    if ismember('SADCP',s(2:end))
        opt1 = 'adcp_proc'; opt2 = 'sadcp_stnav'; run(MEXEC_G.opt_cruise)
        opt1 = 'setup'; opt2 = 'pfiles'; run(MEXEC_G.mcruise)
        f.sadcp = pfiles.sadcp_stnav;
        ps.sadcpfac = 1;
    else
        ps.sadcpfac = 0;
    end
    opt1 = 'setup'; opt2 = 'station_lists'; run(MEXEC_G.opt_cruise)
    if isfield(stnlists, 'stns_short') && ismember(stn, stnlists.stns_short)
        %cast was not full depth
        p.btrk_mode = 0;
        p.getdepth = 1;
    elseif ps.botfac
        p.btrk_mode = 2;
        %p.btrk_ts = 30;
    end
    %ctd and nav data
    f0 = ctdnav_asc_for_ladcp(stn);
    fn = fieldnames(f0);
    for no = 1:length(fn)
        f.(fn{no}) = f0.(fn{no});
    end

    %ladcp processed
    f.res = fullfile(pdir, f.subdir, stn_string);
    if ~exist(fileparts(f.res),'dir')
        mkdir(fullfile(pdir, f.subdir))
        mfixperms(fullfile(pdir, f.subdir),'dir');
    end

    %processing metadata/settings
    p.ladcp_station = stn_string;
    p.cruise_id = MEXEC_G.mcruise;
    p.name = sprintf('%s cast #%d (processing version %s)',p.cruise_id,p.ladcp_station,f.subdir);
    p.saveplot = [];
    p.saveplot_png = [];
    if ~isfield(p,'saveplot_pdf') || isempty(p.saveplot_pdf)
        p.saveplot_pdf	= [1:7 11:14];
        if ps.sadcpfac
            %figure about SADCP constraint
            f.sadcp
            p.saveplot_pdf = [p.saveplot_pdf 9];
        end
        if strcmp(s{1},'DLUL')
            %figures comparing down and uplooker data
            p.saveplot_pdf = [p.saveplot_pdf 8 10];
        end
        if contains(f.subdir,'BT')
            p.saveplot_pdf = [p.saveplot_pdf 13];
        end
    end
%5,6,10: super ensembles. 5,6 blank for ul_gps and dl_gps 
%10 blank for dlul_gps?
end
