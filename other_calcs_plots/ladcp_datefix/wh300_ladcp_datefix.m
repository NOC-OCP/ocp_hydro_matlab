% bak on jc191 9 Feb 2020
% The downlooker WH300 has some stations where the date was set one day
% early. Simple program to read the files, add one to the day number, and
% write out. Based on some other fixing programs from earlier cruises.
% A directory 'gfix' was found on bak's macbook. These programs used to be
% carried round in the mexec scripts directory but seem to have dropped out
% of the set.
%
%


% first read a frame of data from a .000 file, to set up the header, fixed and
% variable leader arrays and prepare a skeleton data array.
%
% we build the structures H,F,V,D to contain
% H  header fields
% F  fixed leader fields
% V  variable leader fields
% D  data fields
%

stnstr = sprintf('%03d',stn);

fnin = ['/local/users/pstar/cruise/data/ladcp/rawdata/Master/data/JC191_' stnstr 'M.000'];
fnot = ['/local/users/pstar/cruise/data/ladcp/rawdata/Master/data/JC191_' stnstr 'M_date_fixed.000'];

[fidin,message] = fopen(fnin,'r','l');
fidot = fopen(fnot,'w','l');

if fidin == -1
  message = sprintf('%s: %s',fnin,message);
  disp('problem with input file ')
  disp(message)
  error('terminate LADCP processing')
end
disp([' loading raw file ',fnin])


%collect the first 6 bytes
h=fread(fidin,6,'uint8');
h = h(:)' %force to row vector

if(h(1)~=127 | h(2)~=127)
   disp('the file does not have the correct HDR ID - terminate processing')
   exit
end


H.ID=h(1:2);    %Header ID
H.NBy=h(3:4);   %Number of bytes in a frame, excluding the 2 byte checksum
H.spare = h(5); %spare
H.Ndt=h(6);     %Number of data types

H_n=H;
H_n.NBy=b2to1(H.NBy) %Convert number of bytes in a frame to decimal

% Now read the whole file and see how many bytes we have

status = fseek(fidin,0,'eof');
nframes = floor(ftell(fidin)/(H_n.NBy+ 2));   %expected number of frames; divide total bytes by frame length
disp(['Number of frames in file appears to be     ' num2str(nframes)]);

status = fseek(fidin,0,'bof');

% Now read a whole header file, and find the byte offsets for each data
% type


h=fread(fidin,(2*H.Ndt+6),'uint8');  %read the whole header
h = h(:)'; %force to row vector

H.off=h(7:(2*H_n.Ndt +6));
H_n.off = b2to1(H.off);
                      %H_n.off and offset0 are the offsets for data
                      %types. Data type 1 is the fixed leader; DT 2 is the
                      %variable leader. Data types 3 and following are
                      %expected to be velocity and other data
offset0=H_n.off;

n=((offset0(4)-offset0(3))-2)/(2*4);  %expected number of bins. This is the number of 
                                    %bytes forJC191_060M_bad_date.000 the first velocity variable, minus 2 for the
                                    %variable ID, divide by 4 beams and 2
                                    %bytes per bin.
disp(['Number of bins appears to be               ' num2str(n)]);

% now go back and start to scan the file

status=fseek(fidin,0,'bof');

for kl = 1:nframes
    frame=fread(fidin,H_n.NBy + 2,'uint8');
    
    frame = frame(:)';  %force to row vector
    
    frameh=frame(1:offset0(1)); % frame of header data
    framef=frame(offset0(1)+1:offset0(2));   %frame of fixed leader data
    framev=frame(offset0(2)+1:offset0(3));   %frame of variable leader data
    framed=frame(offset0(3)+1:H_n.NBy-2);   %frame of data
    
    % day number is byte 7 of the variable leader
    
    day = frame(offset0(2)+7);
    day1 = day+1;
    
    frameout = frame;
    frameout(offset0(2)+7) = day1;
    
    % now do the checksum
    %     csin1 = rem(sum(frame(1:end-2)),65536);
    %     csin2 = b2to1(frame(end-1:end));
    csot1 = rem(sum(frameout(1:end-2)),65536); % as 1 byte
    csot2 = b1to2(csot1);                      % as 2 bytes
    frameout(end-1:end) = csot2;
    
    
    fwrite(fidot,frameout,'uint8');
    
    
end

fclose(fidin);
fclose(fidot);




