function mday_02_merge_av(datatype, ydays, mtable, varargin)
% mday_02_merge_av(datatype, ydays, mtable)
%
% ydays is in yearday
% merge data from multiple inputs/instruments

if nargin>3
    regrid = varargin{1};
else
    regrid = 1;
end

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
ddays = ydays-1;

ngvars = {'utctime'}; %never grid this
gvars = {}; %by default grid all other variables

%define input and output files
switch datatype
    case 'nav'
        opt1 = 'ship'; opt2 = 'datasys_best'; get_cropt
        source = {'position'; 'heading'; 'attitude'};
        streams = {default_navstream; default_hedstream; default_attstream};
        required = [1 1 0];
        otfile = ['bestnav_' mcruise '.nc'];
        tavp_s = 30; %30 s
        gmethod = 'meannum';
        ngvars = [ngvars 'altitude' 'headingtrue' 'coursetrue'];
        ngvars = [ngvars 'speedknots' 'speedkmph' 'rollaccuracy' 'pitchaccuracy' 'headingaccuracy'];
    case 'bathy'
        source = {'sbm'; 'mbm'};
        streams = {'ea640_sddpt'; 'em122_kidpt'};
        required = [0 0];
        otfile = ['bathy_' mcruise '.nc'];
        tavp_s = 5*60; % 5 min
        gmethod = 'medbin';
    case 'ocean'
        source = {'surfmet';'sbe45';'sbe38'};
        streams = {'surfmet_sfuwy'; 'sbe45_nanan'; 'sbe38dk_sbe38'};
        required = [1 1 0]; %***make cruise-specific
        otfile = ['surface_ocean_' mcruise '.nc'];
        tavp_s = 60; % 1 min
        gmethod = 'meannum';
    case 'atmos'
        opt1 = 'ship'; opt2 = 'datasys_best'; get_cropt
        source = {'surfmet'; 'windsonic'; 'position'};
        streams = {'surfmet_sfmet'; 'surfmet_sflgt'; 'windsonic_iimwv'};
        required = [0 1 1];
        otfile = ['atmos_truewind_' mcruise '.nc'];
        tavp_s = 30; % 30 s
        gmethod = 'meannum';
end
otfile = fullfile(mgetdir('sum'),otfile);
opt1 = 'uway_proc'; opt2 = 'merge_av'; get_cropt

%***check for multiple streams from same inst? not important at this
%stage, all will be in corresponding mstar file
if isstruct(mtable) || istable(mtable)
    filepre = cell(size(streams)); filepre_old = filepre;
    for fno = 1:length(streams)
        m = strcmp(streams{fno},mtable.tablenames);
        filepre{fno} = fullfile(mgetdir(mtable.mstarpre{m}), mtable.mstarpre{m});
        d = dir([filepre{fno} '*.nc']);
        if isempty(d)
            filepre{fno} = fullfile(MEXEC_G.mexec_data_root,mtable.mstardir{m},mtable.paramtype{m},mtable.mstarpre{m});
        end
    end
elseif iscell(mtable)
    filepre = mtable;
end
filepre = unique(filepre,'stable');

if regrid

    %gridding parameters
    opt1 = 'uway_proc'; opt2 = 'uway_av'; get_cropt
    %grid in seconds
    tavp_s = round(tavp_s);
    tg = [round(ddays(1)*86400-tavp_s/2):round(tavp_s):round(ddays(end)*86400+1+tavp_s/2)]';
    opts.ignore_nan = 1; 
    opts.grid_ends = [1 1];
    opts.postfill = tavp_s; %after gridding, interpolate over gaps up to one step
    opts.bin_partial = 1; %only relevant for bathy 
    if strcmp(gmethod,'meannum')
        opts.num = tavp_s;
    end

    %load multiple files, either edt (if found) or raw, and merge to common
    %time grid, saving along the way
    found = ones(size(required));
    for fno = 1:length(filepre)
        infile = [filepre{fno} '_' mcruise '_all_edt.nc'];
        if ~exist(infile,'file')
            infile = [filepre{fno} '_' mcruise '_all_raw.nc'];
            if ~exist(infile,'file')
                if required(fno)
                    error('no file found for %s',filepre{fno})
                else
                    found(fno) = 0;
                    warning('no file found for %s*, skipping',filepre{fno})
                    continue
                end
            end
        end
        [d, h] = mload(infile,'/');
        if ~isfield(h,'fldserial')
            h.fldserial = repmat({' '},size(h.fldnam));
        end

        %prepare
        [d, h] = mday_02_calculations(d, h, 'pre', datatype, gvars, ngvars, source{fno}, gmethod, ddays);

        %grid
        tgvar = sprintf('time_s_%d',MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1));
        tic; dg = grid_profile(d, tgvar, tg, gmethod, opts); toc
        dg = table2struct(dg,'ToScalar',true);
        if ~sum(strcmp(gmethod,'meannum'))
            dg.(tgvar) = (tg(1:end-1)+tg(2:end))/2;
        end
        %now add dday for QC plots
        dg.dday = dg.(tgvar)/86400;
        if ~sum(strcmp('dday',h.fldnam))
            h.fldnam = [h.fldnam 'dday'];
            h.fldunt = [h.fldunt replace(h.fldunt{strcmp(tgvar,h.fldnam)},'seconds','days')];
            h.fldserial = [h.fldserial ' '];
        else
            dg = orderfields(dg,h.fldnam);
        end
        %save
        h.dataname = [datatype '_' mcruise '_combined_av'];
        h.comment = sprintf('%s \n%s from %s, % over bins of width %s s',h.comment,source{fno},infile,gmethod(1:end-2),num2str(tavp_s));
        mfsave(otfile, dg, h, '-merge', tgvar) %***what if there were NaNs that can now be filled?

    end
    if ~sum(found)
        warning('no files to load for %s, skipping',datatype)
        return
    end
    clear dg h d tg

end

% load and QC combined data (all?***)
[dg, hg] = mload(otfile,'/');

%edit
opt1 = 'uway_proc'; opt2 = 'avedit'; get_cropt
%apply previous manually selected edits
btol = (tavp_s/2)/86400;
edfile = fullfile(fileparts(otfile),'editlogs',[datatype '_' mcruise]);
[dg, ~] = apply_guiedits(dg, 'dday', [edfile '*'], 0, btol);
if ~isempty(uopts)
    % autoedits (e.g. if A depends on B, remove A when B is bad)
    [dg, comment] = apply_autoedits(dg, uopts);
    if ~isempty(comment)
        hg.comment = [hg.comment comment];
    end
end
if handedit
    %manual selection of (additional) points to edit
    if exist('vars_offset_scale','var')
        [dg, hg] = uway_edit_by_day(dg, hg, edfile, ddays, btol, vars_to_ed, vars_offset_scale);
    else
        [dg, hg] = uway_edit_by_day(dg, hg, edfile, ddays, btol, vars_to_ed);
    end
end
if ~isempty(uopts)
    % autoedits (e.g. if A depends on B, remove A when B is bad) again to
    % apply hand-selected NaNs to related variables
    [dg, comment] = apply_autoedits(dg, uopts);
    if ~isempty(comment)
        hg.comment = [hg.comment comment];
    end
end
if isfield(hg,'fldserial') && length(hg.fldserial)<length(hg.fldnam); keyboard; end

% calibrate/adjust existing variables and calculate additional variables
[dg, hg, comment] = mday_02_calculations(dg, hg, 'post', datatype);
if ~isempty(comment)
    hg.comment = [hg.comment comment];
end

%save again
mfsave(otfile, dg, hg);
