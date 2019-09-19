function y = oxy_apply_grid(oxygen,statnum)

% quick and dirty script to apply crude cal to gridded oxygen for plotting

load oxycoeff

num_stns = size(oxygen,2);


for kloop = 1:num_stns
    s_num = statnum(1,kloop);
    if s_num > length(oxycoeff); continue; end
    fac = oxycoeff(s_num);
     if isnan(fac); continue; end
    oxygen(:,kloop) = fac*oxygen(:,kloop);
end

y = oxygen;
