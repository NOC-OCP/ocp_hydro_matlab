function [out1, out2] = uvsd(in1, in2, varargin)
% function [u, v] = uvsd(spd, dir, 'sduv');
% function [spd, dir] = uvsd(u, v, 'uvsd'); [default]
%
% all in same coordinate system

type = 'uvsd';
if ~isempty(varargin)
    type = varargin{1};
end

switch type
    case 'uvsd'
        u = in1; v = in2;
        %u and v to speed and direction
        spd = sqrt(u.^2 + v.^2);
        dir = mcrange(atan2(u,v)*180/pi,0,360);
        out1 = spd; out2 = dir;
    case 'sduv'
        spd = in1; dir = in2;
        %speed and direction to u and v
        u = spd.*cos((90-dir)*pi/180);
        v = spd.*sin((90-dir)*pi/180);
        out1 = u; out2 = v;
end
