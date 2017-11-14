mcd vmp_chase

tstart = now-0.5/1440;

[lats lons] = mtposinfo(tstart);

figure(201)
clf

yscl = 1000*sw_dist([lats lats+1],[lons lons],'km'); % metres for 1 degree lat
xscl = 1000*sw_dist([lats lats],[lons lons+1],'km'); % metres for 1 degree lon

x = 0;
y = 0;
plot(x,y,'.','color','w')

axis([-5000 5000 -5000 5000]);
axis equal
hold on; grid on


%define ship
shiplen = 100;
shipwid = 20;
p1 = [0 shiplen/2];
p2 = [shipwid/2 .7*shiplen/2];
p3 = [shipwid/2 -shiplen/2];
p4 = [-shipwid/2 -shiplen/2];
p5 = [-shipwid/2 .7*shiplen/2];
p6 = p1;

ship = [p1(:) p2(:) p3(:) p4(:) p5(:) p6(:)];

degrad = pi/180;

% define circle

crad = nan+ones(2,361);


shiph = [];
circh = [];
xall = []; yall = []; tall = []; rall = []; hall = [];

while 1
    fprintf(1,'%s\n','clear saved ranges (1) or reload from replay file (2) ?')
    choose = input('input 1 or 2      ');
    if choose == 1
        %         arrays are already empty
        break
    end
    if choose == 2
        load replay
        break
    end
    fprintf(1,'%s\n','must answer 1 or 2   ')
end


while 1
    choose = input('0 to square azes; 1 for new range/time; 2 to replay; -1 to quit: ');
    if choose == 0
        axis equal
        continue
    end
    if choose == -1
        break;
    end

    if choose == 2
        highlight = input('how many recent profiles to highlight ? : ');
        load replay
        if ~isempty(shiph); set(shiph,'linewidth',1,'color','k'); end
        if ~isempty(circh); set(circh,'linewidth',1,'color','k'); end

%         if exist('shiph','var') == 1; set(shiph,'linewidth',1,'color','k'); end
%         if exist('circh','var') == 1; set(circh,'linewidth',1,'color','k'); end

        [tsort ki] = sort(tall);
        hsort = hall(ki);
        xsort = xall(ki);
        ysort = yall(ki);
        rsort = rall(ki);
        figure(201)
        for ksort = 1:length(xsort)
            if ksort == length(xsort)
                sline = 'r-'; swid = 2;
                cline = 'r-'; bwid = 2;
            elseif ksort > length(xsort)-highlight
                sline = 'b-'; swid = 2;
                cline = 'b-'; bwid = 2;
            else
                sline = 'k-'; swid = 1;
                cline = 'k-'; cwid = 1;
            end
            hrad = hsort(ksort)*degrad;
            rot = [cos(hrad) sin(hrad); -sin(hrad) cos(hrad)];
            shipxy = rot*ship;
            shiph = plot(xsort(ksort)+shipxy(1,:),ysort(ksort)+shipxy(2,:),sline,'linewidth',swid);
            crad = nan+ones(2,361);
            czero = [0;rsort(ksort)];
            for kc = 0:1:360
                arad = kc*degrad;
                rot = [cos(arad) sin(arad); -sin(arad) cos(arad)];
                crad(:,kc+1) = rot*czero;
            end
            circh = plot(xsort(ksort)+crad(1,:),ysort(ksort)+crad(2,:),cline,'linewidth',cwid);
        end
        plot(xsort,ysort,'k+-')
        for ksort = 1:length(xsort)
            timestr = datestr(tsort(ksort),'HH:MM:SS');
            texth = text(xsort(ksort),ysort(ksort),['     ' timestr]);
        end
        continue
    end

    if choose == 1
        while 1
            rstr = input('input range in metres : ','s');
            r = str2num(rstr);
            if length(r) > 1
                fprintf(2,'%s\n','Input one number only')
            else
                break
            end
        end
            

        timestr = input('Time in format daynum hh mm ss; (single zero for ''now'') : ','s');
        time = str2num(timestr);
        if length(time) == 1;
            %now
            dn = now-10/86400; % shift 10 seconds to ensure mtposinfo will work

            headdata = mtlast('gyro_s');
            head = headdata.heading;
        else
            daynum = time(1);
            hh = time(2);
            mm = time(3);
            ss = time(4);
            
            today = datevec(now);
            yyyy = today(1);
            dn = datenum([yyyy 1 1 0 0 0]) + (daynum-1) +hh/24 + mm/1440 + ss/86400;

            headdata = mtload('gyro_s',dn-1/1440,dn+1/1440);
            tin = headdata.time+MEXEC_G.Mtechsas_torg;
            hin = headdata.heading;
            [uni iunique]=unique(tin);
            head = interp1(tin(iunique),hin(iunique),dn);
        end
        [lat lon] = mtposinfo(dn);
        x = xscl*(lon-lons);
        y = yscl*(lat-lats);
    end

    tall = [tall dn];
    xall = [xall x];
    yall = [yall y];
    rall = [rall r];
    hall = [hall head];

    save replay xall yall rall hall tall lons lats xscl yscl

    %ship now
    hrad = head*degrad;
    rot = [cos(hrad) sin(hrad); -sin(hrad) cos(hrad)];
    shipxy = rot*ship;

    czero = [0;r];
    for kc = 0:1:360
        arad = kc*degrad;
        rot = [cos(arad) sin(arad); -sin(arad) cos(arad)];
        crad(:,kc+1) = rot*czero;
    end


    figure(201)
    if ~isempty(shiph)
        set(shiph,'linewidth',1,'color','k')
    end
    shiph =  plot(x+shipxy(1,:),y+shipxy(2,:),'r-','linewidth',2);

    if ~isempty(circh)
        set(circh,'linewidth',1,'color','k')
    end
    circh =  plot(x+crad(1,:),y+crad(2,:),'r-','linewidth',2);
    plot(x,y,'k+')
    timestr = datestr(dn,'HH:MM:SS');
    texth = text(x,y,['     ' timestr]);


end