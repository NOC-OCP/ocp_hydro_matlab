function m_uway_append(shortnames, udirs, days, restartu)

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
root_u = MEXEC_G.mexec_data_root;

days = days(:)';
for day = days
    for sno = 1:length(shortnames)
         if restartu && day==days(1)
             if strcmp(MEXEC_G.Mshipdatasystem, 'scs')
                delete(fullfile(root_u,'scs_mat',udirs{sno}));
            end
            warning(['clobbering ' shortnames{sno} '_' mcruise '_01.nc'])
            delete(fullfile(root_u, udirs{sno}, [shortnames{sno} '_' mcruise '_01.nc']));
         end
        mday_02(shortnames{sno}, day);
    end
end
