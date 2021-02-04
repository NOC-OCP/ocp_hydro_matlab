function mrjson2mat_all(fntxt)
% function mrjson2mat_all(fntxt)
%
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
% 
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
%
% Run function mrjson2mat on a set of json files
%
% Each run of mrjson2mat returns a structure js. In this function, that
%   structure js is saved as a .mat file.
%
% Examples
%
%   mrjson2mat_all('list_json.txt')
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
% (.json file is read, .mat file is created as output)
% 
% cnav_gps-jc.json
% cnav_gps-jc.mat
% dps116_gps-jc.json
% dps116_gps-jc.mat
% 
% Output:
% 
% .mat file is created for each .json file
% 
% On JC211, the original json files were in 
% /home/rvdas/ingester/ingester/sensorfiles/jc on rvdas machine
% These were copied to BAK's mac for converting to matlab files


tlist = cell(0);

fid = fopen(fntxt,'r');

while 1
    tl = fgetl(fid);
    if ~ischar(tl); break; end
    tlist = [tlist;tl];
end

fclose(fid);

nf = length(tlist);

for kl = 1:nf
    fnroot = tlist{kl};
    fnot = fnroot;
    fnin = [tlist{kl} '.json'];
    fprintf(1,'%s %s \n','Loading file ',fnin);
    js = mrjson2mat(fnin);
%     cmd = ['save ' fnot ' js']; eval(cmd)
    save(fnot,'js'); % bak: syntax changed from line above while tidying up but not yet tested.
    
end

fprintf(1,'%d %s \n',nf,' json files converted');