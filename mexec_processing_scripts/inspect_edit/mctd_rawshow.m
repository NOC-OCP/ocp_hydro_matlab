% mctd_rawshow: display raw ctd data to check for spikes
%
% Use: mctd_rawshow        and then respond with station number, or for station 16
%      stn = 16; mctd_rawshow;

opt1 = 'castpars'; opt2 = 'minit'; get_cropt
if MEXEC_G.quiet<=1; fprintf(1,'plotting 24 hz and 1 hz CTD data for station %s to check for spikes\n',stn_string); end

% resolve root directories for various file types
root_ctd = mgetdir('M_CTD');
prefix1 = ['ctd_' mcruise '_'];
infile1 = fullfile(root_ctd, [prefix1 stn_string '_raw_cleaned']);
if ~exist(m_add_nc(infile1),'file')
    infile1 = fullfile(root_ctd, [prefix1 stn_string '_raw']);
    if ~exist(m_add_nc(infile1),'file')
        infile1 = fullfile(root_ctd, [prefix1 stn_string '_raw_noctm']);
    end
end
infile2 = fullfile(root_ctd, ['dcs_' mcruise '_' stn_string]);
infile3 = fullfile(root_ctd, [prefix1 stn_string '_psal']);

hraw = m_read_header(infile1);
[ddcs, hdcs]  = mloadq(infile2,'/');
dcs_ts = ddcs.time_start(1);
dcs_te = ddcs.time_end(1);
dn_start = datenum(hdcs.data_time_origin)+dcs_ts/86400;
dn_end = datenum(hdcs.data_time_origin)+dcs_te/86400;
startdc = datevec(dn_start);
stopdc = datevec(dn_end);
opt1 = 'castpars'; opt2 = 'oxy_align'; get_cropt
if oxy_end
    stopdco = stopdc; 
    stopdco = datevec(datenum(stopdc)-oxy_align/3600/24);
end

close all

opt1 = 'castpars'; opt2 = 'oxyvars'; get_cropt; nox = size(oxyvars,1);

% 1 hz file, so we can see if any small spikes survive into final data for
% key variables
clear pshow5
pshow5.ncfile.name = infile3;
pshow5.xlist = 'time';
pshow5.ylist = ['temp1 temp2 cond1 cond2 press'];
for no = 1:nox
    pshow5.ylist = [pshow5.ylist ' ' oxyvars{no,2}];
    if oxy_end
        pshow5.stopdcv.(oxyvars{no,2}) = stopdco;
    end
end
pshow5.startdc = startdc;
pshow5.stopdc = stopdc;
mplotxy(pshow5);

% raw data main variables
clear pshow1
pshow1.ncfile.name = infile1;
pshow1.xlist = 'time';
pshow1.ylist = 'temp1 temp2 cond1 cond2 press';
pshow1.startdc = startdc;
pshow1.stopdc = stopdc;
mplotxy(pshow1);

% raw data oxygen
clear pshow2
pshow2.ncfile.name = infile1;
pshow2.xlist = 'time';
if nox>1
    ylist = {'pressure_temp' 'press' 'oxygen_sbe1' 'oxygen_sbe2'};
    if oxy_end
        pshow2.stopdcv.oxygen_sbe1 = stopdco;
        pshow2.stopdcv.oxygen_sbe2 = stopdco;
    end
else
    ylist = {'pressure_temp' 'press' 'oxygen_sbe1' 'sbeoxyV1'};
    if oxy_end
        pshow2.stopdcv.oxygen_sbe1 = stopdco;
        pshow2.stopdcv.sbeoxyV1 = stopdco;
    end
end
[~, pshow2.ylist] = mvars_in_file(ylist, infile1);
pshow2.startdc = startdc;
pshow2.stopdc = stopdc;
pshow2.cols = 'kgrbmcy'; % so raw oxygen in this plot matches 1 hz trace in figure 1.
mplotxy(pshow2);

%raw data fluor trans
clear pshow3
pshow3.ncfile.name = infile1;
pshow3.xlist = 'time';
ylist = {'press' 'turbidity' 'fluor' 'transmittance' 'par'};
[~, pshow3.ylist] = mvars_in_file(ylist, infile1);
pshow3.startdc = startdc;
pshow3.stopdc = stopdc;
mplotxy(pshow3);

%raw data lat and lon, carried after jc069 for ladcp processing
%empty for dy040
pshow4.ncfile.name = infile1;
pshow4.xlist = 'time';
ylist = {'latitude' 'longitude'};
[ylist, pshow4.ylist] = mvars_in_file(ylist, infile1);
if ~isempty(ylist)
    pshow4.startdc = startdc;
    pshow4.stopdc = stopdc;
    mplotxy(pshow4);
end

m = {'To edit out spikes, run mctd_rawedit.';
    'If you need to remove a range of scans, set doscanedit in mctd_ rawedit case of opt_ cruise';
    'If you want to remove out-of-range values or large spikes before manual despiking, set dorangeedit ';
    'or dodespike in mctd_ rawedit case of opt_ cruise';
    'However, if there are large spikes in temperature you should instead set redoctm in the mctd_01 ';
    'case of opt_cruise, and restart the processing from the beginning'};
sprintf('%s\n',m{:})
