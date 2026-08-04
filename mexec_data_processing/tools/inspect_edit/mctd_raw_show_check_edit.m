function ed = mctd_raw_show_check_edit(stn, varargin)
% mctd_raw_show_check_edit: display raw or cleaned 24 hz ctd data along
% with 1 hz data to check for spikes, check and modify the cast start,
% bottom, and end, and select/apply edits by calling mctd_rawedit
%
% mctd_rawshow(stn) displays data from the cleaned, corrected
%   (*_cleaned.nc) file, if it exists, the raw (*_cnv.nc) file if not
% mctd_rawshow(stn, 'raw') always displays data from the raw file
% mctd_rawshow(stn, 'cleaned') displays data from the cleaned file if it
%   exists and exits if not
%
% asks if edits were made and outputs this as ed

m_common
opt1 = 'setup'; opt2 = 'procfiles'; get_cropt
if MEXEC_G.quiet<=1; fprintf(1,'plotting 24 hz and 1 hz CTD data for station %s to check for spikes\n',stn_string); end

cfile = m_add_nc(sprintf(ctdfile.clean,stn_string));
rfile = m_add_nc(sprintf(ctdfile.raw,stn_string));
if nargin>1
    rt = varargin{1};
    if strcmp(rt,'raw') && exist(rfile,'file')
        infiler = rfile;
    elseif strcmp(rt,'cleaned')
        if exist(cfile,'file')
            infiler = cfile;
        else
            warning('%s not found, skipping',cfile)
        end
    else
        error('2nd input %s not recognised or file does not exist',varar)
    end
else
    if exist(cfile,'file')
        infiler = cfile;
        rt = 'cleaned';
    elseif exist(rfile,'file')
        infiler = rfile;
        rt = 'raw';
    else
        error('neither %s nor %s found',rfile,cfile)
    end
end
infiled = sprintf(dcsfile.dcs,stn_string);
infile1 = sprintf(ctdfile.p1,stn_string);

[d,h] = mload(infiler,'/');
[d1,h1] = mload(infile1,'/');
[ddcs, hdcs]  = mloadq(infiled,'/');
dn_start = m_commontime(ddcs.time_start(1),'time_start',hdcs,'datenum');
dn_end = m_commontime(ddcs.time_end(1),'time_end',hdcs,'datenum');
if strcmp(rt,'cleaned')
    opt1 = 'ctd_proc'; opt2 = 'raw_corrs'; get_cropt
end

% which variables to plot
opt1 = 'ctd_proc'; opt2 = 'rawshow'; get_cropt
ng = length(rppars);
warn = 0;

for gno = 1:ng
    
    % for each parameter in group, plot both sensors, 1 hz dashed on top of 24 hz
    figure(gno); clf
    nr = length(rppars{gno});
    t(gno) = tiledlayout(nr,1,'TileSpacing','compact');
    ax = zeros(nr,1);
    dat = []; dat1 = []; vnames = {};
    for vno = 1:nr
        ax(vno) = nexttile(vno);
        p = rppars{gno}{vno};
        v = h.fldnam(strncmp(h.fldnam,p,length(p)) & ~strcmp(h.fldnam,'pressure_temp'));
        if ~isempty(v)
            plot(d.scan,d.pumps*(yl.(p)(2)-yl.(p)(1))+yl.(p)(1),'.r','markersize',8); hold on
            if strcmp(p,'oxy')
                scan_end = [ddcs.scan_end ddcs.scan_end-co.oxy_align*24];
            else
                scan_end = ddcs.scan_end;
            end
            plot(repmat([ddcs.scan_start ddcs.scan_bot scan_end],2,1),yl.(p),'--','color',[.5 .5 .5]); hold on
            for sno = 1:length(v)
                plot(d.scan, d.(v{sno}), d1.scan, d1.(v{sno}), ':');
                m = d.scan>=ddcs.scan_start & d.scan<=ddcs.scan_end;
                if max(d.(v{sno}))>yl.(p)(2) || min(d.(v{sno}))<yl.(p)(1)
                    warn = 1;
                end
            end
            ylabel([p ' (' h.fldunt{strcmp(h.fldnam,v{sno})} ')']);
            xlim(d.scan([1 end])); ylim(yl.(p)); 
        end
    end
    if gno==1; ax_save = ax; end
    xlabel(t(gno),sprintf('scan (cast %s)',stn_string)); 
    title(t(gno),[rt ' 24 hz (dotted 1 hz), gray dashed verticals start, bottom, end scans'])
    linkaxes(ax,'x')

end

figure(1)
a = 'p';
while ~isempty(a)
    mess = ['use zoom/pan from figure toolbar, then choose : \n'];
    mess = [mess 'ss  : select start scan\n'];
    mess = [mess 'sb  : select bottom scan\n'];
    mess = [mess 'se  : select end scan\n'];
    mess = [mess 'pp  : plot present selection\n'];
    mess = [mess 'w   : save values and proceed\n'];
    mess = [mess 'enter to proceed without saving new values\n'];
    mess = [mess '    :  '];
    a = input(mess,'s');

    switch a

        case 'pp'
            if exist('hss','var'); delete(hss); clear hss; end
            if exist('hsb','var'); delete(hsb); clear hsb; end
            if exist('hse','var'); delete(hse); clear hse; end
            for vno = 1:length(ax_save)
                p = rppars{1}{vno};
                axes(ax_save(vno))
                if exist('k_start','var') && isfinite(k_start)
                    hss(vno) = plot(d.scan([k_start; k_start]),yl.(p),'--','color',[.5 0 .5]);
                end
                if exist('k_bot','var') && isfinite(k_bot)
                    hsb(vno) = plot(d.scan([k_bot; k_bot]),yl.(p),'--','color',[.5 0 .5]);
                end
                if exist('k_end','var') && isfinite(k_end)
                    hse(vno) = plot(d.scan([k_end; k_end]),yl.(p),'--','color',[.5 0 .5]);
                end
            end

        case 'ss'
            % select downcast start scan
            disp('select start scan on any panel');
            [x, ~] = ginput(1);
            [~,k_start] = min(abs(d.scan-x));

        case 'sb'
            disp('select bottom scan on any panel');
            % select bottom scan
            [x, ~] = ginput(1);
            [~,k_bot] = min(abs(d.scan-x));

        case 'se'
            % select upcast end scan
            disp('select end scan on any panel');
            [x, ~] = ginput(1);
            [~,k_end] = min(abs(d.scan-x));

        case 'w'
            break

    end
end

if strcmp(a,'w')
%save
if exist('k_start','var') && isfinite(k_start) && k_start~=ddcs.dc_start
    ds.dc_start = k_start;
    ds.scan_start = d.scan(ds.dc_start);
    ds.press_start = d.press(ds.dc_start);
    ds.time_start = d.time(ds.dc_start);
    [~,ds.dc24_start] = min(abs(d.scan-ds.scan_start));
end

if exist('k_end','var') && isfinite(k_end) && (~isfield(ddcs, 'dc_end') || k_end~=ddcs.dc_end)
    ds.dc_end = k_end;
    ds.scan_end = d.scan(ds.dc_end);
    ds.press_end = d.press(ds.dc_end);
    ds.time_end = d.time(ds.dc_end);
    [~,ds.dc24_end] = min(abs(d.scan-ds.scan_end));
end

if exist('k_bot','var') && isfinite(k_bot) && k_bot~=ddcs.dc_bot
    ds.dc_bot = k_bot;
    ds.scan_bot = floor(d.scan(ds.dc_bot));
    ds.press_bot = d.press(ds.dc_bot);
    ds.time_bot = d.time(ds.dc_bot);
    [~,ds.dc24_bot] = min(abs(d.scan-ds.scan_bot));
end

if exist('ds','var')
    hnew.fldnam = fieldnames(ds)';
    hnew.fldunt = repmat({' '},size(hnew.fldnam));
    hnew.fldunt(strncmp('dc',hnew.fldnam,2)) = {'number'};
    hnew.fldunt(strncmp('scan',hnew.fldnam,2)) = {'number'};
    hnew.fldunt(strncmp('press',hnew.fldnam,5)) = {'dbar'};
    opt1 = 'mstar'; get_cropt
    if docf
        hnew.fldunt(strncmp('time',hnew.fldnam,4)) = h.fldunt(strcmp('time',h.fldnam));
    else
        hnew.fldunt(strncmp('time',hnew.fldnam,4)) = {'seconds'};
    end
    hnew.comment = 'automatically detected ';
    if isfield(ds,'dc_start'); hnew.comment = [hnew.comment 'start ']; end
    if isfield(ds,'dc_bot'); hnew.comment = [hnew.comment 'bottom ']; end
    if isfield(ds,'dc_end'); hnew.comment = [hnew.comment 'end ']; end
    hnew.comment = [hnew.comment 'of cast overwritten with manual selections\n'];

    MEXEC_A.Mprog = mfilename;
    mfsave(infiled, ds, hnew, '-addvars');
else
    h = m_read_header(infiled); h.comment = [h.comment ' cast start/bottom/end inspected but not changed\n'];
    ncfile.name = m_add_nc(infiled); m_write_header(infiled,h);
end
end

if warn
    m = {'If you need to remove a range of scans or many out-of-range values or large spikes from'
        'several parameters, use cruise options file ctd_proc, rawedit_auto case first'
        'before manual despiking/outlier removal. If there are large spikes in temperature'
        'you should remove them before applying cell thermal mass correction, and if '
        'there are large spikes in oxygen. Enter to continue.'};
    fprintf(1,'%s\n',m{:});
end
if warn || doed
    ed = input('run gui_editpoints now?   ','s');
    if strcmp(ed,'y')
        bads = gui_editpoints(d, 'scan', 'edfilepat', sprintf(edfiles.ctd,stn_string));
        close all
        msg = sprintf('did you make any manual edits or change any automatic editing/correction settings in opt_%s?   ',mcruise);
        ed = strcmp(input(msg,'s'),'y');
    end
else
    ed = false;
end
