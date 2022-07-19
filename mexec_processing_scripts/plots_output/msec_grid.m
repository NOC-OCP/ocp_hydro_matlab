% make gridded section(s) by calling maphsec
%
% formerly msec_run_mgridp (calling mgridp)
%
% you can specify gstart, gstop, gstep, or use the section defaults, or set
% cruise defaults in opt_cruise

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

clear mgrid
mgrid.method = 'msec_maptracer';
mgrid.sam_fill = '';
mgrid.ctd_fill = '';

root_ctd = mgetdir('M_CTD');
otfile = fullfile(root_ctd, [dataname '_' section]);
otfileg = fullfile(root_ctd, ['grid_' mcruise '_' section]);

if ~exist('sections','var') || strcmp(sections, 'all') %if list exists, don't overwrite
    scriptname = mfilename; oopt = 'sections'; get_cropt %get list of sections from this cruise
end

if ~exist('gstart','var')
    scriptname = mfilename; oopt = 'gpars'; get_cropt
else
    disp(['using existing gstart, gstop, gstep, or finding them from ' mfilename])
end


info.section
info.season
info.expocode
info.ctddir
for ksec = 1:length(sections)
    section = sections{ksec};
    
    if isempty(gstart) %parameters differ by section
        switch section
            case {'24n', 'fc'}
                gstart = 10; gstop = 6500; gstep = 20;
            case {'abas' 'falk' '24s'}
                gstart = 10; gstop = 6000; gstep = 20;
            case {'sr1b' 'sr1bb' 'orkney' 'a23' 'srp' 'nsra23'}
                gstart = 10; gstop = 5000; gstep = 20;
            case {'osnapwall' 'laball' 'arcall' 'osnapeall' 'lineball' 'linecall' 'eelall' 'nsr'}
                gstart = 10; gstop = 4000; gstep = 20;
            case {'bc' 'ben' 'bc' 'bc2' 'bc3'}
                gstart = 5; gstop = 3000; gstep = 10;
            case {'fs27n' 'fs27n2'}
                gstart = 5; gstop = 1000; gstep = 10;
            case {'osnapwupper' 'labupper' 'arcupper' 'osnapeupper' 'linebupper' 'linecupper' 'eelupper' 'cumb'}
                gstart = 5; gstop = 500; gstep = 5;
            otherwise
                gstart = 10; gstop = 4000; gstep = 20;
        end      
    end
    pgrid = sprintf('%d %d %d',gstart,gstop,gstep);
    xpress = gstart:gstep:gstop;
    % bak jc191: clear gstart now that we have used it, so it can be reset
    % for next section in ksec loop
    gstart = []; gstop = []; gstep = [];
    
    numlev = length(xpress);
    
    dataname = ['ctd_' mcruise];
    otfile = fullfile(root_ctd, [dataname '_' section]);
    otfile2 = fullfile(root_ctd, ['grid_' mcruise '_' section]);
