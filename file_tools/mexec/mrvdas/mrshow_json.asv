function names_units = mrshow_json(varargin)
% function names_units = mrshow_json(fnmat,names_units)
%
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
% 
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
%
% Show the sentences in the rvdas json file (via .mat), and store variable
%   names and units.
%
% Examples
%
%   names_units = mrshow_json('posmv_gyro-jc')  % start a new names_units structure
%   names_units = mrshow_json('posmv_pos-jc',names_units) % add to the existing structure
%
% Input:
%
% fnmat is a .mat file that has been converted from .json to .mat by
%   jsondecode in matlab. This was introduced to matlab around 2016, so was
%   not available on koaeula on JR211. The conversion was done on BAK's mac.
%
% names_units is an optional argument. If present, the output names_units
%   is added to the input.
% 
% Output:
% 
% to screen: The content of the js structure loaded from the sentences in a
%   json file
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
%   Each table name has fieldnames that are the variable names for that table
%   The contents of each variable name is a string equal to the variable units.


fnmat = varargin{1};
clear d
if nargin == 2
    d = varargin{2};
end

load(fnmat);
fnroot = fnmat(1:end-4);  % 5 feb 2022 bak dy146 bug fix, previously end-3  

% % n_sentences = js.sentencesNo; % The seapath_pos json file 
% has sentencesNo set to 9, but it actually has 10 sentences.
n_sentences = length(js.sentences);
fprintf(1,'\n\n%s%s %2d%s\n','%',fnroot,n_sentences,'  sentences');


for ks = 1:n_sentences
    id = js.id; id = lower(id);
    s = js.sentences(ks);
    jsonname = s.name;
    talkId = s.talkId;
    messageId = s.messageId;
    noflds = length(s.field); %s.fieldNo;
    msg = lower([talkId messageId]);
    sqlname = [id '_' msg];
%     fprintf(1,'\n%s%s%s\n','"',jsonname,'"');
    fprintf(1,'\n%s%s%s%s\n','%','"',jsonname,'"'); % bak dy146 5 feb 2022 make this
    % output a comment for cut and paste
    str = ['rtables.' sqlname ' = {  % from ' fnroot '.json'];
    fprintf(1,'%s\n',str);
    fprintf(1,'%s %2d %s\n',['''' sqlname ''''],noflds,' % fields');
    for kf = 1:noflds
        sf = s.field(kf);
        if iscell(sf)
            f = s.field{kf};
        else
            f = s.field(kf);
        end
        fname = f.fieldNumber;
        funit = f.unit;
        fprintf(1,'%30s %30s\n',['''' fname ''''],['''' funit '''']);
        try
            d.(sqlname).(fname) = funit; % will fail if sqlname or fname are invalid. Some graivity meter json files define names that are invalid matab names, eg with spaces and starting with a number
        catch
            % ignore failures
        end
    end
    fprintf(1,'%s\n','};');
    
end

names_units = d;
return