function generate_cruise_opt_script(cfile)

m_common
fp = fileparts(which(mfilename));
fcfile = fullfile(fp, 'cruise_opt_scripts', [cfile '.m']);

try
    syr = input('cruise start year?  ');
    if ~isfield(MEXEC_G,'ctd')
        MEXEC_G.ctd = lower(input('CTD type: SBE or RBR?   ', 's'));
    end
    if isfield(MEXEC_G,'uway')
        if strcmp(MEXEC_G.uway,'auto')
            
        end
    else
        MEXEC_G.uway = lower(input('underway data system: RVDAS, TECHSAS, SCS_ASCII, SCS_NC?   ','s'));
    end
    if ~isfield(MEXEC_G,'ladcp')
        MEXEC_G.ladcp = lower(input('processing LADCP data with: IX or no?   ','s'));
    end

    fid = fopen(fcfile,'w');
    if ~isempty(MEXEC_G.ctd)
        fprintf(fid, 'mexec_defaults_%s\n', MEXEC_G.ctd);
    end
    if ~isempty(MEXEC_G.uway)
        fprintf(fid, 'mexec_defaults_%s\n', MEXEC_G.uway); %***or are all of these included in org defaults? not quite?  what about default_navstream etc.?
    end

    defs2 = {dir(fullfile(fp, 'defaults', 'mexec_defaults_org_*.m')).name};
    defs2 = cellfun(@(x) x(16:end-2), defs2, 'UniformOutput',false);
    disp(defs2)
    defs_use = input('after sensor/data system defaults, start with organisation-specific\ndefaults for CTD configuration, underway system, bottle sample files, etc.? \n(from above list)    ','s');
    if ~isempty(defs_use)
        if contains(defs_use,','); defs_use = strsplit(defs_use,','); else; defs_use = strsplit(defs_use,' '); end
        while ~isempty(defs_use)
            odfile = sprintf('mexec_defaults_%s',defs_use{1});
            if exist([odfile '.m'],'file')
                fprintf(fid,'%s\n',odfile);
            else
                warning('%s.m not found; not adding to %s',odfile,cfile)
            end
            defs_use(1) = [];
        end
    end
    
    fprintf(fid,'\n');
    fprintf(fid,'switch opt1\n    %s\n        switch opt2\n','case ''setup''');
    fprintf(fid,'            %s\n','case ''time_origin''');
    fprintf(fid,'                MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [%d 1 1 0 0 0];\n',syr);
    fprintf(fid,'            %s\n','case ''setup_datatypes''');
    fprintf(fid,'                MEXEC_G.ladcp=''%s'';', MEXEC_G.ladcp);
    fprintf(fid,'        end\nend');
    fclose(fid);
    fprintf(1,'initialised %s with MDEFAULT_DATA_TIME_ORIGIN,\n now make additional edits, then enter to continue',cfile)
    edit(cfile); pause

catch
    system(['touch ' fcfile]);
    fprintf(1,'could not initialise %s, edit now then enter to continue',cfile)
    edit(cfile); pause
end
