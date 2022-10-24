function data_ot = mcrange(data,r1,r2)
% function data_ot = mcrange(data,r1,r2)
%
% map input array data into numerical range [r1,r2)
%
% can be used in a matlab session or called from mcalib or mcalc
%
% offset data by multiples of r2-r1 until it is in the range r1 <= data < r2
% should work OK on N-Dimensional data
% can be used as a call in mcalc or mcalib
%
% if data_in = r2, data_ot = r1;
%
% INPUT:
%   data: data to be processed
%   r1: lower limit of range
%   r2: upper limit of range
%
% OUTPUT:
%   data_ot: has same shape as data
%
% EXAMPLES:
%   head_out = mcrange(head_in,0,360);
%   head_out = mcrange(head_in,-180,180);
%
% UPDATED:
%   Initial version BAK 2008-10-17 at NOC
%   Help updated by BAK 2009-08-11 on macbook
%   Error handling by BAK 2009-08-11 on macbook
%

if nargin ~= 3
    error('mexec:mcrange:not_3_arguments','\n%s %d %s\n','Require precisely 3 arguments; only',nargin,'provided');
end

if r2 <= r1
    error('mexec:mcrange:invalid_range','\n%s%0.6g%s%0.6g%s\n','Invalid range, require r2 > r1; range limits were (',r1,',',r2,')');
end


data_ot = r1 + mod(data-r1,r2-r1);

return