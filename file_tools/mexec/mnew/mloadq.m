function [d, h] = mloadq(varargin)

% load data and header contents of mstar NetCDF file into structure
% arrays
% eg
% [d h] = mload('filename.nc');
% or type mload to be prompted for answers
m_common
if ~isfield(MEXEC_G,'quiet')
    MEXEC_G.quiet = 2;
end
m_margslocal
m_varargs

MEXEC_A.Mprog = 'mload';
m_proghd

fn = m_getfilename; % this uses the optional input argument if there is one
if isstruct(fn) && isfield(fn,'name')
    ncfile = fn;
else
    ncfile.name = fn;
end
ncfile = m_ismstar(ncfile); %check it is an mstar file and that it is not open

h = m_read_header(ncfile);
if ~MEXEC_G.quiet; m_print_header(h); end

endflag = 0;
while endflag == 0
    if exist('d','var') == 1 && length(fieldnames(d)) == h.noflds
        if ~MEXEC_G.quiet
            m = 'All variables now loaded';
            fprintf(MEXEC_A.Mfidterm,'\n%s\n',m);
        end
        endflag = 1;
        continue;
    end % h.noflds vars have been loaded so we assume that's all of them. No point asking for more names
    %if (length(varargin)<2)
    m = sprintf('%s\n','Type variable names or numbers to load (0 or return to finish, ''/'' for all):');
    %     if ~isempty(varg) > 0
    %         var = varg{1}; varg(1) = [];
    %     else
    var = m_getinput(m,'s');
    %     end
    %else
    %var=varargin{2};
    %endflag=1;
    %end
    if nargin == 2
        endflag = 1;
    end
    if strcmp(' ',var) == 1; endflag = 1; continue; end
    if strcmp('0',var) == 1; endflag = 1; continue; end
    
    vlist = m_getvlist(var,h);
    if ~MEXEC_G.quiet; disp(['list is ' sprintf('%d ',vlist)]); end
    
    for k = 1:length(vlist)
        vname = h.fldnam{vlist(k)};
        vname2 = m_check_nc_varname(vname);
        d.(vname2) = nc_varget(ncfile.name, vname);
        h.fldnam{strcmp(h.fldnam,vname)} = vname2;
        if ~MEXEC_G.quiet; disp([sprintf('%15s',vname) ' loaded as d.' vname2]); end
    end
    
end


