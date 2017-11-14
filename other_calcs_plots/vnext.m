thisos = 75

switch thisos
    case 150

        thisos = 150

        for thisfl = [50:55]
            fl=thisfl; os=thisos; mcod_01
            fl=thisfl; os=thisos; mcod_02
        end
        os = thisos; mcod_mapend

        stns = [90:100]
        % stns = [];


        for kstn = stns
            cast = 'ctd'; stn = kstn; os = thisos; mcod_03
            mcod_stn_out('ctd',kstn,thisos)
        end
        return

    case 75


        thisos = 75

        for thisfl = [37:45]
            fl=thisfl; os=thisos; mcod_01
            if thisfl==37; 
                !/bin/mv os75_jr306037nnx.nc os75_jr306037nnx_32rows.nc; 
                mcod_addrows;
            end
            fl=thisfl; os=thisos; mcod_02
        end
        os = thisos; mcod_mapend

        stns = [1:30]
        % stns = [];


        for kstn = stns
            cast = 'ctd'; stn = kstn; os = thisos; mcod_03
            %     cast = 'hrp02'; stn = kstn; os = thisos; mcod_03
            mcod_stn_out('ctd',kstn,thisos)
        end

        return
end