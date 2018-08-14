%add nutrients, carbon and cfcs to files, and update appended sample file

scriptname = 'botdata_all';
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

klist = [];
if exist('klistn', 'var')
   disp('Will process nutrients from stations in klistn: ')
   disp(klistn)
   pause(1)
   klist = [klist klistn];
else; klistn = []; end
if exist('klistc', 'var')
   disp('Will process carbon from stations in klistc: ')
   disp(klistc)
   pause(1)
   klist = [klist klistc];
else; klistc = []; end
if exist('klistt', 'var')
   disp('Will process tracers from stations in klistt: ')
   disp(klistt)
   pause(1)
   klist = [klist klistt];
else; klistt = []; end

scriptname = 'smallscript'; if isempty(klist); oopt = 'klist'; get_cropt; else; klist = unique(klist); end
scriptname = 'botdata_all'; oopt = '';

if ~exist('docsv'); docsv = 0; end

%carbon
if length(klistc)>0; mco2_01; end %this loads everything into a concatenated BOTTLE_CO2/co2_cruise_01.nc file

%cfcs
if length(klistt)>0; mcfc_01; end %as for carbon

if length(klistn)>0
    disp('if the nutrients .csv file has more than one header line')
   disp('or if it does not have a name for the final column')
   warning('fix it now'); pause
end

for kloop = klistn
    stn = kloop;
    stn_string = sprintf('%03d',stn);

    %nutrients
    stn = kloop; mnut_01
    stn = kloop; mnut_02
end

for kloop = klistc
    %carbon
    stn = kloop; mco2_02
end

for kloop = klistt
    %cfc
    stn = kloop; mcfc_02
end

for kloop = klist
    stn = kloop; msam_02b
    stn = kloop; msam_updateall %if only a few stations have been updated
    
    if docsv
       %csv files
       mctd_makelists(kloop, 'nutsodv');
       mctd_makelists(kloop, 'allpsal');
    end

end

if docsv
   revnisk = 0; mout_sam_csv
   revnisk = 1; mout_sam_csv

   %sync csv files to public drive, by way of mac mini since there's no write
   %permission from eriu
   unix(['rsync -av /local/users/pstar/cruise/data/collected_files/samlists/ 10.cook.local:/Volumes/Public/JC159/water_sample_data_logs/samlists/']);
end

