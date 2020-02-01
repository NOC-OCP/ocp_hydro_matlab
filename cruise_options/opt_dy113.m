switch scriptname

        %%%%%%%%%% mvad_01 %%%%%%%%%%
    case 'mvad_01'
        switch oopt
            case 'files'
                cname = 'dy113_01';
                pre1 = ['mproc/' cname '/' inst nbbstr]; %link here to version you want to use (spprocessing or postprocessing)
                datadir = [root_vmadcp '/' pre1 '/contour'];
                fnin = [datadir '/' inst nbbstr '.nc'];
                dataname = [inst nbbstr '_' mcruise '_01'];
        end
        %%%%%%%%%% end mvad_01 %%%%%%%%%%

        %%%%%%%%%% mctd_03 %%%%%%%%%%
    case 'mctd_03'
        switch oopt
            case 's_choice' %this applies to both t and c
                s_choice = 2; %sensor on fin?***
        end
        %%%%%%%%%% end mctd_03 %%%%%%%%%%


end
