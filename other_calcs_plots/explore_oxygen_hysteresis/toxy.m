d = mload('ctd_jc191_078_24hz.nc','/');
dcs = mload('dcs_jc191_078.nc','/');

scanbot = dcs.scan_bot;
kdown = find(d.scan < scanbot & d.scan>dcs.scan_start);
kup = find(d.scan > scanbot & d.scan < dcs.scan_end);
kok = find(d.scan > dcs.scan_start & d.scan < dcs.scan_end);


hyst_pars1 = [-0.043 5000 1450]; %sbe default
hyst_pars1 = [-0.033 5000 1450]; %

H1 = hyst_pars1(1) + zeros(size(d.oxygen_sbe1));
H2 = hyst_pars1(2) + zeros(size(d.oxygen_sbe1));
H3 = hyst_pars1(3) + zeros(size(d.oxygen_sbe1));

clear resid resid_out hyst_out

% d.oxygen1 = d.oxygen_sbe1+nan;
iset = 0;

sensor = 1;

switch sensor
    case 1 % primary, all sations so far
        %         hyst_pars1 = [-0.045 5000 1450]; %
        d.oxygen_sbe = d.oxygen_sbe1;
        h3tab =[
            -10 1000
            1000 1000
            1001 1000
            2000 1000
            2001 3000
            9000 3000
%             -10 1000
%             1000 1000
% %             1001 1500
% %             3000 1500
%             1001 1000
%             2000 1000
%             2001 3000
%             3000 3000
%             3001 3000
%             4000 3000
%             4001 3000
%             5000 3000
%             7000 3000
            ];
%         h3tab(:,2) = h3tab(:,2)*1000;
    case 2 % secondary
        %         hyst_pars1 = [-0.045 5000 1450]; %
        d.oxygen_sbe = d.oxygen_sbe2;
        h3tab =[
            -10 1000
            1000 1000
            1001 1000
            2000 1000
            2001 3500
            9000 3500
%             -10 300
%             1000 300
%             1001 1250
%             2000 1250
%             2001 1600
%             3000 1600
%             3001 3000
%             4000 3000
%             4001 3700
%             5000 3700
%             7000 5000
            ];
    otherwise
end

H3 = interp1(h3tab(:,1),h3tab(:,2),d.press);


d.oxygen = d.oxygen_sbe1+nan;


[d.oxygen(kok) C(kok) D(kok)] =mcoxyhyst(d.oxygen_sbe(kok),d.time(kok),d.press(kok),H1(kok),H2(kok),H3(kok),0);
close all
figure

plot(d.press(kdown),d.oxygen_sbe(kdown),'k-','linewidth',2);
hold on; grid on;
plot(d.press(kup),d.oxygen_sbe(kup),'m-','linewidth',2);

plot(d.press(kdown),d.oxygen_sbe(kdown)./D(kdown),'g-');
hold on; grid on;
plot(d.press(kup),d.oxygen_sbe(kup)./D(kup),'b-');

plot(d.press(kdown),d.oxygen(kdown),'r-');
plot(d.press(kup),d.oxygen(kup),'c-');


plot(d.press(kok),200+400*(1-D(kok)),'k');

[a,b] = unique(d.press(kup));

cyan_oxy = interp1(a,d.oxygen(kup(b)),d.press(kdown));
blue_oxy = interp1(a,d.oxygen_sbe(kup(b))./D(kup(b)),d.press(kdown));

filt = ones(1,25);

figure
plot(d.press(kdown),(d.oxygen_sbe(kdown)./D(kdown))-cyan_oxy,'c-');
hold on; grid on;
plot(d.press(kdown),((d.oxygen_sbe(kdown)./D(kdown))-d.oxygen(kdown)),'r-');
plot(d.press(kdown),((d.oxygen_sbe(kdown)./D(kdown))-blue_oxy),'b-');
plot(d.press(kdown),filter_bak(filt,(cyan_oxy - d.oxygen(kdown))),'k-')
title('c: green-cyan r:green minus red b: green minus blue K:cyan minus red')
set(gca,'ylim',[-5 5]);

