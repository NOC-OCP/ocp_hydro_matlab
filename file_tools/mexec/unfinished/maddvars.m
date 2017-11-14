function maddvars(varargin)

% add vars from one file to a second file

m_common
m_margslocal
m_varargs

MEXEC_A.Mprog = 'maddvars';
if ~MEXEC_G.quiet; m_proghd; end

fprintf(MEXEC_A.Mfidterm,'%s','Enter name of input disc file  ')
fn_in = m_getfilename;
fprintf(MEXEC_A.Mfidterm,'%s','Enter name of output disc file ')
fn_ot = m_getfilename;
ncfile_in.name = fn_in;
ncfile_ot.name = fn_ot;

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
    m_copy_variable(ncfile_in,vname,ncfile_ot,vname);
end


m = 'Now get details of next input file ';
fprintf(MEXEC_A.Mfidterm,'%s\n',m)
fprintf(MEXEC_A.Mfidterm,'%s\n','Enter name of input disc file')
fn_in2 = m_getfilename;
ncfile_in2.name = fn_in2;

ncfile_in2 = m_openin(ncfile_in2);

h2 = m_read_header(ncfile_in2);
if ~MEXEC_G.quiet; m_print_header(h2); end

hist = h2;
hist.filename = ncfile_in2.name;
MEXEC_A.Mhistory_in{2} = hist;


m = sprintf('%s\n','Type variable names or numbers to copy (return for none, ''/'' for all): ');
var = m_getinput(m,'s');
if strcmp(' ',var) == 1;
    vlist2 = [];
else
    vlist2 = m_getvlist(var,h2);
    m = ['list is ' sprintf('%d ',vlist2) ];
    disp(m);
end

for k = vlist2
    vname = h2.fldnam{k};
    kmat = strmatch(vname,h.fldnam(vlist),'exact');
    if ~isempty(kmat) % attempting to copy a variable that has already been taken from first file
        m1 = ['attempting to copy a variable                    ' vname ];
        m2 = ['that has already been copied from first input file'];
        m3 = ['you need to rename the variable for output'];
        fprintf(MEXEC_A.Mfider,'%s\n',m1,m2,m3)

        ok = 0;
        while ok == 0;
            m3 = sprintf('%s',['type new variable name for output :              ']);
            newname = m_getinput(m3,'s');
            if strcmp(newname,' ') | strcmp(newname,'/');
                m = 'try again';
                fprintf(MEXEC_A.Mfider,'%s\n',m)
                continue
            end
            newname = m_remove_outside_spaces(newname);
            newname = m_check_nc_varname(newname);
            ok = 1;
        end
    else
        newname = vname;
    end
    
    numdc = h2.dimrows(k)*h2.dimcols(k);
    if ~MEXEC_G.quiet
    m = ['Copying ' sprintf('%8d',numdc) ' datacycles for variable '  vname ];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m);
    end
    m_copy_variable(ncfile_in2,vname,ncfile_ot,newname);
end


% finish up

m_finis(ncfile_ot);

h = m_read_header(ncfile_ot);
if ~MEXEC_G.quiet; m_print_header(h); end

hist = h;
hist.filename = ncfile_ot.name;
MEXEC_A.Mhistory_ot{1} = hist;
m_write_history;


return






