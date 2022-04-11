function mchangetimeorigin(varargin)

% change data time origin; adjust time data as required.
% time data are recognised if the var name has a successful strncmp with
% any element of cell array MEXEC_A.Mtimnames


m_common
m_margslocal
m_varargs

MEXEC_A.Mprog = 'mchangetimeorigin';
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
h2= h; % start new header

ok = 0;
kchange = 1;
while ok == 0;
    m = ['Type new data_time_origin (return or / to keep as ['  sprintf('%d ',h.data_time_origin) '] ) : '];
    reply = m_getinput(m,'s');
    if strcmp(reply,' '); kchange = 0; break; end % no change
    if strcmp(reply,'/'); kchange = 0; break; end % no change
    cmd = ['h2.data_time_origin = [' reply '];']; %convert char response to number
    eval(cmd);
    torg = h2.data_time_origin;
    if length(torg) < 6;
        z = h.mstar_time_origin;
        torg = [torg z((length(torg)+1):6)];
        h2.data_time_origin = torg;
    end
    h2.data_time_origin_string = datestr(datenum(h2.data_time_origin),31);
    ok = 1;
end

if kchange == 0
    m = 'You appear to have selected ''no change'' to data_time_origin';
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    for k = 1:h.noflds
        vname = h.fldnam{k};
        if m_isvartime(vname)
            data = nc_varget(ncfile.name,vname);
            data = m_adjtime(vname,data,h,h2);
            nc_varput(ncfile.name,vname,data);
            m_uprlwr(ncfile,vname);
        end
    end
    m_write_header(ncfile,h2);
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
