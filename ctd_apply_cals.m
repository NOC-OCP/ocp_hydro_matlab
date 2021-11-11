function [dcal, hcal] = ctd_apply_cals(d0, h0, docal, calstr);
% [dcal, hcal] = ctd_apply_cals(d0, h0, docal, calstr);
%
% d0 and h0 are the uncalibrated data and header loaded from mstar file
% using mload
% docal is a structure with fields indicating which variables to calibrate
% calstr is a structure with fields giving (in string form) calibrations
% for each sensor for this cruise, as well as (optionally) a message for
% the comment field
% e.g.
%     docal.temp = 1;
%     docal.cond = 0;
%     calstr.temp1.jc200 = 'dcal.temp1 = d0.temp1+1e-3;'
%     calstr.temp1.msg = 'from SBE35 comparison stations 1-30';
%     calstr.temp2.jc200 = 'dcal.temp1 = d0.temp1-1e-4*d0.statnum;'
%     calstr.temp2.msg = 'from SBE35 comparison stations 1-30';
%     calstr.cond1.jc200 = 'dcal.cond1 = d0.cond1.*(1+2.5e-3)/35;'
%     calstr.cond1.msg = 'from bottle salinity stations 1-22';
%     [dcal, hcal] = ctd_apply_cals(d0, h0, docal, calstr);
%  would output dcal containing adjusted temp1 and temp2 only
%
% if you want e.g. an oxygen calibration that is a function of temperature
% as calibrated here, specify that in calstr, e.g. 
%     calstr.oxygen1.jc200 = 'dcal.oxygen1 = d0.oxygen1*(1.005+1e-2*dcal.temp1)+d0.statnum/5;'
% and make sure calstr.temp1 is set before calstr.oxygen1
%
% see mctd_02

m_common

hcal.fldnam = {}; hcal.fldunt = {}; hcal.comment = '';

calsens = fieldnames(calstr); 
for sno = 1:length(calsens)
    
    %figure out if this calstr should be applied, depending on flag
    if ~isempty(str2num(calsens{sno}(end)))
        calvar = calsens{sno}(1:end-1);
    else
        calvar = calsens{sno};
    end
    
    if docal.(calvar)
        
        if ~isfield(calstr.(calsens{sno}),mcruise)
            error(['docal.' calvar ' and calstr.' calsens{sno} ' set but calstr.' calsens{sno} ' has no field ' mcruise ' for this cruise'])
        end
        if ~isfield(d0, calsens{sno})
            warning(['no ' calsens{sno} ' in d0; skipping calibration'])
            return
            
        else
            
            %apply to dcal
            calf = calstr.(calsens{sno}).(mcruise);
            fprintf(1,'\n%s\n\n',calf)
            eval(calf);
            
            %add to hcal
            if isfield(h0,'fldnam')
                ii = find(strcmp(calsens{sno},h0.fldnam));
                hcal.fldnam = [hcal.fldnam calsens{sno}]; hcal.fldunt = [hcal.fldunt h0.fldunt(ii)];
                if isfield(calstr.(calsens{sno}), 'msg')
                    calms = calstr.(calsens{sno}).msg;
                    hcal.comment = [hcal.comment sprintf('calibration (%s) applied to %s using %s\n', calms, calsens{sno}, calf)];
                else
                    hcal.comment = [hcal.comment sprintf('calibration applied to %s using %s\n', calsens{sno}, calf)];
                end
            end
            
        end
        
    end
    
end
