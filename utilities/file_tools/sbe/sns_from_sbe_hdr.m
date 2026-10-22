function sns = sns_from_sbe_hdr(h, mvars, varargin)
% sns = sns_from_sbe_hdr(head, varname)
% sns = sns_from_sbe_hdr(h.comment, h.fldnam) 
%
% read sensor serial numbers from SBE .cnv file header as parsed by
% msbe_to_mstar (and stored in the comment attributes of mstar CTD files)
% output those matching the input list of variable names
% 
% first input argument is a cell array containing MEXEC_G.e.g. if first input argument is a structure,  character array, return sns, a Nx2 array
% containing mstar variable names and corresponding serial numbers
%
% if first input argument is a structure containing comment and fldnam,
% return sns, a cell array the same size as h.fldnam containing serial
% numbers corresponding to each variable
%sg, sng, sn_list, stn)
% where h does not contain fldser, extract sensor s/ns SBE header as
% parsed by msbe_to_mstar into h.comment

m_common

if ischar(h)
    head = h;
elseif isfield(h,'fldserial')
    return
else
    head = h.comment;
    h.fldserial = cell(size(h.fldnam));
end

varname_sensorname = {'temp1' ''}
st = {'#     <TemperatureSensor', 'temp1', 'temp2';
    '#     <ConductivitySensor', 'cond1', 'cond2'
    '#     <OxygenSensor', 'oxy1', 'oxy2'
    '#     <PressureSensor', 'press', ' ' %only expect one
    '#     <PAR_Biospherical', 'par', ' '
    '#     <Fluoro', 'fluor', ' '
    '#     <Turbidity', 'turbidity', ' '
    '#     <Altimeter', 'altimeter', ' '
    '#     <WET_LabsCStar', 'transmissivity', ' '
    '#     <SPAR_Sensor', 'spar', ' '    
    };
opt1 = 'ctd_proc'; opt2 = 'track_serials'; MEXEC_G.mcruise
sns = {};
for sno = 1:length(st)
    ii = find(strncmp(st{sno,1},head,length(st{sno,1})));
    if ~isempty(ii)
        sn = cellfun(@(x) x(findstr('<SerialNumber>',x)+14:findstr('</Serial',x)-1),head(ii+1),'UniformOutput',false);
        %in bottle sample file will need to store as data (numeric values),
        %so remove characters and leading 0s now
        sns = [sns; [st(sno,2) regexprep(sn(1), '[^0-9]', '')]];
        if length(sn)>1
            sns = [sns; [st(sno,3) regexprep(sn(2), '[^0-9]', '')]];
        end
        sns(:,2) = cellfun(@(x) num2str(str2num(x)), sns(:,2), 'UniformOutput', false);
    end
end
sns(cellfun('isempty',sns(:,2)),:) = [];
varargout{1} = sns;

if isstruct(h)
    [~,ia,ib] = intersect(h.fldnam,sns(:,1));
    h.fldserial(ia) = sns(ib,2);
    varargout{1} = h.fldserial;
else
    varargout{1} = sns;
end

iisns = strfind(h.comment,'<SerialNumber>');
iisne = strfind(h.comment,'</SerialNumber>');

for sno = 1:length(st)
    ii = strfind(h.comment,['<' st{sno} 'Sensor']);

    if ~isempty(ii)
        n1 = [sa{sno} '1'];
        if isfield(h,'fldserial')
            sn1 = h.fldserial{strncmp(h.fldnam,sa{sno},length(sa{sno})) & contains(h.fldnam,'1')};
        else
            ii1 = min(iisns(iisns>ii(1)))+14:min(iisne(iisne>ii(1)))-1;
            sn1 = h.comment(ii1);
            sn1 = regexprep(sn1, '[^a-zA-Z0-9]','_');
        end
        sg.(n1) = [sg.(n1); {stn sn1}];
        if isnumeric(sn1)
            sn = [sa{sno} '_' num2str(sn1)];
        else
            sn = [sa{sno} '_' sn1];
        end
        if isfield(sng,sn)
            sng.(sn) = [sng.(sn); [stn 1]];
        else
            sng.(sn) = [stn 1];
        end
        if ~ismember(sn1,sn_list.(sa{sno}))
            sn_list.(sa{sno}) = [sn_list.(sa{sno}) sn1];
        end
        if length(ii)>1
            n2 = [sa{sno} '2'];
            if isfield(h,'fldserial')
                sn2 = h.fldserial{strncmp(h.fldnam,sa{sno},length(sa{sno})) & contains(h.fldnam,'2')};
            else
                ii2 = min(iisns(iisns>ii(2)))+14:min(iisne(iisne>ii(2)))-1;
                sn2 = h.comment(ii2);
                sn2 = regexprep(sn2, '[^a-zA-Z0-9]','_');
            end
            sg.(n2) = [sg.(n2); {stn sn2}];
            if isnumeric(sn2)
                sn = [sa{sno} '_' num2str(sn2)];
            else
                sn = [sa{sno} '_' sn2];
            end
            if isfield(sng,sn)
                sng.(sn) = [sng.(sn); [stn 2]];
            else
                sng.(sn) = [stn 2];
            end
            if ~ismember(sn2,sn_list.(sa{sno}))
                sn_list.(sa{sno}) = [sn_list.(sa{sno}) sn2];
            end
        end
    end
end
