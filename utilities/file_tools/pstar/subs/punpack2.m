function out = punpack(in)

% punpack: unpack real*5 data in pstar files
% mfile to unpack real*5 data for loading pstar files.
% Use:
%  out = punpack(in)
%
% The array in contains a series of 5-byte
% representations of real numbers, read in as characters char*5.
% The pstar status byte was skipped at read time, to make this subroutine
%  more efficient, and enable use of simple reshape.
%
% These char*5 are converted to 5 times hex*2, and then concatenated and converted to real*8.
%
%  Note that hex2num pads from real*5 to real*8 with zeros, as required for pstar real*5 files.
%
% BAK at SOC 31 March 2005

%much faster version by BAK 23 Jun 2007
%exploit knowledge of ieee real numbers, instead of matlab call to HEX2NUM,
% as in previous version of punpack.

in = uint8(in);  %force to uint8
l = length(in)/5;
in = reshape(in,5,l);
in = in';
a = double(in);  %perform arithmetic with double, so that sign is carried

% a real*8 consists of 1 sign bit; 11 exponent bits; 52 fraction bits
% a pstar real*5 is the above with the last 3 bytes discarded



% first, split byte 2 of each real*5 into 4 most and least significant bits

b2 = in(:,2);
b2_l = double((b2-8)/16); %innermost divide is with uint8; 
% this truncates the 4 right-hand bits in the byte
% leaving the 4 left hand bits in the range 0000 to 1111
b2_r = a(:,2) - 16*b2_l; %now recover the 4 right hand bits


a1 = in(:,1);
neg = find(a1 > 127);        %find where sign bit set
a(neg,1) = a(neg,1)-128;     %adjust for sign bit in first byte

% exponent is now first 12 bits, allowing us to include adjusted sign bit

e = a(:,1)*16 + b2_l - 1023;  %exponent is stored offset by 1023

f = 1 + (((a(:,5)/256 + a(:,4))/256 + a(:,3))/256 + b2_r)/16; %build fraction

out = pow2(f,e);
out(neg) = -out(neg);
return