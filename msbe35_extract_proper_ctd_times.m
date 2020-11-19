% msbe35_extract_proper_ctd_times
%
% Use: msbe35_extract_proper_ctd_times        and then respond with station number, or for station 16
%      stn = 16; msbe35_extract_proper_ctd_times;
%
% bak on jc191 3 Feb 2020
%
% extract CTD data that properly corresponds to sbe35 sampling period
% SBE35 sampling time for each station set in opt_jc191
%
% Populates a master sbe35 comparison file.
% input files are
% ctd_ccccc_nnn_24hz.nc
% sam_ccccc_nnn.nc
% sam_ccccc_all.nc
%
% output files are
% sbe35compare_ccccc_nnn.nc
% sbe35compare_ccccc_all.nc
% 
% Writes a bad flag for the SBE35 temp if the CTD pressure has a range of
% more than 5 dbar during the sampling period.

scriptname = 'msbe35_extract_proper_ctd_times';
minit
mdocshow(scriptname, ['copies sbe35 data from sam file and adds CTD data. Writes to to sbe35compare_' mcruise '_all.nc']);

root_ctd = mgetdir('M_CTD');
prefix1 = ['ctd_' mcruise '_'];
prefix2 = ['sam_' mcruise '_'];
prefix3 = ['sam_' mcruise '_'];
prefix4 = ['sbe35compare_' mcruise '_'];
prefix5 = ['sbe35compare_' mcruise '_'];
prefix6 = ['sbe35compare_' mcruise '_'];

infile1 = [root_ctd '/' prefix1 stn_string '_24hz']; % ctd_jc191_nnn_24hz
infile2 = [root_ctd '/' prefix2 stn_string ];        % sam_jc191_nnn
infile3 = [root_ctd '/' prefix3 'all'];              % sam_jc191_all
otfile4 = [root_ctd '/' prefix4 stn_string];         % sbe35compare_jc191_nnn
otfile5 = [root_ctd '/' prefix4 'all'];              % sbe35compare_jc191_all
otfile6 = [root_ctd '/' prefix4 'allspare'];         % sbe35compare_jc191_allspare

% check the files exist
if exist(m_add_nc(infile1),'file') ~= 2
    msg = ['ctd file ' infile1 ' not found'];
    fprintf(MEXEC_A.Mfider,'%s\n',msg);
    return
end
if exist(m_add_nc(infile2),'file') ~= 2
    msg = ['sam file ' infile2 ' not found'];
    fprintf(MEXEC_A.Mfider,'%s\n',msg);
    return
end
if exist(m_add_nc(infile3),'file') ~= 2
    msg = ['sam file ' infile4 ' not found'];
    fprintf(MEXEC_A.Mfider,'%s\n',msg);
    return
end
if exist(m_add_nc(otfile5),'file') ~= 2
    % if the sbe35compare _all file does not exist, make it from the sam_all
    msg = ['sbe35 file ' otfile5 ' not found; making it'];
    fprintf(MEXEC_A.Mfider,'%s\n',msg);
    MEXEC_A.MARGS_IN = {
        infile3
        otfile5
        'sampnum statnum position time wireout upress sbe35temp sbe35flag utemp1 utemp2'
        ' '
        ' '
        ' '
        };
    mcopya
    %--------------------------------
end
% now move the existing compare file to a spare,
% then copy the required vars from the present sam_all file
% then paste back what we already had in sbe35compare_all
% this ensures the sbe35compare_all is updated, from sam_all, but its
% contents are preserved.

system(['/bin/cp -p ' m_add_nc(otfile5) ' ' m_add_nc(otfile6)]);
%--------------------------------
MEXEC_A.MARGS_IN = { % copy from sam_all to sbe35compare_all
    infile3
    otfile5
    'sampnum statnum position time wireout upress sbe35temp sbe35flag utemp1 utemp2'
    ' '
    ' '
    ' '
    };
mcopya
%--------------------------------

%--------------------------------
MEXEC_A.MARGS_IN = { % paste from sbe35compare_allspare to sbe35compare_all
    otfile5
    otfile6
    'y'
    'sampnum'
    'sampnum'
    '/'
    '/'
    };
mpaste
%--------------------------------

%--------------------------------
MEXEC_A.MARGS_IN = { % copy from sam_nnn to sbe35compare_nnn
    infile2
    otfile4
    'sampnum statnum position time wireout upress sbe35temp sbe35flag utemp1 utemp2'
    ' '
    ' '
    ' '
    };
mcopya
%--------------------------------

% now fix up otfile4
[dc hc] = mload(infile1,'/'); % station ctd file
[ds hs] = mload(otfile4,'/'); % station sbe35 file

dc.dnum = datenum(hc.data_time_origin) + dc.time/86400;
ds.dnum = datenum(hs.data_time_origin) + ds.time/86400;
sb35_n = 20;
if (stnlocal >= 61 & stnlocal <= 74); sb35_n = 100; end
sb35_t = 1.1*sb35_n; % seconds
sb35_t = sb35_t + 5; % allow 5 extra seconds beyond nominal end of sbe35 sampling during which we monitor pressure
sb35_t = sb35_t/86400; %days
ctdrange = 5; % range allowed for CTD pressure variation during sampling

nsamp = length(ds.dnum); % number of sbe35 samples
for kn = 1:nsamp
    t_start = ds.dnum(kn);
    t_end = t_start + sb35_t;
    kctd = find(dc.dnum >= t_start & dc.dnum <= t_end);
    ctd_p = dc.press(kctd);
    ctd_t1 = dc.temp1(kctd);
    ctd_t2 = dc.temp2(kctd);
    ds.utemp1(kn) = nanmean(ctd_t1);
    ds.utemp2(kn) = nanmean(ctd_t2);
    if range(ctd_p) > 5
        ds.sbe35flag(kn) = max(ds.sbe35flag(kn),4); % increase flag to 4 if ctd pressure varies too much
    end
end

flagstr = ['y = [' num2str(ds.sbe35flag(:)') ']''']; 
utemp1str = ['y = [' num2str(ds.utemp1(:)') ']''']; 
utemp2str = ['y = [' num2str(ds.utemp2(:)') ']''']; 


%--------------------------------
MEXEC_A.MARGS_IN = {
otfile4
'y'
'sbe35flag'
flagstr
' '
' '
'utemp1'
utemp1str
' '
' '
'utemp2'
utemp2str
' '
' '
' '
};
mcalib
%--------------------------------


%--------------------------------
MEXEC_A.MARGS_IN = { % paste from sbe35compare_nnn to sbe35compare_all
    otfile5
    otfile4
    'y'
    'sampnum'
    'sampnum'
    '/'
    '/'
    };
mpaste
%--------------------------------




return


