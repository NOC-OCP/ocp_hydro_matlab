function mk_ctdfile(statnum)
% function mk_ctdfile(statnum)
% quick for jr195
% adapted form jc032

% #!/bin/csh -f
% ## to make the correct format ascii ctd files
% ## from 1 hz pstar ctd data
% ##
% ## run with command >mk_ctdfile 017
% ## - where 017 is station number

% /bin/rm -f MLIST.ASCII

m_common

if ischar(statnum); 
    statnum = str2num(statnum); % variables come in as char if simply typed on the command line
end 

kstn = statnum;

root_ctd = mgetdir('M_CTD');

infile = [root_ctd '/ctd_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' sprintf('%03d',kstn) '_psal'];

if exist(m_add_nc(infile),'file') ~= 2
    return
end

MEXEC_A.MARGS_IN = {
infile
'time press temp psal latitude longitude'
% 'time press temp sal00'
'0'
}
mload

Igd = find(~isnan(ans.temp)&~isnan(ans.psal));

dum = [ans.time(Igd)' ans.press(Igd)' ans.temp(Igd)' ans.psal(Igd)' ans.latitude(Igd)' ans.longitude(Igd)'];

eval(['save ' root_ctd '/ctd_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' num2str(kstn,'%03.0f') '_1hz_txt  dum -ascii'])
