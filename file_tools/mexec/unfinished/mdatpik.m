function mdatpik(varargin)

% pick data cycles depending on whether control variable is inside or
% outside a range
% based on program with input and output to different files

m_common
m_margslocal
m_varargs

MEXEC_A.Mprog = 'mdatpik';
m_proghd


fprintf(MEXEC_A.Mfidterm,'%s','Enter name of input disc file  ')
fn_in = m_getfilename;
fprintf(MEXEC_A.Mfidterm,'%s','Enter name of output disc file ')
fn_ot = m_getfilename;
ncfile_in.name = fn_in;
ncfile_ot.name = fn_ot;

% m = 'Output file will be same as input file. OK ? Type y to proceed ';
% reply = m_getinput(m,'s');
% if strcmp(reply,'y') ~= 1
%     disp('exiting')
%     return
% end

ncfile_in = m_openin(ncfile_in);
ncfile_ot = m_openot(ncfile_ot);


h = m_read_header(ncfile_in);
if ~MEXEC_G.quiet; m_print_header(h); end

hist = h;
hist.filename = ncfile_in.name;
MEXEC_A.Mhistory_in{1} = hist;


% --------------------
% Now do something with the data
% first write the same header; this will also create the file
h.openflag = 'W'; %ensure output file remains open for write, even though input file is 'R';
m_write_header(ncfile_ot,h);

numcopy = 0; % no cycles selected yet
while numcopy == 0

    m1 = 'enter how data recs to be selected:';
    m2 = '   -1 =  outside every range specified';
    m3 = '    0 =  outside one or more ranges';
    m4 = '    1 =  within  one or more ranges';
    m5 = '    2 =  within every range specified';

    m = sprintf('%s\n',m1,m2,m3,m4,m5);
    disp(' ');
    reply = m_getinput(m,'s');
    kselect = str2num(reply);
    if isempty(find([-1 0 1 2] == kselect))
        errstr = ['You must reply one of [-1 0 1 2]'];
        error(errstr);
    end

    noflds = h.noflds;
    m = ['Enter range definitions as prompted'];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m);

    control = [];
    while 1 > 0
        m = sprintf('%s\n','variable_name_or_number min max (0 / or return  to end)');
        % this could be fixed to allow variable names as well as numbers
        % fix done: bak at NOC 9 Feb 2009
        reply = m_getinput(m,'s');
        if strncmp(' ',reply,1) == 1; break; end
        if strncmp('0',reply,1) == 1; break; end
        if strncmp('/',reply,1) == 1; break; end
        % Now allow for var name instead of number. Need to parse the line
        % into three parts
        toks = {};
        while length(reply) > 0
            [atok,reply] = strtok(reply,' ,');
            toks(end+1) = cellstr(atok);
        end
        if length(toks) ~= 3
            m1 = ['It appears your reply was ' toks];
            m2 = 'and it does not contain precisely three components';
            fprintf(MEXEC_A.Mfider,'%s\n',' ',m1,m2,' ');
            continue
        end
        varnum = m_getvlist(char(toks(1)),h);
        vmin = str2num(char(toks(2)));
        vmax = str2num(char(toks(3)));
%         cmd = ['varlims = [' reply '];']; %convert char response to number
%         eval(cmd);
%         if length(varlims) < 3
%             m = ' You must provide a variable min and max ';
%             fprintf(MEXEC_A.Mfider,'%s\n',m);
%             continue
%         end

        varlims = [varnum vmin vmax];
        if ~MEXEC_G.quiet
        m = ['              ' h.fldnam{varnum} ' ' num2str(vmin) ' ' num2str(vmax)];
        fprintf(MEXEC_A.Mfidterm,'%s\n',m,' ');
	end
        control = [control;varlims];

    end


    control_string = sprintf('%d ',control(:,1));
    vlist_c = m_getvlist(control_string,h);

    % check all control variables have the same dimensions
    vardims = h.dimsset(vlist_c);
    vardims_u = unique(vardims);
    if length(vardims_u) > 1
        m_print_varsummary(h)
        m1 = ' You have chosen a set of variables with non-matching dimensions ';
        m2 = ' Inspect the ''dims'' column in the header and choose a different set ';
        m4 = [' your variable list was ' sprintf('%d ',vlist_c) ' for the control variables'];
        fprintf(MEXEC_A.Mfider,'%s\n',' ',m1,m2,m4);
        continue
    end

    copylistok = 0;
    while copylistok == 0
        m = sprintf('%s\n','Type variable names or numbers to copy after selection ( ''/'' for all):');
        var = m_getinput(m,'s');
        if strncmp('/',var,1) % find all variables with matching dimensions
            udim = vardims_u{1}; %this is the unique dimension set used for picking
            kmatch = strmatch(udim,h.dimsset,'exact');
            var = sprintf('%d ',kmatch);
        end
        vlist = m_getvlist(var,h);
        if ~MEXEC_G.quiet; disp(['list is ' sprintf('%d ',vlist)]); end

        % check all relevant variables have the same dimensions
        vlist_all = [vlist(:)' vlist_c(:)'];
        vardims = h.dimsset(vlist_all);
        vardims_u = unique(vardims);
        if length(vardims_u) > 1
            m_print_varsummary(h)
            m1 = ' You have chosen a set of variables with non-matching dimensions ';
            m2 = ' Inspect the ''dims'' column in the header and choose a different set ';
            m3 = [' your variable list was ' sprintf('%d ',vlist) ' for the copy variables'];
            m4 = [' your variable list was ' sprintf('%d ',vlist_c) ' for the control variables'];
            fprintf(MEXEC_A.Mfider,'%s\n',' ',m1,m2,m3,m4);
            continue
        end
        copylistok = 1;
    end


    % we have a unique dimension set
    rl = h.rowlength;
    cl = h.collength;
    v = str2num(vardims_u{1});
    nrows = rl(v);
    ncols = cl(v);

    % check that the dimension set is Mx1 or 1xN; datpik doesn't make sense
    % for MxN data

    if min(nrows,ncols) > 1
        m1 = ['You have chosen to work with vars of dimension ' sprintf('%d',nrows) ' x ' sprintf('%d',ncols) ];
        m2 = ['mdatpik only makes sense on vars of dimension Mx1 or 1xN'];
        fprintf(MEXEC_A.Mfider,'%s\n',m1,m2);
        continue
    end


    % find index of vars to copy

    numcontrols = size(control,1);

    klogall = [];
    for k = 1:numcontrols
        if (kselect == 1 | kselect == 2); % then it is a 'within' selection
            varnum = control(k,1);
            varnam = h.fldnam{varnum};
            var = nc_varget(ncfile_in.name,varnam);
            % use logical vars
            klog1 = var >= control(k,2);
            klog2 = var <= control(k,3);
            klog = klog1 & klog2; %
            if isempty(klogall) % first pass
                klogall = klog;
            else % combine klog with previous selections
                if kselect == 2
                    klogall = klogall & klog; % require all controls to be satisfied
                else
                    klogall = klogall | klog; % require any of the controls to be satisfied
                end
            end
        else % it is an 'outside' selection
            varnum = control(k,1);
            varnam = h.fldnam{varnum};
            var = nc_varget(ncfile_in.name,varnam);
            % use logical vars
            klog1 = var <= control(k,2);
            klog2 = var >= control(k,3);
            klog = klog1 | klog2; %
            if isempty(klogall) % first pass
                klogall = klog;
            else % combine klog with previous selections
                if kselect == 0
                    klogall = klogall & klog; % require all controls to be satisfied
                else
                    klogall = klogall | klog; % require any of the controls to be satisfied
                end
            end
        end
    end

    indexall = find(klogall);

    numcopy = length(indexall);
    if numcopy == 0
        fprintf(MEXEC_A.Mfider,'\n%s\n','No data cycles selected');
        continue
    end


    m = ['Selection made, now copying ' sprintf('%d',numcopy) ' data cycles and ' sprintf('%d',length(vlist)) ' variables'];
    disp(m)

    if nrows == 1; indexallrows = 1; indexallcols = indexall; end
    if ncols == 1; indexallcols = 1; indexallrows = indexall; end

    for k = 1:length(vlist)
        vname = h.fldnam{vlist(k)};
        if ~MEXEC_G.quiet
        m = ['Copying variable ' vname];
        fprintf(MEXEC_A.Mfidterm,'%s\n',m);
	end
        m_copy_variable(ncfile_in,vname,ncfile_ot,vname,indexallrows,indexallcols);
    end

    % now identify any vars with non-matching dimensions and copy them

    udim = vardims_u{1}; %this is the unique dimension set used for picking
    kmatch = strmatch(udim,h.dimsset,'exact');
    allvars = [1:h.noflds];
    kdiff = setdiff(allvars,kmatch);
    if isempty(kdiff) % there are no other vars with other dimensions
        continue
    end

    m = ['Now copying ' sprintf('%d',length(kdiff)) ' variables with other dimensions'];
    disp(m)

    for k = kdiff(:)'
        vname = h.fldnam{k};
        if ~MEXEC_G.quiet
        m = ['Copying variable ' vname];
        fprintf(MEXEC_A.Mfidterm,'%s\n',m);
	end
        m_copy_variable(ncfile_in,vname,ncfile_ot,vname);
    end

end


% --------------------



m_finis(ncfile_ot);

h = m_read_header(ncfile_ot);
if ~MEXEC_G.quiet; m_print_header(h); end

hist = h;
hist.filename = ncfile_ot.name;
MEXEC_A.Mhistory_ot{1} = hist;
m_write_history;


return
