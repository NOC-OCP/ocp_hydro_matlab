% infile = 'ctd_di279_04';
% infile = 'grid_jc159_24s';
infile = '/local/users/pstar/jc191/mcruise/data/ctd/grid_jc191_24n';
% infile = 'grid_jc032_main';
% infile = 'ctd_usa98_98';
% infile = 'ctd_he006_92';
% infile = 'ctd_at109_81';
otfile1 = [infile '_g1'];
otfile2 = [infile '_g2'];
otfile3 = [infile '_g3'];

%--------------------------------
%--------------------------------
% 2010-02-09 16:16:58
% mcalc
% calling history, most recent first
%    mcalc in file: mcalc.m line: 228
% input files
% Filename ctd_di279_04.nc   Data Name :  ctd_di279_04 <version> 6 <site> di346_atsea
% output files
% Filename ctd_di279_04_g1.nc   Data Name :  ctd_di279_04 <version> 8 <site> di346_atsea
MEXEC_A.MARGS_IN = {
infile
otfile1
'/'
% 'salin temp press'
'psal temp press'
'y = sw_gpan(x1,x2,x3);'
'gpan'
'none'
' '
};
mcalc
%--------------------------------
%--------------------------------
% 2010-02-09 16:23:31
% mcalc
% calling history, most recent first
%    mcalc in file: mcalc.m line: 228
% input files
% Filename ctd_di279_04_g1.nc   Data Name :  ctd_di279_04 <version> 8 <site> di346_atsea
% output files
% Filename ctd_di279_04_g2.nc   Data Name :  ctd_di279_04 <version> 9 <site> di346_atsea
MEXEC_A.MARGS_IN = {
otfile1
otfile2
' '
'gpan,latitude,longitude'
'y = sw_gvel(x1,x2(1,:),x3(1,:))'
'gvel'
'm/s'
'latitude'
'y = (x1(:,1:end-1)+x1(:,2:end))/2'
'glat'
' '
'longitude'
'y = (x1(:,1:end-1)+x1(:,2:end))/2'
'glon'
' '
'latitude longitude'
'y = repmat(sw_dist(x1(1,:),x2(1,:),''km''),size(x1,1),1)'
'gdist'
'km'
'press'
'y = (x1(:,1:end-1)+x1(:,2:end))/2'
'gpress'
' '
' '
};
mcalc
%--------------------------------


%--------------------------------
% 2010-02-09 16:41:08
% mcalc
% calling history, most recent first
%    mcalc in file: mcalc.m line: 228
% input files
% Filename ctd_di279_04_g2.nc   Data Name :  ctd_di279_04 <version> 15 <site> di346_atsea
% output files
% Filename ctd_di279_04_g3.nc   Data Name :  ctd_di279_04 <version> 16 <site> di346_atsea
MEXEC_A.MARGS_IN = {
otfile2
otfile3
'/'
'gvel'
'y = mcbotref(x1)'
'gveldcl'
' '
' '
};
mcalc
%--------------------------------