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
klist = unique(klist);

if ~exist('docsv'); docsv = 0; end

%first do steps that create concatenated (rather than per-station) mstar files

if length(klistsal)>0; msal_standardise_avg; end %loads bottle salts into .mat file (and optionally
%displays individual readings and standards offsets for evaluation)

if length(klistco2)>0; mco2_01; end %loads alk and dic into concatenated co2 file

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
        stn = kloop; mco2_01 %puts carbon in co2 file
        stn = kloop; mco2_02 %puts carbon in sam file
    end
    
    %cfcs
    if ismember(kloop, klistcfc)
        stn = kloop; mcfc_02 %puts cfcs in sam file
    end

    
    %stn = kloop; msam_02b %updates sample flags to match niskin flags
    stn = kloop; msam_updateall %puts sam data into sam_all file

    if 0%docsv
       %csv files
       mout_makelists(kloop, 'nutsodv');
       mout_makelists(kloop, 'allpsal');
    end

end

%nnisk = 1; mout_sam_csv %this makes a list in reverse niskin order
%nnisk = 0; mout_sam_csv %this makes a list in deep-to-surface niskin order
%unix(['cp /local/users/pstar/cruise/data/samlists/* /local/users/pstar/cruise/data/legwork/scientific_work_areas/ctd/csv_ctd_sam/']);
%   mout_cchdo_sam

