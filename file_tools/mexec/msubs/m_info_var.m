function [varargout] = m_info_var(fname,vname,question)

% ask for specific information about a variable
% available questions:
%          shape                   - give back [rows,columns]
%          minimum                 - give back minimum
%          maximum                 - give back maximum
%          range                   - give back minimum and maximum
%          ["first-greater",value] - row and column number where var first exceeds value
%          ["last-greater",value]  - row and column number where var last exceeds value
%          ["first-less",value]    - row and column number where var is first less than value
%          ["last-less",value]     - row and column number where var is last less than value

m_common
m_margslocal
m_varargs

MEXEC_A.Mprog = 'm_ask_var';
m_proghd;

ncfile.name = fname;
ncfile = m_ismstar(ncfile);

h = m_read_header(ncfile);
k = m_findvarnum(vname,h);

if ischar(question)
  word = question;
  value = NaN;
else
  if iscell(question)
    word = cell2mat(question(1));
    value = cell2mat(question(2));
  end
end

switch word

  case 'shape'
    rows = h.dimrows(k);
    cols = h.dimcols(k);
    varargout{1} = rows;
    varargout{2} = cols;
    return

  case 'minimum'
    varargout{1} = h.alrlim(k);
    return

  case 'maximum'
    varargout{1} = h.uprlim(k);
    return

  case 'range'
    varargout{1} = h.alrlim(k);
    varargout{2} = h.uprlim(k);
    return

  case 'first-greater'
    dv = nc_varget(ncfile.name,vname);
    ids = find(dv > value);
    [row,col] = m_index_to_rowcol(ids(1),h,k);
    varargout{1} = row;
    varargout{2} = col;
    return

  case 'last-greater'
    dv = nc_varget(ncfile.name,vname);
    ids = find(dv > value);
    [row,col] = m_index_to_rowcol(ids(end),h,k);
    varargout{1} = row;
    varargout{2} = col;
    return

  case 'first-less'
    dv = nc_varget(ncfile.name,vname);
    ids = find(dv < value);
    [row,col] = m_index_to_rowcol(ids(1),h,k);
    varargout{1} = row;
    varargout{2} = col;
    return

  case 'last-less'
    dv = nc_varget(ncfile.name,vname);
    ids = find(dv < value);
    [row,col] = m_index_to_rowcol(ids(end),h,k);
    varargout{1} = row;
    varargout{2} = col;
    return

  otherwise
    return

end
