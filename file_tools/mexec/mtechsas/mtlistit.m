function mtlistit(instream,ints,dn1,dn2,varlist)
% function mtlistit(instream,ints,dn1,dn2,varlist)
%
% list data in techsas file
%
% USE, eg
%   mtlistit('winch',10,[2009 4 4],[2009 5 4 12 0 0])
%   mtlistit('winch',0,now-0.1,now)
%   mtlistit('winch',0,now-0.1)
%   mtlistit winch 120 now-0.1
%   mtlistit winch 120 '[2009 4 9 12 0 0]' now
%   mtlistit winch 120 '2009 4 9 12 0 0' now 'time cableout rate'
%
%   mtlistit(instream,ints,dn1,dn2,varlist) or
%   mtlistit instream ints dn1 dn2 varlist
%  
%   So for example
%   mtlistit posmvpos 5 now-.001
%   is a convenient way to get the most recent 86 seconds (approximately) of
%   data at 5 second intervals
%
% where the last three arguments are optional
% instream is a techsas stream name or mexec short name.
% ints   is the listing interval in seconds; 0 means all data cycles; defaults to 0
% dn1 and dn2   are matlab datenums or datevecs that define the required data period
% dn1 defaults to the earliest time in the stream
% dn2 defaults to matlab 'now'
% varlist is a single character string and can use either variable names or
% numbers, eg '/' '1~4' 'time lat long' 'time 2~4' 'time 2 4 6'
% Use mtvars to find the variable names in a stream.
%
%
% Data are loaded from all relevant techsas files with matching stream
% name.
%
% As of the present time (9 April 2009 on JC032) there are no options to 
% control output format, which is hardwired at 12.5f.
% first draft by BAK on JC032


m_common
tstream = mtresolve_stream(instream);

% convert datevecs to nums; if the arguments are datenums nothing is
% changed

if ~exist('ints','var'); ints = 0; end  % list all data
if ischar(ints); ints = str2num(ints); end % int comes in as a char if it is simply typed on the command line

[mt1 mt2] = mtgetdfinfo(tstream,'f'); % get time limits in case they are required for default

if ~exist('dn1','var'); dn1 = mt1; end
if isempty(dn1); dn1 = mt1; end
if ischar(dn1); cmd =['dn1 = [' dn1 '];']; eval(cmd); end % if the arg has come in as a string, convert from char to number
if ~exist('dn2','var'); dn2 = now; end
if isempty(dn2); dn2 = now; end
if ischar(dn2); cmd =['dn2 = [' dn2 '];']; eval(cmd); end

dn1 = datenum(dn1);
dn2 = datenum(dn2);

% get var list
[vars units] = mtgetvars(tstream);
nv = length(vars);

% sort out the var list
if ~exist('varlist','var'); varlist = '/'; end
th.fldnam = vars;
th.noflds = nv; % create a structure equivalent to the mstar headers to parse for var names
varnums = m_getvlist(varlist,th);
% time always seems to be last in the techsas list; put it first if it is
% in the load list.
loadvarnames = vars(varnums);
ktime = strmatch('time',loadvarnames);
if ~isempty(ktime)
    timevarnum = varnums(ktime);
    varnums(ktime) = []; % remove time from list
%     varnums = [timevarnum varnums];
end

% always need to load time for mtlistit
loadvlist = ['time ' num2str(varnums)]; % add time first; the rest are resolved to numbers but must be added as a string

[data units]= mtload(tstream,dn1,dn2,loadvlist);

t = data.time + MEXEC_G.uway_torg;
if length(t) == 0
    m = 'You appear to have selected no data cycles';
    fprintf(MEXEC_A.Mfider,'%s\n',m);
    return
end

t0 = floor(t(1)); % set time boundaries to be exact on day boundary

varnames = fieldnames(data); % assume time last
nv = length(varnames);


dvnow = datevec(now);
yyyy = dvnow(1);
doffset = datenum([yyyy 1 1 0 0 0]);

format = '%8s   %03d %8s'; % for date string
varlist = [',datestr(tp,''yy/mm/dd''),floor(tp)-doffset+1,datestr(tp,''HH:MM:SS'')'];
header = ['                   time'];
unitline = ['yy/mo/dd  dnum hh:mm:ss'];
for kv = 1:nv
    if strcmp(varnames{kv},'time'); continue; end % skip time, it is handled eslewhere
    % format for each data cycle listing
    varform = ' %12.5f';
    format = [format varform];
    
    % var name for each data cycle listing
    vartext = [',data.' varnames{kv} '(icount)'];
    varlist = [varlist vartext];
    
    % column headers
    vn = varnames{kv};
    cmd = ['unit = units.' vn ';']; eval(cmd)
    if length(vn) > 12; vn = vn(1:12); end
    if length(unit) > 12; unit = unit(1:12); end
    headerstr = sprintf(' %12s',vn);
    header = [header headerstr];
    unitstr = sprintf(' %12s',unit);
    unitline = [unitline unitstr];
end
format = [format '\n'];
fprintf(MEXEC_A.Mfidterm,'%s\n',header);
fprintf(MEXEC_A.Mfidterm,'%s\n',unitline);
cmd = ['fprintf(MEXEC_A.Mfidterm,format' varlist ');'];


num = length(t);

tintd = ints/86400;
endflag = 0;
tcount = t0;
icount = 1;

if tintd == 0
    % print all cycles
    while icount <= num
    tp = t(icount);
    eval(cmd);
    icount = icount+1;
    end
    return % end of case that tintd == 0
end
    
% step forward in intervals of tintd. In each interval, search for
% data cycles that lie in the period and print the first one
while tcount < t(end) & endflag == 0; % tcount is the start of the search period
    tcount = tcount+tintd; % this is now the end of the search period
    if t(icount) < tcount % the present data cycle [ie t(icount) ] is in the period so print it
        tp = t(icount);
        eval(cmd);
        while t(icount) < tcount; % skip the other data cycles in this search period
            icount = icount+1; % when we exit this loop, t(icount) is in the next search period
            if icount > num; endflag = 1; break; end % set an end flag when we reach the end of the data
        end
    end
end




