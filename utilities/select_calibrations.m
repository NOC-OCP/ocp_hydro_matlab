function calstr = select_calibrations(docal, calstr0)
% take only the calibration structures for variables
% set to 1 in structure docal
% from calstr0 and put into calstr
%
% e.g. 
%   calstr0.temp1.jc200 = 'dcal.temp1 = d0.temp1+1e-3;';
%   calstr0.cond1.jc200 = 'dcal.cond1 = d0.cond1+1e-3;';
%   calstr0.temp2.jc200 = 'dcal.temp2 = d0.temp1+1e-4*d0.statnum;';
%   calstr0.cond2.jc200 = 'dcal.cond2 = d0.cond2.*1.0002;';
%   docal.temp = 1;
%   docal.cond = 0;
% produces calstr with fields for temp1 and temp2 but none for cond1 or
% cond2

cflag = fieldnames(docal);
csens = fieldnames(calstr0);
for vno = 1:length(cflag) %loop through variables
    if docal.(cflag{vno})==1
        thisvar = find(strncmp(cflag{vno}, csens, length(cflag{vno})));
        for sno = 1:length(thisvar)
            calstr.(csens{thisvar(sno)}) = calstr0.(csens{thisvar(sno)});
        end
    end
end

if ~exist('calstr','var')
    calstr = [];
end
return
