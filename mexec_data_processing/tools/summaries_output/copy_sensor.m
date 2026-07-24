function [d, h] = copy_sensor(d, h, stn)

m_common

%identify preferred sensors for (T,C) and O on this station
opt1 = 'ctd_proc'; opt2 = 'sensor_choice'; get_cropt 
if o_choice == 2 && ~sum(strcmp('oxy2', h.fldnam))
   error(['no oxy2 found; edit opt_' mcruise ' ctd_proc, sensor_choice and try again'])
end

%copy selected sensor to new names without sensor number
h0 = h;
vars = {'temp' 'cond' 'psal' 'potemp' 'asal'};
for vno = 1:length(vars)
    name0 = [vars{vno} num2str(ts_choice)];
    ii = find(strcmp(name0,h.fldnam));
    if ~isempty(ii)
        d.(vars{vno}) = d.(name0);
        if ~sum(strcmp(vars{vno},h.fldnam))
            h.fldnam = [h.fldnam vars{vno}];
            h.fldunt = [h.fldunt h.fldunt{ii}];
            h.fldserial = [h.fldserial h.fldserial{ii}];
        end
        h0.fldnam{ii} = vars{vno};
    end
end
h = keep_hvatts(h, h0);
h0 = h;
vars = {'oxy'};
for vno = 1:length(vars)
    name0 = [vars{vno} num2str(o_choice)];
    ii = find(strcmp(name0,h.fldnam));
    if ~isempty(ii)
        d.(vars{vno}) = d.(name0);
        if ~sum(strcmp(vars{vno},h.fldnam))
            h.fldnam = [h.fldnam vars{vno}];
            h.fldunt = [h.fldunt h.fldunt{ii}];
            h.fldserial = [h.fldserial h.fldserial{ii}];
        end
        h0.fldnam{ii} = vars{vno};
    end
end
h = keep_hvatts(h, h0);
