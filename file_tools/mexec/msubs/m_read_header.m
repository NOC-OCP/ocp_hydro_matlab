function h = m_read_header(ncfile)
% function h = m_read_header(ncfile)
%
% read in the header of mstar format file ncfile

if nargin < 1
    error('Must supply precisely one argument to m_read_header');
end

ncfile = m_resolve_filename(ncfile);

ncfile = m_ismstar(ncfile); % check it is an mstar file

metadata = nc_info(ncfile.name); %refresh metadata
ncfile.metadata = metadata;
var_names = m_unpack_varnames(ncfile);
dimnames = m_unpack_dimnames(ncfile);

globatt = metadata.Attribute;

for k = 1:length(globatt)
    gattname = globatt(k).Name;
    gattvalue = globatt(k).Value;
    com = ['h.' gattname ' = gattvalue;'];
    eval(com)
end

%two useful global attributes are stored as variables so that they can be
%documented better
% attvars = {'date_file_updated' 'data_time_origin'};
% % attvars = {'data_time_origin'};
% % for k = 1:length(attvars)
% %     varname = attvars{k};
% %     varvalue = nc_varget(ncfile.name,varname);
% %     com = ['h.' varname ' = varvalue;'];
% %     eval(com)
% % end

torg = datenum(h.mstar_time_origin);
% h.last_update_string = datestr(torg+h.date_file_updated,31);
h.last_update_string = datestr(h.date_file_updated,31);
% h.data_time_origin_string = datestr(torg+h.data_time_origin,31);
if isempty(h.data_time_origin)
    h.data_time_origin_string = '';
else
    h.data_time_origin_string = datestr(datenum(h.data_time_origin),31); 
end
% for some reason datstr([X 1 1 0 0 0],31) doesn't work properly for X <
% about 1481. This construct with datestr(datenum[],31) seems to work OK .



h.noflds = length(var_names)-1; %there's always a pad variable
%find number of rows/cols dimension sets
krmatch = find(strncmp('nrows',dimnames,5));
kcmatch = find(strncmp('ncols',dimnames,5));
for k = 1:length(krmatch)
    h.rowname{k} = dimnames{krmatch(k)};
    h.rowlength(k) = metadata.Dimension(krmatch(k)).Length;
    h.colname{k} = dimnames{kcmatch(k)};
    h.collength(k) = metadata.Dimension(kcmatch(k)).Length;
end
if length(krmatch) ~= length(kcmatch)
    error('m_write_variable weird mismatch of dimension names - investigate further')
end
h.numdimsets = length(krmatch);


% h.norecs = 0;
% h.nrows = 0;
% h.nplane = 0;
% h.icent = 0;
% h.iymd = 0;
% h.ihms = 0;
% h.pltnum = ' ';
% % blank4 = char(fread(fid,4,'*uchar'))';

% initialise in case noflds == 0

if h.noflds==0
    h.fldnam = {};
else
    h.fldnam = var_names(2:h.noflds+1);
    h.fldnam = h.fldnam(:)';
end
h.fldunt = repmat({' '},size(h.fldnam));
h.alrlim = zeros(size(h.fldnam));
h.uprlim = zeros(size(h.fldnam));
h.absent = zeros(size(h.fldnam));
h.num_absent = zeros(size(h.fldnam));
h.dimsset = cell(size(h.fldnam));
h.dimrows = zeros(size(h.fldnam));
h.dimcols = zeros(size(h.fldnam));

for k = 1:h.noflds
    h.fldunt{k} = nc_attget(ncfile.name,h.fldnam{k},'units');
    h.alrlim(k) = nc_attget(ncfile.name,h.fldnam{k},'min_value');
    h.uprlim(k) = nc_attget(ncfile.name,h.fldnam{k},'max_value');
    h.absent(k) = nc_attget(ncfile.name,h.fldnam{k},'_FillValue');
    h.num_absent(k) = nc_attget(ncfile.name,h.fldnam{k},'number_fillvalue');
    %and any other "extra" attributes
    a = nc_getvarinfo(ncfile.name, h.fldnam{k}); a = {a.Attribute.Name};
    a = setdiff(a,{'long_name' 'units' 'min_value' 'max_value' '_FillValue' 'missing_value' 'number_fillvalue'});
    for ano = 1:length(a)
        if ~isfield(h,['fld' a{ano}])
            %initialise
            h.(['fld' a{ano}]) = repmat({' '},size(h.fldnam));
        end
        h.(['fld' a{ano}]){k} = nc_attget(ncfile.name,h.fldnam{k},a{ano});
    end
    vinfo = nc_getvarinfo(ncfile.name,h.fldnam{k});
    nrowsname = vinfo.Dimension{1};
    h.dimsset{k} = nrowsname(6:end);
    h.dimrows(k) = vinfo.Size(1);
    h.dimcols(k) = vinfo.Size(2);
end



