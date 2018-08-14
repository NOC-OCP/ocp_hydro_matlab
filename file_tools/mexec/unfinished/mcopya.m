function mcopya(varargin)

% copy selected vars and data cycles to a new output file

m_common
m_margslocal
m_varargs

MEXEC_A.Mprog = 'mcopya';
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

while 1 > 0

    m = sprintf('%s\n','Type variable names or numbers to copy (return to end, ''/'' for all):');
    var = m_getinput(m,'s');
    if strcmp(' ',var) == 1; break; end
    if strcmp('/',var) == 1; var = ['1~' sprintf('%d',h.noflds)]; end

    vlist = m_getvlist(var,h);
    m = ['list is ' sprintf('%d ',vlist) ];
    disp(m);

    % check that we have selected vars with consistent dimensions
    vardims = h.dimsset(vlist);
    vardims_u = unique(vardims);
    if length(vardims_u) > 1
        m_print_varsummary(h)
        disp(' ')
        disp(' You have chosen a set of variables with non-matching dimensions ')
        disp(' Inspect the ''dims'' column in the header and choose a different set ')
        disp(' ')
        m = ['your list was ' sprintf('%d ',vlist) ];
        disp(m);
        disp(' ')
        continue
    end

    % we have a unique dimension set
    rl = h.rowlength;
    cl = h.collength;
    v = str2num(vardims_u{1});
    nrows = rl(v);
    ncols = cl(v);

    if min(nrows,ncols) == 1 % non-gridded data
        ncycle = max(nrows,ncols);

        % now get the cycle numbers

        m = 'Enter START STOP cycle numbers (return for 1 END)  ';
        reply = m_getinput(m,'s');
        if strcmp(' ',reply) == 1
            lwr = 1;
            upr = ncycle;
        else
            cmd = ['lims = [' reply '];']; %convert char response to number
            eval(cmd);
            lwr = lims(1);
            upr = lims(2);
        end
        indexall = lwr:upr;

        while 1 > 0
            m = 'Enter additional cycles to copy   ';
            m = 'Enter START STOP cycle numbers (return to start copying)  ';
            reply = m_getinput(m,'s');
            if strcmp(' ',reply) == 1; break; end
            cmd = ['lims = [' reply '];']; %convert char response to number
            eval(cmd);
            lwr = lims(1);
            upr = lims(2);
            index = lwr:upr;
            indexall = [indexall index];
        end
        if nrows == 1; indexallrows = 1; indexallcols = indexall; end
        if ncols == 1; indexallcols = 1; indexallrows = indexall; end

%         for k = 1:length(vlist)
%             vname = h.fldnam{vlist(k)};
%             m_copy_variable(ncfile_in,vname,ncfile_ot,vname,indexallrows,indexallcols);
%         end
% mod by bak at NOC after jc032: display to terminal the number of datacycles to
% be copied
        for k = vlist
            vname = h.fldnam{k};
            numdc = length(indexallrows)*length(indexallcols);
            if ~MEXEC_G.quiet
            m = ['Copying ' sprintf('%8d',numdc) ' datacycles for variable '  vname ];
            fprintf(MEXEC_A.Mfidterm,'%s\n',m);
	    end
            m_copy_variable(ncfile_in,vname,ncfile_ot,vname,indexallrows,indexallcols);
        end
    else
        % we have gridded data; select index for rows and columns
        % separately
        m_print_varsummary(h)
        disp(' ')
        disp('These variables have non-unity ROWS and COLUMNS ');
        disp(' ')
         m = 'Enter START STOP __ row __ numbers (return for 1 END)  ';
        reply = m_getinput(m,'s');
        if strcmp(' ',reply) == 1
            lwr = 1;
            upr = nrows;
        else
            cmd = ['lims = [' reply '];']; %convert char response to number
            eval(cmd);
            lwr = lims(1);
            upr = lims(2);
        end
        indexallrows = lwr:upr;

        while 1 > 0
            m = 'Enter additional __ rows __ to copy   ';
            m = 'Enter START STOP __ row __ numbers (return to select cols)  ';
            reply = m_getinput(m,'s');
            if strcmp(' ',reply) == 1; break; end
            cmd = ['lims = [' reply '];']; %convert char response to number
            eval(cmd);
            lwr = lims(1);
            upr = lims(2);
            indexrows = lwr:upr;
            indexallrows = [indexallrows indexrows];
        end
        
        disp(' ')
         m = 'Enter START STOP __ col __ numbers (return for 1 END)  ';
        reply = m_getinput(m,'s');
        if strcmp(' ',reply) == 1
            lwr = 1;
            upr = ncols;
        else
            cmd = ['lims = [' reply '];']; %convert char response to number
            eval(cmd);
            lwr = lims(1);
            upr = lims(2);
        end
        indexallcols = lwr:upr;

        while 1 > 0
            m = 'Enter additional __ cols __ to copy   ';
            m = 'Enter START STOP __ col __ numbers (return to start copying)  ';
            reply = m_getinput(m,'s');
            if strcmp(' ',reply) == 1; break; end
            cmd = ['lims = [' reply '];']; %convert char response to number
            eval(cmd);
            lwr = lims(1);
            upr = lims(2);
            indexcols = lwr:upr;
            indexallcols = [indexallcols indexcols];
        end

%         for k = 1:length(vlist)
%             vname = h.fldnam{vlist(k)};
%             m_copy_variable(ncfile_in,vname,ncfile_ot,vname,indexallrows,indexallcols);
%         end
% mod by bak at NOC after jc032: display to terminal the number of datacycles to
% be copied
        for k = vlist
            vname = h.fldnam{k};
            numdc = length(indexallrows)*length(indexallcols);
            if ~MEXEC_G.quiet
            m = ['Copying ' sprintf('%8d',numdc) ' datacycles for variable '  vname ];
            fprintf(MEXEC_A.Mfidterm,'%s\n',m);
	    end
            m_copy_variable(ncfile_in,vname,ncfile_ot,vname,indexallrows,indexallcols);
        end
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
