% preliminary steps to set up for rvdas processing
% run again if json files are updated
% 

jsondir = fullfile(MEXEC_G.mexec_data_root,'rvdas','json_files');
if ~exist(jsondir,'dir')
    mkdir(jsondir);
end
listfile = fullfile(jsondir,'list_json.txt');

%sync json files
system(['rsync -au --delete ' MEXEC_G.RVDAS.user '@' MEXEC_G.RVDAS.machine ':' MEXEC_G.RVDAS.jsondir '/ ' jsondir '/']);

%list them to file
if ~exist(listfile, 'file')
    system(['ls ' jsondir '/*.json > ' listfile]);
    disp('edit list of .json files, press any key to continue')
    pause
else
    warning('using existing list of .json files')
end

%read in each one and output for mrtables_from_json
p = fileparts(mfilename('fullpath'));
outfile = fullfile(p, 'mrtables_from_json.m');
names_units = mrjson_load_all(listfile, outfile);
