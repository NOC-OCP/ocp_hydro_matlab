function t = ua_times_parse(t,time_origin_string,varargin)
% create t.time in seconds since time_origin_string
% t = ua_times_parse(t,time_origin_string)
% t = ua_times_parse(t,time_origin_string,'resol',1000)
% t = ua_times_parts(t,time_origin_string,'inform','ddMMyyyy HHmmss')

resol = 1000;
inform = '';
if nargin>2
    for no = 1:2:length(varargin)
        eval([varargin{no} ' = varargin{no+1};']);
    end
end

m = strcmp(t.Properties.VariableNames,'datetime');
if sum(m)
    if strcmp(t.Properties.VariableTypes(m),'datetime')
        t(isnat(t.datetime),:) = [];
        t.time = convertTo(t.datetime,'epochtime','Epoch',time_origin_string,'TicksPerSecond',resol)/resol;
    else
        t.time = convertTo(datetime(t.datetime,'InputFormat',inform),'epochtime','Epoch',time_origin_string,'TicksPerSecond',resol)/resol;
    end

else
    md = strcmp(t.Properties.VariableNames,'date');
    mt = strcmp(t.Properties.VariableNames,'time');

    if strcmp(t.Properties.VariableTypes(md),'datetime') && strcmp(t.Properties.VariableTypes(mt),'duration')
        a = t.date+t.time;
        t(isnat(a),:) = []; a(isnat(a)) = [];
        t.time = convertTo(a,'epochtime','Epoch',time_origin_string,'TicksPerSecond',resol)/resol;
    
    else
        a = sprintf('%08d %06d ',[t.date';round(t.time)']); a = reshape(a,16,length(a)/16)';
        b = datetime(a,'InputFormat',inform); %***
        t(isnat(b),:) = []; b(isnat(b)) = [];
        t.time = convertTo(b,'epochtime','Epoch',time_origin_string,'TicksPerSecond',resol)/resol;
    end

end

t.time = double(t.time);
t.dday = t.time/3600/24;
t.Properties.VariableUnits{strcmp(t.Properties.VariableNames,'time')} = ['seconds since ' time_origin_string];
t.Properties.VariableUnits{strcmp(t.Properties.VariableNames,'dday')} = ['days since ' time_origin_string];

t(:,ismember(t.Properties.VariableNames,{'datetime','date'})) = [];
