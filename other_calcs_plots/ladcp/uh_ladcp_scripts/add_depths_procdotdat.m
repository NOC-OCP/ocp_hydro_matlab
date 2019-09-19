% add final station depths to proc.dat; first draft bak jr306 jan 2015.
% program to add the 'correct' water depths to proc.dat
% water depths from CTD station depths file.
% insert new text at start of lines containing depths.
% lines of interest are identified by presence of the word 'from'.
% lines up to word 'from' are compared to see if new text is required of
% line has already been edited.
% station number is extracted from string (eg 'j001_02) at end of line

fnin = 'proc.dat';
fnot = 'proc.dat_revised';
cruisestrlocal = 'jr306';

depfile = ['/local/users/pstar/cruise/data/station_depths/station_depths_' cruisestrlocal '.mat']; % final cruise station depths file generated as part of CTD processing

dep = load(depfile); % loads var called bestdeps; depth for station N is dep.bestdeps(N);

fidin = fopen(fnin,'r');
tlines = {};
kin = 0;
tt = 0;

while tt ~= -1
    tt = fgets(fidin);
    if tt == -1; continue; end
    kin = kin+1;
    tlines{kin} = tt;
end


fclose(fidin); % close input file, open output file
fidot = fopen(fnot,'w');


numl = length(tlines);

dstr = datestr(now,31);

for kl = 1:numl
    tline = tlines{kl};
    tline = tline(1:end-1); % remove line terminator
    
    kf = strfind(tline,'from'); % this is a line with a water depth
    
    if isempty(kf); fprintf(fidot,'%s\n',tline); continue; end % write out lines that do not require modification; don't need line terminator read in using fgets
    
    % find station number
    stnstr = tline(end-5:end-3);
    stn = str2num(stnstr);
    
    % construct extra string to insert
    addstr = ['     ' sprintf('%4.0f',dep.bestdeps(stn)) ' # <-- added from CTD bestdeps file ' dstr ' # '];
    
    % test if extra string has already been inserted; skip if old and new lines match
    % up to word 'from'
    fromind = strfind(tline,'from');
    if strncmp(addstr,tline,fromind(1)) % compare lines up to word 'from'
        newstr = tline; % do not add more text if line already seems to start with the same string
    else
        newstr = [addstr tline]; % insert nmew text at start of line
    end
    
    % write line which may or may not have been modified
    fprintf(fidot,'%s\n',newstr);
end


fclose(fidot);