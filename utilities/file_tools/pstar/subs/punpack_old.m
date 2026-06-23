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

n = length(in); %array 'in' should be an exact multiple of 5 bytes.

call = sprintf('%02x',in);

c = reshape(call,10,n/5)';

out = hex2num(c)';

return
