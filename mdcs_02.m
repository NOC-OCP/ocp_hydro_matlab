% mdcs_02: find scan number corresponding to bottom of file
%          use this to populate the file dcs_[cruise]_[station]
%
% Use: mdcs_02        and then respond with station number, or for station 16
%      stn = 16; mdcs_02;

scriptname = 'mdcs_02';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

if ~exist('stn','var')
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
stnlocal = stn; clear stn % so that it doesn't persist

mdocshow(scriptname, ['finds scan number corresponding to bottom of cast, writes to dcs_' cruise '_' stn_string '.nc']);

root_ctd = mgetdir('M_CTD');

prefix1 = ['ctd_' cruise '_'];
prefix2 = ['dcs_' cruise '_'];

infile1 = [root_ctd '/' prefix1 stn_string '_psal'];
%  infile1 = [root_ctd '/' prefix1 stn_string '_1hz'];  This would be a better choice if have issues with hte data
otfile2 = [root_ctd '/' prefix2 stn_string ];

[d h] = mload(infile1,'time','scan','press',' ');

p = d.press;
% scanmax = min(floor(d.scan((p == max(p)))));
kbot = min(find(p == max(p)));


%--------------------------------

% di346, select bottom data cycle by hand for station 81

if strcmp(cruise,'di346')
    if stnlocal==81
        kbot = 5574;
    end
end
%--------------------------------

scanbot = floor(d.scan(kbot));
pbot = d.press(kbot);
tbot = d.time(kbot);

% set up the data time origin for times start,bottom,end

hinctd = m_read_header(infile1);
hindcs = m_read_header(otfile2);

dtoctd = hinctd.data_time_origin;
dtodcs = hindcs.data_time_origin;
dtodif = dtoctd-dtodcs;
if max(abs(dtodif)) > 0 % reset time origin if needed
    %--------------------------------
    % 2009-01-28 14:51:48
    % mchangetimeorigin
    % input files
    % Filename dcs_jr193_016.nc   Data Name :  dcs_jr193_016 <version> 2 <site> bak_macbook
    % output files
    % Filename dcs_jr193_016.nc   Data Name :  dcs_jr193_016 <version> 3 <site> bak_macbook
    MEXEC_A.MARGS_IN = {
        otfile2
        'y'
        ['[' num2str(hinctd.data_time_origin) ']']
        };
    mchangetimeorigin
    %--------------------------------
end

%--------------------------------
% 2009-01-28 14:41:30
% mcalib
% input files
% Filename dcs_jr193_016.nc   Data Name :  dcs_jr193_016 <version> 1 <site> bak_macbook
% output files
% Filename dcs_jr193_016.nc   Data Name :  dcs_jr193_016 <version> 2 <site> bak_macbook
MEXEC_A.MARGS_IN = {
otfile2
'y'
'time_bot'
['y(1,1) = ' num2str(tbot)]
'/'
'/'
'dc_bot'
['y(1,1) = ' num2str(kbot)]
'/'
'/'
'scan_bot'
['y(1,1) = ' num2str(scanbot)]
'/'
'/'
'press_bot'
['y(1,1) = ' num2str(pbot)]
'/'
'/'
' '
};
mcalib
%--------------------------------

m = ['Bottom of cast is at dc ' sprintf('%d',kbot) ' pressure ' sprintf('%8.1f',pbot) ' and scan ' sprintf('%d',scanbot)];
% m = ['Bottom of cast is at dc ' sprintf('%d',kmax) ' pressure ' sprintf('%8.1f',pmax) ' and scan ' sprintf('%d',scanmax)];
fprintf(MEXEC_A.Mfidterm,'%s\n','',m)
