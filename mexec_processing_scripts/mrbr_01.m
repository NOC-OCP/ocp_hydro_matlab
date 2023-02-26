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
%assume units are standard (dbar, mS/cm, ITS90)

opt1 = 'ctd_proc'; opt2 = '1hz_interp'; get_cropt
maxfill16 = round(maxfill24*2/3);
root_ctd = mgetdir('ctd');
klist = [1:170];
clear dgr dgs
for stn = klist
    psalfile = fullfile(root_ctd,sprintf('ctd_%s_%03d_psal.nc',mcruise,stn));
    if exist(psalfile,'file')
        [d1, h1] = mload(psalfile,'/');
        te = d1.time-0.5; te(length(te)+1) = te(end)+1;
        te = m_commontime(te,h1,'datenum');
        iig = find(drbr.time>te(1)-1/86400 & drbr.time<te(end)+1/86400);
        if length(iig)>5*60
            clear d
            d.press = drbr.press(iig);
            d.temp = drbr.temp(iig);
            d.cond = drbr.cond(iig);
            d.fluor = drbr.fluor(iig);
            d.back = drbr.back(iig);
            d.time = drbr.time(iig);
            d.psal = NaN+d.cond; iig = find(~isnan(d.cond+d.temp));
            d.psal(iig) = gsw_SP_from_C(d.cond(iig),d.temp(iig),d.press(iig));
            dgr(stn) = grid_profile(d, 'time', te, 'meanbin', 'prefill', maxfill16, 'grid_extrap', [0 0], 'postfill', maxfill1);
            dgs(stn).time = dgr(stn).time;
            te = .5*(te(1:end-1)+te(2:end));
            dgs(stn).press = interp1(te,d1.press,dgs(stn).time);
            dgs(stn).temp = interp1(te,d1.temp,dgs(stn).time);
            dgs(stn).cond = interp1(te,d1.cond,dgs(stn).time);
            dgs(stn).psal = interp1(te,d1.psal,dgs(stn).time);
            dgs(stn).fluor = interp1(te,d1.fluor,dgs(stn).time);
            if isfield(d1,'turbidity')
                dgs(stn).back = interp1(te,d1.turbidity,dgs(stn).time);
            else
                dgs(stn).back = NaN+dgs(stn).time;
            end
        else
            klist(klist==stn) = NaN;
        end
    else
        klist(klist==stn) = NaN;
    end
end
rbr_stns = klist(~isnan(klist));
dgs = dgs(~isnan(klist));
dgr = dgr(~isnan(klist));

save(fullfile(mgetdir('ctd'),sprintf('rbr_%s_all',mcruise)), 'dgr', 'rbr_stns', 'dgs')
