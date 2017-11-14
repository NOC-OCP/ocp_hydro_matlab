function muvsd(varargin)
% function muvsd(varargin)
%
% u,v to speed,direction
% using call to mcalc

m_common
m_margslocal
m_varargs

MEXEC_A.Mprog = 'muvsd';
if ~MEXEC_G.quiet; m_proghd; end



prog = MEXEC_A.Mprog; % save for later


fprintf(MEXEC_A.Mfidterm,'%s\n','Enter name of input disc file')
fn_in = m_getfilename;
fprintf(MEXEC_A.Mfidterm,'%s\n','Enter name of output disc file')
fn_ot = m_getfilename;
ncfile_in.name = fn_in;
ncfile_ot.name = fn_ot;

ncfile_in = m_openin(ncfile_in);
h = m_read_header(ncfile_in);
if ~MEXEC_G.quiet; m_print_header(h); end



m = sprintf('%s\n','Type variable names or numbers to copy (return for none, ''/'' for all): ');
varcopy = m_getinput(m,'s');



m1 = ' Which option ? ';
m2 = ' 1 Convert E & N to Speed & Direction (default)';
m3 = ' 2 Convert Speed & Direction to E & N';
m = sprintf('%s\n',' ',m1,m2,m3);
var = m_getinput(m,'s');
if strcmp(var,' ') == 1; var = '1'; end
if strcmp(var,'1') == 1
    m = 'Type variable names or numbers of east & north speed: ';
    m1 = sprintf('%s\n',m);
    var2 = m_getinput(m1,'s');
    enlist = m_getvlist(var2,h);

    m = 'speed variable name : ';
    name1 = m_getinput(m,'s');
    m = 'speed units (return to use same as ''east'') : ';
    units1 = m_getinput(m,'s');
    if strncmp(' ',units1,1) == 1; units1 = h.fldunt{enlist(1)}; end

    m = 'direction variable name : ';
    name2 = m_getinput(m,'s');
    m = 'direction units (return to use ''degrees'') : ';
    units2 = m_getinput(m,'s');
    if strncmp(' ',units2,1) == 1; units2 = 'degrees'; end
    
    eq1 = 'y = sqrt(x1.*x1 + x2.*x2)';
    eq2 = 'y = mcrange(atan2(x1,x2)*180/pi,0,360)'; % modded on jc032 to use mcrange to (0,360);
else
    m = 'Type variable names or numbers of speed and direction: ';
    m1 = sprintf('%s\n',m);
    var2 = m_getinput(m1,'s');
    sdlist = m_getvlist(var2,h);

    m = 'east variable name : ';
    name1 = m_getinput(m,'s');
    m = 'east units (return to use same as ''speed'') : ';
    units1 = m_getinput(m,'s');
    if strncmp(' ',units1,1) == 1; units1 = h.fldunt{sdlist(1)}; end

    m = 'north variable name : ';
    name2 = m_getinput(m,'s');
    m = 'north units (return to use same as ''speed'') : ';
    units2 = m_getinput(m,'s');
    if strncmp(' ',units2,1) == 1; units2 = 'degrees'; end
    
    eq1 = 'y = x1 .* cos((90-x2)*pi/180)';
    eq2 = 'y = x1 .* sin((90-x2)*pi/180)';

end

hist = h;
hist.filename = ncfile_in.name;
history_in{1} = hist;

%--------------------------------
margsin = {
    fn_in
    fn_ot
    varcopy
    var2
    eq1
    name1
    units1
    var2
    eq2
    name2
    units2
    '0'
    };

% return
margs = MEXEC_A.MARGS_OT; % keep a record of input arguments for this prog
MEXEC_A.Mhistory_skip = 1;
% mcalc(fn_in,fn_ot,varcopy,var2,eq1,name1,units1,var2,eq2,name2,units2,'0')
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
