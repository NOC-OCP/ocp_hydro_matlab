function [dcal, hcal] = apply_calibrations(d0, h0, calstr, varargin)
% [dcal, hcal] = apply_calibrations(d0, h0, calstr);
% [dcal, hcal] = apply_calibrations(d0, h0, calstr, docal);
% [dcal, hcal] = apply_calibrations(d0, h0, calstr, 'q');
%
% d0 and h0 are the uncalibrated data and header loaded from mstar file
% using mload
% calstr is a structure:
%     fieldnames indicate sensors to be calibrated
%     each field of calstr has 1-2 fields:
%         required: cruisename gives calibration function, as a string,
%         setting dcal.(sensor) as a function of d0.(sensor) and possibly
%             other fields in d0 or dcal
%         optional: msg gives information on the source of calibration
% e.g.
%   >>  calstr.temp1.jc200 = 'dcal.temp1 = d0.temp1+1e-3;'
%   >>  calstr.temp1.msg = 'from SBE35 comparison stations 1-30';
%   >>  calstr.temp2.jc200 = 'dcal.temp1 = d0.temp1-1e-4*d0.statnum;'
%   >>  calstr.temp2.msg = 'from SBE35 comparison stations 1-30';
%   >>  calstr.cond1.jc200 = 'dcal.cond1 = d0.cond1.*(1+2.5e-3)/35;'
%   >>  calstr.cond1.msg = 'from bottle salinity stations 1-22';
%   >>  calstr.oxygen1.jc200 = 'dcal.oxygen1 = d0.oxygen1.*(1.005+1e-2*dcal.temp1)+d0.statnum/5;';
%   >>  [dcal, hcal] = ctd_apply_cals(d0, h0, calstr);
% would output dcal containing adjusted temp1, temp2, cond1, and oxygen1
%     only, and
% hcal containing dcal fieldnames and units, plus a comment field
%     incorporating the msg information from all these sensors
% note that in this example the oxygen calibration depends on *calibrated*
%     temperature; to do this it is necessary that temp1 comes before
%     oxygen1 in calstr, as calibrations will be applied and fields of
%     dcal created sequentially
%
% if optional input docal (structure) is included, only parameters set to 1
%   in docal will be operated on
%
% see mctd_02, ctd_evaluate_sensors, and mtsg_medav_clean_cal for calling
%     examples; 
% see calibration, ctd_cals case in opt_* for calstr syntax examples

m_common

%select calibrations to apply (optional)
for no = 1:length(varargin)
    if isstruct(varargin{no})
        docal = varargin{no};
        varargin(no) = [];
    end
end
if exist('docal','var')
    cflag = fieldnames(docal);
    csens = fieldnames(calstr);
    for vno = 1:length(cflag) %loop through variables
        if docal.(cflag{vno})==1
            thisvar = find(strncmp(cflag{vno}, csens, length(cflag{vno})));
            for sno = 1:length(thisvar)
                calstr0.(csens{thisvar(sno)}) = calstr.(csens{thisvar(sno)});
            end
        end
    end
    calstr = calstr0;
end

hcal.fldnam = {}; hcal.fldunt = {}; hcal.comment = '';

if ~isstruct(calstr) || isempty(calstr)
    dcal = []; hcal = [];
    warning('no calibrations to apply, returning empty')
    return
end

calsens = fieldnames(calstr);
if length(unique(calsens))<length(calsens)
    error('duplicate sensor calibration functions found, check opt_%s mctd_02b case', mcruise)
end

for sno = 1:length(calsens)

    if ~isempty(str2double(calsens{sno}(end))) %e.g. oxygen1, oxygen2
        calvar = calsens{sno}(1:end-1);
        sensnum = calsens{sno}(end);
    else
        calvar = calsens{sno}; %e.g. oxygen
        sensnum = NaN;
    end


    if ~isfield(calstr.(calsens{sno}),mcruise)
        error(['calstr.' calsens{sno} ' set but calstr.' calsens{sno} ' has no field ' mcruise ' for this cruise'])
    end

    if ~isfield(d0, calsens{sno})
        warning(['no ' calsens{sno} ' in d0; skipping calibration'])
        return

    else

        %calibration function as string expression
        calf = calstr.(calsens{sno}).(mcruise);

        %check for mixed sensors
        if strcmp(calvar,'cond') && ~isnan(sensnum)
            iit = find(strcmp('temp', calf));
            if ~isempty(iit)
                tnum = str2num(calf(iit+4)');
                if ~isnan(tnum) && sum(tnum~=sensnum)>0
                    error('calibration for %s appears to depend on other CTD temp', calsens{sno})
                end
            end
        elseif strcmp(calvar,'oxygen')
            iit = [find(strcmp('temp', calf)) find(strcmp('cond', calf))];
            if ~isempty(iit)
                tnum = str2num(calf(iit+4)');
                if ~isnan(tnum) && sum(tnum~=sensnum)>0
                    warning('calibration for %s appears to depend on other CTD temp or cond', calsens{sno})
                end
            end
        end

        %apply calibration to dcal
        if isempty(varargin) || ~strcmp(varargin{1},'q')
            fprintf(1,'\n%s\n\n',calf)
        end
        eval(calf);

        %add info to hcal
        if isfield(h0,'fldnam')
            ii = find(strcmp(calsens{sno},h0.fldnam));
            hcal.fldnam = [hcal.fldnam calsens{sno}]; hcal.fldunt = [hcal.fldunt h0.fldunt(ii)];
            if isfield(calstr.(calsens{sno}), 'msg') && ~isempty(calstr.(calsens{sno}).msg)
                calms = calstr.(calsens{sno}).msg;
                hcal.comment = [hcal.comment sprintf('calibration (%s) applied to %s using %s\n', calms, calsens{sno}, calf)];
            else
                hcal.comment = [hcal.comment sprintf('calibration applied to %s using %s\n', calsens{sno}, calf)];
            end
        end

    end

end
