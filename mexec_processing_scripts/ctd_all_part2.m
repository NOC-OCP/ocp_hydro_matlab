%average to 2 dbar
mctd_04;

%bottle firing data
stn = stnlocal; mfir_01;
if exist(m_add_nc(blotfile),'file')
    stn = stnlocal; mfir_03;

    %winch data
    stn = stnlocal; mwin_01;
    stn = stnlocal; mwin_to_fir;

    %add to sam file
    stn = stnlocal; mfir_to_sam;
end

%calculate and apply depths
stations_to_reload = stnlocal; station_summary
stn = stnlocal; mdep_01

if 0
    %output to csv files
stn = stnlocal; mout_exch_ctd
mout_exch_sam

%and sync
scriptname = 'batchactions'; oopt = 'output_for_others'; get_cropt
end
