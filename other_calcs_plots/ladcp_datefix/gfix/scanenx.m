function  zz = fixens(inst,blocknum,maxnumseq)
% function  fixens(inst,blocknum,maxnumseq)
%
%
% % maxnumseq = 4; % highest number of sequential ENS file, eg 4 for 0000 to 0004
% % 
% % inst = '75'; % '75' or '150' used in file names
% % % inst = '150'; % '75' or '150' used in file names
% % 
% % blocknum = '035'; % incrementing daily block number, used in dir names


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

% gyro = mload('/local/users/pstar/di346/data/nav/gyros/gyr_di346_01','/');
% gtime = datenum([2010 1 1 0 0 0])+gyro.time/86400;
% ghead = gyro.head_gyr;

m_setup

% gyro = mtload('gyro_s');
% gtime =  datenum([1899 12 30 0 0 0])+gyro.time;
% ghead = gyro.heading;
% 
% load g12all;
% ntime = datenum([1899 12 30 0 0 0])+g12all.time;
% nlat = g12all.lat;
% nlon = g12all.long;

% for kseq =  0:maxnumseq
for kseq =  maxnumseq
    root = ['/local/users/pstar/cruise/data/vmadcp/di346_os' inst '/rawdata' blocknum];
    root2 = [root '_fixnav'];

%     if exist(root2,'dir') ~= 7
%         unix(['mkdir ' root2]);
%     end

%     fn = ['OS' inst '_di346' blocknum '_' sprintf('%06d',kseq) '.ENS'];
    fn = ['OS' inst '_di346' blocknum '_' sprintf('%06d',kseq) '.ENS'];
    rawfile = [root '/' fn];
    otfile = [root2 '/' fn];

    [fidraw,message] = fopen(rawfile,'r','l');

    if fidraw == -1
        message = sprintf('%s: %s',rawfile,message);
        disp('problem with down looking RDI file ')
        disp(message)
        zz = [];
        return
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

    nperframe = H_n.NBy+ 2;
    nframes = floor(ftell(fidraw)/(H_n.NBy+ 2));   %expected number of frames; divide total bytes by frame length
    disp(['Number of frames in file appears to be     ' num2str(nframes)]);

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

    scl = 2^31/180; % scaling for Binary Angular Measure (BAM) lat and lon

    pctimes = nan+ones(nframes,1);
    pctimesraw = pctimes; pcoff = pctimes;
    hdgin = pctimes; utclast = hdgin; latlast = hdgin; lonlast = hdgin; 
    utcorg = hdgin; utcfraclast = hdgin; utcfracfirst = hdgin;
    % read the times all at once, so only need a single interp
    for kframes = 1:nframes
        inframe = fread(fidraw,nperframe,'uint8');
        time = inframe(89:95); % pc clock time
        off_pc_m_utc = b4to1(inframe(1523:1526),1)/1000; % use dummy arg may be negative
        pc_date = datenum([2000+time(1) time(2:6)']);
        pc_date_corrected = pc_date-off_pc_m_utc/86400;
        pcoff(kframes) = off_pc_m_utc;
        pctimesraw(kframes) = pc_date;
        pctimes(kframes) = pc_date_corrected;
        utcyyyy = b2to1(inframe(1517:1518));
        utcmo = inframe(1516);
        utcdd = inframe(1515);
        utcfraclast(kframes) = b4to1(inframe(1535:1538))/86400/10000; % fraction of a day since midnight
        utcfracfirst(kframes) = b4to1(inframe(1519:1522))/86400/10000; % fraction of a day since midnight
        utcorg(kframes) = datenum([utcyyyy utcmo utcdd]) ;
        utclast(kframes) = utcorg(kframes) + utcfraclast(kframes);
        latlast(kframes) = b4to1(inframe(1539:1542))/scl;
        lonlast(kframes) = b4to1(inframe(1543:1546))/scl;
    end
end
zz.hdgin = hdgin;
% zz.newlats = newlatslast;
% zz.newlons = newlonslast;
zz.oldlats = latlast;
zz.oldlons = lonlast;
zz.pctimes = pctimes;
zz.pctimesraw = pctimesraw;
zz.utclast = utclast;
zz.utcfraclast = utcfraclast;
zz.utcfracfirst = utcfracfirst;
zz.utcorg = utcorg;
zz.pcoff = pcoff;
fclose(fidraw);
return

