predir1 = '~/projects/satl_box/hsections/';
predir2 = '~/projects/Acruises/';
predir3 = '~/projects/sr1b/matfiles/';
predir = '~/projects/satl_box/hsections/';

%defaults
clear info
info.ctdout = 0; 
info.samout = 0;
info.expocode = '';

switch cruise
    
    %full hydro
    
    %no dic in two i06s sections??? check again with tco2 in varnamesunits
    %check for comments that totnit is actually just nitrate or vice versa?
    %future: best not to call it totnit when it's not actually totnit, call
    %it no2_no3 or whatever the cchdo name is now
    %one of the 30E sections has places where t and s are defined but
    %oxygen is not. flag problem? 
    case 'knox14'
        info.section = 'i06s';
        info.season = '2007_2008';
        info.expocode = '33RR20080204'; %354
        info.ctddir = [predir1 'i06s/knox14/' info.expocode '_ct1/'];
        info.ctdpat = '*_ct1.csv';
        %info.samdir = [predir1 'i06s/knox14/'];
        %info.sampat = [info.expocode '_hy1.csv'];
        info.samdir = [predir1 '/'];
        info.sampat = 'GLODAPv2.2020_Merged_Master_File.mat';
        info.statind = [1:4 6:76 77:92];% 106:-1:100 99:-1:93]; %4 and 5 are very close but 4 is shallower dog-leg matches 2019 cruise, check what gavin used though
        readme = {'sample data from adjusted GLODAP file'};
    case 'soccom25'
        info.section = 'i06s';
        info.season = '2018_2019';
        info.expocode = '325020190403';
        %info.ctddir = [predir1 'i06s/soccom25/' info.expocode '_ct1/'];
        %info.ctdpat = '*_ct1.csv';
        info.ctddir = [predir1 'i06s/soccom25/' info.expocode '_nc_ctd/'];
        info.ctdpat = '*_ctd.nc';
        info.samdir = [predir1 'i06s/soccom25/'];
        info.sampat = [info.expocode '_hy1.csv'];
        info.statind = [46:54 45:-1:1]; %N to S
        
    case 'jr239'
        info.section = 'andrex';
        info.expocode = '74JC20100319'; %703
        info.season = '2009_2010';
        info.ctddir = [predir1 'andrex/jr239/74JC20100319_ct1/'];
        info.ctdpat = '*_ct1.csv';
        %info.samdir = [predir1 'andrex/jr239/'];
        %%info.sampat = [info.expocode '_hy1.csv'];
        info.samdir = [predir1 '/'];
        info.sampat = 'GLODAPv2.2020_Merged_Master_File.mat';
        info.statind = [68:-1:2]; %E to W
        readme = {'sample data from adjusted GLODAP file'};
    case 'jc030'
        info.section = 'andrex';
        info.expocode = '740H20081226'; %674
        info.season = '2008_2009';
        info.ctddir = [predir1 'andrex/jc030/740H20081226_ct1/'];
        info.ctdpat = '*_ct1.csv';
        info.samdir = [predir1 '/'];
        info.sampat = 'GLODAPv2.2020_Merged_Master_File.mat';
        info.statind = [2:27]; %E to W
        readme = {'sample data from adjusted GLODAP file'};
    case 'jr18005'
        info.section = 'andrex';
        info.season = '2018_2019';
        info.expocode = '74JC20190221';
        info.ctddir = [predir1 'andrex/jr18005/2db/']; 
        info.ctdpat = '*_cal.2db.mat'; %salcal, need to apply ocal*** could have option to apply inline
        info.samdir = [predir1 'andrex/jr18005/'];
        info.sampat = 'ANDREX_II_*BODC.csv'; %***need to convert xlsx to csv for dic, ph, talk, but wait for vas to fix?
        info.sam_hcpat = {{'niskin'}};
        info.statind = fliplr([3:63 66 69:73 75:98]); %E to W
        %ctdout = 1; samout = 1;
        
    case 'jc032'
        info.section = 'a095';
        info.season = '2008_2009';
        info.expocode = '740H20090307'; %676
        info.ctddir = [predir1 'a095/jc032/a095_ct1/']; %gavin used jc032_fromship, should check these are the same
        info.ctdpat = 'a095_*.csv';
        %info.samdir = [predir1 '24s/jc032/'];
        %info.sampat = [info.expocode '_hy1.csv'];
        info.samdir = [predir1 '/'];
        info.sampat = 'GLODAPv2.2020_Merged_Master_File.mat';
        info.statind = [23:34 36:47 49:118]; %1:9 first BC section (farther south), 10:22 second (near 24S)
        %gavin loaded all files or at least 10-118, not sure if they were
        %used though
                readme = {'sample data from adjusted GLODAP file'};
    case 'jc159'
        info.section = 'a095';
        info.season = '2017_2018';
        info.expocode = '740H20180228';
        info.ctddir = [predir2 'jc159/mcruise/data/collected_files/A095_740H20180228_ct1/'];
        info.ctdpat = '*_ct1.csv';
        %info.samdir = [predir2 'jc159/mcruise/data/collected_files/'];
        %info.sampat = ['A095_' info.expocode '_hy.csv'];
        info.samdir = [predir1 '/'];
        info.sampat = 'GLODAPv2.2020_Merged_Master_File.mat';
        info.statind = [4:26 29:32 34:88 90:113 122:-1:114];
                readme = {'sample data from adjusted GLODAP file'};
        
    case 'jr18002'
        info.section = 'sr1b';
        info.season = '2018_2019';
        info.expocode = '74JC20181103';
        info.ctddir = [predir2 'jr18002/mcruise/data/collected_files/sr1b_74JC20181103_ct1/'];
        info.ctdpat = '*_ct1.csv';
        info.samdir = [predir2 'jr18002/mcruise/data/collected_files/'];
        info.sampat = [info.expocode '.exc_2021_nuts_update.csv'];
        info.statind = [23 25 26 27 31 32 36 40 44 22 21:-1:3];

    %multi-section cruises
    case 'jc031'
        info.expocode = '740H20090203'; %675
        info.season = '2008_2009';
        info.ctddir = [predir1 '/sr1b/jc031/' info.expocode '_ct1/']; %for ctd_sr1b_all, loading from wp13/jc31_arch/JC031/cruise/pstar/data/ctd
        info.ctdpat = [info.expocode '*_ct1.csv'];
        %info.samdir = [predir1 '/sr1b/jc031/'];
        %info.sampat = [info.expocode '_hy1.csv'];
        info.samdir = [predir1 '/'];
        info.sampat = 'GLODAPv2.2020_Merged_Master_File.mat';
        info.section = section;
        if strcmp(section, 'sr1b')
            info.statind = [50:79];
        elseif strcmp(section, 'sr1') %a21?
            info.statind = [2:12 14:34 36:49];
        end
                readme = {'sample data from adjusted GLODAP file'};
    case 'dy113'
        info.ctddir = [predir2 'dy113/mcruise/data/ctd/'];
        info.ctdpat = '*_2db.nc';
        info.section = section;
        if strcmp(section, 'sr1b')
            info.statind = [2:30];
        elseif strcmp(section, 'a23')
            info.statind = [31:62]; %***
        end
    case 'jc211'
        info.ctddir = [predir2 'jc211/mcruise/data/ctd/'];
        info.ctdpat = '*_2db.nc';
        info.section = section;
        if strcmp(section, 'sr1b')
            info.statind = [66:94]';
        elseif strcmp(section, 'a23')
            info.statind = [38:67]; %***
        end
        
    %sr1b only physics
    case 'jr0a'
        info.section = 'sr1b';
        info.ctddir = predir3;
        info.ctdpat = 'ctd_sr1b_all.mat';
        info.statind = [31:-1:2];
    case 'jr0b'
        info.section = 'sr1b';
        info.ctddir = predir3;
        info.ctdpat = 'ctd_sr1b_all.mat';
        info.statind = [33:-1:6];
    case 'jr16'
        info.section = 'sr1b';
        info.ctddir = predir3;
        info.ctdpat = 'ctd_sr1b_all.mat';
        info.statind = [30:-1:2];
    case 'jr27'
        info.section = 'sr1b';
        info.ctddir = predir3;
        info.ctdpat = 'ctd_sr1b_all.mat';
        info.statind = [5:54];
    case 'jr47'
        info.section = 'sr1b';
        info.ctddir = predir3;
        info.ctdpat = 'ctd_sr1b_all.mat';
        info.statind = [1:30];
    case {'jr55' 'jr67'}
        info.section = 'sr1b';
        info.ctddir = predir3;
        info.ctdpat = 'ctd_sr1b_all.mat';
        info.statind = [31:-1:2];
    case 'jr81'
        info.section = 'sr1b';
        info.ctddir = predir3;
        info.ctdpat = 'ctd_sr1b_all.mat';
        info.statind = [3:32];
    case 'jr94'
        info.section = 'sr1b';
        info.ctddir = predir3;
        info.ctdpat = 'ctd_sr1b_all.mat';
        info.statind = [3:32];
    case 'jr115'
        info.section = 'sr1b';
        info.ctddir = predir3;
        info.ctdpat = 'ctd_sr1b_all.mat';
        info.statind = [31:-1:2];
    case {'jr139' 'jr163' 'jr193' 'jr194' 'jr195' 'jr265'}
        info.section = 'sr1b';
        info.ctddir = predir3;
        info.ctdpat = 'ctd_sr1b_all.mat';
        info.statind = [30:-1:1];
    case 'jr281'
        info.section = 'sr1b';
        info.ctddir = predir3;
        info.ctdpat = 'ctd_sr1b_all.mat';
        info.statind = [32:-1:1];
    case 'jr299'
        info.section = 'sr1b';
        info.ctddir = predir3;
        info.ctdpat = 'ctd_sr1b_all.mat';
        info.statind = [1:28];
    case 'jr306'
        info.section = 'sr1b';
        info.ctddir = [predir2 'jr306/cruise/data/collected_files/sr1b_74JC20150110_ct1/'];
        info.ctdpat = '*_ct1.csv';
        info.statind = [1:30];
    case 'jr15003'
        info.section = 'sr1b';
        info.ctddir = [predir2 'jr15003/cruise/data/collected_files/sr1b_74JC20151217_ct1/'];
        info.ctdpat = '*_ct1.csv';
        info.statind = [1:28];
    case 'jr16002'
        info.section = 'sr1b';
        info.ctddir = [predir2 'jr16002/cruise/data/collected_files/sr1b_74JC20161110_ct1/'];
        info.ctdpat = '*_ct1.csv';
        info.statind = [30:-1:1];
    case 'jr17001'
        info.section = 'sr1b';
        info.ctddir = [predir2 'jr17001/mcruise/data/collected_files/sr1b_74JC20171121_ct1/'];
        info.ctdpat = '*_ct1.csv';
        info.statind = [1:21];
        
    %a23 only physics
    case {'jr010' 'jr040' 'a16s_2005' 'jr239' 'jr272a' 'jr281' 'a16s_2013' 'jr299' 'jr310' 'jr15006' 'jr16004' 'jr17003'}
        info.section = 'a23';
        info.ctddir = [predir1 'a23/'];
        info.ctdpat = 'a23_ctds_20191021.mat';
        
end
