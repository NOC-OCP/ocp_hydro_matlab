function js = mrjson2mat(fnjson)
% function js = mrjson2mat(fnjson)
%
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
% 
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
%
% Decode a .json file to a .mat file
%
% There are .json files that describe the tables in the rvdas databse.
%   There is one json file for each data source, eg one file for the posmv.
%   That single json file might describe how to store meny different NMEA
%   messages from the posmv. These are known as sentences inside the json
%   file. This function decodes each json file and returned a structure,
%   js, that captures all the sentences.
%
% Needs the matlab function jsondecode, introduced around matlab 2016.
%   jsondecode was not available in matlab2015b on koaeula on JC211,
%   so the fucntion was run on BAK's mac.
%
% Examples
%
%   js = mrjson2mat(fnjson);
%
% Input:
%
% fnjson is a .json file that contains a number of 'sentences'. Each
%   sentence describes a table in the rvdas database that is associated with
%   the data source. eg 'cnav_gps-jc.json' describes 11 sentences including
%    cnav_gps_gngga
%    cnav_gps_gngll
% 
% Output:
% 
% js is a structure that can be saved to a corresponding .mat file
%    cnav_gps-jc.mat


fid = fopen(fnjson,'r');

tlist = [];
while 1
    tl = fgetl(fid);
    if ~ischar(tl); break; end
    tlist = [tlist tl];
end

fclose(fid);

d = tlist;  % tlist is  simple character array, concatenate the whole json definition into one long string, and then it can be decoded
% c = char(d);
c = d;
c = c(:)';
js = jsondecode(c);
return