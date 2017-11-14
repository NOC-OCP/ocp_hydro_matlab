switch scriptname

   %%%%%%%%%% vmadcp_proc %%%%%%%%%%
   case 'vmadcp_proc'
      switch oopt
         case 'aa75'
	    ang = 0.6; %%% DAS based on calibration from first day of bottom track
	    amp = 1.01;
	 case 'aa150'
	    ang = 0.2; %%% DAS based on calibration from first day of bottom track
	    amp = 1.00;
      end
   %%%%%%%%%% end vmadcp_proc %%%%%%%%%%

end