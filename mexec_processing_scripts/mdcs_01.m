% mdcs_01: find bottom of cast
%
% Use: mdcs_01        and then respond with station number, or for station 16
%      stn = 16; mdcs_01;
%
% dy146 ylf added start of cast estimate; sd025 ylf added end of cast
% estimate

opt1 = 'castpars'; opt2 = 'minit'; get_cropt
if MEXEC_G.quiet<=1; fprintf(1,'finding scan numbers corresponding to cast segments for dcs_%s_%s.nc\n',mcruise,stn_string); end

% resolve root directories for various file types
root_ctd = mgetdir('M_CTD');

infile1 = fullfile(root_ctd, ['ctd_' mcruise '_' stn_string '_psal']);
infile0 = fullfile(root_ctd, ['ctd_' mcruise '_' stn_string '_24hz']);
[d1, h1] = mloadq(infile1,'time','scan','press','pumps',' ');

dataname = ['dcs_' mcruise '_' stn_string];
otfile = fullfile(root_ctd, dataname);

if exist(m_add_nc(otfile),'file')
    [ds, hnew] = mloadq(otfile,'/');
else
    clear ds hnew
    ds.statnum = stnlocal;
    hnew.data_time_origin = h1.data_time_origin;
    hnew.comment = '';
end

auto_start = 0; auto_bot = 0; auto_end = 0; kstart = []; kbot = []; kend = []; 
opt1 = mfilename; opt2 = 'cast_divide'; get_cropt

if ~isfield(ds,'dc_bot') || auto_bot
    if isempty(kbot)
        % guess bottom index: first time pressure is within 0.5 dbar of max
        mp = max(d1.press);
        kbot = find(d1.press>=mp-0.5,1,'first');
        hnew.comment = [hnew.comment ' auto detected bottom time'];
    else
        hnew.comment = [hnew.comment ' bottom time set in opt_cruise'];
    end
    ds.dc_bot = kbot;
    ds.scan_bot = d1.scan(ds.dc_bot);
    ds.press_bot = d1.press(ds.dc_bot);
    ds.time_bot = d1.time(ds.dc_bot);
    m = ['Bottom of cast is at dc ' sprintf('%d',ds.dc_bot) ' pressure ' sprintf('%8.1f',ds.press_bot)];
    fprintf(MEXEC_A.Mfidterm,'%s\n','',m)
end

if ~isfield(ds,'dc_start') || auto_start
    if isempty(kstart)
        % guess start index: point farthest above (lower pressure than) previous max pressure
        pressd = d1.press(1:min(kbot,3600)); %for deep casts, square matrix for whole downcast would be too big, so limit search to first hour
        pressd = pressd(:);
        p_minus_maxprev = pressd' - max(triu(repmat(pressd,1,min(kbot,3600))));
        [mnd, kstart] = min(p_minus_maxprev);
        hnew.comment = [hnew.comment ' auto detected start time'];
    else
        hnew.comment = [hnew.comment ' start time set in opt_cruise'];
    end
    ds.dc_start = kstart;
    ds.scan_start = d1.scan(ds.dc_start);
    ds.press_start = d1.press(ds.dc_start);
    ds.time_start = d1.time(ds.dc_start);
        m = ['Start of cast is at dc ' sprintf('%d',ds.dc_start) ' pressure ' sprintf('%8.1f',ds.press_start)];
        fprintf(MEXEC_A.Mfidterm,'%s\n','',m)
end

if ~isfield(ds,'dc_end') || auto_end
    if isempty(kend)
        % guess end index: when pumps go off finally with p<2, or just before p<0, whichever is first
        kend = find(d1.pumps(kbot+1:end)<1 & d1.pumps(kbot:end-1)==1 & d1.press(kbot+1:end)<2, 1, 'last') + kbot - 2;
        if isempty(kend); kend = length(d1.pumps); end
        ksurf2 = find(d1.press(kbot:end)<0, 1, 'first') + kbot - 2;
        if ~isempty(ksurf2)
            kend = min(kend, ksurf2);
        end
        %or when min p is reached for yo-yo cast with separate files
        kmin = find(d1.press(kbot:end)==min(d1.press(kbot:end))) + kbot -1;
        kend = min(kend, kmin);
        hnew.comment = [hnew.comment ' auto detected end time'];
    else
        hnew.comment = [hnew.comment ' end time set in opt_cruise'];
    end
    ds.dc_end = kend;
    ds.scan_end = d1.scan(ds.dc_end);
    ds.press_end = d1.press(ds.dc_end);
    ds.time_end = d1.time(ds.dc_end);
        m = ['End of cast is at dc ' sprintf('%d',ds.dc_end) ' pressure ' sprintf('%8.1f',ds.press_end)];
        fprintf(MEXEC_A.Mfidterm,'%s\n','',m)
end

%corresponding indices in 24hz file
d24 = mloadq(infile0,'scan',' ');
[~,ds.dc24_bot] = min(abs(d24.scan-ds.scan_bot));
[~,ds.dc24_start] = min(abs(d24.scan-ds.scan_start));
[~,ds.dc24_end] = min(abs(d24.scan-ds.scan_end));

% write
varnames = fieldnames(ds);
varunits = repmat({'number'},size(varnames));
istime = strncmp('time', varnames, 4);
opt1 = 'mstar'; get_cropt
if docf
    varunits(istime) = {['seconds since ' datestr(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN,'yyyy-mm-dd HH:MM:SS')]};
    hnew.data_time_origin = [];
else
    varunits(istime) = {'seconds'};
end
ispress = strncmp('press', varnames, 5);
varunits(ispress) = {'dbar'};

MEXEC_A.Mprog = mfilename;
hnew.fldnam = varnames; hnew.fldunt = varunits;
mfsave(otfile, ds, hnew);
