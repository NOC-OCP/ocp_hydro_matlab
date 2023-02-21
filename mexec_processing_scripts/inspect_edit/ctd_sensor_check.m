load ~/cruise/data/ctd/sensor_groups
[ds,hs] = mload('~/cruise/data/ctd/sam_sd025_all','/');
ds.uoxygen2(isnan(ds.utemp2)) = NaN;

fn = fieldnames(sng);
iso = strncmp('oxygen',fn,6);
ist = strncmp('temp',fn,4);
isc = strncmp('cond',fn,4);
osens = fn(iso);
tsens = fn(ist);
csens = fn(isc);

botoxy = ds.botoxy ; botoxy(ds.botoxy_flag>2) = NaN ;
sbe35temp = ds.sbe35temp ; sbe35temp(ds.sbe35temp_flag>2) = NaN ;

% oxygen
for no = 1:length(osens)
    disp(['Oxygen sensor: ' osens(no)])
    ii1 = find(ismember(ds.statnum,sng.(osens{no})(sng.(osens{no})(:,2)==1,1)));
    ii2 = find(ismember(ds.statnum,sng.(osens{no})(sng.(osens{no})(:,2)==2,1)));
    figure(no); clf
    subplot(2,3,1)
    plot(botoxy(ii1),ds.uoxygen1(ii1),'bo',botoxy(ii2),ds.uoxygen2(ii2),'rs',ds.botoxy,ds.botoxy,'k'); grid
    xlabel('bottle oxy'); ylabel('ctd oxy'); title(['oxygen sensor _ serial number: ' osens{no}])
    subplot(2,3,2)
    plot(ds.statnum(ii1),ds.uoxygen1(ii1)./botoxy(ii1),'bo',ds.statnum(ii2),ds.uoxygen2(ii2)./botoxy(ii2),'rs'); grid
    xlabel('station number'); ylabel('ctd/bottle oxy')
    subplot(2,3,3)
    plot(ds.uoxygen1(ii1)./botoxy(ii1),-ds.upress(ii1),'bo',ds.uoxygen2(ii2)./botoxy(ii2),-ds.upress(ii2),'rs'); grid
    xlabel('ctd/bottle oxy'); ylabel('-pressure (dbar)')
    subplot(2,3,4)
    plot(ds.utemp1(ii1),ds.uoxygen1(ii1)./botoxy(ii1),'bo',ds.utemp2(ii2),ds.uoxygen2(ii2)./botoxy(ii2),'rs'); grid
    xlabel('ctd temperature'); ylabel('ctd/bottle oxy')
    subplot(2,3,5)
    scatter(ds.statnum(ii1),-ds.upress(ii1),20,ds.uoxygen1(ii1)./botoxy(ii1),'filled'); colorbar; title('position 1')
    subplot(2,3,6)
    scatter(ds.statnum(ii2),-ds.upress(ii2),20,ds.uoxygen2(ii2)./botoxy(ii2),'filled'); colorbar; title('position 2')
    
    disp('this oxygen sensor was in position 1 on these stations, with these S/Ns for temp1, cond1')
    [sg.temp1(ismember(sg.temp1,ds.statnum(ii1)),:) sg.cond1(ismember(sg.cond1,ds.statnum(ii1)),2)]
    disp('this oxygen sensor was in position 2 on these stations, with these S/Ns for temp2, cond2')
    [sg.temp2(ismember(sg.temp2,ds.statnum(ii2)),:) sg.cond2(ismember(sg.cond2,ds.statnum(ii2)),2)]
    pause
end


% temperature
for no = 1:length(tsens)
    disp(['Temperature sensor: ' tsens(no)])
    ii1 = find(ismember(ds.statnum,sng.(tsens{no})(sng.(tsens{no})(:,2)==1,1)));
    ii2 = find(ismember(ds.statnum,sng.(tsens{no})(sng.(tsens{no})(:,2)==2,1)));
    figure(no); clf
    subplot(2,3,1)
    plot(sbe35temp(ii1),ds.utemp1(ii1),'bo',sbe35temp(ii2),ds.utemp2(ii2),'rs',ds.sbe35temp,ds.sbe35temp,'k'); grid
    xlabel('sbe35temp'); ylabel('ctd temp'); title(['temperature sensor _ serial number: ' tsens{no}])
    subplot(2,3,2)
    plot(ds.statnum(ii1),ds.utemp1(ii1)-sbe35temp(ii1),'bo',ds.statnum(ii2),ds.utemp2(ii2)-sbe35temp(ii2),'rs'); grid
    xlabel('station number'); ylabel('ctd-sbe35 temp')
    subplot(2,3,3)
    plot(ds.utemp1(ii1) - sbe35temp(ii1),-ds.upress(ii1),'bo',ds.utemp2(ii2)./sbe35temp(ii2),-ds.upress(ii2),'rs'); grid
    xlabel('ctd-sbe35 temp'); ylabel('-pressure (dbar)')
    subplot(2,3,4)
    plot(ds.ucond1(ii1),ds.utemp1(ii1)-sbe35temp(ii1),'bo',ds.ucond2(ii2),ds.utemp2(ii2)-sbe35temp(ii2),'rs'); grid
    xlabel('ctd conductivity'); ylabel('ctd-sbe35 temp')
    subplot(2,3,5)
    scatter(ds.statnum(ii1),-ds.upress(ii1),20,ds.utemp1(ii1)-sbe35temp(ii1),'filled'); colorbar; title('position 1')
    subplot(2,3,6)
    scatter(ds.statnum(ii2),-ds.upress(ii2),20,ds.utemp2(ii2)-sbe35temp(ii2),'filled'); colorbar; title('position 2')
    
    disp('this temperature sensor was in position 1 on these stations, with these S/Ns for cond1')
    [sg.cond1(ismember(sg.cond1,ds.statnum(ii1)),:)]
    disp('this temperature sensor was in position 2 on these stations, with these S/Ns for cond2')
    [sg.cond2(ismember(sg.cond2,ds.statnum(ii2)),:)]
    pause
end

    