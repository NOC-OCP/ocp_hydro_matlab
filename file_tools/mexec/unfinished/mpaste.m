function mpaste(varargin)

% paste vars from a second file onto the first, optionally using a control variable

m_common
m_margslocal
m_varargs

MEXEC_A.Mprog = 'mpaste';
m_proghd

if length(MEXEC_A.MARGS_IN_LOCAL)==0
   fprintf(MEXEC_A.Mfidterm,'%s\n','Enter name of output disc file')
   ncfile_ot.name = m_getfilename;
else
   ncfile_ot.name = m_getfilename(MEXEC_A.MARGS_IN_LOCAL{1}); MEXEC_A.MARGS_IN_LOCAL(1) = [];
end
ncfile_ot = m_openio(ncfile_ot);

if length(MEXEC_A.MARGS_IN_LOCAL)==0
   fprintf(MEXEC_A.Mfidterm,'%s\n','Enter name of input disc file')
   ncfile_in.name = m_getfilename;
else
   ncfile_in.name = m_getfilename(MEXEC_A.MARGS_IN_LOCAL{1}); MEXEC_A.MARGS_IN_LOCAL(1) = [];
end
ncfile_in = m_openin(ncfile_in);

hin = m_read_header(ncfile_in);
hot = m_read_header(ncfile_ot);

% bug fix by bak on di346 17 feb 2010
% previously, mpaste did not put name/version of the 'output' file as one of the input files 
% in the history file.
hist = hot;
hist.filename = ncfile_ot.name;
MEXEC_A.Mhistory_in{1} = hist;

hist = hin;
hist.filename = ncfile_in.name;
MEXEC_A.Mhistory_in{2} = hist;


% --------------------
% Now do something with the data
% first write the same header; this will also create the file
hot.openflag = 'W'; %ensure output file remains open for write, even though input file is 'R';
m_write_header(ncfile_ot,hot);

kcontrol = 0;
okreply = 0;
while okreply == 0
   m1 = ['Do you want to use a control variable ?'];
   m2 = ['reply ''y'' or ''n'' (default)'];
   m = sprintf('%s\n',m1,m2);
   reply = m_getinput(m,'s');
   if strcmp(' ',reply) | strcmp('/',reply) | strcmp('n',reply)
      kcontrol = 0; okreply = 1;
   elseif strcmp('y',reply)
      kcontrol = 1; okreply = 1;
   else
      fprintf(MEXEC_A.Mfider,'\n%s\n','You must reply one of ''y'' ''/'' return or ''n'' : ');
   end
end

if kcontrol > 0
    ok = 0;
    while ok == 0;
        hin = m_read_header(ncfile_in);
        if ~MEXEC_G.quiet; m_print_header(hin); end
        m = sprintf('%s\n','Type variable name or number for control variable on input file for paste : ');
        var = m_getinput(m,'s');
        if strcmp(' ',var) == 1;
            vlistcin = [];
        else
            vlistcin = m_getvlist(var,hin);
        end

        if length(vlistcin) == 1
            vcontrolin = vlistcin;
            cdatain = nc_varget(ncfile_in.name,hin.fldnam{vcontrolin});
            cdatain = reshape(cdatain,1,numel(cdatain));
            ok = 1;
	else
            m = 'You must choose precisely one control variable. try again';
            fprintf(MEXEC_A.Mfider,'%s\n',m)
        end
    end
    ok = 0;
    while ok == 0;
        hot = m_read_header(ncfile_ot);
        if ~MEXEC_G.quiet; m_print_header(hot); end
        m = sprintf('%s\n','Type variable name or number for control variable on output file for paste : ');
        var = m_getinput(m,'s');
        if strcmp(' ',var) == 1;
            vlistcot = [];
        else
            vlistcot = m_getvlist(var,hot);
        end

        if length(vlistcot) == 1
            vcontrolot = vlistcot;
            cdataot = nc_varget(ncfile_ot.name,hot.fldnam{vcontrolot});
            cdataot = reshape(cdataot,1,numel(cdataot));
            ok = 1;
        else
            m = 'You must choose precisely one control variable. try again';
            fprintf(MEXEC_A.Mfider,'%s\n',m)
        end
    end
end

% control variable ok, now get variables for paste
listok = 0;
while listok == 0
    if ~MEXEC_G.quiet; m_print_header(hin); end
    m1 = 'Type variable names or numbers for variables from input';
    m2 = 'file for paste (return for none, ''/'' for all): ';
    m = sprintf('%s\n',m1,m2);
    var = m_getinput(m,'s');
    if strcmp(' ',var) == 1;
        vlistin = [];
    else
        vlistin = m_getvlist(var,hin);
        if ~MEXEC_G.quiet; disp(['list is ' sprintf('%d ',vlistin) ]); end
    end

    if ~MEXEC_G.quiet; m_print_header(hot); end
    m1 = 'Type variable names or numbers for variables from output';
    m2 = 'file for paste (return for none, ''/'' for all): ';
    m = sprintf('%s\n',m1,m2);
    var = m_getinput(m,'s');
    if strcmp(' ',var) == 1;
        vlistot = [];
    else
        vlistot = m_getvlist(var,hot);
        if ~MEXEC_G.quiet; disp(['list is ' sprintf('%d ',vlistot) ]); end
    end

    if  length(vlistin) == length(vlistot)
        listok = 1;
    else
        m = 'Your lists of input and output variables do not match; try again';
        fprintf(MEXEC_A.Mfider,'%s\n',m)
    end
end

numpaste = length(vlistin);

for k = 1:numpaste
    datain = nc_varget(ncfile_in.name,hin.fldnam{vlistin(k)});
    if kcontrol == 0
        nc_varput(ncfile_ot.name,hot.fldnam{vlistot(k)},datain);
        nump = numel(datain);
        if ~MEXEC_G.quiet
           m = [sprintf('%10d',nump) ' datacycles pasted for input variable ' hin.fldnam{vlistin(k)}];
           fprintf(MEXEC_A.Mfidterm,'%s\n',m);
	end
    else
        dataot = nc_varget(ncfile_ot.name,hot.fldnam{vlistot(k)}); % get the data before pasting
        ndata = numel(datain); % assume length of control data matches
        nump = 0;
        for k2 = 1:ndata
            cin = cdatain(k2);
            kmat = find(cdataot == cin);
            kot = min(kmat);
            if ~isempty(kot); dataot(kot) = datain(k2); nump = nump+1; end
        end
        nc_varput(ncfile_ot.name,hot.fldnam{vlistot(k)},dataot);
        if ~MEXEC_G.quiet
           m = [sprintf('%10d',nump) ' datacycles pasted for input variable ' hin.fldnam{vlistin(k)}];
           fprintf(MEXEC_A.Mfidterm,'%s\n',m);
	end
    end
    varoutname = hot.fldnam{vlistot(k)};
    m_uprlwr(ncfile_ot,varoutname);
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






