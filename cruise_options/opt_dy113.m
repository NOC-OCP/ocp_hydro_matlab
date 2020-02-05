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
            case 'o_choice'
                o_choice = 1;
        end
        %%%%%%%%%% end mctd_03 %%%%%%%%%%
        
        
                %%%%%%%%%% populate_station_depths %%%%%%%%%%
    case 'populate_station_depths'
        switch oopt
            case 'fnin'
                fnin = [root_ctddep '/station_depths_' mcruise '.txt'];
                depmeth = 3; %calculate from ctd data ***change this to ladcp***
            case 'bestdeps'
        end
        %%%%%%%%%% end populate_station_depths %%%%%%%%%%

          %%%%%%%%%% mout_sam_csv %%%%%%%%%%
  case 'mout_sam_csv'
      switch oopt
          case 'morefields'
      fields = fields0;
      end


end
