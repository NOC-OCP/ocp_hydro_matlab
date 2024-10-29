switch scriptname

    case 'castpars'
        switch oopt
            case 'minit'
        if stn>0
            stn_string = sprintf('%03dss', stn);
        elseif stn<0
            stn_string = sprintf('%03dt', -stn);
        end
        end

        %%%%%%%%%% mvad_01 %%%%%%%%%%
    case 'mvad_01'
        switch oopt
            case 'files'
                cname = 'dy111_01';
                pre1 = ['mproc/' cname '/' inst nbbstr]; %link here to version you want to use (spprocessing or postprocessing)
                datadir = fullfile(root_vmadcp, pre1, 'contour');
                fnin = fullfile(datadir, [inst nbbstr '.nc']);
                dataname = [inst nbbstr '_' mcruise '_01'];
        end
        %%%%%%%%%% end mvad_01 %%%%%%%%%%

end
