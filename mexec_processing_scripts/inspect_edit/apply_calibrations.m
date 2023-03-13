function [dcal, hcal] = apply_calibrations(d0, h0, calstr, varargin)
% [dcal, hcal] = apply_calibrations(d0, h0, calstr);
% [dcal, hcal] = apply_calibrations(d0, h0, calstr, docal);
% [dcal, hcal] = apply_calibrations(d0, h0, calstr, 'q');
%
% d0 and h0 are the uncalibrated data and header loaded from mstar file
% using mload
% calstr is a nested structure:
%   fieldnames are parameters to be calibrated, e.g. cond, fluor
%   their fieldnames are sensors, given either by serial number (e.g.
%     sn1234) or place (e.g. pl1 for cond1, just pl for something with only
%     one sensor, like fluor); to specify by serial number h0 must contain
%     fldserial, a list of serial numbers matching fldnam
%   each sensor field in turn contains 1-2 fields: 
%     required: cruisename gives calibration function, as a string,
%       setting e.g. dcal.cond as a function of d0.cond and possibly other
%       fields in d0 or dcal, for this particular sensor number; 
%     optional: msg gives information on the source of calibration
% e.g.
%   >>  calstr.temp.pl1.jc200 = 'dcal.temp = d0.temp+1e-3;'
%   >>  calstr.temp.pl1.msg = 'from SBE35 comparison stations 1-30';
%   >>  calstr.temp.pl2.jc200 = 'dcal.temp = d0.temp-1e-4*d0.statnum;'
%   >>  calstr.temp.pl2.msg = 'from SBE35 comparison stations 1-30';
%   >>  calstr.cond.pl1.jc200 = 'dcal.cond = d0.cond.*(1+2.5e-3)/35;'
%   >>  calstr.cond.pl1.msg = 'from bottle salinity stations 1-22';
%   >>  calstr.oxygen.pl1.jc200 = 'dcal.oxygen = d0.oxygen.*(1.005+1e-2*dcal.temp)+d0.statnum/5;';
% or
%   >>  calstr.temp.sn1234.jc200 = 'dcal.temp = d0.temp+1e-3;'
%  ...
%   >>  calstr.oxygen.sn203.jc200 = 'dcal.oxygen = d0.oxygen.*(1.005+1e-2*dcal.temp)+d0.statnum/5;';
%
% then
%
%   >>  [dcal, hcal] = ctd_apply_cals(d0, h0, calstr);
%
% would output dcal containing adjusted variables (here temp1, temp2,
%   cond1, and oxygen1) only, and hcal containing fldnam, fldunt, and (if
%   in h0) fldserial matching the fields of dcal, plus a comment field
%   incorporating the msg information from all these sensors
% note that in the above example the oxygen calibration depends on
%   *calibrated* temperature; to do this it is necessary that temp.pl1
%   comes before oxygen.pl1 in calstr, as calibrations will be applied and
%   fields of dcal created sequentially
%
% if optional input docal (structure) is included, only parameters set to 1
%   in docal will be operated on
%
% see mctd_02, ctd_evaluate_sensors, and mtsg_merge_av for calling
%     examples; 
% see calibration, ctd_cals case in opt_sd025 for calstr syntax examples

m_common

%check first input
if ~isstruct(calstr) || isempty(calstr)
    dcal = []; hcal = [];
    warning('no calibrations to apply, returning empty')
    return
end

%select calibrations to apply (optional)
qflag = 0;
for no = 1:length(varargin)
    if isstruct(varargin{no})
        docal = varargin{no};
        cflag = fieldnames(docal);
        for vno = 1:length(cflag)
            if ~docal.(cflag{vno}) && isfield(calstr,cflag{vno})
                calstr = rmfield(calstr,cflag{vno});
            end
        end
    else
        qflag = strcmp(varargin{no},'q');
    end
end

params = fieldnames(calstr);
if length(unique(params))<length(params)
    error('duplicate sensor calibration functions found, check opt_%s mctd_02b case', mcruise)
end

hcal.fldnam = {}; hcal.fldunt = {}; hcal.comment = '';

hasnums = {'temp' 'cond' 'oxygen'};

for pno = 1:length(params)
    param = params{pno}; %e.g. cond
    sens = fieldnames(calstr.(param)); 

    for sno = 1:length(sens)
        sen = sens{sno}; %e.g. sn1000 or pl2
        calf = calstr.(param).(sen).(mcruise);

        if strncmp('sn',sen,2) %by serial number
            m = strncmp(param, h0.fldnam, length(param));
            m = m & strcmp(sen(3:end), h0.fldserial);
            if ~sum(m)
                continue
            end
            ii = find(m); ii = ii(1); 
            sensnum = h0.fldnam{ii}(length(param)+1:end); %could be empty

        elseif strncmp('pl',sen,2) %by place (ctd1 or ctd2)
            sensnum = sen(3:end); %could be empty
            m = strcmp([param sensnum], h0.fldnam);
            ii = find(m);

        end

        if ~isempty(sensnum)
            %need to turn temp to tempN, cond to condN, etc.
            for nno = 1:length(hasnums)
                calf = replace(calf, hasnums{nno}, [hasnums{nno} sensnum]);
            end
        end

        %evaluate cstr, the string giving the calibration expression
        eval(calf);
        if ~qflag
            fprintf(1, '\n%s\n\n', calf)
        end
        %and add info to hcal
        hcal.fldnam = [hcal.fldnam h0.fldnam{ii}];
        hcal.fldunt = [hcal.fldunt h0.fldunt{ii}];
        if isfield(calstr.(param).(sen),'msg') && ~isempty(calstr.(param).(sen).msg)
            calms = [' (' calstr.(param).(sen).msg ')'];
        else
            calms = '';
        end
        hcal.comment = [hcal.comment sprintf('calibration%s applied to %s using %s\n', calms, h0.fldnam{m}, calf)];
    end
end
if exist('dcal', 'var')
    %propagate the serial numbers and other variable attributes
    hcal = keep_hvatts(hcal,h0);
else
    dcal = [];
end
