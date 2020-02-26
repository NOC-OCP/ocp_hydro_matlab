function vardata = nc_varget(ncfile , varname , varargin )
%
% version of nc_varget for mexec to replace snctools version
% the aim is to replace snctools nc_ calls with faster versions that make
% simple native matlab netcdf calls.
%
% rather than changing every mexec program, the snctools library can be
% replaced with this library
%
% varargin can be
% start, count, stride
% start begins at zero, so if start = [2 3] it will retrieve data from
% row 3, column 4;
% if start is defined and count is empty, the data are retrieved from
% the point denoted by the start offset, to the end of each row and column.
%
% When I tried it, the -1 notation for count in the snctools version did
% not work as intended.
%
% This version handles _FillValue scale_factor and add_offset.
% missing_value is not looked for. missing_value is information to the
% user, and not an indication that the data should ncessarily be changed
% to NaN.
%
% The _FillValue is is in the normalisation of the
% file value of the variable, not the real world value.
% So the variable is tested against _FillValue, and then scaled, and then
% offset. This convention agrees with the matlab ncread command.
%
% The old snctools description was
%
% % DATA = NC_VARGET(NCFILE,VARNAME) retrieves all the data from the
% % variable VARNAME in the netCDF file NCFILE.
% %
% % DATA = NC_VARGET(NCFILE,VARNAME,START,COUNT) retrieves the contiguous
% % portion of the variable specified by the index vectors START and
% % COUNT.  Remember that SNCTOOLS indexing is zero-based, not
% % one-based.  Specifying a -1 in COUNT means to retrieve everything
% % along that dimension from the START coordinate.
% %
% % DATA = NC_VARGET(NCFILE,VARNAME,START,COUNT,STRIDE) retrieves
% % a non-contiguous portion of the dataset.  The amount of
% % skipping along each dimension is given through the STRIDE vector.
% %
% % NCFILE can also be an OPeNDAP URL if the proper java SNCTOOLS
% % backend is installed.  See the README for details.
% %
% % NC_VARGET tries to be intelligent about retrieving the data.
% % Since most general matlab operations are done in double precision,
% % retrieved numeric data will be cast to double precision, while
% % character data remains just character data.  %
%
%
% bak jc191 6 Feb 2020
%

args = varargin(:);
start = [];
count = [];
stride = [];
switch length(args)
    case 1
        start = args{1};
    case 2
        start = args{1};
        count = args{2};
    case 3
        start = args{1};
        count = args{2};
        stride = args{3};
    otherwise
end

ncid = netcdf.open(ncfile,'NOWRITE');

varid = netcdf.inqVarID(ncid,varname);


% is there is start but no count, then calculate count to retrieve from
% start to the end of each dimension

[varname,xtype,dimids,natts] = netcdf.inqVar(ncid, varid);

if isempty(count) & ~isempty(start)
    
    % we seem to need to flip the dimids to get the same effect as the snctools
    % nc_addvar
    
    dimids = fliplr(dimids);
    
    ndimsv = length(dimids);
    clear dimsize
    for kd = 1:ndimsv
        [dimname, dimlength] = netcdf.inqDim(ncid, dimids(kd));
        dimsize(kd) = dimlength;
    end
    
    count = dimsize(:)'-start;
    
end

% the snctools version seems to retrieve every element if there is start but no count.
%
% I couldn't see anywhere where mexec calls nc_varget with start but no
% count, so the above difference should not matter.

start = fliplr(start);
count = fliplr(count);
stride = fliplr(stride);

if isempty(start)
    vardata = netcdf.getVar(ncid, varid );
elseif isempty(count)
    fprintf(2,'\n%s\n','Warning, nc_varget has been called with start but no count');
    fprintf(2,'%s\n','The bahaviour of this version is different than the behaviour of the snctools version');
    fprintf(2,'%s\n\n','Suggest the code be rewritten to state exactly what ''count'' should be');
    error('error in nc_varget');
    % if you reinstate the line of code below you will get precisely one data
    % value, at location given by 'start'
    vardata = netcdf.getVar(ncid, varid, start );
elseif isempty(stride)
    vardata = netcdf.getVar(ncid, varid, start, count );
else
    vardata = netcdf.getVar(ncid, varid, start, count, stride);
end



if length(dimids) == 1
    vardata = vardata(:);  % techsas files have one dimension which is time; snctools nc_varget makes this a column vector
else
    vardata = vardata'; % this is necessary to mimic the action of the old nc_varget;
    %     the above line will only work on 2-D vars, ie 1xN, Mx1, MxN.
    %     mexec is not presently set up to handle more than 2-D vars.
    %     mexec files have at least three dimension parameters: n_unity, nrows1, ncols1.
    %     mexec variables are always 2-D. MxN 1xN or Mx1.
end

% now handle _FillValue

switch ( xtype )
    case { 6 } % 6 is double
        scalefactor = 1;
        addoffset = 0;
        % The _FillValue is is in the normalisation of the
        % file value of the variable, not the real world value.
        % So the variable is tested against _FillValue, and then scaled, and then
        % offset. This convention agrees with the matlab ncread command.
        try
            fillvalue = netcdf.getAtt(ncid, varid, '_FillValue');
            vardata(vardata == fillvalue) = NaN;
        catch
            % If there is no _FillValue defined, take no action
        end
        
        try
            scalefactor = netcdf.getAtt(ncid, varid, 'scale_factor');
            if scalefactor ~= 1; vardata = vardata*scalefactor; end
        catch
        end
        
        try
            addoffset = netcdf.getAtt(ncid, varid, 'add_offset');
            if addoffset ~= 0; vardata = vardata + addoffset; end
        catch
        end
        
        
    otherwise
end


netcdf.close(ncid);

return
