function [pos, scn] = msbe_niskins_load(infile)
%load scan and position for each rosette firing, from .bl or .btl file
[~,~,ext] = fileparts(infile);

if strcmp(ext,'.bl')
    cellall = mtextdload(infile,',',10); % load all text
    if size(cellall,2)<4
        warning('no bottles for cast %s; skipping',stn_string)
        return
    end
    nr = size(cellall,1);
    n = 1;
    pos = NaN; scn = NaN;
    for kline = 1:nr
        if ~isempty(cellall{kline,4})
            pos(n) = str2double(cellall{kline,2});
            scn(n) = str2double(cellall{kline,4});
            n = n+1;
        end
    end

elseif strcmp(ext, '.btl')
    n = 0; pos = []; scn = [];
    iis = nan; iip = nan;
    cont = true;
    fid = fopen(infile,'r');
    while cont
        s = fgets(fid);
        if ~ischar(s); break; elseif contains(s,'#') || contains(s,'*'); continue; end
        if isnan(iis) %haven't set this yet
            %first header line
            iis = strfind(s,'Scan');
            if isempty(iis); warning('no Scan in .btl file line %s; skipping', s); return; end
            iip = strfind(s,'Bottle');
            if isempty(iip); warning('no Bottle Position in .btl file line %s; skipping', s); return; end
            iis = iis-4:iis+4; %allow for a slight misalignment
            iip = iip-1:iip+3; %allow for a slight misalignment
        elseif contains(s,'avg') %or could test later for non-empty s(iip)
            %subsequently data lines
            if ~isempty(str2double(s(iip)))
                n = n+1; 
                pos(n) = str2double(s(iip)); 
                scn(n) = str2double(s(iis));
            end
        end
    end
    fclose(fid);
% elseif strcmp(ext,'.ros') %***
%     [d,h] = msbe_to_mstar(blinfile,'y','y');
%     pos = d.Position; h = d.scan;
else
    warning('bottle file type not recognised for cast %s; skipping',stn_string)
    d = []; h = []; 
    return
end

pos = pos(:);
scn = scn(:);
