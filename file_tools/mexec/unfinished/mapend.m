function mapend(varargin)

% simple version, assumes all files have matching variables
% user choice of whether to append along rows or columns
% 
% revised version on jr302, jul 2014: massive improvement in speed when
% each file is read in completely, just once, to avoid reading data one
% file and one variable at a time. Assumes there is enough memory to read
% in the entire appended data, which is very likely to be the case. This
% means appending 150 sample files now takes less than one hour....

m_common
m_margslocal
m_varargs

MEXEC_A.Mprog = 'mapend';
m_proghd


fprintf(MEXEC_A.Mfidterm,'%s','Enter name of output disc file ')
fn_ot = m_getfilename;
ncfile_ot.name = fn_ot;
ncfile_ot = m_openot(ncfile_ot);

ok = 0;
while ok == 0
    m1 = 'Type dataname for new file                            ';
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
m = sprintf('%s\n','Type variable names or numbers to copy and apend (return for none, ''/'' for all): ');
var = m_getinput(m,'s');
if strcmp(' ',var) == 1;
    vlist = [];
else
    vlist = m_getvlist(var,h);
    m = ['list is ' sprintf('%d ',vlist) ];
    disp(m);
end

ok = 0;
kapp= 0;
m1 = 'Append down columns (''c'') or along rows ( ''r'' ''/'' or return)  ';
m2 = sprintf('%s\n',' ',m1);
while ok == 0
    reply = m_getinput(m2,'s');
    if(strcmp(reply,' ') == 1); kapp = 1; ok = 1; continue; end
    if(strcmp(reply,'/') == 1); kapp = 1; ok = 1; continue; end
    if(strcmp(reply,'r') == 1); kapp = 1; ok = 1; continue; end
    if(strcmp(reply,'c') == 1); kapp = 0; ok = 1; continue; end
    fprintf(MEXEC_A.Mfider,'%s\n','You must reply ''c'' or ''r'',''/'' or return')
end

% Improvement by BAK on JC032; Only read the file headers once.
file_headers = {};
file_data = {}; % bak for speed improvement on jr302
m1 = 'Reading file headers';
m2 = 'This may take a while if you have a large number of files and variables';
fprintf(MEXEC_A.Mfidterm,'%s\n',' ',m1,m2,' ');
for kf = 1:numfiles
    if mod(kf,10) == 0; fprintf(MEXEC_A.Mfidterm,'%d %s %d %s\n',kf,' out of ',numfiles,' files processed'); end 
    ncfile_in.name = file_list{kf};
    ncfile_in = m_openin(ncfile_in);
    [d2 h2] = mload(ncfile_in.name,'/');
    file_headers{kf} = h2;
    file_data{kf} = d2;
end

for k = 1:length(vlist)
    clear v
    v.data = [];
    for kf = 1:numfiles
        ncfile_in.name = file_list{kf};
%         ncfile_in = m_openin(ncfile_in);
        % h2 = m_read_header_test(ncfile_in);
        h2 = file_headers{kf};
        d2 = file_data{kf} ;% bak speed improvement on jr302
%         kf;
%         vlist(k);
        vname = h2.fldnam{vlist(k)};
%         data2 = nc_varget(ncfile_in.name,vname);
        cmd = ['data2 = d2.' vname ';']; eval(cmd); % bak speed improvement on jr302; read data from memory instead of from a file each time
        if m_isvartime(vname); data2 = m_adjtime(vname,data2,h2,h); end % adjust time to data time origin of first input file

        if kapp == 1
            v.data = [v.data data2];
        else
            v.data = [v.data; data2];
        end
        if k == 1; continue; end
        hist = h2;
        hist.filename = ncfile_in.name;
        MEXEC_A.Mhistory_in{kf} = hist;

    end
    v.name = vname;
    m_write_variable(ncfile_ot,v,'nodata'); %write the variable information into the header but not the data
    % next copy the attributes
    vinfo = nc_getvarinfo(ncfile_in.name,vname);
    va = vinfo.Attribute;

    for k2 = 1:length(va)
        vanam = va(k2).Name;
        vaval = va(k2).Value;
        nc_attput(ncfile_ot.name,vname,vanam,vaval);
	end
    if ~MEXEC_G.quiet
       m = ['Writing '  sprintf('%10d',numel(v.data)) ' data cycles for variable  ' vname];
       fprintf(MEXEC_A.Mfidterm,'%s\n',m);
    end
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






