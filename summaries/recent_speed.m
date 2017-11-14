function recent_speed(varargin)
%jc069 while doing towyo

t2 = now;
if nargin == 0
    deltat = 120;
    gap = 60;
elseif nargin == 1
    deltat = str2num(varargin{1});
    gap = 60
else
    deltat = str2num(varargin{1});
    gap = str2num(varargin{2});
end

while 1

    t2 = t2-1/1440;
    t1 = t2-deltat/86400;
    [lat1 lon1] = mtposinfo(t1);
    [lat2 lon2 ] = mtposinfo(t2);

    [dist angle] = sw_dist_original([lat1 lat2],[lon1 lon2],'nm');

    spd = 3600*dist/deltat; %knots
    hdg = 90-angle;

    fprintf(1,'%s ',datestr(t2,31));
    mess = ['Speed over last ' sprintf('%5.0f',deltat) ' seconds was ' sprintf('%4.1f',spd) ' knots on heading ' sprintf('%5.1f',hdg)];
    fprintf(1,'%s\n',mess)

    while 2
        tnow = now;
        day = floor(tnow);
        daypart = tnow-day;
        daysecs = floor(daypart*86400);
        if rem(daysecs,gap) < 5
            t2 = day+daysecs/86400;
            break
        else
            pause(2)
        end
    end
end
