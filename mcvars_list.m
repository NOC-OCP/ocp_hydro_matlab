function var_copycell = mcvars_list(typ);
%function var_copycell = mcvars_list(typ);
%
%YLF JR15003
% Lists of variables to copy for ctd profiles (typ = 1)
% or bottle firing/sample files (typ = 2)
%
% It is safe to simply add to this list, because a bit of code called later
% in mctd_03, mctd_04, mfir_03, mfir_04
% removes any vars from the list that aren't found in the data files. 
    
if typ==1 % this is for ctd profiles

   var_copycell = {'scan' 'time' 'press' 'pressure_temp' ...
   'temp' 'cond' 'temp1' 'cond1' 'temp2' 'cond2' ...
   'altimeter' 'oxygen' 'oxygen1' 'oxygen2' ...
   'fluor' 'transmittance' 'fluorc' 'fluore' ... % jr15003 two fluorometers
   'par' 'par_up' 'par_dn' 'EH' 'LSS' 'BBRTD'... % light variables on jr281 or jc004
   'turbidity' ... % added di368 :turbWETbb0,turbidity,m^-1/sr
   'latitude' 'longitude' ... % added bak jc069 for ladcp processing
   'asal' 'asal1' 'asal2' 'psal' 'psal1' 'psal2' ...
   'pumps' ... % on jr306, added back jc159
   };

elseif typ==2 % this is for comparing with bottle samples

   var_copycell = {...
   'press' 'depth' ...
   'temp' 'temp1' 'temp2' ...
   'cond' 'cond1' 'cond2' ...
   'asal' 'asal1' 'asal2' ...
   'psal' 'psal1' 'psal2' ...
   'potemp' 'potemp1' 'potemp2' ...
   'oxygen1' 'oxygen2' 'oxygen' 'fluor' 'transmittance' ...
   'turbidity' ...
   'fluorc' 'fluore' ...
   'EH' 'LSS' 'BBRTD'... % light variables added on JC044
    }; 

else

   error('pick variable list type 1 or 2')

end

