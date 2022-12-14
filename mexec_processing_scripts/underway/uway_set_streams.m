%called by uway_daily_proc
% 

[udirs, udcruise] = m_udirs;

scriptname = 'uway_daily_proc'; oopt = 'excludestreams'; get_cropt

if exist('uway_proc_list', 'var') %only from this list
    [~,iik,~] = intersect(udirs(:,1),uway_proc_list);
    udirs = udirs(iik,:);
else
    if exist('uway_excludes','var')
        [~,iie,~] = intersect(udirs(:,1), uway_excludes);
        udirs(iie,:) = [];
    end
    if exist('uway_excludep','var')
        iie = [];
        for no = 1:size(uway_excludep,1)
            if ~isempty(strfind(udirs{sno,1}, uway_excludep{no})); iie = [iie; sno]; end
        end
        udirs(iie,:) = [];
    end
end
shortnames = udirs(:,1); streamnames = udirs(:,3); udirs = udirs(:,2);
