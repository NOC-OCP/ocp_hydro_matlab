%defaults
clear info
info.ctdout = 0;
info.samout = 0;
info.expocode = '';

switch cruise
    
    case 'antxxx_2'
        info.section = 'a12';
        info.season = '2014';
        info.expocode = '06AQ20141202'; %354
        info.ctddir = fullfile(predir, info.expocode);
        info.ctdpat = '*_ct1.csv';
        info.samdir = fullfile(predir, '06AQ20141202');
        info.sampat = [info.expocode '_hy1.csv'];
        %info.samdir = [predir1 '/'];
        %info.sampat = 'GLODAPv2.2020_Merged_Master_File.mat';
        info.statind = [1:36];% station 1-36 have data from prime merdian only
        %readme = {'sample data from adjusted GLODAP file'};
        info.event_extract_string = 'a = replace(replace(replace(data0.event,''PS117_'',''''),''-1'',''''),''-2'',''''); data0.statnum = str2num(sprintf(''%s\n'',a{:}));';
    case 'jr239'
        info.section = 'andrex';
        info.season = '2009_2010';
        info.expocode = '74JC20100319';
        info.ctddir = [predir1 info.expocode];
        info.ctdpat = '*_ct1.csv';
        %info.ctddir = [predir1 'i06s/soccom25/' info.expocode '_nc_ctd/'];
        %info.ctdpat = '*_ctd.nc';
        info.samdir = [predir1 '74JC20100319'];
        info.sampat = [info.expocode '_hy1.csv'];
        info.statind = [6:23 24:68]; %E to W station 1-3 are beteen islands and 6-23 are transit between islands
        
    case 'jc030'
        info.section = 'andrex';
        info.expocode = '740H20081226'; %703
        info.season = '2008_2009';
        info.ctddir = [predir1 info.expocode];
        info.ctdpat = '*_ct1.csv';
        info.samdir = [predir1 '740H20081226'];
        info.sampat = [info.expocode '_hy1.csv'];
        %info.samdir = [predir1 '/'];
        %info.sampat = 'GLODAPv2.2020_Merged_Master_File.mat';
        info.statind = [2:27]; %E to W
        %readme = {'sample data from adjusted GLODAP file'};
        
    case 'jr18005'
        info.section = 'andrex';
        info.season = '2018_2019';
        info.expocode = '74JC20190221';
        info.ctddir = [predir1 '74JC20190221/2db/'];
        info.ctdpat = '*_cal.2db.mat'; %salcal, need to apply ocal*** could have option to apply inline
        info.samdir = [predir1 '74JC20190221'];
        info.sampat = [info.expocode '_hy1.csv'];
        info.sam_hcpat = {{'niskin'}};
        info.statind = fliplr([3:63 66 69:73 75:98]); %E to W station 6-23 between islands 24-98 stations fliplr grids in oposite way to track
        %ctdout = 1; samout = 1;
        
    case 'antix_2'
        info.section = 'sr04';
        info.season = '2001_2002';
        info.expocode = '06AQANTIX_2';
        info.ctddir = [predir1 info.expocode '_ct1/'];
        info.ctdpat = '*_ct1.csv';
        info.samdir = [predir1 '06AQANTIX_2'];
        info.sampat = [info.expocode '_hy1.csv'];
        %info.samdir = [predir1 '/'];
        %info.sampat = 'GLODAPv2.2020_Merged_Master_File.mat';
        info.statind = [40:115]; %E to W
        
        
        
    case 'jr18002'
        info.section = 'sr1b';
        info.season = '2018_2019';
        info.expocode = '74JC20181103';
        info.ctddir = [predir1 info.expocode];
        info.ctdpat = '*_ct1.csv';
        info.samdir = [predir1 '74JC20181103'];
        info.sampat = [info.expocode '_hy1.csv'];
        
        info.statind = [23 25 26 27 31 32 36 40 44 22 21:-1:3];
        
        %multi-section cruises
        
        
    case 'antxiii_4'
        info.expocode = '06AQ19960317'; %675
        info.season = '1996';
        info.ctddir = [predir1 info.expocode];
        info.ctdpat = [info.expocode '*_ct1.csv'];
        info.samdir = [predir1 '06AQ19960317'];
        info.sampat = [info.expocode '_hy1.csv'];
        info.section = s04 ;
        if strcmp(section, 's04')
            info.statind = [67:103];% stations 103-67
        elseif strcmp(section, 'so4a') %prime meridian stations 33-66
            info.statind = [33:66];
        elseif strcmp(section, 'so4b') %0-40E stations 65-25
            info.statind = [65:25];
        end
        
    case 'antxv_4'
        info.ctddir = [predir1 info.expocode];
        info.ctdpat = [info.expocode '*_ct1.csv'];
        info.samdir = [predir1 '06AQ19980328'];
        info.sampat = [info.expocode '_hy1.csv'];
        info.section = section;
        if strcmp(section, 's04')
            info.statind = [3:30 74];% stations 3-30 plus station 74
        elseif strcmp(section, 's04_1')
            info.statind = [31:52]; %***station 52-31 still in the weddle sea but from s to n
        elseif strcmp(section, 's04b')
            info.statind = [79:136]; %*prime meridian station 79-136
        end
        
    case 'antxxii_3'
        info.ctddir = [predir1 info.expocode];
        info.ctdpat = [info.expocode '*_ct1.csv'];
        info.samdir = [predir1 '06AQ20050122'];
        info.sampat = [info.expocode '_hy1.csv'];
        info.section = section;
        if strcmp(section, 'sr1')
            info.statind = [176:155];% stations 176-155
        elseif strcmp(section, 's04')
            info.statind = [149:81]; %***station 81-141
        elseif strcmp(section, 's04b')
            info.statind = [25:65]; %*prime meridian station 25-65
        end
        
    case 'antxxvii_2'
        info.ctddir = [predir1 info.expocode];
        info.ctdpat = [info.expocode '*_ct1.csv'];
        info.samdir = [predir1 '06AQ20101128'];
        info.sampat = [info.expocode '_hy1.csv'];
        info.section = section;
        if strcmp(section, 's04')
            info.statind = [69:123];% stations 69-123
        elseif strcmp(section, 's04b')
            info.statind = [21:66]; %*prime meridian station 21-66
        end
        
    case 'ps117_1'
        info.ctddir = [predir1 info.expocode '_ct1/'];
        info.ctdpat = [info.expocode '*_ct1.csv'];
        info.ctd_hcpat = {'CTDPRS';'[dbar]'};
        info.samdir = [predir1 'PS117_2019'];
        info.sampat = [info.expocode '2019_hy1.csv'];
        info.section = section;
        if strcmp(section, 's04')
            info.statind = [33:94];% stations 33-94
        elseif strcmp(section, 's04b')
            info.statind = [1:30]; %*prime meridian station 21-66
        end
        
end
