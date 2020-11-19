function [H_n F_n V_n D_n] = read_raw_frame(rawfile)

%read a frame of data from a .000 file, to set up the header, fixed and
%variable leader arrays and prepare a skeleton data array.

%we build the structures H,F,V,D to contain
% H  header fields
% F  fixed leader fields
% V  variable leader fields
% D  data fields

%add suffix _n when 2-byte inputs are conmverted to 'double' numbers in
%matlab

%the frame is unpacked using the frame definition for a WH300 in LADCP mode with a 555
%byte frame (ie 553+2 checksum).

%BAK at NOC; 8 Feb 2006. Based on prvious code by AJS.


%rawfile='c020_02.000';
%rawfile = 'example_2frames';

[fidraw,message] = fopen(rawfile,'r','l');

if fidraw == -1
  message = sprintf('%s: %s',rawfile,message);
  disp('problem with down looking RDI file ')
  disp(message)
  error('terminate LADCP processing')
end
disp([' loading raw file ',rawfile])


%collect the first 6 bytes
h=fread(fidraw,6,'uint8');
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


status = fseek(fidraw,0,'eof');
m = floor(ftell(fidraw)/(H_n.NBy+ 2));   %expected number of frames; divide total bytes by frame length
disp(['Number of frames in file appears to be     ' num2str(m)]);

status = fseek(fidraw,0,'bof');
h=fread(fidraw,(2*H.Ndt+6),'uint8');  %read the whole header
h = h(:)'; %force to row vector

H.off=h(7:(2*H_n.Ndt +6));
H_n.off = b2to1(H.off);
                      %H_n.off and offset0 are the offsets for data
                      %types. Data type 1 is the fixed leader; DT 2 is the
                      %variable leader. Data types 3 and following are
                      %expected to be velocity and other data
offset0=H_n.off;

n=((offset0(4)-offset0(3))-2)/(2*4);  %expected number of bins. This is the number of 
                                    %bytes for the first velocity variable, minus 2 for the
                                    %variable ID, divide by 4 beams and 2
                                    %bytes per bin.
disp(['Number of bins appears to be               ' num2str(n)]);

status=fseek(fidraw,0,'bof');

%read the first frame
frame0=fread(fidraw,H_n.NBy + 2,'uint8');  
F_ID_test=fread(fidraw,4,'uint8'); %read the next 4 bytes, which should start the next frame
disp(' ')
disp(' ')
disp(' ')
disp(['First 4 bytes of next frame are ' num2str(F_ID_test(:)')]); 
disp(' ')

frame0 = frame0(:)';  %force to row vector

framef=frame0(offset0(1)+1:offset0(2));   %frame of fixed leader data
framev=frame0(offset0(2)+1:offset0(3));   %frame of variable leader data
framed=frame0(offset0(3)+1:H_n.NBy-2);   %frame of data

% F.ID=framef(1:2);  %Fixed leader ID should be 00 00h
% F.to=framef(3:8);  %Firmware and hardware configuration flags
% F.Bm=framef(9);    %Number of beams
% F.WN=framef(10);   %Number of water track bins
% F.WP=framef(11:12); %Number of pings per ensemble
% F.WS=framef(13:14); %Bin length in cm
% F.WF=framef(15:16); %Blank after transmit
% F.WM=framef(17);    %Signal processing mode
% F.WC=framef(18);    %Correlation threshold
% F.cr=framef(19);    %Number of code repetitions
% F.WG=framef(20);    %Min prcent good
% F.WE=framef(21:22); %Error velocity threshold in mm/s
% F.TP=framef(23:25); %Fields set by TP command  minutes; seconds; hundredths
% F.EX=framef(26);    %co-ordinate transformation
% F.EA=framef(27:28); %value set for EA
% F.EB=framef(29:30); %value set for EB
% F.EZ=framef(31);    %value set for EZ
% F.SA=framef(32);    %Sensors available
% F.B1=framef(33:34); %Distance to middle of first bin; 
%                        %If the Pulse length matches the bin size, B1 should be Blank + Binsize
% F.XM=framef(35:36); %Pulse length
% F.WL=framef(37:38); %start and end bin for reference layer averaging
% F.WA=framef(39);    %threshold value for false target
% F.spare=framef(40); %spare, contains the CX command setting
% F.LD=framef(41:42); %Transmit lag distance
% F.cpu = framef(43:50); %board serial number
% if length(framef) > 50
%     disp(' ')
%     disp(['Number of fixed leader bytes not parsed was ' num2str(length(framef)-50)])
%     F.rest = framef(51:length(framef)); %catch any unread bytes
% end

% F_n=F;
% 
% F_n.WP=b2to1(F.WP); %Number of pings per ensemble
% F_n.WS=b2to1(F.WS); %Bin length in cm
% F_n.WF=b2to1(F.WF); %Blank after transmit
% F_n.WE=b2to1(F.WE); %Error velocity threshold in mm/s
% F_n.EA=0.01*b2to1(F.EA,1);  %range is -179.99 to 180.00
% F_n.EB=0.01*b2to1(F.EB,1);  %range is -179.99 to 180.00
% F_n.B1=b2to1(F.B1);
% %note by BAK 6 Feb 2006: there is no conversion of F.XM, which would have been
% %logical to include.
% F_n.LD=b2to1(F.LD);
% 



V.ID=framev(1:2);     %Variable leader ID  should be 80 00h
V.EN=framev(3:4);     %sequential ensemble number
V.time=framev(5:11);  %Time  year,month,day,hour,minute,second,hundredths
V.E=framev(12);       %ensemble MSB, increments when V.EN rolls over.
% V.BIT=framev(13:14);  %BIT result
V.EC=framev(15:16);   %speed of sound
V.ED=framev(17:18);   %depth of xducer
V.EH=framev(19:20);   %heading 0 to 359.99
V.EP=framev(21:22);   %pitch -20.00 to +20.00
V.ER=framev(23:24);   %roll -20.00 to +20.00
V.ES=framev(25:26);   %salinity
V.ET=framev(27:28);   %temperature
V.MPT=framev(29:31);  %minimum pre-ping wait time in this ensemble minutes,seconds,hundredths
V.STD=framev(32:34);  %std dev of heading and tilt angles
V.ADC=framev(35:42);  %analog to digital fields
if length(framev) > 42
    disp(['Number of variable leader bytes not parsed was ' num2str(length(framev)-42)])
    disp(' ')
    V.rest=framev(43:length(framev));
end

V_n=V;

V_n.EN=b2to1(V.EN);
V_n.EC=b2to1(V.EC);
V_n.ED=b2to1(V.ED);
V_n.EH=0.01*b2to1(V.EH);
V_n.EP=0.01*b2to1(V.EP,1);
V_n.ER=0.01*b2to1(V.ER,1);
V_n.ES=b2to1(V.ES);
V_n.ET=0.01*b2to1(V.ET,1);
F_n = []; D_n = [];
return
%build data frame; this assumes structure is 
% vel; corr; echo; pcg; other. This code should be rewritten to detect data type
% from data ID bytes.

D.vel_id = frame0(offset0(3)+1:offset0(3)+2);
D.vel_data = frame0(offset0(3)+3:offset0(4));
D.cm_id = frame0(offset0(4)+1:offset0(4)+2);
D.cm_data = frame0(offset0(4)+3:offset0(5));
D.ei_id = frame0(offset0(5)+1:offset0(5)+2);
D.ei_data = frame0(offset0(5)+3:offset0(6));
D.pc_id = frame0(offset0(6)+1:offset0(6)+2);
D.pc_data = frame0(offset0(6)+3:offset0(7));
D.rest = frame0(offset0(7)+1:H_n.NBy-2);
D.reserved = frame0(H_n.NBy-1:H_n.NBy);

D_n = D;
D_n.vel_id = b2to1(D.vel_id);
D_n.vel_data = b2to1(D.vel_data,1);
D_n.cm_id = b2to1(D.cm_id);
D_n.ei_id = b2to1(D.ei_id);
D_n.pc_id = b2to1(D.pc_id);


fclose(fidraw);
