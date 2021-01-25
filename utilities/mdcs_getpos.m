%script called by mdcs_04, code broken out because mdcs_04 repeats this 
%code for cast start, bot, and end times
%
%requires dvar and isdpos be set
%if isdpos, requires dcsfileot, infile1, infile2
%if ~isdpos, requires wkfile1, wkfile2 (new), and infile1 [see mdcs_04]

if ~isdpos %if no dcs pos file yet or it does not have this variable in it yet, merge from bst nav file
   
   MEXEC_A.MARGS_IN = {
      wkfile2
      wkfile1
      '/'
      ['time_' dvar]
      infile1
      'time'
      [latname ' ' lonname]
      'f'
      };
      mmerge
   MEXEC_A.MARGS_IN = {
      wkfile2
      'y'
      '8'
      latname
      ['lat_' dvar]
      'degrees'
      lonname
      ['lon_' dvar]
      'degrees'
      '-1'
      '-1'
      };
   mheadr

else %use mcalib to modify dcs pos fields (if necessary)

   [din hin] = mload(dcsfileot, ['time_' dvar], ['lat_' dvar], ['lon_' dvar], ' ');
   if isnan(getfield(din, ['lat_' dvar])) | getfield(din, ['lat_' dvar])<-900

      tim = getfield(din, ['time_' dvar])/86400 + datenum(hin.data_time_origin);

      %try bst nav file again, in case it has more times now
      [dn, hn] = mload(infile1, 'time', latname, lonname, ' ');
      lat = interp1(dn.time/86400+datenum(hn.data_time_origin), getfield(dn, latname), tim);
      lon = interp1(dn.time/86400+datenum(hn.data_time_origin), getfield(dn, lonname), tim);
    
      if isnan(lat) %still NaN; try raw file
         [dr, hr] = mload(infile2, '/');
         if isfield(dr, 'latitude')
            lat = interp1(dr.time/86400+datenum(hr.data_time_origin), dr.latitude, tim);
            lon = interp1(dr.time/86400+datenum(hr.data_time_origin), dr.longitude, tim);
         else
            lat = hr.latitude;
            lon = hr.longitude;
         end
      end
      
      MEXEC_A.MARGS_IN = {
         dcsfileot
         'y'
         ['lat_' dvar]
         sprintf('y = %12.6f;', lat)
         ' '
         ' '
         ['lon_' dvar]
         sprintf('y = %12.6f;', lon)
         ' '
         ' '
         ' '
         };
      mcalib
   end

end
