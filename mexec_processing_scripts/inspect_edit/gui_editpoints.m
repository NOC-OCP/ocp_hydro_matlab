function bads = gui_editpoints(d, xvar, varargin)
% function bads = gui_editpoints(d, indepvar, 'parameter', 'value');
%
% gui for selecting bad points from one (at a time) of a set of lines
% plotted together
%
% d is a structure. if scalar, fields other than indepvar are plotted vs
% indepvar; if vector, each element should contain indepvar and one other
% (non-empty) variable.
%
% indepvar (string) is the name of the independent variable
%
% optional parameter-value input pairs include:
%
% edfilepat, the path and prefix for the file to which to write selected
%   edits (file name will have time of writing appended so this can be run
%   more than once without overwriting previous edits)
% colors, markers, lines[tyle] (to use for plot)
% xgroups, cell array of indices in indepvar to step through
%
% output bads is a structure with fieldnames matching those in input
%   (besides indepvar) and values listing indices of selected points for
%   each

%check inputs and construct vector structure d0 and list of dependent
%fields fn
nl0 = length(d);
if nl0==1
    fn = setdiff(fieldnames(d),xvar,'stable');
    nl = length(fn);
    m = true(nl,1);
    for no = 1:nl
        if length(d.(fn{no}))==length(d.(xvar))
            d0(no).(xvar) = d.(xvar);
            d0(no).(fn{no}) = d.(fn{no});
        else
            warning('variable %s does not match %s; skipping',fn{no},xvar)
            m(no) = false;
        end
    end
    d0 = d0(m); fn = fn(m); nl = length(fn);
else
    d0 = d;
    m = true(nl0,1);
    fn = cell(nl0,1);
    for no = 1:nl0
        fn0 = setdiff(fieldnames(d0(no)),xvar,'stable');
        found = 0; n = 1;
        while ~found && n<=length(fn0)
            if length(d0(no).(fn0{n}))==length(d0(no).xvar)
                fn{no} = fn0{n};
                found = 1;
            else
                n = n+1;
            end
        end
        if ~found
            m(no) = false;
            warning('no field matching %s in input d(%d); skipping',xvar,no)
        end
    end
    d0 = d0(m); fn = fn(m); nl = length(fn);
end

%parameter-value inputs for plot
for no = 1:2:length(varargin)
    eval([varargin{no} ' = varargin{no+1};'])
end
if ~exist('colors','var')
    colors = [1 0 0; 1 .5 0; 0 .5 0; 0 1 1; 0 0 1; .5 0 .5];
end
nc = size(colors,1); if nc==1; nc = length(colors); end
if ~exist('markers','var')
    markers = [repmat({'o'},nc,1); repmat({'<'},nc,1); repmat({'.'},nc,1)];
    colors = [colors; colors; colors];
end
if ~exist('lines','var')
    lines = repmat({'-'},nc*3,1);
end
colors = colors(1:length(m),:); markers = markers(1:length(m)); lines = lines(1:length(m));
colors = colors(m,:); markers = markers(m); lines = lines(m);
if ~exist('xgroups','var')
    xgroups = {1:length(d0(1).(xvar))};
end

for gno = 1:length(xgroups)

    done = 0;
    figure(10); clf; clear hl
    iis = xgroups{gno};
    if isempty(iis); done = 1; end
    while ~done

        if ~exist('hl','var')
            %make new plot
            for no = 1:nl
                hl(no) = plot(d0(no).(xvar)(iis),d0(no).(fn{no})(iis),'color',colors(no,:),'marker',markers(no),'linestyle',lines{no});
                hold on
            end
            grid on
        elseif exist('edno','var') && ~isempty(edno) && isfinite(edno)
            %add edited line back to plot
            delete(hl(edno)); hl(edno) = plot(d0(edno).(xvar)(iis),d0(edno).(fn{edno})(iis),'color',colors(edno,:),'marker',markers(edno),'linestyle',lines{edno});
            hold on
        end

        disp('use figure buttons to zoom and pan, then select variable to edit from:')
        for no = 1:nl
            disp([num2str(no) ': ' fn{no} ' (' markers{no} ')'])
        end
        edno = input('or enter to quit/step through to next indices without (more) edits\n','s');
        if isempty(edno)
            cont = 'n';
            done = 1; continue %go on to next loop
        else
            edno = str2double(edno);
            if isempty(edno) %it was some other string
                cont = 'e';
                continue %try again, same loop because done hasn't been reset
            end
        end

        %chose something to edit
        set(hl(edno),'color',[0 0 0],'marker','x')
        disp(['select bottom left and top right corners of box around bad data from variable ' num2str(edno) ' (black xes)']);
        [x,y] = ginput(2); if x(1)>x(2); x = flipud(x(:)); y = flipud(y(:)); end

        %check edits
        bad = d0(edno).(xvar)>=x(1) & d0(edno).(xvar)<=x(2) & d0(edno).(fn{edno})>=y(1) & d0(edno).(fn{edno})<=y(2);
        if sum(bad)
            hle = plot(d0(edno).(xvar)(bad),d0(edno).(fn{edno})(bad),'p','color',[.5 .5 .5]);
            confirm = input('delete selected points (y/n)?\n','s');
            if ~strcmp(confirm,'y')
                bad = 0;
            end
            delete(hle)
        end

        if sum(bad) %kept edits; append to list
            if ~exist('bads','var') || ~isfield(bads,fn{edno})
                bads.(fn{edno}) = [];
            end
            bads.(fn{edno}) = [bads.(fn{edno}); d0(edno).(xvar)(bad)];
            d0(edno).(fn{edno})(bad) = NaN;
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

%output and write
if ~exist('bads','var')
    bads = [];
elseif ~isempty(bads) && exist('edfilepat','var') && ~strcmp(cont,'q')
    fname = [edfilepat '_' datestr(now,'yyyymmdd_HHMMSS')];
    fp = fileparts(fname); if ~exist(fp,'dir'); mkdir(fp); end
    fnb = fieldnames(bads);
    fid = fopen(fname,'w');
    fprintf(fid,'gui_editpoints with indepvar %s\n',xvar);
    for no = 1:length(fnb)
        fprintf(fid,'%s\n',fnb{no});
        fprintf(fid,'%d\n',bads.(fnb{no})(:));
    end
    fclose(fid);
end

