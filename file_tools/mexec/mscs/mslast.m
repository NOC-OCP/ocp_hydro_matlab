function [pdata punits] = mslast(instream)
% function [data units] = mslast(instream)
%
% first draft by BAK on JC032
%
% Get the last data cycle from a file.
% If there are output arguments in the call, the results are printed to the
% screen. In that case use a semicolon to supress the echo of the output argument to the
% screen.
%
%
% Examples of use:
%
% mtlast position-Applanix_GPS_JC1.gps;
% mtlast posmvpos;
% mtlast('posmvpos');
% [data units] = mtlast('posmvpos');
%
% The instream can be either a scs stream name or its mexec short form
% the data and units are returned as arguments.
%
% 8 Sep 2009: SCS version of original techsas script, for JR195
% The searched directory is MEXEC_G.uway_root, which for example can be
% /data/cruise/jcr/20090310/scs_copy/Compress
% The var names and units are taken from ascii file
% seatex-gga.TPL
% for example.
%
% 2009-09-22 fixed at noc to work with either standard (comma delimited) or 
% sed-revised (space delimited) ACO files

m_common
tstream = msresolve_stream(instream);

% SCS version

matnames = msgetstreamfilenames(tstream);

nm = length(matnames);
intcr = int8(sprintf('\r')); % char number 13
delim = ',';
intdelim = int8(delim);


% set up file names
faco = matnames{1};
ftpl = [faco(1:end-4) '.TPL'];
fullfaco = [MEXEC_G.uway_sed '/' faco];
fullftpl = [MEXEC_G.uway_sed '/' ftpl];

% assume only one TPL file to describe vars and units
varcells = mtextdload(fullftpl);
numdatavars = length(varcells);

vnames = cell(numdatavars,1); % empty cells
vunits = vnames;

for kloop = 1:numdatavars % parse the names and units
    vcell = varcells{kloop};
    vnames{kloop} = vcell{2};
    vunits{kloop} = vcell{3};
end

time = nan+ones(1,nm);
data_vars = nan+ones(length(vnames),nm);

for kn = 1:nm
    
    faco = matnames{kn};
    fullfaco = [MEXEC_G.uway_sed '/' faco];

    
    fid = fopen(fullfaco,'r'); % open file read only
    fseek(fid,0,1); % move to end of file
    numbytes_file = ftell(fid); % check the number of bytes at this instant
    fseek(fid,0,-1); % rewind
    line_1 = fgets(fid);
    numbytes_line = length(line_1);
    fseek(fid,numbytes_file-2*numbytes_line,-1); % move two lines before end of file
    line_end = fgets(fid); % read to the next end of line
    line_end = fgets(fid); % read next line to avoid possible problem of partial lines near end of file
    fclose(fid);
    
    % now parse the final line in this file
    
    sline = line_end;

    kcr = find(sline==intcr); sline(kcr) = []; % strip out carriage return chars
    sline(sline==intcr) = []; % strip out carriage return chars
    kdelim = find(sline==intdelim);

    sc = char(sline);
    if length(sc) == 1  % bak on jr281 dealing with case where there are no data
        %no data found apparently
    else
        % mod by bak at noc for jr195
        com = strfind(sc,',');
        if isempty(com)
            % space delimited
            f1 = '%f ';
            xx = sscanf(sc,f1,4+numdatavars);
            yyyy = xx(1); ddd = xx(3); fff = xx(4);
            data_vars(:,kn) = xx(5:end);
        else
            % comma delimited; can't simply use sscanf because oceanlogger
            % sampletime has spaces that case early truncation of sscanf.
            f1 = '%f,';
            yyyy = str2double(sc(1:kdelim(1)-1));
            ddd = str2double(sc(kdelim(2)+1:kdelim(3)-1));
            fff = str2double(sc(kdelim(3)+1:kdelim(4)-1));
            for kloop2 = 1:numdatavars
                data_vars(kloop2,kn) = str2double(sc(kdelim(3+kloop2)+1:kdelim(4+kloop2)-1));
            end
        end
        time(kn) = datenum(yyyy,1,1)+ddd+fff-1;
        % % % % %     data_vars = [];
    end
end

[tmax kmax] = max(time);

if isnan(tmax) % bak on jr281. report time = now and absent data if there are no valid data
    tmax = now;
end

dmax = data_vars(:,kmax);

% dvnow = datevec(now);
dvnow = datevec(tmax);
yyyy = dvnow(1);
doffset = datenum([yyyy 1 1 0 0 0]);
daynum1 = floor(tmax) - doffset + 1;
str1 = datestr(tmax,'yy/mm/dd');
str1a = datestr(tmax,'HH:MM:SS.FFF');


pdata.time = tmax;
punits.time = 'matlab';
fields = vnames;
for k = 1:length(fields)
    fn = fields{k};    
    fn(strfind(fn,'-')) = '_';
    fn(strfind(fn,'/')) = '_'; % bak on jr281 march 2013; emlog speed name contains a slash character
    cmd = ['pdata.' fn ' = dmax(k);']; eval(cmd);
    cmd = ['punits.' fn ' = vunits{k};']; eval(cmd);
end

if nargout > 0; return; end

fprintf(MEXEC_A.Mfidterm,'\n%s\n',tstream);
fprintf(MEXEC_A.Mfidterm,'%12s :    %8s   %03d %10s\n\n','last data cycle',str1,daynum1,str1a(1:10));

fields = fieldnames(pdata);
for k = 1:length(fields)
    fn = fields{k};
    s1 = fn;
    cmd = ['s2 = num2str(pdata.' fn ');']; eval(cmd);
    cmd = ['s3 = punits.' fn ';']; eval(cmd);
    fprintf(MEXEC_A.Mfidterm,'%30s : %12s   %15s\n',s1,s2,s3)
end


