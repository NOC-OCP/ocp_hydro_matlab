function [ot]=b1to2(in,dummy)

%convert single numbers to 2 separate bytes for writing out
%BAK at NOC 6 Feb 2006

%use a dummy second argument if it is a variable for which negative numbers must be adjusted.

in = in(:)'; %ensure row vector
in = round(in);

if nargin > 1
    %assume the number can be negative and may need to be adjusted before conversion
    k_adj = find(in < 0);
    in(k_adj) = in(k_adj)+65536;
end
    
b=floor(in/256);  %MSB
a=(in-(256*b));   %LSB
k_out = 2*length(in); %number of output bytes

x = [a;b];  %each column of x is now a required pair of bytes
ot = reshape(x,1,k_out);




