function m_print_varsummary(h,lenfn,lenfu)
% function m_print_varsummary(h,lenfn,lenfu)
%
% print summary of variables to screen

% unfinished could be given arguments for width of each part of header,
% especially upr/lwr lims

if nargin == 1
% if you want to , you can change the number of chars allowed for each of
% the var name and units with the following two statements
lenfn = 15;
lenfu = 10;
elseif nargin == 2
    lenfu = 10;
end


disp('Dimension sets:');
disp('set  nrows      ncols      norecs');

for k = 1:h.numdimsets
    rn = h.rowname{k};
    suffix = rn(6:end);
    disp([sprintf('%-4s %-10d %-10d %-10d',[suffix ':'],h.rowlength(k),h.collength(k),h.rowlength(k)*h.collength(k))])
end


fnform = ['%-' sprintf('%d',lenfn) 's'];    
fuform = ['%-' sprintf('%d',lenfu) 's'];    
namestring = sprintf(fnform,'name');
unitstring = sprintf(fuform,'units');
starlong = '**********************************************************';
namestar = starlong(1:lenfn);
unitstar = starlong(1:lenfu);

disp(['*****' namestar   '*' unitstar    '**************************************************************']);
disp(['*   *' namestring '*' unitstring  '*dims*       min     *       max     *     nabs * absval     *']);
disp(['*****' namestar   '*' unitstar    '**************************************************************']);
for k = 1:h.noflds
    fn = h.fldnam{k};
    if length(fn) > lenfn
        fn = [fn(1:lenfn-1) '@'];
    end
    fu = h.fldunt{k};
    if length(fu) > lenfu
        fu = [fu(1:lenfu-1) '@'];
    end

    lwrform = '%13.3f';
    if h.alrlim(k) == h.absent(k); h.alrlim(k) = nan; end
    if abs(h.alrlim(k)) < 0.1; lwrform = '%13.3e'; end
    if abs(h.alrlim(k)) == 0; lwrform = '%11.1f  '; end
    if h.alrlim(k) > 99999999.9; lwrform = '%13.3e'; end
    uprform = '%13.3f';
    if h.uprlim(k) == h.absent(k); h.uprlim(k) = nan; end
    if abs(h.uprlim(k)) < 0.1; uprform = '%13.3e'; end
    if abs(h.uprlim(k)) == 0; uprform = '%11.1f  '; end
    if abs(h.uprlim(k)) > 99999999.9; uprform = '%13.3e'; end
    
%     disp(['*' sprintf('%3d',k) '*' sprintf('%-10s',fn) '*' sprintf('%-8s',fu) '*' sprintf('%8d',h.dimrows(k)) '*' sprintf('%8d',h.dimcols(k)) '* ' sprintf(lwrform,h.alrlim(k)) ' * ' sprintf(uprform,h.uprlim(k)) ' * ' sprintf('%6d',h.num_absent(k)) ' * ' sprintf('%10.3f',h.absent(k)) ' *']);
fuform = ['%-' sprintf('%d',lenfu) 's'];    
fnform = ['%-' sprintf('%d',lenfn) 's'];    
disp(['*' sprintf('%3d',k) '*' sprintf(fnform,fn) '*' sprintf(fuform,fu) '*' sprintf('%3s ',h.dimsset{k}) '* ' sprintf(lwrform,h.alrlim(k)) ' * ' sprintf(uprform,h.uprlim(k)) ' *' sprintf('%9d',h.num_absent(k)) ' * ' sprintf('%10.3f',h.absent(k)) ' *']);
end
disp(['*****' namestar   '*' unitstar    '**************************************************************']);




return
