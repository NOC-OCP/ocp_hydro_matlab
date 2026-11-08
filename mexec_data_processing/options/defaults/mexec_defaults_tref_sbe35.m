switch opt2
    case 'sbe35_files'
        foundit = true;
        infiles.sbe35_raw = fullfile(MEXEC_G.data_root, 'ctd', 'ASCII_FILES', 'SBE35', ['SBE35_' MEXEC_G.mcruise '*.asc']);
        pfiles.sbe35_all = fullfile(MEXEC_G.data_root, 'ctd', 'ASCII_FILES', 'SBE35', ['sbe35_' MEXEC_G.mcruise '_all.nc']);
        %stnind is indices in filename sbe35file normally
        %containing the station number; use negative to indicate
        %distance from end e.g. [-6:-4] for dy113_SBE35_CTD_010.asc
        %or CE26008_014.txt
        stnind = -6:-4;
    case 'sbe35_irregular_parse'
        foundit = true;
        %deal with combined files and other irregularities
        helptext = 'may add additional code here';
end
