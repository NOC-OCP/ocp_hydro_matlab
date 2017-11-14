function mcalib2(varargin)

% calibrate a variable, writing output back to the same variable
% JC032 mcalib2: allow multiple independent variables.
% needs a new name because not compatible with mcalib i/o.
% but completely supercedes mcalib. mcalib should eventually be removed
% from scripts. use mcalib2 instead.
m_common
m_margslocal
m_varargs

MEXEC_A.Mprog = 'mcalib2';
if ~MEXEC_G.quiet; m_proghd; end


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
% now prompt for details of new calculations
% BAK on JC032: significant upgrade: allow function of many independent
% vars, eg adjust oxygen with a dependence on oxygen, pressure, .....
% chunk of code lifted in from mcalc that already allows this
% first establish the output variable:
while 1 > 0
    m = 'Type variable name or number to calibrate (return to finish): ';
    var = m_getinput(m,'s');
    if strcmp(' ',var) == 1; break; end
    depvarnum = m_getvlist(var,h);
    x = nc_varget(ncfile.name,h.fldnam{depvarnum});
    y = x; %default if empty return for equation

    % now establish the independent vars, if this is a genuine 'calibration' the list will also include the
    % output variable.
    endflag = 0;
    while endflag == 0
        m = 'Type variable names or numbers of independent variables [x,y,z,...] (return or 0 to finish): ';
        m1 = sprintf('%s\n',m);
        var = m_getinput(m1,'s');
        if strncmp(' ',var,1) == 1; break; end
        if strncmp('0',var,1) == 1; break; end
        indvarnums = m_getvlist(var,h);
        % check all independent variables have the same dimensions
        vardims = h.dimsset(indvarnums);
        vardims_u = unique(vardims);
        if length(vardims_u) > 1
            m_print_varsummary(h)
            m1 = ' Warning: ';
            m2 = ' You have chosen a set of variables with non-matching dimensions ';
            m3 = ' If this wasn''t intentional, you should inspect the ''dims'' column ';
            m3a = 'in the header and choose a different set ';
            m4 = [' your variable list was ' sprintf('%d ',varnum) ' for the independent variables'];
            fprintf(MEXEC_A.Mfider,'%s\n',' ',m1,m2,m3,m3a,m4,' ');
            %         disp(m)
            %         continue % Warning only, becase you may wish to combine vars of
            %         differing diemnsion
        end

        nextx = 0;
        for k = 1:length(indvarnums)
            nextx = nextx+1;
            cmd = ['x' sprintf('%d',nextx) ' = nc_varget(ncfile.name,h.fldnam{indvarnums(k)});'];
            eval(cmd);
        end
        % following is equivalent to [xc xr] = meshgrid([1:ncols],[1:nrows]);
        nrows = size(x1,1); ncols = size(x1,2);
        xr = (1:nrows); xr = xr(:); xr = repmat(xr,1,ncols);
        xc = (1:ncols); xc = xc(:)'; xc = repmat(xc,nrows,1);
        xdc = (1:numel(x1));
        xdc = reshape(xdc,nrows,ncols);
        endeq = 0;
        while endeq == 0;
            m1 = sprintf('%s','Type calibration algorithm using y and x1,x2,x3,... in the form y = f(x)');
            m2 = sprintf('%s','The sequence of x vars corresponds to the order of independent variables');
            m3 = sprintf('%s','This will become the matlab equation exactly as you type it');
            m4 = sprintf('%s','To multiply two variables use the matlab syntax x1 .* x2');
            m5 = sprintf('%s','For example y = 1.2 + 2.4*x1 + 3*x2.*x3');
            m6 = sprintf('%s','or          y = sin(x1*pi/180)');
            m7 = sprintf('%s','use xdc,xr or xc to denote the data cycle, row or column index');
            m = sprintf('%s\n',' ',m1,m2,m3,m4,m5,m6,m7);
            eq = m_getinput(m,'s');
            if strncmp(' ',eq,1) == 1;
                % no calibration
                x = nc_varget(ncfile.name,h.fldnam{depvarnum});
                eq = 'y=x'; %default if empty return for equation
                break; 
            end
            endeq = 1;
        end
        clear y;
        cmd = [eq ';']; eval(cmd);
        endflag = 1; % only one pass through when used in mcalib
    end

    % output the data

    nc_varput(ncfile.name,h.fldnam{depvarnum},y); %variable y contains the calibrated data

    m = ' Choose new name for calibrated variable ? (return or / for no change) ';
    newname = m_getinput(m,'s');
    if strncmp(' ',newname,1) == 1;
    elseif strncmp('/',newname,1) == 1;
    else
        nc_varrename(ncfile.name,h.fldnam{depvarnum},newname);
        h = m_read_header(ncfile);
    end

    m = ' Choose new units for calibrated variable ? (return or / for no change) ';
    newunits = m_getinput(m,'s');
    if strncmp(' ',newunits,1) == 1;
    elseif strncmp('/',newunits,1) == 1;
    else
        nc_attput(ncfile.name,h.fldnam{depvarnum},'units',newunits);
    end
    % bak on di346 17 feb 2010. Bug fix. calculate uprlwr for each var as
    % you go round the loop. Was previously outside loop so only updated
    % final var.
    m_uprlwr(ncfile,h.fldnam{depvarnum});


end % of main calib loop

h = m_read_header(ncfile);
if ~MEXEC_G.quiet; m_print_varsummary(h); end
% --------------------




m_finis(ncfile);

h = m_read_header(ncfile);
if ~MEXEC_G.quiet; m_print_header(h); end

hist = h;
hist.filename = ncfile.name;
MEXEC_A.Mhistory_ot{1} = hist;
m_write_history;


return