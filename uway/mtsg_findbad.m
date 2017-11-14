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

scriptname = 'mtsg_findbad';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
    
switch MEXEC_G.Mship
    case 'cook'
        abbrev = 'met_tsg';
    case 'jcr'
        abbrev = 'ocl';
end
roottsg = mgetdir(abbrev);
infile1 = [roottsg '/' abbrev '_' cruise '_01_medav_clean'];

%get previous limits
scriptname0 = scriptname; scriptname = 'mtsg_cleanup'; oopt = 'kbadlims'; get_cropt; scriptname = scriptname0;

[d h] = mload(infile1,'/');

switch MEXEC_G.Mship
   case 'jcr'
      d.salin = d.salinity;
      d.cond = d.conductivity;
      d.temp_h = d.tstemp; % bak on jr302 tstemp is housing; sampletemp is fluorometer
      d.temp_m = d.sstemp;
      d.flowrate = d.flowrate;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%% start graphical part

figure(103)
clf

scrsz = get(0,'ScreenSize');
set(gcf,'Position',[1 0.1*scrsz(4) 0.4*scrsz(3) 0.8*scrsz(4)])


np = 0;
yporg = .2;
yptop = .2;

clear yporgs  yptops

% first count how many plots we will have, so we can get the size

if isfield(d,'salin')
    np = np+1;
end
if isfield(d,'cond')
    np = np+1;
end
if isfield(d,'temp_m') | isfield(d,'temp_h')
    np = np+1;
end
if isfield(d,'flowrate')
    np = np+1;
end


pl = .1;
pb = .1;
pw = .8;
ph = .8/(np+1); % allow salin plot to be double height

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
        mess = [mess 'pp  : plot present selection\n'];
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
            y0 = pb;

            iib = []; for no = 1:size(kbadlims,1); iib = [iib find(decday>=kbadlims(no,1) & decday<=kbadlims(no,2))]; end

            if isfield(d,'salin')   
                kount = kount+1;
                
                subplot('position',[pl y0 pw 2*ph])
                y0 = y0+2*ph;
                plot(decday,d.salin,'k+-',decday(iib),d.salin(iib),'c+');
                hold on ;grid on
                ha(kount) = gca;
                ylabel('salin');
                %             set(gca,'ylim',plims);
                ht = get(ha(kount),'title'); %handle for title
                set(ht,'string',infile1);
                set(ht,'interpreter','none');
            end

            if isfield(d,'cond')
                kount = kount+1;
                subplot('position',[pl y0 pw ph])
                y0 = y0+ph;
                plot(decday,d.cond,'k+-',decday(iib),d.cond(iib),'c+');
                hold on ;grid on
                ha(kount) = gca;
                ylabel('cond');
            end
            
            if isfield(d,'temp_m') | isfield(d,'temp_h')
                kount = kount+1;
                subplot('position',[pl y0 pw ph])
                y0 = y0+ph;
                if isfield(d,'temp_h')
                    plot(decday,d.temp_h,'k+-',decday(iib),d.temp_h(iib),'c+');
                    hold on ;grid on
                end
                if isfield(d,'temp_m')
                    plot(decday,d.temp_m,'r+-',decday(iib),d.temp_m(iib),'c+');
                    hold on ;grid on
                end
                ha(kount) = gca;
                ylabel('temp')
            end
            
            if isfield(d,'flowrate')
                kount = kount+1;
                subplot('position',[pl y0 pw ph])
                y0 = y0+ph;
                plot(decday,d.flowrate,'k+-',decday(iib),d.flowrate(iib),'c+');
                hold on ;grid on
                ha(kount) = gca;
                ylabel('flowrate');
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
            break
        case 'q'
            return
        otherwise
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%% end graphical part

disp(['new bad times: start     end'])
disp([datestr(alltimes(:,1),'yyyy mm dd HH MM SS') repmat('  ',size(alltimes,1),1) datestr(alltimes(:,2),'yyyy mm dd HH MM SS')])
