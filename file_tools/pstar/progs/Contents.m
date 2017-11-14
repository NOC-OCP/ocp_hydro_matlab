% Selection of programs to manipulate pstar binary files in matlab
% 
% plisth  : load a pstar file header and echo it to the screen
% pload   : load a pstar file; fixes variable names that would be illegal in matlab. (calls plisth).
% pst2nc  : copy contents of pstar file to netcdf file (calls pload).
% nclisth : list the header of a pstar to netcdf file made by pst2nc
%
