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
%   call set_mexec_defaults
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
set_mexec_defaults

%continue to set cruise-specific options
cfile = sprintf('opt_%s',mcruise);
if exist([cfile '.m'],'file')
    eval(cfile)
elseif ~isfield(MEXEC_G,'no_cruise_options_file') || ~MEXEC_G.no_cruise_options_file
    c = input(sprintf('%s.m not found; create now?  ',cfile),'s');
    if strncmp(c,'y',1)
        fp = fileparts(which(mfilename));
        fcfile = fullfile(fp, [cfile '.m']);
        try
            syr = input('cruise start year?  ');
            fid = fopen(fcfile,'w');
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
        eval(cfile)
    else
        warning('skipping %s, default parameters only until MEXEC_G is cleared',cfile)
        MEXEC_G.no_cruise_options_file = 1;
    end
end

