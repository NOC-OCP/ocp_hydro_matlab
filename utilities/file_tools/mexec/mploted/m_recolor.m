% jc032 script to allow changes of colormap


hall = handles;

hc = get(hall,'children');

keeplev = nan+ones(length(hc),1);
for k = 1:length(hc)
    keeplev(k) = get(hc(k),'CData');
end
%
% hc1 = hc(1);
%
% hc1_properties = get(hc1);
%
% lev = hc1_properties.CData;
% k_levindex = find(clev == lev)
% k_cmapindex = k_levindex+1
%
% set(hc1,'CDataMapping','direct')
% set(hc1,'CData',5)
% set(hc1,'linewidth',10)
clev_temp = ca(1):blocksize:ca(end);
% keyboard
for k = 1:length(hc)
    %     set(hc(k),'linewidth',3)
    newlev = max(find(clev-1e-10 < keeplev(k)));
%     if isempty(newlev)
%         newlev = min(find(clev > keeplev(k)))-2; % find index level for contour whose value is equal to datamin
%     end
    set(hc(k),'CDataMapping','direct');
    set(hc(k),'CData',newlev+ctabstart-1);
%     fprintf(MEXEC_A.Mfidterm,'%6.3f %d\n',keeplev(k),newlev+ctabstart-1);
%     keyboard
end
% keyboard