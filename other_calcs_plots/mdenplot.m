% mdenplot
%
% Use: mdenplot        and then respond with station number, or for station 16
%      stn = 16; mdenplot;

scriptname = 'mdenplot';

if exist('stn','var')
    m = ['Running script ' scriptname ' on station ' sprintf('%03d',stn)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
stnlocal = stn;
clear stn % so that it doesn't persist

mcd('M_CTD'); % change working directory

prefix1 = ['ctd_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
prefix2 = ['sam_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];

infile1 = [prefix1 stn_string '_2db'];
infile2 = [prefix2 stn_string ];

d = mload(infile1,'/');
b = mload(infile2,'/');

d.sig1 = sw_pden(d.psal,d.temp,d.press,1000)-1000;
b.usig1 = sw_pden(b.upsal,b.utemp,b.upress,1000)-1000;

figure
plot(d.sig1,-d.press,'k-');
hold on; grid on

plot(b.usig1,-b.upress,'r+');

refdens = [
    32.332 %tracer 
    32.4
    32.15
    ]

xx = refdens(1); xx = [xx xx];
yy = [-500 -max(d.press)];
plot(xx,yy,'k-','linewidth',2)

for kr = 2:length(refdens)
    xx = refdens(kr); xx = [xx xx];
    plot(xx,yy,'k-','linewidth',1)
end

for kb = 1:length(b.usig1)
%     plot([b.usig1(kb)-.2 b.usig1(kb)+.2],-[b.upress(kb) b.upress(kb)],'r-')
end

xlabel('sigma 1')
ylabel('press')
h = title(infile2);
set(h,'interpreter','none')
    