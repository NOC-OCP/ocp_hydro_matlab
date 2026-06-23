function mcalib(varargin)

% calibrate a variable, writing output back to the same variable

m_common
m_margslocal
m_varargs

MEXEC_A.Mprog = 'mcalib';
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
while 1 > 0
    m = 'Type variable name or number to calibrate (return to finish): ';
    var = m_getinput(m,'s');
    if strcmp(' ',var) == 1; break; end
    varnum = m_getvlist(var,h);
    x = nc_varget(ncfile.name,h.fldnam{varnum});
    y = x; %default if empty return for equation

    m1 = sprintf('%s','Type calibration alogorithm using x and y in the form y = f(x)');
    m2 = sprintf('%s','This will become the matlab equation exactly as you type it');
    m3 = sprintf('%s','To square a variable use the matlab syntax x.*x');
    m4 = sprintf('%s','For example y = 1.2 + 2.4*x + 3*x.*x');
    m5 = sprintf('%s','or          y = sin(x*pi/180)');
    m6 = sprintf('%s','default (c/r) is y = x              ');
    m = sprintf('\n%s',m1,m2,m3,m4,m5,m6);
    eq = m_getinput(m,'s');
    cmd = [eq ';'];
    eval(cmd);

    nc_varput(ncfile.name,h.fldnam{varnum},y); %variable y contains the calibrated data
    
    m = ' Choose new name for calibrated variable ? (return or / for no change) ';
    newname = m_getinput(m,'s');
    if strncmp(' ',newname,1) == 1;
    elseif strncmp('/',newname,1) == 1;
    else
        nc_varrename(ncfile.name,h.fldnam{varnum},newname);
        h = m_read_header(ncfile);
    end

    m = ' Choose new units for calibrated variable ? (return or / for no change) ';
    newunits = m_getinput(m,'s');
    if strncmp(' ',newunits,1) == 1; 
    elseif strncmp('/',newunits,1) == 1;
    else
        nc_attput(ncfile.name,h.fldnam{varnum},'units',newunits);
    end


    m_uprlwr(ncfile,h.fldnam{varnum});
    h = m_read_header(ncfile);
    m_print_varsummary(h);
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
