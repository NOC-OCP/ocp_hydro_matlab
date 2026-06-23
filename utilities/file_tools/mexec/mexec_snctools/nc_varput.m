function nc_varput(ncfile , varname , vardata , varargin )
%
% version of nc_varput for mexec to replace snctools version
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
% If subsetting is used, ie start, count, stride, then the size of vardata
% must exactly match the number of elements implied by the subsetting.
% There is no checking that this matches, the program will just crash if it
% things don't match.
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
% So the variable is offset, scaled and then tested against _FillValue. 
% This convention agrees with the matlab ncwrite command.
%
% The old snctools description was
%
% % NC_VARPUT:  Writes data into a netCDF file.
% %
% % NC_VARPUT(NCFILE,VARNAME,DATA) writes the matlab variable DATA to
% % the variable VARNAME in the netCDF file NCFILE.  The main requirement
% % here is that DATA have the same dimensions as the netCDF variable.
% %
% % NC_VARPUT(NCFILE,VARNAME,DATA,START,COUNT) writes DATA contiguously,
% % starting at the zero-based index START and with extents given by
% % COUNT.
% %
% % NC_VARPUT(NCFILE,VARNAME,DATA,START,COUNT,STRIDE) writes DATA
% % starting at the zero-based index START with extents given by
% % COUNT, but this time with strides given by STRIDE.  If STRIDE is not
% % given, then it is assumes that all data is contiguous.
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

ncid = netcdf.open(ncfile,'WRITE');

varid = netcdf.inqVarID(ncid,varname);

% If there is start but no count, then calculate count to retrieve from
% start to the end of each dimension

[varname,xtype,dimids,natts] = netcdf.inqVar(ncid, varid);

if isempty(count) & ~isempty(start)
    
    % calculate the size of count to ensure writing from start to the end
    % of each dimension
    
    % we seem to need to flip the dimids to get the same effect as the snctools
    % nc_varput
    
    dimids = fliplr(dimids);
    
    ndimsv = length(dimids);
    clear dimsize
    for kd = 1:ndimsv
        [dimname, dimlength] = netcdf.inqDim(ncid, dimids(kd));
        dimsize(kd) = dimlength;
    end
    
    count = dimsize(:)'-start;
    
end

% I couldn't see anywhere where mexec calls nc_varget with start but no
% count, so the above difference should not matter.

start = fliplr(start);
count = fliplr(count);
stride = fliplr(stride);


% now handle _FillValue

switch ( xtype )
    case { 6 } % 6 is double
        scalefactor = 1;
        addoffset = 0;
        % The _FillValue is is in the normalisation of the
        % file value of the variable, not the real world value.
        % So the variable is offset, scaled and then NaNs are changed to _FillValue.
        % This convention agrees with the matlab ncwrite command.
        try
            addoffset = netcdf.getAtt(ncid, varid, 'add_offset');
            if addoffset ~= 0; vardata = vardata - addoffset; end
        catch
        end
        
        try
            scalefactor = netcdf.getAtt(ncid, varid, 'scale_factor');
            if scalefactor ~= 1; vardata = vardata/scalefactor; end
        catch
        end
        
        try
            fillvalue = netcdf.getAtt(ncid, varid, '_FillValue');
            vardata(isnan(vardata)) = fillvalue;
        catch
            % If there is no _FillValue defined, take no action
        end
        
        
        
        
    otherwise
        
end

% Now transpose; mexec files are always 2-D

if length(dimids) == 2
    vardata = vardata'; % this is necessary to mimic the action of the old nc_varget;
    %     the above line will only work on 2-D vars, ie 1xN, Mx1, MxN.
    %     mexec is not presently set up to handle more than 2-D vars.
    %     mexec files have at least three dimension parameters: n_unity, nrows1, ncols1.
    %     mexec variables are always 2-D. MxN 1xN or Mx1.
end

if isempty(start)
    netcdf.putVar(ncid, varid, vardata );
elseif isempty(count)
    fprintf(2,'\n%s\n','Warning, nc_varget has been called with start but no count');
    fprintf(2,'%s\n','The bahaviour of this version is different than the behaviour of the snctools version');
    fprintf(2,'%s\n\n','Suggest the code be rewritten to state exactly what ''count'' should be');
    error('error in nc_varget');
    % I don't know what happens in putvar if there is start but not count
    % getvar reads only one point.
    netcdf.putVar(ncid, varid, start, vardata );
elseif isempty(stride) % assume it is 1
    %     k1 = start(1)+ (1:count(1));
    %     k2 = start(2)+ (1:count(2));
    netcdf.putVar(ncid, varid, start, count, vardata );
else
    %     k1 = start(1)+1+stride(1)*(0:count(1)-1);
    %     k2 = start(2)+1+stride(2)*(0:count(2)-1);
    netcdf.putVar(ncid, varid, start, count, stride, vardata);
end


netcdf.close(ncid);

return