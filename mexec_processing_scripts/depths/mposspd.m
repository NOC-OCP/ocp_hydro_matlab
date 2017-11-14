function mposspd(varargin)
% function mposspd(varargin)
% 
% mexec main program operates on mstar netcdf files
% 1 input file 
% 1 output file
% 
% calculate ve,vn from time,lat,lon
% all vars must have identical dimensions
% if 2-D, work along rows
% ve, vn from data cycles k,k+1 are assigned to data cycle k+1;
% ve,ve for first data cycle are NaN.
%
% present version has rather little checking of consistency of input
% variables
% 
% RESPONSES:
%   infile
%   otfile
%   variables to copy
%   variables for time, lat, lon
%   selection for knots or m/s
%   output variable names/units
%
% UPDATED:
%   Initial version BAK 2008-10-17 at NOC

% unfinished check gridded input vars are sensible if gridded
% unfinished should be rewritten to be a callable function from mcalc

m_common
m_margslocal
m_varargs

MEXEC_A.Mprog = 'mposspd';
if ~MEXEC_G.quiet; m_proghd; end

fprintf(MEXEC_A.Mfidterm,'%s','Input file name     ')
fn_in = m_getfilename;
fprintf(MEXEC_A.Mfidterm,'%s','Output file name    ')
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

m = sprintf('%s\n','Type variable names or numbers to copy (return for none, ''/'' for all): ');
varcopy = m_getinput(m,'s');
copylist = m_getvlist(varcopy,h);
for k = copylist
    vname = h.fldnam{k};
    m_copy_variable(ncfile_in,vname,ncfile_ot,vname);
end


m = 'Type variable names or numbers of time, lat and lon: ';
m1 = sprintf('%s\n',m);
var2 = m_getinput(m1,'s');
tlllist = m_getvlist(var2,h);

time = nc_varget(ncfile_in.name,h.fldnam{tlllist(1)});
lat = nc_varget(ncfile_in.name,h.fldnam{tlllist(2)});
lon = nc_varget(ncfile_in.name,h.fldnam{tlllist(3)});

unit = h.fldunt{tlllist(1)};
isdays = m_isunitdays(unit);
issecs = m_isunitsecs(unit);
% if unit not recognised, assume it is seconds

if isdays + issecs == 0
    m = ['time unit ' unit ' not recognised as days or seconds, assumed to be seconds'];
    fprintf(MEXEC_A.Mfider,'\n\n%s\n\n',m)
    issecs = 1;
end
if isdays == 1
    time = time*86400; % convert days to seconds
end


m = 'Which output units. Type ''k'' for knots, ''m (default)'' for m/s : ';
fprintf(MEXEC_A.Mfidterm,'%s\n',m);
% var2 = m_getinput(m1,'s');
kunit = 0;
ok = 0;
while ok == 0
    reply = m_getinput(' ','s');
    if strcmp(' ',reply) == 1; kunit = 1; break; end
    if strcmp('/',reply) == 1; kunit = 1; break; end
    if strcmp('m',reply) == 1; kunit = 1; break; end
    if strcmp('k',reply) == 1; kunit = 0; break; end
    fprintf(MEXEC_A.Mfider,'\n%s\n','You must reply one of ''m'' ''/'' return or ''k'' : ');
end

if kunit == 1;
    ustring = 'km'; % need m/s
    speedunit = 'm/s';
    scale = 1000;
else
    ustring = 'nm'; % need knots
    speedunit = 'knots';
    scale = 3600;
end
timeunit = unit;

ve = nan+lat;
vn = ve;

if m_numdims(lat) == 1
    % not gridded data
    [dist angle] = sw_dist(lat,lon,ustring);
    delt = diff(time);
    speed = scale*(dist./delt);
    ve(2:end) = speed.*cos(angle*pi/180);
    vn(2:end) = speed.*sin(angle*pi/180);
% % % % %     t1 = time(2:end);
else
    % gridded
    nrows = size(lat,1);
    ncols = size(lat,2);
% % % % %     ve = nan+zeros(nrows,ncols-1);
% % % % %     vn = ve;
% % % % %     t1 = ve;

    for k = 1:nrows
        rlat = lat(k,:);
        rlon = lon(k,:);
        rdelt = diff(time(k,:));
        [rdist rangle] = sw_dist(rlat,rlon,ustring);
        speed = scale*(rdist./rdelt);
        rve = speed.*cos(rangle*pi/180);
        rvn = speed.*sin(rangle*pi/180);
        ve(k,2:end) = rve;
        vn(k,2:end) = rvn;
% % % % %         t1(k,2:end) = time(k,2:end);
    end
end

h2 = m_read_header(ncfile_ot);

ok = 0;
while ok == 0;
    m3 = sprintf('%s',['type new variable name for ve (return for ''ve'' :  ']);
    newname = m_getinput(m3,'s');
    if strcmp(' ',newname); newname = 've'; end
    kmat = strmatch(newname,h2.fldnam,'exact');
    if ~isempty(kmat)
        m1 = 'That name is already taken in the output file; try again';
        fprintf(MEXEC_A.Mfider,'%s\n',m1)
        continue
    end
    newname = m_remove_outside_spaces(newname);
    ve_newname = m_check_nc_varname(newname);
    ok = 1;
end

ok = 0;
while ok == 0;
    m3 = sprintf('%s',['type new variable name for vn (return for ''vn'' :  ']);
    newname = m_getinput(m3,'s');
    if strcmp(' ',newname); newname = 'vn'; end
    kmat = strmatch(newname,h2.fldnam,'exact');
    if ~isempty(kmat)
        m1 = 'That name is already taken in the output file; try again';
        fprintf(MEXEC_A.Mfider,'%s\n',m1)
        continue
    end
    newname = m_remove_outside_spaces(newname);
    vn_newname = m_check_nc_varname(newname);
    ok = 1;
end

% % % % % ok = 0;
% % % % % while ok == 0;
% % % % %     m3 = sprintf('%s',['type new variable name for time (return for ''time_speed'' :  ']);
% % % % %     newname = m_getinput(m3,'s');
% % % % %     if strcmp(' ',newname); newname = 'time_speed'; end
% % % % %     kmat = strmatch(newname,h2.fldnam,'exact');
% % % % %     if ~isempty(kmat)
% % % % %         m1 = 'That name is already taken in the output file; try again';
% % % % %         fprintf(MEXEC_A.Mfider,'%s\n',m1)
% % % % %         continue
% % % % %     end
% % % % %     newname = m_remove_outside_spaces(newname);
% % % % %     t_newname = m_check_nc_varname(newname);
% % % % %     ok = 1;
% % % % % end

% % % % % 
% % % % % clear v
% % % % % v.data = t1;
% % % % % v.name = t_newname;
% % % % % v.units = timeunit;
% % % % % % its a new variable, so the other atributes [_FillValue missing_value] will be default
% % % % % m_write_variable(ncfile_ot,v);
    
clear v
v.data = ve;
v.name = ve_newname;
v.units = speedunit;
% its a new variable, so the other atributes [_FillValue missing_value] will be default
m_write_variable(ncfile_ot,v);

clear v
v.data = vn;
v.name = vn_newname;
v.units = speedunit;
% its a new variable, so the other atributes [_FillValue missing_value] will be default
m_write_variable(ncfile_ot,v);

    
    



% --------------------




m_finis(ncfile_ot);

h = m_read_header(ncfile_ot);
if ~MEXEC_G.quiet; m_print_header(h); end

hist = h;
hist.filename = ncfile_ot.name;
MEXEC_A.Mhistory_ot{1} = hist;
m_write_history;

return