switch opt2
    case 'sadcp_infiles'
        foundit = true;
        infiles.sadcp_all = fullfile(MEXEC_G.data_root, 'vmadcp', 'postprocessing', upper(MEXEC_G.mcruise), 'proc_editing', inst, 'contour', [inst '_' MEXEC_G.mcruise '.nc']);
    case 'sadcp_on_station'
        foundit = true;
        min_nvmadcpprf = 3;      %throws a warning if number of vmADCP profiles within an LADCP cast is less than this
        min_nvmadcpbin = 3;      %masks depths with number of valid bins less than this
        min_nvmadcpbin_refl = 3; %throws a warning if number of good profiles at any depth in the watertrack reference layer is less than this
end