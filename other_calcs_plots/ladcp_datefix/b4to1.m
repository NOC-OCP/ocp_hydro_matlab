function [ot]=b4to1(in,dummy)

%convert  2 separate bytes to a single number 
%BAK at NOC 6 Feb 2006

%use a dummy second argument if it is a variable for which negative numbers must be adjusted.

in = in(:)'; %ensure row vector

a = in(1:4:end);  %LSB
b = in(2:4:end);  %MSB
c = in(3:4:end);  %LSB
d = in(4:4:end);  %MSB
ot = a + 256 * ( b + 256 * ( c + 256* d));


if nargin > 1
    %assume the number can be negative and may need to be adjusted
    k_adj = find(ot > 2147483647); %for this kind of variable, these numbers are negative
    ot(k_adj) = ot(k_adj) - 4294967296;
end