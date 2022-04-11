d = mload(infile, 'lat long');
if max(mod(abs([d.lat(:);d.long(:)])*100,100))<=61
    
    if std(d.lat)<.1 & std(d.lon)<.1 % ship hasn't moved much
        warning('Cannot determine whether or not to apply cnav fix. Not applying.');
        
    else
        mdocshow(scriptname, ['applying cnav fix to cnav_' mcruise '_d' day_string '_edt.nc']);
        sensors_to_cal={'lat','long'};
        sensorcals={'y=cnav_fix(x1)' 'y=cnav_fix(x1)'};
        sensorunits={'/','/'}; % keep existing units
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
    
else
    mdocshow(scriptname, ['cnav fix not required for cnav_' mcruise '_d' day_string '_edt.nc']);
end