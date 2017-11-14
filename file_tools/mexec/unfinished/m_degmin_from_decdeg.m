function [deg min] = m_degmin_from_decdeg(dec)
% function [deg min] = m_degmin_from_decdeg(dec)
%
% return degrees and decimal minutes from decimal degrees
% if input is negative, only degrees of output is negative
% quick on jc032 by BAK

s = sign(dec);

kn = find(s<0);
dec(kn) = -dec(kn);

deg = floor(dec);
min = 60*(dec-deg);

kz = find(deg == 0 & s < 0);
deg(kz) = deg(kz) + 1e-10; % ensure negative hemisphere zeros can be printed as "-0" using %f6.0
deg(kn) = -deg(kn);
