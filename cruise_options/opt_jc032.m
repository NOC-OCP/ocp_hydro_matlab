switch scriptname

   %%%%%%%%%% mco2_01 %%%%%%%%%%
   case 'mco2_01'
      switch oopt
         case 'setflags'
	    ii = find(ismember(sampnum, [1317 1319])); alk_flag(ii) = 4;
      end
   %%%%%%%%%% end mco2_01 %%%%%%%%%%

   %%%%%%%%%% msec_run_mgridp %%%%%%%%%%
   case 'msec_run_mgridp'
      switch oopt
         case 'sections'
	    sections = {'bc1' 'bc2' 'bc3' 'main'};
	 case 'kstns'
	    switch section
	       case 'bc1'
	          sstring = '1:9';
               case 'bc2'
	          sstring = '10:22';
	       case 'bc3'
	          sstring = '23:35';
	       case 'all'
	          sstring = '[1:47 49:118]';
	       case 'main'
	          sstring = '[23:35 37:47 49:118]';
	    end
      end
   %%%%%%%%%% end msec_run_mgridp %%%%%%%%%%
      
   
                %%%%%%%%%% m_maptracer %%%%%%%%%%
    case 'm_maptracer'
        switch oopt
            case 'kstatgroups'
                kstatgroups = {[1:9] [10:22] [23:200]};
        end
        %%%%%%%%%% end m_maptracer %%%%%%%%%%

end