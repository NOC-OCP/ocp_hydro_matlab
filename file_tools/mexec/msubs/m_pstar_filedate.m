function m_pstar_filedate(ncfile,pstar_fn)
% function m_pstar_filedate(ncfile,pstar_fn)
%
% Add or update a variable that stores the last time the file was modified
% when converting pstar files, use unix file date

% Use this dimension and name for "file update date".
string_dim_name = 'n_unity';
string_dim_val = 1;
string_var_name = 'date_file_updated';

unix_string = ['!/bin/ls -l ' pstar_fn];
s = evalc(unix_string);
[s1 s2 s3 s4 s5 s6 s7 s8 s9] = strread(s,'%s %s %s %s %s %s %s %s %s');

kdash = strfind(s6,'-');
% s6 is a string in a cell. It seems that if the string contains the search
% text, then kdash is a double containing the index.
% But if s6 does not contain the search text, then kdash is a cell
% containing an empty double, so kdash has length 1.
if iscell(kdash) & ~isempty(kdash); kdash = kdash{1}; end
if ~isempty(kdash)
    % probably of form YYYY-MM-DD HH:MM which is found on linux box nosea1
    s6 = char(s6);
    s7 = char(s7);
    yyyy = s6(1:4);
    mo = s6(6:7);
    dd = s6(9:10);
    hh = s7(1:2);
    mm = s7(4:5);
    date_string = [yyyy '-' mo '-' dd ' ' hh ':' mm ':00'];
    tfile = datenum(date_string,31);
else
    % parse according to time on mac unix, which could be either of " dd mmm hh:mm" or "dd mmm yyyy"
    % solaris on 'rapid' or 'cook3' seems to be                     " mmm dd hh:mm" or "mmm dd yyyy"
    
    mmm = char(s7);
    dd = char(s6);
    if length(dd) > 2
        mmm = char(s6);
        dd = char(s7);
    end
    dd = sprintf('%02d',str2num(dd));
    time_or_year = char(s8);

    tnow = now;

    k = findstr(time_or_year,':');
    if isempty(k)
        %only year found; not time of day; set time to 00:01:00
        yyyy = char(s8);
        time = '00:01:00';
        date_string = [dd '-' mmm '-' yyyy ' ' time];
        tfile = datenum(date_string);

    else
        %time found
        yyyy = datestr(tnow,10); %first assumption is that time is during this year
        time = [sprintf('%02d',str2num(time_or_year(1:k-1))) ':' sprintf('%02d',str2num(time_or_year(k+1:end))) ':00' ];
        date_string = [dd '-' mmm '-' yyyy ' ' time];
        tfile = datenum(date_string);
        if tfile - tnow > 10 %time appears > 10 days into future; assume year was previous year
            ynum = str2num(yyyy);
            yyyy = sprintf('%4d',ynum-1);
        end
        date_string = [dd '-' mmm '-' yyyy ' ' time];
        tfile = datenum(date_string);
    end
end

torg = datenum(1950,1,1,0,0,0);
t = tfile-torg;

metadata = nc_info(ncfile.name); %refresh metadata
ncfile.metadata = metadata;
% 
% dimnames = m_unpack_dimnames(ncfile);
% varnames = m_unpack_varnames(ncfile);
% % % % % 
% % % % % 
% % % % % % Add unity dimension if needed.
% % % % % 
% % % % % m_add_dimension(ncfile,string_dim_name,string_dim_val);
% % % % % m_add_variable_name(ncfile,string_var_name,{string_dim_name},'double');
% % % % % m_add_default_variable_attributes(ncfile,string_var_name);
% % % % % 
% % % % % %put units for this variable
% % % % % nc_attput(ncfile.name,string_var_name,'units','decimal days since (1950,1,1,0,0,0)');
% % % % % 
% % % % % %put data
% % % % % nc_varput(ncfile.name,string_var_name,t);
% % % % % 
% % % % % %update uprlwr
% % % % % m_uprlwr(ncfile,string_var_name);


v = datevec(tfile);
vr = round(v);
nc_attput(ncfile.name,nc_global,'date_file_updated',vr);

return