% mctd_rawedit: display raw ctd data to check for spikes
%
% Use: mctd_rawedit        and then respond with station number, or for station 16
%      stn = 16; mctd_rawedit;

minit;
mdocshow(mfilename, ['applies despiking and other edits if set in opt_cruise; allows interactive selection of bad data cycles; writes cleaned data to ctd_' mcruise '_' stn_string '_raw_cleaned.nc']);

% resolve root directories for various file types
root_ctd = mgetdir('M_CTD');

prefix1 = ['ctd_' mcruise '_'];
prefix2 = ['dcs_' mcruise '_'];

otfile = [root_ctd '/' prefix1 stn_string '_raw_cleaned'];
if ~exist(m_add_nc(infile), 'file')
    % raw file only, so no cleaning has been done yet; move raw to raw_original and copy to raw_cleaned, making this writeable (for now) and making a link to raw_cleaned from raw
    infile1 = [root_ctd '/' prefix1 stn_string '_raw'];
    unix(['/bin/cp -p ' m_add_nc(infile1) ' ' m_add_nc(otfile)]);
    cpfile1 = [root_ctd '/' prefix1 stn_string '_raw_original'];
    unix(['/bin/mv ' m_add_nc(infile1) ' ' m_add_nc(cpfile1)]);
    unix(['chmod 444 ' m_add_nc(cpfile1)]) %write-protected
    l = length(root_ctd)+2; unix(['ln -s ' m_add_nc(otfile(l:end)) ' ' m_add_nc(infile1)]); %link raw to raw_cleaned
end
unix(['chmod 644 ' m_add_nc(otfile)]); %make raw_cleaned writeable for now


%optional: start with automatic edits
scriptname = mfilename; oopt = 'rawedit_auto'; get_cropt

%scanedit (for additional bad scans)
if length(sevars)>0
    MEXEC_A.MARGS_IN = {infile; 'y'};
    for no = 1:length(sevars)
        sestring = sprintf('y = x1; y(x2>=%d & x2<=%d);', sevars{no,2}, sevars{no,3});
        MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; sevars{no,1}; [sevars{no,1} ' scan']; sestring; ' '; ' '];
        disp(['will edit out scans from ' sevars{no,1} ' with ' sestring])
    end
    MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; ' '];
    mcalib2
end

%remove out of range values
if length(revars)>0
    MEXEC_A.MARGS_IN = {infile; 'y'};
    for no = 1:size(revars,1)
        MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; revars{no,1}; sprintf('%f %f',revars{no,2},revars{no,3}); 'y'];
        disp(['will edit values out of range [' sprintf('%f %f',revars{no,2},revars{no,3}) '] from ' revars{no,1}])
    end
    MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; ' '];
    medita
end

%despike
if length(dsvars)>0
    nds = 2;
    while nds<=size(dsvars,2)
        MEXEC_A.MARGS_IN = {infile; 'y'};
        for no = 1:size(dsvars,1)
            MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; dsvars{no,1}; dsvars{no,1}; sprintf('y = m_median_despike(x1, %f);', dsvars{no,nds}); ' '; ' '];
            disp(['will despike ' dsvars{no,1} ' using threshold ' sprintf('%f', dsvars{no,nds})])
        end
        MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; ' '];
        mcalib2
        nds = nds+1;
    end
end

if (length(revars)>0 & sum(strncmp('temp', revars(:,1), 4))) | (length(dsvars)>0 | sum(strncmp('temp', dsvars(:,1), 4)))
    warning('You have applied rangeedit or despike to temperature. If large spikes were removed,')
    warning(['you should set redoctm=1 in the mctd_01 case in opt_' mcruise ', add these editing '])
    warning(['instructions to the mctd_02a case in opt_' mcruise ', remove ctd_' mcruise '_' stn_string '*.nc,'])
    warning('and rerun mexec processing steps from the beginning')
    warning('(otherwise conductivity will be contaminated).') %***what about oxygen?
end

%%%%%%%%% now the GUI %%%%%%%%%

%only plot the good part of the cast, chosen in mdcs_03g (not the on-deck or soak periods)
infiled = [root_ctd '/' prefix2 stn_string ]; % dcs file
if ~exist(m_add_nc(infiled), 'file')
    unix(['chmod 444 ' m_add_nc(otfile)]);
    warning('dcs file required for GUI editing; quitting'); return
else
    
    [ddcs hdcs]  = mload(infiled,'/');
    dcs_ts = ddcs.time_start(1);
    dcs_te = ddcs.time_end(1);
    dn_start = datenum(hdcs.data_time_origin)+dcs_ts/86400;
    dn_end = datenum(hdcs.data_time_origin)+dcs_te/86400;
    startdc = datevec(dn_start);
    stopdc = datevec(dn_end);
    
    close all
    
    %ylf edited jc159 to allow multiple passes through mplxyed (probably for different variables) in a single call to mctd_rawedit
    scriptname = 'castpars'; oopt = 'oxyvars'; get_cropt; nox = size(oxyvars,1);
    redo = 1;
    while redo
        
        clear pshow1
        hraw = m_read_header(otfile);
        pshow1.ncfile.name = otfile;
        pshow1.xlist = 'time';
        pshow1.ylist = ['temp1 temp2 cond1 cond2 press'];
        for no = 1:nox; pshow1.ylist = [pshow1.ylist ' ' oxyvars{no,1}]; end
        pshow1.startdc = startdc;
        pshow1.stopdc = stopdc;
        mplxyed(pshow1);
        
        redo = input('run for another variable? (1 for yes, 0 for no)');
        
    end
    
    unix(['chmod 444 ' m_add_nc(otfile)]);
    
end
