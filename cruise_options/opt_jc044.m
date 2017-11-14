switch scriptname

   %%%%%%%%%% mctd_03 %%%%%%%%%%
   case 'mctd_03'
      switch oopt
         case 's_choice'
	    s_choice = 1; % default, 1 = primary
            alternate = [1:49]; % list of station numbers for which secondary is preferred
      end
   %%%%%%%%%% end mctd_03 %%%%%%%%%%

end