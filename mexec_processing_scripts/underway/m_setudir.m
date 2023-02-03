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



%%%%%%% test that underway streams present match what's expected %%%%%%%
%%%%%%% and keep list of the expected streams that are found %%%%%%%
%%%%%%% and which directories they go with %%%%%%%

isrvdas = 0;
scriptname = 'ship'; oopt = 'datasys_best'; get_cropt

switch(shipdatasystem)
    case 'techsas'
        % based on m_check_mtnames by bak on jc184 4 july 2019 uhdas trials
        matlist = mtnames; matlist = matlist(:,[1 3]); am = matlist(:,2); % mtnames list
        as = mtgetstreams; % list of all streams found
        f = 'mtnames';
        udirs = muwaydirs(shipdatasystem);
    case 'scs'
        matlist = msnames; matlist = matlist(:,[1 3]); am = matlist(:,2); %msnames list
        as = msgetstreams; %list of all streams found
        f = 'msnames';
        udirs = muwaydirs(shipdatasystem);
    case 'rvdas'
        d = mrdefine('this_cruise','has_mstarpre'); 
        matlist = d.tablemap(ismember(d.tablemap(:,2),d.mrtables_list),:);
        isrvdas = 1;
end

if ~isrvdas
    fprintf(2,'\n\n%s\n\n',['The following ' shipdatasystem ' stream names are not identified in ' f])
    for kl = 1:length(as)
        if sum(strcmp(as{kl},am))==0
            fprintf(1,'%s\n',as{kl});
        end
    end
    fprintf(1,'\n%s\n\n\n\n','End of list')

    fprintf(1,'%s\n\n',['The following ' f ' stream names are not found in ' shipdatasystem])
    m = zeros(length(am),1);
    for kl = 1:length(am)
        if sum(strcmp(am{kl},as))==0
            fprintf(1,'%s\n',am{kl});
        else
            iid = find(strcmp(matlist{kl,1}, udirs(:,1)));
            if ~isempty(iid); m(kl) = iid; end
        end
    end
    fprintf(1,'\n%s\n\n','End of list')
else
    m = ones(size(matlist,1),1);
end

%%%%%%% write m_udirs function using available underway streams %%%%%%%
%%%%%%% and make directories as necessary %%%%%%%

upath = fileparts(mfilename('fullpath'));
fid = fopen(fullfile(upath, 'm_udirs.m'), 'w');
fprintf(fid, '%s\n\n', 'function [udirs, udcruise] = m_udirs()');
fprintf(fid, 'udcruise = ''%s'';\n', MEXEC_G.MSCRIPT_CRUISE_STRING);
fprintf(fid, '%s\n', 'udirs = {');


for sno = 1:size(matlist,1)
    iid = m(sno);
    if iid>0
        if isrvdas
            sn = matlist{sno,1};
            if sum(strncmp(sn,{'dop','pos','vtg','hdt','att','rot'},3))
                dn = ['nav/' sn(4:end)];
            elseif strncmp(sn,'singleb',7)
                dn = 'bathy/singleb';
            elseif strncmp(sn,'multib',6)
                dn = 'bathy/multib';
            elseif strncmp(sn,'wind',4)
                dn = ['met/' sn(5:end)];
            elseif sum(strncmp(sn,{'env','sky','dew','prs','rad'},3))
                dn = ['met/' sn(4:end)];
            elseif strncmp(sn, 'surfmet', 7)
                dn = 'met/surfmet';
            elseif strncmp(sn, 'tsg', 3)
                dn = 'met/tsg';
            elseif strncmp(sn, 'gravity', 7)
                dn  = ['uother/' sn];
            elseif strncmp(sn, 'log', 3)
                dn = ['uother/' sn(4:end)];
            elseif strncmp(sn, 'mag', 3)
                dn = ['uother/' sn];
            elseif strncmp(sn, 'svel', 4)
                dn = ['uother/' sn];
            elseif strncmp(sn, 'winch', 5)
                dn = 'ctd/WINCH';
            end
            a = str2double(dn(end-1)); b = str2double(dn(end));
            if (isfinite(b) && isreal(b)) && (~isfinite(a) || ~isreal(a))
                dn = dn(1:end-1);
            end
        else
            sn = udirs{iid,1}; dn = udirs{iid,2};
        end
        fprintf(fid, '''%s''    ''%s''    ''%s'';\n', sn, dn, matlist{sno,end});
        if ~exist(fullfile(MEXEC_G.mexec_data_root, dn), 'dir')
            mkdir(fullfile(MEXEC_G.mexec_data_root, dn));
        end
    end
end
matlist = matlist(m>0,:);

%wrap up
fprintf(fid, '%s\n', '};');
fclose(fid);
