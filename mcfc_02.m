% mcfc_02: paste cfc data into sam file

scriptname = 'mcfc_02';
cruise = 'MEXEC_G.MSCRIPT_CRUISE_STRING';
oopt = '';

if exist('stn','var')
    m = ['Running script ' scriptname ' on station ' sprintf('%03d',stn)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
stnlocal = stn;
clear stn % so that it doesn't persist

root_cfc = mgetdir('M_BOT_CFC');
root_ctd = mgetdir('M_CTD');
prefix1 = ['cfc_' cruise '_'];
prefix2 = ['sam_' cruise '_'];
oopt = 'infile1'; get_cropt
otfile2 = [root_ctd '/' prefix2 stn_string];


% bak on jr281 march 2013
% allow for each cruise to have a specific cfc list
%
oopt = 'cfclist'; get_cropt


%--------------------------------
% 2009-03-13 17:06:01
% mpaste
% input files
% Filename cfc_jc032_003.nc   Data Name :  cfc_jc032_003 <version> 1 <site> jc032
% output files
% Filename sam_jc032_003.nc   Data Name :  sam_jc032_003 <version> 10 <site> jc032
MEXEC_A.MARGS_IN = {
otfile2
infile1
'y'
'sampnum'
'sampnum'
cfcinlist
cfcotlist
};
mpaste

%--------------------------------


while strcmp(cruise,'di346')
    
    extrabad = {
        2308 'ccl4'
        2309 'ccl4'
        2310 'ccl4'
        2311 'ccl4'
        2404 'cfc12 cfc11 f113 ccl4 sf6'
        2504 'cfc12 cfc11 f113 ccl4 sf6'
        2512 'f113'
        3109 'cfc12 cfc11 f113 ccl4 sf6'
        3110 'cfc12 cfc11 f113 ccl4 sf6'
        3605 'ccl4'
        4110 'sf6'
        4512 'f113'
        4708 'cfc12 cfc11 f113 ccl4 sf6'
        4709 'cfc12 cfc11 f113 ccl4 sf6'
        4710 'cfc12 cfc11 f113 ccl4 sf6'
        4711 'cfc12 cfc11 f113 ccl4 sf6'
        4712 'cfc12 cfc11 f113 ccl4 sf6'
        5002 'cfc12 cfc11 f113 ccl4 sf6'
        5112 'sf6'
        5211 'ccl4'
        6713 'cfc11 f113 '
        };

    numsamps = size(extrabad,1);
    sampall = nan+ones(numsamps,1);
    statall = nan+ones(numsamps,1);
    for klsam = 1:numsamps
        sampall(klsam) = extrabad{klsam,1};
        statall(klsam) = floor(sampall(klsam)/100);
    end

    kmat = find(statall == stnlocal);
    if isempty(kmat); break; end
    nmat = length(kmat); % number of samples to be fixed on this station
    for klmat = 1:nmat

        mcset_flag(otfile2,extrabad{kmat(klmat),1},extrabad{kmat(klmat),2}); % use default new flags
    end
    break
end
