function [vdata, vunits] = mtload(instream,dn1,dn2,varlist)
% function [vdata, vunits] = mtload(instream,dn1,dn2,varlist)
%
% USE, eg
%   mtload('winch',[2009 4 4],[2009 5 4 12 0 0])
%   mtload('winch',now-0.1,now)
%   mtload('winch',now-0.1)
%   mtload winch now-0.1
%   mtload winch '[2009 4 9 12 0 0]' now
%   mtload winch '2009 4 9 12 0 0' now 'time cableout rate'
%
%   mtload(instream,dn1,dn2,varlist) or
%   mtload instream dn1 dn2 varlist
%
% load techsas data into Matlab
% source stream is instream; can be techsas name or mexec short name.
% dn1 and dn2 are matlab datenums or datevecs that define the required 
% data period
% note silent mode; use 'q' to suppress output to the screen;
% Data are loaded from all relevant techsas files with matching stream
% name, and appended.
% varlist is a single character string and can use either variable names or
% numbers, eg '/' '1~4' 'time lat long' 'time 2~4' 'time 2 4 6'
% Use mtvars to find the variable names in a stream.
%
% YLF modified Feb 2017 (JC145) for case where no files are found

m_common
tstream = mtresolve_stream(instream);

[mt1 mt2] = mtgetdfinfo(tstream,'f'); % get time limits in case they are required for default

if ~exist('dn1','var'); dn1 = mt1; end
if isempty(dn1); dn1 = mt1; end
if ischar(dn1); cmd =['dn1 = [' dn1 '];']; eval(cmd); end % if the arg has come in as a string, convert from char to number
if ~exist('dn2','var'); dn2 = now; end
if isempty(dn2); dn2 = now; end
if ischar(dn2); cmd =['dn2 = [' dn2 '];']; eval(cmd); end


% convert datevecs to nums; if the arguments are datenums nothing is
% changed
dn1 = datenum(dn1);
dn2 = datenum(dn2);

% get file names
fnames = mtchoosefiles(tstream,dn1,dn2);
nf = length(fnames);

if nf==0; vdata = []; vunits = []; else %YLF added JC145
    
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
    varnums(ktime) = [];
    varnums = [timevarnum varnums];
end

% identify parts of files to load

dc1 = nan+ones(nf,1); dc2 = dc1; totdc = 0;
m = 'Counting data cycles';
if ~MEXEC_G.quiet; fprintf(MEXEC_A.Mfidterm,'%s\n',m); end

scriptname = 'ship'; oopt = 'datasys_best'; get_cropt
for kf = 1:nf
    fn = fnames{kf};
    fullfn = fullfile(uway_root, fn);
    [dc1(kf), dc2(kf)] = mtgetdcrange(fn,dn1,dn2);
    totdc = totdc + dc2(kf)-dc1(kf)+1;
end
       
m = [sprintf('%d',totdc) ' data cycles and ' sprintf('%d',nv) ' vars found in ' sprintf('%d',nf) ' files'];
if ~MEXEC_G.quiet; fprintf(MEXEC_A.Mfidterm,'%s\n',m); end

% now load data

for kv = varnums
    % make empty space so file doesn't grow in loop
    vuse = nan+ones(1,totdc);
    kount = 0;
    m = ['loading variable ' vars{kv}];
    if ~MEXEC_G.quiet; fprintf(MEXEC_A.Mfidterm,'%s\n',m); end

    for kf = 1:nf
        fn = fnames{kf};
        fullfn = fullfile(uway_root, fn);
        nk = dc2(kf)-dc1(kf)+1; % load this many data cycles on this operation
        vin = nc_varget(fullfn,vars{kv},dc1(kf)-1,nk);
        vuse(kount+1:kount+nk) = vin;
        kount = kount+nk;
    end
    cmd = ['vdata.' vars{kv} ' =  vuse(:)'';']; eval(cmd);
    cmd = ['vunits.' vars{kv} ' =  units{kv};']; eval(cmd);
end

end
    