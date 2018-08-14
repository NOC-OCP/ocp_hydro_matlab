function sam_listing(stn)
% list bottle data for chemists
%
m_setup

cdir = pwd;
mcd ctd
fn = ['sam_di346_' sprintf('%03d',stn)];

MEXEC_A.MARGS_IN = {
    fn
    'sampnum wireout upress utemp upsal/'
    ' '
    ' '
    };
mlist
cd(cdir)