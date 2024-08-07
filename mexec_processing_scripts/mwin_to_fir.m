function mwin_to_fir(stn)
% mwin_to_fir: merge winch wireout onto fir file
%
% Use: mwin_to_fir        and then respond with station number, or for station 16
%      stn = 16; mwin_to_fir;
%
% formerly mwin_03

m_common
opt1 = 'ctd_proc'; opt2 = 'minit'; get_cropt

% resolve root directories for various file types
root_win = mgetdir('M_CTD_WIN');
root_ctd = mgetdir('M_CTD');

winfile = fullfile(root_win, ['win_' mcruise '_' stn_string]);
firfile = fullfile(root_ctd, ['fir_' mcruise '_' stn_string]);
if ~exist(m_add_nc(firfile),'file')
    firfile = [firfile '_ctd']; %backwards compatibility
    if ~exist(m_add_nc(firfile),'file')
        warning('station %s fir file not found; skipping',stn_string)
        return
    end
end
if MEXEC_G.quiet<=1; fprintf(1,'adding winch data from bottle firing times to fir_%s_%s.nc\n',mcruise,stn_string); end

clear d h

[df,hf] = mloadq(firfile,'/');
if isfield(df, 'utime') && sum(isfinite(df.utime))>0
    
    [dwin, hwin] = mloadq(winfile,'/');
    opt1 = 'mstar'; get_cropt
    if docf
        dwin.time = m_commontime(dwin,'time',hwin,hf.fldunt{strcmp(hf.fldnam,'utime')});
    else
        dwin.time = m_commontime(dwin.time,hwin.data_time_origin,hf.data_time_origin);
    end

    % scan input file to extract winch cable out variable name
    cabvar = intersect({'cableout' 'cab' 'cable' 'wireout' 'out' 'mfctdcablelengthout' 'ctdcablelengthout'}, hwin.fldnam);
    if isempty(cabvar)
        error('Winch cable/wireout variable not found in input file')
    else
        if length(cabvar)>1
            warning('Winch cable/wireout variable: more than one option found')
        end
        cabvar = cabvar{1};
    end
    
    %interpolate
    iig = find(~isnan(dwin.(cabvar)));
    clear d h
    d.utime = df.utime;
    d.wireout = interp1(dwin.time(iig), dwin.(cabvar)(iig), df.utime);
    opt1 = mfilename; opt2 = 'winch_fix'; get_cropt
    if sum(~isnan(d.wireout))>0
        h.fldnam = {'utime' 'wireout'}; h.fldunt = {hf.fldunt{strcmp('utime',hf.fldnam)} 'metres'};
        h.dataname = hwin.dataname; h.mstar_string = hwin.mstar_string;
        MEXEC_A.Mprog = mfilename;
        mfsave(firfile, d, h, '-merge', 'utime')
    end
    
end
