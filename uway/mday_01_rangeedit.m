%%%%% set data to absent outside ranges %%%%%

%list of possible fields and ranges; this should generally only be added to because extras will just be ignored
varr.head.range = [0 360]; varr.head.names = {'head' 'head_ash' 'headingtrue'};
varr.pitch.range = [-5 5];
varr.roll.range = [-7 7];
varr.mrms.range = [1e-5 1e-2]; 
varr.brms.range =[1e-5 0.1];
varr.lon.range = [-181 181]; varr.lon.names = {'lon' 'long' 'longitude'};
varr.lat.range = [-91 91]; varr.lat.names = {'lat' 'latitude'};
varr.airtemp.range = [-50 50]; varr.airtemp.names = {'airtemp' 'airtemperature'};
varr.humid.range = [0.1 110]; varr.humid.names = {'humid' 'humidity'};
varr.winddirection.range = [-0.1 360.1]; varr.winddirection.names = {'direct' 'winddirection'};
varr.windspeed.range = [-0.001 200]; varr.windspeed.names = {'speed' 'windspeed'};
varr.airpressure.range = [0.01 1500]; varr.airpressure.names = {'pres' 'airpressure'};
varr.rad.range = [-10 1500]; varr.rad.names = {'ppar' 'spar' 'ptir' 'stir' 'parport' 'parstarboard' 'tirport' 'tirstarboard'};
varr.seatemp.range = [-2 50]; varr.seatemp.names = {'temp_h' 'temp_r' 'temp_m' 'sstemp' 'tstemp' 'housingwatertemperature' 'remotewatertemperature'};
varr.cond.range = [0 10]; varr.cond.names = {'cond' 'conductivity'};
varr.trans.range = [0 105]; 
varr.dep.range = [20 1e4]; varr.dep.names = {'depth' 'swath_depth'};


fn = fieldnames(varr);
h = m_read_header(otfile);
for vno = 1:length(fn) %look for each variable type in file
    v = varr.(fn{vno});
    if isfield(v, 'names')
        vnames = v.names;
    else
        vnames = fn(vno);
    end
    MEXEC_A.MARGS_IN = {otfile; 'y'};
    for nno = 1:length(vnames)
        if sum(strcmp(vnames{nno}, h.fldnam)
            MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; vnames{nno}; sprintf('''%f %f''',v.range)];
        end
    end
    if length(MEXEC_A.MARGS_IN)>2
        MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; ' ']; %fixed jc191/192, jc211
        medita
    end
    
end

