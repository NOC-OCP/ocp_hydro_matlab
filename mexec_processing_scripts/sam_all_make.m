% sam_all_restart is a cell array containing elements to (re)make:
%   'sam' to delete sam_all file first,
%   'fir' to remake fir files (as well as pasting in to sam_all file with
%     mfir_to_sam.m), 
%   one or more parameters 'sbe35', 'sal', 'oxy', 'nut', 'co2',
%     'iso', 'cfc' to run m{parameter}_01.m (as well as
%     m{parameter}_to_sam.m), or 
%     'all' to run all of these
%   'shore' to run msam_ashore_flag

if ~exist('sam_all_restart','var')
    scriptname = mfilename; oopt = 'sam_all_restart_steps'; get_cropt
end

root_ctd = mgetdir('M_CTD'); % change working directory
otfile = fullfile(root_ctd, ['sam_' MEXEC_G.MSCRIPT_CRUISE_STRING '_all.nc']);

if sum(strcmp('sam',sam_all_restart)) && exist(otfile,'file')
    warning('deleting sam file: %s',otfile)
    delete(otfile)
end

if ~exist('klist','var') || isempty(klist)
    if ~exist('stn','var') %prompt
        stn = input('type stn number: ');
    end
    klist = stn; clear stn
else
disp('Will process stations in klist: ')
disp(klist)
end
klistl = klist(:)'; clear klist

dofir = sum(strcmp('fir',sam_all_restart));
doshore = sum(strcmp('shore',sam_all_restart));
sam_all_restart = setdiff(sam_all_restart,{'sam','fir','shore'});
if sum(strcmp('all',sam_all_restart))
    sam_all_restart = {'sbe35','sal','oxy','nut','co2','cfc','iso'};
end

for kloop = klistl

    if dofir
        stn = kloop; mfir_01
        stn = kloop; mfir_03
        %stn = kloop; mfir_03_extra
        try
        stn = kloop; mwin_to_fir
        catch; continue; end
    end

    stn = kloop; mfir_to_sam

end

for no = 1:length(sam_all_restart)
    klist = klistl;
    eval(['m' sam_all_restart{no} '_01'])
end

if doshore
    msam_ashore_flag
end

%mout_exch_sam


