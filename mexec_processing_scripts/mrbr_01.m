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
for fno = size(ii,2):-1:1
    fname = res(ii(1,fno):ii(2,fno));
    t = readtable(fname);
    iit = find(diff(t.Time)<=0);
    t(iit+1,:) = [];
    iit = find(t.SeaPressure<=-10 | t.SeaPressure>=8000 | t.Temperature>40 | t.Temperature<-2);
    t(iit,:) = [];
    if fno==size(ii,2)
        drbr.time = datenum(t.Time);
        drbr.press = t.SeaPressure;
        drbr.cond = t.Conductivity;
        drbr.temp = t.Temperature;
        drbr.fluor = t.Chlorophyll_a;
        drbr.back = t.Backscatter;
    else
        tim = datenum(t.Time);
        [~,iinew] = setdiff(tim,drbr.time);
        drbr.time = [drbr.time; tim(iinew)];
        drbr.press = [drbr.press; t.SeaPressure(iinew)];
        drbr.cond = [drbr.cond; t.Conductivity(iinew)];
        drbr.temp = [drbr.temp; t.Temperature(iinew)];
        drbr.fluor = [drbr.fluor; t.Chlorophyll_a(iinew)];
        drbr.back = [drbr.back; t.Backscatter(iinew)];
    end
    disp([num2str(fno) '/' num2str(size(ii,2))])
end
%now sort
[drbr.time,ii] = sort(drbr.time); drbr.press = drbr.press(ii);
drbr.cond = drbr.cond(ii); drbr.temp = drbr.temp(ii);
drbr.fluor = drbr.fluor(ii); drbr.back = drbr.back(ii);
%assume units are standard (dbar, mS/cm, ITS90)

%for each station, find rbr data, grid to 1 hz; also subsample sbe 24 hz
%data to 16/24 samples and grid the same way
opt1 = 'ctd_proc'; opt2 = '1hz_interp'; get_cropt
maxfill16 = round(maxfill24*2/3);
root_ctd = mgetdir('ctd');
klist = [1:180];
do24as16 = 1;
clear dgr dgs
for stn = klist
    psalfile = fullfile(root_ctd,sprintf('ctd_%s_%03d_psal.nc',mcruise,stn));
    if exist(psalfile,'file')
        [d1, h1] = mload(psalfile,'/');
        d1.time = m_commontime(d1,'time',h1,'datenum');
        [dd, hd] = mload(fullfile(root_ctd,sprintf('dcs_%s_%03d',mcruise,stn)),'/');
        dd.time_start = m_commontime(dd,'time_start',hd,'datenum');
        dd.time_end = m_commontime(dd,'time_end',hd,'datenum');
        te = d1.time(d1.time>=dd.time_start & d1.time<=dd.time_end)-0.5/86400; 
        te(length(te)+1) = te(end)+1/86400;
        
        iig = find(drbr.time>dd.time_start-1/86400 & drbr.time<dd.time_end+1/86400 & ~isnan(drbr.press));
        if length(iig)>5*60

            %bin average RBR to 1 hz
            clear d
            d.press = drbr.press(iig);
            d.temp = drbr.temp(iig);
            d.cond = drbr.cond(iig);
            d.fluor = drbr.fluor(iig);
            d.back = drbr.back(iig);
            d.time = drbr.time(iig);
            d.psal = NaN+d.cond; iig = find(~isnan(d.cond+d.temp));
            d.psal(iig) = gsw_SP_from_C(d.cond(iig),d.temp(iig),d.press(iig));
            dgr(stn) = grid_profile(d, 'time', te, 'meanbin', 'ignore_nan', 1, 'grid_ends', [1 1]);

            if do24as16 %subsample SBE 24 to 16 hz, then bin average to same 1 hz grid
                file24 = fullfile(root_ctd,sprintf('ctd_%s_%03d_24hz.nc',mcruise,stn));
                [d24, h24] = mload(file24, '/');
                iic = [1:3:length(d24.time) 2:3:length(d24.time)];
                vars = intersect(h24.fldnam,{'time','press','temp1','cond1','psal1','turbidity','fluor'});
                clear ds
                for vno = 1:length(vars)
                    ds.(vars{vno}) = d24.(vars{vno})(iic);
                end
                if isfield(ds,'turbidity')
                    ds.back = ds.turbidity; ds = rmfield(ds,'turbidity');
                else
                    ds.back = NaN+ds.time;
                end
                ds.psal = NaN+ds.cond1; iig = find(~isnan(ds.temp1+ds.cond1));
                ds.psal(iig) = gsw_SP_from_C(ds.cond1(iig),ds.temp1(iig),ds.press(iig));
                ds.temp = ds.temp1; ds.cond = ds.cond1; ds = rmfield(ds,{'temp1' 'cond1'});
                ds.time = m_commontime(ds, 'time', h24, 'datenum');
                dgs(stn) = grid_profile(ds, 'time', te, 'meanbin', 'ignore_nan', 1, 'grid_ends', [1 1]);

            else %just interpolate SBE (already bin averaged from 24 hz to 1 hz) to this 1 hz grid
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
