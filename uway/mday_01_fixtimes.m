%script containing code from previous version of mday_01_clean_av to flag
%repeated times and backward time jumps
%(for rvdas we hope this won't be necessary)

%%%%% check for repeated times and backward time jumps %%%%%
switch abbrev
    
    case {'ash', 'cnav', 'gp4', 'pos', 'met', 'met_light', 'met_tsg', 'tsg', 'surfmet'}
        %work on the latest file, which already be an edited version; always output to otfile
        if exist([otfile '.nc'])
            unix(['/bin/mv ' otfile '.nc ' wkfile '.nc']); infile1 = wkfile;
        else
            infile1 = infile;
        end
        MEXEC_A.MARGS_IN = {infile1; otfile; '/'; 'time'; 'y=[1 x1(2:end)-x1(1:end-1)]'; 'deltat'; 'seconds'; ' '};
        mcalc
        unix(['/bin/rm ' m_add_nc(wkfile)]);
        
    case {'gys', 'gyr', 'gyro_s', 'gyropmv' 'posmvpos'}
        %work on the latest file, which already be an edited version; always output to otfile
        if exist([otfile '.nc'])
            unix(['/bin/mv ' otfile '.nc ' wkfile '.nc']); infile1 = wkfile;
        else
            infile1 = infile;
        end
        wkfile2 = [prefix '_wk2'];
        % flag non-monotonic times
        MEXEC_A.MARGS_IN = {infile1; wkfile2; '/'; 'time'; 'y = m_flag_monotonic(x1);'; 'tflag'; ' '; ' '};
        mcalc
        if strcmp(abbrev, 'posmvpos')
            varlist = '1 2 3 4 5 6 7 8 9';
        else
            varlist = '1 2';
        end
        MEXEC_A.MARGS_IN = {wkfile2; otfile; '2'; 'tflag .5 1.5'; ' '; varlist};
        mdatpik
        unix(['/bin/rm ' m_add_nc(wkfile2)])
        unix(['/bin/rm ' m_add_nc(wkfile)]);
        
end