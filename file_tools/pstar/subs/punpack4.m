function out = punpack(in)
% disp('p3')

fid = fopen('/users/bak/wkk','r+');


%much faster version by BAK 23 Jun 2007
%exploit knowledge of ieee real numbers, instead of matlab call to HEX2NUM,
% as in previous version of punpack.

in = uint8(in);  %force to uint8
l = length(in)/5;

in = in(:)';

z = uint8(0);
kk = 0;
o = [];
for k = 1:l
    oo = [in(kk+1:kk+5) z z z];
    kk = kk+5;
    o = [o oo];
end
fwrite(fid,o,'uint8');
fseek(fid,0,-1);
out = fread(fid,l,'double');
% if l > 1 ; keyboard; end
fclose(fid);

return
