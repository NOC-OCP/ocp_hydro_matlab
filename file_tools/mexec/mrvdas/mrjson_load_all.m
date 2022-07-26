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
