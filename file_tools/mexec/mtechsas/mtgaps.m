function mtgaps(instream,g,dn1,dn2)
% function mtgaps(instream,g,dn1,dn2)
%
% USE, eg
%   mtgaps('posmvpos',5,[2009 4 4],[2009 5 4 12 0 0],'q')
%   mtgaps posmvpos                  % all gaps over 5 seconds
%   mtgaps posmvpos 10 '[2009 4 4]'  % from 4 April until now
%   mtgaps posmvpos 10 '2009 4 4'    % from 4 April until now
%   mtgaps winch 10 now-.5           % approximatley the last 12 hrs of data
% search for gaps in techsas data
% instream is a techsas stream name or mexec short name.
% dn1 and dn2 are matlab datenums or datevecs that define the required 
% data period
% g is the search threshold in seconds
% note silent mode; use 'q' to suppress dfinfo output to the screen;
% Data are loaded from all relevant techsas files with matching stream
% name.
% g defaults to 5 seconds
% dn1 defaults to the earliest time in the stream
% dn2 defaults to matlab 'now'
% first draft by BAK on JC032


m_common
tstream = mtresolve_stream(instream);
% convert datevecs to nums; if the arguments are datenums nothing is
% changed

if ~exist('g','var'); g = 5; end  % look for gaps > 5 seconds by default
if ischar(g); g = str2num(g); end % g comes in as a char if it is simply typed on the command line

[mt1, mt2] = mtgetdfinfo(tstream,'f'); % get time limits in case they are required for default

if ~exist('dn1','var'); dn1 = mt1; end
if isempty(dn1); dn1 = mt1; end
if ischar(dn1); cmd =['dn1 = [' dn1 '];']; eval(cmd); end % if the arg has come in as a string, convert from char to number
if ~exist('dn2','var'); dn2 = now; end
if isempty(dn2); dn2 = now; end
if ischar(dn2); cmd =['dn2 = [' dn2 '];']; eval(cmd); end

dn1 = datenum(dn1);
dn2 = datenum(dn2);


% get file names
fnames = mtchoosefiles(tstream,dn1,dn2);
nf = length(fnames);


% identify parts of files to load

dc1 = nan+ones(nf,1); dc2 = dc1; totdc = 0;
m = 'Counting data cycles';
if ~MEXEC_G.quiet; fprintf(MEXEC_A.Mfidterm,'%s\n',m); end

for kf = 1:nf
    fn = fnames{kf};
    fullfn = fullfile(uway_root, fn);
    [dc1(kf), dc2(kf)] = mtgetdcrange(fn,dn1,dn2);
    totdc = totdc + dc2(kf)-dc1(kf)+1;
end
       
m = [sprintf('%d',totdc) ' data cycles found in ' sprintf('%d',nf) ' files'];
if ~MEXEC_G.quiet; fprintf(MEXEC_A.Mfidterm,'%s\n',m); end

% now load data

vuse = nan+ones(1,totdc);
kount = 0;
m = ['loading variable ' 'time'];
if ~MEXEC_G.quiet; fprintf(MEXEC_A.Mfidterm,'%s\n',m); end

scriptname = 'ship'; oopt = 'datasys_best'; get_cropt
for kf = 1:nf
    fn = fnames{kf};
    fullfn = fullfile(uway_root, fn);
    nk = dc2(kf)-dc1(kf)+1; % load this many data cycles on this operation
    vin = nc_varget(fullfn,'time',dc1(kf)-1,nk);
    vuse(kount+1:kount+nk) = vin;
    kount = kount+nk;
end

ttime = vuse;
mtime = uway_torg + ttime;
mtime = [dn1 mtime(:)' dn2];
dtime = diff(mtime)*86400; % time difference in seconds
kgaps = find(dtime > g);
ng = length(kgaps);
dvnow = datevec(now);
yyyy = dvnow(1);
doffset = datenum([yyyy 1 1 0 0 0]);

fprintf(MEXEC_A.Mfidterm,'\n%s %s %s %s\n\n',tstream,' gaps greater than ',num2str(g),' seconds');

for k = 1:ng
    t1 = mtime(kgaps(k)); 
    t2 = mtime(kgaps(k)+1);
    dt = dtime(kgaps(k));
    daynum1 = floor(t1) - doffset + 1;
    daynum2 = floor(t2) - doffset + 1;
    str1 = datestr(t1,'yy/mm/dd');
    str1a = datestr(t1,'HH:MM:SS');
    daystr1 = sprintf('%03d',daynum1);
    str2 = datestr(t2,'yy/mm/dd');
    str2a = datestr(t2,'HH:MM:SS');
    daystr2 = sprintf('%03d',daynum2);
    % don't print the actual time if the end of the last gap was the end
    % of the search interval, since to do so might imply data started again
    % fill the elements of the end time string with other text. Likewise
    % at the start of the search period
    if kgaps(k)+1 == length(mtime)
        daystr2 = 'end';
        str2a = 'search  ';
        str2 = 'period  ';
    end
    if kgaps(k) == 1
        daystr1 = 'search';
        str1a = 'period  ';
        str1 = '  start ';
    end
    % use %6s on daystr1 to fake the "start search period" format
    fprintf(MEXEC_A.Mfidterm,'%11s  %8s%6s %8s  %s  %3s %8s   %8s %8.0f %s\n','time gap : ',str1,daystr1,str1a,'to',daystr2,str2a,str2,dt,'seconds');
end
    






 
    
    