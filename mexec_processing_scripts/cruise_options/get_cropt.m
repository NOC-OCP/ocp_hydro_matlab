% this script is called by others to set options: parameters/variables
%     dependent on cruise, ship, section, etc.
%
% options are specified by switch-case through two
% variables:
%     scriptname (almost but not quite always the name of the calling script)
%     oopt (another string, which for ease of searching should be
%         unique, not reused between different scriptname cases)
%
% set help_cropt = 1 to get information on options (more detail below)
%
% otherwise (normally), get_cropt will:
%   call the setdef_cropt_? scripts to set defaults
%       (split into 4 scripts for easier editing; broadly,
%       setdef_cropt_cast contains defaults related to ctd data processing,
%       setdef_cropt_sam contains defaults related to sample ingestion,
%       setdef_cropt_other contains defaults related to ctd/sample mapping,
%       plotting, and non-mstar output files,
%       setdef_cropt_uway contains defaults related to underway data)
%   call the cruise-specific options script (opt_cruise, e.g. opt_jc211)
%     to make any cruise-specific changes
%   call check_cropt to warn if expected options have not been set in
%     either setdef_cropt or opt_cruise ***and other things like correct
%     cruise in calstructure? useful cal pars?***
%
% help mode (when help_cropt set to 1) can be called three ways:
%
% 1) with empty scriptname and oopt, e.g.
%     >> help_cropt = 1; scriptname = ''; oopt = ''; get_cropt
%       displays the full list of scriptnames and oopts in setdef_cropt
%
% 2) with scriptname but empty oopt, e.g.
%     >> help_cropt = 1; scriptname = 'mctd_02b'; oopt = ''; get_cropt
%       displays the list of (scriptname, oopt) pairs in mctd_02b.m:
%         scriptname = mfilename; oopt = 'raw_corrs'; get_cropt
%         scriptname = 'castpars'; oopt = 'oxyvars'; get_cropt
%         scriptname = mfilename; oopt = 'oxyrev'; get_cropt
%         scriptname = mfilename; oopt = 'oxyrev'; get_cropt
%         scriptname = mfilename; oopt = 'oxyhyst'; get_cropt
%         scriptname = mfilename; oopt = 'oxyhyst'; get_cropt
%         scriptname = mfilename; oopt = 'turbVpars'; get_cropt
%       (mfilename gives the name of the current script, so in this example
%       is equivalent to scriptname = 'mctd_02b')
%     >> help_cropt = 1; scriptname = 'castpars'; oopt = ''; get_cropt
%       (because there is no castpars.m) displays the list of scripts calling
%       get_cropt with scriptname = 'castpars', along with the oopts used:
%         mbot_00.m:scriptname = 'castpars'; oopt = 'nnisk'; get_cropt
%         mctd_02b.m:scriptname = 'castpars'; oopt = 'oxyvars'; get_cropt
%         mctd_checkplots.m:scriptname = 'castpars'; oopt = 'oxyvars'; get_cropt; nox = size(oxyvars,1);
%         mctd_rawshow.m:scriptname = 'castpars'; oopt = 'oxyvars'; get_cropt; nox = size(oxyvars,1);
%
% 3) with scriptname and oopt, e.g.
%     >> help_cropt = 1; scriptname = 'mctd_03'; oopt = 's_choice'; get_cropt
%       displays the corresponding help message from this case of setdef_cropt:
%         's_choice (default 1) sets the primary sensor for temperature and conductivity; '
%         'stns_alternate_s (default []) lists stations on which to use the other one. if there is '
%         'only one CTD, keep the default (1).'


if ~exist('MEXEC_G','var')
    if exist('m_common.m','file')
        m_common
    end
end
if exist('MEXEC_G','var')
    mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
end

if ~exist('help_cropt', 'var') || ~help_cropt %normal, use-in-scripts mode
    
    %set defaults
    setdef_cropt_cast %defaults for ctd scripts
    setdef_cropt_sam %defaults for sample scripts
    setdef_cropt_uway %defaults for underway scripts
    setdef_cropt_other %others (sections, plots, ladcp, summaries)
    
    %continue to set cruise-specific options
    if exist(['opt_' mcruise '.m'],'file')==2
        eval(['opt_' mcruise]);
    else
        disp(['opt_' mcruise '.m not found; probably needs to be created to set cruise-specific options'])
    end
    
    % check and warn for unset options
    check_cropt
    
else %help mode
    
    if ~isunix
        clear help_cropt
        error('help mode uses grep and does not currently work on windows')
        
    elseif ~exist('scriptname','var') || isempty(scriptname)
        %called to get list of scriptnames and oopts
        dm = which('m_setup'); dm = [dm(1:end-9) '/mexec_processing_scripts'];
        dc = pwd;
        try
            cd(dm);
            [st, slist] = system('grep case cruise_options/setdef_cropt_*.m | grep -v switch');
            cd(dc);
            more on
            disp('these are the scriptnames and oopts (the latter indented) with settings under get_cropt')
            disp(slist)
            more off
        catch me
            throw(me)
        end
        
    elseif ~exist('oopt', 'var') || isempty(oopt)
        
        %called to get list of options for specific scriptname
        f = which(scriptname);
        
        if ~isempty(f) %show calls to get_cropt in m-file scriptname.m
            [st, olist] = unix(['grep cropt ' f ]);
            disp(['calls to get_cropt in ' scriptname '.m:'])
            disp(olist)
            
        else %show calls to get_cropt with scriptname in all m-files in mexec_processing_scripts and subdirectories
            dm = which('m_setup'); dm = dm(1:end-9);
            dc = pwd;
            try
                cd(dm);
                [~, slist1] = unix(['grep ' scriptname ' *.m | grep oopt | grep -v cruise_options']);
                [~, slist2] = unix(['grep ' scriptname ' */*.m | grep oopt | grep -v cruise_options']);
                [~, slist3] = unix(['grep ' scriptname ' */*/*.m | grep oopt | grep -v cruise_options']);
                cd(dc);
                disp(['mexec_processing_scripts that call get_cropt with scriptname = ''' scriptname ''':'])
                more on
                disp(slist1); disp(slist2); disp(slist3)
                more off
            catch me %just to avoid an error in the middle leaving us in the wrong directory
                throw(me)
            end
        end
        
    else %called to get help message for specific scriptname, oopt pair
        
        %get help messages from setdef_cropt
        setdef_cropt_cast
        if exist('crhelp_str','var'); disp('defaults set in setdef_cropt_cast'); end
        setdef_cropt_sam
        if exist('crhelp_str','var'); disp('defaults set in setdef_cropt_sam'); end
        setdef_cropt_uway
        if exist('crhelp_str','var'); disp('defaults set in setdef_cropt_uway'); end
        setdef_cropt_other
        if exist('crhelp_str','var'); disp('defaults set in setdef_cropt_other'); end
        dm = which('m_setup'); dm = dm(1:end-9);
        dc = pwd;
        try
            cd(dm);
            [st, clist] = unix(['grep ' oopt ' cruise_options/opt_*.m | grep case']);
            cd(dc)
            more on
            disp(['look in these files for examples of how to change default settings for scriptname = ''' scriptname '''; oopt = ''' oopt ''':'])
            disp(clist)
            more off
        catch me
            throw(me)
        end
        if exist('crhelp_str','var')
            disp(crhelp_str);
        else
            disp(['no help string for ' scriptname ', ' oopt ' in setdef_cropt_*'])
        end
        
    end
    
    clear help_cropt %don't want this to persist
    return
    
end
