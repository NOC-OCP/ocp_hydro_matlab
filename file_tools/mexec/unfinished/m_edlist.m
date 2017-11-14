% script to edit something

    vlist = m_getvlist([xname ' ' yname],h);
    m = ['list is ' sprintf('%d ',vlist) ];
    disp(m);


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

    
    index = x1-1+kfind{vared}(:)';

    disp(h1)
    disp(hnames)
    disp(hunits)
    disp(h1)


    for ki = 1:length(index)
        vall = [];
        for k = 1:length(vlist)
            vnum = vlist(k);
            vnam = h.fldnam{vnum};
            [row col] = m_index_to_rowcol(index(ki),h,vnum);
            vdata = nc_varget(pdfot.ncfile.name,vnam,[row-1 col-1],[1 1]);
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
        fprintf(MEXEC_A.Mfidterm,'%s\n',s);
    end


return
