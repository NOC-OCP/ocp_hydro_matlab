function [firstm lastm numdc] = msgetfiletimes(fname,tonly)
% function [firstm lastm numdc] = msgetfiletimes(fname)
%
% get the time of the first and last data cycle in a scs file, and
% return the times as matlab datenums; return a third argument which is the
% number of data cycles in the scs file.
%
% first draft BAK JC032
%
% mstar scs (mt) routine; requires mexec to be set up
%
% The scs files are searched for in a directory MEXEC_G.uway_root defined in
% the mexec setup. At sea, this will typically be a data area exported from a
% ship's computer and cross-mounted on the mexec processing machine
%
% 8 Sep 2009: SCS version of original scs script, for JR195
% The searched directory is MEXEC_G.uway_root, which for example can be
% /data/cruise/jcr/20090310/scs_copy/Compress
% The var names and units are taken from ascii file
% seatex-gga.TPL
% for example.
%
% 2009-09-22 fixed at noc to work with either standard (comma delimited) or 
% sed-revised (space delimited) ACO files

m_common
if nargin == 1; tonly = ' '; end

fullfn = [MEXEC_G.uway_sed '/' fname];

if strncmp(tonly,'f',1) % faster option; don't count numdc in every file
    fid = fopen(fullfn,'r'); % open file read only
    fseek(fid,0,1); % move to end of file
    numbytes_file = ftell(fid); % check the number of bytes at this instant
    fseek(fid,0,-1); % rewind
    line_1 = fgets(fid);
    numbytes_line = length(line_1);
    fseek(fid,numbytes_file-2*numbytes_line,-1); % move two lines before end of file
    line_end = fgets(fid); % read to the next end of line
    line_end = fgets(fid); % read next line to avoid possible problem of partial lines near end of file
    num_newlines = -1;
    numlines = num_newlines;
    numdc = num_newlines;
    numtest = numbytes_file;
    fclose(fid);
else
    fid = fopen(fullfn,'r'); % open file read only
    fseek(fid,0,1); % move to end of file
    numbytes_file = ftell(fid); % check the number of bytes at this instant
    fseek(fid,0,-1); % rewind
    num_newlines = 0;
    block = 100000; % set a block size. Read the file this many bytes at a time
    % to avoid reading the entire file into memory.
    done = 0;
    while done < numbytes_file
        numbytes_remain = numbytes_file - done;
        num_to_read = min(block,numbytes_remain);
        [all ok] = fread(fid,block,'uchar=>int8'); % read each byte
        num_newlines = num_newlines + length(find(all==10)); % count the number of 'newline' characters
        done = done+ok;
    end
    fseek(fid,0,-1); % rewind
    line_1 = fgets(fid);
    numbytes_line = length(line_1);
    fseek(fid,numbytes_file-2*numbytes_line,-1); % move two lines before end of file
    line_end = fgets(fid); % read to the next end of line
    line_end = fgets(fid); % read next line to avoid possible problem of partial lines near end of file
    numlines = num_newlines;
    numdc = num_newlines;
    numtest = numdc;
    fclose(fid);
end

if numtest > 0 % expect properly formatted lines have 4 timestamp vars
    firstline = line_1;
    lastline = line_end;

    comindex = strfind(firstline,',');
    if isempty(comindex)
        % space delimited
        xx = sscanf(firstline,'%f ',4);
        yyyy1 = xx(1); ddd1 = xx(3); fracd1 = xx(4);
        
        xx = sscanf(lastline,'%f ',4);
        yyyy2 = xx(1); ddd2 = xx(3); fracd2 = xx(4);
    else
        % comma delimited
        yyyy1 = firstline(1:comindex(1)-1);
        ddd1 = firstline(comindex(2)+1:comindex(3)-1);
        fracd1 = firstline(comindex(3)+1:comindex(4)-1);

        comindex = strfind(lastline,',');
        yyyy2 = lastline(1:comindex(1)-1);
        ddd2 = lastline(comindex(2)+1:comindex(3)-1);
        fracd2 = lastline(comindex(3)+1:comindex(4)-1);

        yyyy1 = str2double(yyyy1);
        ddd1 = str2double(ddd1);
        fracd1 = str2double(fracd1);

        yyyy2 = str2double(yyyy2);
        ddd2 = str2double(ddd2);
        fracd2 = str2double(fracd2);
    end

    firstm = datenum(yyyy1,1,1) + (ddd1-1) + fracd1; %scs reports day number, 1 Jan = day 1.
    lastm = datenum(yyyy2,1,1) + (ddd2-1) + fracd2;

else
    firstm = 0;
    lastm = 0;
    numdc = 0;
end

return

