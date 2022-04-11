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

%scriptname = 'mctd_02'; oopt = 'rawedit_auto'; get_cropt
%[d, h] = mloadq(infile, '/');
%[d, comment] = ctd_apply_autoedits(d, castopts);


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
