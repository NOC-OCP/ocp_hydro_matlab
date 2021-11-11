% mctd_rawedit: 
%
% input: _raw.nc or (if it exists) _raw_cleaned.nc; dcs_
%
% apply automatic edits as set in opt_cruise: 
%     edits based on scan range (sevars)
%     edits based on variable range (revars)
%     despiking (dsvars)
% then display raw ctd data to check for and edit out spikes and other bad
% data from individual sensors
%
%     to skip this step, set rawedit_nogui = 1;
%
% output: _raw_cleaned.nc
%
% Use: mctd_rawedit        and then respond with station number, or for station 16
%      stn = 16; mctd_rawedit;
% or to skip the GUI and only apply automatic edits
%     stn = 16; rawedit_nogui = 1; mctd_rawedit

m_common; MEXEC_A.mprog = mfilename;
scriptname = 'castpars'; oopt = 'minit'; get_cropt
mdocshow(mfilename, ['applies despiking and other edits if set in opt_cruise; allows interactive selection of bad data cycles; writes cleaned data to ctd_' mcruise '_' stn_string '_raw_cleaned.nc']);

% resolve root directories for various file types
root_ctd = mgetdir('M_CTD');

prefix1 = ['ctd_' mcruise '_' stn_string];
prefix2 = ['dcs_' mcruise '_' stn_string];

otfile = fullfile(root_ctd, [prefix1 '_raw_cleaned.nc']);
infile = fullfile(root_ctd, [prefix1 '_raw.nc']);
infiled = fullfile(root_ctd, [prefix2 '.nc']); % dcs file

if ~exist(m_add_nc(otfile), 'file')
    copyfile(m_add_nc(infile), m_add_nc(otfile))
end
system(['chmod 644 ' m_add_nc(otfile)])


%%%%% automatic edits %%%%%

scriptname = mfilename; oopt = 'rawedit_auto'; get_cropt

%scanedit (for additional bad scans)
if exist('sevars','var') && ~isempty(sevars)
    MEXEC_A.MARGS_IN = {otfile; 'y'};
    for no = 1:size(sevars,1)
        sestring = sprintf('y = x1; y(x2>=%d & x2<=%d) = NaN;', sevars{no,2}, sevars{no,3});
        MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; sevars{no,1}; [sevars{no,1} ' scan']; sestring; ' '; ' '];
        disp(['will edit out scans from ' sevars{no,1} ' with ' sestring])
    end
    MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; ' '];
    mcalib2
end

%remove out of range values
if exist('revars','var') && isempty(revars)
    MEXEC_A.MARGS_IN = {otfile; 'y'};
    for no = 1:size(revars,1)
        MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; revars{no,1}; sprintf('%f %f',revars{no,2},revars{no,3}); 'y'];
        disp(['will edit values out of range [' sprintf('%f %f',revars{no,2},revars{no,3}) '] from ' revars{no,1}])
    end
    MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; ' '];
    medita
end

%despike
if exist('dsvars','var') && ~isempty(dsvars)
    nds = 2;
    while nds<=size(dsvars,2)
        MEXEC_A.MARGS_IN = {otfile; 'y'};
        for no = 1:size(dsvars,1)
            MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; dsvars{no,1}; dsvars{no,1}; sprintf('y = m_median_despike(x1, %f);', dsvars{no,nds}); ' '; ' '];
            disp(['will despike ' dsvars{no,1} ' using threshold ' sprintf('%f', dsvars{no,nds})])
        end
        MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; ' '];
        mcalib2
        nds = nds+1;
    end
end

if (exist('revars','var') && ~isempty(revars) && sum(strncmp('temp', revars(:,1), 4))) || (exist('dsvars','var') && ~isempty(dsvars) && sum(strncmp('temp', dsvars(:,1), 4)))
    warning('You have applied rangeedit or despike to temperature. If large spikes were removed,')
    warning(['you should set redoctm=1 in the mctd_01 case in opt_' mcruise ', add these editing '])
    warning(['instructions to the mctd_02a case in opt_' mcruise ', remove ctd_' mcruise '_' stn_string '*.nc,'])
    warning('and rerun mexec processing steps from the beginning')
    warning('(otherwise conductivity will be contaminated).') %***what about oxygen?
end


%%%%%%%%% now the GUI %%%%%%%%%

if (exist('rawedit_nogui','var') && rawedit_nogui)
    clear rawedit_nogui
    return
else
    
 %only plot the good part of the cast, chosen in mdcs_03g (not the on-deck or soak periods)
    if ~exist(m_add_nc(infiled), 'file')
        system(['chmod 444 ' m_add_nc(otfile)]);
        warning('dcs file required for GUI editing; quitting'); return
    else
        
        [ddcs, hdcs]  = mloadq(infiled,'/');
        dcs_ts = ddcs.time_start(1);
        dcs_te = ddcs.time_end(1);
        dn_start = datenum(hdcs.data_time_origin)+dcs_ts/86400;
        dn_end = datenum(hdcs.data_time_origin)+dcs_te/86400;
        clear pshow0
        pshow0.startdc = datevec(dn_start);
        pshow0.stopdc = datevec(dn_end);
        pshow0.ncfile.name = otfile;
        pshow0.xlist = 'time';
        pshow0.ylist = ['temp1 temp2 cond1 cond2 press'];
        scriptname = 'castpars'; oopt = 'oxyvars'; get_cropt
        scriptname = 'castpars'; oopt = 'oxy_align'; get_cropt
        nox = size(oxyvars,1); % bak add
        for no = 1:nox
            pshow0.ylist = [pshow0.ylist ' ' oxyvars{no,1}];
            if oxy_end %truncate extra oxy_align seconds from end of oxygen variables shown
                pshow0.stopdcv.(oxyvars{no,1}) = datevec(datenum(pshow0.stopdc)-oxy_align/3600/24);
            end
        end
        
        close all
        
        %ylf edited jc159 to allow multiple passes through mplxyed (probably for different variables) in a single call to mctd_rawedit
        redo = 1;
        while redo
            
            %hraw = m_read_header(otfile);
            pshow1 = pshow0;
            mplxyed(pshow1);
            
            redo = input('run for another variable? (1 for yes, 0 for no) ');
            
        end
        
        system(['chmod 444 ' m_add_nc(otfile)]);
        
    end
    
end
