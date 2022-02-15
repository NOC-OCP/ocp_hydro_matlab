function dg = grid_cast_segment(d, gridvar, ge, varargin);
% function dg = grid_cast_segment(d, gridvar, ge, varargin);
%
% grids variables in structure d based on field gridvar by averaging into
% bins with edges ge
%
% optional inputs:
% trunc (default 1) 1 to discard bins with no gridvar values, 0 to keep
%     (filling with NaNs)***
% cmgridvar (default 0) 1 to save average values of gridvar as well (rather
%     than average of bin_edges)
%
% d.(gridvar) must be a vector
% when it is 1xM, other variables in d can be 1xM or NxM
% when it is Mx1, other variables in d can be Mx1 or MxN

cmgridvar = 0;
trunc = 1;
for no = 1:2:length(varargin)
    eval([varargin{no} ' = varargin{no+1};'])
end

fn = fieldnames(d);

%find dimensions (and make ge match for convenience)
if size(d.(gridvar),1)==1
    isrow = 1;
    ge = ge(:)';
else
    isrow = 0;
    ge = ge(:);
end

%sort by gridvar
iig = find(~isnan(d.(gridvar)));
[x, iip] = sort(d.(gridvar)(iig)); %***what about repeated values?
iip = iig(iip);
for vno = 1:length(fn)
    if isrow
        d.(fn{vno}) = d.(fn{vno})(:,iip);
    else
        d.(fn{vno}) = d.(fn{vno})(iip,:);
    end
end

%set up gridding coordinate
if trunc
    %discard the bins with no data
    iie = find(ge(2:end)<x(1));
    if ~isempty(iie)
        ge(iie-1) = [];
    end
    iie = find(ge(1:end-1)>x(end));
    if ~isempty(iie)
        ge(iie+1) = [];
    end
end

%bin average***make this have the option to do linear fit as well as
%(default option) to average all points in bin?
for bno = 1:length(ge)-1
    m = (x>=ge(bno) & x<ge(bno+1));
    for vno = 1:length(fn)
        if isrow
            dg.(fn{vno})(bno) = m_nanmean(d.(fn{vno})(:,m),2); %***have option to not ignore nans
        else
            dg.(fn{vno})(bno) = m_nanmean(d.(fn{vno})(m,:));
        end
    end
end
if cmgridvar
    %optionally keep centers of mass of gridvar as well
    dg.([gridvar '_av']) = dg.(gridvar);
end
%save bin centers as new gridvar
dg.(gridvar) = .5*(ge(1:end-1)+ge(2:end));

