returnscriptname = 'ctd_all_part1';
minit

if 1 %jc159 all done at the start
   % make empty sam file
   % notes added bak and ylf at start of jr306 jan 2015
   % if/else added ylf jr15003
   if ~exist([MEXEC_G.MEXEC_DATA_ROOT '/ctd/sam_' mcruise '_template.nc'], 'file')
      stn = stnlocal; msam_01; % create empty sam file at start of cruise
      eval(['!cp ' MEXEC_G.MEXEC_DATA_ROOT '/ctd/sam_' mcruise '_' stn_string '.nc ' MEXEC_G.MEXEC_DATA_ROOT '/ctd/sam_' mcruise '_template.nc']) %copy to template
      eval(['!cp ' MEXEC_G.MEXEC_DATA_ROOT '/ctd/sam_' mcruise '_' stn_string '.nc ' MEXEC_G.MEXEC_DATA_ROOT '/ctd/sam_' mcruise '_all.nc']) %copy to template
   else
       stn = stnlocal; msam_01b; % copy template for this station number (empty at present)
   end
end

stn = stnlocal; mctd_01; %read in sbe .cnv data to mstar
stn = stnlocal; mctd_02a; %rename variables following templates/ctd_renamelist.csv

%ylf added jc159: check for out-of-range pressures that will cause trouble
%in mctd_03
root_ctd = mgetdir('M_CTD');
[d, h] = mload([root_ctd '/ctd_' mcruise '_' stn_string '_raw'], '/');
if min(d.press)<=-10
    disp(['negative pressures in ctd_' mcruise '_' stn_string '_raw'])
    disp(['check ctd_' mcruise '_' stn_string '_raw; if there are large'])
    disp(['spikes, edit opt_' mcruise ' mctd_01 case and reprocess this station'])
    disp(['if not too large, edit mctd_rawedit case so that out-of-range'])
    disp(['values will be removed; run mctd_rawedit here and return to continue'])
    disp(['(note this will only apply automatic edits; you will still need to'])
    disp(['run mctd_rawedit again after ctd_all_part2 to go through the GUI editor)'])
    keyboard
end
stn = stnlocal; mctd_02b; %apply corrections (e.g. oxygen hysteresis)

stn = stnlocal; mctd_03; %average to 1 hz, compute salinity

stn = stnlocal; msam_putpos; % jr302 populate lat and lon vars in sam file

stn = stnlocal; mdcs_01; % on jr306 make all these files at start of cruise
stn = stnlocal; mdcs_02;

mout_1hzasc(stnlocal) %output 1 hz data in ascii format (required for LDEO IX LADCP processing)

