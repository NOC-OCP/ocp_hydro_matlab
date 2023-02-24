%average to 2 dbar
mctd_04;

try
    stn = stnlocal; mwin_01;
catch me
    warning('could not extract winch data')
    warning(me.message)
end

%bottle firing data
stn = stnlocal; mfir_01;
if exist(m_add_nc(blotfile),'file')
    stn = stnlocal; mfir_03;

    %add winch data
    try
        stn = stnlocal; mwin_to_fir;
    catch me
        warning('no winch data added to fir file')
        warning(me.message)
    end

    %add to sam file
    stn = stnlocal; mfir_to_sam;
end

%calculate and apply depths
station_summary(stnlocal)
stn = stnlocal; mdep_01
get_sensor_groups(stnlocal)

%output to csv files
klist = stnlocal; mout_cchdo_exchangeform; clear klist

%and sync
opt1 = 'batchactions'; opt2 = 'output_for_others'; get_cropt
