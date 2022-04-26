function varargout = timeunits_mstar_cf(tuin)
% function cf_time_units_string = timeunits_mstar_cf(data_time_origin);
% function [units, data_time_origin] = timeunits_mstar_cf(cf_time_units_string);
%
% convert between mstar data_time_origin (in header/metadata) and units
% (seconds) and cf time units (e.g. 'seconds since yyyy-mm-dd hh:mm:ss')
% (time zone not considered)
%
% if input is string, convert from cf to mstar
% if input is vector, convert from mstar to cf

if ischar(tuin)
    %cf, convert to mstar
    
    if strcmp(' ',tuin(1)); tuin = tuin(2:end); end
    if strcmp(' ',tuin(end)); tuin = tuin(1:end-1); end
    
    ii = strfind(tuin, ' ');
    
    if isempty(ii)
        varargout{1} = tuin;
    
    else
        varargout{1} = tuin(1:ii(1)-1);
        if length(ii)<3
            ymd = replace(tuin(ii(2)+1:end),'-',' ');
            hms = '0 0 0';
        else
            ymd = replace(tuin(ii(2)+1:ii(3)-1),'-',' ');
            if length(ii)<4
                hms = replace(tuin(ii(3)+1:end),':',' ');
            else
                hms = replace(tuin(ii(3)+1:ii(4)-1),':',' ');
            end
        end
        dto = [str2num(ymd) str2num(hms)];
        if length(dto)<6
            dto = [dto zeros(1,6-length(dto))];
        end
        varargout{2} = dto;
        
    end
    
else
    
    %mstar, convert to cf
    varargout{1} = ['seconds since ' datestr(tuin,'yyyy-mm-dd HH:MM:SS')];
    
end

if length(varargout)<nargout
    varargout{2} = [];
end
