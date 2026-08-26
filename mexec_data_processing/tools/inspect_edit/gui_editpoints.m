function bads = gui_editpoints(data, xvar, xgroups, ygroups, varargin)
% function bads = gui_editpoints(d, xvar, xgroups, ygroups, 'parameter', 'value');
%
% gui for selecting bad points from one (at a time) of a set of lines
% plotted together
%
% data is a table
% ygroups can be
%   empty, in which case all columns other than data.(xvar) are plotted vs 
%     data.(xvar), or
%   a cell array of strings listing variable names from data, in which
%     case only columns found in ygroups are plotted vs data.(xvar) 
%   a cell array of cell arrays, in which case plotting loops through each
%     set of variables
% xgroups can be 
%   empty, in which case all rows are plotted at once, or
%   a cell array of numeric vectors giving indices to step through
%
% optional parameter-value input pairs include:
%
% edfilepre, the path and prefix for a file to which to write the selected
%   edits (file name will have time of writing appended so this can be run
%   more than once without overwriting previous edits)
% yl, table with the same names as dependent variables in table data,
%   giving the lower and upper limits for the y-axis for that variable
%
% output bads is a table with variables matching those in data (besides
% xvar) and values listing the xvar values of selected points for each)
% 
% e.g.
% bads = gui_editpoints(data, 'scan', [],...
%   {{'temp1','temp2','cond1','cond2','press'},{'fluor','oxygen1','oxygen2','press'}});
% bads = gui_editpoints(data, 'dday', {[1:1000];[1000:87400]}, []);

%parameter-value inputs for plot
colors = [0 0 0; 1 .5 1; 1 0 0; 1 .5 0; 0 .5 0; 0 1 1; 0 0 1; .5 0 .5];
colornames = {'black';'pink';'red';'orange';'green';'cyan';'blue';'purple'}';
markers = repmat({'o','<','.'},1,3);
markersize = 8;
lines = repmat({'-','--',':'},1,3);
ti = '';
for no = 1:2:length(varargin)
    eval([varargin{no} ' = varargin{no+1};'])
end
markers = markers(:); lines = lines(:); 
%axis offsets, in pairs because we alternate left and right y axis location
axo = [.2 .2:-0.04:0.04]';
if ~exist('add_sensnum','var')
    add_sensnum = 0;
end

if isempty(xgroups)
    xgroups = {1:length(data.(xvar))};
end

vn = data.Properties.VariableNames;
yln = yl.Properties.VariableNames;
%scale data to all fit in [0 1] (y axis labels will come from yl)
for scno = 1:length(yln)
    m = strcmp(vn,yln{scno});
    if sum(m)
        data{:,m} = (data{:,m}-yl.(yln{scno})(1))./(diff(yl.(yln{scno})));
    end
end

if isempty(ygroups)
    ygroups.g1 = {setdiff(vn,xvar)};
end


gs = fieldnames(ygroups);

for vgno = 1:length(gs)
    yv = ygroups.(gs{vgno});
    for xrno = 1:length(xgroups)
        done = 0;
        figure(10); clf; clear hl ha vused cused mused cnused
        iis = xgroups{xrno};
        if isempty(iis); done = 1; end
        while ~done

            if ~exist('hl','var')
                %make new plot
                hasdata = 0; clf; 
                vused = {}; hl = [];
                cused = []; cnused = {}; mused = {}; lused = {};
                ytl = {}; yt = {}; ano = 1;
                for gno = 1:length(yv)
                    v = yv{gno};
                    m = ismember(vn,v) & sum(~isnan(data{:,:}));
                    if sum(sum(~isnan(data{iis,m})))
                        ha(ano) = axes('Box','off');                        
                        l = yl.(v{1}); 
                        set(ha(ano),'ylim',l); 
                        t = get(ha(ano),'ytick'); 
                        if length(t)<10
                            ytl{ano} = t(1):(t(2)-t(1))/5:t(end); %make them closer together
                        else
                            ytl{ano} = t(1):(t(2)-t(1))/2:t(end);
                        end
                        yt{ano} = (ytl{ano}-l(1))/(l(2)-l(1));
                        hl = [hl; plot(ha(1), data.(xvar)(iis), data{iis,m},...
                            'color', colors(gno,:), 'markersize', markersize)];
                        hold on
                        vused = [vused vn(m)]; 
                        cused = [cused; repmat(colors(gno,:),sum(m),1)];
                        cnused = [cnused repmat(colornames(gno),1,sum(m))];
                        mused = [mused; markers(1:sum(m))];
                        lused = [lused; lines(1:sum(m))];
                        axes(ha(ano)); ylabel(sprintf('%s ',v{:}));
                        if ano==1
                            ha(ano).YAxisLocation = 'right';
                        else
                            ha(ano).YAxisLocation = 'left';
                            ha(ano).Color = 'none'; 
                            ha(ano).YColor = colors(ano,:);
                            set(ha(ano),'xtick',[])
                            set(ha(ano),'ylim',[0 1],'ytick',yt{ano},'yticklabel',ytl{ano});
                        end
                        set(ha(ano),'position',[axo(ano) .1 1-2*axo(ano)+.1 .8])
                        hasdata = 1; ano = ano+1;
                    end
                end
                if exist('ha','var')
                linkaxes(ha,'y');
                set(ha(1),'ylim',[0 1],'ytick',yt{1},'yticklabel',ytl{1});
                axes(ha(1)); title(ti)
                for sno = 1:length(vused)
                    set(hl(sno),'marker',mused{sno},'linestyle',lused{sno})
                end
                end
                if ~hasdata; done = 1; cont = 1; continue; end %skip days with no data
                hold on; grid on

            elseif exist('edno','var') && ~isempty(edno) && isfinite(edno)
                %add edited line back to plot
                delete(hl(edno)); hl(edno) = plot(data.(xvar)(iis),data.(vused{edno})(iis),'color',cused(edno,:),'marker',mused(edno));
                hold on; zoom('on')

            end

            disp('use figure buttons to zoom and pan, then select variable to edit from:')
            for sno = 1:length(vused)
                disp([num2str(sno) ': ' vused{sno} ' (' cnused{sno} ', marker ' mused{sno} ')'])
            end
            edno = input('or enter to quit/step through to next indices or next variable group\n','s');
            if isempty(edno)
                cont = 'n';
                done = 1; continue %go on to next loop
            else
                edno = str2double(edno);
                if isempty(edno) || isnan(edno) %it was some other string
                    cont = 'e';
                    continue %try again, same loop because done hasn't been reset
                end
            end

            %chose something to edit
            set(hl(edno),'color',[0 0 0],'marker','x')
            disp(['select bottom left and top right corners of one or more boxes around bad data from variable ' num2str(edno) ' (black xes); enter to continue']);
            [x,y] = ginput(50); if isempty(x); continue; elseif x(1)>x(2); x = flipud(x(:)); y = flipud(y(:)); end

            %check edits
            bad = false(size(data.(xvar)));
            for no = 1:2:length(x)
                bad = bad | data.(xvar)>=x(no) & data.(xvar)<=x(no+1) & data.(vused{edno})>=y(no) & data.(vused{edno})<=y(no+1);
            end
            if sum(bad)
                hle = plot(ha(1), data.(xvar)(bad),data.(vused{edno})(bad),'s','color',[.5 .5 .5]);
                confirm = input(['delete ' num2str(sum(bad)) ' selected points (y/n)?\n'],'s');
                if ~strcmp(confirm,'y')
                    bad = 0;
                end
                delete(hle)
            end

            if sum(bad) %kept edits; append to list
                if ~exist('bads','var') || ~isfield(bads,vused{edno})
                    bads.(vused{edno}) = [];
                end
                bads.(vused{edno}) = [bads.(vused{edno}); data.(xvar)(bad)];
                data.(vused{edno})(bad) = NaN;
            end

            cont = input('enter ''e'' to edit more points here,\n ''n'' to go on to next,\n ''w'' to write to file and quit, \n or ''q'' to quit without saving any\n','s');
            if strcmp(cont,'n') || strcmp(cont,'w') || strcmp(cont,'q')
                done = 1; %leave while
            end

        end

        if strcmp(cont,'w') || strcmp(cont,'q')
            break %leave for loop
        end

    end

end

%output and write
if ~exist('bads','var')
    bads = [];
elseif ~isempty(bads) && exist('edfilepre','var') && ~strcmp(cont,'q')
    fname = [edfilepre '_' datestr(now,'yyyymmdd_HHMMSS')];
    fp = fileparts(fname); if ~exist(fp,'dir'); mkdir(fp); end
    fnb = fieldnames(bads);
    fid = fopen(fname,'w'); mfixperms(fname);
    fprintf(fid,'gui_editpoints with xvar %s\n',xvar);
    for no = 1:length(fnb)
        fprintf(fid,'%s\n',fnb{no});
        fprintf(fid,'%f\n',bads.(fnb{no})(:));
    end
    fclose(fid); mfixperms(fname);
end

