function mfsave(filename, d, varargin)
% mfsave(filename, d, h);
% mfsave(filename, d, h, '-addvars');
% mfsave(filename, d, h, '-merge', indepvar);
% mfsave(filename, d, '-addvars');
% mfsave(filename, d, '-merge', indepvar);
% mfsave(filename, d, h, '-merge', indepvar, comment_update);
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
%         added must match those in the existing file). variables in d and
%         already in the file will be overwritten, but variables in the
%         file and not in d will not be overwritten
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
%         Note that unlike in mmerge, there is no interpolation.
%     ***TBI:***comment_update (default 0) 1 to check existing file comment string
%         for lines similar to the new comment lines to be added, and remove
%         them (so that, for example, if yesterday you merged into the sam
%         file all the sal data available, and today you merged in all of
%         it again, the comment string would only say 'merged from
%         sal_cruise_01.nc once)
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
mergemode = 0; %default: (if file exists) add new variables, don't change existing variables
nosort = 0; %default: if mergemode==1, sort indepvar for output
unitsnew = 0;

for argn = 1:length(varargin)
    if isstruct(varargin{argn})
        h = varargin{argn}; 
    elseif ischar(varargin{argn})
        if strcmp(varargin{argn},'-addvars') || strcmp(varargin{argn},'-addvar')
            writenew = 0; %add new variables to file
        elseif strcmp(varargin{argn},'-merge')
            writenew = 0; mergemode = 1; %add new or existing variables, merging on mergevar
        elseif strcmp(varargin{argn},'-nosort')
            nosort = 1;
        else
            if sum(strcmp(varargin{argn},{'addvar','addvars','merge','nosort'}))
                warning('did you forget a ''-'' before %s?',varargin{argn}); pause
            end
            indepvar = varargin{argn};
        end
    else
        error('optional input arguments must be either header structure or char array')
    end
end
if ~exist('h','var') || ~isfield(h, 'fldnam')
    h.fldnam = fieldnames(d);
end

if length(h.fldnam)~=length(fieldnames(d)) || (isfield(h,'fldunt') && length(h.fldunt)~=length(h.fldnam))
    error('field names and units in header h must match each other and fields in data d');
end

if ~exist(filename, 'file') && ~writenew
    warning(['file ' filename ' not found, creating new']);
    writenew = 1;
    mergemode = 0;
end
ncfile.name = filename;

% If the filename exists, get the header now and we'll figure out later
% what to keep; otherwise, start with defaults and fill in from new header
% (comments will be added separately later)
if exist(filename, 'file') && ~writenew
    h0 = m_read_header(filename);
    oldheader = 1;
else
    oldheader = 0;
    h0 = m_default_attributes;
    if isfield(h, 'dataname')
        h0.dataname = h.dataname;
    else
        [~,fn,~] = fileparts(filename);
        h0.dataname = fn;
    end
    h0.fldnam = []; h0.fldunt = [];
end
hist0 = h0;



%%%%% merge if specified %%%%%

if mergemode 
    
    if ~exist('indepvar','var')
        error('mergemode=1 requires the name of the variable to merge on to be supplied');
    end
    if ~isfield(d, indepvar) || sum(isfinite(d.(indepvar)))==0
        error(['merge variable ' indepvar ' has no good values in input data structure']);
    else
        if ~sum(strcmp(indepvar, h0.fldnam))
            error([indepvar ' not found in file ' filename ' to merge on']);
        end
    end
    
    d0 = mloadq(filename, indepvar);
    d0.(indepvar) = d0.(indepvar)(:);
    if size(d.(indepvar),2)>1
        d0.(indepvar) = d0.(indepvar).';
    end
    if length(d0.(indepvar))==length(d.(indepvar)) && max(abs(d0.(indepvar)-d.(indepvar)))==0
        mergemode = 0; %identical indepvar contents, including order, so can use -addvars mode
    else
        %merge new variables and existing ones in workspace
        if length(d0.(indepvar))==length(d.(indepvar)) && max(abs(sort(d0.(indepvar)-d.(indepvar))))==0
            nosort = 1; %same contents though in different order, so put new vars into existing order
        end
        [d0, h0] = mloadq(filename, '/');
        [d, hnew] = merge_mvars(d0, h0, d, h, indepvar, nosort);
        
        %determine whether dimension has increased and we actually need a new file
        if length(d.(indepvar))~=max(h0.rowlength,h0.collength)
            writenew = 1;
            h.fldnam = hnew.fldnam; h.fldunt = hnew.fldunt;
        end
    end
    
end


%%%%% write to file %%%%%

if writenew %initialise new file and set varsnew and untsnew to write below
        
    %add variables from h
    if ~isfield(h,'fldunt')
        error(['file ' filename ' does not yet exist, or you have chosen to overwrite it, so you must specify h.fldunt']);
    else
        varsnew = h.fldnam; untsnew = h.fldunt;
    end
    
    %initialise and open file for write
    ncfile = m_openot(ncfile);
    
else %overwrite existing variables and keep record of new ones in varsnew and untsnew to write below

    fn = fieldnames(d); 
    if length(d.(fn{1}))~=max(h0.rowlength,h0.collength)
        error(['fields in d must have same length as those in file ' filename ', else use ''-merge''']);
    end
    %varsold = h0.fldnam;
    
    %open file for write
    ncfile = m_openio(ncfile);
    
    %loop through variables in d, overwrite those that exist in file
    varsnew = {}; untsnew = {}; %keep record of new variables
    for vno = 1:length(h.fldnam)
        
        ii = find(strcmp(h.fldnam{vno},h0.fldnam));
        
        if ~isempty(ii) %existing
            
            %sort out units
            if isfield(h, 'fldunt') && ~strcmp(h.fldunt{vno}, h0.fldunt{ii})
                if mergemode
                    warning(['unit ' h.fldunt{vno} ' in new header does not match ' h0.fldunt{ii} ' for variable ' h.fldnam{vno} ' in existing ' filename]);
                    cont = input('overwrite (1) or keep old (0)? (or control-C to quit)\n');
                    if cont==1
                        h0.fldunt(ii) = h.fldunt(vno);
                        unitsnew = 1;
                    elseif cont==0
                        h.fldunt(vno) = h0.fldunt(ii);
                    else
                        error('must answer 1 or 0')
                    end
                else
                    warning(['unit ' h.fldunt{vno} ' in new header overwriting ' h0.fldunt{ii} ' in existing ' filename]);
                    h0.fldunt(ii) = h.fldunt(vno);
                end
            end
            
            %write
            nc_varput(ncfile.name, h.fldnam{vno}, d.(h.fldnam{vno}));
            m_uprlwr(ncfile, h.fldnam{vno});
            
        else %new variable, write below
            
            if isfield(h, 'fldunt')
                varsnew = [varsnew h.fldnam{vno}];
                untsnew = [untsnew h.fldunt{vno}];
            else
                error(['d contains field ' h.fldnam{vno} ' not already in file ' filename ', so h.fldunt must be supplied']);
            end
            
        end
        
    end
    
end

% write just the new variables
for vno = 1:length(varsnew)
    clear v
    v.data = d.(varsnew{vno}); 
    if ~isa(v.data, 'double')
        error(['writing from matlab to mstar not valid for variable of class ' class(v.data) '; must be double']);
    end
    if ~isempty(v.data)
        v.name = varsnew{vno};
        v.units = untsnew{vno};
        m_write_variable(ncfile,v);
    else
        warning([varsnew{vno} ' empty, not writing']);
    end
end


%%%%% edit comments, header, history %%%%%

%modify global attributes
fn = setdiff(fieldnames(h),{'comment' 'fldnam' 'fldunt' 'version' 'mstar_site'});
for fno = 1:length(fn)
    h0.(fn{fno}) = h.(fn{fno});
end
if ~isempty(fn) || writenew
    m_write_header(ncfile,h0);
end

%modify variable attributes fldnam and fldunt
if ~isempty(varsnew)
    h0.fldnam = [h0.fldnam varsnew]; h0.fldunt = [h0.fldunt untsnew];
    % now check that variable units match those in h. Note that
    % m_write_header only writes the parts of h that are global attributes.
    % fldnam and fldunt are variable attributes.
    m_write_units_from_header(ncfile,h0);
end
if unitsnew
    m_write_units_from_header(ncfile,h0);
end

%modify comments
if isfield(h,'comment') && ~isempty(h.comment)
    % The h.comment in ncfile should already terminate in a comment
    % delimiter. Make sure there aren't any stray ones at start of
    % hnew.comment. Remove all delims at start of comment.
    delim = h0.comment_delimiter_string;
    ndelim = length(delim);
    while strncmp(h.comment,delim,ndelim)
        h.comment(1:ndelim) = [];
    end
    if ~isempty(h.comment)
        filecomin = h.comment;
    end
else
    filecomin = [];
end
if isfield(h,'dataname') && isfield(h,'mstar_site') && isfield(h,'version')
    commentadd = [' from: ' h.dataname ' <s> ' h.mstar_site ' <v> ' sprintf('%d',h.version)];
else
    commentadd = ' ';
end
if writenew
    comstring = [filecomin 'Variables' commentadd ' written'];
elseif mergemode
    comstring = [filecomin 'Variables' commentadd ' added, merging on ' indepvar];
else
    comstring = [filecomin 'Variables' commentadd ' added'];
end
m_add_comment(ncfile,[comstring '  at ' datestr(now,31) '  by ' MEXEC_G.MUSER]);

%write history
if writenew && ~oldheader
    %fake input file details for write_history
    hist0.filename = [];
    if isfield(h,'dataname')
        hist0.dataname = h.dataname;
    else
        [~,hist0.dataname,~] = fileparts(ncfile.name);
    end
    hist0.version = [];
    hist0.mstar_site = [];
else
    hist0.filename = ncfile.name;
end
m_common
if ~isfield(MEXEC_A,'MARGS_IN_LOCAL')
    MEXEC_A.MARGS_IN_LOCAL = {};
end
MEXEC_A.Mhistory_in{1} = hist0;
hist = m_read_header(ncfile);
hist.filename = ncfile.name;
MEXEC_A.Mhistory_ot{1} = hist; 
MEXEC_A.MARGS_IN = {}; 
MEXEC_A.MARGS_OT = {};
varstr = ' '; for vno = 1:length(varsnew); varstr = [varstr varsnew{vno} ' ']; end; varstr = varstr(2:end-1);
vastr = ' '; for vno = 1:length(varargin); if ~isstruct(varargin{vno}); vastr = [vastr varargin{vno} ' ']; end; end; vastr = vastr(2:end-1);
MEXEC_A.MARGS_OT = [MEXEC_A.MARGS_OT; ['writing variables ' varstr]; ['called with ' vastr]];
%***add some information on what was done. see hist.comment, varsnew, ...
MEXEC_A.Mprog = 'mfsave';
m_finis(ncfile); % need mfinis after setting MEXEC_A.Mhistory_in
m_write_history;
MEXEC_A.MARGS_OT = {};


