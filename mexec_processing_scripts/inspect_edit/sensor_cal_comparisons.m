function [dc, p, mod] = sensor_cal_comparisons(d, parameter, snstr, udstr, iis1, iis2, okf, p)
% function [dc, p, mod] = sensor_cal_comparisons(d, parameter, snstr, udstr, iis1, iis2, okf, p)
%
% arrange comparisons between a given sensor and calibration data as well
%   as the other sensor on the same casts
%
% d is a structure containing ctd and sample data (e.g. from
%   sam_{cruise}_all.nc) as well sensor serial numbers
% parameter is 'temp', 'cond', 'oxygen', or 'oxygen_diff'
% snstr is sensor serial number (string)
% udstr is 'u' or 'd' depending on whether to use upcast or downcast
%   data from d
% iis1 and iis2 are lists of indices in d where sensor with serial number
%   given by snstr was in use in ctd position 1 or ctd position 2
%   respectively
% okf is a vector of acceptable values for calbration data flag
% p is either empty, in which case defaults are used, or a structure
%   containing rlim, slim and glim, limits for stdev and gradient of ctd
%   data around bottle stop (if previously calculated and in d) to use to
%   limit data included in model fit
%
% outputs (structures)
% dc containins ctddata, ctdother, caldata, calflag, res, ctdres
% p contains labels and limits for plotting
% mod contains a model of form form, with vectors r and coefficients b
%   (i.e. ctddata_cal = r*b)

if strcmp(parameter,'oxygen_diff')
    useoxyratio = 0;
    parameter = 'oxygen';
else
    useoxyratio = 1;
end

%general fields we might need
iig0 = [iis1; iis2];
dc.press = d.([udstr 'press'])(iig0);

dc.ctddata = []; dc.ctemp = []; dc.cpsal = []; dc.ctdother = [];
if ~isempty(iis1)
    %ctd data, where this is in position 1
    dc.ctddata = d.([udstr parameter '1'])(iis1);
    dc.ctemp = d.([udstr 'temp1'])(iis1);
    dc.cpsal = d.([udstr 'psal1'])(iis1);
    if strcmp(parameter,'cond')
        %cond of psal2 at temp1
        dc.ctdother = gsw_C_from_SP(d.([udstr 'psal2'])(iis1),d.([udstr 'temp1'])(iis1),d.([udstr 'press'])(iis1));
    else
        dc.ctdother = d.([udstr parameter '2'])(iis1);
    end
end
if ~isempty(iis2)
    %ctd data, where this is in position 2
    dc.ctddata = [dc.ctddata; d.([udstr parameter '2'])(iis2)];
    dc.ctemp = [dc.ctemp; d.([udstr 'temp2'])(iis2)];
    dc.cpsal = [dc.cpsal; d.([udstr 'psal2'])(iis2)];
    if strcmp(parameter,'cond')
        %cond of psal1 at temp2
        dc.ctdother = [dc.ctdother; gsw_C_from_SP(d.([udstr 'psal1'])(iis2),d.([udstr 'temp2'])(iis2),d.([udstr 'press'])(iis2))];
    else
        dc.ctdother = [dc.ctdother; d.([udstr parameter '1'])(iis2)];
    end
end

if isempty(p)
    clear p
    p.rlim = [];
end

%sample/comparison data and residuals
switch parameter
    case 'temp'
        dc.caldata = d.sbe35temp(iig0);
        dc.calflag = d.sbe35temp_flag(iig0);
        if isempty(p.rlim)
            p.rlim = [-1 1]*1e-2;
        end

    case 'cond'
        dc.caldata = gsw_C_from_SP(d.botpsal(iig0), dc.ctemp, dc.press); %cond at CTD temp
        dc.calflag = d.botpsal_flag(iig0);
        if isempty(p.rlim)
            p.rlim = [-1 1]*1e-2;
        end

    case 'oxygen'
        dc.caldata = d.botoxy(iig0);
        dc.calflag = d.botoxy_flag(iig0);
        if isempty(p.rlim)
            if useoxyratio
                p.rlim = 1+[-5 5]/100;
            else
                p.rlim = [-1 1]*1.5;
            end
        end

end

%limit to acceptable samples
iig = find(ismember(dc.calflag,okf) & ~isnan(dc.caldata+dc.ctddata)); %caldata could be nan for cond even when flag is good if ctd temp is bad
if isempty(iig)
    dc = []; mod = [];
    return
end
dc.calflag = dc.calflag(iig);
dc.caldata = dc.caldata(iig);
dc.ctddata = dc.ctddata(iig);
dc.ctdother = dc.ctdother(iig);
dc.press = dc.press(iig);
dc.sampnum = d.sampnum(iig0(iig));
dc.statnum = d.statnum(iig0(iig));
dc.time = d.([udstr 'time'])(iig0(iig));
dc.nisk = d.position(iig0(iig));
dc.niskf = d.niskin_flag(iig0(iig));
dc.ctemp = d.([udstr 'temp'])(iig0(iig));
dc.cpsal = d.([udstr 'psal'])(iig0(iig));

%for model fit, also limit to acceptable ctd background
dc.cqflag = 2+zeros(length(iig),1);
m = false(size(dc.cqflag));
if ~isfield(p,'slim')
    p.slim = p.rlim(2)*.5;
    if strcmp(parameter,'cond'); p.slim = p.rlim(2)*.8; end
end
if ~isfield(p,'glim')
    p.glim = p.rlim(2)*.5;
    if strcmp(parameter,'cond'); p.glim = p.rlim(2)*.8; end
end
if isfield(d,['std1_' parameter])
    m = m | d.(['std1_' parameter])(iig)>p.slim;
end
if isfield(d,['grad_' parameter])
    m = m | abs(d.(['grad_' parameter])(iig))>p.glim;
end
dc.cqflag(m) = 3;
iigc = find(dc.cqflag==2);
disp(['fit to ' num2str(length(iigc)) '/' num2str(length(iig)) ' points'])

switch parameter

    case 'temp'
        dc.res = dc.caldata-dc.ctddata;
        p.cclabel = ['sbe35 T - ctd T s/n ' snstr ' (^oC)'];
        dc.ctdres = dc.ctdother-dc.ctddata;
        p.colabel = ['ctd T alt - ctd T s/n ' snstr ' (^oC)'];
        mod.r = [ones(length(iigc),1) dc.press(iigc) dc.statnum(iigc)];
        mod.form = 'tempcal = temp + C1 + C2(press) + C3(stn)';
        mod.b = regress(dc.res(iigc),mod.r);

    case 'cond'
        dc.res = (dc.caldata./dc.ctddata - 1)*35;
        p.cclabel = ['(bottle C (ctd T)/ctd C s/n ' snstr '-1)/35 (~psu)'];
        dc.ctdres = (dc.ctdother./dc.ctddata - 1)*35;
        p.colabel = ['(ctd C alt (ctd T)/ctd C s/n ' snstr '-1)/35 (~psu)'];
        mod.r = [dc.ctddata(iigc) dc.ctddata(iigc).*dc.press(iigc) dc.ctddata(iigc).*dc.statnum(iigc)];
        mod.form = 'condcal = cond*(C1 + C2(press) + C3(stn))';
        mod.b = regress(dc.caldata(iigc),mod.r);

    case 'oxygen'
        if useoxyratio
            dc.res = dc.caldata./dc.ctddata;
            p.cclabel = ['bottle O / ctd O s/n ' snstr];
            dc.ctdres = dc.ctdother./dc.ctddata;
            p.colabel = ['ctd O alt / ctd O s/n ' snstr];

        else
            dc.res = (dc.caldata - dc.ctddata);
            p.cclabel = ['bottle oxygen - ctd oxygen s/n ' snstr ' (umol/kg)'];
            dc.ctdres = dc.ctdother - dc.ctddata;
            p.colabel = ['ctd oxygen alternate - ctd oxygen s/n ' snstr ' (umol/kg)'];

        end
        %mod.r = [ones(length(iigc),1) dc.press(iigc) dc.press(iigc).^2 dc.ctddata(iigc) dc.ctddata(iigc).*dc.press(iigc) dc.ctddata(iigc).*dc.press(iigc).^2];
        %mod.form = 'oxycal = C1 + C2(press) + C3(press^2) + (C4 + C5(press) + C6(press^2))(oxy)';
        mod.r = [ones(length(iigc),1) dc.press(iigc) dc.statnum(iigc) dc.ctddata(iigc) dc.ctddata(iigc).*dc.press(iigc) dc.ctddata(iigc).*dc.statnum(iigc)];
        mod.form = 'oxycal = C1 + C2(press) + C3(stn) + (C4 + C5(press) + C6(stn))(oxy)';
        mod.b = regress(dc.caldata(iigc),mod.r);

end
disp(mod.form); fprintf(1,'%f, ',mod.b(:)); fprintf('\n')
p.iigc = iigc;

