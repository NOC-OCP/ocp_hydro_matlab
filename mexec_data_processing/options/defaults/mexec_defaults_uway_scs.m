switch opt2
    case 'scs_skip'
        skip = {'USBL'};
    case 'scs_nmea_form' 
        colsi = {}; colsf = {};
        untsi = {}; untsf = {};
    case 'scs_nmea_custom'
        inform = '';
    case 'uway_ascii_parse'
        if exist('inform','var') && ~isempty(inform) && ~strcmp(inform,'none')
            t = ua_times_parse(t, MEXEC_G.data_time_origin_string, 'inform', inform);
        elseif strcmp(inform,'none')
            t.time = [1:length(t.lat)]'+t0; t.Properties.VariableUnits(end) = {'temporary invented seconds'};
            t.dday = t.time/86400; t.Properties.VariableUnits(end) = {'temporary invented days'};
        else
            t = ua_times_parse(t, MEXEC_G.data_time_origin_string);
        end
        if sum(strcmp(t.Properties.VariableNames','msg')) && strcmp(t.msg(1),'$PSXN')
            t = t(t.linetype==23,:);
        end
        m = strcmp(t.Properties.VariableNames,'nslatitude');
        if sum(m)
            if strcmp(t.Properties.VariableUnits(m),'cdegrees')
                t.lat = t.nslatitude/100;
            else
                t.lat = t.nslatitude;
            end
            t.lat(strcmp(t.ns,'S')) = -t.lat(strcmp(t.ns,'S'));
            t.Properties.VariableUnits{strcmp(t.Properties.VariableNames,'lat')} = 'degrees N';
        end
        m = strcmp(t.Properties.VariableNames,'ewlongitude');
        if sum(m)
            if strcmp(t.Properties.VariableUnits(m),'cdegrees')
                t.lon = t.ewlongitude/100;
            else
                t.lon = t.ewlongitude;
            end
            t.lon(strcmp(t.ew,'W')) = -t.lon(strcmp(t.ew,'W'));
            t.Properties.VariableUnits{strcmp(t.Properties.VariableNames,'lon')} = 'degrees E';
        end
        m = strcmp(t.Properties.VariableNames,'psxn_heave');
        if sum(m)
            t.heave = cellfun(@(x) str2double(x(1:end-3)), t.psxn_heave);
            t.Properties.VariableUnits{strcmp(t.Properties.VariableNames,'heave')} = 'm';
        end
end
