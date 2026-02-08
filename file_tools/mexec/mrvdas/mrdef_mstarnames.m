function mrtables_out = mrdef_mstarnames(mrtables, varargin)
% mrtables_out = mrdef_mstarnames(mrtables, [use_mrtables_skip no_duplicate_vars]);
%
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
% 
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
%
% Define mstar filename prefixes for rvdas tables, and (optionally) exclude
% tables/variables/messages we don't want (as set in opt_cruise.m)
%
%
% Input:
% 
% mrtables is the output of mrgetrvdascontents: all of the non-empty tables
%   in the current RVDAS database, and all of their variables
% second argument is a vector [use_mrtables_skip no_duplicate_vars]
%   use_mrtables_skip [1]: 1 to call mrtables_skip and discard what is
%     listed there (messages, e.g. 'gnzda'; variables, e.g. 'ggaqual';
%     variables matching patterns, e.g. 'flag'; and ship-specific
%     tables/sentences, e.g.
%     'sd025_transmissometer_wetlabs_cstar_ucsw1_pwltran1_reference').
%     anything specified in opt_cruise rvdas_skip case will be skipped
%     whatever the value of use_mrtables_skip. 
%   no_duplicate_vars [1]: how to treat variables that are parsed into the
%     RVDAS database from multiple messages from a given instrument: 1 to
%     keep only the first ocurrence of each variable name from a given
%     instrument (does not apply to 'time', which is kept in each table)***
%     not implemented?
%
%     
% Output: 
% 
% mrtables_out, with additional columns for mstar prefix and directory
% 
% 
% The mapping is constructed by searching for the messages in
% mrtables.tablenames in a lookup, defined in mstar_dirs_tables. 


% optional input arguments
limit = [1 1];
if nargin>1
    limit = varargin{1};
end

% lookup for instruments/messages that would go in each directory
[mt, skips] = mrdef_dirs_tables;

% map these onto mrtables.tablenames
mrtables_out = mstar_by_table(mt, mrtables);

% limit tables/messages/variables
if sum(limit)
    mrtables_out = limit_tables(mrtables_out, limit, skips);
end



% -----------------------------------
% subfunctions
% -----------------------------------

%%%%%%%%% mstar_by_table %%%%%%%%%
function mrtables_out = mstar_by_table(mt, mrtables)
% add mstar prefixes and directories to each table line, and remove lines
% with no corresponding mstar lookup

opt1 = 'ship'; opt2 = 'rvdas_form'; get_cropt %sets npre?***
if use_cruise_views
    n0 = length(view_name)+2; %assume it's followed by underscore
else
    n0 = 1;
end

nt = length(mrtables.tablenames);
mstarpre = cell(nt,1);
mstardir = cell(nt,1);
paramtype = cell(nt,1);
rvdasmsg = cell(nt,1);
nomp = false(nt,1);

for tno = 1:nt
    tabl = mrtables.tablenames{tno}(n0:end);
    iiu = strfind(tabl,'_');
    if isempty(iiu)
        %if it doesn't have a message, skip
        nomp(tno) = true;
        continue
    end 
    if npre>0
        %if we have an extra prefix like anemometer_ on this ship/database
        iiu = iiu(npre:end); 
    end
    if isscalar(iiu)
        iiu(2) = iiu(1); %tablemap{:,4} will be empty
    end
    msg = tabl(iiu(end)+1:end);
    if isscalar(iiu)
        inst1 = tabl(1:iiu-1);
    else
        inst1 = tabl(1:iiu(2)-1);
        %inst2 = tabl(ii(2)+1:ii(end)-1);
        inst2 = tabl(iiu(end-1)+1:iiu(end)-1);
        if ~contains(inst2,digitsPattern) && length(iiu)>=3
            n = length(iiu)-1;
            inst2 = tabl(iiu(end-n)+1:iiu(end-n+1)-1);
        end
    end
    %inst = tabl(ii(1)+1:ii(2)-1); %everything after the prefix and before the message
    
    %for each table, look through mt to find the first match to both msg
    %and inst 
    iit = find(cellfun(@(x) sum(contains(x,inst1)), mt.inst) & cellfun(@(x) sum(contains(x,msg)), mt.msg));
    if isempty(iit)
        nomp(tno) = true;
    else
        if length(iit)>1
            sprintf('extra matches to %s being ignored from dirs:\n',tabl)
            fprintf(1,'%s\n',mt.dir{iit(2:end)})
            iit = iit(1);
        end
        mstarpre{tno} = inst1;
        mstardir{tno} = mt.dir{iit};
        paramtype{tno} = mt.typ{iit};
        rvdasmsg{tno} = msg;
        %mstarfull{tno} = inst2; %***
    end
end

mrtables_out = mrtables;
mrtables_out.mstarpre = mstarpre;
mrtables_out.mstardir = mstardir;
mrtables_out.paramtype = paramtype;
mrtables_out.rvdasmsg = rvdasmsg;
%remove rows with no mstar info
mrtables_out(nomp,:) = [];


%%%%%%%%% limit_tables %%%%%%%%%
function mrtables_out = limit_tables(mrtables_out, limit, skips)
% mrtables_out = limit_tables(mrtables_out, limit, skips)
%

% discard tables/messages set in mrvdas_skip or in opt_cruise rvdas_skip
if limit(1)
    [~,iis,~] = intersect(lower(mrtables_out.rvdasmsg), lower(skips.msg));
    mrtables_out(iis,:) = [];
    [~,iis,~] = intersect(lower(mrtables_out.tablenames), lower(skips.sentence));
    mrtables_out(iis,:) = [];
    for no = 1:length(skips.sentence_pat)
        mrtables_out(contains(lower(mrtables_out.tablenames), lower(skips.sentence_pat{no})),:) = [];
    end
end

if sum(limit)
    novars = false(length(mrtables_out.mstarpre),1);
    insts = unique(mrtables_out.mstarpre); %***for sda does this have to be inst2, or something else to include the location or s/n?
    
    for ino = 1:length(insts)
        ts = find(strcmp(insts{ino},mrtables_out.mstarpre)); %all tables (messages) being read from this instrument
        vars0 = {};

        for tno = 1:length(ts)
            vars = lower(mrtables_out.tablevars{ts(tno)});

            if limit(2)
                %discard any variables we already have from this instrument
                vars(ismember(vars,vars0)) = [];
            end
            if limit(1)
                %while we're here, discard any set in opt_cruise rvdas_skip
                vars(ismember(vars, lower(skips.var))) = [];
                vars(logical(sum(cell2mat( ...
                    cellfun(@(x) contains(vars,x), lower(skips.pat), ...
                    'UniformOutput', false)')))) = [];
            end

            if isempty(setdiff(vars,{'time','utctime'}))
                novars(ts(tno)) = true;
            else
                mrtables_out.tablevars{ts(tno)} = vars;
                %record the ones we already have (but keep time from each
                %message)
                vars0 = [vars0 setdiff(vars,{'time' 'utctime'})];
            end

        end
    end

    %remove lines that would now be empty of variables
    mrtables_out(novars,:) = [];
end

