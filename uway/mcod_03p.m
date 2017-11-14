% average a single profile from on station vmadcp data

m_common
m_margslocal
m_varargs

scriptname = 'mcod_03p';

if exist('stn','var')
    m = ['Running script ' scriptname ' on station ' sprintf('%03d',stn)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);

if exist('os','var')
    m = ['Running script ' scriptname ' for OS ' sprintf('%d',os)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    os = input('Enter OS type: 75 or 150 ');
end

mcd vmadcp
cmd=['cd ' MEXEC_G.MSCRIPT_CRUISE_STRING '_os' sprintf('%d',os)];eval(cmd);

infile=['os' sprintf('%d',os) '_' MEXEC_G.MSCRIPT_CRUISE_STRING 'nnx_stn' stn_string ];
otfile=['os' sprintf('%d',os) '_' MEXEC_G.MSCRIPT_CRUISE_STRING 'nnx_stn' stn_string 'p'];

%--------------------------------
% 2010-01-18 14:07:10
% mavrge
% calling history, most recent first
%    mavrge in file: mavrge.m line: 324
% input files
% Filename os75_di346nnx_stn008.nc   Data Name :  os75_di346nnx_stn008 <version> 1 <site> di346_atsea
% output files
% Filename os75_di346nnx_stn008p.nc   Data Name :  os75_di346nnx_stn008 <version> 2 <site> di346_atsea
MEXEC_A.MARGS_IN = {
infile
otfile
'/'
'time'
'c'
'0,1e10,1e10'
'b'
};
mavrge
%--------------------------------