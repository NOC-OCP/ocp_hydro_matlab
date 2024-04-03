%average to 2 dbar
mctd_04(stn);

try
    mwin_01(stn);
catch me
    warning('could not extract winch data')
    warning(me.message)
end

%bottle firing data into .fir file
mfir_03(stn)
mfir_03_extra(stn)
%add winch data
try
    mwin_to_fir(stn)
catch me
    warning('no winch data added to fir file')
    warning(me.message)
end

%add to sam file
mfir_to_sam(stn)

%calculate and apply depths
station_summary(stn)
mdep_01(stn)
get_sensor_groups(stn)

%output to csv files
mout_cchdo_exchangeform(stn) %currently having trouble with
%rows/columns, yvonne to investigate***

%and sync
opt1 = 'batchactions'; opt2 = 'output_for_others'; get_cropt
