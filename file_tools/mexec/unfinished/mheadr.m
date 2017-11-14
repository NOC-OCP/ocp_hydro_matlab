function mheadr(varargin)

% change header data

m_common
m_margslocal
m_varargs

MEXEC_A.Mprog = 'mheadr';
if ~MEXEC_G.quiet; m_proghd; end

fn = m_getfilename; % this uses the optional argument if there is one
ncfile.name = fn;

m = 'Output file will be same as input file. OK ? Type y to proceed ';
reply = m_getinput(m,'s');
if strcmp(reply,'y') ~= 1
    disp('exiting');
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
h = m_editheader(h,ncfile);
m_write_header(ncfile,h);

% --------------------


m_finis(ncfile);

h = m_read_header(ncfile);
if ~MEXEC_G.quiet; m_print_header(h); end

hist = h;
hist.filename = ncfile.name;
MEXEC_A.Mhistory_ot{1} = hist;
m_write_history;


return