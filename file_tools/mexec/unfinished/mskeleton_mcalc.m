function mskeleton_mcalc(varargin)


% script to convert u,v to speed,direction
% using call to mcalc

m_common
m_margslocal
m_varargs

MEXEC_A.Mprog = 'mskeleton_mcalc';
m_proghd


prog = MEXEC_A.Mprog; % save for later

fprintf(MEXEC_A.Mfidterm,'%s','Enter name of input disc file  ')
fn_in = m_getfilename;
ncfile_in.name = fn_in;
ncfile_in = m_openin(ncfile_in);
h = m_read_header(ncfile_in);
if ~MEXEC_G.quiet; m_print_header(h); end
hist = h;
hist.filename = ncfile_in.name;
history_in{1} = hist;


fprintf(MEXEC_A.Mfidterm,'%s','Enter name of output disc file  ')
fn_ot = m_getfilename;
ncfile_ot.name = fn_ot;

m = sprintf('%s\n','Type variable names or numbers to copy (return for none, ''/'' for all): ');
varcopy = m_getinput(m,'s');


%--------------------------------


% here's a very simple example convert east and north speed to total speed

m = 'Type variable names or numbers of east & north speed: ';
m1 = sprintf('%s\n',m);
var2 = m_getinput(m1,'s');
enlist = m_getvlist(var2,h);

m = 'speed variable name : ';
name1 = m_getinput(m,'s');
m = 'speed units (return to use same as ''east'') : ';
units1 = m_getinput(m,'s');
if strncmp(' ',units1,1) == 1; units1 = h.fldunt{enlist(1)}; end

eq1 = 'y = sqrt(x1.*x1 + x2.*x2)';

%--------------------------------
margsin = {
    fn_in
    fn_ot
    varcopy
    var2
    eq1
    name1
    units1
    '0'
    };

margs = MEXEC_A.MARGS_OT; % keep a record of input arguments for this prog
MEXEC_A.Mhistory_skip = 1; % don't write a history from the call to mcalc
% mcalc(fn_in,fn_ot,varcopy,var2,eq1,name1,units1,var2,eq2,name2,units2,'0') % can also call mcalc with arguments
MEXEC_A.MARGS_IN = margsin; mcalc
MEXEC_A.Mhistory_skip = 0;
%--------------------------------

MEXEC_A.Mprog = prog;
MEXEC_A.Mhistory_in = history_in; % retrieve value for this prog
MEXEC_A.MARGS_OT = margs;
h = m_read_header(ncfile_ot);
if ~MEXEC_G.quiet; m_print_header(h); end

hist = h;
hist.filename = ncfile_ot.name;
MEXEC_A.Mhistory_ot{1} = hist;
m_write_history;
