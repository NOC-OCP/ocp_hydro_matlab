%%%%% set data to absent outside ranges %%%%%

%list of possible streams and fields; this should generally only be added to because extras will just be ignored
car = {'ash' {'head_ash' 'pitch' 'roll' 'mrms' 'brms'} {'0 360' '-5 5' '-7 7' '0.00001 0.01' '0.00001 0.1'}
    'gp4' {'long' 'lat'} {'-181 181' '-91 91'}
    'pos' {'long' 'lat'} {'-181 181' '-91 91'}
    'seapos' {'long' 'lat'} {'-181 181' '-91 91'}
    'posdps' {'long' 'lat'} {'-181 181' '-91 91'}
    'met' {'airtemp' 'humid' 'direct' 'speed'} {'-50 50' '0.1 110' '-0.1 360.1' '-0.001 200'}
    'surfmet' {'airtemp' 'humid' 'direct' 'speed'} {'-50 50' '0.1 110' '-0.1 360.1' '-0.001 200'}
    'met_light' {'pres' 'ppar' 'spar' 'ptir' 'stir'} {'0.01 1500' '-10 1500' '-10 1500' '-10 1500' '-10 1500'}
    'surflight' {'pres' 'ppar' 'spar' 'ptir' 'stir'} {'0.01 1500' '-10 1500' '-10 1500' '-10 1500' '-10 1500'}
    'tsg' {'temp_h' 'temp_r' 'temp_m' 'sstemp' 'tstemp' 'cond' 'trans'} {'-2 50' '-2 50' '-2 50' '-2 50' '-2 50' '0 10' '0 105'}
    'met_tsg' {'temp_h' 'temp_r' 'temp_m' 'sstemp' 'tstemp' 'cond' 'trans' 'fluo' 'flow1'} {'-2 50' '-2 50' '-2 50' '-2 50' '-2 50' '0 10' '0 105' '0 10' '0 10'}
    'ocl' {'temp_h' 'temp_r' 'temp_m' 'sstemp' 'tstemp' 'cond' 'trans'} {'-2 50' '-2 50' '-2 50' '-2 50' '-2 50' '0 10' '0 105'}
    'sim' {'depth' 'depth_uncor'} {'20 10000' '20 10000'}
    'ea600m' {'depth' 'depth_uncor'} {'20 10000' '20 10000'}
    'ea600' {'depth' 'depth_uncor'} {'20 10000' '20 10000'}
    'em120' {'swath_depth'} {'20 10000'}
    'em122' {'swath_depth'} {'20 10000'}
    };

ii = find(strcmp(abbrev, car(:,1)));
if length(ii)>0
    %work on the latest file, which may already be an edited version; always output to otfile
    if ~exist([otfile '.nc'])
        unix(['/bin/cp ' infile '.nc ' otfile '.nc']);
    end
    
    MEXEC_A.MARGS_IN = {otfile; 'y'};
    h = m_read_header(otfile);
    for no = 1:length(car{ii,2})
        if sum(strcmp(car{ii,2}{no}, h.fldnam)) %fixed jc191/192, jc211
            MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; car{ii,2}{no}; car{ii,3}{no}];
        end
    end
    if length(MEXEC_A.MARGS_IN)>2
        MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; ' ']; %fixed jc191/192, jc211
        medita
    end
    
end

