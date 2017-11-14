function [data,header] = read_sbefile(infile)
% READ_SBEFILE is a script to read in ascii data files created by
% the SBE data processing (v7.18) program.
%
% [data,header] = read_sbefile(infile)
%
%   infile - the data input file (only XXX.cnv and XXX.ros have
%            been tested so far)
%   data - the data in a matrix
%   header - a string matrix containing the full header
%

% ZB Szuts, 04.11.2009 on di344

if nargin~=1
  error('one input argument is required')
else
  if ~exist(infile,'file')
    error(['the input file does not exist: ' infile])
  end
end



fid = fopen(infile);

if fid==-1
  error(['the file cannot be opened: ' infile])
end


header = [];
while 1
  zeile = deblank(fgetl(fid));

  if strmatch(zeile(1),{'*','#'})
    header = strvcat(header,zeile);
  
    % extract the data size
    if strfind(zeile,'nquan') % looking for, e.g. "# nquan = 14"
      i = strfind(zeile,'=');
      nquan = str2num(zeile(i+1:end));
    elseif strfind(zeile,'nvalues') % looking for, e.g. "# nvalues = 241"
      i = strfind(zeile,'=');
      nvalues = str2num(zeile(i+1:end));
    end

  else
    break
  end

end


data = repmat(nan,nvalues,nquan);
i=1;
while ~isequal(zeile,-1)
  data(i,:) = str2num(zeile);
  
  i = i+1;
  zeile = fgetl(fid);
  
end

out = fclose(fid);
if out==-1
  error(['could not properly close the file: ' infile])
end
