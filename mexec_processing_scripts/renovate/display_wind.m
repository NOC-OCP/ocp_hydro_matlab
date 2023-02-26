% script to display some SCS data that aren't shown on a monitor

m_setup

mslast('anemometer');
[andata anunits] = mslast('anemometer');
% anemometer returns wind speed in knots
knots_to_metres_per_sec = 1852/3600; % 1852 metres per 3600 seconds
anspeed = andata.anemometer_wind_speed*knots_to_metres_per_sec;
andir = andata.anemometer_wind_dir;


mslast('seatex-gll');

[data units] = mslast('seatex-gll');

[latd latm] = m_degmin_from_decdeg(data.seatex_gll_lat);
[lond lonm] = m_degmin_from_decdeg(data.seatex_gll_lon);

% % % dvnow = datevec(now);
% % dvnow = datevec(dn);
% % yyyy = dvnow(1);
% % doffset = datenum([yyyy 1 1 0 0 0]);
% % daynum1 = floor(dn) - doffset + 1;
% % 
% % str1 = datestr(dn,'yy/mm/dd');
% % str1a = datestr(dn,'HH:MM:SS');
% % fprintf(MEXEC_A.Mfidterm,'%s\n',tstream);
% % fprintf(MEXEC_A.Mfidterm,'%s     %8s   %03d %8s\n','time',str1,daynum1,str1a);
fprintf(MEXEC_A.Mfidterm,'\n\n%32s %7.1f\n','anemometer speed :',anspeed);
fprintf(MEXEC_A.Mfidterm,'%32s   %03d\n','anemometer direction :',round(andir));
fprintf(MEXEC_A.Mfidterm,'%32s %5.0f %6.2f\n','lat :',latd,latm);
fprintf(MEXEC_A.Mfidterm,'%32s %5.0f %6.2f\n','lon :',lond,lonm);



 