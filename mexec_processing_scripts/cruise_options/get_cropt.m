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
else
    warning([cfile '.m not found; probably needs to be created to set cruise-specific options'])
end

