%%%%% apply factory calibrations to uncalibrated (still in voltage units) underway sensors - from cruise option file %%%%%

scriptname = mfilename; oopt = 'uway_factory_cal'; get_cropt

if exist('sensorcals','var') && isstruct(sensorcals)
    fn = fieldnames(sensorcals);
    h = m_read_header(otfile);
    [vars,iic,iiv0] = intersect(fn,h.fldnam);

    for m = 1:length(vars)
        iiv = find(strncmp(vars{m},h.fldnam,length(sensors_to_cal{m})));
        iir = strfind(h.fldnam{iiv},'_raw');
        if isempty(iir)
            % rename variable to raw
            MEXEC_A.MARGS_IN = {
                otfile
                'y' % yes, overwrite file
                '8' % rename vars
                int2str(iiv0(m)) % variable number to rename
                [vars{m},'_raw'] % new name
                '/' % keep existing unit (volt?)
                '-1' % done
                '/' % quit
                };
            mheadr
        end
        sensorraw = [vars{m} '_raw'];

        % apply calibration and rename units
        MEXEC_A.MARGS_IN = {
            otfile
            'y' % yes, overwrite file
            sensorraw % variable to calibrate
            sensorraw % input variables for calibration -- factory cals don't depend on any other vars
            sensorcals.(fn{iic(m)}) % function for calibration
            vars{m} % new name for output variable
            sensorunits.(fn{iic(m)}) % new unit for output variable (or '/' to retain existing)
            ' ' % quit
            };
        mcalib2
    end
end

if ~isempty(xducer_offset)
    h = m_read_header(otfile);
    iia = find(strcmp(abbrev,h.fldnam));
    if isempty(iia)
        iit = find(strcmp([abbrev '_t'],h.fldnam));
        d = mloadq(otfile,[abbrev '_t'],' ');
        clear dnew hnew
        dnew.(abbrev) = d.([abbrev '_t']) + xducer_offset;
        hnew.fldnam = {abbrev};
        hnew.fldunt = h.fldunt(iit);
        hnew.comment = [abbrev ' calculated by adding xducer_offset specified in opt_' mcruise ' to ' abbrev '_t'];
        mfsave(otfile,dnew,hnew,'-addvars')
    end
end


% windspeed_ms from speed 'y = x1*1852/3600' % 'y=x1*0.512' % bim used 0.512 on jc032, but the correct answer is (BAK thinks) 0.5144444
