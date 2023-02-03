function names_units = mrjson_load_all(json_list,varargin)
% function names_units = mrjson_load_all(json_list)
% function names_units = mrjson_load_all(json_list,outfile)
%
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
%
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
%
% For each .json file in json_list, if it is not in the table_skip list
%   (set by setdef_cropt_uway and opt_cruise), load and call jsondecode,
%   then pass to mrjson_show, which will loop through the sentences (except
%   those matching the sentences_skip and msg_skip lists) and write out the
%   variables and units (except those matching the var_skip,
%   sentence_var_skip, and pat_skip lists)
%
% Input: 
%   json_list, cell array or name of text file listing the .json files (and
%     paths, with or without extension) 
%   [optional] outfile, (path and) name of .m file to which to write
%     results
%
% Output:
%
% names_units : is a structure. Each field describes a table in rvdas.
%   The first call to mrshow_json writes, for example
%     names_units.posmv_pos_gpgga
%     names_units.posmv_pos_gpggk
%   The next call adds to names_units
%     names_units.posmv_gyro_prdid
%     names_units.posmv_gyro_pashr
%
% names_units has fieldnames that are rvdas table names
%   Each table name has fieldnames that are the variable names for that table
%   The contents of each variable name is a string equal to the variable units.

if nargin>1
    %write initial function-defining text to file
    outfile = varargin{1};
    fid = fopen(outfile,'w');
    text_for_file = {'function rtables = mrtables_from_json';
        '% function rtables = mrtables_from_json';
        '% Make the list of rvdas tables that mexec may want to copy.';
        '% The rtables created in this script will define which variables are loaded';
        '% when a table is loaded from rvdas. Units are collected from the json files';
        '% The content of this file was obtained by using the script mrjson_load_all.m';
        '% Variables and/or tables can subsequently be commented out';
        '%';
        '% Examples';
        '%';
        '%   rtables= mrtables_from_json; %list of tables to use';
        '%   [rtables, ctables] = mrtables_from_json; %list of tables to use, and list of commented-out tables';
        '%';
        '% Input:';
        '%';
        '%   None';
        '%';
        '% Output:';
        '%';
        '% rtables is a structure. Each field is a cell array. The name of the';
        '%   is the rvdas table name. The content of each field is an Nx2 cell array.';
        '%   Element {1,1} is the rvdas table name. The remaining rows are the ';
        '%   variable names and units we are interested in. Variables we do not wish';
        '%   to grab from rvdas are commented out and may be listed by supplying the';
        '%   optional second output argument ctables.';
        ' '};
    fprintf(fid, '%s\n', text_for_file{:});
    fclose(fid);
end

if ~iscell(json_list) %read in file
    if exist(json_list,'file')
        fidl = fopen(json_list,'r');
        json_list = {}; %fill in cell array instead, now we have file pointer
        while 1
            tl = fgetl(fidl);
            if ischar(tl) %line contains (presumably) a file name
                json_list = [json_list; tl];
            else
                break
            end
        end
        fclose(fidl);
    end
end

names_units = [];

%find the .json files and messages to skip (from cruise options, and based
%on MEXEC_G.Mship) 
scriptname = 'mrvdas_ingest'; oopt = 'rvdas_skip'; get_cropt

%loop through .json files
for jno = 1:length(json_list)

    [fp,fname,~] = fileparts(json_list{jno});

    %skip this table?
    ii = strfind(fname,'-');
    if ~isempty(ii) && sum(strncmpi(fname(1:ii(1)-1),table_skip,ii(1)-1))
        continue 
    end
    
    jdata = [];
    fidd = fopen(fullfile(fp,[fname '.json']),'r');
    while 1
        td = fgetl(fidd);
        if ischar(td)
            jdata = [jdata td];
        else
            break
        end
    end
    fclose(fidd);

    js = jsondecode(jdata(:)');
    %compare to table_skip again in case file names don't match id field
    if sum(strncmpi(js.id,table_skip,length(js.id)))
        continue
    end
    
    js.filename = fname;
    if exist('outfile','var')
        names_units = mrjson_show(js, names_units, outfile);
    else
        names_units = mrjson_show(js, names_units);
    end
    
end


function names_units = mrjson_show(varargin)
% function names_units = mrjson_show(fnmat,names_units)
% function names_units = mrjson_show(js,names_units,outfile)
%
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
% 
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
%
% Show the sentences in the rvdas json file (via .mat or structure via
% jsondecode), and store variable names and units.
%
% Examples
%
%   names_units = mrjson_show('posmv_gyro-jc')  % start a new names_units structure
%   names_units = mrjson_show('posmv_pos-jc',names_units) % add to the existing structure
%   names_units = mrjson_show(js, names_units) %pass structure as in
%       mrshow_json_all.m
%
% Input:
%
% fnmat is a .mat file that has been converted from .json to .mat by
%   jsondecode in matlab. This was introduced to matlab around 2016, so was
%   not available on koaeula on JR211. The conversion was done on BAK's mac.
% OR
% js is a structure generated by jsondecode
%
% names_units is an optional argument. If present, the output names_units
%   is added to the input.
% 
% Output:
% 
% to outfile if specified, else to screen: The relevant content of the js
%   structure loaded from the sentences in a json file;
%   variables set (by cruise options) to be skipped (those matching the
%   var_skip, pat_skip, or sentence_var_skip lists) will be omitted from
%   names_units and commented out in outfile
%
% names_units : is a structure. Each field describes a table in rvdas.
%   The function writes, for example
%     names_units.posmv_pos_gpgga
%     names_units.posmv_pos_gpggk
%   If the next call has names_units as an input argument, the next set of
%        tables from the next json/mat file will be added.
%     names_units.posmv_gyro_prdid
%     names_units.posmv_gyro_pashr

% names_units has fieldnames that are rvdas table names
%   Each table name has fieldnames that are the variable names for that
%   table; each variable name has two fields, units and long_name, whose
%   contents are the variable units and long name (js.sentences.name)

if isstruct(varargin{1})
    js = varargin{1};
elseif ischar(varargin{1}) && exist(varargin{1},'file')
    load(varargin{1})
    [~,fname,~] = fileparts(varargin{1});
    js.filename = fname; %fnroot
end
for no = 2:nargin
    if isstruct(varargin{no})
        names_units = varargin{no};
    elseif ischar(varargin{no})
        outfile = varargin{no};
    end
end

if exist('outfile','var')
    fid = fopen(outfile,'a');
else
    fid = 1;
end

n_sentences = length(js.sentences);
id = js.id; id = lower(id);
fprintf(fid,'\n\n%s%s %2d%s\n','%',js.filename,n_sentences,'  sentences');

specchar = {' ', ',', '''', ';'};

scriptname = 'mrvdas_ingest'; oopt = 'use_cruise_views'; get_cropt
if use_cruise_views
    sqlpre = [view_name '_'];
else
    sqlpre = '';
end

scriptname = 'mrvdas_ingest'; oopt = 'rvdas_skip'; get_cropt
for ks = 1:n_sentences

    s = js.sentences(ks);
    jsonname = s.name;
    talkId = s.talkId;
    messageId = s.messageId;
    noflds = length(s.field); %s.fieldNo;
    msg = lower([talkId messageId]);
    sqlname = [sqlpre id '_' msg];
    %skip this sentence?
    if sum(strcmpi(msg,msg_skip)) || sum(strcmpi(sqlname,sentence_skip))
        continue
    end

    str = ['rtables.' sqlname ' = {  % from ' js.filename '.json'];
    fprintf(fid,'\n%s%s%s%s\n','%','"',jsonname,'"'); % make this output a comment for cut and paste
    fprintf(fid,'%s\n',str);
    fprintf(fid,'%s %2d %s %s\n',['''' sqlname ''''],noflds,'[]',' % fields');

    for kf = 1:noflds
        sf = s.field(kf);
        if iscell(sf)
            f = s.field{kf};
        else
            f = s.field(kf);
        end
        fname = f.fieldNumber;
        longname = replace(f.name, specchar, '_');
        if isfield(f,'units'); funit = f.units; else; funit = f.unit; end
        
        skipit = false;
        if ~isempty(var_skip)
            skipit = skipit || sum(strcmpi(fname,var_skip));
        end
        if ~isempty(sentence_var_skip)
            skipit = skipit || sum(strcmpi([sqlname '_' fname],sentence_var_skip));
        end
        if ~isempty(pat_skip)
            skipit = skipit || sum(contains(fname,pat_skip,'IgnoreCase',true));
        end
        if skipit
            fprintf(fid,'%s %28s %30s %80s\n','%',['''' fname ''''],['''' funit ''''],['''' longname '''']);
        else
            fprintf(fid,'%30s %30s %80s\n',['''' fname ''''],['''' funit ''''],['''' longname '''']);
            try
                names_units.(sqlname).(fname).units = funit; % will fail if sqlname or fname are invalid. Some gravity meter json files define names that are invalid matab names, eg with spaces and starting with a number
                names_units.(sqlname).(fname).long_name = longname;
            catch
                sqlname = matlab.lang.makeValidName(sqlname);
                fname = matlab.lang.makeValidName(fname);
                names_units.(sqlname).(fname).unit = funit;
                names_units.(sqlname).(fname).long_name = longname;
            end
        end
    end
    fprintf(fid,'%s\n','};');
    
end
if fid~=1; fclose(fid); end

