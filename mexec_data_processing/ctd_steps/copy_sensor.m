function [d,h] = copy_sensor(d,h,stn)
%add cruise options call! for now just copy 1 to make code run


names = {'temp','psal','oxygen'};
ii = [];
nn = {};
for no = 1:length(names)
    d.(names{no}) = d.([names{no} '1']);
    if ~sum(strcmp(names{no},h.fldnam))
        ii = [ii find(strcmp([names{no} '1'],h.fldnam))];
        nn = [nn names{no}];
    end
end
h.fldnam = [h.fldnam nn];
h.fldunt = [h.fldunt h.fldunt(ii)];
h.fldserial = [h.fldserial h.fldserial(ii)];
