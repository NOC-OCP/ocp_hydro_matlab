function [ot]=b1to4(in,dummy)

%convert single numbers to 4 separate bytes for writing out
%BAK at NOC 6 Feb 2006

%use a dummy second argument if it is a variable for which negative numbers must be adjusted.

in = in(:)'; %ensure row vector
in = round(in);

if nargin > 1
    %assume the number can be negative and may need to be adjusted before conversion
    k_adj = find(in < 0);
    in(k_adj) = in(k_adj)+4294967296;
end
    
r = in; d=floor(r/16777216);  %MSB
r = in-16777216*d; c= floor(r/65536);
r = r-65536*c; b = floor(r/256);
a = r-256*b;  % LSB

k_out = 4*length(in); %number of output bytes

x = [a;b;c;d];  %each column of x is now a required set of 4 bytes
ot = reshape(x,1,k_out);




