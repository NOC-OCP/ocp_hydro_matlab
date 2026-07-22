% this script is called by others to set options: parameters/variables
%     dependent on cruise, ship, section, etc.
%
% options are specified by switch-case through two
% variables:
%     opt1 (often but not always the name of the calling script)
%     opt2 (another string, which for ease of searching should be
%         unique, not reused between different opt1 cases)
%
% otherwise (normally), get_cropt will:
%   call mexec_defaults_all
%   call the cruise-specific options script (opt_{cruise}, e.g. opt_jc211)
%     to make any cruise-specific changes
%


if ~exist('MEXEC_G','var')
    if exist('m_common.m','file')
        m_common
    else
        error('you probably need to run m_setup')
    end
end
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

%set defaults
mexec_defaults_all

%set cruise-specific options
cfile = sprintf('opt_%s',mcruise);

if exist([cfile '.m'],'file')
    %by running existing opt_cruise file
    eval(cfile)

elseif ~isfield(MEXEC_G,'no_cruise_options_file') || ~MEXEC_G.no_cruise_options_file
    %by creating and then running opt_cruise file
    c = input(sprintf('%s.m not found; create now?  ',cfile),'s');

    if strncmp(c,'y',1)    
        fp = fileparts(which(mfilename));
        fcfile = fullfile(fp, 'cruise_opt_scripts', [cfile '.m']);
        
            fid = fopen(fcfile,'w');
            % dt = MEXEC_G.datatypes;
            % dtn = fieldnames(dt);
            % for dtno = 1:length(dtn)
            %     dfile = sprintf('mexec_defaults_%s',dt.(dtn{dtno}));
            %     if exist([dfile '.m'],'file')
            %     fprintf(fid,'%s\n',dfile)
            %     else
            %         warning('defaults file for %s data type %s not found',dtn{dtno},dt.(dtn{dtno}))
            %     end
            % end
            syr = input('cruise start year?  ');
            oo.setup.time_origin = sprintf('MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [%d 1 1 0 0 0];',syr);
            fprintf(fid,'\nswitch opt1\n\n');
            o1 = fieldnames(oo);
            for no1 = 1:length(o1)
                fprintf(fid,'    case ''%s''\n        switch opt2\n',o1{no1});
                o2 = fieldnames(oo.(o1{no1}));
                for no2 = 1:length(o2)
                    fprintf(fid,'            case ''%s''\n                %s\n',o2{no2},oo.(o1{no1}).(o2{no2}));
                end
                fprintf(fid,'        end\n\n');
            end
            fprintf(fid,'end\n');
            fclose(fid);
            fprintf(1,'initialised %s,\nnow make additional edits, then enter to continue',cfile)
            edit(cfile); pause
        %catch
        %    system(['touch ' fcfile]);
        %    fprintf(1,'could not initialise %s, edit now then enter to continue',cfile)
        %    edit(cfile); pause
        %end
        eval(cfile)

    else
        warning('skipping %s, default parameters only until MEXEC_G is cleared',cfile)
        MEXEC_G.no_cruise_options_file = 1;
    end

end

clear opt1 opt2