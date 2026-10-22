% this script creates, if it does not exist, a cruise options file for the
% current MEXEC_G.cruise, MEXEC_G.opt_cruise (often referred to as the
% opt_cruise file), initialising it with default settings, some of which
% depend on the datatypes and ship underway system settings specified in
% MEXEC_G  
% it is normally called by m_setup initially, but can be re-run to restart
% the file
%
% the cruise options files are called by many of the mexec_data_processing 
% scripts, and are used to 
%   a) set processing parameters such as settings for data cleaning (valid
%     data ranges, despiking parameters, etc.) and averaging (bin length,
%     treatment of missing data, etc.), calibration coefficients, and more, 
%     that will be applied by the calling function(s)  
%   b) execute code to perform operations in the midst of the calling 
%     function(s), for instance to perform a custom (cruise-specific) 
%     renaming of a variable from a particular input file -- this is the 
%     reason that they are scripts
%
% in the opt_cruise files options are specified by layered switch-cases
% starting with string opt1 
% opt1 can be 'ctd_proc', 'uway_proc', 'samp_proc', ***
% within each opt1 case, there is often another switch-case on opt2, also a
% string, which for ease of searching should be unique rather than reused
% between different opt1 cases; for some (e.g. opt1 = 'samp_proc') there 
% may be a further switch-case layer, (e.g. on the parameter type)
% 
%

if ~exist('MEXEC_G','var')
    if exist('m_common.m','file')
        m_common
    else
        error('you probably need to run m_setup')
    end
end

%cruise options file
fp = fileparts(which(mfilename));
cofile = fullfile(fp, 'cruise_opt_scripts', MEXEC_G.opt_cruise);
if exist([cofile '.m'],'file')
    warning('%s exists in %s/cruise_opt_scripts',MEXEC_G.opt_cruise,fp)
    cr = input('do you want to overwrite it? (y/n)  ','s');
    if ~strcmp(cr,'y')
        return
    end
elseif ~isempty(which(MEXEC_G.opt_cruise))
    warning('%s exists on path, but not where it is expected to be; skipping')
    return
end

%where to get defaults from
deffile = fullfile(fp,'defaults','mexec_defaults_all.m');
d = fieldnames(MEXEC_G.datatypes);
for no = 1:length(d)
    %specific defaults
    if ~strcmp(MEXEC_G.datatypes.(d{no}),'no')
        ddeffiles.(d{no}) = fullfile(fp,'defaults',['mexec_defaults_' d{no} '_' MEXEC_G.datatypes.(d{no}) '.m']);
    end
end


fprintf(1,'initialising %s based on %s\n', cofile, deffile)
cfid = fopen(cofile,'w');
fprintf(cfid,'%s processing settings for cruise %s\n\n','%',MEXEC_G.mcruise);
%first write selected fields from current MEXEC_G as comments
fprintf(cfid,'%s at the time this file was initialised, MEXEC_G included:\n','%');
fn = fieldnames(MEXEC_G.datatypes);
for no = 1:length(fn)
    fprintf(cfid,'%s datatypes.%s: ''%s''\n','%',fn{no},MEXEC_G.datatypes.(fn{no}));
end
fprintf(cfid,'%s data_time_origin_string: ''%s''\n','%',MEXEC_G.data_time_origin_string);
fprintf(cfid,'%s mexec_version: ''%s''\n\n','%',MEXEC_G.mexec_version);


%read in deffile to find the starting line (below initial comments)
cont = true;
foundstart = false;
dfid = fopen(deffile, 'r');
while cont && ~foundstart
    s = fgets(dfid);
    if ~ischar(s); error('end of file reached before mcruise = MEXEC_G.mcruise;'); end
    if strncmp(s,'switch opt1',11)
        foundstart = true;
    end
end
%copy the starting line of deffile to cofile, then keep reading deffile and
%copying subsequent lines, except any line starting (after indentation)
%with 'placeholder_', which may trigger reading and copying in the contents
%of a different file setting datatype-specific defaults, before proceeding 
%through deffile 
fprintf(cfid,s);
while cont
    s = fgets(dfid);
    if ~ischar(s); break; end
    if strncmp(s,'        placeholder_',20)
        s = replace(strtrim(s),'placeholder_','');
        dtfile = fullfile(fp,'defaults',['mexec_defaults_' s '.m']);
        printed = false;
        if exist(dtfile,'file')
            tfid = fopen(dtfile,'r');
            tcont = true;
            while tcont
                l = fgets(tfid);
                if ~ischar(l); break; end
                fprintf(cfid,'    %s',l); %these all start with switch opt2, so print with extra indentation
                printed = true;
            end
            fclose(tfid);
        end
        if ~printed
            warning('no mexec_defaults_ file found for %s; skipping placeholder',s)
        end
    else
        fprintf(cfid,'%s',s);
    end
end
fclose(dfid);
fclose(cfid);

edit(MEXEC_G.opt_cruise)
fprintf(1,'initialised %s,\nnow make additional edits, then enter to continue',MEXEC_G.opt_cruise);
pause
run(MEXEC_G.opt_cruise)
