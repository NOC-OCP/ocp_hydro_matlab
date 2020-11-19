%script to write out ctd and bottle sample data in a csv file
%in reverse niskin order

stn = 0; minit

root_ctd = mgetdir('M_CTD');
root_out = mgetdir('M_SUM');

[d, h] = mload([root_ctd '/sam_' mcruise '_all.nc'], '/');

d.dep = sw_dpth(d.upress, d.lat);
d.dens = sw_dens(d.upsal, d.utemp, d.upress);
d.den20 = sw_dens(d.upsal, 20+zeros(size(d.upsal)), zeros(size(d.upsal)));
d.uoxygen_per_l = d.uoxygen.*d.dens/1e3;
d.silc_per_kg = d.silc./d.dens*1e3;
d.phos_per_kg = d.phos./d.dens*1e3;
d.totnit_per_kg = d.totnit./d.dens*1e3;
d.no2_per_kg = d.no2./d.dens*1e3;
d.cfc11_per_kg = d.cfc11./d.dens*1e3;
d.cfc12_per_kg = d.cfc12./d.dens*1e3;
d.ccl4_per_kg = d.ccl4./d.dens*1e3;
d.f113_per_kg = d.f113./d.dens*1e3;
d.sf6_per_kg = d.sf6./d.dens*1e3;

if 1
   %reverse niskins, or rather, sort them in surface-to-bottom order
   %(mostly)
   stns = unique(d.statnum(~isnan(d.utemp)));
   iig = [];
   for no = 1:length(stns)
      iis = find(d.statnum==stns(no) & ~isnan(d.utemp));
      p = d.upress(iis); ii = find(abs(diff(p))<5);
      if length(ii)>length(p)*.8 %bottle blank station; just reverse them
         iip = length(iis):-1:1;
      else
         %make sure pairs will be sorted in reverse firing order even if
         %heave meant their pressures were ordered the other way--this 
         %will (hopefully) ensure they match the nominal depth order that 
         %will have been used by analysts
         if length(ii)>0; p(ii+1) = p(ii)-1; end
         [c, iip] = sort(p, 'ascend');
      end
      iig = [iig; iis(iip)];
   end
   nostr = '_nisk_surf_to_deep';
end

fields = {'statnum',        'station',          ' ',         '%d';...
          'position',       'niskin',           '(position)','%d';...
          'bottle_qc_flag', 'niskin_flag',      '(woce)',    '%d';...
          'lat',            'latitude',         ' ',         '%5.3f';...
          'lon',            'longitude',        ' ',         '%6.3f';...
          'upress',         'pressure',         '(dbar)',    '%6.2f';...
          'dep',            'depth',            '(m)',       '%6.2f';...
          'utemp',          'temperature',      '(degC)',    '%5.3f';...
          'upsal',          'salinity',         '(psu)',     '%5.3f';...
          'botpsal',        'bottle salinity',  '(psu)',     '%5.3f';...
          'botpsalflag',    'botsal flag',      '(woce)',    '%d';...
	  'dens',           'density',              '(kg/m^3)',  '%6.2f';...
	  'den20',          'density(T=20,P=0)',    '(kg/m^3)',  '%6.2f';...
	  'uoxygen',  'oxygen',           '(umol/kg)',  '%5.2f';...
	  'botoxy',   'bottle_oxygen',    '(umol/kg)',  '%5.2f';...
	  'botoxyflag',     'botoxy_flag',      '(woce)',    '%d';...
	  'silc_per_kg',    'Si',               '(umol/kg)',  '%5.3f';...
	  'silc_flag',      'Si_flag',          '(woce)',    '%d';...
	  'phos_per_kg',    'P',               '(umol/kg)',  '%5.3f';...
	  'phos_flag',      'P_flag',           '(woce)',    '%d';...
	  'totnit_per_kg',  'NO3+NO2',          '(umol/kg)',  '%5.3f';...
	  'totnit_flag',    'NO3+NO2_flag',     '(woce)',    '%d';...
	  'no2_per_kg',     'NO2',              '(umol/kg)',  '%5.3f';...
	  'no2_flag',       'NO2_flag',         '(woce)',     '%d';...
      'alk',            'TAlk',             '(umol/kg)',  '%5.2f';...
      'alk_flag',       'TAlk_flag',        '(woce)',     '%d';...
      'dic',            'DIC',              '(umol/kg)',  '%5.2f';...
      'dic_flag',       'DIC_flag',         '(woce)',     '%d';...
      'cfc11_per_kg',   'CFC11',            '(pmol/kg)',  '%5.3f';...
      'cfc11_flag',     'CFC11_flag',       '(woce)',     '%d';...
      'cfc12_per_kg',   'CFC12',            '(pmol/kg)',  '%5.3f';...
      'cfc12_flag',     'CFC12_flag',       '(woce)',     '%d';...
      'f113_per_kg',    'F113',             '(pmol/kg)',  '%5.3f';...
      'f113_flag',      'F113_flag',        '(woce)',     '%d';...
      'ccl4_per_kg',    'CCL4',             '(pmol/kg)',  '%5.3f';...
      'ccl4_flag',      'CCL4_flag',        '(woce)',     '%d';...
      'sf6_per_kg',     'SF6',              '(fmol/kg)',  '%5.3f';...
      'sf6_flag',       'SF6_flag',         '(woce)',     '%d'};

formstr = []; data = [];
for fno = 1:size(fields, 1)
   formstr = [formstr fields{fno,4} ', '];
   a = getfield(d, fields{fno,1});
   data = [data a(:)];
end
formstr = [formstr(1:end-2) '\n'];
data = data(iig,:)';

fid = fopen([root_out '/samlists/sam_' mcruise '_csv_list' nostr '.csv'], 'w');

for fno = 1:size(fields,1)-1; fprintf(fid, '%s, ', fields{fno,2}); end
fno = fno+1; fprintf(fid, '%s\n', fields{fno,2});
for fno = 1:size(fields,1)-1; fprintf(fid, '%s, ', fields{fno,3}); end
fno = fno+1; fprintf(fid, '%s\n', fields{fno,3});

fprintf(fid, formstr, data);

fclose(fid);