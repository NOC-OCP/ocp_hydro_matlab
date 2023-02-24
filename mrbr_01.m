% read in data from RBR converted .txt files, which are handy csvs;
% concatentate into one file and average to 1 s matching each ctd_*psal.nc
% file 

mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

%list of files
sn = 211618;
rbr_root = fullfile(MEXEC_G.mexec_data_root,'ctd','RBR');
[stat, res] = system(['find ' rbr_root ' -name ''' num2str(sn) '*_data.txt'' ']);
ii0 = strfind(res,whitespacePattern);
ii = [[1 ii0(1:end-1)+1]; ii0-1];

%load all rbr
clear drbr
for fno = 1:size(ii,2)
    fname = res(ii(1,fno):ii(2,fno));
    t = readtable(fname);
    iit = find(diff(t.Time)<=0);
    t(iit+1,:) = [];
    iit = find(t.SeaPressure<=-10 | t.SeaPressure>=8000 | t.Temperature>40 | t.Temperature<-2);
    t(iit,:) = [];
    if fno==1
        drbr.time = datenum(t.Time);
        drbr.press = t.SeaPressure;
        drbr.cond = t.Conductivity;
        drbr.temp = t.Temperature;
        drbr.fluor = t.Chlorophyll_a;
        drbr.back = t.Backscatter;
    else
        drbr.time = [drbr.time; datenum(t.Time)];
        drbr.press = [drbr.press; t.SeaPressure];
        drbr.cond = [drbr.cond; t.Conductivity];
        drbr.temp = [drbr.temp; t.Temperature];
        drbr.fluor = [drbr.fluor; t.Chlorophyll_a];
        drbr.back = [drbr.back; t.Backscatter];
    end
    disp([num2str(fno) '/' num2str(size(ii,2))])
end
drbr.time = drbr.time-datenum(2023,1,1);
%assume units are standard (dbar, mS/cm, ITS90)

opt1 = 'ctd_proc'; opt2 = '1hz_interp'; get_cropt
maxfill16 = round(maxfill24*2/3);
root_ctd = mgetdir('ctd');
f1 = dir(fullfile(root_ctd,['ctd_' mcruise '_*_psal.nc']));
for no = 1:length(f1)
    psalfile = fullfile(root_ctd,f1(no).name);
    [d1, h1] = mloadq(psalfile,'/');
    t = d1.time/86400+datenum(h1.data_time_origin)-datenum(2023,1,1);
    iig = find(drbr.time>=t(1)-1/86400 & drbr.time<=t(end)+1/86400);
    if ~isempty(iig)
        clear d
        d.press = drbr.press(iig);
        d.temp = drbr.temp(iig);
        d.cond = drbr.cond(iig);
        d.fluor = drbr.fluor(iig);
        d.back = drbr.back(iig);
        d.time = (drbr.time(iig)-datenum(h1.data_time_origin))*86400;
        d.psal = NaN+d.cond; iig = find(~isnan(d.cond+d.temp)); 
        d.psal(iig) = gsw_SP_from_C(d.cond(iig),d.temp(iig),d.press(iig));
        dg = grid_profile(d, 'time', d1.time, 'meannum', 'num', 16, 'prefill', maxfill16, 'grid_extrap', [0 0], 'postfill', maxfill1);
        keyboard
    end
end

%***keep other variables too
