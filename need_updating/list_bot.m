% list_botden: list bottle density data with sf5cf3 tracer. or other
% combinations. 
% bak jc069 DIMES UK3
%
% Use: list_botden        and then respond with station number, or for station 16
%      stn = 16; list_botden;

scriptname = 'castpars'; oopt = 'minit'; get_cropt
mdocshow(mfilename, ['add documentation string for ' scriptname])

if exist('choice','var')
    m = ['Running script ' scriptname ' with choice ' sprintf('%s',choice)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    choice = input('type choice of parameters ','s');
end
choicelocal = choice;
clear choice % so that it doesn't persist

root_ctd = mgetdir('M_CTD');

prefix1 = ['sam_' mcruise '_'];
prefix2 = ['ctd_' mcruise '_'];

infile1 = [root_ctd '/' prefix1 stn_string ];
infile2 = [root_ctd '/' prefix2 stn_string '_2db'];

if exist(m_add_nc(infile1),'file') ~= 2
    return
end
if exist(m_add_nc(infile2),'file') ~= 2
    return
end

[dsam hsam] = mload(infile1,'/');
[dctd hctd] = mload(infile2,'/');

                dsam.lon = hctd.longitude + zeros(size(dsam.sampnum));
                dsam.lat = hctd.latitude + zeros(size(dsam.sampnum));
                dsam.bottom_dep = hctd.water_depth_metres + zeros(size(dsam.sampnum));
                dsam.udepth = sw_dpth(dsam.upress,dsam.lat);
                dsam.usig0 = sw_pden(dsam.upsal,dsam.utemp,dsam.upress,0);
oopt = 'samadj'; get_cropt

sig0 = sw_pden(dsam.upsal,dsam.utemp,dsam.upress,0)-1000;
sig1 = sw_pden(dsam.upsal,dsam.utemp,dsam.upress,1000)-1000;

varlist = { % column header; width for col header; sam variable name; format for data
%     1 'samp' '%5s' 'sampnum' '%5d'
%     2 'wire' '%4s' 'wireout' '%4.0f'
%     3 'press' '%6s' 'upress' '%6.1f'
%     4 'potemp' '%6s' 'upotemp' '%6.3f'
%     5 'psal' '%6s' 'upsal' '%6.3f'
%     6 'psal1' '%6s' 'upsal1' '%6.3f'
%     7 'psal2' '%6s' 'upsal2' '%6.3f'
%     8 'botpsal' '%7s' 'botpsal' '%7.3f'
%     9 'botoxy' '%6s' 'botoxy' '%6.1f'
%     10 'ctdoxy' '%6s' 'uoxygen' '%6.1f'
%     11 'utemp1' '%6s' 'utemp1' '%6.3f'
%     12 'utemp2' '%6s' 'utemp2' '%6.3f'
%     13 'sbe35' '%6s' 'sbe35temp' '%6.3f'
%     14 'sb35fl' '%6s' 'sbe35flag' '%6.3f'
1 'samp' '%7s' 'sampnum' '%7d'
2 'wire' '%7s' 'wireout' '%7.0f'
3 'press' '%7s' 'upress' '%7.1f'
4 'potemp' '%7s' 'upotemp' '%7.3f'
5 'psal' '%7s' 'upsal' '%7.3f'
6 'psal1' '%7s' 'upsal1' '%7.3f'
7 'psal2' '%7s' 'upsal2' '%7.3f'
8 'botpsal' '%7s' 'botpsal' '%7.3f'
% 9 'botoxy' '%7s' 'botoxy' '%7.1f'
9 'botoxy' '%7s' 'botoxy_per_l' '%7.1f' % bak jc159
10 'ctdoxy' '%7s' 'uoxygen' '%7.1f'
11 'utemp1' '%7s' 'utemp1' '%7.3f'
12 'utemp2' '%7s' 'utemp2' '%7.3f'
13 'sbe35' '%7s' 'sbe35temp' '%7.3f'
14 'sb35fl' '%7s' 'sbe35flag' '%7.3f'
15 'Cruise'  '%10s'  'cruise' '%10d' % these vars are for the nuts team ODV csv
16 'Station'  '%10s' 'statnum' '%10d'
17 'Bottle'  '%10s' 'position' '%10d'
18 'Longitude [degrees_east]'  '%10s' 'lon' '%10.5f'
19 'Latitude [degrees_north]'  '%10s' 'lat' '%10.5f'
20 'bottom_depth'  '%10s' 'bottom_dep' '%10.1f'
21 'depth'  '%10s' 'udepth' '%10.1f'
22 'pressure'  '%10s' 'upress' '%10.1f'
23 'sal'  '%10s'   'upsal' '%10.3f'
24 'temp'  '%10s' 'utemp' '%10.3f'
25 'pdens'  '%10s' 'usig0' '%10.3f'
26 'ctd_oxy'  '%10s' 'uoxygen' '%10.2f'
% 27 'bot_oxy'  '%10s' 'botoxy' '%10.2f'
% 28 'QF'  '%10s' 'botoxyflag' '%10d'
27 'bot_oxy'  '%10s' 'botoxy_per_l' '%10.2f' % bak jc159
28 'QF'  '%10s' 'botoxyflaga' '%10d' % bak jc159
29 'Si(OH)4'  '%10s' 'silc' '%10.2f'
30 'QF'  '%10s' 'silc_flag' '%10d'
31 'PO4'  '%10s' 'phos' '%10.2f'
32 'QF'  '%10s' 'phos_flag' '%10d'
33 'TP'  '%10s' 'tp' '%10.2f'
34 'QF'  '%10s' 'tp_flag' '%10d'
35 'TN'  '%10s' 'tn' '%10.2f'
36 'QF'  '%10s' 'tn_flag' '%10d'
37 'NO3+NO2'  '%10s' 'totnit' '%10.2f'
38 'QF'  '%10s' 'totnit_flag' '%10d'
39 'NO2'  '%10s' 'no2' '%10.2f'
40 'QF'  '%10s' 'no2_flag' '%10d'
41 'NH4'  '%10s' 'nh4' '%10.2f'
42 'QF'  '%10s' 'nh4_flag' '%10d'
43 'DON'  '%10s' 'don' '%10.2f'
44 'QF'  '%10s' 'don_flag' '%10d'
45 'DOP'  '%10s' 'dop' '%10.2f'
46 'QF'  '%10s' 'dop_flag' '%10d'
47 'dic'  '%10s' 'dic' '%10.1f'
48 'dic_f'  '%10s' 'dic_flag' '%10d'
49 'alk'  '%10s' 'alk' '%10.1f'
50 'alk_f'  '%10s' 'alk_flag' '%10d'
51 'CH4' '%7s' 'ch4' '%7.2f'
52 'CH4_f' '%7s' 'ch4_flag' '%7d'
53 'CH4_sat' '%7s' 'ch4_sat' '%7.2f'
54 'N2O' '%7s' 'n2o' '%7.2f'
55 'N2O_f' '%7s' 'n2o_flag' '%7d'
56 'N2O_sat' '%7s' 'n2o_sat' '%7.2f'
57 'analtmp' '%7s' 'ch4_temp' '%7.2f'
58 'gamma_n'  '%10s' 'ugamma_n' '%10.3f'

};

fout = 'txt'; % output is plain fixed width 'txt' or 'csv'
switch choicelocal
    case 'physics'
        kuse = [1 2 3 4 5];
    case 'physoxy'
        kuse = [1 2 3 4 5 10];
    case 'allpsal'
        kuse = [1 2 3 4 5 6 7 8];
    case 'sbe35'
        kuse = [1 2 3 4 11 12 13 14];
    case 'nuts'
        kuse = [1 2 3 4 5 9 10];
        fout = 'csv';
    case 'nutsodv'
        kuse = [15:46];
        kuse = [15:28];
        fout = 'csv';
    case 'ch4'
        kuse = [1 2 3 4 5 9 10 49:55];
        fout = 'csv';
    case 'co2'
        kuse = [1 2 3 4 5 9 10 37 38 31 32 29 30 47 48 49 50 19 18];
        fout = 'csv';
    case 'cfc'
        kuse = [1 2 3 4 5 10 58];
        fout  = 'csv';
    otherwise
        kuse = [1 2 3 4 5];
end

prefix3 = ['samlist_'  mcruise '_' ];

otfile_list = [MEXEC_G.MEXEC_DATA_ROOT '/collected_files/samlists/' prefix3 stn_string '_' choicelocal '.' fout];
fidout = fopen(otfile_list,'w');



headmess = [];
headunits = [];
for kl = 1:length(kuse)
    samvarnum = strmatch(varlist{kuse(kl),4},hsam.fldnam,'exact')';
    samvarunits = hsam.fldunt{samvarnum};
    switch fout
        case 'txt'
            headmess = [headmess sprintf([varlist{kuse(kl),3} '  '],varlist{kuse(kl),2})];
            headunits = [headunits sprintf([varlist{kuse(kl),3} '  '],samvarunits(1:min(7,length(samvarunits))))];
        case 'csv'
            headmess = [headmess sprintf([varlist{kuse(kl),3} ','],varlist{kuse(kl),2})];
            headunits = [headunits sprintf([varlist{kuse(kl),3} ','],samvarunits(1:min(7,length(samvarunits))))];
    end
end
fprintf(1,'\n%s',headmess);
fprintf(fidout,'\n%s',headmess);
fprintf(1,'\n%s\n\n',headunits);
fprintf(fidout,'\n%s\n\n',headunits);

    
    

for kloop = 1:length(dsam.upsal)
    datamess = [];
    for kl = 1:length(kuse)
        if(strcmp(mcruise,'jr302') & strcmp('Cruise',varlist{kuse(kl),2}))
            switch fout
                case 'txt'
                    cmd = ['datamess = [datamess sprintf(''' varlist{kuse(kl),3} '  '',''JR302'')];']; eval(cmd); continue
                case 'csv'
                    cmd = ['datamess = [datamess sprintf(''' varlist{kuse(kl),3} ','',''JR302'')];']; eval(cmd); continue
            end
        end
        
        switch fout
            case 'txt'
                cmd = ['datamess = [datamess sprintf([varlist{kuse(kl),5} ''  ''],dsam.' varlist{kuse(kl),4} '(kloop))];']; eval(cmd)
            case 'csv'
                cmd = ['datamess = [datamess sprintf([varlist{kuse(kl),5} '',''],dsam.' varlist{kuse(kl),4} '(kloop))];']; eval(cmd)
        end
    end
    
    fprintf(1,'%s\n',datamess);
    fprintf(fidout,'%s\n',datamess);
    
end

oopt = 'printmsg'; get_cropt

fclose(fidout);
