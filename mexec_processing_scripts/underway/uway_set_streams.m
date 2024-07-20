%called by uway_daily_proc
% 

if ~strcmp(MEXEC_G.Mshipdatasystem,'rvdas')
    [udirs, udcruise] = m_udirs; %***needs to be reworked for scs at least
else
    mrtv = mrdefine;
end

switch MEXEC_G.Mshipdatasystem
    case 'techsas'
        uway_excludes = {'posmvtss'};
    case 'rvdas'
        uway_excludes = {'gravity';'mag'};
end

opt1 = 'uway_proc'; opt2 = 'excludestreams'; get_cropt

if exist('uway_proc_list', 'var') %only from this list
    [~,iik,~] = intersect(mrtv.mstardir,uway_proc_list,'stable');
    mrtv = mrtv(iik,:);
else
    if exist('uway_excludes','var')
        [~,iie,~] = intersect(mrtv.mstardir, uway_excludes);
        mrtv(iie,:) = [];
    end
end
