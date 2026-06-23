function out = punpack(in)
% disp('p3')

%much faster version by BAK 23 Jun 2007
%exploit knowledge of ieee real numbers, instead of matlab call to HEX2NUM,
% as in previous version of punpack.

in = uint8(in);  %force to uint8
l = length(in)/5;
in = reshape(in,5,l);
in = in';
a = double(in);  %perform arithmetic with double, so that sign is carried

% a real * 8 consists of 1 sign bit; 11 exponent bits; 52 fraction bits
% a pstar real*5 is the above with the last 3 bytes discarded

% split array of second bytes in real*5 into 4 most and least significant
% bits

a2_l = floor(a(:,2)/16); % get the most significant part, equivalent to the 4 left hand bits
a2_r = a(:,2) - 16*a2_l; % now recover the 4 right hand bits which are part of the fraction

a1 = in(:,1);
neg = find(a1 > 127);        %find where sign bit set
a(neg,1) = a(neg,1)-128;     %adjust for sign bit in first byte

% exponent is now first 12 bits, allowing us to include adjusted sign bit

e = a(:,1)*16 + a2_l - 1023;  %exponent is stored offset by 1023

f = 1 + (((a(:,5)/256 + a(:,4))/256 + a(:,3))/256 + a2_r)/16; %build fraction

out = pow2(f,e);
out(neg) = -out(neg);
return