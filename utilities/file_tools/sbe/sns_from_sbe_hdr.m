function sns = sns_from_sbe_hdr(head, mvars)
% sns = sns_from_sbe_hdr(head, mvars)
%
% read sensor serial numbers from SBE .cnv file header as parsed by
% msbe_to_mstar (and stored in the comment attributes of mstar CTD files)
% output those matching the input list of variable names
% 
% first input argument is a cell array 
% second input argument is a cell array listing (mexec) variable names for
% which to find serial numbers
%
% output sns matches mvars

m_common

sns = cell(size(mvars));

%how would we find some of the possible S/Ns
st = {'#     <TemperatureSensor', 'temp1', 'temp2';
    '#     <ConductivitySensor', 'cond1', 'cond2'
    '#     <OxygenSensor', 'oxy1', 'oxy2'
    '#     <OxygenSensor', 'sbe_oxygen1V', 'sbe_oxygen2V'
    '#     <PressureSensor', 'press', ' ' %only expect one
    '#     <PAR_Biospherical', 'par', ' '
    '#     <Fluoro', 'fluor', ' '
    '#     <Turbidity', 'turbidity', ' '
    '#     <Altimeter', 'altimeter', ' '
    '#     <WET_LabsCStar', 'transmittance', ' '
    '#     <SPAR_Sensor', 'spar', ' '    
    };
opt1 = 'ctd_proc'; opt2 = 'track_serials'; MEXEC_G.mcruise
%limit to variables in mvar
st = st(ismember(st(:,2),mvars') | ismember(st(:,3),mvars'), :);

for sno = 1:size(st,1)
    %find the line(s) in the cell matching the #    ... pattern
    ii = find(strncmp(st{sno,1},head,length(st{sno,1})));
    if ~isempty(ii)
        %parse the line(s) immediately following for serial number
        sn = cellfun(@(x) x(findstr('<SerialNumber>',x)+14:findstr('</Serial',x)-1),head(ii+1),'UniformOutput',false);
        %in bottle sample file will need to store as data (numeric values),
        %so remove characters and leading 0s now
        sn = cellfun(@(x) regexprep(x, '[^0-9]', ''), sn, 'UniformOutput', false);
        [~,ia,ib] = intersect(st(sno,2:3),mvars);
        sns(ib) = sn(ia);
    end
end
