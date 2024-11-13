function mintrp(varargin)

% interpolate a set of variables to fill gaps

m_common
m_margslocal
m_varargs

MEXEC_A.Mprog = 'mintrp';
m_proghd


fn = m_getfilename; % this uses the optional argument if there is one
ncfile.name = fn;

m = 'Output file will be same as input file. OK ? Type y to proceed ';
reply = m_getinput(m,'s');
if strcmp(reply,'y') ~= 1
    disp('exiting')
    return
end

ncfile = m_openio(ncfile);

h = m_read_header(ncfile);
if ~MEXEC_G.quiet; m_print_header(h); end

hist = h;
hist.filename = ncfile.name;
MEXEC_A.Mhistory_in{1} = hist;


% --------------------
% Now do something with the data

ok = 0;
while ok == 0

    m = 'Type variable names or numbers of variables to interpolate (''/'' for all): ';
    m1 = sprintf('%s\n',m);
    var = m_getinput(m1,'s');
    varnum = m_getvlist(var,h);

    mindim = nan+zeros(1,length(varnum));
    for k = 1:length(varnum)
        mindim(k) = min(h.dimrows(varnum(k)),h.dimcols(varnum(k)));
    end

    if max(mindim) > 1
        % at least one variable is 2-D
        if max(mindim) > 1
            m1 = sprintf('%s\n','At least one of your chosen variables has nrows > 1 and ncols > 1');
            m2 = sprintf('%s\n','Do you want to interpolate along rows (r) or down cols (c) of 2-D variables ?');
            m5 = sprintf('%s\n','reply r or c ');
            reply = m_getinput([m1 m2 m5],'s');
            okreply = 0;
            while okreply == 0
                if strcmp('r',reply) == 1; rc = 2; break; end
                if strcmp('c',reply) == 1; rc = 1; break; end
                fprintf(MEXEC_A.Mfider,'\n%s\n','You must reply r or c : ');
                reply = m_getinput(' ','s');
            end
        end
    end

    ok = 0;
    while ok == 0
        m1 = sprintf('%s','Type name or number of control variable :');
        m2 = sprintf('%s','Use ''0'' or ''/'' (default) to interpolate evenly into gaps instead :');
        m = sprintf('%s\n',m1,m2);
        var = m_getinput(m,'s');
        if strcmp(var,'0')
            vcontrol = 0;
        elseif strcmp(var,' ')
            vcontrol = 0;
        elseif strcmp(var,'/')
            vcontrol = 0;
        else
            vlist = m_getvlist(var,h);
            vcontrol = vlist(1);
        end
        ok = 1;
    end

    % if using a control variable, all dimensions must match those of control
    % var. If no control var, each variable handled separately, so
    % dimensions can be anything.

    if vcontrol > 0
        vardims = h.dimsset([vcontrol varnum]);
        vardims_u = unique(vardims);
        if length(vardims_u) > 1
            m_print_varsummary(h)
            m1 = ' You have chosen a set of variables with non-matching dimensions ';
            m2 = ' Inspect the ''dims'' column in the header and choose a different set ';
            m4 = [' your variable list was ' sprintf('%d ',varnum) ' for the control variable'];
            m5 = [' and ' sprintf('%d ',varnum) ' for the interpolated variables'];
            fprintf(MEXEC_A.Mfider,'%s\n',m1,m2,m4,m5);
            continue
        end
    end
    
    ok = 1;

end

m1 = 'Now choose what to do with absent data at the ends of each series.';
m2 = 'You can perform linear extrapolation using the N good values at the end(beginning) of the array.';
m3 = 'Respond N = 1 to copy the end last(first) non-absent value to the end(beginning) of the array.';
m4 = 'Respond N = 0 to perform no extrapolation (default)';
fprintf(MEXEC_A.Mfidterm,'%s\n',m1,m2,m3,m4,' ');

m1 = 'Extrapolation (N) required at start/top of array ?  ';
reply = m_getinput(m1,'s');
e1 = str2num(reply);
m1 = 'Extrapolation (N) required at end/bottom of array ? ';
reply = m_getinput(m1,'s');
e2 = str2num(reply);


if vcontrol > 0
    vc = nc_varget(ncfile.name,h.fldnam{vcontrol});
    if sum(sum(isnan(vc))) > 0
        error('Absent data not permitted in control variable');
    end
end

for kint = 1:length(varnum);
    v = nc_varget(ncfile.name,h.fldnam{varnum(kint)});
    m = ['Interpolating variable ' h.fldnam{varnum(kint)}];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m);
    if m_numdims(v) > 1 % this var is 2-D, so rc will already have been set
        if rc == 1 % interpolate down rows
            if vcontrol == 0;
                nrows = size(v,1); ncols = size(v,2);
                xr = (1:nrows); xr = xr(:); vc = repmat(xr,1,ncols);
            end

            for k = 1:h.dimcols(varnum(kint))
                xi = vc(:,k);
                y = v(:,k);
                yi = m_interp(xi,y,xi,e1,e2);
                v(:,k) = yi;
            end
        elseif rc == 2
            if vcontrol == 0;
                nrows = size(v,1); ncols = size(v,2);
                xc = (1:ncols); xc = xc(:)'; vc = repmat(xc,nrows,1);
            end
            for k = 1:h.dimrows(varnum(kint))
                xi = vc(k,:);
                y = v(k,:);
                yi = m_interp(xi,y,xi,e1,e2);
                v(k,:) = yi;
            end

        end
    else
        % 1-D variable
        if vcontrol == 0;
            vc = 1:length(v);
        end
        xi = vc;
        y = v;
        yi = m_interp(xi,y,xi,e1,e2);
        v = reshape(yi,size(v));
    end
        nc_varput(ncfile.name,h.fldnam{varnum(kint)},v);
        m_uprlwr(ncfile,h.fldnam{varnum(kint)});
end


% --------------------




m_finis(ncfile);

h = m_read_header(ncfile);
if ~MEXEC_G.quiet; m_print_header(h); end

hist = h;
hist.filename = ncfile.name;
MEXEC_A.Mhistory_ot{1} = hist;
m_write_history;


return
