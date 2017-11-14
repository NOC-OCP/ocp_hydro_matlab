function [oxygen_rev]=mcoxyhyst_reverse(oxygen_sbe,time,press,H1,H2,H3)
% function [oxygen_rev]=mcoxyhyst_reverse(oxygen_sbe,time,press,H1,H2,H3)
%
% gdm on di346
% function to reverse the adjustment for hysteresis in the oxygen sensor
% applied by SeaBird 
% 
% the default values and ranges or the constants are:
% H1     -0.033     [-0.02 to -0.05]
% H2      5000      
% H3      1450      [1200  to  2000]

oxygen_rev=oxygen_sbe;

for k=2:length(time)
    D=1+H1*(exp(press(k)/H2)-1);
    C=exp(-1*(time(k)-time(k-1))/H3);

    oxygen_rev(k)=D*(oxygen_sbe(k)-C*oxygen_sbe(k-1))+C*oxygen_rev(k-1);
    
end;