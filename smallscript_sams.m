%scripts to rerun the steps that make the sam files (starts from scratch)
%
%comment out msal_01 or moxy_01 if you don't need to regenerate the sal_ or oxy_ files

scriptname = 'smallscript';
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
oopt = '';
    
if ~exist('klist'); oopt = 'klist'; get_cropt; end

disp('Will process stations in klist: ')
disp(klist)
okc = input('OK to continue (y/n)?','s');
if okc == 'n' | okc == 'N'
	return
end

%start fresh
root_sam = mgetdir('M_CTD');
%stn = 1; msam_01; % create empty sam file at start of cruise
%eval(['!cp ' root_sam '/sam_' mcruise '_001.nc ' root_sam '/sam_' mcruise '_template.nc']) %copy to template

for kloop = klist
    stn = kloop; msam_01b %copy from template

    stn = kloop; mfir_04
    stn = kloop; mwin_04

    stn = kloop; mbot_01
    stn = kloop; mbot_02
    stn = kloop; mdcs_05

    stn = kloop; msam_02b
    stn = kloop; msam_putpos
    if ~exist([root_sam '/sam_' mcruise '_all.nc'])
        unix(['cp -f ' root_sam '/sam_' mcruise '_001.nc ' root_sam '/sam_' mcruise '_all.nc'])
    else
        stn = kloop; msam_apend
    end
    
end

%msam_ashore_flag

nnisk = 1; mout_sam_csv %this makes a list in reverse niskin order
nnisk = 0; mout_sam_csv %this makes a list in deep-to-surface niskin order
