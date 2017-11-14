scriptname = 'ctd_all_part1';

if ~exist('stn','var')
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);

stnlocal = stn;

clear stn % so that it doesn't persist

% notes added bak and ylf at start of jr306 jan 2015
% if/else added ylf jr15003
if stnlocal==1 | ~exist([MEXEC_G.MEXEC_DATA_ROOT '/ctd/sam_' MEXEC_G.MSCRIPT_CRUISE_STRING '_template.nc'], 'file')
   stn = stnlocal; msam_01; % create empty sam file at start of cruise
   eval(['!cp sam_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' stn_string '.nc sam_' MEXEC_G.MSCRIPT_CRUISE_STRING '_template.nc']) %copy to template
else
    stn = stnlocal; msam_01b; % copy template for this station number (empty at present)
end

stn = stnlocal; mctd_01;
stn = stnlocal; mctd_02a;
stn = stnlocal; mctd_02b;

stn = stnlocal; mctd_03;

stn = stnlocal; msam_putpos; % jr302 populate lat and lon vars in sam file

stn = stnlocal; mdcs_01; % on jr306 make all these files at start of cruise
stn = stnlocal; mdcs_02;
