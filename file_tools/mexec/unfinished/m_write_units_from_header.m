function m_write_units_from_header(ncfile,h)
% function m_write_units_from_header(ncfile,h)
%
% bak jc211
%
% m_write_header only writes the global attributes from h into ncfile.name
%
% variables names and units are variable attributes
%
% This function steps through the fldnams in h and writes the fldunts to
% ncfile.
%
% This might be needed after a call to m_write_header
%



if nargin ~= 2
    error('Must supply precisely two arguments to m_write_header');
end

hfile = m_read_header(ncfile);

for k = 1:length(h.fldnam)
    vname = h.fldnam{k};
    vunit = h.fldunt{k};
    if sum(strcmp(vname,hfile.fldnam)) % ie if this fldnam is found in ncfile
            nc_attput(ncfile.name,vname,'units',vunit)
    end
end
