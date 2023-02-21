function [d,f,p] = loadrdi_mult(f,p)
% function [d,f,p] = loadrdi_mult(f,p)
%
% load multiple files (calls loadrdi)

for no = 1:length(f.ladcpdo)
    f1 = f; f1.ladcpdo = f1.ladcpdo{no};
    [d1(no), p1(no)] = loadrdi(f1, p);
    l(no) = length(d1(no).time_jul);
end
ii = find(l==max(l)); ii = ii(1); %start with longest
iia = setdiff(1:length(f.ladcpdo), ii);
d = d1(ii); p = p1(ii); f.ladcpdo = f.ladcpdo{no};

%append
fldnms = fieldnames(d);
for no = iia
    for fno = 1:length(fldnms)
        dat = d1(no).(fldnms{fno});
        if isnumeric(dat)
            s = size(dat);
            if s(2)==l(no)
                d.(fldnmes{fno}) = [d.(fldnms{fno}) d1(no).(fldnms{fno})];
            elseif s(1)==l(no)
                d.(fldnmes{fno}) = [d.(fldnms{fno}); d1(no).(fldnms{fno})];
            end
        end
    end
end

%sort
[~, iit] = sort(d.time_jul);
for fno = 1:length(fldnms)
    dat = d.(fldnms{fno});
    if isnumeric(dat)
        s = size(dat);
        if s(2)==length(d.time_jul)
            d.(fldnms{fno}) = dat(:,iit);
        elseif s(1)==length(d.time_jul)
            d.(fldnms{fno}) = dat(iit,:);
        end
    end
end
