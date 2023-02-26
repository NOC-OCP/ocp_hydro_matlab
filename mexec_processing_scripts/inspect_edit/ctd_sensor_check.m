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
okf = [2 3];
udstr = 'u';
p = [];

for pno = 1:length(sensors_to_check)
    parameter = sensors_to_check{pno};
    ispar = strncmp(parameter,fn,length(parameter));
    sens = fn(ispar);
    for sno = 1:length(sens)
        ii1 = find(ismember(ds.statnum,sng.(sens{sno})(sng.(sens{sno})(:,2)==1,1)));
        ii2 = find(ismember(ds.statnum,sng.(sens{sno})(sng.(sens{sno})(:,2)==2,1)));
        snstr = sens{sno}; snstr = snstr(findstr(snstr,'_')+1:end);
        if oxydiff && strcmp(parameter,'oxygen')
            [dc, p, mod] = sensor_cal_comparisons(ds, [parameter '_diff'], snstr, udstr, ii1, ii2, okf, p);
        else
            [dc, p, mod] = sensor_cal_comparisons(ds, parameter, snstr, udstr, ii1, ii2, okf, p);
        end
        ii1g = intersect(ii1,find(dc.calflag==2));
        ii1q = intersect(ii1,find(dc.calflag==3));
        ii2g = intersect(ii2,find(dc.calflag==2));
        ii2q = intersect(ii2,find(dc.calflag==3));
        figure(pno*10+sno); clf
        plot_panels(dc,p,ii1g,ii2g,ii1q,ii2q)
        disp([sens{sno} ' in position 1 on these stations with bottles, with these S/Ns for temp1, cond1'])
        [sg.temp1(ismember(sg.temp1(:,1),ds.statnum(ii1)),:) sg.cond1(ismember(sg.cond1(:,1),ds.statnum(ii1)),2)]
        disp([sens{sno} ' in position 2 on these stations with bottles, with these S/Ns for temp2, cond2'])
        [sg.temp2(ismember(sg.temp2(:,1),ds.statnum(ii2)),:) sg.cond2(ismember(sg.cond2(:,1),ds.statnum(ii2)),2)]
        cont = pick_line();
        if ~strcmp(cont,'n')
            a = sng.(sens{sno});
            disp([sens{sno} ' in position 1 on stations: '])
            disp(a(a(:,2)==1,1)')
            disp([sens{sno} ' in position 2 on stations: '])
            disp(a(a(:,2)==2,1)')
        end
    end
end


function plot_panels(ds,p,ii1g,ii2g,ii1q,ii2q)

tvar = 'statnum';
tvar = 'time';
if strcmp(tvar,'time')
    ds.utime = ds.time/86400;
    tl = 'days';
else
    tl = 'station number';
end

subplot(2,3,1)
plot(ds.caldata(ii1q),ds.ctddata(ii1q),'.b',ds.caldata(ii2q),ds.ctddata(ii2q),'.r',ds.caldata(ii1g),ds.ctddata(ii1g),'ob',ds.caldata(ii2g),ds.ctddata(ii2g),'rs'); grid
xlabel('bottle'); ylabel('ctd');
subplot(2,3,2)
plot(ds.(tvar)(ii1q),ds.res(ii1q),'.b',ds.(tvar)(ii2q),ds.res(ii2q),'.r',ds.(tvar)(ii1g),ds.res(ii1g),'ob',ds.(tvar)(ii2g),ds.res(ii2g),'sr'); grid
xlabel(tl); ylabel(p.cclabel); ylim(p.rlim)
subplot(2,3,3)
plot(ds.res(ii1q),-ds.press(ii1q),'.b',ds.res(ii2q),-ds.press(ii2q),'.r',ds.res(ii1g),-ds.press(ii1g),'ob',ds.res(ii2g),-ds.press(ii2g),'sr'); grid
xlabel(p.cclabel); ylabel('-pressure (dbar)'); xlim(p.rlim)
subplot(2,3,4)
plot(ds.ctemp(ii1g),ds.res(ii1g),'bo',ds.ctemp(ii2g),ds.res(ii2g),'rs'); grid
xlabel('ctd best temperature'); ylabel(p.cclabel); ylim(p.rlim)
subplot(2,3,5)
scatter(ds.(tvar)(ii1g),-ds.press(ii1g),20,ds.res(ii1g),'filled'); colorbar; title('position 1'); caxis(p.rlim)
subplot(2,3,6)
scatter(ds.(tvar)(ii2g),-ds.press(ii2g),20,ds.res(ii2g),'filled'); colorbar; title('position 2'); caxis(p.rlim)


function cont = pick_line()
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
    cont = input('(zoom then) enter to continue or ''a'' to select again\n','s');
    if isempty(cont)
        done = 1;
    end
end
