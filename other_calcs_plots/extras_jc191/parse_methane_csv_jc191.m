% bak jc191 parse the metahe csv file to discover sample depths

fnin = '/local/users/pstar/cruise/data/ctd/BOTTLE_CH4/ch4_jc191_all.csv';
fnot = '/local/users/pstar/cruise/data/ctd/BOTTLE_CH4/ch4_jc191_sampnums.txt';
fnot2 = '/local/users/pstar/cruise/data/ctd/BOTTLE_CH4/ch4_jc191_stations.txt';

fid = fopen(fnin,'r');

txtall = {};

while 1
    txt = fgetl(fid);
    if (~ischar(txt)); break; end
    txtall = [txtall {txt}];
end

fclose(fid);

fidout = fopen(fnot,'w');
fidout2 = fopen(fnot2,'w');

nlines = length(txtall);

kstart = find(strncmp('JC191',txtall,5)); % station blocks start here
kend = [kstart(2:end)-1 nlines]; % end of each station block

nstations = length(kstart);

statnums = nan(nstations,1);

for kstat = 1:nstations
    txtstn = txtall(kstart(kstat):kend(kstat));
    kbad = [];
    botnums = [];
    
    for kl = 1:length(txtstn)
        txt = txtstn{kl};
        kst = strfind(txt,'STATION');
        if ~isempty(kst); knumline = kl; numline = txt; end
    end
    
    %     now try to get the number out of numline
    kcom = strfind(numline,',');
    str1 = numline(kcom(1)+1:kcom(2)-1);
    str2 = numline(kcom(2)+1:kcom(3)-1);
    
    % possible formats are 
    % CTDnn
    % nn
    % CTD,nn
    
    str1(strfind(str1,'C')) = [];
    str1(strfind(str1,'T')) = [];
    str1(strfind(str1,'D')) = [];
    if ~isempty(str1); 
        statnums(kstat) = str2num(str1); 
    else
        statnums(kstat) = str2num(str2);
    end
    
    
    
    for kl = 1:length(txtstn)
        txt = txtstn{kl};
        kcom = strfind(txt,',');
        str = txt(kcom(3)+1:kcom(4)-1);
        if isempty(str); kbad = [kbad kl]; end
    end
    txtstn(kbad) = [];
    
    for kl = 1:length(txtstn)
        txt = txtstn{kl};
        knis = strfind(txt,'Niskin');
        if ~isempty(knis); khead = kl; end 
    end
    
    % khead is now the start of the data
    
    for kl = khead:length(txtstn);
        txt = txtstn{kl};
        kcom = strfind(txt,',');
        str = txt(kcom(3)+1:kcom(4)-1);
        botnum = str2num(str);
        botnums = [botnums; botnum];
    end
    
    for kl = 1:length(botnums)
        sampnum = statnums(kstat)*100+botnums(kl);
        fprintf(fidout,'%d\n',sampnum);
    end
    fprintf(fidout2,'%d\n',statnums(kstat));

end

fclose(fidout);
fclose(fidout2);
