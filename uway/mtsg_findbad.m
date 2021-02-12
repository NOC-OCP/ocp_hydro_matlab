% mtsg_findbad: find times of bad tsg data
%
% Use: mtsg_findbad
% jc069: graphical version by bak
% Data are displayed in several panels. Salinity in the upper panel.
% Use Matlab zoom in the upper panel.
% When you have displayed a segment of data that you wish to examine further,
% type ‘z’ in the command window. Other panels will then zoom to the same time axis
% Use ss and se to define time limits enclosing data to be identified as bad
% When you are satisfied with the ss ans se values, type 'n'. THIS IS CRITICAL,
% because it is 'n' that stores the bad limits and moves to the next case.
% 'r' and 'l' should move half a panel left or right
% 'w' adds your new limits of bad data to the accumulating file
%
% YLF modified 12/2015 (JR15003) to plot previously selected bad times in a
% different color
% YLF modified jc145 to use opt_cruise rather than saving to .mat file

mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

scriptname = 'ship'; oopt = 'ship_data_sys_names'; get_cropt
roottsg = mgetdir(tsgpre);
infile1 = [roottsg '/' abbrev '_' mcruise '_01_medav_clean'];

%get previous limits
scriptname = 'mtsg_cleanup'; oopt = 'kbadlims'; get_cropt

[d h] = mload(infile1,'/');
salvar = mvarname_find({'salinity' 'psal'},h.fldnam);
if length(salvar)>0; issal = 1; else; issal = 0; end
tempsst = mvarname_find({'remotetemp' 'temp_4' 'sstemp'},h.fldnam);
if length(tempsst)>0; issst = 1; else; isst = 0; end
condvar = mvarname_find({'conductivity' 'cond'},h.fldnam);
if length(condvar)>0; iscond = 1; else; iscond = 0; end
tempvar = mvarname_find({'housingtemp' 'temp_h' 'tstemp'},h.fldnam);
if length(tempvar)>0; istemp = 1; else; istemp = 0; end
flowvar = mvarname_find({'flow' 'flow1'},h.fldnam);
if length(flowvar)>0; isflow = 1; else; isflow = 0; end

%%%%%%%%%%%%%%%%%%%%%%%%%%% start graphical part

figure(103)
clf

scrsz = get(0,'ScreenSize');
set(gcf,'Position',[1 0.1*scrsz(4) 0.4*scrsz(3) 0.8*scrsz(4)])


np = 0;
yporg = .2;
yptop = .2;

clear yporgs yptops

% first count how many plots we will have, so we can get the size

if issal
    np = np+1;
end
if iscond
    np = np+1;
end
if issst | istemp
    np = np+1;
end
if isflow
    np = np+1;
end


pl = .1;
pb = .1;
pw = .8;
ph = .6/(np+1); % allow salin plot to be double height

%start here

time = d.time;
dn = datenum(h.data_time_origin)+time/86400;
dv = datevec(dn(1)); yyyy = dv(1);
torg = datenum([yyyy 1 1 0 0 0]);
decday = dn-torg; % noon on 1 Jan is 0.5

kfirst = 1;

alltimes = [];

while 1
    if kfirst == 0
        mess = ['choose : \n'];
        mess = [mess 'p   : plot all\n'];
        mess = [mess 'z   : zoom all panels to current x lims\n'];
        mess = [mess 'q   : quit\n'];
        mess = [mess 'w   : save values and proceed\n'];
        mess = [mess 'n   : store values and proceed to next\n'];
        mess = [mess 'r   : move half a panel to the right\n'];
        mess = [mess 'l   : move half a panel to the left\n'];
        mess = [mess 'o   : zoom out: double the x lim range\n'];
        mess = [mess 'ss  : select start time\n'];
        mess = [mess 'se  : select end time\n'];
        mess = [mess '  :  '];
        aplot = input(mess,'s');
    else
        aplot = 'p';
        kfirst = 0;
    end
    switch aplot
        case 'p'
            clear ha
            clf
            
            kount = 0;
            
            iib = [];
            for no = 1:size(kbadlims,1)
                kbadlims1 = cell2mat(kbadlims(:,1:2)); %asf edit
                iib = [iib find(decday>=kbadlims1(no,1) & decday<=kbadlims1(no,2))];
            end
            
            if issal
                kount = kount+1;
                subplot('position',[pl pb+(np-1)*(ph+pb) pw ph*2])
                plot(decday,d.(salvar),'k+-',decday(iib),d.(salvar)(iib),'c+');
                hold on; grid on
                ha(kount) = gca;
                ylabel('salin');
                ht = get(ha(kount),'title'); %handle for title
                set(ht,'string',infile1);
                set(ht,'interpreter','none');
            end
            
            if iscond
                kount = kount+1;
                subplot('position',[pl pb+(np-2)*(ph+pb) pw ph])
                plot(decday,d.(condvar),'k+-',decday(iib),d.(condvar)(iib),'c+');
                hold on; grid on
                ha(kount) = gca;
                ylabel('cond');
            end
            
            if issst | istemp
                kount = kount+1;
                subplot('position',[pl pb+(np-3)*(ph+pb) pw ph])
                if issst
                    plot(decday,d.(tempvar),'k+-',decday(iib),d.(tempvar)(iib),'c+');
                    hold on; grid on
                end
                if istemp
                    plot(decday,d.(tempsst),'r+-',decday(iib),d.(tempsst)(iib),'c+');
                    hold on ;grid on
                end
                ha(kount) = gca;
                ylabel('temp')
            end
            
            if isflow
                kount = kount+1;
                subplot('position',[pl pb+(np-4)*(ph+pb) pw ph])
                plot(decday,d.(flowvar),'k+-',decday(iib),d.(flowvar)(iib),'c+');
                hold on; grid on
                ha(kount) = gca;
                ylabel('flow rate');
            end
            
        case 'z'
            xl = get(gca,'xlim');
            for kp = 1:np
                set(ha(kp),'xlim',xl);
            end
        case 'r'
            xl = get(gca,'xlim');
            for kp = 1:np
                set(ha(kp),'xlim',xl+0.5*(xl(2)-xl(1)));
            end
        case 'l'
            xl = get(gca,'xlim');
            for kp = 1:np
                set(ha(kp),'xlim',xl-0.5*(xl(2)-xl(1)));
            end
        case 'o'
            xl = get(gca,'xlim');
            for kp = 1:np
                set(ha(kp),'xlim',[xl(1)-0.5*(xl(2)-xl(1)) xl(2)+0.5*(xl(2)-xl(1))]);
            end
        case 'ss'
            % select  start scan
            [x y] = ginput(1);
            dn_startbad = min(decday(decday>=x));
            
        case 'se'
            % select  end scan
            [x y] = ginput(1);
            dn_endbad = max(decday(decday<=x));
            
        case 'n'
            alltimes = [alltimes; [dn_startbad dn_endbad]];
        case 'w'
            if ~(alltimes(end,1)==dn_startbad & alltimes(end,2)==dn_endbad)
                alltimes = [alltimes; [dn_startbad dn_endbad]];
            end
            break
        case 'q'
            return
        otherwise
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%% end graphical part

disp(['put the lines below into the mtsg_cleanup case of opt_' mcruise])
disp(['(or add to existing list of kbadlims)'])
disp(['if you want to remove only some variables for a time range,'])
disp(['replace ''all'' with a cell array listing the variable names'])
disp(['see mtsg_cleanup case in get_cropt'])
disp(['lines to paste:'])
sprintf('kbadlims = {%s',' ')
for no = 1:size(alltimes,1)
    %sprintf('datenum([%s]) datenum([%s]) ''all''\n', alltimes(no,1)+torg, alltimes(no,2)+torg)
    sprintf('datenum([%g %g %g %g %g %g]) datenum([%g %g %g %g %g %g]) ''all''\n', datevec(alltimes(no,1)+torg), datevec(alltimes(no,2)+torg))
end




