function [d,f,p] = loadrdi_mult(f,p)
% function [d,f,p] = loadrdi_mult(f,p)
%
% load multiple files (calls loadrdi)
% all must have their own header; if not you will have to concatenate
% instead

n = 1;
if iscell(f.ladcpdo) && ~isempty(f.ladcpdo)
    for no = 1:length(f.ladcpdo)
        f1 = f; f1.ladcpdo = f1.ladcpdo{no};
        [d1(no), p1(no)] = loadrdi(f1, p);
        l(no) = length(d1(no).time_jul);
    end
    n = no;
end
if iscell(f.ladcpup) && ~ isempty(f.ladcpup)
    for no = 1:length(f.ladcpup)
        f1 = f; f1.ladcpup = f1.ladcpup{no};
        [d1(no+n), p1(no+n)] = loadrdi(f1, p);
        l(no+n) = length(d1(no+n).time_jul);
    end
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
                d.(fldnms{fno}) = [d.(fldnms{fno}) d1(no).(fldnms{fno})];
            elseif s(1)==l(no)
                d.(fldnms{fno}) = [d.(fldnms{fno}); d1(no).(fldnms{fno})];
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
