% mctd_senscal
%
% apply calibration function specified in opt_cruise to variable calvar (string),
% sensor number senscal (integer, optional), in _24hz file for
% station stn
%
% valid values for calvar: temp, cond, oxygen, fluor, transmittance
% valid values for senscal: 1, 2, []
%
% requires stn and calvar
% [calvar num2str(senscal)] must be a variable in _24hz file
%
% examples:
% stn = 15; calvar = 'temp'; senscal = 2; mctd_senscal %to apply
% calibration to temp2 from station 15
% or
% stn = 15; calvar = 'oxygen'; mctd_senscal %if only one oxygen sensor and it
% is called oxygen, not oxygen1; code will prompt for senscal, but can
% leave empty
%
% this combines/replaces mctd_condcal, mctd_tempcal, mctd_oxycal,
% mctd_fluorcal, mctd_transmisscal,
% cond_apply_cal, temp_apply_cal, oxy_apply_cal, fluor_apply_cal,
% transmiss_apply_cal

minit;
mdocshow(mfilename, ['applies calibration as set in opt_' mcruise ' to ctd_' mcruise '_' stn_string '_24hz.nc, for selected variable']);

root_ctd = mgetdir('M_CTD');
infile = [root_ctd '/ctd_' mcruise '_' stn_string '_24hz'];

%prompt for sensor number
if exist('senscal','var')
    m = ['Running script ' scriptname ' on sensor ' sprintf('%03d',senscal)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    senscal = input('type choice of sensor to calibrate, reply 1 or 2, or just enter for variables with no sensor number: ');
end
clear senslocal
if ~isempty(senscal)
    senslocal = senscal; clear senscal
end
if senslocal>2 | senslocal<1
    m = ['Must specify sensor as 1 or 2. Sensor was sepcified as ' sprintf('%d',senslocal)];
    fprintf(2,'%s\n',m)
    return
end

%get variables and calibration function for this sensor from opt_cruise
scriptname = 'senscals'; oopt = [calvar 'cal']; get_cropt

if ~isempty(calvars) & ~isempty(calstr)
    d = mloadq(infile, sprintf('%s ', calvars{:}));
    for vno = 1:length(calvars)
        eval([calvars{dno} ' = getfield(d, ' calvars{dno} ');'])
    end
    fprintf(1,'\n%s\n\n',calstr);
    eval(calstr)
    
    
    %get list of variables and calibration string in form expected by mcalib2
    x = {}; invars = ' ';
    for n = 1:length(calvars);
        x = [x 'x' num2str(n)];
        invars = [invars calvars{n} ' '];
    end
    invars = invars(2:end-1);
    calstr_mcalib2 = sprintf(ccalstr, 'y', x{:});
    
    %apply to 24hz file
    MEXEC_A.MARGS_IN = {
        infile
        'y'
        calvars{1}
        invars
        calstr_mcalib2
        ' '
        ' '
        ' '
        };
    mcalib2
    
    %display calibration and add comments to file
    x = calvars; 
    calstr_print = sprintf(calstr, calvars{1}, calvars{:});
    fprintf(1,'\n%s\n\n',calstr_print);
    ncfile.name = m_add_nc(infile);
    comment = ['calibration applied to ' calvars{1} ' using ' calstr_print];
    m_add_comment(ncfile,comment);
    
end
