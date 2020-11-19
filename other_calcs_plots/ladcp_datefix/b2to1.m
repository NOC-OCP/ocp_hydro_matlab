function [ot]=b2to1(in,dummy)

%convert  2 separate bytes to a single number 
%BAK at NOC 6 Feb 2006

%use a dummy second argument if it is a variable for which negative numbers must be adjusted.

in = in(:)'; %ensure row vector

a = in(1:2:end);  %LSB
b = in(2:2:end);  %MSB
ot = a+b*256;


if nargin > 1
    %assume the number can be negative and may need to be adjusted
    k_adj = find(ot > 32767); %for this kind of variable, these numbers are negative
    ot(k_adj) = ot(k_adj) - 65536;
end