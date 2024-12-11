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
dto = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN;
timestring = ['days since ' datestr(dto,'yyyy-mm-dd HH:MM:SS')];
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

%***check for multiple streams from same inst? not important at this
%stage, all will be in corresponding mstar file
if isstruct(mtable) || istable(mtable)
    filepre = cell(size(streams));
    for fno = 1:length(streams)
        m = strcmp(streams{fno},mtable.tablenames);
        filepre{fno} = fullfile(mgetdir(mtable.mstarpre{m}), mtable.mstarpre{m});
    end
elseif iscell(mtable)
    filepre = mtable;
end
filepre = unique(filepre);
otfile = fullfile(fileparts(filepre{1}),otfile);

if regrid

    %gridding parameters
    opt1 = 'uway_proc'; opt2 = 'uway_av'; get_cropt
    tavp_s = round(tavp_s); tavp = tavp_s/86400; %now days
    tg = [ddays(1)-tavp/2:tavp:ddays(end)+1+tavp/2]';
    opts.ignore_nan = 1;
    opts.grid_ends = [1 1];
    opts.postfill = tavp_s; %***
    opts.bin_partial = 0;
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

        %prepare
        timvar = munderway_varname('timvar',h.fldnam,1,'s');
        d.dday = m_commontime(d, timvar, h, timestring);
        if ~sum(strcmp('dday',h.fldnam))
            h.fldnam = [h.fldnam 'dday']; h.fldunt = [h.fldunt timestring];
        end
        [h.fldnam,ii] = setdiff(h.fldnam,timvar,'stable'); h.fldunt = h.fldunt(ii);
        d = rmfield(d,timvar);
        [d, h, gvars, ngvars] = mday_02_calculations(d, h, 'pre', ...
            datatype, gvars, ngvars, source{fno}, gmethod, ddays);

        %grid
        tic; dg = grid_profile(d, 'dday', tg, gmethod, opts); toc
        if ~sum(strcmp(gmethod,'meannum'))
            dg.dday = (tg(1:end-1)+tg(2:end))/2;
        end
        %keep these for merging
        dg.times = round(dg.dday*86400);
        h.fldnam = [h.fldnam 'times'];
        h.fldunt = [h.fldunt replace(timestring,'days','seconds')];
        if isfield(h,'fldserial')
            h.fldserial = [h.fldserial ' '];
        else
            h.fldserial = repmat({' '},size(h.fldnam));
        end
                if isfield(h,'fldserial') && length(h.fldserial)<length(h.fldnam); keyboard; end

        %save
        h.dataname = [datatype '_' mcruise '_combined_av'];
        h.comment = sprintf('\n %s from %s, % over bins of width %s s',source{fno},infile,gmethod(1:end-2),num2str(tavp_s));
        mfsave(otfile, dg, h, '-merge', 'times')

    end
    if ~sum(found)
        warning('no files to load for %s, skipping',datatype)
        return
    end
    clear dg h d tg

end

% load and QC combined data (all?***)
[dg, hg] = mload(otfile,'/');

% calibrate/adjust existing variables and calculate additional variables
[dg, hg, comment] = mday_02_calculations(dg, hg, 'post', datatype);
if ~isempty(comment)
    hg.comment = [hg.comment comment];
end

%edit
opt1 = 'uway_proc'; opt2 = 'avedit'; get_cropt
%deal with a common edit
if exist('flowlims','var') && exist('tsgpumpvars','var') && ~isempty(flowlims) && ~isempty(tsgpumpvars)
    uopts.rangelim.flow = flowlims;
    for vno = 1:length(tsgpumpvars)
        uopts.badflow.(tsgpumpvars{vno}) = [NaN NaN];
    end
end
if ~isempty(uopts)
    % autoedits (e.g. if A depends on B, remove A when B is bad)
    [dg, comment] = apply_autoedits(dg, uopts);
    if ~isempty(comment)
        hg.comment = [hg.comment comment];
    end
end
if handedit
    btol = (tavp_s/2)/86400;
    edfile = fullfile(fileparts(otfile),'editlogs',[datatype '_' mcruise]);
    [dg, hg] = uway_edit_by_day(dg, hg, edfile, ddays, btol, vars_to_ed);
end
    if isfield(hg,'fldserial') && length(hg.fldserial)<length(hg.fldnam); keyboard; end

%save again
mfsave(otfile, dg, hg);
