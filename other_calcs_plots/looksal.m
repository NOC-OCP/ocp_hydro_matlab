d3 = mload('sam_jc159_003','/');
d4 = mload('sam_jc159_004','/');

d = d3;

s1 = d.upsal1;
s2 = d.upsal2;
b1 = d.botpsal;
w = d.wireout;

fprintf(1,'%10s %10s %10s %10s %10s\n','bot','psal2','psal2-bot','psal2-psal1','wireout');

for kl = 1:24
    fprintf(1,'%10.3f %10.3f %10.3f %10.3f %10.0f \n',b1(kl),s2(kl),s2(kl)-b1(kl),s2(kl)-s1(kl),w(kl))
end

d = d4;

s1 = d.upsal1;
s2 = d.upsal2;
b1 = d.botpsal;
w = d.wireout;

fprintf(1,'%10s %10s %10s %10s %10s\n','bot','psal2','psal2-bot','psal2-psal1','wireout');

for kl = 1:24
    fprintf(1,'%10.3f %10.3f %10.3f %10.3f %10.0f \n',b1(kl),s2(kl),s2(kl)-b1(kl),s2(kl)-s1(kl),w(kl))
end
