function generate_cruise_opt_script(cfile)

fp = fileparts(which(mfilename));
        fcfile = fullfile(fp, 'cruise_opt_scripts', [cfile '.m']);
        try
            syr = input('cruise start year?  ');
            ctd = lower(input('CTD type: SBE or RBR?   ', 's'));
            uway = lower(input('underway data system: RVDAS, TECHSAS, SCS_ASCII, SCS_NC?   ','s'));
            defs2 = {dir(fullfile(fp, 'defaults', 'mexec_defaults_org_*.m')).name};
            defs2 = cellfun(@(x) x(16:end-2), defs2, 'UniformOutput',false);
disp(defs2)
            defs_use = input('start with organisation-specific defaults for CTD configuration, underway system, bottle sample files, etc.?  (from above list)','s');
            fid = fopen(fcfile,'w');
            if ~isempty(defs_use)
                defs_use = strsplit(defs_use,',');
                while ~isempty(defs_use)
                    odfile = sprintf('mexec_defaults_org_%s',defs_use{1});
                    if exist([odfile '.m'],'file')
                fprintf(fid,'%s\n',odfile);
                    else
                        warning('%s.m not found; not adding to %s',odfile,cfile)
                    end
                    defs_use(1) = [];
                end
            end
            if ~isempty(ctd)
                fprintf(fid, 'mexec_defaults_%s\n', ctd);
            end
            if ~isempty(uway)
                fprintf(fid, 'mexec_defaults_%s\n', uway); %***or are all of these included in org defaults? not quite?  what about default_navstream etc.? 
            end
            fprintf(fid,'\n');
            fprintf(fid,'switch opt1\n    %s\n        switch opt2\n            %s\n','case ''setup''','case ''time_origin''');
            fprintf(fid,'                MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [%d 1 1 0 0 0];\n',syr);
            fprintf(fid,'        end\nend');
            fclose(fid);
            fprintf(1,'initialised %s with MDEFAULT_DATA_TIME_ORIGIN,\n now make additional edits, then enter to continue',cfile)
            edit(cfile); pause
        catch
            system(['touch ' fcfile]);
            fprintf(1,'could not initialise %s, edit now then enter to continue',cfile)
            edit(cfile); pause
        end
