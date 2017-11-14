% This script automates the vmadcp processing. Three inputs are needed,
%  1) instrument type (75 or 150 Khz) 
%  2) Narrowband or broadband
%  3) dataset sequence(s).  Mosstly use one sequence at a time but 
%  also possible to process multiple sequences in one go
% To batch process follow instructions below to write sequence numbers in this script

%% 0. Previous steps
%m_setup; %probably already run
m_common;
codaspaths;

scriptname = 'vmadcp_edit'
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

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
mcd('vmadcp');
dir1 = [MEXEC_G.MEXEC_CWD '/' cruise '_os' num2str(os0)];
rawdir = [dir1 '/rawdata'];

if ~exist('seq'); seq=input('What dataset(s)?'); end
for sq=1:length(seq)

    fl0 = sprintf('%03d',seq(sq));

    seqrawdir = [dir1 '/rawdata' fl0];

    seqprocdir = [dir1 '/' cruise fl0 nbbstr 'enx'];
    seqdbname = [cruise fl0];

    %% Make command file: q_pyedit.cnt
    cd(seqprocdir)
    
    disp('CREATING FILE q_pyedit.cnt')
    % q_pyedit.cnt
    fid1=fopen('q_pyedit.cnt','wt');
    fprintf(fid1,['#q_pyedit.cnt\n']);
    fprintf(fid1,['##comments follow hash marks; this is a comment line\n']);
    fprintf(fid1,['--yearbase ' num2str(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1)) '\n']);
    fprintf(fid1,['--steps2rerun apply_edit:navsteps:calib:matfiles\n']);
    fprintf(fid1,['--instname os' num2str(os0) '\n']);
    fprintf(fid1,['--auto\n']);
    fprintf(fid1,['#end of q_pyedit.cnt\n']);
    fclose(fid1);

    if ~exist('nonewedits') | ~nonewedits
    cd ('edit');
    % 8. Run GAUTOEDIT for manual editing.
    disp('MANUAL EDITING. CONTINUE PROCESSING AFTER EDITING AND LISTING TO DISK');
    gautoedit;
    disp('dbcont when finished with gautoedit')
    keyboard
    end
            
    % 9. Apply edits
    cd ..
    disp('APPLYING MANUAL EDITS: RUNNING quick_adcp.py');
    unix('quick_adcp.py --cntfile q_pyedit.cnt');

    if 1
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

    %% 10. Run additional matlab processing scripts
    fl = fl0; os = os0; mcod_01;
    fl = fl0; os = os0; mcod_02;
     
end
    
% 11. Append all the sequences
%disp('APPENDING ALL SEQUENCES TOGETHER FOR SELECTED VMADCP TYPE');
os = os0; mcod_mapend;

%% 12. Clear variables for next row
clear fl0 os0 ang amp seq doall
