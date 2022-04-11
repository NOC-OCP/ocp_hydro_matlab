% get the list of mexec abbreviations and directories for the subset of the underway
% streams (listed in mtechsas, mscs, or mrvdas) which are available
%    for techsas and scs this relies on techsas_linkscript or sedexec_startall, respectively, having been run
%
% save this list in m_udirs.m and make directories if necessary
%
% this script will be called by m_setup if m_udirs.m is not found or does not have the current cruise name at the top
%
% subsequently, m_udirs will be used and it is not necessary to rerun this script unless
% you edit mtnames/msnames/mrnames, or new streams become available (e.g. the swath comes online partway into a cruise)
%
% you should comment out any rows which correspond to the same techsas/scs stream in mtnames/msnames
% for the ship you are on (e.g. for cook, comment out either ea600m or sim, because both are
% associated with 'EA600-EA600_JC1.EA600')

% first the names and directories list
% several short names may correspond to the same data directories, but it is not likely that
% more than 1-2 (besides quality message streams) will be in use on a given ship/cruise
udirs = muwaydirs(MEXEC_G.Mshipdatasystem);


%%%%%%% test that underway streams present match what's expected %%%%%%%
%%%%%%% and keep list of the expected streams that are found %%%%%%%
%%%%%%% and which directories they go with %%%%%%%

switch(MEXEC_G.Mshipdatasystem)
    case 'techsas'
        % based on m_check_mtnames by bak on jc184 4 july 2019 uhdas trials
        matlist = mtnames; matlist = matlist(:,[1 3]); am = matlist(:,2); % mtnames list
        as = mtgetstreams; % list of all streams found
        f = 'mtnames';
    case 'scs'
        matlist = msnames; matlist = matlist(:,[1 3]); am = matlist(:,2); %msnames list
        as = msgetstreams; %list of all streams found
        f = 'msnames';
    case 'rvdas'
        matlist = mrnames('q'); am = matlist(:,2); %mrnames list
        as = fieldnames(mrgettables); %list of tables found in database
        f = 'mrnames';
end

fprintf(2,'\n\n%s\n\n',['The following ' MEXEC_G.Mshipdatasystem ' stream names are not identified in ' f])
for kl = 1:length(as)
    if sum(strcmp(as{kl},am))==0
        fprintf(1,'%s\n',as{kl}); 
    end
end
fprintf(1,'\n%s\n\n\n\n','End of list')

fprintf(1,'%s\n\n',['The following ' f ' stream names are not found in ' MEXEC_G.Mshipdatasystem])
iim = zeros(length(am),1);
for kl = 1:length(am)
    if sum(strcmp(am{kl},as))==0
        fprintf(1,'%s\n',am{kl}); 
    else
        iid = find(strcmp(matlist{kl,1}, udirs(:,1)));
        if length(iid)>0; iim(kl) = iid; end
    end
end
fprintf(1,'\n%s\n\n','End of list')


%%%%%%% write m_udirs function using available underway streams %%%%%%%
%%%%%%% and make directories as necessary %%%%%%%

upath = fileparts(mfilename('fullpath'));
fid = fopen(fullfile(upath, 'm_udirs.m'), 'w');
fprintf(fid, '%s\n\n', 'function [udirs, udcruise] = m_udirs();');
fprintf(fid, 'udcruise = ''%s'';\n', MEXEC_G.MSCRIPT_CRUISE_STRING);
fprintf(fid, '%s\n', 'udirs = {');

for sno = 1:size(matlist,1)
    iid = iim(sno);
    if iid>0
        fprintf(fid, '''%s''    ''%s''    ''%s'';\n', udirs{iid,1}, udirs{iid,2}, matlist{sno,end});
        if ~exist(fullfile(MEXEC_G.mexec_data_root, udirs{iid,2}), 'dir')
            mkdir(fullfile(MEXEC_G.mexec_data_root, udirs{iid,2}));
        end
    end
end
matlist = matlist(iim>0,:);

%wrap up
fprintf(fid, '%s\n', '};');
fclose(fid);
