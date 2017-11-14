function mcalc(varargin)

% perform a calculation g = f(x,y,z,....)
% where the user specifies the algorithm
%
% return multiple output argments in a structure, see mcarter for an
% example
%
% Thus any output function can be built from an arbitrary number of
% input independent variables
%
% xr = [1 1 1
%       2 2 2
%       3 3 3]
%
% xc = [1 2 3
%       1 2 3
%       1 2 3]
%
% xdc = [1 2 3]
% or
% xdc = [1
%        2
%        3]
% or
% xdc = [1 4 7
%        2 5 8
%        3 6 9]
%
% YLF edited 12/2015 (jr15003): in case name supplied in varargin is 
% already used in output file, get new name from matlab command line 
% not from next varargin (which may be units)

m_common
m_margslocal
m_varargs

MEXEC_A.Mprog = 'mcalc';
if ~MEXEC_G.quiet; m_proghd; end


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

%copy selected vars from the infile
m = sprintf('%s\n','Type variable names or numbers to copy (return for none, ''/'' for all): ');
var = m_getinput(m,'s');
if strcmp(' ',var) == 1;
    vlist = [];
else
    vlist = m_getvlist(var,h);
    m = ['list is ' sprintf('%d ',vlist) ];
    disp(m);
end

for k = vlist
    vname = h.fldnam{k};
    numdc = h.dimrows(k)*h.dimcols(k);
    if ~MEXEC_G.quiet
    m = ['Copying ' sprintf('%8d',numdc) ' datacycles for variable '  vname ];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m);
    end
    tic; m_copy_variable(ncfile_in,vname,ncfile_ot,vname); if ~MEXEC_G.quiet; disp(toc); end
end

% now prompt for details of new calculations
endflag = 0;
while endflag == 0
    m = 'Type variable names or numbers of independent variables [x,y,z,...] (return or 0 to finish): ';
    m1 = sprintf('%s\n',m);
    var = m_getinput(m1,'s');
    if strncmp(' ',var,1) == 1; break; end
    if strncmp('0',var,1) == 1; break; end
    varnum = m_getvlist(var,h);
    % check all independent variables have the same dimensions
    vardims = h.dimsset(varnum);
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
    for k = 1:length(varnum)
        nextx = nextx+1;
        cmd = ['x' sprintf('%d',nextx) ' = nc_varget(ncfile_in.name,h.fldnam{varnum(k)});'];
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
        if strncmp(' ',eq,1) == 1; break; end
        endeq = 1;
    end
    clear y
    cmd = [eq ';']; eval(cmd);

    % return multiple output variables from the function call by returning
    % them as fields in a structure
    numout = 1;
    if isstruct(y)
        % extract default names and units if present
        if isfield(y,'default_names')
            y_default_names = y.default_names;
            y = rmfield(y,'default_names');
        end
        if isfield(y,'default_units')
            y_default_units = y.default_units;
            y = rmfield(y,'default_units');
        end
    else
        % y was a simple variable. Turn it into a structure for
        % convenience, and create default name and units from x1 variable.
        var1 = y;
        clear y;
        y.var1 = var1;
        clear var1;
        y_default_names = h.fldnam(varnum(1)); % cell array
        y_default_units = h.fldunt(varnum(1)); % cell array

    end
    struct_var_names = fieldnames(y);
    numout = length(struct_var_names);

    
    % now process the output variables. They will get default attributes for
    % fillvalue
    for kout = 1:numout
        clear v
        fieldnam = struct_var_names{kout};
        defnam = y_default_names{kout};
        defunt = y_default_units{kout};
        cmd = ['v.data = y.' fieldnam ';']; eval(cmd);

        m = ['new variable name, default is : ' defnam '  '];
        %     fprintf(MEXEC_A.Mfidterm,'%s\n',m);

        ok = 0;
        while ok == 0;
            newname = m_getinput(m,'s');
            if strcmp(newname,' ')
                newname = m_remove_outside_spaces(defnam);
            end

            hot = m_read_header(ncfile_ot);
            kmat = strmatch(newname,hot.fldnam,'exact');
            while ~isempty(kmat)
                m1 = 'That name is already taken in the output file; try again';
                fprintf(MEXEC_A.Mfider,'%s\n',m1)
                newname = input('new variable name','s');
                kmat = strmatch(newname,hot.fldnam,'exact');
            end
            newname = m_remove_outside_spaces(newname);
            v.name = m_check_nc_varname(newname);
            ok = 1;
        end
        %         v.name = m_getinput(m,'s');
        m = ['new variable unit, default is : ' defunt '  '];
        v.units = m_getinput(m,'s');
        if strcmp(v.units,' ')
            v.units = m_remove_outside_spaces(defunt);
        end
        % its a new variable, so the other atributes [_FillValue missing_value] will be default
        m_write_variable(ncfile_ot,v);

    end
end



% --------------------



m_finis(ncfile_ot);

hot = m_read_header(ncfile_ot);
if ~MEXEC_G.quiet; m_print_header(hot); end

hist = hot;
hist.filename = ncfile_ot.name;
MEXEC_A.Mhistory_ot{1} = hist;
m_write_history;


return
