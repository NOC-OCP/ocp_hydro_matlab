function names_units = mrshow_json_all(fntxt)
% function names_units = mrshow_json_all(fntxt)
%
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
% 
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
%
%
% Run function mrshow_json on a set of json/mat files
% Each run of mrshow_json adds to the names_units structure.
%
% Examples
%
%   mrshow_json_all('list_json.txt')
%
% Input:
%
% Text file with list of roots of .json files for conversion to .mat. 
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
% Files that would exist in this directory would include 
% (.mat file is read, .json file alrady exists)
% 
% cnav_gps-jc.json
% cnav_gps-jc.mat
% dps116_gps-jc.json
% dps116_gps-jc.mat
% 
% Output:
% 
% to screen
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

tlist = cell(0);
d = [];

fid = fopen(fntxt,'r');

while 1
    tl = fgetl(fid);
    if ~ischar(tl); break; end
    tlist = [tlist;tl];
end

fclose(fid);

nf = length(tlist);

for kl = 1:nf
    fnin = tlist{kl};
    fnin = [fnin '.mat'];
    d = mrshow_json(fnin,d);
end

names_units = d;

