%average to 2 dbar
mctd_04(stn);

try
    mwin_01(stn);
    win = 1;
catch me
    warning('could not extract winch data')
    warning(me.message)
    win = 0;
end

%bottle firing data into .fir file
mfir_03(stn)
mfir_03_extra(stn)
%add winch data
if win
    try
        mwin_to_fir(stn)
    catch me
        warning('no winch data added to fir file')
        warning(me.message)
    end
end

%add to sam file
mfir_to_sam(stn)
msbe35_01(stn) %read sbe35 data, if not already done

%calculate and apply depths
station_summary(stn)
mdep_01(stn)
% get_sensor_groups(stn)

%output to csv files
% mout_cchdo_exchangeform(stn)

%and sync
opt1 = 'batchactions'; opt2 = 'output_for_others'; get_cropt
