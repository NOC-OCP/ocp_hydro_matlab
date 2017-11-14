function mgridp_flags(varargin)

% simple version, assumes all files have matching variables
% also assumes all data sorted, no absent data in gridding variable, etc

% unfinished
% not set up to work on gridded files yet

m_common
m_margslocal
m_varargs

MEXEC_A.Mprog = 'mgridp_flags';
if ~MEXEC_G.quiet; m_proghd; end


fprintf(MEXEC_A.Mfidterm,'%s','Enter name of output disc file ')
fn_ot = m_getfilename;
ncfile_ot.name = fn_ot;
ncfile_ot = m_openot(ncfile_ot);

ok = 0;
while ok == 0
    m1 = 'Type dataname for new file ';
    m2 = sprintf('%s',' ',m1);
    reply = m_getinput(m2,'s');
    reply = m_remove_outside_spaces(reply);
    if(strcmp(reply,'') == 1); break; end
    newdataname = reply;
    ok = 1;
end


ok = 0;
filelist = 0;
m1 = 'Supply input file names from the terminal (''t'') or from a file ( ''f'' ''/'' or return)  ';
m2 = sprintf('%s\n',' ',m1);
while ok == 0
    reply = m_getinput(m2,'s');
    if(strcmp(reply,' ') == 1); filelist = 1; ok = 1; continue; end
    if(strcmp(reply,'/') == 1); filelist = 1; ok = 1; continue; end
    if(strcmp(reply,'f') == 1); filelist = 1; ok = 1; continue; end
    if(strcmp(reply,'t') == 1); filelist = 0; ok = 1; continue; end
    fprintf(MEXEC_A.Mfider,'%s\n','You must reply ''t'' or ''f'',''/'' or return')
end

if filelist == 1
    fprintf(MEXEC_A.Mfidterm,'%s','Enter name of file containing list of mstar filenames  ')
    fn_in = m_getinput(' ','s');
    listfilename = fn_in;
    fid = fopen(listfilename,'r');
    clear file_list
    k = 1;
    while k > 0
        s = fgetl(fid);
        if strcmp(class(s),'double') == 1; break; end % fgetl has returned -1 as a number
        file_list{k} = s;
        k = k+1;
    end
else
    clear file_list
    k = 1;
    while k > 0
        fprintf(MEXEC_A.Mfidterm,'%s','Enter name of input disc file (return to finish) ')
        fn_in = m_getfilename;
        fn_in = m_remove_outside_spaces(fn_in);
        if strmatch(fn_in,'.nc','exact'); break; end
        file_list{k} = fn_in;
        k = k+1;
    end
end

numfiles = length(file_list);


ncfile_in.name = file_list{1};
% ncfile_in = m_openin(ncfile_in); % Open first input file

% end

h = m_read_header(ncfile_in); % read first header
if ~MEXEC_G.quiet; m_print_header(h); end

% hist = h;
% hist.filename = ncfile_in.name;
% MEXEC_A.Mhistory_in{1} = hist;


% --------------------
% Now do something with the data
% first write the same header; this will also create the file
h.openflag = 'W'; %ensure output file remains open for write, even though input file is 'R';
h.dataname = newdataname;
h.version = 0;
m_write_header(ncfile_ot,h);

%copy selected vars from the infile
m = sprintf('%s\n','Type variable names or numbers to grid (gridding variable first, ''/'' for all): ');
var = m_getinput(m,'s');
if strcmp(' ',var) == 1;
    var = '/';
end
vlist = m_getvlist(var,h);
m = ['list is ' sprintf('%d ',vlist) ];
disp(m);

m0 = ['Enter details of grid '];
m1 = ['Enter START, STOP, STEP '];
m2 = sprintf('%s\n',m0,m1);
reply = m_getinput(m2,'s');
ok = 0;
while ok == 0
    clear lims
    cmd = ['lims = [' reply '];']; %convert char response to number
    eval(cmd);
    if length(lims) ~= 3;
        fprintf(MEXEC_A.Mfider,'\n%s\n','You must type 3 responses : ');
        reply = m_getinput(' ','s');
        continue
    elseif ((lims(2)-lims(1))/lims(3)) < 1
        fprintf(MEXEC_A.Mfider,'\n%s\n','START - STOP < STEP so no bins. This version requires STOP > START and STEP > 0 : ');
        reply = m_getinput(' ','s');
        continue
    end
    ok = 1;
end
lwr = lims(1);
upr = lims(2);
step = lims(3);
bins = [lwr:step:upr];
numbins = length(bins);

% text copied from mapend, not needed while 2-D variables not allowed.
% ok = 0;
% kapp= 0;
% m1 = 'Append down columns (''c'') or along rows ( ''r'' ''/'' or return)  ';
% m2 = sprintf('%s\n',' ',m1);
% while ok == 0
%     reply = m_getinput(m2,'s');
%     if(strcmp(reply,' ') == 1); kapp = 1; ok = 1; continue; end
%     if(strcmp(reply,'/') == 1); kapp = 1; ok = 1; continue; end
%     if(strcmp(reply,'r') == 1); kapp = 1; ok = 1; continue; end
%     if(strcmp(reply,'c') == 1); kapp = 0; ok = 1; continue; end
%     fprintf(MEXEC_A.Mfider,'%s\n','You must reply ''c'' or ''r'',''/'' or return')
% end

lat = nan+zeros(1,numfiles);
lon = lat;
distrun = lat;
for kf = 1:numfiles
    ncfile_in.name = file_list{kf};
    ncfile_in = m_openin(ncfile_in);
    h = m_read_header(ncfile_in);
    lat(kf) = h.latitude;
    lon(kf) = h.longitude;
end
dist = sw_dist(lat,lon,'km');
% BAK trick on JC032: you never want two gridded profiles in identical
% places. If lats and lons are all identical, eg -999, then increment
% distrun by 1, so this becomes a profile index, even though the first
% profile has 'distrun' = 0;
dist(dist==0) = 1;
% end of trick
distrun = [0 cumsum(dist)];

lat = repmat(lat,numbins,1);
lon = repmat(lon,numbins,1);
distrun = repmat(distrun,numbins,1);
% allbins = repmat(bins,1,numfiles);
allbins = repmat(bins(:),1,numfiles); % BAK correction on jc032; ensure gridding variable is of correct shape

v.name = 'distrun'; v.data = distrun; v.units = 'km'; m_write_variable(ncfile_ot,v);
v.name = 'latitude'; v.data = lat; v.units = 'degrees'; m_write_variable(ncfile_ot,v);
v.name = 'longitude'; v.data = lon; v.units = 'degrees'; m_write_variable(ncfile_ot,v);
v.name = h.fldnam{vlist(1)}; v.data = allbins; v.units = h.fldunt{vlist(1)}; m_write_variable(ncfile_ot,v);



for k = 2:2:length(vlist) % don't need to interp for gridding variable
    % mod/kludge on jc032 by BAK. Enter vars for gridding in pairs; second
    % of each pair is a flag that must be of value 2 to be gridded.
    m1 = ['Gridding variable ' sprintf('%d',vlist(k))];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m1);
    clear v
    v.data = [];
    for kf = 1:numfiles
        ncfile_in.name = file_list{kf};
        ncfile_in = m_openin(ncfile_in);
        h2 = m_read_header(ncfile_in);
        vname = h2.fldnam{vlist(k)};
        vname_flag = h2.fldnam{vlist(k+1)};
        vnameg = h2.fldnam{vlist(1)};
        % check for 2-D variable
        data2x = nc_varget(ncfile_in.name,vnameg); % read in variable for gridding
        data2 = nc_varget(ncfile_in.name,vname);
        data2f = nc_varget(ncfile_in.name,vname_flag);
        if m_numdims(data2) > 1
            m = ['This program doesn''t work on 2-D variables such as ' vname ' in file ' ncfile_in.name];
            error(m);
        end
        if m_isvartime(vname); data2 = m_adjtime(vname,data2,h2,h); end % adjust time to data time origin of first input file
        if m_isvartime(vnameg); data2x = m_adjtime(vnameg,data2x,h2,h); end % adjust time to data time origin of first input file
        % skip part of mapend that relates to choice of rows or cols in 2-D
        % variable
        %         if kapp == 1
        %             v.data = [v.data data2];
        %         else
        %             v.data = [v.data; data2];
        %         end
        
        % jc032 fix for flags
        data2(data2f > 3) = nan; % data -> nan if flag > 2.
        kbad = find(isnan(data2+data2x));
        data2x(kbad) = []; data2(kbad) = [];
        if length(data2x) > 0
            data2g = interp1(data2x,data2,bins);
        else
            data2g = bins+nan;
        end
        v.data = [v.data data2g(:)]; % add another column
        if k == 2; continue; end
        hist = h2;
        hist.filename = ncfile_in.name;
        MEXEC_A.Mhistory_in{kf} = hist;

    end

    v.name = vname;
    m_write_variable(ncfile_ot,v,'nodata'); %write the variable information into the header but not the data
    % next copy the old attributes to preserve them
    vinfo = nc_getvarinfo(ncfile_in.name,vname);
    va = vinfo.Attribute;
    for k2 = 1:length(va)
        vanam = va(k2).Name;
        vaval = va(k2).Value;
        nc_attput(ncfile_ot.name,vname,vanam,vaval);
    end
    m = ['Writing '  sprintf('%10d',numel(v.data)) ' data cycles for variable  ' vname];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m);
    % now write the data, using the attributes already saved in the output file
    % this provides the opportunity to change attributes if required, eg fillvalue
    nc_varput(ncfile_ot.name,vname,v.data);
    m_uprlwr(ncfile_ot,vname);
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






