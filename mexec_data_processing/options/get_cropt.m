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

%continue to set cruise-specific options
cfile = sprintf('opt_%s',mcruise);
if exist([cfile '.m'],'file')
    eval(cfile)
elseif ~isfield(MEXEC_G,'no_cruise_options_file') || ~MEXEC_G.no_cruise_options_file
    c = input(sprintf('%s.m not found; create now?  ',cfile),'s');
    if strncmp(c,'y',1)
        generate_cruise_opt_script(cfile)
        eval(cfile)
    else
        warning('skipping %s, default parameters only until MEXEC_G is cleared',cfile)
        MEXEC_G.no_cruise_options_file = 1;
    end
end

%check_cropt. required: year, Mship and PLATFORM_IDENTIFIER (and warn if no
%Mshipdatasystem)***

clear opt1 opt2