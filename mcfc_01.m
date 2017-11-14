% mcfc_01: read in the bottle cfc data
%
% Use: mcfc_01        and then respond with station number, or for station 16
%      stn = 16; mco2_01;

scriptname = 'mcfc_01';

% BAK on jc032; data from Ute; 3 files and structures contain data from all
% stations
% % % % % if exist('stn','var')
% % % % %     m = ['Running script ' scriptname ' on station ' sprintf('%03d',stn)];
% % % % %     fprintf(MEXEC_A.Mfidterm,'%s\n',m)
% % % % % else
% % % % %     stn = input('type stn number ');
% % % % % end
% % % % % stn_string = sprintf('%03d',stn);
% % % % % % clear stn % so that it doesn't persist

% bak on di346: a single matlab file provided by Andrew Brousseau

% resolve root directories for various file types
root_cfc = mgetdir('M_BOT_CFC');

prefix1 = ['cfc_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
otfile = [root_cfc '/' prefix1 '01']; % di346 ; previously hardwired on jc032
dataname = [prefix1 '01'];

clear fn

fn = 'cfc_jr302_all_raw';

data = load([root_cfc '/' fn '.mat']);

cmd = ['indata = data.BottleFile_Data;']; eval(cmd);

incols = [1 2 7 8 9 10 11 12 13 14 15 16]; % these are the columns that correspond to the vars below.

indata = indata(:,incols); 
% jr302 30 columns of indata

invars = {
    'statnum'
    'position'
    'cfc12'
    'cfc12_flag'
    'cfc11'
    'cfc11_flag'
    'f113'
    'f113_flag'
    'ccl4'
    'ccl4_flag'
    'sf6'
    'sf6_flag'
    };
inunits = {
    'number'
    'on.rosette'
    'pmol/l'
    'woce_table_4.9'
    'pmol/l'
    'woce_table_4.9'
    'pmol/l'
    'woce_table_4.9'
    'pmol/l'
    'woce_table_4.9'
    'fmol/l'
    'woce_table_4.9'
    };

for kloop = 1:length(invars);
    cmd = ['clear in' invars{kloop} ';']; eval(cmd);
    cmd = ['in' invars{kloop} ' = indata(:,kloop);']; eval(cmd);
end

% scaling
vars_toscale = {'sf6' 'cfc12' 'cfc11' 'f113' 'ccl4'};
scale = [1e15 1e12 1e12 1e12 1e12]; % no scaling on ccl4 yet; other dtaa start in mols

for kloop = 1:length(scale)
    cmd = ['in' vars_toscale{kloop} ' = in' vars_toscale{kloop} ' * scale(kloop);']; eval(cmd);
    % temp fix to kill some zerosd where area is nan
end


last_stn = max(instatnum);
insampnum = 100*instatnum+inposition;
nsamps = 24*last_stn;

sf6 = nan+zeros(nsamps,1);
sf6_flag = 9+zeros(nsamps,1);
cfc12 = sf6;
cfc12_flag = sf6_flag;
cfc11 = sf6;
cfc11_flag = sf6_flag;
f113 = sf6;
f113_flag = sf6_flag;
ccl4 = sf6;
ccl4_flag = sf6_flag;
sampnum = sf6;
statnum = sf6;
position = sf6;

for kstn = 1:last_stn
    for kpos = 1:24;
        index = kpos+24*(kstn-1);
        snum = kstn*100+kpos;
        sampnum(index) = snum;
        statnum(index) = kstn;
        position(index) = kpos;
        kmatch = find(insampnum == snum);
        if isempty(kmatch); continue; end
        
        sf6_match = insf6(kmatch);
        sf6_flag_match = insf6_flag(kmatch);
        sf6_bestflag = min(sf6_flag_match); % best quality flag for this sample; so if one replicate has flag = 3 it will be excluded
        kuse = find(sf6_flag_match == sf6_bestflag); %match best flag, eg all the 2s or all the 3s.
        sf6(index) = m_nanmean(sf6_match(kuse));
        sf6_flag(index) = sf6_bestflag;
        sampnum(index) = snum;

        cfc12_match = incfc12(kmatch);
        cfc12_flag_match = incfc12_flag(kmatch);
        cfc12_bestflag = min(cfc12_flag_match); % best quality flag for this sample; so if one replicate has flag = 3 it will be excluded
        kuse = find(cfc12_flag_match == cfc12_bestflag); %match best flag, eg all the 2s or all the 3s.
        cfc12(index) = m_nanmean(cfc12_match(kuse));
        cfc12_flag(index) = cfc12_bestflag;

        cfc11_match = incfc11(kmatch);
        cfc11_flag_match = incfc11_flag(kmatch);
        cfc11_bestflag = min(cfc11_flag_match); % best quality flag for this sample; so if one replicate has flag = 3 it will be excluded
        kuse = find(cfc11_flag_match == cfc11_bestflag); %match best flag, eg all the 2s or all the 3s.
        cfc11(index) = m_nanmean(cfc11_match(kuse));
        cfc11_flag(index) = cfc11_bestflag;

        f113_match = inf113(kmatch);
        f113_flag_match = inf113_flag(kmatch);
        f113_bestflag = min(f113_flag_match); % best quality flag for this sample; so if one replicate has flag = 3 it will be excluded
        kuse = find(f113_flag_match == f113_bestflag); %match best flag, eg all the 2s or all the 3s.
        f113(index) = m_nanmean(f113_match(kuse));
        f113_flag(index) = f113_bestflag;

        ccl4_match = inccl4(kmatch);
        ccl4_flag_match = inccl4_flag(kmatch);
        ccl4_bestflag = min(ccl4_flag_match); % best quality flag for this sample; so if one replicate has flag = 3 it will be excluded
        kuse = find(ccl4_flag_match == ccl4_bestflag); %match best flag, eg all the 2s or all the 3s.
        ccl4(index) = m_nanmean(ccl4_match(kuse));
        ccl4_flag(index) = ccl4_bestflag;

% %         % temporary fix: jc032
% % %         if (kstn == 13 & (kpos == 17 | kpos == 19)); alk_flag(index) = 4; end
    end
end



% sorting out units for msave

varnames = ['sampnum' ; invars(:)];
varunits = ['number' ; inunits(:)];
varnames_units = {};
for k = 1:length(invars)
    varnames_units = [varnames_units; varnames(k)];
    varnames_units = [varnames_units; {'/'}];
    varnames_units = [varnames_units; varunits(k)];
end
timestring = ['[' sprintf('%d %d %d %d %d %d',MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN) ']'];


% return
%--------------------------------
% 2009-03-09 20:49:09
% msave
% input files
% Filename    Data Name :   <version>  <site>
% output files
% Filename oxy_jc032_001.nc   Data Name :  oxy_jc032_001 <version> 1 <site> jc032MEXEC_A.MARGS_IN_1 = {
MEXEC_A.MARGS_IN_1 = {
    otfile
    };
MEXEC_A.MARGS_IN_2 = varnames(:);
MEXEC_A.MARGS_IN_3 = {
    ' '
    ' '
    '1'
    dataname
    '/'
    '2'
    MEXEC_G.PLATFORM_TYPE
    MEXEC_G.PLATFORM_IDENTIFIER
    MEXEC_G.PLATFORM_NUMBER
    '/'
    '4'
    timestring
    '/'
    '8'
    };
MEXEC_A.MARGS_IN_4 = varnames_units(:);
MEXEC_A.MARGS_IN_5 = {
    '-1'
    '-1'
    };
MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN_1; MEXEC_A.MARGS_IN_2; MEXEC_A.MARGS_IN_3; MEXEC_A.MARGS_IN_4; MEXEC_A.MARGS_IN_5];
msave
%----

