%function msam_other(type)
% read in bottle sample data not covered by specific function (specific
% functions include msal_01, moxy_01, mnut_01, ***mco2_01, mcfc_01***)
%
% for each type of input, parse as specified in opt_cruise, handle
% replicates and flags, save to a concatenated sample file for this type,
% and save data from CTD Niskins to sam_cruise_all.nc 

%opt1 = 'botsam'; opt2 = type; get_cropt

rootchl = mgetdir('M_BOT_CHL');
infile = fullfile(rootchl,'DY180_Chlorophyll a data_master.xlsx');
opts.hcpat = {'Site'}; %icolhead, icolunits, numhead? 

%[tsd, headsam] = load_samdata(infile,opts);
[tsd, headsam] = load_samdata(infile,'hcpat',{'Site'});
ddlim = datenum([2024 5 21; 2024 6 27])-datenum(2024,1,1);
tsd.dday = datenum(tsd.date_day_month_year)-datenum(2024,1,1);
tsd = tsd(tsd.dday>=ddlim(1) & tsd.dday<=ddlim(2),:);

comment = ['chlorophyll loaded from ' infile ', units assumed'];

%ctd samples
tsd_ctd = tsd(strncmp('C0',tsd.cast_number,2),:);
tsd_ctd.sampnum = cellfun(@(x) str2double(x(2:4)), tsd_ctd.cast_number)*100 + tsd_ctd.niskin_bottle;
clear dc hc
dc.sampnum = tsd_ctd.sampnum;
dc.chl = tsd_ctd.chlorophyll_dil_x_r_adj_x_fl_bl_x_ace_per_sampl;
hc.fldnam = {'sampnum', 'chl'}; %what else to save?
hc.fldunt = {'number', 'ug_per_l'};
hc.comment = comment;
outc = fullfile(rootchl,['chl_' mcruise '_all.nc']);
mfsave(outc,dc,hc)
%add to sam file

%underway samples
tsd_uway = tsd(strncmp('UW',tsd.cast_number,2),:);
clear du hu
to = [MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1) 1 1 0 0 0];
du.time = datenum(tsd_uway.date_day_month_year)-datenum(to); %***HH MM?????
du.chl = tsd_uway.chlorophyll_dil_x_r_adj_x_fl_bl_x_ace_per_sampl;
hu.fldnam = {'time', 'chl'};
hu.fldunt = {['days since ' datestr(to,'yyyy-mm-dd HH:MM:SS')], 'ug_per_l'}; %***
hu.comment = comment;
outu = fullfile(rootchl,['ucswchl_' mcruise '_all.nc']);
mfsave(outu,du,hu)
