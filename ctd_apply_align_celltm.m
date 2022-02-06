function ctd_apply_align_celltm(filename)

m_common; MEXEC_A.mprog = mfilename;


MEXEC_A.MARGS_IN = {
    otfile1
    'y'
    'cond1'
    'time temp1 cond1'
    'y = ctd_apply_celltm(x1,x2,x3);'
    ' '
    ' '
    'cond2'
    'time temp2 cond2'
    'y = ctd_apply_celltm(x1,x2,x3);'
    ' '
    ' '
    };
scriptname = 'castpars'; oopt = 'oxy_align'; get_cropt
for no = 1:length(ovars)
    MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN;
        ovars{no}
        ['time ' ovars{no}]
        sprintf('y = interp1(x1,x2,x1+%d);',oxy_align)
        ' '
        ' '
        ];
end
MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; ' '];
mcalib2