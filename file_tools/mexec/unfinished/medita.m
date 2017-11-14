function medita(varargin)

% Edit data that lie outside a range to absent value
% varlist can be names or variable numbers
%
% function medita(ncfile,varlist,rangelist)

% example:
% medita(ncfile,'time u v',[0 -100 -200; 1000 100 200])
% or just type medita and be prompted for input


m_common
m_margslocal
m_varargs

MEXEC_A.Mprog = 'medita';
if ~MEXEC_G.quiet; m_proghd; end


fn = m_getfilename; % this uses the optional argument if there is one
ncfile.name = fn;
ncfile = m_ismstar(ncfile); %check it is an mstar file and that it is not open

m = 'Output file will be same as input file. OK ? Type y to proceed ';
reply = m_getinput(m,'s');
if strcmp(reply,'y') ~= 1
    disp('exiting')
    return
end

ncfile = m_openio(ncfile);

% ncfile.name = m_add_nc(ncfile.name);
h = m_read_header(ncfile);
if ~MEXEC_G.quiet; m_print_header(h); end
hist = h;
hist.filename = ncfile.name;

MEXEC_A.Mhistory_in{1} = hist;

while 1 > 0
    m = 'Type variable name or number to edit (return to finish): ';
    var = m_getinput(m,'s');
    if strcmp(' ',var) == 1; break; end
    varnum = m_getvlist(var,h);
    m = 'Type range of valid values                               ';
    reply = m_getinput(m,'s');
    cmd = ['lims = [' reply '];']; %convert char response to number
    eval(cmd);

    lwr = lims(1);
    upr = lims(2);

    vdata = nc_varget(ncfile.name,h.fldnam{varnum});
    lim = [lwr upr];
    kbad = find(vdata < lim(1) | vdata > lim(2));
    disp(['Variable ' sprintf('%-10s',h.fldnam{varnum}) ' ' sprintf('%d',length(kbad)) ' data cycles found outside range ' sprintf('%12.4f %12.4f',lim)]);
    m = 'OK to edit (c/r or ''y'' for yes, anything else for no) ? ';
    ok = m_getinput(m,'s');
    if strcmp(' ',ok) | strcmp('y',ok) == 1
        vdata(kbad) = nan;
    else
        disp('                                                          Skipping edit')
    end

    nc_varput(ncfile.name,h.fldnam{varnum},vdata);

    m_uprlwr(ncfile,h.fldnam{varnum});
    h = m_read_header(ncfile);

    if ~MEXEC_G.quiet; m_print_varsummary(h); end

end


m_finis(ncfile);

h = m_read_header(ncfile);
if ~MEXEC_G.quiet; m_print_header(h); end

hist = h;
hist.filename = ncfile.name;
MEXEC_A.Mhistory_ot{1} = hist;
m_write_history;


return
