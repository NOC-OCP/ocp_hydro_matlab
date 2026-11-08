switch opt2
    case 'techsas_form'
        foundit = true;
        uway_torg = datenum([1899 12 30 0 0 0]); % techsas time origin as a matlab datenum
    case 'ship_data_sys_names'
        foundit = true;
        tsgpre = 'tsg';
        metpre = 'met';
end
