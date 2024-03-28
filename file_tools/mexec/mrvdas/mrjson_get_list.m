% preliminary steps to set up for rvdas processing
% run again if json files are updated
% 

jsondir = fullfile(MEXEC_G.mexec_data_root,'rvdas','json_files');
if ~exist(jsondir,'dir')
    mkdir(jsondir);
end
listfile = fullfile(jsondir,'..','list_json.txt');

%sync json files
opt1 = 'ship'; opt2 = 'rvdas_database'; get_cropt
switch MEXEC_G.Mship
    case 'sda'
        system(['rsync -au --delete ' RVDAS.jsondir '/ ' jsondir '/']);
    otherwise
        if contains(RVDAS.jsondir,'pstar')
            system(['rsync -au --delete ' RVDAS.jsondir '/ ' jsondir '/']);
        else
            system(['rsync -au --delete ' RVDAS.user '@' RVDAS.machine ':' RVDAS.jsondir '/ ' jsondir '/']);
        end
end

%list them to file
if ~exist(listfile, 'file')
    system(['ls ' jsondir '/*.json > ' listfile]);
    fprintf(1,'edit list of .json files in\n %s,\n then press any key to continue\n',listfile);
    pause
else
    warning('using existing list of .json files')
end

%read in each one and output for mrtables_from_json
p = fileparts(mfilename('fullpath'));
outfile = fullfile(p, 'mrtables_from_json.m');
names_units = mrjson_load_all(listfile, outfile);
