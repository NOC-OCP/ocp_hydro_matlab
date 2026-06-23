function m_write_vatts_from_header(ncfile,h)
% function m_write_vatts_from_header(ncfile,h)
%
% bak jc211, ylf sd025 added other attributes
%
% m_write_header only writes the global attributes from h into ncfile.name
%
% This function steps through the fldnams in h (variable names) and writes
% the fldunts to attribute units, and any other ['fld' attname] fields to
% attribute attname, into ncfile.name
%
% This might be needed after a call to m_write_header
%



if nargin ~= 2
    error('Must supply precisely two arguments to m_write_vatts_from_header');
end

hfile = m_read_header(ncfile);

%get the list of "extra" attributes which follow the pattern 
% h.(['fld' attname])
hf = fieldnames(h); 
hf = hf(strncmp('fld',hf,3));
hf = setdiff(hf,{'fldnam' 'fldunt'});

for k = 1:length(h.fldnam)
    vname = h.fldnam{k};
    if sum(strcmp(vname,hfile.fldnam)) % if this fldnam is found in ncfile
        nc_attput(ncfile.name,vname,'units',h.fldunt{k})
        if ~isempty(hf)
            for fno = 1:length(hf)
                attname = hf{fno}(4:end);
                nc_attput(ncfile.name,vname,attname,h.(hf{fno}){k})
            end
        end
    end
end
