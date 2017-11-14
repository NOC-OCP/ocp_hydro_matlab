function n = tracer_norm(x,y,a,h,m,d,w)

% sf5 tracer norm
% 
% x vertical coord
% y data
% a amp
% h width
% m median
% w weight
kd1 = find(x <= m);
kd2 = find(x > m);

y2(kd1) = a*exp(-((x(kd1)-m)/h).*((x(kd1)-m)/h));
y2(kd2) = a*exp(-((x(kd2)-m)/d).*((x(kd2)-m)/d));

yr = y-y2(:);
n = sqrt(sum(yr.*yr.*w)/sum(w));



