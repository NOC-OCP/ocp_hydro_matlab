function checkbottles_01(stations, varname, section)
% function checkbottles_01(stations, varname, section)
%
% (formerly identify_bottles, then msam_checkbottles_01)
% bak on jc159 19 March 2018
%
% identify problem bottles by plotting against theta or pressure
% plot full values or anomalies against CTD (S,O) or gridded data if available
%
% use:
% msam_checkbottles_01(stations, var, section)
%
% stations is a numeric array with a list of station numbers to display; If
% 'stations' is empty, use all.
%
% var is a text string with the name of the (bottle sample) variable in a
% sam_xxxxx_all file
%
% section is a character string identifying a gridded section of bottle
% data to use as a reference for calculating anomalies. If it doesn't
% exist, anomalies are not plotted.
%
% eg
% checkbottles_01([],'botpsal')
% checkbottles_01([10:30 32:50],'totnit','24s')
%
% The second example will refer to file
% grid_jc159_24s.nc

% check for at least two arguments: stations and variable
if nargin < 2
    fprintf(2,'\n%s\n\n','Must supply at least two arguments; see help msam_checkbottles_01 ');
    return
end

m_common
if MEXEC_G.quiet<=1; fprintf(1,'plotting bottle sample residuals (from ctd, or from gridded fields) to allow selection of outliers\n and identification of where flags need to be changed\n'); end

root_ctd = mgetdir('M_CTD'); % identify CTD directory
root_asc = mgetdir('M_CTD_CNV'); %this is where the bottle data flags script will live
bdffile = fullfile(root_asc, 'bottle_data_flags.txt'); %the name of this file is not a cruise option, partially because it always needs to be a m-file

% check for existence of sam file and load; exit if absent;

fnsamall = fullfile(root_ctd, ['sam_' mcruise '_all']);

if exist(m_add_nc(fnsamall),'file') == 2
    [dsam, ~]  = mload(fnsamall,'/');
else
    fprintf(2,'\n%s %s %s\n\n','File ',m_add_nc(fnsamall),' not found; exiting');
    return
end


% check for existence of gridded file; warn if 3 arguments but file is absent

if nargin >= 3
    fngrid = fullfile(root_ctd, ['grid_' mcruise '_' section '.mat']);
    if exist(fngrid,'file') == 2
        load(fngrid,'mgrid'); dg = mgrid;
        clear hg; hg.fldnam = dg.vars; hg.fldunt = dg.unts;
        dg = rmfield(dg,{'vars' 'unts'});
        scriptname = 'mctd_02'; oopt = 'ctd_cals'; get_cropt
        if isfield(castopts, 'calstr')
            calstr = select_calibrations(castopts.docal, castopts.calstr);
            if ~isempty(calstr)
                [dg, hg] = apply_calibrations(dg, hg, calstr);
                if castopts.docal.cond || castopts.docal.temp
                    dg.psal = gsw_SP_from_C(dg.cond, dg.temp, dg.press);
                    dg.asal = gsw_SA_from_SP(dg.psal, dg.press, hg.longitude, hg.latitude);
                    dg.potemp = gsw_pt0_from_t(dg.asal, dg.temp, dg.press);
                end
            end
        end

    else
        fprintf(2,'\n%s %s %s\n\n','File ',fngrid,' not found; anomalies will not be plotted');
        clear dg hg
    end
else
    fprintf(2,'\n%s\n\n','No gridded file identified; anomalies will not be plotted');
    fngrid = [];
    clear dg hg
end


% if stations weren't specified, use all stations found in the sam file
if isempty(stations)
    stations = unique(dsam.statnum(~isnan(dsam.utemp))); % all stations in sam file
end


% sort out the variable to be plotted and the anomaly if required

if ~isfield(dsam,varname)
    fprintf(2,'\n%s %s %s \n\n','Variable ',varname',' does not exist in dsam');
    return
end

v = dsam.(varname);

% flag (name format not always consistent)
varflagname = [varname '_flag'];
if ~isfield(dsam, varflagname)
    varflagname = [varname(1:end-1) 'flag' varname(end)]; %assume there's a number or letter appended
    if ~isfield(dsam, varflagname)
        varflagname = [varname 'flag']; %maybe there's no underscore
        if ~isfield(dsam, varflagname)
            error(['could not identify flag field for variable ' varname])
        end
    end
end
vflag = dsam.(varflagname);

%anomaly from comparison field
switch varname
    case 'botpsal'
        vanom = v - dsam.upsal;
    case {'botoxy', 'botoxya', 'botoxyb'}
        vanom = v - dsam.uoxygen;
    otherwise % expect to find the variable in both sam and grid
        if exist('dg','var') ~= 1
            fprintf(2,'\n%s\n\n','Gridded data have not been loaded; anomalies will be set to zero');
            vanom = 0*v;
        elseif ~isfield(dg,varname)
            fprintf(2,'\n%s %s %s\n\n','Gridded file does not have variable',varname,'; anomalies will be set to zero');
            vanom = 0*v;
        else
            vanom = make_vanom(varname,dsam,dg);
        end
end


% find sample data selected for stations
kuse = find(ismember(dsam.statnum, stations));
v = v(kuse);
vanom = vanom(kuse);
vflag = vflag(kuse);
vsampnum = dsam.sampnum(kuse);
press = dsam.upress(kuse);
potemp = dsam.upotemp(kuse);

% end coarse selection based on station


kall = 1:length(v); kall = kall(:);
k2 = find(vflag == 2 | vflag == 6); %good or average of replicates
k3 = find(vflag == 3);
k4 = find(vflag == 4);
k5 = find(vflag == 5);
k9 = find(vflag == 9);
kother = setdiff(kall,[k2; k3; k4; k5; k9]);
% keyboard
%advise if any NaNs have "good" flags
iib2 = find(isnan(v(k2)));
if ~isempty(iib2)
    warning('these NaNs have flags of 2!')
    sprintf('%8.0f\n', vsampnum(k2(iib2)))
end

x1 = v;
x2 = vanom;
y1 = -press;
y2 = potemp;

% create 4 plots; versus P and versus T and full or anomaly

m_figure

hfig = gcf;

h = plot4(x1,x2,y1,y2,k2,k3,k4,k5,k9,kother);
subplot(2,2,1); xlabel(varname);

while 1
    mess = [ ...
        'choose : \n' ...
        'p   : plot all\n' ...
        'z   : zoom all panels to current x lims\n' ...
        'o   : zoom out\n' ...
        'l   : list values found in window\n' ...
        'c   : surround with crosshairs and list values to screen\n' ...
        'w   : surround with crosshairs and list values to file for later use in setting flags\n' ...
        'q   : quit\n'...
        '    : '...
        ];
    a = input(mess,'s'); % answer carrid through script
    
    if strcmp(a,'q'); return; end
    
    switch a
        case 'p'
            kwin = 1; % just so it is set
        otherwise
            mess = [ ...
                'Which subplot (1-4) should be used for the action\n' ...
                'numbering from top left to top right in the usual matlab convention:  ' ...
                ];
            kwin = input(mess); % subplot number carried through script
            if isempty(find([1 2 3 4] == kwin, 1))
                fprintf(2,'\n%s %d\n\n','Subplot number must be 1,2,3 or 4. You entered ',kwin);
                continue
            else
                fprintf(1,'\n%s %d \n\n','Using subplot ',kwin);
            end
    end
    
    
    
    % find which samples are in present subplot
    % identify which window is current
    g = get(h(kwin));
    
    xl = g.XLim;
    yl = g.YLim;
    
    switch kwin
        case 1
            x = x1; y = y1;
        case 2
            x = x2; y = y1;
        case 3
            x = x1; y = y2;
        case 4
            x = x2; y = y2;
        otherwise
            fprintf(2,'\n%s\n\n','Error, window not identified correctly; return');
    end
    
    switch a % increase limits for selected subplot
        case 'o'
            xl(1) = xl(1)-0.25*(xl(2)-xl(1));
            xl(2) = xl(2)+0.25*(xl(2)-xl(1));
            yl(1) = yl(1)-0.25*(yl(2)-yl(1));
            yl(2) = yl(2)+0.25*(yl(2)-yl(1));
        otherwise
    end
    
    switch a % select data in the selected subplot
        case 'p'
            ksel = kall;
        case {'z' 'l' 'o'}
            ksel = find(x >= min(xl) & x <= max(xl) & y >= min(yl) & y <= max(yl));
        case {'c' 'w'}
            g1 = ginput(1);
            plot(xl,g1(2)+0*yl,'k-');
            plot(g1(1)+0*xl,yl,'k-');
            g2 = ginput(1);
            xy2 = [g1;g2];
            xx = sort(xy2(:,1));
            yy = sort(xy2(:,2));
            if ~exist('ksel','var'); ksel = kall; end
            kg = find(x >= xx(1) & x <= xx(2) & y >= yy(1) & y <= yy(2));
            
    end
    
    [~, ksel2, ~] = intersect(ksel,k2); % we need the index within ksel of flags
    [~, ksel3, ~] = intersect(ksel,k3); % we need the index within ksel of flags
    [~, ksel4, ~] = intersect(ksel,k4); % we need the index within ksel of flags
    [~, ksel5, ~] = intersect(ksel,k5); % we need the index within ksel of flags
    [~, ksel9, ~] = intersect(ksel,k9); % we need the index within ksel of flags
    [~, kselother, ~] = intersect(ksel,kother); % we need the index within ksel of flags
    
    h = plot4(x1(ksel),x2(ksel),y1(ksel),y2(ksel),ksel2,ksel3,ksel4,ksel5,ksel9,kselother);
    subplot(2,2,1); xlabel(varname);
    
    switch a
        case {'c' 'w'}
            subplot(2,2,kwin);
            plot(xx,yy(1)+0*xx,'k-');
            plot(xx,yy(2)+0*xx,'k-');
            plot(xx(1)+0*yy,yy,'k-');
            plot(xx(2)+0*yy,yy,'k-');
    end
    
    
    switch a % plotting
        case 'p'
            % we have a new plot, use default lims
        case {'z' 'l' 'o' 'c'}
            % replot, but adjust lims to what we had zoomed to
            switch kwin
                case 1
                    set(h(1),'XLim',xl,'YLim',yl)
                    set(h(2),'YLim',yl);
                    set(h(3),'XLim',xl);
                case 2
                    set(h(1),'YLim',yl)
                    set(h(2),'XLim',xl,'YLim',yl);
                    set(h(4),'XLim',xl);
                case 3
                    set(h(1),'XLim',xl);
                    set(h(3),'XLim',xl,'YLim',yl)
                    set(h(4),'YLim',yl);
                case 4
                    set(h(2),'XLim',xl);
                    set(h(3),'YLim',yl);
                    set(h(4),'XLim',xl,'YLim',yl)
            end
        otherwise
    end
    
    switch a % listing;
        case 'l'
            fprintf(1,'%8s %7s %7s %8s %8s %4s\n','sampnum','press','potemp','val','resid','flag');
            for kl = 1:length(ksel)
                fprintf(1,'%8.0f %7.1f %7.3f %8.3f %8.3f %4.0f\n',vsampnum(ksel(kl)),press(ksel(kl)),potemp(ksel(kl)),v(ksel(kl)),vanom(ksel(kl)),vflag(ksel(kl)));
            end
        case {'c', 'w'}
            fprintf(1,'%8s %7s %7s %8s %8s %4s\n','sampnum','press','potemp','val','resid','flag');
            for kl = 1:length(kg)
                fprintf(1,'%8.0f %7.1f %7.3f %8.3f %8.3f %4.0f\n',vsampnum(kg(kl)),press(kg(kl)),potemp(kg(kl)),v(kg(kl)),vanom(kg(kl)),vflag(kg(kl)));
            end
            subplot(2,2,1)
            plot(v(kg),-press(kg),'g^','markersize',15);
            subplot(2,2,2)
            plot(vanom(kg),-press(kg),'g^','markersize',15);
            subplot(2,2,3)
            plot(v(kg),potemp(kg),'g^','markersize',15);
            subplot(2,2,4)
            plot(vanom(kg),potemp(kg),'g^','markersize',15);
            if strcmp(a, 'w') % also write to file
                if exist(bdffile,'file')==2
                    fid = fopen(bdffile, 'a');
                else
                    fid = fopen(bdffile, 'w');
                end
                for kl = 1:length(kg)
                    fprintf(fid, '%s, %d, %d, %d\n', varflagname, vsampnum(kg(kl)), vflag(kg(kl)), vflag(kg(kl)));
                end
                fclose(fid);
                disp(['now run checkbottles_02 to check against property gradients'])
                disp(['and determine what the new flags should be; edit flags in opt_' mcruise])
            end
    end
    
end



function h = plot4(x1,x2,y1,y2,k2,k3,k4,k5,k9,kother)

% called by msam_checkbottles_01.m

clf

clear h; h = nan(4,1);


subplot(2,2,1) % P-var
h(1) = gca;

plot(x1(k2),y1(k2),'+');
hold on; grid on;
plot(x1(k3),y1(k3),'ro','markersize',8);
plot(x1(k4),y1(k4),'ko','markersize',8);
plot(x1(kother),y1(kother),'co','markersize',8);
plot(x1(k5),y1(k5),'gx','markersize',10);
plot(x1(k9),y1(k9),'mx','markersize',10);
ylabel('pressure');
xlabel('variable');
title({'flagged data: 3 (ro) 4 (ko) 5 (gx) 9 (mx) other (co)'})



subplot(2,2,2) % P-anom
h(2) = gca;

plot(x2(k2),y1(k2),'+');
hold on; grid on;
plot(x2(k3),y1(k3),'ro','markersize',8);
plot(x2(k4),y1(k4),'ko','markersize',8);
plot(x2(kother),y1(kother),'co','markersize',8);
plot(x2(k5),y1(k5),'gx','markersize',10);
plot(x2(k9),y1(k9),'mx','markersize',10);
xlabel('anomaly');



subplot(2,2,3) % T-var
h(3) = gca;

plot(x1(k2),y2(k2),'+');
hold on; grid on;
plot(x1(k3),y2(k3),'ro','markersize',8);
plot(x1(k4),y2(k4),'ko','markersize',8);
plot(x1(kother),y2(kother),'co','markersize',8);
plot(x1(k5),y2(k5),'gx','markersize',10);
plot(x1(k9),y2(k9),'mx','markersize',10);
ylabel('potemp');



subplot(2,2,4) % T-anom
h(4) = gca;

plot(x2(k2),y2(k2),'+');
hold on; grid on;
plot(x2(k3),y2(k3),'ro','markersize',8);
plot(x2(k4),y2(k4),'ko','markersize',8);
plot(x2(kother),y2(kother),'co','markersize',8);
plot(x2(k5),y2(k5),'gx','markersize',10);
plot(x2(k9),y2(k9),'mx','markersize',10);


return

function vanom = make_vanom(varname,dsam,dg)

v = dsam.(varname);
vanom = v+nan;

stats = unique(dsam.statnum(~isnan(dsam.utemp))); %sam stations
statg = dg.statnum(1,:);

for kl = 1:length(stats)
    snum = stats(kl); % station number
    ksam = find(dsam.statnum == snum); % cycles in sam file for this station
    
    kgcol = find(statg == snum);% column in gridded file
    
    if isempty(kgcol) % station not in gridded file
        fprintf(2,'%s %4d %s\n','Station',snum,'not found in gridded file; anomalies will be set to zero'); % so vanom is zero
        vanom(ksam) = 0*v(ksam);
    else
        gvar = dg.(varname); gvar = gvar(:,kgcol);
        vanom(ksam) = v(ksam) - interp1(dg.press(:,kgcol),gvar,dsam.upress(ksam));
    end
end
