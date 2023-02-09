%script containing code from previous version of mday_01_clean_av to flag
%repeated times, backward time jumps, and non-finite times

prefix = [abbrev '_' mcruise '_d' day_string];
wkfile1 = ['wk1_' prefix '_' mfilename '_' datestr(now,30)];
wkfile2 = ['wk2_' prefix '_' mfilename '_' datestr(now,30)];

%%%%% check for repeated times and backward time jumps %%%%%

%work on the latest file, which already be an edited version; always output to otfile
if exist(m_add_nc(otfile),'file')
    [d,h] = mload(otfile,'/');
else
    [d,h] = mload(infile,'/');
end
deltat = d.time(2:end)-d.time(1:end-1);
deltat = [1; deltat(:)];
iib = find(deltat==0 | ~isfinite(d.time));
if ~isempty(iib)
    for no = 1:length(h.fldnam)
        d.(h.fldnam{no})(iib) = [];
    end
    mfsave(otfile, d, h);
end

switch abbrev
    
    case {'gys', 'gyr', 'gyro_s', 'gyropmv' 'posmvpos'}
        %work on the latest file, which already be an edited version; always output to otfile
        if exist([otfile '.nc'],'file')
            movefile(m_add_nc(otfile), m_add_nc(wkfile)); infile1 = wkfile;
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
        delete(m_add_nc(wkfile2));
        delete(m_add_nc(wkfile));
        
end