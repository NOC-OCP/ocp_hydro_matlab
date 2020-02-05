% mdcs_02: find scan number corresponding to bottom of file
%          use this to populate the file dcs_[cruise]_[station]
%
% Use: mdcs_02        and then respond with station number, or for station 16
%      stn = 16; mdcs_02;

minit; scriptname = mfilename;
mdocshow(scriptname, ['finds scan number corresponding to bottom of cast, writes to dcs_' mcruise '_' stn_string '.nc']);

root_ctd = mgetdir('M_CTD');

infile1 = [root_ctd '/ctd_' mcruise '_' stn_string '_psal'];
otfile2 = [root_ctd '/dcs_' mcruise '_' stn_string ];
infile0 = [root_ctd '/ctd_' mcruise '_' stn_string '_24hz'];

[d h] = mload(infile1,'time','scan','press',' ');
d24 = mload(infile0,'scan',' ');

p = d.press;
% scanmax = min(floor(d.scan((p == max(p)))));
kbot = min(find(p == max(p)));


%--------------------------------

get_cropt

scanbot = floor(d.scan(kbot));
pbot = d.press(kbot);
tbot = d.time(kbot);
k24bot = min(find(d24.scan >= scanbot));

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
'dc24_bot'
['y(1,1) = ' num2str(k24bot)]
'/'
'/'
' '
};
mcalib
%--------------------------------

m = ['Bottom of cast is at dc ' sprintf('%d',kbot) ' pressure ' sprintf('%8.1f',pbot) ' and scan ' sprintf('%d',scanbot)];
% m = ['Bottom of cast is at dc ' sprintf('%d',kmax) ' pressure ' sprintf('%8.1f',pmax) ' and scan ' sprintf('%d',scanmax)];
fprintf(MEXEC_A.Mfidterm,'%s\n','',m)
