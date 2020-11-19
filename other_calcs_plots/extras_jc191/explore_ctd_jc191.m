% explore CTD sensor offsets jc191
%
% we dont only need to do this with bottle stops, can use CTD downcasts
% to detrmine adjustments to bring sensors into agreement
% 
% assume both CTDs see the same water on the downcast
%
% t1 c1 on frame
% t2 c2 on vane
%
% jc191:
% station   1 -  34  T11, C11, T21, C21
% station  35 -  74  T11, C11, T22, C21  swap t2
% station  75 - 999  T12, C11, T22, C21  swap t1
%

ks1 = 1:34;
ks2 = 35:74;
ks3 = 75:999;
ks4 = [];;

ks  = ks3;

froot = ['/local/users/pstar/jc191/mcruise/data/ctd/'];
c35 = sw_c3515;
cdef = 35; % useful to make a cond ratio different from 1 look like a salinity offset

figure(101); clf
figure(102); clf
figure(103); clf
figure(104); clf
figure(105); clf
figure(106); clf

f = ones(1,21); % smnoothing filter
fg = [-1 -1 -1 -1 -1 0 1 1 1 1 1]; % gradient filter

tdel11 = 0;%0.1; % T11 lag;
talign11 = 0;%0.1; % align primary and secondary sensors
tdel12 = 0;%0.1; % T11 lag;
talign12 = 0;%0.3; % align primary and secondary sensors
tdel13 = 0;
talign13 = 0;

pall = [];
t1all = [];
t2all = [];

for kl = [81:86];
    col = 'r-';
    if kl <= 83; col = 'k-'; end
    
    stnstr = sprintf('%03d',kl);
    fnin = [froot 'ctd_jc191_' stnstr '_2db.nc'];
    if exist(fnin,'file') ~= 2; continue; end
    clear d
    d = mload(fnin,'/');
    m = filter_bak(f,d.time(:)'); % use m for tiMe to distinguish it from temp
    p = filter_bak(f,d.press(:)');
    t1 = filter_bak(f,d.temp1(:)'); 
    s1 = filter_bak(f,d.psal1(:)');
    c1 = c35*sw_cndr(s1,t1,p);
    t2 = filter_bak(f,d.temp2(:)');
    s2 = filter_bak(f,d.psal2(:)');
    c2 = c35*sw_cndr(s2,t2,p);
    
    dm = filter_bak_nonorm(fg,m);
    dp = filter_bak_nonorm(fg,p);
    dt1 = filter_bak_nonorm(fg,t1);
    ds1 = filter_bak_nonorm(fg,s1);
    dpdm = dp./dm;
    dt1dm = dt1./dm;
    ds1dm = ds1./dm;
    
    
    if ismember(kl,[ks1 ks2]) % T11
        t1 = t1 + tdel11 * dt1dm;
        s1 = sw_salt(c1/c35,t1,p);
        
        t1 = t1 + talign11 * dt1dm;
        s1 = s1 + talign11 * ds1dm;
        c1 = c35*sw_cndr(s1,t1,p);
        t1 = t1  + 0*(0.00040 - 0.00050*p/1000) + 0.00000*p/1000;
    end
    if ismember(kl,[ks3]) % T12
        t1 = t1 + tdel12 * dt1dm;
        s1 = sw_salt(c1/c35,t1,p);
        
        t1 = t1 + talign12 * dt1dm;
        s1 = s1 + talign12 * ds1dm;
        c1 = c35*sw_cndr(s1,t1,p);
        t1 = t1 + 0*(+0.0006 - 0.00000*p/1000) + 0.00000*p/1000;
    end
    if ismember(kl,[ks4]) % T12 after 84
        t1 = t1 + tdel13 * dt1dm;
        s1 = sw_salt(c1/c35,t1,p);
        
        t1 = t1 + talign13 * dt1dm;
        s1 = s1 + talign13 * ds1dm;
        c1 = c35*sw_cndr(s1,t1,p);
        t1 = t1 + 0*(+0.0006 - 0.00000*p/1000) + 0.00000*p/1000;
    end
    
    if ismember(kl,[ks1]) % T21
%         t2 = t2  + 0.00289 - 0.00024*p/1000 + 0.00008*p/1000; 
        t2 = t2  + 0*(0.00242 - 0.00013*p/1000 + 0.00000*p/1000); 
    end
    if ismember(kl,[ks2 ks3 ks4]) % T22
        t2 = t2  + 0.0000 + 0.00000*p/1000 + 0.00000*p/1000; 
    end
    if ismember(kl,[ks1 ks2 ks3 ks4])
        c1 = c1*(1 - 0 *0.0003/35);
    end
    if ismember(kl,[ks1 ks2 ks3 ks4])
        c2 = c2*(1+0*.0022/35);
    end
    
    s1 = sw_salt(c1/c35,t1,p);
    s2 = sw_salt(c2/c35,t2,p);
    
    c1a = c35*sw_cndr(s2,t1,p); % c1 required to produce salinity s2 from t1 and p. ie this is s2, seen in the space of c1,t1,p
    c2a = c35*sw_cndr(s1,t2,p); % c2 required to produce salinity s1 from t2 and p. ie this is s1, seen in the space of c2,t2,p
    
    figure(101)
    plot(1000*(t2-t1),-p,col); hold on; grid on;
    title('jc191 t2-t1')
    
    figure(102)
    plot(s2-s1,-p,col); hold on; grid on;
     title('jc191 s2-s1')
   
    figure(103)
    plot(cdef*(c1a./c1 - 1),-p,col); hold on; grid on;
    title('jc191 c1a./c1')
    
    figure(104)
    plot(cdef*(c2a./c2 - 1),-p,col); hold on; grid on;
    title('jc191 c2a./c2')
    
    figure(105)
    plot(cdef*(c2./c1 - 1),-p,col); hold on; grid on;
    title('jc191 c2./c1')
    
    figure(106)
    plot(dt1dm,-p,col); hold on; grid on;
    title('jc191 dt/dT')
    
    pall = [pall; p(:)];
    t1all = [t1all; t1(:)];
    t2all = [t2all; t2(:)];
    
    
end


kuse = find(pall > 3000);

pfit = polyfit(pall(kuse),(t2all(kuse)-t1all(kuse)),1);

fprintf(1,'%s %6.3f %6.3f %s\n','t2 - t1 regression' , pfit(2)*1e3,pfit(1)*1e6,' mdeg offset and mdeg per thousand dbar');

figure(101)
% px = [0 6000];
% tx = polyval(pfit,px);
% plot(tx,-px,'r-');
set(gca,'xlim',[-5 5]);
ylabel('pressure');
xlabel('in situ temp difference, mdegC');
title({'jc191 T2 minus T1';'Stations 81:83 (k) 84:86(r)'});
set(gca,'fontsize',14);
set(gca,'linewidth',2);
set(gca,'xtick',[-5:1:5]);



