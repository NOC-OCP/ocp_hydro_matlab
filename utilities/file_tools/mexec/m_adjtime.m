function data = m_adjtime(timename,data,h1,h2)
% function data = m_adjtime(timename,data,h1,h2)
%
% adjust a time variable from data_time_origin in h1 to data_time_origin in
% h2

m_common

un1 = h1.fldunt(strcmp(h1.fldnam,timename));
un2 = h2.fldunt(strcmp(h2.fldnam,timename));

if ~isempty(h1.data_time_origin)
    un1 = [un1 ' since ' datestr(h1.data_time_origin,'yyyy-mm-dd HH:MM:SS')];
end
if ~isempty(h2.data_time_origin)
    un2 = [un2 ' since ' datestr(h2.data_time_origin,'yyyy-mm-dd HH:MM:SS')];
end
data0 = data;
data = m_commontime(data,un1,un2);

if max(abs(data-data0))>0
    %adjust time origin
    m = ['adjusting value of time variable ''' timename ''' for difference in data_time_origin between files'];
    fprintf(MEXEC_A.Mfider,'%s\n',m)
else
    return
end
