%%%%% compute salinity and add to tsg file %%%%%

%work on the latest file, which already be an edited version; always output to otfile
if exist([otfile '.nc'])
    unix(['/bin/mv ' otfile '.nc ' wkfile '.nc']);
else
    unix(['/bin/cp ' infile '.nc ' wkfile '.nc']);
end

infile1 = wkfile;

tempvars = {'tstemp' 'temp_h' 'temp_m' 'temp_housing_raw' 'temp_housing'};

h = m_read_header(infile1);
if sum(strcmp('cond', h.fldnam))
    if sum(strcmp('tstemp', h.fldnam))
        tvar = 'tstemp';
    elseif sum(strcmp('temp_h', h.fldnam))
        tvar = 'temp_h';
    elseif sum(strcmp('temp_m', h.fldnam))
        tvar = 'temp_m';
    else
        warning('no housing/pumped seawater supply temperature set')
        tvar = [];
    end
    if sum(strcmp('psal', h.fldnam))==0 & length(tvar)>0
        MEXEC_A.MARGS_IN = {infile1; otfile; '/'; ['cond ' tvar]; 'y = gsw_SP_from_C(10*x1,x2,0)'; 'psal'; 'pss-78'; ' '};
        mcalc
        unix(['/bin/rm ' m_add_nc(wkfile)]);
    elseif length(tvar)>0
        unix(['/bin/mv ' wkfile '.nc ' otfile '.nc']);
        MEXEC_A.MARGS_IN = {otfile; 'y'; 'psal'; ['cond ' tvar]; 'y = gsw_SP_from_C(10*x1,x2,0)'; '/'; 'pss-78'; ' '};
        mcalib2
    else
        unix(['/bin/rm ' m_add_nc(wkfile)]);
    end
else %if exist(m_add_nc(wkfile),'file') % if we don't have conductivity, e.g. on Discovery, where it's in tsg but not met_tsg, don't delete the file!
    unix(['/bin/mv ' wkfile '.nc ' otfile '.nc']);
end
