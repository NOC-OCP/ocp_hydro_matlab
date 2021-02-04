function mfsave(filename, d, varargin)
% mfsave(filename, d, h);
% mfsave(filename, d, h, '-addvars');
% mfsave(filename, d, h, '-merge', indepvar);
% mfsave(filename, d, '-addvars');
% mfsave(filename, d, '-merge', indepvar);
%
% save data to new or existing mstar file filename
%
% input arguments:
%     filename, including full path
%     d, structure whose fields will be saved to filename
% optional string arguments that determine what to do if file filename
%         exists (if none is specified, contents of file filename will be
%         overwritten)
%     '-addvars': add variables in d to the file (works like matlab's
%         built-in save -append except the dimensions of variables to be
%         added must match those in the existing file)
%     '-merge': use variable indepvar (see below) to place (*not*
%         interpolate) fields in d into the existing variables in
%         filename, or for variables not already in file, add them. 
% additional arguments if '-merge' specified:
%     indepvar (string, required) gives the name of the independent
%         variable to use for placing new data into existing variables.
%         Normally the resulting indepvar will be the unique, sorted
%         combination of the original (from filename) and new (from d)
%         values of indepvar; however, there will be no sorting if either
%         a. they contain the same values, or b. 
%     '-nosort' is specified; in this case the values in d that are not in
%         the original file already will be appended to the end.
%         Other variables (from both file and d) will be padded to the same
%         size as the new indepvar, with one exception: if indepvar is
%         sampnum, statnum and position will be reconstructed from it***
%         the same size. Note that unlike in mmerge, there is no
%         interpolation.
% required argument if '-merge' or '-addvars' not specified, or if file
%         filename does not exist, else optional:
%     h, structure with information for mstar file header, such as some
%             or all of:
%         fldnam, a cell array list of variable names in d (if not
%             included, will be reconstructed)
%         fldunt, a cell array list of corresponding units (required unless
%             -merge specified, and also if -merge specified and there are
%             new variables not yet in file filename)
%         dataname (defaults to filename without path or suffix)
%         comment, to be added to the existing comment string (if any)***
%             (defaults to "Variables written/added from matlab[, merging
%             on indepvar]"). Use this to give information on the source of
%             d (e.g. sample data file, or that variables were interpolated
%             in the workspace, etc.), but if you are for instance adding
%             another day to an appended file, you don't need to reiterate
%             all the info from the new day's file, as it will already have
%             been included from a previous day***
%         instrument_identifier
%         recording_interval
%
% examples:
%
% for a new file:
% >> d.position = [1:24]';
% >> d.statnum = repmat(3,24,1);
% >> d.bottle_qc_flag = repmat(2,24,1);
% >> h.fldnam = {'position' 'statnum' 'bottle_qc_flag'};
% >> h.fldunt = {'number' 'number' 'woce_table_4.9'};
% >> mfsave(filename, d, h);
%
% to add variable(s) to an existing file (when they are the same size as,
%     and match up with, variables already in the file)
% >> d.botpsal = botpsal;
% >> h.fldnam = {'botpsal'};
% >> h.comment = 'Salinity data loaded from saldata_cruise_all.txt \n and standardised';
% >> mfsave(filename, d, h, '-append');
%
% to add data to variable(s) in the file but for a different set of e.g.
%     sampnum:
% >> d.botpsal = botpsal;
% >> d.sampnum = sampnum;
% >> mfsave(filename, d, '-merge', 'sampnum');
%

m_common %brings in MEXEC_G

%%%%% handle input arguments %%%%%

filename = m_add_nc(filename);

writenew = 1; %default: overwrite if exists, or create new
oldheader = 0; % default: don't put any info from old header into the comment
mergemode = 0; %default: (if file exists) add new variables, don't change existing variables
nosort = 0; %default: if mergemode==1, sort indepvar for output

for argn = 1:length(varargin)
    if isstruct(varargin{argn})
        hnew = varargin{argn}; 
    elseif ischar(varargin{argn})
        if strcmp(varargin{argn},'-addvars')
            writenew = 0; %add new variables to file
            oldheader = 1; % keep old header info
        elseif strcmp(varargin{argn},'-merge')
            writenew = 0; mergemode = 1; %add new or existing variables, merging on mergevar
            oldheader = 1; % keep old header info
        elseif strcmp(varargin{argn},'-nosort')
            nosort = 1;
        else
            indepvar = varargin{argn};
        end
    else
        error('optional input arguments must be either header structure or char array')
    end
end

if ~exist(filename, 'file') & ~writenew
    warning(['file ' filename ' not found, creating new']);
    writenew = 1;
    oldheader = 0; % no old header info
    mergemode = 0;
end
ncfile.name = filename;

% If the filename exists, get the header now and we'll figure out later what to keep.
if exist(filename, 'file')
    h0 = m_read_header(filename);
    h0.filename = filename;
end
if exist('hnew', 'var') % keep this unaltered, so we can use dataname and version later
    h1 = hnew;
end

if mergemode
    if ~exist('indepvar','var')
        error('mergemode=1 requires the name of the variable to merge on to be supplied');
    elseif sum(strcmp(indepvar,{'sampnum','scan','time'}))==0
        msg = ['merge variable %s is an unusual choice; note there is no \n interpolation, so the new %s will contain all the values in d and in file \n %s \n thus merge variable should usually be discrete like sampnum or scan; \n if you want to interpolate, do that first then call with ''-append'''];
        warning(msg,indepvar,indepvar,filename)
    end
    if ~isfield(d, indepvar)
        error(['merge variable ' indepvar ' not in input data structure'])
    else
        h = m_read_header(filename);
        if ~sum(strcmp(indepvar, h.fldnam))
            error([indepvar ' not found in file ' filename ' to merge on'])
        end
    end
end

if ~exist('hnew') | ~isfield(hnew, 'fldnam')
    hnew.fldnam = fieldnames(d);
elseif length(hnew.fldnam)~=length(fieldnames(d)) | (isfield(hnew,'fldunt') & length(hnew.fldunt)~=length(hnew.fldnam))
    error('field names and units in header h must match each other and fields in data d');
end



%%%%% sort out variables, modify, write to file %%%%%

if mergemode 
    
    d0 = mload(filename, indepvar);
    if length(d0.(indepvar))==length(d.(indepvar)) & max(abs(d0.(indepvar)-d.(indepvar)))==0
        mergemode = 0; %identical indepvar contents, including order, so can use -addvars mode
    else
        %merge new variables and existing ones in workspace
        if length(d0.(indepvar))==length(d.(indepvar)) & max(abs(sort(d0.(indepvar)-d.(indepvar))))==0
            nosort = 1; %same contents though in different order, so put new vars into existing order
        end
        [d, hnew] = merge_mvars(filename, d, hnew, indepvar, nosort);
        
        %determine whether dimension has increased and we actually need a new file
        h = m_read_header(filename);
        if length(d.(indepvar))~=max(h.rowlength,h.collength)
            writenew = 1;
            oldheader = 1; % there is some old header info to keep
        end
    end
    
end

if ~writenew %overwrite existing variables and keep record of new ones
    
    h = m_read_header(filename); %existing header
    fn = fieldnames(d); 
    if length(d.(fn{1}))~=max(h.rowlength,h.collength)
        error(['fields in d must have same length as those in file ' filename ', else use ''-merge''']);
    end
    hist0 = h;
    hist0.filename = ncfile.name;
    varsold = h.fldnam;
    
    %open file for write
    ncfile = m_openio(ncfile);
    
    %loop through variables in d, overwrite those that exist in file
    varsnew = {}; untsnew = {}; %keep record of new variables
    for vno = 1:length(hnew.fldnam)
        
        ii = find(strcmp(hnew.fldnam{vno},h.fldnam));
        
        if length(ii)>0 %existing
            
            %sort out units
            if isfield(hnew, 'fldunt') & ~strcmp(hnew.fldunt{vno}, h.fldunt{ii})
                if mergemode
                    error(['unit ' hnew.fldunt{vno} ' in new header does not match ' h.fldunt{ii} ' in existing ' filename])
                else
                    warning(['unit ' hnew.fldunt{vno} ' in new header overwriting ' h.fldunt{ii} ' in existing ' filename])
                    h.fldunt(ii) = hnew.fldunt(vno);
                end
            end
            
            %write
            nc_varput(ncfile.name, hnew.fldnam{vno}, d.(hnew.fldnam{vno}));
            m_uprlwr(ncfile, hnew.fldnam{vno});
            
        else %new variable, write below
            
            if isfield(hnew, 'fldunt')
                varsnew = [varsnew hnew.fldnam{vno}];
                untsnew = [untsnew hnew.fldunt{vno}];
            else
                error(['d contains field ' hnew.fldnam{vno} ' not already in file ' filename ', so h.fldunt must be supplied']);
            end
            
        end
        
    end
    
else %initialise new file and header
    
    %start with default header
    h = m_default_attributes;
    
    %and add variables from hnew
    if ~exist('hnew') | ~isfield(hnew,'fldunt')
        error(['file ' filename ' does not yet exist, or you have chosen to overwrite it, so you must specify at least h.fldunt']);
    else
        varsnew = hnew.fldnam; untsnew = hnew.fldunt;
        h.fldnam = []; h.fldunt = []; %will be appended below
        ii = strfind(ncfile.name, '/');
        if length(ii)>0; ii = ii(end)+1; else; ii = 1; end
        h.dataname = ncfile.name(ii:end-3);
    end
    
    %initialise and open file for write***copy old file away temporarily?
    ncfile = m_openot(ncfile);
    
end

%write just the new variables
for vno = 1:length(varsnew)
    clear v
    v.data = d.(varsnew{vno});
    if ~isa(v.data, 'double')
        error(['writing from matlab to mstar not valid for variable of class ' class(v.data) '; must be double']);
    end
    v.name = varsnew{vno};
    v.units = untsnew{vno};
    m_write_variable(ncfile,v);
end


%%%%% edit comments, header, history %%%%%

%modify header
fn = setdiff(fieldnames(hnew),{'comment' 'fldnam' 'fldunt' 'dataname' 'version' 'mstar_site'});
for fno = 1:length(fn)
    h.(fn{fno}) = hnew.(fn{fno});
end
if length(varsnew)>0 | length(fn)>0
    h.fldnam = [h.fldnam varsnew]; h.fldunt = [h.fldunt untsnew];
    m_write_header(ncfile,h);
    % now check that variable units match those in h. Note that
    % m_write_header only writes the parts of h that are global attributes.
    % fldnam and fldunt are variable attributes.
    m_write_units_from_header(ncfile,h);
end

%modify comments
if isfield(hnew,'comment') & length(hnew.comment)>0
    % The h.comment in ncfile should already terminate in a comment
    % delimiter. Make sure there aren't any stray ones at start of
    % hnew.comment. Remove all delims at start of comment.
    delim = h.comment_delimiter_string;
    ndelim = length(delim);
    while strncmp(hnew.comment,delim,ndelim)
        hnew.comment(1:ndelim) = [];
    end
    if ~isempty(hnew.comment);
        filecomin = hnew.comment;
    end
else
    filecomin = [];
end
if isfield(h1,'dataname') & isfield(h1,'mstar_site') & isfield(h1,'version');
    commentadd = [' from: ' h1.dataname ' <s> ' h1.mstar_site ' <v> ' sprintf('%d',h1.version)];
else
    commentadd = ' ';
end
if writenew
    comstring = [filecomin 'Variables' commentadd ' written via matlab to mstar'];
elseif mergemode
    comstring = [filecomin 'Variables' commentadd ' added via matlab to mstar, merging on ' indepvar];
else
    comstring = [filecomin 'Variables' commentadd ' added via matlab to mstar'];
end
m_add_comment(ncfile,[comstring '  at ' datestr(now,31) '  by ' MEXEC_G.MUSER]);

%write history
if writenew & oldheader
    hist0 = h0;
elseif writenew & ~oldheader
    %fake input file details for write_history
    h = m_read_header(ncfile);
    hist0 = h;
    hist0.filename = [];
    hist0.dataname = [];
    hist0.version = [];
    hist0.mstar_site = [];
else
    %saved earlier, from original file header
end
MEXEC_A.Mhistory_in{1} = hist0;
hist = m_read_header(ncfile);
hist.filename = ncfile.name;
MEXEC_A.Mhistory_ot{1} = hist; 
MEXEC_A.MARGS_IN = {}; 
MEXEC_A.MARGS_OT = {};
varstr = ' '; for vno = 1:length(varsnew); varstr = [varstr varsnew{vno} ' ']; end; varstr = varstr(2:end-1);
vastr = ' '; for vno = 1:length(varargin); if ~isstruct(varargin{vno}); vastr = [vastr varargin{vno} ' ']; end; end; vastr = vastr(2:end-1);
MEXEC_A.MARGS_OT = [MEXEC_A.MARGS_OT; ['writing variables ' varstr]; ['called with ' vastr]; hnew.comment];
%***add some information on what was done. see hist.comment, varsnew, ...
MEXEC_A.Mprog = 'mfsave';
m_finis(ncfile); % need mfinis after setting MEXEC_A.Mhistory_in
m_write_history
MEXEC_A.MARGS_OT = {};


function [d, h] = merge_mvars(filename, d, hnew, indepvar, nosort)
%%%%% merge_mvars: do the extra actions to merge variables %%%%%

%load old data
[d0, h0] = mload(filename, '/');

%check indepvars
mvo = d0.(indepvar);
if length(unique(mvo))<length(mvo)
    error(['merge variable ' indepvar ' has non-unique values in file ' filename]);
end
mvn = d.(indepvar);
if length(unique(mvn))<length(mvn)
    error(['merge variable ' indepvar ' supplied in input d has non-unique values']);
end

%get combined indepvar
if nosort
    s = size(mvo);
    iin = find(~ismember(mvn, mvo)); %new ones that aren't in old
    mvnsub = mvn(iin);
    d.(indepvar) = [mvo(:); mvnsub(:)]; %append these, no sorting
    s(s>1) = length(d.(indepvar));
    d.(indepvar) = reshape(d.(indepvar),s); %row vs column vector
else
    s = size(mvo);
    d.(indepvar) = unique([mvo(:); mvn(:)]);
    s(s>1) = length(d.(indepvar));
    d.(indepvar) = reshape(d.(indepvar),s); %row vs column vector
end
h = h0;

%place combined variables
[c,iico,iio] = intersect(d.(indepvar), mvo);
[c,iicn,iin] = intersect(d.(indepvar), mvn);
vars = setdiff([h0.fldnam hnew.fldnam], indepvar);
a = zeros(size(d.(indepvar))); %add fill value to pad
for vno = 1:length(vars)
    varname = vars{vno};
    if length(varname)>4 & strcmp(varname(end-4:end),'flag')
        data = 9+a;
    else
        data = NaN+a;
    end
    if isfield(d0, varname)
        data(iico) = d0.(varname)(iio);
    end
    if isfield(d, varname)
        data(iicn) = d.(varname)(iin);
        if ~isfield(d0, varname)
            nvno = find(strcmp(varname,hnew.fldnam));
            h.fldnam = [h.fldnam hnew.fldnam{nvno}];
            h.fldunt = [h.fldunt hnew.fldunt{nvno}];
        end
    end
    d.(varname) = data;
end

%remake fields that shouldn't be filled with NaN or 9***
if strcmp(indepvar,'sampnum') isfield(d,'sampnum') & isfield(d,'statnum')
    d.statnum = floor(d.sampnum/100); 
    if isfield(d, 'position')
        d.position = d.sampnum-d.statnum*100;
    end
end

%header
% if isfield(hnew,'comment'); h.comment = [h.comment ' \n ' hnew.comment]; end
if isfield(hnew,'comment'); h.comment = [h.comment  hnew.comment]; end % bak: delimiter not required before new comment. The old comments always ends with the delimiter.
if isfield(hnew, 'dataname'); h.dataname = hnew.dataname; end


