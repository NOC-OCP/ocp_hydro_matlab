function m_add_variable_name(ncfile,string_var_name,dims_array,datatype)
% function m_add_variable_name(ncfile,string_var_name,dims_array,datatype)
%
% Add variable string_var_name to ncfile if it isn't already in it
%
% input arguments:
%   ncfile, a structure
%   string_var_name
%   dims_array, a cell array (default {'nrows' 'ncols'})
%   data type, 'double' or 'char' (default 'double')

if nargin < 4
    datatype = 'double'; %default data type to double
end

if nargin < 3
    dims_array = {'nrows' 'ncols'}; %default dimensions of a variable
end

%metadata = nc_infoqdim(ncfile.name); %refresh metadata
metadata = nc_info(ncfile.name); %refresh metadata
ncfile.metadata = metadata;

dimnames = m_unpack_dimnames(ncfile);
varnames = m_unpack_varnames(ncfile);

%test to see if a variable already exists with correct dimensions; if not, add it.

kmatch = strmatch(string_var_name,varnames,'exact');

if ~isempty(kmatch) % It exists; check dimensions match;
    if ~isfield(metadata,'Dataset') % if 'Dataset' has not already been read in, read it now
        metadata = nc_info(ncfile.name);
        ncfile.metadata = metadata;
    end
    olddims = metadata.Dataset(kmatch).Dimension; % this is the cell array of dimensions of the variable in the file

    kcmp = strcmp(sort(olddims),sort(dims_array));

    if sum(kcmp) ~= length(dims_array)
        errstr0 = 'Error in m_add_variable';
        errstr1 = ['Attempting to add variable ''' string_var_name ''' to file ''' ncfile.name ''''];
        errstr2 = ['Variable already exists in file but new requested dimensions :'];
        for kk = 1:length(dims_array)
            errstr2 = [errstr2 ' ' dims_array{kk} ' :'];
        end
        errstr3 = ['do not match dimensions of variable in file :'];
        for kk = 1:length(olddims)
            errstr3 = [errstr3 ' ' olddims{kk} ' :'];
        end
        errstr4 = sprintf('\n%s\n%s\n%s\n%s\n',errstr0,errstr1,errstr2,errstr3);
        error(errstr4);
    end

    %Now check data type; cludge it until I think of a neater solution
    oldtype_index = metadata.Dataset(kmatch).Nctype;
    types = {'' 'char' '' '' '' 'double' ''};
    oldtype = types{oldtype_index};
    newtype = datatype;
    if ~strcmp(oldtype,newtype)
        errstr0 = 'Error in m_add_variable';
        errstr1 = ['Attempting to add variable ''' string_var_name ''' to file ''' ncfile.name ''''];
        errstr2 = ['Variable already exists in file but new requested datatype :'];
        errstr2 = [errstr2 ' ' newtype];
        errstr3 = ['do not match data type of variable in file :'];
        errstr3 = [errstr3 ' ' oldtype];
        errstr4 = sprintf('\n%s\n%s\n%s\n%s\n',errstr0,errstr1,errstr2,errstr3)
        error(errstr4);

    end


    %if no error trap, variable exists and dimensions seem OK.

    return
end

% Variable doesn't exist so we will add it; First, check each requested dimension exists in file
for k = 1:length(dims_array)

    kmatch = strmatch(dims_array{k},dimnames,'exact');

    if isempty(kmatch)
        errstr0 = 'Error in m_add_variable';
        errstr1 = ['Attempting to add variable ''' string_var_name ''' to file ''' ncfile.name ''''];
        errstr2 = ['Dimensions must be added before adding new variable. New dimensions required are :'];
        for kk = 1:length(dims_array)
            errstr2 = [errstr2 ' ' dims_array{kk} ' :'];
        end
        errstr3 = ['Existing dimension list is :'];
        for kk = 1:length(dimnames)
            errstr3 = [errstr3 ' ' dimnames{kk} ' :'];
        end
        errstr4 = sprintf('\n%s\n%s\n%s\n%s\n',errstr0,errstr1,errstr2,errstr3);
        error(errstr4);

    end

end

%Add variable name


v.Name = string_var_name;
v.Dimension = dims_array;
v.Nctype = datatype;
%keyboard
nc_addvar(ncfile.name,v);

% % metadata = nc_info(ncfile.name); %refresh metadata
% % ncfile.metadata = metadata;
m_add_default_variable_attributes(ncfile,string_var_name)

return
