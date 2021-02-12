% mwin_to_fir: merge winch wireout onto fir file
%
% Use: mwin_to_fir        and then respond with station number, or for station 16
%      stn = 16; mwin_to_fir;
%
% formerly mwin_03

minit;
mdocshow(mfilename, ['adds winch data from bottle firing times to fir_' mcruise '_' stn_string '.nc']);

% resolve root directories for various file types
root_win = mgetdir('M_CTD_WIN');
root_ctd = mgetdir('M_CTD');

winfile = [root_win '/win_' mcruise '_' stn_string];
firfile = [root_ctd '/fir_' mcruise '_' stn_string];

clear d h

[df,hf] = mloadq(firfile,'/');
if isfield(firfile, 'time') && sum(isfinite(firfile.time))>0
    
    [dwin, hwin] = mloadq(winfile,'/');
    dwin.time = m_commontime(dwin.time,hwin.data_time_origin,hf.data_time_origin);
    
    % scan input file to extract winch cable out variable name
    cabvar = mvarname_find({'cab' 'cable' 'wireout' 'out'}, hwin.fldnam);
    if length(cabvar)==0
        error(['Winch cable/wireout variable not found uniquely in input file'])
    end
    
    %interpolate
    iig = find(~isnan(dwin.(cabvar)));
    d.time = df.time;
    d.(cabvar) = interp1(dwin.time(iig), dwin.(cabvar)(iig), df.time);
    if sum(~isnan(d.(cabvar)))>0
        h.fldnam = {'time' cabvar}; h.fldunt = {'seconds' 'metres'};
        h.dataname = hwin.dataname; h.version = hwin.version; h.mstar_string = hwin.mstar_string;
        mfsave(d, h, '-merge', 'time')
        
        scriptname = mfilename; oopt = 'winch_fix_string'; get_cropt; %***not very general
        if ~isempty(winch_fix_string)
            MEXEC_A.MARGS_IN = {
                firfile
                'y'
                'wireout'
                winch_fix_string
                ' '
                ' '
                ' '
                };
            mcalib
        end
    end
    
end