function mmerge(varargin)

% merge vars from a second file onto the first, using a control variable
% and either linearly interpolating or taking the median over a specified window in
% the control variable
% if the control var in both files is 1-D, no problem
% the control var in either one of the files can be 2-D
% something will surely crash if the control var in both files is 2-D
%
% modified on jc159 march 2018 to enable the user to specfy a maximum
% number of consecutive NaNs to be filled before interpolation. Backwards
% compatible so 'k' and 'f' are allowable replies, as well as 0,1,...,inf
% zero is equivalent to 'k'; inf is equivalent to 'f' for fill all.

m_common
m_margslocal
m_varargs

MEXEC_A.Mprog = 'mmerge_avmed';
m_proghd

if length(MEXEC_A.MARGS_IN_LOCAL)==0
   fprintf(MEXEC_A.Mfidterm,'%s\n','Enter name of output disc file')
   ncfile_ot.name = m_getfilename;
else
   ncfile_ot.name = m_getfilename(MEXEC_A.MARGS_IN_LOCAL{1}); MEXEC_A.MARGS_IN_LOCAL(1) = [];
end
ncfile_ot = m_openot(ncfile_ot);

if length(MEXEC_A.MARGS_IN_LOCAL)==0
   fprintf(MEXEC_A.Mfidterm,'%s\n','Enter name of input disc file')
   ncfile_in.name = m_getfilename;
else
   ncfile_in.name = m_getfilename(MEXEC_A.MARGS_IN_LOCAL{1}); MEXEC_A.MARGS_IN_LOCAL(1) = [];
end
ncfile_in = m_openin(ncfile_in);

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

%copy selected vars from the infile
m = sprintf('%s\n','Type variable names or numbers to copy (return for none, ''/'' for all): ');
var = m_getinput(m,'s');
if strcmp(' ',var) == 1;
    vlist = [];
else
    vlist = m_getvlist(var,h);
    if ~MEXEC_G.quiet; disp(['list is ' sprintf('%d ',vlist) ]); end
end

for k = vlist
    vname = h.fldnam{k};
    numdc = h.dimrows(k)*h.dimcols(k);
    if ~MEXEC_G.quiet
    m = ['Copying ' sprintf('%8d',numdc) ' datacycles for variable '  vname ];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m);
    end
    m_copy_variable(ncfile_in,vname,ncfile_ot,vname);
end

ok = 0;
while ok == 0;
    m = sprintf('%s\n','Type variable name or number for control variable for merge : ');
    var = m_getinput(m,'s');
    if strcmp(' ',var) == 1;
        vlistc = [];
    else
        vlistc = m_getvlist(var,h);
    end

    if length(vlistc) ~= 1
        m = 'You must choose precisely one control variable. try again';
        fprintf(MEXEC_A.Mfider,'%s\n',m)
        continue
    end
    vcontrol = vlistc;
    ok = 1;
end

% get control data
vname_c_1 = h.fldnam{vcontrol};
data_c_1 = nc_varget(ncfile_in.name,vname_c_1);


if length(MEXEC_A.MARGS_IN_LOCAL)==0
   m = 'Now get details of next input file ';
   fprintf(MEXEC_A.Mfidterm,'%s\n',m)
   fprintf(MEXEC_A.Mfidterm,'%s\n','Enter name of input disc file')
   ncfile_in2.name = m_getfilename;
else
   ncfile_in2.name = m_getfilename(MEXEC_A.MARGS_IN_LOCAL{1}); MEXEC_A.MARGS_IN_LOCAL(1) = [];
end
ncfile_in2 = m_openin(ncfile_in2);

h2 = m_read_header(ncfile_in2);
if ~MEXEC_G.quiet; m_print_header(h2); end

hist = h2;
hist.filename = ncfile_in2.name;
MEXEC_A.Mhistory_in{2} = hist;


ok = 0;
while ok == 0;
    m = sprintf('%s\n','Type variable name or number for control variable for merge : ');
    var = m_getinput(m,'s');
    if strcmp(' ',var) == 1;
        vlistc2 = [];
    else
        vlistc2 = m_getvlist(var,h2);
    end

    if length(vlistc2) ~= 1
        m = 'You must choose precisely one control variable. try again';
        fprintf(MEXEC_A.Mfider,'%s\n',m)
        continue
    end
    vcontrol2 = vlistc2;
    ok = 1;
end

data_c_2 = nc_varget(ncfile_in2.name,h2.fldnam{vcontrol2});
if m_isvartime(h2.fldnam{vcontrol2}); data_c_2 = m_adjtime(h2.fldnam{vcontrol2},data_c_2,h2,h); end % adjust time to data time origin of first input file

numdims_c = m_numdims(data_c_2);

contmerge = 0;

if numdims_c == 2
    % 2-d control var
    m = 'Your control var has 2 dimensions, do you want to use a row or column ';
    m2 = 'as the independent variable for the interpolation ?';
    fprintf(MEXEC_A.Mfidterm,'%s\n',m,m2);
    ok = 0;
    while ok == 0;
        m3 = sprintf('%s','type r for row, c for column :  ');
        reply = m_getinput(m3,'s');
        if strcmp(reply,'r'); rc = 2; break; end % ind var is a row; colindex varies
        if strcmp(reply,'c'); rc = 1; break; end % ind var is a col; rowindex varies
        fprintf(MEXEC_A.Mfider,'\n%s\n','You must reply r or c : ');
    end

    str = {'column' 'row'};
    strtext = str{rc};

    % find row/column number
    m1 = 'Interpolation only works when the independent variable is 1-D ?';
    m2 = ['Which ' strtext ' do you want to use ?'];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m1,m2);
    maxd = size(data_c_2,1);
    ok = 0;
    while ok == 0;
        m3 = sprintf('%s',['type number in range 1 (default) to ' sprintf('%d',maxd) '  ']);
        reply = m_getinput(m3,'s');
        if strcmp(reply,' '); contindex = 1; break; end
        cmd = ['contindex = [' reply '];']; %convert char response to number
        eval(cmd);
        if length(contindex) ~= 1; continue; end
        ok = 1;
    end

    m1 = ['Do you want to merge on the other ' strtext 's of the control variable ?'];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m1);
    maxd = size(data_c_2,1);
    ok = 0;
    while ok == 0;
        m3 = sprintf('%s',['reply no (n, default) or yes (y)  ']);
        reply = m_getinput(m3,'s');
        if strcmp(reply,' '); contmerge = 0; break; end
        if strcmp(reply,'n'); contmerge = 0; break; end
        if strcmp(reply,'y'); contmerge = 1; break; end
    end


    if rc == 1
        x = data_c_2(:,contindex);
    else
        x = data_c_2(contindex,:);
    end
else
    % 1-D var
    x = data_c_2;
end

xdm = min(diff(x));
if xdm <= 0
    m = 'Control variable was not monotonic; it will be sorted';
    fprintf(MEXEC_A.Mfider,'%s\n',m)
    [xsort ksort] = sort(x);
else
    xsort = x; ksort = 1:length(x);
end
xbad = isnan(xsort);
if sum(xbad) > 0
    m = ['Control variable contained '  sprintf('%d',sum(xbad)) ' nan values; these are not valid in interp1 and have been removed'];
    fprintf(MEXEC_A.Mfider,'%s\n',m)
    xsort(xbad) = [];
end

% now we've got the two control variables: data_c_1 and xsort.
% xsort has been adjusted for data time origin if necessary
% if they're both time variables but one is days and the other is seconds,
% scale xsort into same units as data_c_1

%vname_c_1 = vname_c_1
unit_c_1 = h.fldunt(vlistc);
vname_c_2 = h2.fldnam{vcontrol2};
unit_c_2 = h2.fldunt{vcontrol2};

if (m_isvartime(vname_c_1) == 1) & (m_isvartime(vname_c_2) == 1)
    % both recognised as time variables
    if m_isunitsecs(unit_c_2) == 1
        if m_isunitdays(unit_c_1) == 1
            xsort = xsort/86400;
        end
    end
    if m_isunitdays(unit_c_2) == 1
        if m_isunitsecs(unit_c_1) == 1
            xsort = xsort*86400;
        end
    end
end


% check whether data_c_1 is in range of xsort

xmin = min(xsort);
xmax = max(xsort);
ximin = min(min(data_c_1));
ximax = max(max(data_c_1));
if ximin < xmin
    m = ['warning file 1 control variable is not contained within file 2 at low end'];
    fprintf(MEXEC_A.Mfider,'%s\n',m)
end
if ximax > xmax
    m = ['warning file 1 control variable is not contained within file 2 at high end'];
    fprintf(MEXEC_A.Mfider,'%s\n',m)
end


% control variable ok, now get variables for merge

m = sprintf('%s\n','Type variable names or numbers for variables for merge (return for none, ''/'' for all with matching dimensions): ');
var = m_getinput(m,'s');
if strcmp(' ',var) == 1;
    vlist2 = [];
else
    vlist2 = m_getvlist(var,h2);
    if ~MEXEC_G.quiet; disp(['list is ' sprintf('%d ',vlist2) ]); end
end

ok = 0;
m1 = sprintf('%s','If NaNs are found in the merging variable, do you want them filled first (f, default)');
m2 = sprintf('%s','or do you want them kept in place (k) so that NaNs may appear in the output ?');
m4 = sprintf('\n%s\n%s','After 28 March 2018, new option to specify the maximum number of NaNs that will be filled','before the merge takes place.');
m5 = sprintf('\n%s','This is backwards compatible, so ''k'' is equivalent to zero and ''f'' is equivalent to inf');
m6 = sprintf('%s','You can reply with characters f or k, or an integer');
fprintf(MEXEC_A.Mfidterm,'%s\n\n',m1,m2,m4,m5,m6);
while ok == 0;
    m3 = sprintf('%s','reply ''f'' or inf or return for fill or ''k'' or 0 for keep, \nor an integer for the maximum number of NaNs to be filled : ');
    reply = m_getinput(m3,'s');
    if strcmp(reply,' '); absfill = inf; break; end
    if strcmp(reply,'f'); absfill = inf; break; end
    if strcmp(reply,'k'); absfill = 0; break; end
    try
        absfill = str2num(reply);
        if(~isempty(absfill)); break; end
    catch
    end
end

ok = 0;
m1 = sprintf('%s','Do you want to interpolate (0, default),');
m2 = sprintf('%s','or take the median over time range [deltat1 deltat2]');
m4 = sprintf('%s','such that deltat1<time2-time1<deltat2');
fprintf(MEXEC_A.Mfidterm,'%s\n\n',m1,m2,m4);
while ok ==0;
    m3 = sprintf('%s','reply 0 to interpolate or [deltat1 deltat2] to compute median: ');
    reply = m_getinput(m3,'d');
    reply = str2num(reply);
    if length(reply)==1; noav = 1; break; 
    else; avi = reply; noav = 0; break; end
end
        
% find vars with 'matching' dimensions
crows = h2.dimrows(vcontrol2);
ccols = h2.dimcols(vcontrol2);
ccycles = crows*ccols;
nrows = h2.dimrows;
ncols = h2.dimcols;
ncycles = nrows.*ncols;

if ccols == 1; rc = 1; end; % only one col so use it as independent var;
if crows == 1; rc = 2; end; % only one row so use it as independent var;

if(rc == 1) % we're working down columns
    kmat = find(nrows == crows);
end
if(rc == 2) % we're working along rows
    kmat = find(ncols == ccols);
end

if contmerge == 1; vlist2 = [vcontrol2 vlist2]; end% since the user asked for the merging variable, make sure it is in the list

kmat = intersect(kmat,vlist2); % find vars that are in user's list and have suitable dims

if contmerge == 0; kmat = setdiff(kmat,vcontrol2); end % remove control var from action list
%leave control var in if contmerge == 1

if rc == 2;
    % need to transpose so that interp1 works on gridded data
    xsort = xsort';
end

if ~MEXEC_G.quiet; disp(['list of matching vars is ' sprintf('%d ',kmat) ]); end

for k = 1:length(kmat)
    vname = h2.fldnam{kmat(k)};
    kmat2 = strmatch(vname,h.fldnam(vlist),'exact');
    if ~isempty(kmat2) % attempting to copy a variable that has already been taken from first file
        m1 = ['attempting to merge a variable                    ' vname ];
        m2 = ['that has already been copied from first input file'];
        m3 = ['you need to rename the variable for output'];
        fprintf(MEXEC_A.Mfider,'%s\n',m1,m2,m3)

        ok = 0;
        while ok == 0;
            m3 = sprintf('%s',['type new variable name for output :              ']);
            newname = m_getinput(m3,'s');
            if strcmp(newname,' ') | strcmp(newname,'/');
                m = 'try again';
                fprintf(MEXEC_A.Mfider,'%s\n',m)
                continue
            end
            newname = m_remove_outside_spaces(newname);
            newname = m_check_nc_varname(newname);
            ok = 1;
        end
    else
        newname = vname;
    end

    if ~MEXEC_G.quiet
    m = ['Merging ' h2.fldnam{kmat(k)}];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m);
    end
    z = nc_varget(ncfile_in2.name,h2.fldnam{kmat(k)});
    if m_isvartime(h2.fldnam{kmat(k)}); z = m_adjtime(h2.fldnam{kmat(k)},z,h2,h); end % adjust time to data time origin of first input file
    % rearrange data according to sort of control variable
    if rc == 2;
        % need to transpose so that interp1 works on gridded data
        z = z';
    end
    zsort = z(ksort,:);
    zsort(xbad,:) = [];
    
if absfill > 0;
    % fill any nans in z by interpolation
    for kfill = 1:size(zsort,2);
        ok = ~isnan(zsort(:,kfill));
        if sum(ok) < 2 ; continue; end % not enough good data to fill with interp1
        if sum(ok) == size(zsort,1); continue; end % all data are good; skip interp1
        % bak on jc159 28 March 2018; To handle the case of not
        % interpolating more than absfill values, construct a
        % mask to set back to NaN. absfill = 0 means interpolate max of
        % zero values, ie no interpolation. absfill NaNs will be filled;
        % absfill+1 NaNs will not be filled.
        zs = zsort(:,kfill);
        kmask = zeros(size(zs));
        kok = find(ok);
        gap = diff(kok); % gap size to next OK value
        kbiggap = find(gap > absfill+1); % when there are absfill values, which is acceptable to fill, the step between good values is absfill+1. Take action if this gap is exceeded.
        %kok(biggap) are the index in zs of the last good cycles before big
        %gaps
        for kl = 1:length(kbiggap)
            kmask((kok(kbiggap(kl))+1):(kok(kbiggap(kl))+gap(kbiggap(kl))-1)) = nan;
        end
        % fill them all, then mask out the ones that should not have been
        % filled.
        zsort(:,kfill) = interp1(xsort(ok),zsort(ok,kfill),xsort);
        zsort(:,kfill) = zsort(:,kfill)+kmask;
    end
end
    
    [dontcare iuni juni]=unique(xsort); %redundant? (sort only returns unique values)
    if noav
       zi = interp1(xsort(iuni),zsort(iuni),data_c_1); % zi has same dimensions as  data_c_1
    else
       m = repmat(x(:),1,length(data_c_1))-repmat(data_c_1(:)',length(x),1);
       m = (m<avi(1) | m>avi(2));
       z = repmat(z(:),1,length(data_c_1)); z(m) = NaN;
       zi = nanmedian(z)'; %***could add something to keep track of stdev too
       if size(data_c_1,1) == 1; zi = zi'; end
    end
    % yi = interp1(x,y,xi)
    % if y is 2-D then yi is always a column, so we need to fix its shape
    % to match xi
    % if y is 1-D, then yi is the same shape as xi
    if m_numdims(zsort) == 1 % zsort is 1-D
        ktranspose = 0; % dimensions of zi will match data_c_1;
    else % zsort is 2-D and zi will have merge index varying down a column 
        if size(data_c_1,1) == 1
            % data_c_1 was a row vector. Force z to be a row vector
            ktranspose = 1;
        else
            ktranspose = 0;
        end
    end
    
    if ktranspose == 1
        zi = zi';
    end


    % write the output
    clear v
    v.name = newname;
    v.data = zi;
    m_write_variable(ncfile_ot,v,'nodata'); %write the variable information into the header but not the data
    % next copy the attributes
    vinfo = nc_getvarinfo(ncfile_in2.name,vname);
    va = vinfo.Attribute;
    for k2 = 1:length(va)
        vanam = va(k2).Name;
        vaval = va(k2).Value;
        nc_attput(ncfile_ot.name,newname,vanam,vaval);
    end

    % now write the data, using the attributes already saved in the output file
    % this provides the opportunity to change attributes if required, eg fillvalue
    nc_varput(ncfile_ot.name,newname,v.data);
    m_uprlwr(ncfile_ot,newname);

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






