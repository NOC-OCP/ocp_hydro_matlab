function save_sbefile(outfile,data,header)
% SAVE_SBEFILE is a script to save ascii data files in the same
% format as created by the SBE data processing (v7.18) program.
%
% save_sbefile(outfile,data,header)
%
%   outfile - the output file (only XXX.cnv and XXX.ros are
%       allowed so far)
%   data - the data in a matrix
%   header - a string matrix containing the full header.  a line is
%       appended to the bottom of the header to indicate this file
%       as the origin.
%

% ZB Szuts, 04.11.2009 on di344

if nargin~=3
  error('three input arguments are required')
else
  filetype = outfile(end-2:end);
  if ~any(strmatch(filetype,{'ros','cnv'}))
    error(['this function has not yet been tested for file type: ' ...
           filetype])
  end
end


fid = fopen(outfile,'w');

if fid==-1
  error(['the file cannot be opened: ' outfile])
end


for i = 1:size(header,1)
  fprintf(fid,'%s\n',deblank(header(i,:)));
end

switch filetype
 case 'ros'
  % an example of the desired output format is:
  %     162484          1   6770.125   5513.729     2.4610     2.4592  33.195363  33.196460    -0.0018   0.001097      10.74       0.00          1  0.000e+00

  fformat = ['%11d%11d%11.3f%11.3f%11.4f%11.4f%11.6f%11.6f'...
             '%11.4f%11.6f%11.2f%11.2f%11d%11.3e\n'];

 case 'cnv'     
  % an example of the desired output format is:
  %          1          0      0.000     -0.064    23.8774    24.1547   0.024430   0.661123     0.2773   0.636693      12.99       0.00          0 0.0000e+00
  %          2          0      0.042     -0.011    23.8774    24.1550   0.024400   0.662669     0.2776   0.638260      12.99       0.00          0 0.0000e+00
  %          3          0      0.083     -0.049    23.8778    24.1549   0.024442   0.666078     0.2771   0.641642      12.99       0.00          0 0.0000e+00
  
  fformat = ['%11d%11d%11.3f%11.3f%11.4f%11.4f%11.6f%11.6f'...
            '%11.4f%11.6f%11.2f%11.2f%11d%11.4e\n'];
  
end


for i = 1:size(data,1)
  fprintf(fid,fformat,data(i,:));
end


out = fclose(fid);
if out==-1
  error(['could not properly close the file: ' outfile])
end



%% .ros file variables
%
%# nquan = 14
%# nvalues = 241                     
%# units = specified
%# name 0 = scan: Scan Count
%# name 1 = pumps: Pump Status
%# name 2 = timeS: Time, Elapsed [seconds]
%# name 3 = prDM: Pressure, Digiquartz [db]
%# name 4 = t090C: Temperature [ITS-90, deg C]
%# name 5 = t190C: Temperature, 2 [ITS-90, deg C]
%# name 6 = c0mS/cm: Conductivity [mS/cm]
%# name 7 = c1mS/cm: Conductivity, 2 [mS/cm]
%# name 8 = T2-T190C: Temperature Difference, 2 - 1 [ITS-90, deg C]
%# name 9 = C2-C1mS/cm: Conductivity Difference, 2 - 1 [mS/cm]
%# name 10 = ptempC: Pressure Temperature [deg C]
%# name 11 = altM: Altimeter [m]
%# name 12 = nbf: Bottles Fired
%# name 13 = flag:  0.000e+00



%% .cnv file variables
%
%# nquan = 14
%# nvalues = 170974                      
%# units = specified
%# name 0 = scan: Scan Count
%# name 1 = pumps: Pump Status
%# name 2 = timeS: Time, Elapsed [seconds]
%# name 3 = prDM: Pressure, Digiquartz [db]
%# name 4 = t090C: Temperature [ITS-90, deg C]
%# name 5 = t190C: Temperature, 2 [ITS-90, deg C]
%# name 6 = c0mS/cm: Conductivity [mS/cm]
%# name 7 = c1mS/cm: Conductivity, 2 [mS/cm]
%# name 8 = T2-T190C: Temperature Difference, 2 - 1 [ITS-90, deg C]
%# name 9 = C2-C1mS/cm: Conductivity Difference, 2 - 1 [mS/cm]
%# name 10 = ptempC: Pressure Temperature [deg C]
%# name 11 = altM: Altimeter [m]
%# name 12 = nbf: Bottles Fired
%# name 13 = flag:  0.000e+00

