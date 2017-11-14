function m_verson(ncfile,increment)
% function m_verson(ncfile,increment); advance version of dataname in version file
% 
% allow user to specify version file increment. Can specify as zero when
% loading pstar files to mstar.
%
% During jc032, there were a few occasions when errors or hangs occurred
% while updating the version file. Right at the end of the cruise, the version
% file was irrecoverably corrupted and had to be rebuilt from the history
% files. This was thought to be possibly caused
% by two programs trying to access the version file simultaneously. This
% version, updated 10 Aug 2009, attempts to use a 'lock file' of a special
% name, which must exist before verson.m attempts to access the version
% file and which is temporarily renamed while the version file is in use.
% If the lock file does not exist in its default name, the program waits in
% a loop until it is made available again.
%
% Use of the lock file is controlled by variable 'MEXEC_G.Muse_version_lockfile'
% set in m_setup to have value 'yes' or 'no'
%
% INPUT:
%   ncfile: structure containing filename
%   increment: numerical size of version increment, usually 1, occasionally 0
%
% OUTPUT:
%   none
%
% EXAMPLES:
%   m_verson(ncfile,1);
%
% UPDATED:
%   Initial version BAK 2008-10-17 at NOC
%   Help updated by BAK 2009-08-11 on macbook
%   Lock file handling by BAK 2009-08-11 on macbook

if nargin == 1; increment = 1; end

m_common

MEXEC.versfile = MEXEC_G.VERSION_FILE;  %at the moment, the version file is a mat file

Mversionlock = nan; % local variable
if isfield(MEXEC_G,'Muse_version_lockfile')
    if strcmp(MEXEC_G.Muse_version_lockfile,'yes')
        Mversionlock = 1; % set to unity if MEXEC_G.Muse_version_lockfile exists and is set to 'yes'
    end
end
        
if ~isnan(Mversionlock) % use lock file

    % bak after jc032: attempt at file locking to avoid multiple users writing
    % to the version file
    nowstr = datestr(now,'yyyymmdd_HHMMSS_FFF');
    randstr = sprintf('%04d',floor(9999*rand));
    [uMEXEC.status userstr] = unix('whoami'); userstr = userstr(1:end-1); % on nosea1 the whoami command is terminated with a c/r
    % bak on di346 13 jan 2010. at least twice during the cruise it appears
    % that the user lock file ends wqith 'pstar' intsead of the random
    % number. I guess this is because the userstr still contains a c/r or
    % n/l which interferes with the renaming. Therefore do a further remove
    % of CR and NL in the userstr.
    userstr(strfind(userstr,char(13))) = []; % remove CR & NL
    userstr(strfind(userstr,char(10))) = []; % remove CR & NL

    MEXEC.simplelockfile = [MEXEC.versfile(1:end-4) '_lock'];
    userlockfile = [MEXEC.simplelockfile '_' nowstr '_' userstr '_' randstr]; % this should be a unique string, including a time and a random number.

    while 1
        cmd = ['mv ' MEXEC.simplelockfile ' ' userlockfile];
        [us ur] = unix(cmd);
        if us == 0 & exist(userlockfile,'file') == 2 % successful rename of lock file
            m = 'Version lock file moved to user lock file so version file is locked: OK';
            fprintf(MEXEC_A.Mfidterm,'%s\n',m)
            break;
        end
        % else lock file isn't there, it must be in use
        m = 'Waiting for version lock file to become available';
        fprintf(MEXEC_A.Mfider,'%s\n',m)
        %     pause(0.5)
        pause(1.0)
    end

end

load(MEXEC.versfile); %contains 'datanames' which is a cell array  and 'versions' which is a double array
n = length(datanames);



file_dataname = nc_attget(ncfile.name,nc_global,'dataname');
file_version = nc_attget(ncfile.name,nc_global,'version');


kmatch = strmatch(file_dataname,datanames,'exact');

if length(kmatch) > 1
    error(['problem with multiple occurrences of dataname ' file_dataname ' in version file'])
end

if isempty(kmatch) %new dataname at this site
    index = n+1;
    datanames{index} = file_dataname;
%     versions(index) = file_version;
    new_version = 1;
else
    index = kmatch;
%     new_version = increment+max(versions(index),file_version);
    new_version = increment+versions(index);
end
% keyboard
versions(index) = new_version;
save(MEXEC.versfile,'datanames','versions');
if ~isnan(Mversionlock) % reset lock file
    cmd = ['mv ' userlockfile ' ' MEXEC.simplelockfile];
    [us ur] = unix(cmd);

    while 1
        if us == 0 & exist(MEXEC.simplelockfile,'file') == 2 & exist(userlockfile,'file') ~=2 % seems to be a successful rename of lock file
            m = 'Version lock file restored to default so version file is unlocked: OK';
            fprintf(MEXEC_A.Mfidterm,'%s\n',m);
            break
        elseif us ~=0
            m1 = 'There has been a problem restoring the version lock file in subroutine m_verson.m:';
            m20 = 'The unix rename command returned a non-zero error return code';
            m2 = 'This needs investigation and repair before any more processing is done';
            m3 = ' ';
            m4 = 'The intention in m_verson is that after updating the version file,';
            m5 = 'The user lock file, which in this case is named';
            m6 = userlockfile;
            m7 = 'should have been renamed to the default lock file name:';
            m8 = MEXEC.simplelockfile;
            m9 = 'Future calls to m_verson that share the same version file will wait in a loop until the';
            m10 = 'default lock file name exists again';
            m11 = 'In order to repair the situation, ';
            m13 = 'change directory to the directory containing the version file';
            m14 = MEXEC.versfile;
            m15 = 'and then rename the lock file as described above';
            m16 = 'It should then be safe to type the word ''return'' in response to the ''keyboard'' K>>';
            m17 = 'prompt, and the program should exit normally';
            m18 = 'The master version file, and also the version number in the data file';
            m19 = 'should both have been updated normally by this program';
            m12 = '**********';
            fprintf(MEXEC_A.Mfider,'%s\n',m3,m3,m12,m12,m12,m1,m20,m2,m3,m4,m5,m3,m6,m3,m7,m3,m8,m3,m9,m10,m3,m11,m13,m3,m14,m3,m15,m16,m17,m18,m19,m12,m12,m12)
            keyboard
            % assume the user has sorted the problem out; so exit loop
            break
        else
            % us is zero, but MEXEC.simplelockfile not there. This could be because another mstar
            % program grabbed it between the unix rename and the check for success of rename
            % pause and then go round the loop again
            m = 'Rename of version lock file after updating version appeared to be successful,';
            m1 = 'but name check failed, possibly due to use by other program. pausing for recheck';
            fprintf(MEXEC_A.Mfider,'%s\n',m,m1,' ')
            %     pause(0.5)
            pause(2.0)
        end
    end
end

nc_attput(ncfile.name,nc_global,'version',new_version);
nc_attput(ncfile.name,nc_global,'mstar_site',MEXEC_G.SITE);

return