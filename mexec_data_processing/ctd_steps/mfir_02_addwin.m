function mfir_02_addwin(stn)
% mfir_02_addwin: merge winch wireout onto fir file

m_common
opt1 = 'setup'; opt2 = 'pfiles'; run(MEXEC_G.opt_cruise)

if ~exist(m_add_nc(pfiles.ctd_win),'file')
    warning('station %s fir file not found; skipping',stn_string)
    return
end
if MEXEC_G.quiet<=1; fprintf(1,'adding winch data from bottle firing times to %s\n',f); end

clear d h

[df,hf] = mloadq(f,'/');
if isfield(df, 'utime') && sum(isfinite(df.utime))>0
    
    [dwin, hwin] = mloadq(pfiles.ctd_win,'/');
    if isfield(hf,'data_time_origin') && ~isempty(hf.data_time_origin)
        dwin.time = m_commontime(dwin.time,hwin.data_time_origin,hf.data_time_origin);
    else
        dwin.time = m_commontime(dwin,'time',hwin,hf.fldunt{strcmp(hf.fldnam,'utime')});
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
    opt1 = mfilename; opt2 = 'winch_fix'; run(MEXEC_G.opt_cruise)
    if sum(~isnan(d.wireout))>0
        h.fldnam = {'utime' 'wireout'}; h.fldunt = {hf.fldunt{strcmp('utime',hf.fldnam)} 'metres'};
        h.dataname = hwin.dataname; h.mstar_string = hwin.mstar_string;
        MEXEC_A.Mprog = mfilename;
        mfsave(pfiles.ctd_nisk, d, h, '-merge', 'utime')
    end
    
end
