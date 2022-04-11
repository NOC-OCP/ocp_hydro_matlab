ssd0 = MEXEC_G.ssd; MEXEC_G.ssd = 1;

mctd_04;

stn = stnlocal; mfir_01;
stn = stnlocal; mfir_03;

stn = stnlocal; mwin_01;
stn = stnlocal; mwin_to_fir;

stn = stnlocal; mfir_to_sam;

stations_to_reload = stnlocal; station_summary
stn = stnlocal; mdep_01

MEXEC_G.ssd = ssd0;
