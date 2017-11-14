function f(figure_number)
% function f(figure_number)
% 
% bring up figure by number
% 
% gdm jc064

if nargin<1
    figure;
    return
end

figure(str2num(figure_number))