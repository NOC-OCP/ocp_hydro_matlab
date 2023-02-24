function ctd_sensor_check(varargin)
% ctd_sensor_check(sensors_to_check)

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

if nargin>0
    if iscell(varargin{1})
        sensors_to_check = varargin{1};
    else
        sensors_to_check = varargin(1);
    end
else
    sensors_to_check = {'temp' 'cond' 'oxygen'};
end
m = strcmp('oxygen_diff',sensors_to_check);
if sum(m)
    oxydiff = 1;
    sensors_to_check{m} = 'oxygen';
else
    oxydiff = 0;
end

opt1 = 'castpars'; opt2 = 'ctdsens_groups'; get_cropt
if exist(sgfile,'file')
    load(sgfile)
end
[ds, ~] = mload(fullfile(mgetdir('sam'),['sam_' mcruise '_all']),'/');
ds.uoxygen1(isnan(ds.utemp1)) = NaN;
ds.uoxygen2(isnan(ds.utemp2)) = NaN;

fn = fieldnames(sng);
iso = strncmp('oxygen',fn,6);
ist = strncmp('temp',fn,4);
isc = strncmp('cond',fn,4);
osens = fn(iso);
tsens = fn(ist);
csens = fn(isc);

% oxygen
if ismember('oxygen',sensors_to_check)
for no = 1:length(osens)
    disp(['Oxygen sensor: ' osens(no)])
    ii1 = find(ismember(ds.statnum,sng.(osens{no})(sng.(osens{no})(:,2)==1,1)));
    ii2 = find(ismember(ds.statnum,sng.(osens{no})(sng.(osens{no})(:,2)==2,1)));
    ii1g = intersect(ii1,find(ds.botoxy_flag==2));
    ii1q = intersect(ii1,find(ds.botoxy_flag==3));
    ii2g = intersect(ii2,find(ds.botoxy_flag==2));
    ii2q = intersect(ii2,find(ds.botoxy_flag==3));
    figure(no); clf
    if oxydiff
        plot_panels(ds.statnum,ds.upress,ds.botoxy,ds.uoxygen1,ds.uoxygen2,'oxygen_diff',osens{no},ii1g,ii2g,ii1q,ii2q)
    else
        plot_panels(ds.statnum,ds.upress,ds.botoxy,ds.uoxygen1,ds.uoxygen2,'oxygen',osens{no},ii1g,ii2g,ii1q,ii2q)
    end
    figure(no); clf; clear hl
    if oxydiff
        subplot(2,3,1)
    plot(ds.botoxy(ii1q),ds.uoxygen1(ii1q),'.b',ds.botoxy(ii2q),ds.uoxygen(ii2q),'.r',ds.botoxy(ii1g),ds.uoxygen1(ii1g),'ob',ds.botoxy(ii2g),ds.uoxygen2(ii2g),'rs'); grid
    xlabel('bottle oxy'); ylabel('ctd oxy'); title(['oxygen sensor _ serial number: ' osens{no}])
    subplot(2,3,2)
    plot(ds.statnum(ii1q),ds.uoxygen1(ii1q)-ds.botoxy(ii1q),'.b',ds.statnum(ii2q),ds.uoxygen2(ii2q)-ds.botoxy(ii2q),'.r',ds.statnum(ii1g),ds.botoxy(ii1g)./ds.uoxygen1(ii1g),'ob',ds.statnum(ii2g),ds.botoxy(ii2g)./ds.uoxygen2(ii2g),'sr'); grid
    xlabel('station number'); ylabel('ctd/bottle oxy')
    subplot(2,3,3)
    plot(ds.botoxy(ii1q)./ds.uoxygen1(ii1q),-ds.upress(ii1q),'.b',ds.botoxy(ii2q)./ds.uoxygen(ii2q),-ds.upress(ii2q),'.r',ds.botoxy(ii1g)./ds.uoxygen1(ii1g),-ds.upress(ii1g),'ob',ds.botoxy(ii2g)./ds.uoxygen2(ii2g),-ds.upress(ii2g),'sr'); grid
    xlabel('ctd/bottle oxy'); ylabel('-pressure (dbar)')
    subplot(2,3,4)
    plot(ds.utemp1(ii1),ds.uoxygen1(ii1)./ds.botoxy(ii1),'bo',ds.utemp2(ii2),ds.uoxygen2(ii2)./ds.botoxy(ii2),'rs'); grid
    xlabel('ctd temperature'); ylabel('ctd/bottle oxy')
    subplot(2,3,5)
    scatter(ds.statnum(ii1),-ds.upress(ii1),20,ds.uoxygen1(ii1)./ds.botoxy(ii1),'filled'); colorbar; title('position 1')
    subplot(2,3,6)
    scatter(ds.statnum(ii2),-ds.upress(ii2),20,ds.uoxygen2(ii2)./ds.botoxy(ii2),'filled'); colorbar; title('position 2')
    else
                subplot(2,3,1)
    plot(ds.botoxy(ii1q),ds.uoxygen1(ii1q),'.b',ds.botoxy(ii2q),ds.uoxygen(ii2q),'.r',ds.botoxy(ii1g),ds.uoxygen1(ii1g),'ob',ds.botoxy(ii2g),ds.uoxygen2(ii2g),'rs'); grid
    xlabel('bottle oxy'); ylabel('ctd oxy'); title(['oxygen sensor _ serial number: ' osens{no}])
    subplot(2,3,2)
    plot(ds.statnum(ii1q),ds.botoxy(ii1q)./ds.uoxygen1(ii1q),'.b',ds.statnum(ii2q),ds.botoxy(ii2q)./ds.uoxygen(ii2q),'.r',ds.statnum(ii1g),ds.botoxy(ii1g)./ds.uoxygen1(ii1g),'ob',ds.statnum(ii2g),ds.botoxy(ii2g)./ds.uoxygen2(ii2g),'sr'); grid
    xlabel('station number'); ylabel('ctd/bottle oxy')
    subplot(2,3,3)
    plot(ds.botoxy(ii1q)./ds.uoxygen1(ii1q),-ds.upress(ii1q),'.b',ds.botoxy(ii2q)./ds.uoxygen(ii2q),-ds.upress(ii2q),'.r',ds.botoxy(ii1g)./ds.uoxygen1(ii1g),-ds.upress(ii1g),'ob',ds.botoxy(ii2g)./ds.uoxygen2(ii2g),-ds.upress(ii2g),'sr'); grid
    xlabel('ctd/bottle oxy'); ylabel('-pressure (dbar)')
    subplot(2,3,4)
    plot(ds.utemp1(ii1),ds.uoxygen1(ii1)./ds.botoxy(ii1),'bo',ds.utemp2(ii2),ds.uoxygen2(ii2)./ds.botoxy(ii2),'rs'); grid
    xlabel('ctd temperature'); ylabel('ctd/bottle oxy')
    subplot(2,3,5)
    scatter(ds.statnum(ii1),-ds.upress(ii1),20,ds.uoxygen1(ii1)./ds.botoxy(ii1),'filled'); colorbar; title('position 1')
    subplot(2,3,6)
    scatter(ds.statnum(ii2),-ds.upress(ii2),20,ds.uoxygen2(ii2)./ds.botoxy(ii2),'filled'); colorbar; title('position 2')
    end
    disp('this oxygen sensor was in position 1 on these stations, with these S/Ns for temp1, cond1')
    [sg.temp1(ismember(sg.temp1(:,1),ds.statnum(ii1)),:) sg.cond1(ismember(sg.cond1(:,1),ds.statnum(ii1)),2)]
    disp('this oxygen sensor was in position 2 on these stations, with these S/Ns for temp2, cond2')
    [sg.temp2(ismember(sg.temp2(:,1),ds.statnum(ii2)),:) sg.cond2(ismember(sg.cond2(:,1),ds.statnum(ii2)),2)]
    pick_line()
end
end

% temperature
if ismember('temp',sensors_to_check)
    for no = 1:length(tsens)
    disp(['Temperature sensor: ' tsens(no)])
    ii1 = find(ismember(ds.statnum,sng.(tsens{no})(sng.(tsens{no})(:,2)==1,1)));
    ii2 = find(ismember(ds.statnum,sng.(tsens{no})(sng.(tsens{no})(:,2)==2,1)));
    ii1 = intersect(ii1,find(ds.sbe35temp_flag==2));
    ii2 = intersect(ii2,find(ds.sbe35temp_flag==2));
    figure(no+10); clf
    subplot(2,3,1)
    plot(ds.sbe35temp(ii1),ds.utemp1(ii1),'bo',ds.sbe35temp(ii2),ds.utemp2(ii2),'rs',ds.sbe35temp,ds.sbe35temp,'k'); grid
    xlabel('sbe35temp'); ylabel('ctd temp'); title(['temperature sensor _ serial number: ' tsens{no}])
    subplot(2,3,2)
    plot(ds.statnum(ii1),ds.utemp1(ii1)-ds.sbe35temp(ii1),'bo',ds.statnum(ii2),ds.utemp2(ii2)-ds.sbe35temp(ii2),'rs'); grid
    xlabel('station number'); ylabel('ctd-sbe35 temp')
    subplot(2,3,3)
    plot(ds.utemp1(ii1) - ds.sbe35temp(ii1),-ds.upress(ii1),'bo',ds.utemp2(ii2)./ds.sbe35temp(ii2),-ds.upress(ii2),'rs'); grid
    xlabel('ctd-sbe35 temp'); ylabel('-pressure (dbar)')
    subplot(2,3,4)
    plot(ds.ucond1(ii1),ds.utemp1(ii1)-ds.sbe35temp(ii1),'bo',ds.ucond2(ii2),ds.utemp2(ii2)-ds.sbe35temp(ii2),'rs'); grid
    xlabel('ctd conductivity'); ylabel('ctd-sbe35 temp')
    subplot(2,3,5)
    scatter(ds.statnum(ii1),-ds.upress(ii1),20,ds.utemp1(ii1)-ds.sbe35temp(ii1),'filled'); colorbar; title('position 1')
    subplot(2,3,6)
    scatter(ds.statnum(ii2),-ds.upress(ii2),20,ds.utemp2(ii2)-ds.sbe35temp(ii2),'filled'); colorbar; title('position 2')
    
    disp('this temperature sensor was in position 1 on these stations, with these S/Ns for cond1')
    [sg.cond1(ismember(sg.cond1(:,1),ds.statnum(ii1)),:)]
    disp('this temperature sensor was in position 2 on these stations, with these S/Ns for cond2')
    [sg.cond2(ismember(sg.cond2(:,1),ds.statnum(ii2)),:)]
        pick_line()
end
end

% conductivity
if ismember('cond',sensors_to_check)
    for no = 1:length(csens)
    disp(['Conductivity sensor: ' csens(no)])
    ii1 = find(ismember(ds.statnum,sng.(csens{no})(sng.(csens{no})(:,2)==1,1)));
    ii2 = find(ismember(ds.statnum,sng.(csens{no})(sng.(csens{no})(:,2)==2,1)));
    ii1g = intersect(ii1,find(ds.botpsal_flag==2));
    ii2g = intersect(ii2,find(ds.botpsal_flag==2));
    ii1q = intersect(ii1,find(ds.botpsal_flag==3));
    ii2q = intersect(ii2,find(ds.botpsal_flag==3));
    figure(no+20); clf
    subplot(2,3,1)
    plot(ds.botpsal(ii1q),ds.upsal1(ii1q),'.b',ds.botpsal(ii2q),ds.upsal(ii2q),'.r',ds.botpsal(ii1g),ds.upsal1(ii1g),'ob',ds.botpsal(ii2g),ds.upsal2(ii2g),'rs'); grid
    xlabel('bottle psal'); ylabel('ctd psal'); title(['cond sensor _ serial number: ' csens{no}])
    subplot(2,3,2)
    plot(ds.statnum(ii1q),ds.botpsal(ii1q)./ds.upsal1(ii1q),'.b',ds.statnum(ii2q),ds.botpsal(ii2q)./ds.upsal(ii2q),'.r',ds.statnum(ii1g),ds.botpsal(ii1g)./ds.upsal1(ii1g),'ob',ds.statnum(ii2g),ds.botpsal(ii2g)./ds.upsal2(ii2g),'rs'); grid
    xlabel('station number'); ylabel('ctd/bottle psal')
    subplot(2,3,3)
    plot(ds.botpsal(ii1q)./ds.upsal1(ii1q),-ds.upress(ii1q),'.b',ds.botpsal(ii2q)./ds.upsal(ii2q),-ds.upress(ii2q),'.r',ds.botpsal(ii1g)./ds.upsal1(ii1g),-ds.upress(ii1g),'ob',ds.botpsal(ii2g)./ds.upsal2(ii2g),-ds.upress(ii2g),'rs'); grid
    xlabel('ctd/bottle psal'); ylabel('-pressure (dbar)')
    subplot(2,3,4)
    plot(ds.utemp1(ii1),ds.upsal1(ii1)-ds.botpsal(ii1),'bo',ds.utemp2(ii2),ds.upsal2(ii2)-ds.botpsal(ii2),'rs'); grid
    xlabel('ctd temperature'); ylabel('ctd-bottle psal')
    subplot(2,3,5)
    scatter(ds.statnum(ii1),-ds.upress(ii1),20,ds.upsal1(ii1)-ds.botpsal(ii1),'filled'); colorbar; title('position 1')
    subplot(2,3,6)
    scatter(ds.statnum(ii2),-ds.upress(ii2),20,ds.upsal2(ii2)-ds.botpsal(ii2),'filled'); colorbar; title('position 2')
    
    disp('this conductivity sensor was in position 1 on these stations, with these S/Ns for temp1')
    [sg.temp1(ismember(sg.temp1(:,1),ds.statnum(ii1)),:)]
    disp('this conductivity sensor was in position 2 on these stations, with these S/Ns for temp2')
    [sg.temp2(ismember(sg.temp2(:,1),ds.statnum(ii2)),:)]
    pick_line
end
end

function pick_line()
done = 0;
while ~done
    cont = input('select points (y/n)?\n','s');
    if ~strcmp(cont,'y'); done = 1; continue; end
    disp('select two or more points on any axis to describe a [piecewise] line\n then enter');
    [x,y] = ginput;
    if length(x)<=1
        continue
    elseif length(x)==2
        b = regress(y,[x ones(2,1)]);
        disp(['fit is y = x*' num2str(b(1)) ' + ' num2str(b(2))])
    else
        disp('points are: ')
        [x y]
    end
    cont = input('(zoom then) enter to continue or ''a'' to select again\n');
    if isempty(cont)
        done = 1;
    end
end
