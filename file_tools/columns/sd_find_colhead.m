function varargout = sd_find_colhead(hdr, hcpat, icolhead, icolunits)
% function [iih, ch, un] = sd_find_colhead(hdr, hcpat, icolhead, icolunits);
%
% find and parse 1 or more column header (and optionally column units)
%   lines from cell array hdr, optionally by searching for pattern hcpat
%
% hdr (MxN) and hcpat (Kx1, or empty) are cell arrays
% icolhead and icolunits are vector indices; if K>0 then
%   max([icolhead(:);icolunits(:)])<=K
%
% if hcpat is empty, iih = 1:max([icolhead(:);icolunits(:)])
% if hcpat is not empty, searches hdr for the rows where each element
%   of hcpat is found in a column, and iih starts from the first such row
%   (rather than from 1)
% hdr(iih(icolhead),:) are turned into acceptable matlab variable names
%   (appending contents of multiple rows for each column if
%   length(icolhead)>1) and output as ch;  hdr(iih(chunts),:) is parsed the
%   same way and output as un.
%
% e.g.
% hdr = {'this is file', '', '' '';
%        'one of one', 'or two', ''
%        'cast no.', 'niskin', 'data'
%        '', 'bottle', ''
%        '', '', '(units)'
%        '1', '5', '21.5729'};
% hcpat = {'niskin';'bottle'}; icolhead = 1:2; icolunits = 3;
% produces
% iih = 3:5;
% ch = {'cast_no_', 'niskin_bottle', 'data'};
% un = {'', '', '_units_'};
%
% if hcpat occurs P times, iih will contain all P sets of indices
% (concatenated) and ch and un will be Pxncol
%

if isempty(icolhead)
    error('icolhead must have at least one element')
end

nhl = max([icolhead(:);icolunits(:)]);
np = length(hcpat);
s = size(hdr);

%get rid of leading and trailing whitespace
hdr = strtrim(hdr);

varargout = cell(1,nargout);

if np==0
    iih = 1:nhl;
else
    %header rows are those where one column matches rows of hcpat
    m = true(s(1)-np+1,s(2));
    for no = 1:np
        m = m & strcmp(hcpat{no}, hdr(no+[0:s(1)-np],:));
    end
    [iih,~] = find(m); %first row in each instance of header rows
    if isempty(iih)
        return
    end
    %now for each of these, keep as many following as needed for icolhead and
    %icolunits
    iih = repmat(iih,1,nhl)+repmat([0:nhl-1],length(iih),1);
    varargout{1} = iih;
    nb = size(iih,1);
end

%convert the relevant rows from iih to matlab variable name forms
if nargout>1 && ~isempty(iih)
    npat = cellstr(['()=-:.?><][{}#~$%^&*!;']');
    npat = [npat; ' '];
    hdr = replace(hdr, npat, '_');
    hdr = replace(replace(replace(hdr,'+','_plus_'),'/','_per_'),'%','_percent');
    hdr = replace(hdr, '__', '_');
    
    ch = cell(nb,size(hdr,2));
    un = ch;
    %loop through blocks/occurrences
    for bno = 1:nb
        h = hdr(iih(bno,icolhead), :);
        if ~isempty(icolunits)
            u = hdr(iih(bno,icolunits),:);
        end
        %loop through columns
        for no = 1:size(hdr,2)
            a = replace(lower(sprintf('%s_', h{:,no})),'__','_');
            if ~isvarname(a)
                warning('invalid variable name in row %d; unless variable names were supplied in input structure, column %d will be skipped',iih(icolhead(1)),no)
                a = '_'; %will make ch empty
            end
            ch{bno,no} = a(1:end-1);
            if ~isempty(icolunits)
                a = replace(lower(sprintf('%s_', u{:,no})),'__','_');
                un{bno,no} = a(1:end-1);
            end
        end
    end
    varargout{2} = ch;
    varargout{3} = un;
end
