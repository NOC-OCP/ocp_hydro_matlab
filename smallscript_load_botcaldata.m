%load calibration and/or other bottle data into Mster files, 
%and update appended sample file
%
%this script takes one or more of several variations on klist, 
%one for each type of data to load
%klisttem (temperature)
%klistsal (salinity)
%klistoxy (oxygen)
%klistnut (nutrients)
%klistco2 (carbon)
%klistcfc (tranient tracers/cfcs)
%at the end, all of the affected stations are updated in the appended file
%
%this allows you to read in bottle data from different possibly overlapping sets of 
%stations without calling msam_02b or msam_updateall more than necessary

scriptname = 'smallscript_load_botcaldata';
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

klist = [];
if exist('klisttem', 'var') & ~isempty(klisttem)
   disp('Will process sbe35 temperature from stations in klisttem: ')
   disp(klisttem)
   pause(1)
   klist = [klist klisttem];
else; klisttem = []; end
if exist('klistsal', 'var') & ~isempty(klistsal)
   disp('Will process salinity from stations in klistsal: ')
   disp(klistsal)
   pause(1)
   klist = [klist klistsal];
else; klistsal = []; end
if exist('klistoxy', 'var') & ~isempty(klistoxy)
   disp('Will process oxygen from stations in klistoxy: ')
   disp(klistoxy)
   pause(1)
   klist = [klist klistoxy];
else; klistoxy = []; end
if exist('klistnut', 'var') & ~isempty(klistnut)
   disp('Will process nutrients from stations in klistnut: ')
   disp(klistnut)
   pause(1)
   klist = [klist klistnut];
   disp('if the nutrients .csv file has more than one header line')
   disp('or if it does not have a name for the final column')
   warning('fix it now'); pause
else; klistnut = []; end
if exist('klistco2', 'var') & ~isempty(klistco2)
   disp('Will process carbon from stations in klistco2: ')
   disp(klistco2)
   pause(1)
   klist = [klist klistco2];
else; klistco2 = []; end
if exist('klistcfc', 'var') & ~isempty(klistcfc)
   disp('Will process tracers from stations in klistcfc: ')
   disp(klistcfc)
   pause(1)
   klist = [klist klistcfc];
else; klistcfc = []; end
if exist('klistiso', 'var') & ~isempty(klistiso)
   disp('Will process tracers from stations in klistiso: ')
   disp(klistiso)
   pause(1)
   klist = [klist klistiso];
else; klistiso = []; end
klist = unique(klist);

if ~exist('docsv'); docsv = 0; end

%first do steps that create concatenated (rather than per-station) mstar files

if length(klistsal)>0; msal_standardise_avg; end %checks standardisations for salinity
if length(klistco2)>0; mco2_01; end %loads alk and dic into concatenated co2 file
if length(klistiso)>0; miso_01; end %loads c13, c14, o18 into concatenated isotope file
if length(klistcfc)>0; mcfc_01; end %loads cfcs into concatenated cfc file

%now loop through stations
for kloop = klist

    %temperature
    if ismember(kloop, klisttem)
        stn = kloop; msbe35_01 %loads SBE35 temperatures into sbe35 file
        stn = kloop; msbe35_02 %puts temperature into sam file
    end
    
    %salinity
    if ismember(kloop, klistsal)
        stn = kloop; msal_01 %loads bottle salts into sal file
        stn = kloop; msal_02 %puts salt in sam file
    end
    
    %oxygen
    if ismember(kloop, klistoxy)
        stn = kloop; moxy_01 %loads bottle oxygen into oxy file
        stn = kloop; moxy_02 %puts oxygen in sam file
        stn = kloop; msam_oxykg %converts from /L to /kg based on ctd T,S
    end
    
    %nutrients
    if ismember(kloop, klistnut)
        stn = kloop; mnut_01 %loads nutrients in to nut file
        stn = kloop; mnut_02 %puts nutrients in sam file
    end
    
    %carbon
    if ismember(kloop, klistco2)
        stn = kloop; mco2_02 %puts carbon in sam file
    end
    
    %cfcs
    if ismember(kloop, klistcfc)
        stn = kloop; mcfc_02 %puts cfcs in sam file
    end

    %c14, c13, o18
    if ismember(kloop, klistiso)
        stn = kloop; mciso_02 %puts iso in sam file
    end

    
    stn = kloop; msam_02b %updates sample flags to match niskin flags
    stn = kloop; msam_updateall %puts sam data into sam_all file

    if docsv
       %csv files
       mout_makelists(kloop, 'nutsodv');
       mout_makelists(kloop, 'allpsal');
    end

end

if docsv
%   mout_sam_csv % end of jc159 no need for sam lists
   mout_cchdo_sam

   %sync csv files to public drive, by way of mac mini since there's no write
   %permission from eriu
% end of jc159 mac mini no longer is there
% % % %    unix(['rsync -auv --delete /local/users/pstar/cruise/data/collected_files/ 10.cook.local:/Volumes/Public/JC159/collected_files/']);
end
