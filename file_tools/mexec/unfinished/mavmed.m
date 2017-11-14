function mavmed(varargin)

% average data into bins
% use m_nanmedian instead of m_nanmean

m_common
m_margslocal
m_varargs
MEXEC_A.Mprog = 'mavmed';
if ~MEXEC_G.quiet; m_proghd; end


fprintf(MEXEC_A.Mfidterm,'%s','Enter name of input disc file  ')
fn_in = m_getfilename;
fprintf(MEXEC_A.Mfidterm,'%s','Enter name of output disc file  ')
fn_ot = m_getfilename;
ncfile_in.name = fn_in;
ncfile_ot.name = fn_ot;

% m = 'Output file will be same as input file. OK ? Type y to proceed ';
% reply = m_getinput(m,'s');
% if strcmp(reply,'y') ~= 1
%     disp('exiting')
%     return
% end

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


ok = 0;
while ok == 0
    m1 = ' Do you want just the average (/ or return)  ';
    m2 = ' or the full stats (f) ?';
    m1 = sprintf('%s\n',' ',m1,m2);
    reply = m_getinput(m1,'s');
    if(strcmp(reply,' ') == 1); fullstats = 0; ok = 1; continue; end
    if(strcmp(reply,'/') == 1); fullstats = 0; ok = 1; continue; end
    if(strcmp(reply,'f') == 1); fullstats = 1; ok = 1; continue; end
end

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
        m2 = sprintf('%s\n','Do you want to average rows (r) together or cols (c) together ?');
        m3 = sprintf('%s\n','Averaging rows together will be performed using the first column ');
        m4 = sprintf('%s\n','as the independent variable to assign data to bins and vice versa');
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

if ccols == 1; rc = 1; end; % only one col so average rows together;
if crows == 1; rc = 2; end; % only one row so average cols together;

if(rc == 1) %average rows together so match number of nrows
    kmat = find(nrows == crows);
end
if(rc == 2)
    kmat = find(ncols == ccols);
end
% 
% if fullstats == 0; kmat = setdiff(kmat,vcontrol); end % remove control var from action list
% %leave control var in if fullstats == 1

m1 = ['Enter START, STOP, STEP '];
m2 = sprintf('%s\n',m1);
reply = m_getinput(m2,'s');
okreply = 0;
while okreply == 0
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
    okreply = 1;
end
% lwr = lims(1);
% upr = lims(2);
% step = lims(3);
% bins = [lwr:step:upr];

m1 = ['Use the full range of bins (f) or discard end bins which have no data in control variable ? '];
m2 = ['You can discard bins to the left (l), right (r) or both (b or ''/'', default)'];
m2 = sprintf('%s\n',m1,m2);
reply = m_getinput(m2,'s');
okreply = 0;
trunc = 0;
while okreply == 0
    if strcmp(' ',reply) == 1; trunc = 4; break; end
    if strcmp('/',reply) == 1; trunc = 4; break; end
    if strcmp('l',reply) == 1; trunc = 2; break; end
    if strcmp('r',reply) == 1; trunc = 3; break; end
    if strcmp('b',reply) == 1; trunc = 4; break; end
    if strcmp('f',reply) == 1; trunc = 1; break; end
    fprintf(MEXEC_A.Mfider,'\n%s\n','You must reply one of ''f'' ''l'' ''r'' or ''b'' ''c/r'' ''/'' : ');
    reply = m_getinput(' ','s');
end
lwr = lims(1);
upr = lims(2);
step = lims(3);
% bins = [lwr:step:upr]; % don't get all bins here. This could be very large if
% lower time limit was offered as 0 and variable is seconds since 1950.
% do the truncation first.

cvar = nc_varget(ncfile_in.name,h.fldnam{vcontrol});
if rc == 1
    x = cvar(:,1);
elseif rc == 2
    x = cvar(1,:);
end

if trunc == 2 | trunc == 4
    % find first bin that contains data
    xmin = min(x);
    lwr = lwr + max(0,step*floor((xmin-lwr)/step));
%     kb1 = find(bins <= xmin);
%     if isempty(kb1); kb1 = 1; end
%     if kb1(end) > 1; bins(1:kb1(end)-1) = []; end
end
% nbins = length(bins);
if trunc == 3 | trunc == 4
    % find last bin that contains data
    xmax = max(x);
    upr = upr - max(0,step*floor((upr-xmax)/step));    
%     kb2 = find(bins > xmax);
%     if isempty(kb2); kb2 = nbins; end
%     if kb2(1) < nbins; bins(kb2(1)+1:end) = []; end
end
bins = [lwr:step:upr];
nbins = length(bins); %number of bin boundaries.

if ~MEXEC_G.quiet
m = ['number of output bins for averaging is ' sprintf('%d',nbins-1)]; 
fprintf(MEXEC_A.Mfidterm,'%s\n',m);
end

[xsort ksort] = sort(x);

[klo khi] = m_assign_to_bins(xsort,bins);

% tile the control variable if it started as 2-D;
if rc == 1; tile = [1 ccols]; bins = bins(:); end
if rc == 2; tile = [crows 1]; bins = bins(:)'; end
xc = bins(1:end-1) + step/2; % bin centres
xcontrol = repmat(xc,tile);

% write the control variable bin centres

vname = h.fldnam{vcontrol};
v.name = vname;
v.data = xcontrol;

m_write_variable(ncfile_ot,v,'nodata'); %write the variable information into the header but not the data
% next copy the attributes
vinfo = nc_getvarinfo(ncfile_in.name,vname);
va = vinfo.Attribute;
for k2 = 1:length(va)
    vanam = va(k2).Name;
    vaval = va(k2).Value;
    nc_attput(ncfile_ot.name,vname,vanam,vaval);
end
% now write the data, using the attributes already saved in the output file
% this provides the opportunity to change attributes if required, eg fillvalue
nc_varput(ncfile_ot.name,vname,v.data);
m_uprlwr(ncfile_ot,vname);


for k = 1:length(kmat)
    if ~MEXEC_G.quiet
    m = ['Averaging ' h.fldnam{kmat(k)}];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m);
    end
    z = nc_varget(ncfile_in.name,h.fldnam{kmat(k)});
    % rearrange data according to sort of control variable
    lenav = length(klo);
    if rc == 1; zsort = z(ksort,:); zav = nan+zeros(lenav,ncols(kmat(k))); end
    if rc == 2; zsort = z(:,ksort); zav = nan+zeros(nrows(kmat(k)),lenav); end

    if(fullstats == 1)
        zn = zav; zstd = zav;
    end

    for k2 = 1:lenav
        if ~isnan(klo(k2)) & ~isnan(khi(k2))
            if rc == 1;
                zsub = zsort(klo(k2):khi(k2),:);
                zav(k2,:) = m_nanmedian(zsub,rc); % average in direction controlled by rc
                if fullstats == 1
                    ok = isfinite(zsub);
                    zn(k2,:) = sum(ok,rc);
%                     zstd(k2,:) = m_nanstd(zsub,rc);
                    zstd(k2,:) = m_nanprctile(zsub,60,rc) - m_nanprctile(zsub,40,rc); % jc032 
                end
            else
                zsub = zsort(:,klo(k2):khi(k2));
                zav(:,k2) = m_nanmedian(zsub,rc); % average in direction controlled by rc
                if fullstats == 1
                    ok = isfinite(zsub);
                    zn(:,k2) = sum(ok,rc);
%                     zstd(:,k2) = m_nanstd(zsub,rc);
                    zstd(:,k2) = m_nanprctile(zsub,60,rc) - m_nanprctile(zsub,40,rc); % jc032 
                end

            end
        end
    end

    vname = h.fldnam{kmat(k)};
    vname1 = vname;
    if kmat(k) == vcontrol; vname1 = [vname1 '_bin_average']; end
    v.name = vname1;
    v.data = zav;
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

    if fullstats == 1
        vname = h.fldnam{kmat(k)};
        vname2 = [vname '_bin_number'];
        v.name = vname2;
        v.data = zn;
        m_write_variable(ncfile_ot,v,'nodata'); %write the variable information into the header but not the data
        % next copy the attributes
        vinfo = nc_getvarinfo(ncfile_in.name,vname);
        va = vinfo.Attribute;
        for k2 = 1:length(va)
            vanam = va(k2).Name;
            vaval = va(k2).Value;
            nc_attput(ncfile_ot.name,vname2,vanam,vaval);
        end
        % change units on the '_bin_number' variable
        nc_attput(ncfile_ot.name,vname2,'units','number');
        % now write the data, using the attributes already saved in the output file
        % this provides the opportunity to change attributes if required, eg fillvalue
        nc_varput(ncfile_ot.name,vname2,v.data);
        m_uprlwr(ncfile_ot,vname2);

        vname = h.fldnam{kmat(k)};
%         vname3 = [vname '_bin_std'];
        vname3 = [vname '_bin_spread'];
        v.name = vname3;
        v.data = zstd;
        m_write_variable(ncfile_ot,v,'nodata'); %write the variable information into the header but not the data
        % next copy the attributes
        vinfo = nc_getvarinfo(ncfile_in.name,vname);
        va = vinfo.Attribute;
        for k2 = 1:length(va)
            vanam = va(k2).Name;
            vaval = va(k2).Value;
            nc_attput(ncfile_ot.name,vname3,vanam,vaval);
        end

        % now write the data, using the attributes already saved in the output file
        % this provides the opportunity to change attributes if required, eg fillvalue
        nc_varput(ncfile_ot.name,vname3,v.data);
        m_uprlwr(ncfile_ot,vname3);

    end


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