function names_units = mrjson_load_all(fntxt,varargin)
% function names_units = mrjson_load_all(fntxt)
% function names_units = mrjson_load_all(fntxt,outfile)
%
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
% 
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
%
%
% Load list of json files, load each file, decode, and run mrshow_json to
% print out to screen in format suitable for mrtables_from_json, as well as
% adding to names_units
%
% Examples
%
%   mrshow_json_all('list_json.txt')
%
% Input:
%
% Text file with list of roots of .json files to be read
% eg fntxt = 'list_json.txt';
% eg content might be
%    
% RANGER2_USBL-jc
% air2sea_gravity
% air2sea_s84
% at1m_u12
% cnav_gps-jc
% dps116_gps-jc
% 
% Files to be read might be
%
% cnav_gps-jc.json
% cnav_gps-jc.mat
% dps116_gps-jc.json
% dps116_gps-jc.mat
% 
% Output:
% 
% to outfile if specified, else to screen
%
% names_units : is a structure. Each field describes a table in rvdas.
%   The first call to mrshow_json writes, for example
%     names_units.posmv_pos_gpgga
%     names_units.posmv_pos_gpggk
%   The next call adds to names_units
%     names_units.posmv_gyro_prdid
%     names_units.posmv_gyro_pashr

% names_units has fieldnames that are rvdas table names
%   Each table name has fieldnames that are the variable names for that table
%   The contents of each variable name is a string equal to the variable units.

if nargin>1
    outfile = varargin{1};
    fid = fopen(outfile,'w');
    text_for_file = {'function [rtables,rtables_list] = mrtables_from_json';
        '% Make the list of rvdas tables that mexec may want to copy.';
        '% The rtables created in this script will define which variables are loaded';
        '% when a table is loaded from rvdas. Units are collected from the json files';
        '% The content of this file was obtained by using the script mrjson_load_all.m';
        '% Variables and/or tables can subsequently be commented out';
        '%';
        '% Examples';
        '%';
        '%   [rtables rtables_list]= mrtables_from_json';
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
        '%   to grab from rvdas are commented out.';
        '%';
        '% rtables_list is a cell array and is a list of the tables we have';
        '%   identified. So rtables_list = fieldnames(rtables).';
        ' ';
        'clear rtables rtables_list';
        ' '};
    fprintf(fid, '%s\n', text_for_file{:});
    fclose(fid);
end

names_units = []; 

fidl = fopen(fntxt,'r');
while 1
    tl = fgetl(fidl);

    if ischar(tl) %line contains (presumably) a file name
        jdata = [];
        [fp,fname,~] = fileparts(tl); %might or might not have full path and/or extension
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
        jdata = jdata(:)';
        js = jsondecode(jdata);
        js.filename = fname;
        if exist('outfile','var')
            names_units = mrjson_show(js, names_units, outfile);
        else
            names_units = mrjson_show(js, names_units);
        end
    else
        break
    end
end
fclose(fidl);

if exist('outfile','var')
    fid = fopen(outfile,'a');
    fprintf(fid,'\n%s\n','rtables_list = fieldnames(rtables);');
    fclose(fid);
end

