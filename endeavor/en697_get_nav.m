function en697_get_nav

data_root = '/local/users/pstar/projects/rpdmoc/en697/mcruise/data/scs/';
data_dir  = 'scs_raw/';
data_pref = 'GPS-Furuno-GGA_';
date_string = datestr(now,'yyyymmdd');
date_string ='20230221';
file_name_in  = [data_root data_dir data_pref date_string '-000000.raw']
data_dir  = 'scs_mat/';
file_name_out = [data_root data_dir data_pref date_string '-000000']
edit_coms = 'sed_coms_nav';
temp_file = 'sed_out_temp';

% cmd_str = ['./sed_edit.csh ' file_name ' ' edit_coms]

cmd_str = ['cat ' file_name_in ' | sed -f ' edit_coms ' >! ' temp_file]
[status, results] = system(cmd_str);

if status ~= 0
	disp(results)
	return
end

nvars = 13;
ff = fopen(temp_file);
data_in = fscanf(ff,'%f');
keyboard
nrows = length(data_in(:))/nvars;
data_in = reshape(data_in,nvars,nrows)';

DD = data_in(:,2);
MM = data_in(:,1);
YY = data_in(:,3);
hh = data_in(:,4);
mm = data_in(:,5);
ss = data_in(:,6);
lat_ddmm = data_in(:,8);
lon_ddmm = data_in(:,9);

lat_dec = dm2dd(lat_ddmm);
lon_dec = -dm2dd(lon_ddmm);  % *** Hard wire that this is a west longitude during EN697

time_all =  datenum([YY MM DD hh mm ss])';
vnames = {'time','lat','lon'};
vunits = {'???','degrees','degrees'};
data_all = [lat_dec(:)';lon_dec(:)'];

save(file_name_out,'time_all','data_all','vnames','vunits')
keyboard 

function[dddd] = dm2dd(ddmm)

s = sign(ddmm);         % Save original sign
ddmm = abs(ddmm);       % Absolute
d = fix(ddmm/100);      % Degrees
m = ddmm-(d*100);       % Minutes
dd = m/60;              % Minutes -> Decimal Degrees
dddd = s.*(d+dd);       % Combine degrees and decimal degrees and restore sign

