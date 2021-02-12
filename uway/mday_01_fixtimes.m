%script containing code from previous version of mday_01_clean_av to flag
%repeated times and backward time jumps
%(for rvdas we hope this won't be necessary)

prefix = [abbrev '_' mcruise '_d' day_string];
wkfile1 = ['wk1_' prefix '_' mfilename '_' datestr(now,30)];
wkfile2 = ['wk2_' prefix '_' mfilename '_' datestr(now,30)];

%%%%% check for repeated times and backward time jumps %%%%%

switch abbrev
    
    case {'ash', 'cnav', 'gp4', 'pos', 'met', 'met_light', 'met_tsg', 'tsg', 'surfmet' 'possea' 'dopsea' 'vtgsea' 'attsea' 'dopcnav' 'hdtsea' 'ea600'}
        %work on the latest file, which already be an edited version; always output to otfile
        if exist([otfile '.nc'])
            unix(['/bin/mv ' otfile '.nc ' wkfile1 '.nc']); infile1 = wkfile1;
        else
            infile1 = infile;
        end
        %flag repeated times
        h = m_read_header(infile1);
        MEXEC_A.MARGS_IN = {infile1; otfile; '/'; 'time'};
        if h.rowlength==1
            MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; 'y=[1 x1(2:end)-x1(1:end-1)]'];
        else
            MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; 'y=[1; x1(2:end)-x1(1:end-1)]'];
        end
        MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; 'deltat'; 'seconds'; ' '];
        mcalc
        unix(['/bin/rm ' m_add_nc(wkfile1)]);
        %now remove them
        d = mload(otfile, 'deltat');
        if sum(d.deltat==0)
            h = m_read_header(otfile); fn = setdiff(h.fldnam, 'deltat');
            MEXEC_A.MARGS_IN = {otfile; 'y'};
            for fno = 1:length(fn)
                MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN;
                    fn{fno};
                    [fn{fno} ' deltat']
                    ['y = x1; y(x2==0) = NaN;']
                    ' '
                    ' '
                    ];
            end
            MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; ' '];
            mcalib2
        end
        
    case {'gys', 'gyr', 'gyro_s', 'gyropmv' 'posmvpos'}
        %work on the latest file, which already be an edited version; always output to otfile
        if exist([otfile '.nc'])
            unix(['/bin/mv ' otfile '.nc ' wkfile '.nc']); infile1 = wkfile;
        else
            infile1 = infile;
        end
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