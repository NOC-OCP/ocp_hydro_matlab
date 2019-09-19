mcd M_CTD 

% section = 'bc1'; % jc032
% section = 'bc2'; % jc032
% section = 'bc3'; % jc032
% % section = 'all'; % jc032 
% section = 'main'; % jc032
% section = 'fc'; % di346
 section = 'jc069_towyo'; % di346
% grid = '10 6000 20'; % jc032
gstart = 10; gstop = 4500; gstep = 20; % di346
grid = sprintf('%d %d %d',gstart,gstop,gstep);
xpress = gstart:gstep:gstop; 
numlev = length(xpress);

varlist = [];
varlist = [varlist ' press'];
varlist = [varlist ' temp'];
varlist = [varlist ' psal'];
varlist = [varlist ' potemp'];
varlist = [varlist ' oxygen'];
varlist = [varlist ' fluor'];
varlist = [varlist ' transmittance'];


switch section
    case 'bc1'
        sstring = '[1:9]';
        cmd = ['kstns = ' sstring ';']; eval(cmd);
    case 'bc2'
        sstring = '[10:22]';
        cmd = ['kstns = ' sstring ';']; eval(cmd);
    case 'bc3'
        sstring = '[23:35]';
        cmd = ['kstns = ' sstring ';']; eval(cmd);
    case 'all'
        sstring = '[1:47 49:118]';
        cmd = ['kstns = ' sstring ';']; eval(cmd);
    case 'main'
        sstring = '[23:35 37:47 49:118]';
        cmd = ['kstns = ' sstring ';']; eval(cmd);
    case 'fc'
        sstring = '[2:13]';
        cmd = ['kstns = ' sstring ';']; eval(cmd);
    case '24n'
        sstring = '[14 15 16 18 17 19:40 41 42:135]';
        cmd = ['kstns = ' sstring ';']; eval(cmd);
    case 'jc069_towyo'
        sstring = '[40:59]';
        cmd = ['kstns = ' sstring ';']; eval(cmd);
    otherwise
        return
end

prefix = ['ctd_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
prefix2 = ['grid_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];


otfile = [prefix section];
otfile2 = [prefix2 section];

dataname = [prefix section];


fnlist = {};
for kstn = kstns
    stn_string = sprintf('%03d',kstn);
    infile1 = [prefix  stn_string '_2db'];
    infile2 = [prefix  stn_string '_2up'];
    fprintf(MEXEC_A.Mfidterm,'%s%s\n','adding ',infile1);
    fnlist = [fnlist; infile1];
    fprintf(MEXEC_A.Mfidterm,'%s%s\n','adding ',infile2);
    fnlist = [fnlist; infile2];
end

%--------------------------------
% 2009-03-18 19:32:06
% mgridp
% input files
% Filename sam_jc032_001.nc   Data Name :  sam_jc032_001 <version> 27 <site> jc032
% Filename sam_jc032_002.nc   Data Name :  sam_jc032_002 <version> 17 <site> jc032
% Filename sam_jc032_003.nc   Data Name :  sam_jc032_003 <version> 16 <site> jc032
% Filename sam_jc032_004.nc   Data Name :  sam_jc032_004 <version> 16 <site> jc032
% Filename sam_jc032_005.nc   Data Name :  sam_jc032_005 <version> 15 <site> jc032
% Filename sam_jc032_006.nc   Data Name :  sam_jc032_006 <version> 15 <site> jc032
% Filename sam_jc032_007.nc   Data Name :  sam_jc032_007 <version> 15 <site> jc032
% Filename sam_jc032_008.nc   Data Name :  sam_jc032_008 <version> 14 <site> jc032
% Filename sam_jc032_009.nc   Data Name :  sam_jc032_009 <version> 25 <site> jc032
% output files
% Filename section_cfc.nc   Data Name :  section_cfc <version> 1 <site> jc032
MEXEC_A.MARGS_IN_1 = {
otfile
dataname
't'
};
MEXEC_A.MARGS_IN_2 = {
    ''
varlist
grid
};
MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN_1; fnlist; MEXEC_A.MARGS_IN_2];
mgridp

%--------------------------------
%--------------------------------
return
stnline = ['y = repmat(' sstring ',' sprintf('%d',numlev)  ',1);'];

%--------------------------------
% 2009-03-26 21:48:42
% mcalc
% input files
% Filename ctd_jc032_bc3.nc   Data Name :  ctd_jc032_bc3 <version> 5 <site> jc032
% output files
% Filename wk.nc   Data Name :  ctd_jc032_bc3 <version> 6 <site> jc032
MEXEC_A.MARGS_IN = {
otfile
'gridwk.nc'
'/'
'1'
stnline
'statnum'
'number'
' '
};
mcalc
%--------------------------------



%--------------------------------

MEXEC_A.MARGS_IN = {
    'gridwk'
    otfile2
    '/'
    'statnum psal temp press'
    'y = m_maptracer(x1,x2,x3,x4,''botoxy'',''botoxyflag'')'
    'botoxy'
    'umol/kg'
    'statnum psal temp press'
    'y = m_maptracer(x1,x2,x3,x4,''silc'',''silc_flag'')'
    'silc'
    'umol/kg'
    'statnum psal temp press'
    'y = m_maptracer(x1,x2,x3,x4,''phos'',''phos_flag'')'
    'phos'
    'umol/kg'
    'statnum psal temp press'
    'y = m_maptracer(x1,x2,x3,x4,''totnit'',''totnit_flag'')'
    'totnit'
    'umol/kg'
    'statnum psal temp press'
    'y = m_maptracer(x1,x2,x3,x4,''alk'',''alk_flag'')'
    'alk'
    'umol/kg'
    'statnum psal temp press'
    'y = m_maptracer(x1,x2,x3,x4,''dic'',''dic_flag'')'
    'dic'
    'umol/kg'
    'statnum psal temp press'
    'y = m_maptracer(x1,x2,x3,x4,''cfc11'',''cfc11_flag'')'
    'cfc11'
    'pmol/l'
    'statnum psal temp press'
    'y = m_maptracer(x1,x2,x3,x4,''cfc12'',''cfc12_flag'')'
    'cfc12'
    'pmol/l'
    'statnum psal temp press'
    'y = m_maptracer(x1,x2,x3,x4,''sf6'',''sf6_flag'')'
    'sf6'
    'fmol/l'
    'statnum psal temp press'
    'y = m_maptracer(x1,x2,x3,x4,''f113'',''f113_flag'')'
    'f113'
    'pmol/l'
    'statnum psal temp press'
    'y = m_maptracer(x1,x2,x3,x4,''ccl4'',''ccl4_flag'')'
    'ccl4'
    'pmol/l'
    'statnum psal temp press'
    'y = m_maptracer(x1,x2,x3,x4,''tn'',''tn_flag'')'
    'tn'
    'umol/kg'
    'statnum psal temp press'
    'y = m_maptracer(x1,x2,x3,x4,''tp'',''tp_flag'')'
    'tp'
    'umol/kg'
    'statnum psal temp press'
    'y = m_maptracer(x1,x2,x3,x4,''don'',''don_flag'')'
    'don'
    'umol/kg'
    'statnum psal temp press'
    'y = m_maptracer(x1,x2,x3,x4,''dop'',''dop_flag'')'
    'dop'
    'umol/kg'
    ' '
};
mcalc
%--------------------------------
