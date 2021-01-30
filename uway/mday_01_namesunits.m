%script containing code from previous version of mday_01_clean_av to rename
%variables and convert (or rename) some units for scs and techsas streams
%(for rvdas variable renaming is done at an earlier stage)

%%%%% change variable names (calling mheadr) %%%%%
%{abbrev, new name, {old name(s, or beginnings of)} }
can = {'ash' 'head_ash' {'head'}
    'gys' 'head_gyr' {'head'}
    'gyro_s' 'head_gyr' {'head'}
    'gyro_pmv' 'head_gyr' {'head'}
    'gyropmv' 'head_gyr' {'head'}
    'gpsfugro' 'long' {'lon'}
    'sim' 'depth_uncor' {'depthm' 'depth' 'dep' 'snd'}
    'ea600' 'depth_uncor' {'depthm' 'depth' 'dep' 'snd'}
    'ea600m' 'depth_uncor' {'depthm' 'depth' 'dep' 'snd'}
    'em120' 'swath_depth' {'depthm' 'dep' 'snd'}
    'em122' 'swath_depth' {'depthm' 'dep' 'snd'}
    'tsg' 'psal' {'salinity' 'salin'}
    'met_tsg' 'psal' {'salinity' 'salin'}
    };

ii = find(strcmp(abbrev, can(:,1)));
if length(ii)>0
    %work on the latest file, which may already be an edited version; always output to otfile
    if ~exist([otfile '.nc'])
        unix(['/bin/cp ' infile '.nc ' otfile '.nc']);
    end
    
    newname = can{ii,2};
    h = m_read_header(otfile);
    if ~sum(strcmp(newname, h.fldnam))
        for no = 1:length(can{ii,3})
            name = can{ii,3}{no};
            varnum = find(strncmp(name, h.fldnam, length(name)));
            if length(varnum)>0
                MEXEC_A.MARGS_IN = {otfile; 'y'; '8'; sprintf('%d', varnum); newname; ' '; '-1'; '-1'; };
                mheadr
                break %only for renaming one variable per file (listed above in order of preference)
            end
        end
    end
    
end


%%%%% change units labels (calling mheadr) %%%%%
switch abbrev
    case 'met' %asf note: techsas records m/s, however, the SSDS displays values converted to knots. There is no separate record of this since SSDS is live, so all wind records should be in m/s and no conversions are needed.
        if strcmp(MEXEC_G.Mshipdatasystem, 'techsas')
            MEXEC_A.MARGS_IN = {otfile; 'y'; '8'; 'speed'; ' '; 'm/s'; '-1'; '-1'};
            mheadr
        end
end
