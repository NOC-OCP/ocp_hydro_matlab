function msort(varargin)

% sort data 

% much common code with mavrge
% unfinished: only works on first row or col of gridded file; could be made
% to work on user choice

m_common
m_margslocal
m_varargs

MEXEC_A.Mprog = 'msort';
if ~MEXEC_G.quiet; m_proghd; end


if length(MEXEC_A.MARGS_IN_LOCAL)==0
   fprintf(MEXEC_A.Mfidterm,'%s','Enter name of input disc file   ')
   ncfile_in.name = m_getfilename;
else
   ncfile_in.name = m_getfilename(MEXEC_A.MARGS_IN_LOCAL{1}); MEXEC_A.MARGS_IN_LOCAL(1) = [];
end
if length(MEXEC_A.MARGS_IN_LOCAL)==0
   fprintf(MEXEC_A.Mfidterm,'%s','Enter name of output disc file  ')
   ncfile_ot.name = m_getfilename;
else
   ncfile_ot.name = m_getfilename(MEXEC_A.MARGS_IN_LOCAL{1}); MEXEC_A.MARGS_IN_LOCAL(1) = [];
end

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

copylistok = 0;
while copylistok == 0
    m = sprintf('%s\n','Type name or number of control variable :');
    var = m_getinput(m,'s');
    vlist = m_getvlist(var,h);
    vcontrol = vlist(1);
    crows = h.dimrows(vcontrol);
    ccols = h.dimcols(vcontrol);
    ccycles = crows*ccols;
    rc = 0;
    if min(crows,ccols) > 1
        m1 = sprintf('%s\n','Your control variable has nrows > 1 and ncols > 1');
        m2 = sprintf('%s\n','Do you want to sort down rows (r)  or cols (c)  ?');
        m3 = sprintf('%s\n','Sorting rows will be performed using the first column ');
        m4 = sprintf('%s\n','as the independent variable and vice versa');
        m5 = sprintf('%s\n','reply r or c ');
        reply = m_getinput([m1 m2 m3 m4 m5],'s');
        okreply = 0;
        while okreply == 0
            if strcmp('r',reply) == 1; rc = 1; break; end
            if strcmp('c',reply) == 1; rc = 2; break; end
            fprintf(MEXEC_A.Mfider,'\n%s\n','You must reply r or c : ');
            reply = m_getinput(' ','s');
        end
    end
    copylistok = 1;
end


% find vars with 'matching' dimensions
nrows = h.dimrows;
ncols = h.dimcols;
ncycles = nrows.*ncols;

if ccols == 1; rc = 1; end; % only one col so sort rows;
if crows == 1; rc = 2; end; % only one row so sort cols;

if(rc == 1) %sort cols so match number of nrows
    kmat = find(nrows == crows);
end
if(rc == 2)
    kmat = find(ncols == ccols);
end
% 


cvar = nc_varget(ncfile_in.name,h.fldnam{vcontrol});
if rc == 1
    x = cvar(:,1);
elseif rc == 2
    x = cvar(1,:);
end


[xsort ksort] = sort(x);


for k = 1:length(kmat)
    if ~MEXEC_G.quiet
    m = ['Sorting ' h.fldnam{kmat(k)}];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m);
    end
    z = nc_varget(ncfile_in.name,h.fldnam{kmat(k)});
    % rearrange data according to sort of control variable

    if rc == 1; zsort = z(ksort,:); end
    if rc == 2; zsort = z(:,ksort); end


    vname = h.fldnam{kmat(k)};
    vname1 = vname;
    v.name = vname1;
    v.data = zsort;
    m_write_variable(ncfile_ot,v,'nodata'); %write the variable information into the header but not the data
    % next copy the attributes
    vinfo = nc_getvarinfo(ncfile_in.name,vname);
    va = vinfo.Attribute;
    for k2 = 1:length(va)
        vanam = va(k2).Name;
        vaval = va(k2).Value;
        nc_attput(ncfile_ot.name,vname1,vanam,vaval);
    end
    % now write the data, using the attributes already saved in the output file
    % this provides the opportunity to change attributes if required, eg fillvalue
    nc_varput(ncfile_ot.name,vname1,v.data);
    m_uprlwr(ncfile_ot,vname1);



end



% --------------------


m_finis(ncfile_ot);

h = m_read_header(ncfile_ot);
if ~MEXEC_G.quiet; m_print_header(h); end

hist = h;
hist.filename = ncfile_ot.name;
MEXEC_A.Mhistory_ot{1} = hist;
m_write_history;


return