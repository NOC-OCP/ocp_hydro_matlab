%%%%% apply factory calibrations to uncalibrated (still in voltage units) underway sensors - from cruise option file %%%%%

scriptname = mfilename; oopt='uway_factory_cal'; get_cropt

for m=1:length(sensors_to_cal)
    h = m_read_header(otfile);
    varnum = find(strcmp(sensors_to_cal{m}, h.fldnam));
    
    % rename variable to raw
    MEXEC_A.MARGS_IN = {
        otfile
        'y' % yes, overwrite file
        '8' % rename vars
        int2str(varnum) % variable number to rename
        [sensors_to_cal{m},'_raw'] % new name
        '/' % keep existing unit (volt?)
        '-1' % done
        '/' % quit
        };
    mheadr
    % apply calibration and rename units
    MEXEC_A.MARGS_IN = {
        otfile
        'y' % yes, overwrite file
        [sensors_to_cal{m},'_raw'] % variable to calibrate
        [sensors_to_cal{m},'_raw'] % input variables for calibration
        sensorcals{m} % function for calibration
        sensors_to_cal{m} % new name for output variable
        sensorunits{m} % new unit for output variable (or '/' to retain existing)
        ' ' % quit
        };
    mcalib2
end
