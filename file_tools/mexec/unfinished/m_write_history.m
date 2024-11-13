function m_write_history

% write processing steps in the calling program to a history file
% need to check/think about what happens if there is numerical args instead
% of character

m_common

if isfield(MEXEC_A,'Mhistory_skip');
    if MEXEC_A.Mhistory_skip ~= 0;
        m1 = ' *********** ';
        m2 = [' Skipping write of history from program            ' MEXEC_A.Mprog];
        m3 = [' To restart history ensure global variable MEXEC_A.Mhistory_skip = 0'];
        fprintf(MEXEC_A.Mfider,'%s\n',m1,m1,m2,m3,m1,m1)
        return;
    end
end

history_directory = MEXEC_G.HISTORY_DIRECTORY;

% term = 1;

for k = 1:length(MEXEC_A.Mhistory_ot) % write a history file for the datanames in every output file
    hist = MEXEC_A.Mhistory_ot{k};
    dnames{k} = hist.dataname;
end

dnames_u = unique(dnames);

for k = 1:length(dnames_u)
    % list all input and output filenames
    MEXEC_A.Mhistory_filename = fullfile(history_directory, dnames_u{k});
    fid = fopen(MEXEC_A.Mhistory_filename,'a'); mfixperms(MEXEC_A.Mhistory_filename);
    nlines = 0;
    % BAK 13 Nov 2009: Write the calling tree for the program, so we can
    % see what script a program was called from as well as the program name
    stacklist = dbstack(1); % get calling history but skip the present function
    m1 = '%--------------------------------';
    m2 = ['% ' MEXEC_A.Mprog];
    m3 = ['% ' datestr(now,31)];
    m4 =['% calling history, most recent first'];
    fprintf(fid,'%s\n',m1,m3,m2,m4); nlines = nlines+4;
    for kloop1 = 1:length(stacklist)
        st = stacklist(kloop1);
        m1 = ['%    ' st.name ' in file: ' st.file ' line: ' sprintf('%d',st.line)];
        fprintf(fid,'%s\n',m1); nlines = nlines+1;
    end
    m4 = ['% input files'];
    fprintf(fid,'%s\n',m4); nlines = nlines+1;
    fprintf(MEXEC_A.Mfidterm,'%s\n',m4);
    if isfield(MEXEC_A,'Mhistory_in') ~= 1
        m4a = ['% no input files'];
        fprintf(fid,'%s\n',m4a); nlines = nlines+1;
        fprintf(MEXEC_A.Mfidterm,'%s\n',m4a);
    else
        for kin = 1:length(MEXEC_A.Mhistory_in)
            h = MEXEC_A.Mhistory_in{kin};
            m4 = ['% Filename '  h.filename '   Data Name :  ' h.dataname ' <version> ' sprintf('%d',h.version) ' <site> ' h.mstar_site];
            fprintf(fid,'%s\n',m4); nlines = nlines+1;
            fprintf(MEXEC_A.Mfidterm,'%s\n',m4);
        end
    end
    m5 = ['% output files'];
    fprintf(fid,'%s\n',m5); nlines = nlines+1;
    fprintf(MEXEC_A.Mfidterm,'%s\n',m5);

    for kot = 1:length(MEXEC_A.Mhistory_ot)
        h = MEXEC_A.Mhistory_ot{kot};
        m6 = ['% Filename '  h.filename '   Data Name :  ' h.dataname ' <version> ' sprintf('%d',h.version) ' <site> ' h.mstar_site];
        fprintf(fid,'%s\n',m6); nlines = nlines+1;
        fprintf(MEXEC_A.Mfidterm,'%s\n',m6);
    end

    m = 'MEXEC_A.MARGS_IN = {';
    fprintf(fid,'%s\n',m); nlines = nlines+1;
    for k = 1:length(MEXEC_A.MARGS_OT)
        arg = MEXEC_A.MARGS_OT{k};
        if ischar(arg) == 1
            m = ['''' sprintf('%s',arg) '''']; % add quotes
        elseif isstruct(arg) == 1
            m = sprintf('%s','< structure variable >');
        else
            m = sprintf('%d',arg);
        end
        fprintf(fid,'%s\n',m); nlines = nlines+1;
    end
    m = '};';
    fprintf(fid,'%s\n',m); nlines = nlines+1;
    fprintf(fid,'%s\n',MEXEC_A.Mprog); nlines = nlines+1;
    m = '%--------------------------------';
    fprintf(fid,'%s\n',m); nlines = nlines+1;


    fclose(fid); mfixperms(MEXEC_A.Mhistory_filename);
    
    % bak after jc032
    % when there are many different possible users of a file (instead of a
    % single user as on cruises) we need to ensure group write permission
    % to the history files. This means that in order for processing to work
    % smoothly, all users who are working on a dataset will need to join
    % the relevant unix group.
    [uMEXEC.status uresult] = system(['chmod 664 ' MEXEC_A.Mhistory_filename]);
    
    
    MEXEC_A.Mhistory_lastlines = nlines;
    if ~MEXEC_G.quiet
       m = [sprintf('%d',nlines) ' lines written to history file ' MEXEC_A.Mhistory_filename];
       fprintf(MEXEC_A.Mfidterm,'\n%s\n',m)
    end
end

return
