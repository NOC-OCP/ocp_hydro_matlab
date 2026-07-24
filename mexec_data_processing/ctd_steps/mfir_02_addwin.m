function mfir_02_addwin(stn)
% mfir_02_addwin: merge winch wireout onto fir file
%

m_common
opt1 = 'setup'; opt2 = 'procfiles'; get_cropt

f = sprintf(firfile.fir,stn_string);
if ~exist(m_add_nc(f),'file')
    warning('station %s fir file not found; skipping',stn_string)
end
if MEXEC_G.quiet<=1; fprintf(1,'adding winch data from bottle firing times to %s\n',f); end

clear d h

[df,hf] = mloadq(f,'/');
if isfield(df, 'utime') && sum(isfinite(df.utime))>0
    
    [dwin, hwin] = mloadq(sprintf(winfile.win,stn_string),'/');
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
        mfsave(f, d, h, '-merge', 'utime')
    end
    
end
