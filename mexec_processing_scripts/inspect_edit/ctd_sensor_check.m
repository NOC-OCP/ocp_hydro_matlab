
function ctd_sensor_check(varargin)
% ctd_sensor_check(sensors_to_check)
% ctd_sensor_check(sensors_to_check,'parameter','value')
%
% for each parameter in sensors_to_check, loop through individual CTD
%   sensors (by serial number, as generated by get_sensor_sns); compare to
%   bottle (or sbe35) values, plot differences or ratios as functions of a)
%   station number (or time), b) pressure, c) temperature and prompt to
%   select a linear or piecewise linear fit from the plots; optionally
%   generate a second set of plots with CTD profile data ***
%
% sensors_to_check is cell array, options are 'temp', 'cond', 'oxygen',
%   'oxygen_diff'
% temp is always compared as a difference, cond always as a ratio, oxygen
%   can be a ratio or a difference (if input as 'oxygen_diff')
%
%
% optional parameter-value pairs include:
%
% setlims (default 0): 1 to limit axes on comparison plot to expected range
%   of differences (ratios) for a given parameter
% okf (default [2 3 6]): which flags on bottle data to include in comparison
%   and fit of model
% tvar (default 'statnum'): use statnum or time as independent variable
% profile_compare (default 0): 1 to step through stations***
%

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

setlims = 0;
okf = [2 3 6];
udstr = 'u';
p = [];
tvar = 'statnum';
if nargin>0
    if iscell(varargin{1})
        sensors_to_check = varargin{1};
    else
        sensors_to_check = varargin(1);
    end
else
    sensors_to_check = {'temp' 'cond' 'oxygen'};
end
for no = 2:2:length(varargin)-1
    varargin{no} = eval(varargin{no+1});
end

m = strcmp('oxygen_diff',sensors_to_check);
if sum(m)
    oxydiff = 1;
    sensors_to_check{m} = 'oxygen';
else
    oxydiff = 0;
end

opt1 = 'ctd_proc'; opt2 = 'ctdsens_groups'; get_cropt
if exist(sgfile,'file')
    load(sgfile)
end
[ds, ~] = mload(fullfile(mgetdir('sam'),['sam_' mcruise '_all']),'/');

ds.uoxygen1(isnan(ds.utemp1)) = NaN;
ds.uoxygen2(isnan(ds.utemp2)) = NaN;

fn = fieldnames(sng);

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
        s1 = unique(ds.statnum(ii1));
        s2 = unique(ds.statnum(ii2));
        disp([sens{sno} ' in position 1 on these stations with bottles:']); disp(s1')
        t = unique(sg.temp1(ismember(sg.temp1(:,1),s1),2))'; c = unique(sg.cond1(ismember(sg.cond1(:,1),s1),2))';
        disp('with these sensors for temp1, cond1:'); fprintf(1,'%d  ',t(:)); fprintf(1,'\n'); fprintf(1,'%d  ',c(:)); fprintf(1,'\n');
        disp([sens{sno} ' in position 2 on these stations with bottles:']); disp(s2')
        t = unique(sg.temp2(ismember(sg.temp2(:,1),s2),2))'; c = unique(sg.cond2(ismember(sg.cond2(:,1),s2),2))';
        disp('with these sensors for temp2, cond2:'); fprintf(1,'%d  ',t(:)); fprintf(1,'\n'); fprintf(1,'%d  ',c(:)); fprintf(1,'\n');
        if isempty(dc) || isempty(dc.calflag)
            disp('no good (enough) calibration data; skipping')
            continue
        else
            ii1g = intersect(find(ismember(dc.statnum,s1)),find(ismember(dc.calflag,[2 6])));
            ii1q = intersect(find(ismember(dc.statnum,s1)),find(dc.calflag==3));
            ii2g = intersect(find(ismember(dc.statnum,s2)),find(ismember(dc.calflag,[2 6])));
            ii2q = intersect(find(ismember(dc.statnum,s2)),find(dc.calflag==3));
            figure(pno*10+sno); clf
            plot_panels(dc,p,ii1g,ii2g,ii1q,ii2q,setlims,tvar)
            cont = pick_line();
        end
    end
end


function plot_panels(ds,p,ii1g,ii2g,ii1q,ii2q,setlims,tvar)

if strcmp(tvar,'time')
    ds.(tvar) = ds.(tvar)/86400;
    tl = 'days';
else
    tl = 'station number';
end

subplot(2,3,1)
plot(ds.caldata(ii1q),ds.ctddata(ii1q),'.b',ds.caldata(ii2q),ds.ctddata(ii2q),'.r',ds.caldata(ii1g),ds.ctddata(ii1g),'ob',ds.caldata(ii2g),ds.ctddata(ii2g),'rs'); grid
xlabel('bottle'); ylabel('ctd');
subplot(2,3,2)
plot(ds.(tvar)(ii1q),ds.res(ii1q),'.b',ds.(tvar)(ii2q),ds.res(ii2q),'.r',ds.(tvar)(ii1g),ds.res(ii1g),'ob',ds.(tvar)(ii2g),ds.res(ii2g),'sr'); grid
xlabel(tl); ylabel(p.cclabel); if setlims; ylim(p.rlim); end
subplot(2,3,3)
plot(ds.res(ii1q),-ds.press(ii1q),'.b',ds.res(ii2q),-ds.press(ii2q),'.r',ds.res(ii1g),-ds.press(ii1g),'ob',ds.res(ii2g),-ds.press(ii2g),'sr'); grid
xlabel(p.cclabel); ylabel('-pressure (dbar)'); if setlims; xlim(p.rlim); end
subplot(2,3,4)
plot(ds.ctemp(ii1g),ds.res(ii1g),'bo',ds.ctemp(ii2g),ds.res(ii2g),'rs'); grid
xlabel('ctd best temperature'); ylabel(p.cclabel); if setlims; ylim(p.rlim); end
subplot(2,3,5)
scatter(ds.(tvar)(ii1g),-ds.press(ii1g),20,ds.res(ii1g),'filled'); colorbar; title('position 1'); if setlims; caxis(p.rlim); end
subplot(2,3,6)
scatter(ds.(tvar)(ii2g),-ds.press(ii2g),20,ds.res(ii2g),'filled'); colorbar; title('position 2'); if setlims; caxis(p.rlim); end


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
