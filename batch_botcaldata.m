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
%klistpig (pigments)
%klistiso (isotopes)
%at the end, all of the affected stations are updated in the appended file
%
%this allows you to read in bottle data from different possibly overlapping sets of
%stations without calling msam_02b or msam_updateall more than necessary

mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

%get concatenated list of stations
list_actions = {'klisttem' 'process sbe35 temperature';
    'klistsal' 'process bottle salinity';
    'klistoxy' 'process bottle oxygen';
    'klistnut' 'process nutrients';
    'klistco2' 'process CO2';
    'klistcfc' 'process transient tracers';
    'klistpig' 'process pigments';
    'klistiso' 'process isotopes'};
klistall = [];
for lno = 1:size(list_actions,1)
    if ~exist(list_actions{lno,1}, 'var')
        eval([list_actions{lno,1} ' = [];']);
    else
        eval(['klist = ' list_actions{lno,1} '(:)';']);
        klistall = [klistall klist];
        sprintf('Will %s from stations\n', list_actions{lno,2});
        disp(klist); pause(0.5)
    end
end
scriptname = 'castpars'; oopt = 'klist'; get_cropt
klist = setdiff(klist, klist_exc); %remove non-CTD casts

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
        stn = kloop; miso_02 %puts iso in sam file
    end
    
    
    stn = kloop; msam_02b %updates sample flags to match niskin flags
    stn = kloop; msam_updateall %puts sam data into sam_all file
    
end

mout_cchdo_sam
    
%sync csv files to public drive, by way of mac mini since there's no write
