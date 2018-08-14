% This script automates the vmadcp processing. Three inputs are needed,
%  1) instrument type (75 or 150 Khz) 
%  2) Narrowband or broadband
%  3) dataset sequence(s).  Mosstly use one sequence at a time but 
%  also possible to process multiple sequences in one go
% To batch process follow instructions below to write sequence numbers in this script

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First stage of this script is to call unix script "vmadcp_linkscript"
% Will need to check that the paths are correctly setup for this

% Created for jc064 by Cristian Florindo Lopez. 23rd September 2011
% Edited by CFL 05/10/2011
% Edited by bak jc069 5 Feb 2012
% Edited jc103 25/4/2014
% Edited by María Dolores Pérez-Hernández 19th May 2014
% new edits allows to run the processing for each.ENX, avoiding problems due
% to PC clock
% DAS on dy039 deleted obsolete lines - see jc103 version for these - and updated comments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% YLF on jc145 to
%    clean up some redundancy
%    process all files from sequence together (since we are restarting the sequence daily
%       it's not necessary to further break it down)
%    allow presetting rather than querying for inputs (vmadcp type, sequence(s) to run)
%    allow for rerunning only calibration (angle/amplitude) step

% Make sure we have latest files
unix('vmadcp_linkscript');      % Copies raw data into rawdataseq directories

%% 0. Previous steps
%m_setup; %probably already run
m_common;
codaspaths;

scriptname = 'vmadcp_proc'
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

%% 1. Select type of vmadcp and sequence to process
if ~exist('os0'); os0 = input('What type of vmadcp? (75 or 150) '); end
if ~exist('nbb'); nbb = input('Enter narrowband (1) or broadband (2) '); end
if nbb==1
    nbbstr='nb';
    %seq=[2 3 5 6 8 9 11:17 19:25 27:33 35:46 48:52 54:61 63:65];%to run all 75kHz files in one go
else
    nbbstr='bb';
    %seq=[3:7 9 10 12 15 16 17:21 23:24 30 32 34 35 37 39:43 45:46 48 50 52:60 62 64:80];%to run all 150kHz files in one go
end

% Set path to the raw data directory
root_vmadcp = mgetdir('M_VMADCP');
dir1 = [root_vmadcp '/' mcruise '_os' num2str(os0)];
if ~exist(dir1, 'dir'); mkdir(dir1); end
rawdir = [dir1 '/rawdata'];

% select processing stage: all or calib rotation and amplitude steps only
if ~exist('doall'); doall = input('Run all quick_adcp.py steps (1) or just apply angle/amplitude calibrations (2)?'); end

% This can run all sequence numbers at the same time, in which case gautoedit is not run
% or if only one sequence is input, interactive gautoedit will be run
if ~exist('seq'); seq=input('What dataset(s)?'); end
for sq=1:length(seq)

    fl0 = sprintf('%03d',seq(sq));

    %% make directory for this sequence and sync files
    disp(['SYNCING FILES FOR SEQUENCE ' fl0])
    seqrawdir = [dir1 '/rawdata' fl0];
    if ~exist(seqrawdir); mkdir(seqrawdir); end
    
    unix(['rsync -auv ' rawdir '/*_' fl0 '_* ' seqrawdir '/']);

    %% set up processing directory tree for this sequence
    disp('MAKING A TREE DIRECTORY');
    cd(dir1)
    seqprocdir = [dir1 '/' mcruise fl0 nbbstr 'enx'];
    unix(['adcptree.py ' seqprocdir ' --datatype enx']); %edited 25/4/14 for either nb or bb
    % Creating files
    seqdbname = [mcruise fl0];

    %% Make command files: q_py.cnt or q_pyrot.cnt, and q_pyedit.cnt
    cd(seqprocdir)
    
    if doall==1
    
        disp('CREATING FILE q_py.cnt')
        % nominal instrument angle and amplitude correction
        oopt = ['aa0_' num2str(os0)]; get_cropt
        % q_py.cnt
        fid=fopen('q_py.cnt','wt');
        fprintf(fid,['# q_py.cnt is\n']);
        fprintf(fid,['## comments follow hash marks; this is a comment line\n']);
        fprintf(fid,['--yearbase ' num2str(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1)) '\n']); % ylf on jc145
        fprintf(fid,['--dbname ' seqdbname '\n']);
        fprintf(fid,['--datadir ' seqrawdir '\n']);
        %fprintf(fid,['--datafile_glob "*.LTA"\n']);
        fprintf(fid,['--datafile_glob *.ENX\n']);
        fprintf(fid,['--instname os' num2str(os0) '\n']);
        fprintf(fid,['--instclass os\n']);
        fprintf(fid,['--datatype enx\n']);
        fprintf(fid,['--auto\n']);
        fprintf(fid,['--rotate_angle ' num2str(ang) '\n']);
        fprintf(fid,['--rotate_amp ' sprintf('%10.4f',amp) '\n']);
        fprintf(fid,['--pingtype ' nbbstr '\n']);
        fprintf(fid,['--ducer_depth 6\n']);
        %fprintf(fid,['#--verbose\n']);
        fprintf(fid,['# end of q_py.cnt\n']);
        fclose(fid);

        disp('RUNNING quick_adcp.py')
	    unix('quick_adcp.py --cntfile q_py.cnt');

    elseif doall==2
    
        disp('CREATING FILE q_pyrot.cnt')
        % additional instrument angle and amplitude correction
        oopt = ['aa' num2str(os0)]; get_cropt
        % q_pyrot.cnt
        fid=fopen('q_pyrot.cnt','wt');
        fprintf(fid,['# q_pyrot.cnt is\n']);
        fprintf(fid,['## comments follow hash marks; this is a comment line\n']);
        fprintf(fid,['--yearbase ' num2str(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1)) '\n']); % ylf on jc145
        fprintf(fid,['--auto\n']);
        fprintf(fid,['--rotate_angle ' num2str(ang) '\n']);
        fprintf(fid,['--rotate_amp ' sprintf('%10.4f',amp) '\n']);
        fprintf(fid,['--steps2rerun rotate:navsteps:calib\n']);
        %fprintf(fid,['#--verbose\n']);
        fprintf(fid,['# end of q_pyrot.cnt\n']);
        fclose(fid);

        disp('RUNNING quick_adcp.py')
	    unix('quick_adcp.py --cntfile q_pyrot.cnt');
	
    end      

    if 0%sq==1 & length(seq)==1 %manual edits

        disp('CREATING FILE q_pyedit.cnt')
        % q_pyedit.cnt
        fid1=fopen('q_pyedit.cnt','wt');
        fprintf(fid1,['#q_pyedit.cnt\n']);
        fprintf(fid1,['##comments follow hash marks; this is a comment line\n']);
        fprintf(fid,['--yearbase ' num2str(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1)) '\n']);
        fprintf(fid1,['--steps2rerun apply_edit:navsteps:calib:matfiles\n']);
        fprintf(fid1,['--instname os' num2str(os0) '\n']);
        fprintf(fid1,['--auto\n']);
        fprintf(fid1,['#end of q_pyedit.cnt\n']);
        fclose(fid1);
    
        cd ('edit');
        % 8. Run GAUTOEDIT for manual editing.
        disp('MANUAL EDITING. CONTINUE PROCESSING AFTER EDITING AND LISTING TO DISK');
        gautoedit;
        go=1;
        pass=input('Enter "go" when you finish with gautoedit ');
        while pass~=1;
            pass=input('Enter "go" when you finish with gautoedit ');
        end
            
        % 9. Apply edits
        cd ..
        disp('APPLYING MANUAL EDITS: RUNNING quick_adcp.py');
        unix('quick_adcp.py --cntfile q_pyedit.cnt');

        if 0
        % 9.2 Copy .asc files into a edit_files, so they are saved and can be
        % applied if the sequence is reprocessed.
        cd ..
        if ~exist('edit_files','dir');
            disp('CREATING edit_files DIRECTORY');
            unix('mkdir edit_files');
        end
        cd ('edit_files');
        disp('CREATING A SUBDIRECTORY FOR THIS SEQUENCE');
        if ~exist(seqprocdir, 'dir')
           unix(['mkdir ' seqprocdir])
        end
        cd ..
        % disp('COPYING .ASC FILES');
        unix(['cp ' seqprocdir '/edit/*asc edit_files/' seqprocdir '/']);
        end

    end

    %% 10. Run additional matlab processing scripts
    fl = fl0; os = os0; mcod_01;
    fl = fl0; os = os0; mcod_02;
     
end
    
% 11. Append all the sequences
disp('APPENDING ALL SEQUENCES TOGETHER FOR SELECTED VMADCP TYPE');
os = os0; mcod_mapend;

%% 12. Clear variables for next row
clear fl0 os0 ang amp seq doall
