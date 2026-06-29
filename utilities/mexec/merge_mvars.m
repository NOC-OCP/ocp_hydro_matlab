function [d, hnew] = merge_mvars(d0, h0, d, h, indepvar, nosort)
% function [d, hnew] = merge_mvars(d0, h0, d, h, indepvar, nosort)
%
% combine data from structures d0 and d, using indepvar which is present in
%   both to place data relative to unique([d0.(indepvar); d.(indepvar)])
%   (no interpolation)
%
% fields fldnam and fldunt from structures h0 and h (corresponding to
%   variables in d0 and d, respectively) will be combined in output
%   structure hnew, as will any other fields matching 'fld*'; for any
%   variables present in d0, h0.fldunt (etc.) will be used; h.fldunt (etc.)
%   will be used only for variables present in d but not d0
% no other fields from h0 or h (e.g. comment, data_time_origin) will be
%   carried through (and common time base will not be checked)***

%initialise hnew with h0
hnew.fldnam = h0.fldnam;
hnew.fldunt = h0.fldunt;
hnew = keep_hvatts(hnew, h0);

%check indepvars
mvo = d0.(indepvar);
if length(unique(mvo))<length(mvo)
    error(['merge variable ' indepvar ' has non-unique values for dataname ' h0.dataname]);
end
mvn = d.(indepvar);
if length(unique(mvn))<length(mvn)
    error(['merge variable ' indepvar ' supplied in input d has non-unique values']);
end

%get combined indepvar
if nosort
    s = size(mvo);
    mvnsub = mvn(~ismember(mvn, mvo)); %new ones that aren't in old
    d.(indepvar) = [mvo(:); mvnsub(:)]; %append these, no sorting
    s(s>1) = length(d.(indepvar));
    d.(indepvar) = reshape(d.(indepvar),s); %row vs column vector
else
    s = size(mvo);
    d.(indepvar) = unique([mvo(:); mvn(:)]);
    if sum(s)>2
        s(s>1) = length(d.(indepvar));
        d.(indepvar) = reshape(d.(indepvar),s); %row vs column vector
    end
end

%place combined variables
[~,iico,iio] = intersect(d.(indepvar), mvo);
[~,iicn,iin] = intersect(d.(indepvar), mvn);
vars = setdiff([h0.fldnam h.fldnam], indepvar, 'stable');
a = zeros(size(d.(indepvar))); %add fill value to pad
for vno = 1:length(vars)
    varname = vars{vno};
    if length(varname)>4 && strcmp(varname(end-3:end),'flag')
        data = 9+a;
    else
        data = NaN+a;
    end
    if isfield(d0, varname)
        data(iico) = d0.(varname)(iio);
    end
    if isfield(d, varname)
        data(iicn) = d.(varname)(iin);
        if ~isfield(d0, varname)
            nvno = strcmp(varname,h.fldnam);
            hnew.fldnam = [hnew.fldnam h.fldnam{nvno}];
            hnew.fldunt = [hnew.fldunt h.fldunt{nvno}];
        end
    end
    d.(varname) = data;
end
%add (or fill) other variable attributes from h to hnew
hnew = keep_hvatts(hnew,h); 

%remake fields that shouldn't be filled with NaN or 9
if strcmp(indepvar,'sampnum') && isfield(d,'sampnum') && isfield(d,'statnum')
    d.statnum = floor(d.sampnum/100); 
    if isfield(d, 'position')
        d.position = d.sampnum-d.statnum*100;
    end
end


