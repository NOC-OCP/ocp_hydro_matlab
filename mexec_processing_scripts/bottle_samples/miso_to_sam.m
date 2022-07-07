% miso_02: paste iso data into sam file

minit
if MEXEC_G.quiet<=1; fprintf(1, 'pasting bottle isotope data (specified in opt_%s) into sam_%s_%s.nc', mcruise, mcruise, stn_string); end

root_iso = mgetdir('M_BOT_ISO');
root_ctd = mgetdir('M_CTD');
prefix1 = ['iso_' mcruise '_'];
prefix2 = ['sam_' mcruise '_'];
infile1 = fullfile(root_iso, [prefix1 '01']);
otfile2 = fullfile(root_ctd, [prefix2 stn_string]);

% bak on jr302 19 jun 2014 some stations don't have any iso data; exit
% gracefully

if exist(m_add_nc(infile1),'file')~=2;
    mess = ['File ' m_add_nc(infile1) ' not found'];
    fprintf(MEXEC_A.Mfider,'%s\n',mess)
    return
end

oopt = 'vars'; get_cropt

% 
%--------------------------------
% 2009-03-11 02:02:37
% mpaste
% input files
% Filename iso_jc032_001.nc   Data Name :  iso_jc032_001 <version> 3 <site> jc032
% output files
% Filename sam_jc032_001.nc   Data Name :  sam_jc032_001 <version> 16 <site> jc032
MEXEC_A.MARGS_IN = {
otfile2
infile1
'y'
'sampnum'
'sampnum'
cvars
cvars
};
mpaste
%--------------------------------
