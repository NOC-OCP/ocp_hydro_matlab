%script to write out ctd 2dbar or 1hz data in a csv file
%concatenates all the stations

scriptname = 'castpars'; oopt = 'minit'; get_cropt

root_ctd = mgetdir('M_CTD');
root_out = mgetdir('M_SUM');

if ~exist('csuf'); csuf = '2db'; end %default to 2db downcast file

fnin = fullfile(root_ctd, ['ctd_' mcruise '_' stn_string '_' csuf '.nc']);
if exist(fnin, 'file')
   [d, h] = mload(fnin, '/');
else
    error([fname ' not found'])
end

switch csuf
    case '2db'
        tsuf = '2dbar_down';
    case '2up'
        tsuf = '2dbar_up';
    case '1hz'
        tsuf = '1hz';
    otherwise
        error('mout_ctd_csv does not contain a case for printing 24hz ctd data to an ascii file')
end
fnot = fullfile(root_out, 'ctdlists', ['ctd_' mcruise '_' stn_string '_csv_list_' tsuf '.csv']);

if isfield(d, 'asal')
    d.dens = gsw_rho_t_exact(d.asal, d.temp, d.press);
    d.ctem = gsw_CT_from_t(d.asal, d.temp, d.press);
else
    d.dens = sw_dens(d.psal, d.temp, d.press);
end

fields = {
    'latitude',       'latitude',                 ' ',         '%5.3f';...
    'longitude',      'longitude',                ' ',         '%6.3f';...
    'depth',          'depth',                    '(m)',       '%6.2f';...
    'press',          'pressure',                 '(dbar)',    '%6.2f';...
    'temp',           'temperature',              '(degC)',    '%5.3f';...
    'psal',           'practical salinity',       '(psu)',     '%5.3f';...
	'oxygen',         'oxygen',                   '(umol/kg)', '%5.2f'};
if isfield(d, 'fluor')
    fields = [fields;
   {'fluor',          'fluorescence',             '(ug/l)',    '%5.2f'}];
end
if isfield(d, 'transmittance')
    fields = [fields;
   {'transmittance',  'transmittance',            '(percent)', '%5.2f'}];
end
if isfield(d, 'turbidity')
    fields = [fields;
   {'turbidity',      'turbidity',                '(1/(m sr))','%5.2f'}];
end
fields = [fields;
   {'dens',           'density',                  '(kg/m^3)',  '%6.2f'}];
if isfield(d, 'asal')
    fields = [fields; 
   {'ctem',           'Conservative Temperature', '(degC)',    '%5.3f';...
    'asal',           'Absolute Salinity',        '(g/kg)',    '%5.3f'}];
end
    
formstr = []; data = [];
for fno = 1:size(fields, 1)
   formstr = [formstr fields{fno,4} ', '];
   data = [data; getfield(d, fields{fno,1})];
end
formstr = [formstr(1:end-2) '\n'];

fid = fopen(fnot, 'w');

for fno = 1:size(fields,1)-1; fprintf(fid, '%s, ', fields{fno,2}); end
fno = fno+1; fprintf(fid, '%s\n', fields{fno,2});
for fno = 1:size(fields,1)-1; fprintf(fid, '%s, ', fields{fno,3}); end
fno = fno+1; fprintf(fid, '%s\n', fields{fno,3});

fprintf(fid, formstr, data);

fclose(fid);
