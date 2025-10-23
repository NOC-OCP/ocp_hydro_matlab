function m_write_variable(ncfile,v,opt)
% function m_write_variable(ncfile,v,opt)
%
% write data v to nc file ncfile
% both ncfile and v are structures
%
% use optional third argument opt = 'nodata' if you want to create the variable in the
% file but not put the data or the attributes

if nargin < 3; opt = ' '; end

% if ~isfield(v,'type') v.type = 'double'; end
if ~isfield(v,'units'); v.units = ' '; end
if ~isfield(v,'data') || ~isfield(v,'name')
    error('m_write_variable: the variable argument must have fields data and name');
end
if ~isfield(v,'type'); v.type = class(v.data); end


s  = size(v.data);

if length(s) > 2
    error('m_write_variable Not set up to work with arrays with more than 2 dimensions yet');
end

d1 = s(1);
d2 = s(2);

metadata = nc_info(ncfile.name); %refresh metadata
ncfile.metadata = metadata;

dimnames = m_unpack_dimnames(ncfile);

krmatch = find(strncmp('nrows',dimnames,5));
kcmatch = find(strncmp('ncols',dimnames,5));

rowname = dimnames(krmatch);
colname = dimnames(kcmatch);
for k = 1:length(krmatch)
    rowlength(k) = metadata.Dimension(krmatch(k)).Length;
    collength(k) = metadata.Dimension(kcmatch(k)).Length;
end

if length(krmatch) ~= length(kcmatch)
    error('m_write_variable weird mismatch of dimension names - investigate further')
end


%now sort out the dimensions

clear nrowsname ncolsname

matchok = 0;

if isempty(krmatch)
    %no nrows/ncols yet. make them
    nrowsname = 'nrows1';
    ncolsname = 'ncols1';
    nc_add_dimension(ncfile.name,nrowsname,d1);
    nc_add_dimension(ncfile.name,ncolsname,d2);
    matchok = 1;
else
    % at least some rows/cols dimension names exist


    dim_file_pairs = [rowlength(:) collength(:)];
    dim_new_pair = [d1 d2];

    %find whether required dimension pair matches any existing pair

    for k = 1:size(dim_file_pairs,1)
        if (dim_new_pair(1) == dim_file_pairs(k,1) && dim_new_pair(2) == dim_file_pairs(k,2))
            nrowsname = rowname{k};
            ncolsname = colname{k};
            matchok = 1;
            %we have found matching dimensions
            break
        end
    end

    if matchok == 0
        % we must make the next set of names

        for k2 = 1:length(rowname)
            knam = rowname{k2};
            if length(knam) > 5
                suffix(k2) = str2num(knam(6:end));
            else
                suffix(k2) = 1;
            end
        end
        newsuffix = max(suffix)+1;
        nrowsname = ['nrows' sprintf('%d',newsuffix)];
        ncolsname = ['ncols' sprintf('%d',newsuffix)];
        nc_add_dimension(ncfile.name,nrowsname,d1);
        nc_add_dimension(ncfile.name,ncolsname,d2);

    end
end

m_add_variable_name(ncfile,v.name,{nrowsname ncolsname},v.type);
if strcmp(opt,'nodata'); return; end
if ~isempty(v.units); nc_attput(ncfile.name,v.name,'units',v.units); end
if isfield(v,'serial') && ~isempty(v.serial); nc_attput(ncfile.name,v.name,'serial',v.serial); end
nc_varput(ncfile.name,v.name,v.data);
m_uprlwr(ncfile,v.name);

return
