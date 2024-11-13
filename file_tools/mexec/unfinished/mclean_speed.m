function mclean_speed(varargin)
% function mposspd_polar(varargin)
% 
% mexec main program operates on mstar netcdf files
% 1 input file 
% 1 output file
% 
% Given an input file containing speed over ground (sog) and course
% over ground (cog) fields, pass m_median_despike over the input
% speed. Next, for any speed entry which is eliminated, also
% eliminate the course entry as suspect.
%
% present version has rather little checking of consistency of input
% variables
% 
% RESPONSES:
%   infile
%   otfile
%   sog variable   
%   cog variable
%   filter width in sog units.
%
% Note that specifying a very small filter width will make
% execution extremely slow.

m_common
m_margslocal
m_varargs

MEXEC_A.Mprog = 'mclean_speed';
m_proghd

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

ok = 0;
while ok == 0;
    m3 = sprintf('%s',['type variable name for speed over ground (return for ''sog'' :  ']);
    newname = m_getinput(m3,'s');
    if strcmp(' ',newname); newname = 'sog'; end
    kmat = strmatch(newname,h.fldnam,'exact');
    if isempty(kmat)
        m1 = 'That name is not present in the input file; try again';
        fprintf(MEXEC_A.Mfider,'%s\n',m1)
        continue
    end
    newname = m_remove_outside_spaces(newname);
    sog_name = m_check_nc_varname(newname);
    ok = 1;
end

ok = 0;
while ok == 0;
    m3 = sprintf('%s',['type new variable name for course over ground (return for ''cog'' :  ']);
    newname = m_getinput(m3,'s');
    if strcmp(' ',newname); newname = 'cog'; end
    kmat = strmatch(newname,h.fldnam,'exact');
    if isempty(kmat)
        m1 = 'That name is not present in the input file; try again';
        fprintf(MEXEC_A.Mfider,'%s\n',m1)
        continue
    end
    newname = m_remove_outside_spaces(newname);
    cog_name = m_check_nc_varname(newname);
    ok = 1;
end

ok = false;
while ~ok;
    m3 = sprintf('%s',['type field width filter on speed over ground  ' ...
                       'in SOG units:  ']);
    s = str2num(m_getinput(m3,'d'));
    if (isnan(s))
      m1 = 'Invalid field width';
      fprintf(MEXEC_A.Mfider,'%s\n',m1)
    else
      ok=true;
    end
      
end

speed=nc_varget(fn_in,sog_name);
course=nc_varget(fn_in,cog_name);

% Turn any spikes to NaN.
speed=m_median_despike(speed,s);
% Turn course entries at speed spikes to NaN.
course(isnan(speed))=NaN;  

for i=1:h.noflds
  if strmatch(sog_name,h.fldnam{i},'exact')
    clear v
    v.data = speed;
    v.name = sog_name;
    v.units = h.fldunt{i};
    % its a new variable, so the other atributes [_FillValue missing_value] will be default
    m_write_variable(ncfile_ot,v);

  elseif strmatch(cog_name,h.fldnam{i},'exact')
    clear v
    v.data = course;
    v.name = cog_name;
    v.units = h.fldunt{i};
    % its a new variable, so the other atributes [_FillValue missing_value] will be default
    m_write_variable(ncfile_ot,v);
  
  else
    m_copy_variable(ncfile_in,h.fldnam{i},ncfile_ot,h.fldnam{i});
  end
end

m_finis(ncfile_ot);

h = m_read_header(ncfile_ot);
if ~MEXEC_G.quiet; m_print_header(h); end

hist = h;
hist.filename = ncfile_ot.name;
MEXEC_A.Mhistory_ot{1} = hist;
m_write_history;
