function [d, h] = pload(filename,instring)

% pload: load a pstar file; fixes variable names that would be illegal in matlab.
% filename is a pstar filename
% instring is an optional character array of variable numbers/names to load; use '/' or '' or ' ' for  all;
% [d h] = pload(filename,instring);   %full form of command
% [d h] = pload;              %will prompt for filename and varlist
% [d h] = pload(filename);    %will prompt for variable list
% [d h] = pload(filename,''); %will select all variables
% [d h] = pload(filename,'1 3~5 a b');  %will select vars 1 3,4,5 and variables named 'a' and 'b'
%
% The final list of variable numbers is passed through 'unique' before loading.
%
% the variables are loaded into struct array d
% the header info is loaded into struct array h
%
% BAK at SOC 31 March 2005

% As presently written, the load is a bit slow for pstar data packed as
% real*5; The time is mostly spent in punpack.m


clear d h

if nargin < 1
    filename = input('Type name of pstar file to load :\n','s');
elseif nargin > 2
    disp(['You must give a maximum of two arguments']);
    return
end

if exist(filename,'file') ~= 2
    disp(['Filename ''' filename ''' not found']);
    return
end

h = plisth(filename);
norecs = h.norecs;
noflds = h.noflds;
nrows = max(h.nrows,1);
%bak at NOCS, 14 Jul 2005: include possibility of NPLANE; I didn't know anyone actually used this,
% but RTP says he sometimes does !
nplane = max(h.nplane,1);

if mod(norecs,nrows*nplane) ~= 0
    error(['nrows * nplane ' num2str(nrows) ' * ' num2str(nplane) ' does not divide norecs ' num2str(norecs)])
    return
else
    ncols = round(norecs/(nrows*nplane));
end 

if nargin < 2
    disp([' ']);
    disp(['Type list of pstar variables to load']);
    disp(['List can be space or comma separated']);
    instring = input('Use variable names or numbers or n1~n2. Type c/r or / for all); \n','s');
end

vlist = getvlist(instring,h);

vlist = unique(vlist); %sort and remove duplicates for load

skip = 1+0*[1:noflds];
skip(vlist) = 0;
loadlist = vlist;

magvar=1344950870;
magdat=1344950852;
magvr8=1344951864;
magdr8=1344947256;

r5 = 1365;
r8 = 1024;

lb = 0;
if h.magic == magvar | h.magic == magdat 
    lb = r5;
elseif h.magic == magvr8 | h.magic == magdr8
    lb = r8;
else
    disp('Problem with magic number - quitting')
    return
end

storvar = '   ';
if h.magic == magvar | h.magic == magvr8
    storvar = 'var';
else
    storvar = 'dcs';
end

varnames = '';
disp(' ');
printsummary = 0;  %Will set this to 1 if any variables are renamed
for k = 1:noflds %sort out difficult variable names
    if skip(k) == 1
        varnames{k} = '';
        continue
    end
    vn = h.fldnam{k};
    vnold = vn;
    renamed = 0;
    %list of problem characters that may occur in pstar file names
    %you can add to the list as new ones are discovered.
    %Blanks are simply discarded.
    if strcmp(vn,'        ') % if the pstar fldnam was all blanks, rename the variable.
        vn = ['blank_' num2str(k) '_'];
        renamed = 1;
    end
    
    %remove trailing blanks;
    while strcmp(vn(end),' ')
        vn(end) = [];
    end
    
    swap = {
        ' ' '_space_'
        '-' '_minus_'
        '+' '_plus_'
        '/' '_slash_'
        '*' '_star_'
        '.' '_dot_'
        '#' '_hash_'
        '$' '_dollar_'
        '^' '_hat_'
        '&' '_amp_'
        '(' '_lparen_'
        ')' '_rparen_'
        '[' '_lbrac_'
        ']' '_rbrac_'
    } ;
    nswaps = size(swap,1);
    for k2 = 1:nswaps
        s1 = char(swap(k2,1));
        s2 = char(swap(k2,2));
        sindex = findstr(vn,s1);
        if length(sindex) > 0
            vnew = '';
            count = 1;
            for kswap = 1:length(sindex)
                vnew = [vnew vn(count:sindex(kswap)-1) s2];
                count = sindex(kswap)+1;
            end
            vnew = [vnew vn(count:end)];
            vn = vnew;
            renamed = 1;
        end
    end
    
    %replace any other odd characters with underscore. We'll permit alphanumeric and underscore in matlab var names.
    okchars = '_0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    for k2 = 1:length(vn)
        if length(findstr(okchars,vn(k2))) == 0
            vn(k2) = '_';
            renamed = 1;
        end
    end

    okfirstchar = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'; %must start with an alpha; if not, insert 'v_'
    if length(findstr(okfirstchar,vn(1))) == 0
        vn = ['v_' vn];
        renamed = 1;
    end
    
    if length(vn) > 26 %truncate. Allow for later addition of _nnn_ and still keep
                       %total var name to shorter than 31, which seems to be needed in 
                       % Matlab fieldnames in a structure.
        vn = vn(1:26);
        renamed = 1;
    end
    
    
    smatch = strmatch(vn,varnames,'exact');
    if length(smatch) > 0
        vn = [vn '_' num2str(k) '_'];
        renamed = 1;
    end
    
    if renamed == 1
        printsummary = 1;
        disp(['Variable number ' sprintf('%3d',k) ':''' vnold ''' renamed to ''' vn '''']);     
    end
    
    vnprint = vn;
    while length(vnprint) < 32
        vnprint = [vnprint ' '];
    end
    varnames{k} = vnprint;
end % of for k = 1:noflds %sort out problem variable names
disp(' ');
if printsummary == 1
    disp('List of loaded variables will be');
    disp('************************************************************************************************');
    for k = loadlist
        disp(['*' sprintf('%3d',k) '*' sprintf('%32s',varnames{k}) '*' h.fldunt{k} '* ' sprintf('%15.3f',h.alrlim(k)) ' * ' sprintf('%15.3f',h.uprlim(k)) ' * ' sprintf('%10.3f',h.absent(k)) ' *']);
    end
    disp('************************************************************************************************');
    disp(' ')
end

if strcmp(storvar,'var') %store by variable
    numblocks_per_var = ceil(norecs/lb);
    num_data_blocks = noflds*numblocks_per_var;
else %store by data cycle
    numcycles_per_block = floor(lb/noflds);
    num_data_blocks = ceil(norecs/numcycles_per_block);
end

disp(['There are ' num2str(num_data_blocks) ' data blocks to read'])

fid = fopen(filename,'r','b');
fseek(fid,8192,0); %skip header block

for k = 1:num_data_blocks
    if mod(k,100) == 0; disp(['Reading data block ' num2str(k) ' out of ' num2str(num_data_blocks)]); end;
    clear buf raw
    numvar = 1 + mod(k-1,noflds); %this is the numvar if storage is by variable
    if strcmp(storvar,'var') & skip(numvar) == 1
        fseek(fid,8192,0); %skip a block
        continue
    elseif lb == r8;
        buf = fread(fid,lb,'double'); %read from real*8
    else
        %1365*5 = 6825
        raw = char(fread(fid,6825,'5*uchar',1)); %read some real*5; skip the status byte
        % The syntax of fread means you collect 6825 bytes of data in 5s, (ie 1365 elements) and 1365 skips of 1 byte.
        % So there are 2 bytes left in the block of 8192.
        fseek(fid,2,0); %skip the last 2 bytes
        buf = punpack(raw(1:6825));
    end
    

    %now store the data
    if strcmp(storvar,'var') %store this block in the correct variable
        blocknum_thisvar = 1+floor((k-1)/noflds);
        completed = lb*(blocknum_thisvar-1);
        remaining = norecs-completed;
        thistime = min(lb,remaining);
        dcnums = completed+1:completed+thistime;
        vn = varnames{numvar};
        if exist('d','var');
            if isfield(d,m_remove_outside_spaces(vn))
                eval(['lenvn = length(d.' vn ');']);
                eval(['if lenvn < norecs; d.' vn '(end+1:norecs) = nan; end']);
            end
        end
        eval(['d.' vn '(dcnums) = buf(1:thistime);']);

    else %store by data cycle; distribute data across variables
        completed = numcycles_per_block*(k-1);
        remaining = norecs-completed;
        for k2 = 1:min(numcycles_per_block,remaining)
            for k3 = loadlist
                bufindex = noflds*(k2-1)+k3;
                vn = varnames{k3};
                eval(['d.' vn '(completed+k2) = buf(bufindex);']);
            end %of k3 = 1:noflds
        end %of k2 = 1:numcycles_per_block
    end %of assigning data to variables

end %of k = 1:num_data_blocks
disp(['Finished reading data blocks']);

fclose(fid);

for k3 = loadlist  %sort out gridded data and absent values
    clear grid vec absent bad
    vn = varnames{k3};
    eval(['vec = d.' vn ';']);
    absent = h.absent(k3);
    bad = find(vec == absent);
    vec(bad) = nan;  %set absent data to nan;
    if nrows > 1 & nplane < 2
        vec = reshape(vec,nrows,ncols);
    end
    if nplane > 1
        vec = reshape(vec,nrows,ncols,nplane);
    end
    eval(['d.' vn ' = vec;']);
    %if nrows > 1 %assign data to 2-D matrix %better done with reshape command as above
    %    for k1 = 1:nrows
    %        for k2 = 1:ncols
    %            grid(k1,k2) = vec(nrows*(k2-1)+k1);
    %        end
    %    end
    %    eval(['d.' vn ' = grid;']); 
    %else %copy one-D matrix with NaNs back to d.vn
    %    eval(['d.' vn ' = vec;']);
    %end
end
