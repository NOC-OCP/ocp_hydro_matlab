% p = [
%     37    59   0.87   -48  14.77 
%     38    59  12.02   -47  49.19    ];


% xsize = 20.5; ysize = 14.4; ax = [-57 -50]; ay = [51 54];
% xsize = 20.5; ysize = 14.4; ax = [-57 -50]+2; ay = [51 54]-1;
% xsize = 14.5*7/5; ysize = 16.8; ax = [-50 -43]+6+1+4; ay = [57 60]+.2;
% % xsize = 20.5; ysize = 15.1; ax = [-57 -50]+6; ay = [51 54]+2;
% % xsize = 20.5; ysize = 16.4; ax = [-57 -50]+6; ay = [51 54]+5;
% % xsize = 20.5; ysize = 17.3; ax = [-57 -50]+8; ay = [51 54]+7;
% % xsize = 25.5; ysize = 17.9; ax = [-56 -33]; ay = [51.5 60.5]  ;
% % xsize = 25.5; ysize = 17.9; ax = [-56 -33]+23; ay = [51.5 60.5] + 3.5  ;
% % xsize = 25.5; ysize = 17.9; ax = [-56 -33]+23 + 5; ay = [51.5 60.5] + 3.5  ;
% xsize = 22; ysize = 14; ax = [-45 20]; merclat = -24; aydel = cos(merclat*3.142/180)*ysize*(ax(2)-ax(1))/xsize; ay = -24 + [0 aydel];
% % xsize = 22; ysize = 16; ax = [-57 -37]+15;merclat = 57; aydel = cos(merclat*3.142/180)*ysize*(ax(2)-ax(1))/xsize; ay = 56 + [0 aydel];
% % xsize = 22; ysize = 16; ax = [-57 -37]+20+15;merclat = 57; aydel = cos(merclat*3.142/180)*ysize*(ax(2)-ax(1))/xsize; ay = 56 + [0 aydel];

views = {'t0' 't1' 't2' 't3' 't4' 't5'};
views = {'t4'};
views = { 'jc159_bc' };%'24s'};
views = { 'jc159_24s' };%'24s'};
% views = { 'jc159_mar' };%'24s'};
% views = { 'jc159_walvis' };
views = { 'jc191_24n' };
views = { 'jc191_27nfs' };
% views = { 'jc191_24nwbdy' };
views = { 'jc191_24n' };
% views = { 'jc191_24nebdy' };
% views = { 'jc191_floats1' };
% views = { 'jc191_floats2' };

for kl = 1:length(views)
    view = views{kl};
    
    % view = 't0'; % whole cruise
    % % view = 't1'; % lab sea
    % view = 't2'; % greenland
    % view = 't3'; % osnap-e part 1
    % view = 't4'; % osnap-e part 2
    % view = 't5'; % eel
    % view = 'all';
    % view = 'planning';
    % view = 'eele';
    % view = 'rr2';
    % view = 'rr3';
    % view = 'ice2';
    statfilt = 'no';
    
    switch view
        case 't0'
            orient landscape
            xsize = 22; ysize = 14; ax = [-57 -2]; ay0 = 47; merclat = 57; aydel = cos(merclat*3.142/180)*ysize*(ax(2)-ax(1))/xsize; ay = ay0 + [0 aydel];
            klabs = [];
            statfilt = 'yes';
            title_str = {'James Clark Ross Cruise 302';'CTD stations'}; title(title_str);
        case 't1'
            orient tall
            xsize = 14; ysize = 20; ax = [-57 -40]; ay0 = 50; merclat = 57; aydel = cos(merclat*3.142/180)*ysize*(ax(2)-ax(1))/xsize; ay = ay0 + [0 aydel];
            klabs = [1:53];
            statfilt = 'yes';
            title_str = {'James Clark Ross Cruise 302';'CTD stations';'OSNAP-West'}; title(title_str);
        case 't2'
            orient landscape
            xsize = 22; ysize = 14; ax = [-52 -35]; ay0 = 56; merclat = 57; aydel = cos(merclat*3.142/180)*ysize*(ax(2)-ax(1))/xsize; ay = ay0 + [0 aydel];
            klabs = [33:109];
            statfilt = 'yes';
            title_str = {'James Clark Ross Cruise 302';'CTD stations';'Around Greenland'}; title(title_str);
        case 't3'
            orient landscape
            xsize = 22; ysize = 14; ax = [-45 -21]; ay0 = 56; merclat = 57; aydel = cos(merclat*3.142/180)*ysize*(ax(2)-ax(1))/xsize; ay = ay0 + [0 aydel];
            klabs = [77:82 85 90:94 110:112 115:5:145 ]; %1:500;
            statfilt = 'yes';
            title_str = {'James Clark Ross Cruise 302';'CTD stations';'OASNAP-East part 1'}; title(title_str);
        case 't4'
            orient landscape
            xsize = 22; ysize = 14; ax = [-28 -4]; ay0 = 56; merclat = 57; aydel = cos(merclat*3.142/180)*ysize*(ax(2)-ax(1))/xsize; ay = ay0 + [0 aydel];
            klabs = [ 140 145:5:160 161 199 200:5:250 214 215 216 234]; %1:500;
            statfilt = 'yes';
            title_str = {'James Clark Ross Cruise 302';'CTD stations';'OASNAP-East part 2'}; title(title_str);
        case 't5'
            orient landscape
            xsize = 22; ysize = 14; ax = [-28 -4]; ay0 = 56; merclat = 57; aydel = cos(merclat*3.142/180)*ysize*(ax(2)-ax(1))/xsize; ay = ay0 + [0 aydel];
            klabs = [ 161 162 165 170 175 178 179 180 184 185 186 187 188 190 192:198 199 200:5:250 214 215 216 234]; %1:500;
            statfilt = 'yes';
            title_str = {'James Clark Ross Cruise 302';'CTD stations';'EEL'}; title(title_str);
        case 'planning'
            orient landscape
            xsize = 22; ysize = 14; ax = [-37 -17]; ay0 = 54; merclat = 57; aydel = cos(merclat*3.142/180)*ysize*(ax(2)-ax(1))/xsize; ay = ay0 + [0 aydel];
            klabs = [];
        case 'eele'
            orient landscape
            xsize = 14.6*9/5; ysize = 5.3; ax = [-10 -1]; ay0 = 56; merclat = 57; aydel = cos(merclat*3.142/180)*ysize*(ax(2)-ax(1))/xsize; ay = ay0 + [0 1];
            klabs = [];
        case 'rr2'
            orient landscape
            xsize = 14.6*6/5; ysize = 16.9; ax = [-31 -25]; ay0 = 57; merclat = 57; aydel = cos(merclat*3.142/180)*ysize*(ax(2)-ax(1))/xsize; ay = ay0 + [0 3];
            klabs = [];
        case 'rr3'
            orient landscape
            xsize = 22; ysize = 14; ax = [-38 -20]; ay0 = 56; merclat = 57; aydel = cos(merclat*3.142/180)*ysize*(ax(2)-ax(1))/xsize; ay = ay0 + [0 aydel];
            klabs = [];
        case 'ice1'
            orient landscape
            xsize = 17.6; ysize = 14; ax = [-23 -17]; ay0 = 60; merclat = 61; aydel = cos(merclat*3.142/180)*ysize*(ax(2)-ax(1))/xsize; ay = ay0 + [0 aydel];
            klabs = [];
        case 'ice2'
            orient landscape
            xsize = 17.6; ysize = 14; ax = [-23 -17]; ay0 = 61; merclat = 62; aydel = cos(merclat*3.142/180)*ysize*(ax(2)-ax(1))/xsize; ay = ay0 + [0 aydel];
            klabs = [];
        case 'jc159_24s'
            orient landscape
            xsize = 22; ysize = 10; ax = [-45 20]; ay0 = -36; merclat = -24; aydel = cos(merclat*3.142/180)*ysize*(ax(2)-ax(1))/xsize; ay = ay0 + [0 aydel];
            klabs = [20:10:100  4 11 16 26 29 33 67 75  113  122 114]; %1:500;
            statfilt = 'yes';
            title_str = {'James Cook Cruise 159';'CTD stations';'24S Section'}; title(title_str);
        case 'jc159_mar'
            orient landscape
            xsize = 22; ysize = 10; ax = [-22 -5]; ay0 = -27; merclat = -24; aydel = cos(merclat*3.142/180)*ysize*(ax(2)-ax(1))/xsize; ay = ay0 + [0 aydel];
            klabs = [50:75]; %1:500;
            statfilt = 'yes';
            title_str = {'James Cook Cruise 159';'CTD stations';'24S Section through MAR'}; title(title_str);
        case 'jc159_bc'
            orient landscape
            xsize = 15; ysize = 12; ax = [-44 -36]; ay0 = -26; merclat = -24; aydel = cos(merclat*3.142/180)*ysize*(ax(2)-ax(1))/xsize; ay = ay0 + [0 aydel];
            klabs = [1:16]; %1:500;
            statfilt = 'yes';
            title_str = {'James Cook Cruise 159';'CTD stations';'Brazil Current Section'}; title(title_str);
        case 'jc159_walvis'
            orient landscape
            xsize = 10.1; ysize = 12.2; ax = [7 17]; ay0 = -29; merclat = -24; aydel = cos(merclat*3.142/180)*ysize*(ax(2)-ax(1))/xsize; ay = ay0 + [0 aydel];
            klabs = [110:125]; %1:500;
            statfilt = 'yes';
            title_str = {'James Cook Cruise 159';'CTD stations';'Walvis Bay Section'}; title(title_str);
        case 'jc191_24n'
            orient landscape
            xsize = 22; ysize = 10; ax = [-84 -11]; ay0 = 12; merclat = 24; aydel = cos(merclat*3.142/180)*ysize*(ax(2)-ax(1))/xsize; ay = ay0 + [0 aydel];
            klabs = [ 30 40 46 51 60 70 74 80 90 94 95 96 100 104 110 118 125 135]; %1:500;
            statfilt = 'yes';
            title_str = {'James Cook Cruise 191';'CTD stations red dots; Deep APEX floats yellow triangles';'24N Section'}; title(title_str);
        case 'jc191_27nfs'
            orient landscape
            xsize = 22; ysize = 12; ax = [-81 -75]; ay0 = 25.5; merclat = 27; aydel = cos(merclat*3.142/180)*ysize*(ax(2)-ax(1))/xsize; ay = ay0 + [0 aydel];
            klabs = [1 2 3  13 ]; %1:500;
            statfilt = 'yes';
            title_str = {'James Cook Cruise 191';'CTD stations';'27N Florida Strait'}; title(title_str);
        case 'jc191_24nwbdy'
            orient landscape
            xsize = 22; ysize = 12; ax = [-77.5 -74.9]; ay0 = 25.9; merclat = 26; aydel = cos(merclat*3.142/180)*ysize*(ax(2)-ax(1))/xsize; ay = ay0 + [0 aydel];
            klabs = [14 15 18 20 21 24 26 28 30 33 ]; %1:500;
            statfilt = 'yes';
            title_str = {'James Cook Cruise 191';'CTD stations';'26.5N Western Boundary'}; title(title_str);
        case 'jc191_24nebdy'
            orient landscape
            xsize = 22; ysize = 12; ax = [-25 -10]; ay0 = 23.5; merclat = 27; aydel = cos(merclat*3.142/180)*ysize*(ax(2)-ax(1))/xsize; ay = ay0 + [0 aydel];
            klabs = [120 125 131 134 135]; %1:500;
            statfilt = 'yes';
            title_str = {'James Cook Cruise 191';'CTD stations';'27N Eastern Boundary'}; title(title_str);
        case 'jc191_floats1'
            orient landscape
            xsize = 22; ysize = 12; ax = [-80 -40]; ay0 = 16; merclat = 27; aydel = cos(merclat*3.142/180)*ysize*(ax(2)-ax(1))/xsize; ay = ay0 + [0 aydel];
            klabs = [120 125 131 134]; %1:500;
            statfilt = 'yes';
            title_str = {'James Cook Cruise 191';'Deep APEX tracks';' Circles UK, Squares, US'}; title(title_str);
        case 'jc191_floats2'
            orient landscape
            xsize = 22; ysize = 12; ax = [-70 -52]; ay0 = 20; merclat = 27; aydel = cos(merclat*3.142/180)*ysize*(ax(2)-ax(1))/xsize; ay = ay0 + [0 aydel];
            klabs = [120 125 131 134]; %1:500;
            statfilt = 'yes';
            title_str = {'James Cook Cruise 191';'Deep APEX tracks';' Circles UK, Squares, US'}; title(title_str);
        otherwise
            orient landscape
            xsize = 22; ysize = 17; ax = [-57 -2]; ay0 = 46; merclat = 57; aydel = cos(merclat*3.142/180)*ysize*(ax(2)-ax(1))/xsize; ay = ay0 + [0 aydel];
            klabs = [];
    end
    switch statfilt
        case 'yes'
            if(exist('hlines','var') & exist('hts','var'))
                for kstat = 1:length(hlines) % make unwanted station labels invisible
                    if isempty(find(klabs == kstat))
                        set(hlines(kstat),'visible','off');
                        set(hts(kstat),'visible','off');
                    else
                        set(hlines(kstat),'visible','on');
                        set(hts(kstat),'visible','on');
                    end
                end
            end
        otherwise
    end
    
    set(gcf,'PaperType','a4');
    ha = gca;
    set(ha,'units','centimeters');
    axis normal
    porg = [2 2];
    psize = [xsize ysize];
    % psize = [10 10];
    posnew = [porg psize];
    set(ha,'position',posnew);
    
    xtint = 1+floor((ax(2)-ax(1))/10);
    ytint = 1+floor((ay(2)-ay(1))/10);
    
    % set(ha,'xlim',[ax(1) ax(2)],'ylim',[ay(1) ay(2)],'xtick',[ax(1):1:ax(2)],'ytick',[ay(1):1:ay(2)]);
    xticks = xtint*[-360:1:360]; xticks = xticks((xticks > ax(1)) & (xticks < ax(2)));
    yticks = ytint*[-360:1:360]; yticks = yticks((yticks > ay(1)) & (yticks < ay(2)));
    set(ha,'xlim',[ax(1) ax(2)],'ylim',[ay(1) ay(2)],'xtick',xticks,'ytick',yticks);
    
    fnotroot = [MEXEC_G.MEXEC_DATA_ROOT '/users/cruise_track/'];
    if exist(fnotroot,'dir') ~= 7; cmd = ['mkdir -p ' fnotroot]; system(cmd); end
    
    cmd = ['print -dpsc ' fnotroot 'jc191_stations_' view '.ps']; eval(cmd)
    cmd = ['print -dpng ' fnotroot 'jc191_stations_' view '.png']; eval(cmd)
    
end

