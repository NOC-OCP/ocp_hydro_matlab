function matlab_to_mstar

% create mstar file containing vars that are the arguments of the function
% first argument is filename, then list of vars
% var names are generated as v1,v2,....
% This is now done using msave, which generates the list in MEXEC_A.MSAVE_VLIST

m_common

ncfile.name = MEXEC_A.MSAVE_VLIST{1};

ncfile_ot = m_openot(ncfile);

nvar = (length(MEXEC_A.MSAVE_VLIST)-1)/2;

for k = 1:nvar
    clear v
    v.data = MEXEC_A.MSAVE_VLIST{2*k+1};
    v.name = MEXEC_A.MSAVE_VLIST{2*k};
    if strcmp(class(v.data),'double') ~= 1
        m1 = ['writing from matlab to mstar not valid for variable of class ' class(v.data)];
        m2 = ['variable class must be double'];
        m = sprintf('%s\n',m1,m2)
        error(m)
    end
    if ~ischar(v.name)
        m1 = ['writing from matlab to mstar not valid unless proposed variable name is a char string ' class(v.data)];
        m = sprintf('%s\n',m1)
        error(m)
    end
    v.units = 'notset';
    m_write_variable(ncfile_ot,v);
end

nowstring = datestr(now,31);
m_add_comment(ncfile_ot,'Variables written from matlab to mstar');
m_add_comment(ncfile_ot,['at ' nowstring]);
m_add_comment(ncfile_ot,['by ' MEXEC_G.MUSER]);


m_finis(ncfile_ot);

h = m_read_header(ncfile_ot);
if ~MEXEC_G.quiet; m_print_header(h); end

hist = h;
hist.filename = ncfile_ot.name;
MEXEC_A.Mhistory_ot{1} = hist;
m_write_history;


return

