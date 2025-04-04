function status = mout_columns(intype, outtype, varargin)
% status = mout_columns(intype, outtype, params)
%
% write selected data from mstar CTD and Niskin sample data file(s) to csv
% or xlsx, optionally bin-averaging, changing time coordinate, computing
% additional variables, and/or renaming variables and formatting to match
% exchange format or the BODC sample data template
%
% calls set_mexec_defaults, opt_{cruise}, mout_columns_defaults, and
% mout_columns_prepare_data
%
% intype:
%   'sam' to write sample data or 'ctd' to write CTD profiles
%
% outtype:
%   'mstar' to keep mstar variable names and include mstar file global
%     attributes in header,
%   'exch' to produce WOCE exchange-format files including parameter names
%     and required headers
%   'bodc' to use bodc sample data template for sample file (for ctd,
%     reverts to 'mstar') and writetable to .xlsx
%
% params (optional): structure (all fields optional)
%   ddir: directory where input data files are found
%   outdir: directory for output file(s)
%   stnlist: list of stations to include
%   vars_exclude: list of variables not to write from input files
%   extras: structure giving values of variables not in (or calculated
%     from) file to be repeated on every row (e.g. expocode)***put in cropt
%   extrah: structure with variables not in individual input
%     file headers to be added to header (should be included in
%     params.varsh)***put in cropt?
%
%   fields used for intype 'ctd' only:
%     suf: '_24hz' to force regridding from the 24hz file
%     bin_size (default 2): integer scalar
%     bin_units (default 'dbar'): 'dbar', 'm', or 'hz'
%     bin_prof (only used if params.bin_units is 'm' or 'dbar', default
%       'down'): 'down' or 'up' to average down or upcast
%
%   fields used for outtype 'exch' or 'mstar only:
%     header: cell array to print at top of file
%
%   fields used for outtype 'mstar' or 'bodc' only:
%     csvpre: prefix for output csv file(s)
%
%   fields used for outtype 'mstar' only:
%     vars_units: either Nx1 cell array containing original (mstar)
%     variable names to write, or Nx4 cell array containing 
%       [original (mstar) variable names, output variable names, output variable units, format strings]
%       e.g. vars_units = m_exch_vars_list(1); vars_units = vars_units(:,[3 1 2 4]);
%       if vars_units is Nx1, output variable names will be the same, units
%       will come from mstar header/attributes, and m_exch_vars_list.m will
%       be searched for format strings. 
%       for fixed-column formats where columns with no data should be
%       included but left blank, use 'blank' in the first column of
%       params.vars_units, e.g.  
%       params.vars_units = {'statnum', 'Station ID', ' ', '%d';
%                            'blank',   'Event ID',   ' ', '%s';
%                            'position', 'Bottle ID', ' ', '%d';
%                            'temp', 'Temperature', 'deg C ITS-90', '%f';
%                            'blank', 'Temperature Standard Deviation', 'deg C ITS-90', '%f';
%                            'temp_flag', 'Temperature Flag', 'woce_4.9', '%d'};
%     datetimeform or dateform and timeform: format for string date and
%       time either in one column (datetimeform) or two columns (dateform
%       and timeform), e.g. 'dd/mm/yyyy HH:MM'
%     time_units (only used if above not supplied): CF-format time
%       unit string, e.g. 'days since 1900-01-01' or 'seconds since
%       2022-07-30'. time_units (or date/timeform) overwrites the
%       corresponding units from vars_units.
%     autoheader: include in the header information about averaging (if
%       relevant) and processing from input header ***
%     vars_units_header: Nx4 cell array specifying (scalar) variables to
%       add to header (see vars_units above for format) ***from input
%       header?***
%


%m_common; mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
status = 0;

if nargin>2
    params = varargin{1};
end
params.in = intype;
params.out = outtype;

if strcmp(params.in,'ctd') && strcmp(params.out,'bodc')
    params.out = 'mstar'; %no defined bodc ctd .csv format
end
if isfield(params,'header') && ischar(params.header)
    params.header = {params.header};
end
% set or modify parameters according to the type of input and output
params = mout_columns_defaults(params);

params0 = params; %in case different variables in each file
kloop = params.stnlist(1);
while kloop<=length(params.stnlist)

    %load and modify (grid, derive variables) data, put into table dtab
    [dtab, params] = mout_columns_prepare_data(params, kloop);
    if isempty(dtab)
        kloop = kloop+1;
        continue
    end

    if isfield(params,'vars_units') && size(params.vars_units,2)==4
        %limit list of variables to write according to what's available
        varn = dtab.Properties.VariableNames;
        m = ismember(params.vars_units(:,1),varn);
        params.vars_units = params.vars_units(m,:);
        %make sure there are no duplicate column names other than 'blank'
        %in vars_units
        ii = find(~strcmp('blank',params.vars_units(:,1)));
        [~,ia,~] = unique(params.vars_units(ii,1),'stable');
        if length(ia)<length(ii)
            ii = ii(setdiff(1:length(ii),ia));
            params.vars_units(ii,:) = [];
        end
        %get rid of extra automatically generated 'blank's from vars_units
        if isfield(params,'lastblank') && isnumeric(params.lastblank) && params.lastblank>=0
            ii = find(~strcmp('blank',params.vars_units(:,1)));
            params.vars_units(ii(end)+params.lastblank+1:end,:) = [];
        end
        %option to use own units, or check consistency of units?***
    else
        %construct name-units-format string lookup
        params = get_vars_units(params, dtab);
    end

    %%% write %%%

    %open csv file
    if strcmp(params.in,'ctd')
        if strcmp(params.out,'exch')
            h.statnum = params.stnlist{kloop};
        end
    else
        params.stn_string = '';
    end
    outfile = sprintf('%s%s%s.csv',params.csvpre,params.stn_string,params.csvpost);
    if exist(outfile, 'file')
        delete(outfile);
        fid = fopen(outfile,'w');
    else
        fid = fopen(outfile,'w');
    end
    mfixperms(outfile);

    %write header
    if isfield(params,'header')
        fprintf(fid, '%s\n', params.header{:});
    end
    for hno = 1:size(params.varsh,1)
        if isfield(h,params.varsh{hno,3})
            fprintf(fid, ['%s = ' params.varsh{hno,4} '\n'], upper(params.varsh{hno,1}), h.(params.varsh{hno,3}));
        else
            fprintf(fid, ['%s = ' params.varsh{hno,4} '\n'], upper(params.varsh{hno,1}), params.extrah.(params.varsh{hno,3}));
        end
    end

    %column header rows: variable names and units
    str1 = strjoin(params.vars_units(:,2),',');
    str2 = strjoin(params.vars_units(:,3),',');
    fprintf(fid,'%s\n%s\n',str1,str2);
    %fprintf(fid, '%s, ', params.vars_units{1:end-1,2});
    %fprintf(fid, '%s\n', params.vars_units{end,2});
    %%and units
    %fprintf(fid, '%s, ', params.vars_units{1:end-1,3});
    %fprintf(fid, '%s\n', params.vars_units{end,3});

    %data rows
    iir = 1:params.nr;
    for sno = iir
        %print (fid, '%format, ', data column))
        for cno = 1:size(params.vars_units,1)-1
            fprintf(fid, [params.vars_units{cno,4} params.sep], dtab.(params.vars_units{cno,1})(sno,:));
        end
        fprintf(fid, [params.vars_units{end,4} '\n'], dtab.(params.vars_units{end,1})(sno,:));
    end

    %finish up
    if isfield(params,'footer')
        fprintf(fid, '%s', params.footer);
    end
    fclose(fid); mfixperms(outfile);

    if strcmp(params.in,'ctd')
        disp(['file ' num2str(kloop) ' written'])
    end
    status = 1;
    params = params0; %in case different variables in each file
    if strcmp(params.in,'sam')
        kloop = inf; %only one input file so stop loop after this
    else
        kloop = kloop+1;
    end

end

%%%%%%%%%%%%%%%% subfunctions %%%%%%%%%%%%%%%%%%

function params = get_vars_units(params, dtab)
%params = get_vars_units(params, fn, vars);
% takes single-column input list of variables in either params.vars_units
% or names of dtab, and adds columns for: output variable names (same),
% output variable units, output format string

varn = dtab.Properties.VariableNames(:);
varu = dtab.Properties.VariableUnits(:);

if ~isfield(params,'vars_units')
    params.vars_units = [varn varn varu];
else
    [~,ia,ib] = intersect(params.vars_units,varn,'stable');
    params.vars_units = [params.vars_units(ia,:) varn(ib) varu(ib)];
end
params.vars_units(:,4) = {'%f'}; %default

%where possible, get format strings from m_exch_vars_list.m
exvars = m_exch_vars_list(params.in); exvars = exvars(:,[3 1 2 4]);
[~,ia,ib] = intersect(params.vars_units(:,1),exvars(:,1));
params.vars_units(ia,3:4) = exvars(ib,3:4); 



