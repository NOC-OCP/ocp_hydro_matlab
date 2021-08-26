

scriptname = 'msal_plot_autosal_standards_jc191';
%clear all
% need to run mload 'sal_jc191_01' first 
%msal_01_jc191_real_all_with_dnum;

% this contains the offsets for each crate 
msal_01_jc191_read_all_with_dnum, 'sal_jc191_01.csv';
% this contains all the data 
d = mload('/local/users/pstar/jc191/mcruise/data/ctd/BOTTLE_SAL/sal_jc191_01.nc','/');


k = find(d.sampnum > 999000 & d.sampnum < 999999);

% temp = [
%  1 23.5 
%  2 23.3 
%  3 23.3 
%  4 23.3 
%  5 23.2 
%  6 23.2 
%  7 24.8 
%  8 24.8 
%  9 24.1 
%  10 24.1
%  11 23.9 
%  12 23.9 
%  13 24.3 
%  14 24.3 
%  15 23.3
%  16 23.5 
%  17 23.5 
%  18 24.0
%  19 24.5 
%  20 24.6
%  21 23.8
%  22 23.8
%  23 24.8
%  24 25.0
%  26 24.4 
%  27 25.1
%  29 26.4 
%  30 25.9
%  31 23.7
%  32 23.9
%  33 24.1 
%  34 24.8 
%  35 24.5
%  36 24.4
%  37 24.8
%  38 25.3
%  39 24.9
%  40 24.8
%  41 23.4 
%  42 24.1 
%  43 24.2 
%  44 24.3 
%  45 25.2
%  46 25.4 
%  47 25.1 
%  48 25.2
%  49 25.3
%  50 25.3
%  51 25.0
%  52 26.8
%  53 24.8
%  54 24.9
%  55 25.2
%  56 25.0
%  57 27.5
%  58 29.1
%  59 25.5
%  60 26.0
%  61 25.9
%  62 25.2
%  63 25.5
%  64 25.5
%  65 25.1
%  66 25.2
%  67 25.3
%  68 22.0
%  69 22.3
%  70 23.6
%  71 25.2
%  72 25.5
%  73 23.9
%  74 23.9
%  75 22.3
%  76 22.7
%  77 23.2
%  78 23.2
%  79 23.2
%  80 22.6
%  81 23.4
%  82 24.0
%  83 22.9
%  84 22.9
%  85 24.1
%  86 23.8
%  87 22.5 
%  88 22.6
%  89 23.0
%  90 23.1
%  91 22.9
%  92 22.9
%  93 22.6
%  94 22.5
%  95 23.3
%  96 23.2
%  97 22.6
%  98 22.6
%  99 23.0
%  100 22.9
%  101 23.9
%  102 25.1
%  103 24.8
%  104 24.9
%  105 26.1
%  106 24.9
%  107 25.1
%  108 24.8 
%  109 24.9
%  110 24.5
%  111 24.5
%  112 25.0 
%  113 25.2
% ];
 
 
% want to go through dsamp num and find everything less than 999000 which
% is just the niskin bottles
ctd_bottles_index = find(d.sampnum < 999000);
ctd_bottles = d.sampnum(ctd_bottles_index); 

ctd_vec = []; % random initalising 
%std_res = round((1.99970 - d.runavg(k))*10^5);

count = 1; 
% this loop finds all the ctd numbers and puts them in an array
for kl = 1 : length(ctd_bottles)

    y = num2str(ctd_bottles(kl));

    if length(y) == 3                  % turns the niskin bottle number into just the stat num
        ctd = str2double(y(1));
    elseif length(y) == 4
        ctd = str2double(y(1:2));
    elseif length(y) == 5
        ctd = str2double(y(1:3));
    end

    if (sum(ctd == ctd_vec) == 0) % has this number already gone in?
        ctd_vec(count*2-1) = ctd;
        ctd_vec(count*2) = ctd;
        ctd_bottle_vec(count) = ctd_bottles(kl); % this vector will be half the size and will just have ...
                                                 %the first bottle number
        count = count + 1;
    else
    end

end

% this loop will find the standards either side of the ctd

index = 1;

for kl = 1 : length(ctd_bottle_vec)

    lookat = ctd_bottle_vec(kl);
    lookat_index = find(d.sampnum == lookat); % find in the main list where this bottle sits
    std_index_vec_1 = find(d.sampnum(1:lookat_index) > 999000); % findng the standard before it
    std_index_vec_2 = find(d.sampnum(lookat_index:end) > 999000); % finding the standard after it
    
   
    std_index_1 = std_index_vec_1(end);
    std_index_2 = std_index_vec_2(1);
    
    % the find function will count where it starts as 1, need to add on
    % where it's been 
    index = std_index_2 + lookat_index -1;

    std_vec(kl*2-1) = d.sampnum(std_index_1);       % this is putting the standard numbers for each stn
    std_vec(kl*2) = d.sampnum(index(1));            % choose the first if it finds the bottle twice
    std_res(kl*2-1) = d.runavg(std_index_1);        % putting in the residuals associated with each stn
    std_res(kl*2) = d.runavg(index(1));

end

std_res = round((1.99970 - std_res)*10^5);  % turning into a residual that you can understand


% this loop just extracts niskin numbers from a_adj without bottle numbers
for kl = 1 : length(g_adj)

    % converts the first column of a_adj into a bottle number 
    y = num2str(g_adj(kl,1));
    if length(y) == 3
        adj_crate_num(kl) = str2double(y(1));
    elseif length(y) == 4
        adj_crate_num(kl) = str2double(y(1:2));
     elseif length(y) == 5
        adj_crate_num(kl) = str2double(y(1:3));
    end

end

% this loop matches the ctd crate from the d.sampnum list with its
% corresponding given offset
for kl = 1 : length(ctd_vec)

    whole_list = find(ctd_vec(kl) <= adj_crate_num);
    this_index = whole_list(1);

    residual = g_adj(this_index,3);

    if (residual > 10000)            % when we had to adjust the residuals for wrong supression on auto sal
        residual = residual - 10000;
    end
    
    %     if (residual > 1000)            % when we had to adjust the residuals for wrong supression on auto sal
%         residual = residual - 10000;
%     end
    
    ctd_res(kl) = residual; % put the value into the ctd vector
end


for kl = 1 : (length(ctd_vec)/2)
    ctd_vec(kl*2) = ctd_vec(kl*2)+0.99;     % making the second value, ctd 1.99 or 31.99 so that the samples plot over

end

std_vec = std_vec - 999000; 

% temp_vec = [];
% % for loop for adding temp 
% for kl = 1 : length(ctd_vec)/2 
%     lookat_ctd = ctd_vec(kl*2-1);
%     %ctd_index = find(lookat_ctd == temp(:,1));
%     temp_index = find(temp(:,1) == lookat_ctd);
%     temp_vec(2*kl) = temp(temp_index, 2);
%     temp_vec(2*kl-1) = temp(temp_index, 2);
% end 

vec = [ctd_vec' std_vec' std_res' ctd_res'];
%vec = [ctd_vec' std_vec' std_res' ctd_res' temp_vec'];

vec = sortrows(vec); 


% 
% figure;
% grid on; hold on; 
% [hAx, hLine1 hLine2] = plotyy([vec(:,1), vec(:,1)], [vec(:,3), vec(:,4)], vec(:,1), vec(:,5)); 
% %plot(vec(:,1), vec(:,3), 'k+');
% %plot(vec(:,1), vec(:,4), 'r-', 'LineWidth', 2);
% hLine1.LineStyle = 'k+';
% hLine1.LineStyle = 'r-';
% hLine2.LineStyle = 'bo';
% % two to three then 1 to 3 
% % set limits and labels
% set(gca, 'box', 'off');
% xlim([min(ctd_vec) max(ctd_vec)]);
% %ylim([min(std_res)-1, max(std_res)+1]);
% %set(b, 'ylim', [min(offset)-1, max(offset)+1]);
% xlabel('CTD station');
% ylabel(hAx(1), 'offset applied to each crate', 'FontSize', '14');
% ylabel(hAx(2), 'temperature','FontSize', '14');
% legend('standard values', 'offset applied');
% title('AUTOSAL standards JC191');


count = 1; 
figure;
grid on; hold on; 
plot(vec(:,1), vec(:,3), 'k+', 'LineWidth', 3);
plot(vec(:,1), vec(:,4), 'r-', 'LineWidth', 3);
% for kl = 1: length(ctd_vec)/2
%    line([vec(count,1) vec(kl*2, 1)], [vec(count,4) vec(count,4)],'Color','r','LineWidth',4);
%     count = count + 2; 
% end

% two to three then 1 to 3 
% set limits and labels
set(gca, 'box', 'off', 'FontSize', 14);
xlim([min(ctd_vec) max(ctd_vec)]);
ylim([min(std_res)-1, max(std_res)+1]);
%set(b, 'ylim', [min(offset)-1, max(offset)+1]);
xlabel('CTD station', 'FontSize', 14);
ylabel('offset applied to each crate (counts)', 'FontSize', 14);
legend('standard values', 'offset applied', 'FontSize', 14);
title('AUTOSAL standards JC191', 'FontSize', 14);


cd BOTTLE_SAL; 
print -dpng autosal_standards.png;









