function mlist(varargin)
% function mlist(varargin)
%
% list data

m_common
m_margslocal
m_varargs

MEXEC_A.Mprog = 'mlist';
if ~MEXEC_G.quiet; m_proghd; end


fn = m_getfilename; % this uses the optional argument if there is one
ncfile.name = fn;
ncfile = m_ismstar(ncfile); %check it is an mstar file and that it is not open

h = m_read_header(ncfile);
if ~MEXEC_G.quiet; m_print_header(h); end

listold = '/';
while 1 > 0
    m1 = 'Type variable names or numbers to display ';
    m2 = '(or return to finish, ''/'' for all, ''s'' for same set):';
    m = sprintf('%s\n',m1,m2);
    var = m_getinput(m,'s');
    if strcmp(' ',var) == 1; break; end
    if strcmp('s',var) == 1;
        var = listold;
    end
    listold = var;

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

    ktime = zeros(1,length(vlist)); % This will be zero, or 1 if the variable is a time variable
    for ktime2 = 1:length(vlist)
        if m_isvartime(h.fldnam{vlist(ktime2)}) == 1; ktime(ktime2) = 1; end
    end
        
    if sum(ktime) > 0 %there are some time variables
        m1 = ['Convert time variables to yymodd hhmmss ?'];
        m2 = ['reply ''y'' (default) or ''n'''];
        fprintf(MEXEC_A.Mfidterm,'%s\n',m1,m2);
        ktconvert = 1;
        okreply = 0;
        while okreply == 0
            reply = m_getinput(' ','s');
            if strcmp(' ',reply) == 1; ktconvert = 1; break; end
            if strcmp('/',reply) == 1; ktconvert = 1; break; end
            if strcmp('y',reply) == 1; ktconvert = 1; break; end
            if strcmp('n',reply) == 1; ktconvert = 0; break; end
            fprintf(MEXEC_A.Mfider,'\n%s\n','You must reply one of ''y'' ''/'' return or ''n'' : ');
        end
    end
    
    h1 = ' ***********';
    hnames = ' data_cycle*';
    hunits = '     number*';
    for k = 1:length(vlist)
        vnum = vlist(k);
        lenfn = 10;
        if (abs(h.alrlim(vnum)) < 0.1) & (abs(h.uprlim(vnum)) < 0.1)
            lenfn = 12;
        end
        if (abs(h.alrlim(vnum)) > 99999.99) | (abs(h.uprlim(vnum)) > 99999.99)
            lenfn = 12;
        end
        if ktime(k) == 1 & ktconvert == 1 % then this var must be converted using its units
            lenfn = 17;
        end

        fn = h.fldnam{vnum};
        if length(fn) > lenfn
            fn = [fn(1:lenfn-1) '@'];
        end
        
        fu = h.fldunt{vnum};
        if ktime(k) == 1 & ktconvert == 1 % then this unit must be converted using its units
            fu = 'yymodd doy hhmmss';
        end
        if length(fu) > lenfn
            fu = [fu(1:lenfn-1) '@'];
        end
        cmd = ['hnames = [hnames sprintf(''%' sprintf('%2d',lenfn) 's '',fn)];'];
        eval(cmd);
        cmd = ['hunits = [hunits sprintf(''%' sprintf('%2d',lenfn) 's '',fu)];'];
        eval(cmd);
        longstar = '*******************';
        h1 = [h1 '  ' longstar(1:lenfn-2) ' '];
    end

    vall = [];
    form = ' %10d'; %format for data cycle number
    for k = 1:length(vlist)
        vnum = vlist(k);
        vnam = h.fldnam{vnum};
        vform = ' %10.3f';
        if (abs(h.alrlim(vnum)) < 0.1) & (abs(h.uprlim(vnum)) < 0.1)
            vform = ' %12.5e';
        end
        if (abs(h.alrlim(vnum)) > 99999.99) | (abs(h.uprlim(vnum)) > 99999.99)
            vform = ' %12.5e';
        end
        if ktime(k) == 1 & ktconvert == 1 % then this var must be converted using its units
            vform = ' %02d%02d%02d %3d %02d%02d%02d';
        end

        form = [form vform];
    end


    eflag = 0;
    while eflag == 0

        nrows = h.dimrows(vlist(1));
        ncols = h.dimcols(vlist(1));
        ncycles = nrows*ncols;

        m1 = ['Enter START, STOP, [STEP] cycle numbers (return for 1 ' sprintf('%d',ncycles) ' 1)  '];
        m2 = sprintf('%s\n',m1);
        reply = m_getinput(m2,'s');
        if strcmp(' ',reply) == 1
            lwr = 1;
            upr = ncycles;
            step = 1;
        else       % pad with some spaces to ensure there are always some spaces outside commas
            reply = ['  ' reply '  '];
            kc = strfind(reply,',');
            if isempty(kc) % no commas so unpick numbers
                cmd = ['lims = [' reply '];']; %convert char response to number
                eval(cmd);
                lwr = lims(1);
                upr = lims(2);
                if length(lims) == 2;
                    step = 1;
                else
                    step = lims(3);
                end
            elseif length(kc) == 1
                % add ,1 so now it is a complete comma delimited string
                reply = [reply ',1']
                kc = strfind(reply,',');
                r1 = m_remove_spaces(reply(1:kc(1)-1));
                r2 = m_remove_spaces(reply(kc(1)+1:kc(2)-1));
                r3 = m_remove_spaces(reply(kc(2)+1:end));
                lwr = str2num(r1); if isempty(lwr); lwr = 1; end
                upr = str2num(r2); if isempty(upr); upr = ncycles; end
                step = str2num(r3); if isempty(step); step = 1; end
            elseif length(kc) == 2
                r1 = m_remove_spaces(reply(1:kc(1)-1));
                r2 = m_remove_spaces(reply(kc(1)+1:kc(2)-1));
                r3 = m_remove_spaces(reply(kc(2)+1:end));
                lwr = str2num(r1); if isempty(lwr); lwr = 1; end
                upr = str2num(r2); if isempty(upr); upr = ncycles; end
                step = str2num(r3); if isempty(step); step = 1; end
            else
                m = 'Problem unpicking START STOP END string';
                m2 = 'Use format like [1,10,2] or even [ , , 10]';
                fprintf(fider,'%s\n',' ',m,m2,' ');
                continue
            end
        end
        eflag = 1;
    end
    index = lwr:step:upr;

    fidlist = fopen('mlist_out','w');

    fprintf(fidlist,'%s\n',h1)
    fprintf(fidlist,'%s\n',hnames)
    fprintf(fidlist,'%s\n',hunits)
    fprintf(fidlist,'%s\n',h1)


    
    for ki = 1:length(index)
        vall = [];
        for k = 1:length(vlist)
            vnum = vlist(k);
            vnam = h.fldnam{vnum};
            [row col] = m_index_to_rowcol(index(ki),h,vnum);
            vdata = nc_varget(ncfile.name,vnam,[row-1 col-1],[1 1]);
            vdata = reshape(vdata,numel(vdata),1);
            %             if ~isempty(find(k_tconvert == k)) % then this var must be converted assuming it is decimal days
            if ktime(k) == 1 & ktconvert == 1 % then this var must be converted using its units
                [yy mo dd hh mm ss dayofyear] = m_time_to_ymdhms(vnam,vdata,h);
                vdata = [yy-2000 mo dd dayofyear hh mm round(ss)]; % ss is rounded in m_time_to_ymdhms, but need to force it to integer
                if vdata(1) < 0; vdata(1) = vdata(1)+100; end % this will only produce a 2-digit year if 1900 <= yy <= 2099
            end

            vall = [vall vdata];
        end
        vall = [index(ki) vall];
        s = sprintf(form,vall(1,:));
        fprintf(fidlist,'%s\n',s);
    end
    
    fclose(fidlist);

end

return
