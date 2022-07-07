% mdcs_01: find bottom of cast
%
% Use: mdcs_01        and then respond with station number, or for station 16
%      stn = 16; mdcs_01;
%
% dy146 ylf added start of cast estimate

scriptname = 'castpars'; oopt = 'minit'; get_cropt
if MEXEC_G.quiet<=1; fprintf(1,'finding scan number corresponding to bottom of cast for dcs_%s_%s.nc\n',mcruise,stn_string); end

% resolve root directories for various file types
root_ctd = mgetdir('M_CTD');

infile1 = fullfile(root_ctd, ['ctd_' mcruise '_' stn_string '_psal']);
infile0 = fullfile(root_ctd, ['ctd_' mcruise '_' stn_string '_24hz']);

% guess bottom index: max 1hz pressure
[d1, h1] = mloadq(infile1,'time','scan','press',' ');
kbot = find(d1.press==max(d1.press),1,'first');
% or as set in cruise options file
scriptname = mfilename; oopt = 'kbot'; get_cropt

% guess start index: point farthest above previous max pressure
pressd = d1.press(1:min(kbot,3600)); %for deep casts, square matrix for whole downcast would be too big, so limit search to first hour
pressd = pressd(:);
p_minus_maxprev = pressd' - max(triu(repmat(pressd,1,min(kbot,3600))));
[mnd, kstart] = min(p_minus_maxprev);
% or as set in cruise options file
scriptname = mfilename; oopt = 'kstart'; get_cropt

%variables to save
clear ds hnew
ds.statnum = stnlocal;
ds.dc_bot = kbot;
ds.scan_bot = d1.scan(ds.dc_bot);
ds.press_bot = d1.press(ds.dc_bot);
ds.time_bot = d1.time(ds.dc_bot);
ds.dc_start = kstart;
ds.scan_start = d1.scan(ds.dc_start);
ds.press_start = d1.press(ds.dc_start);
ds.time_start = d1.time(ds.dc_start);

%corresponding indices in 24hz file
d24 = mloadq(infile0,'scan',' ');
[~,ds.dc24_bot] = min(abs(d24.scan-ds.scan_bot));
[~,ds.dc24_start] = min(abs(d24.scan-ds.scan_start));

m = ['Bottom of cast is at dc ' sprintf('%d',ds.dc_bot) ' pressure ' sprintf('%8.1f',ds.press_bot) ' and scan ' sprintf('%d',ds.scan_bot)];
fprintf(MEXEC_A.Mfidterm,'%s\n','',m)

% write
dataname = ['dcs_' mcruise '_' stn_string];
otfile = fullfile(root_ctd, dataname);

varnames = fieldnames(ds);
varunits = repmat({'number'},size(varnames));
istime = strncmp('time', varnames, 4);
varunits(istime) = {'seconds'};
ispress = strncmp('press', varnames, 5);
varunits(ispress) = {'dbar'};

MEXEC_A.Mprog = mfilename;
hnew.data_time_origin = h1.data_time_origin;
hnew.fldnam = varnames; hnew.fldunt = varunits;
if exist(m_add_nc(otfile),'file')
    %add to existing file
    mfsave(otfile, ds, hnew, '-addvars');
else
    %save new file
    mfsave(otfile, ds, hnew); 
end
