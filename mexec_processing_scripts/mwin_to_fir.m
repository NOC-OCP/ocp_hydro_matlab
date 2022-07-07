% mwin_to_fir: merge winch wireout onto fir file
%
% Use: mwin_to_fir        and then respond with station number, or for station 16
%      stn = 16; mwin_to_fir;
%
% formerly mwin_03

scriptname = 'castpars'; oopt = 'minit'; get_cropt
if MEXEC_G.quiet<=1; fprintf(1,'adding winch data from bottle firing times to fir_%s_%s.nc\n',mcruise,stn_string); end

% resolve root directories for various file types
root_win = mgetdir('M_CTD_WIN');
root_ctd = mgetdir('M_CTD');

winfile = fullfile(root_win, ['win_' mcruise '_' stn_string]);
firfile = fullfile(root_ctd, ['fir_' mcruise '_' stn_string]);

clear d h

[df,hf] = mloadq(firfile,'/');
if isfield(df, 'utime') && sum(isfinite(df.utime))>0
    
    [dwin, hwin] = mloadq(winfile,'/');
    dwin.time = m_commontime(dwin.time,hwin.data_time_origin,hf.data_time_origin);
    
    % scan input file to extract winch cable out variable name
    cabvar = intersect({'cableout' 'cab' 'cable' 'wireout' 'out'}, hwin.fldnam);
    if isempty(cabvar)
        error(['Winch cable/wireout variable not found in input file'])
    else
        if length(cabvar)>1
            warning(['Winch cable/wireout variable: more than one option found'])
        end
        cabvar = cabvar{1};
    end
    
    %interpolate
    iig = find(~isnan(dwin.(cabvar)));
    clear d h
    d.utime = df.utime;
    d.wireout = interp1(dwin.time(iig), dwin.(cabvar)(iig), df.utime);
    scriptname = mfilename; oopt = 'winch_fix'; get_cropt
    if sum(~isnan(d.wireout))>0
        h.fldnam = {'utime' 'wireout'}; h.fldunt = {'seconds' 'metres'};
        h.dataname = hwin.dataname; h.mstar_string = hwin.mstar_string;
        MEXEC_A.Mprog = mfilename;
        mfsave(firfile, d, h, '-merge', 'utime')
    end
    
end
