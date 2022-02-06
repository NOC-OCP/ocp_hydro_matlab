%%%%% apply factory calibrations to uncalibrated (still in voltage units) underway sensors - from cruise option file %%%%%

scriptname = mfilename; oopt='uway_factory_cal'; get_cropt

for m=1:length(sensors_to_cal)
    h = m_read_header(otfile);
    varnum = find(strcmp(sensors_to_cal{m}, h.fldnam));
    
    iiv = find(strncmp(sensors_to_cal{m},h.fldnam,length(sensors_to_cal{m})));
    iir = strfind(h.fldnam{iiv},'_raw');
    if length(iir)==0
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
    end
    sensorraw = [sensors_to_cal{m} '_raw'];
    
    % apply calibration and rename units
    MEXEC_A.MARGS_IN = {
        otfile
        'y' % yes, overwrite file
        sensorraw % variable to calibrate
        sensorraw % input variables for calibration -- factory cals don't depend on any other vars
        sensorcals{m} % function for calibration
        sensors_to_cal{m} % new name for output variable
        sensorunits{m} % new unit for output variable (or '/' to retain existing)
        ' ' % quit
        };
    mcalib2
end

% windspeed_ms from speed 'y = x1*1852/3600' % 'y=x1*0.512' % bim used 0.512 on jc032, but the correct answer is (BAK thinks) 0.5144444
