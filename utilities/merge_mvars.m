function [d, hnew] = merge_mvars(d0, h0, d, h, indepvar, nosort)
% function [d, hnew] = merge_mvars(d0, h0, d, h, indepvar, nosort)
%
% merge variables in d0 and d using indepvar, with no interpolation
%
% d0, h0, d, and h are structures of data and header information, like
% those produced by mload with two output arguments
%
% d0 and d must both contain indepvar as a field
%
% h0 and h must both have fldnam (cell array listing fields in d0 or d) 
% and fldunt (cell array listing corresponding units)
%
%     indepvar (string) gives the name of the independent
%         variable to use for placing new data into existing variables.
%         Normally the resulting indepvar will be the unique, sorted
%         combination of the original (from filename) and new (from d)
%         values of indepvar; however, there will be no sorting if either
%         a. they contain the same values, or b. 
%     nosort is true; then the values in d that are not in the original file
%         already will be appended to the end. Other variables (from both
%         file and d) will be padded to the same size as the new indepvar,
%         with one exception: if indepvar is sampnum, statnum and position
%         will be reconstructed from it***
%
% variables whose name ends in _flag will be filled with 9; other variables
% will be filled with NaN

hnew.fldnam = h0.fldnam; hnew.fldunt = h0.fldunt;

%check indepvars
mvo = d0.(indepvar);
if length(unique(mvo))<length(mvo)
    error(['merge variable ' indepvar ' supplied in input d0 has non-unique values']);
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
    s(s>1) = length(d.(indepvar));
    d.(indepvar) = reshape(d.(indepvar),s); %row vs column vector
end

%place combined variables
[~,iico,iio] = intersect(d.(indepvar), mvo);
[~,iicn,iin] = intersect(d.(indepvar), mvn);
vars = setdiff([h0.fldnam h.fldnam], indepvar);
a = zeros(size(d.(indepvar))); %add fill value to pad
for vno = 1:length(vars)
    varname = vars{vno};
    if length(varname)>4 && strcmp(varname(end-4:end),'flag')
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
            nvno = find(strcmp(varname,h.fldnam));
            hnew.fldnam = [hnew.fldnam h.fldnam{nvno}];
            hnew.fldunt = [hnew.fldunt h.fldunt{nvno}];
        end
    end
    d.(varname) = data;
end

%remake fields that shouldn't be filled with NaN or 9***
if strcmp(indepvar,'sampnum') && isfield(d,'sampnum') && isfield(d,'statnum')
    d.statnum = floor(d.sampnum/100); 
    if isfield(d, 'position')
        d.position = d.sampnum-d.statnum*100;
    end
end

