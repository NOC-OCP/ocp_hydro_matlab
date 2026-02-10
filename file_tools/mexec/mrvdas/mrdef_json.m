function mrtables = mrdef_json(mrtables)
%
% names_units = mrdef_json(mrtables)
% read and parse .json files matching mrtables.tablenames

m_common

%update files
jsondir = fullfile(MEXEC_G.mexec_data_root,'rvdas','json_files');
if ~exist(jsondir,'dir')
    mkdir(jsondir); mfixperms(jsondir, 'dir');
end
RVDAS.jsondir = '';
opt1 = 'ship'; opt2 = 'rvdas_database'; get_cropt
switch MEXEC_G.Mship
    case 'sda'
        system(['rsync -au --delete ' RVDAS.jsondir '/ ' jsondir '/']);
    otherwise
        if isempty(RVDAS.jsondir)
            warning('relying on .json files already in %s', jsondir)
        elseif contains(RVDAS.jsondir,'pstar') %this is a link to shared drive mounted on workstation
            system(['rsync -au --delete ' RVDAS.jsondir '/ ' jsondir '/']);
        else %this must be a directory on the RVDAS computer itself
            system(['rsync -au --delete ' RVDAS.user '@' RVDAS.machine ':' RVDAS.jsondir '/ ' jsondir '/']);
        end
end

%list of instruments
opt1 = 'ship'; opt2 = 'rvdas_form'; get_cropt
if use_cruise_views
    sqlpre = [view_name '_'];
    instpos = 2;
else
    sqlpre = '';
    instpos = 1;
end

insts = cellfun(@(x) x{instpos}, ...
    cellfun(@(x) strsplit(x,'_'), mrtables.tablenames, ...
    'UniformOutput', false), 'UniformOutput', false);
%***something different for sda?
insts = unique(insts);

%for each instrument, look for a matching .json file, load, parse, and
%extract the units for variables corresponding to messages in
%mrtables
nt = length(mrtables.tablenames);
mrtables.tableunts = repmat({' '},nt,1);
mrtables.longnames = repmat({' '},nt,1);
for no = 1:length(insts)
    iit = find(strcmp(insts{no},mrtables.mstarpre));
    d = dir(fullfile(jsondir,['*' insts{no} '*.json']));
    if isempty(d)
        warning('no .json identified in %s for %s',jsondir,insts{no})
        for tno = 1:length(iit)
            mrtables.tableunts{iit(tno)} = cell(size(mrtables.tablevars{iit(tno)}));
            mrtables.longnames{iit(tno)} = mrtables.tableunts{iit(tno)};
        end
    else
        %look for the instrument-message combinations we care about
        n = 1;
        while n<=length(d) && ~isempty(iit)
            jsonfile = fullfile(jsondir,d(n).name);
            jdata = mrjson_parse(jsonfile, sqlpre); n = n+1;
            fn = fieldnames(jdata);
            for fno = 1:length(fn)
                iif = find(strcmp(fn{fno},mrtables.tablenames(iit)));
                if isscalar(iif)
                    vars = mrtables.tablevars{iit(iif)};
                    unts = repmat({' '},size(vars)); lnames = unts;
                    serial = unts; calfunc = unts; calcoef = unts; 
                    caled = unts; calunt = unts;
                    [~,ia,ib] = intersect(vars,jdata.(fn{fno}).vars);
                    unts(ia) = jdata.(fn{fno}).unts(ib);
                    lnames(ia) = jdata.(fn{fno}).longnames(ib);
                    serial(ia) = jdata.(fn{fno}).serial(ib);
                    calfunc(ia) = jdata.(fn{fno}).calibration_function(ib);
                    calcoef(ia) = jdata.(fn{fno}).calibration_coefficient(ib);
                    caled(ia) = jdata.(fn{fno}).calibration_applied(ib);                    
                    calunt(ia) = jdata.(fn{fno}).calibrated_units(ib);
                    m = cellfun('isempty', replace(unts,whitespacePattern,'')) & cellfun(@(x) length(x),calunt)>0;
                    if sum(m)
                        unts(m) = calunt(m);
                    end
                    mrtables.tableunts{iit(iif)} = unts;
                    mrtables.longnames{iit(iif)} = lnames;
                    mrtables.serials{iit(iif)} = serial;
                    mrtables.calfunc{iit(iif)} = calfunc;
                    mrtables.calcoef{iit(iif)} = calcoef;
                    mrtables.caled{iit(iif)} = caled;
                    iit(iif) = [];
                elseif length(iif)>1
                    warning('multiple matches for %s',fn{fno})
                    keyboard
                end
            end
        end
    end
end


% ---------------------------------------------
% subfunctions 
% ---------------------------------------------


%%%%%%%%% mrjson_parse %%%%%%%%%
function jdata = mrjson_parse(jsonfile, sqlpre)

%read in
jdata = [];
fidd = fopen(jsonfile,'r');
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
clear jdata

nsent = length(js.sentences);
id = lower(js.id);
for sno = 1:nsent
    s = js.sentences(sno);
    %jsonname = s.name;
    msg = lower([s.talkId s.messageId]);
    sqlname = [sqlpre id '_' msg];
    sf = struct2table(s.field,'AsArray',true);
    jdata.(sqlname).vars = lower(sf.fieldNumber);
    jdata.(sqlname).unts = sf.unit;
    m = ~cellfun(@ischar, sf.unit) | cellfun(@isempty, sf.unit);
    if sum(m)
        jdata.(sqlname).unts(m) = {' '};
    end
    jdata.(sqlname).longnames = sf.name;
    a = struct2table(sf.netcdf_attributes,'AsArray',true);
    jdata.(sqlname).serial = {a.instrument.serial_number};
    jdata.(sqlname).calibration_function = {a.calibrations.calibration_function};
    jdata.(sqlname).calibration_coefficient = {a.calibrations.calibration_coefficients};
    jdata.(sqlname).calibration_applied = {a.calibrations.calibration_applied};
    jdata.(sqlname).calibrated_units = {a.calibrations.output_units};
end
