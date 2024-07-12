function mctd_rawedit(stn, varargin)
% mctd_rawedit:
%
% input: _raw.nc or (if it exists) _raw_cleaned.nc; dcs_
%
% display raw ctd data to check for and edit out spikes and other bad
% data from individual sensors
%
% output: _raw_cleaned.nc
%
% Use: mctd_rawedit(stn) %to edit T or C
%      mctd_rawedit(stn,'oxy') %to edit oxygen

m_common; MEXEC_A.mprog = mfilename;
opt1 = 'castpars'; opt2 = 'minit'; get_cropt
if MEXEC_G.quiet<=1; fprintf(1,'calling mplxyed for GUI editing of raw data, saving to ctd_%s_%s_raw_cleaned.nc\n',mcruise,stn_string); end
dooxy = 0;
if nargin>1; dooxy = strcmp(varargin{1},'oxy'); end

% resolve root directories for various file types
root_ctd = mgetdir('M_CTD');

prefix1 = ['ctd_' mcruise '_' stn_string];
prefix2 = ['dcs_' mcruise '_' stn_string];

otfile = fullfile(root_ctd, [prefix1 '_raw_cleaned.nc']);
infile = fullfile(root_ctd, [prefix1 '_raw.nc']);
infiled = fullfile(root_ctd, [prefix2 '.nc']); % dcs file

if ~exist(m_add_nc(otfile), 'file')
    copyfile(m_add_nc(infile), m_add_nc(otfile)); mfixperms(m_add_nc(otfile));
end


%only plot the good part of the cast, chosen in mdcs_03g (not the on-deck or soak periods)
if ~exist(m_add_nc(infiled), 'file')
    warning('dcs file required for GUI editing; quitting'); return
else
    
    [ddcs, hdcs]  = mloadq(infiled,'/');
    dn_start = m_commontime(ddcs.time_start(1),'time_start',hdcs,'datenum');
    dn_end = m_commontime(ddcs.time_end(1),'time_end',hdcs,'datenum');
    clear pshow0
    pshow0.startdc = datevec(dn_start);
    pshow0.stopdc = datevec(dn_end);
    pshow0.ncfile.name = otfile;
    pshow0.xlist = 'time'; 
    %***option to only plot some of these variables?***
    pshow0.ylist = ['temp1 temp2 cond1 cond2 press'];
    if dooxy
        opt1 = 'castpars'; opt2 = 'oxyvars'; get_cropt
        opt1 = 'castpars'; opt2 = 'oxy_align'; get_cropt
        nox = size(oxyvars,1); % bak add
    else
        nox = 0;
    end
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
        
        redos = input('run for another variable? (y/n) \n','s');
        if isfinite(str2double(redos))
            redo = str2double(redos);
        else
            if strncmp(redos,'y',1); redo = 1; else; redo = 0; end
        end
        
    end
    
end
