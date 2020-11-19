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

gyro = mtload('gyro_s');
gtime =  datenum([1899 12 30 0 0 0])+gyro.time;
ghead = gyro.heading;


for kseq = maxnumseq
%     root = ['/local/users/pstar/cruise/data/vmadcp/di382_os' inst '/rawdata' blocknum];
%     root = ['/local/users/pstar/cruise/data/vmadcp/di346_os' inst '/rawdata' blocknum];
    root = ['/Users/bak/desktop/gfix/rawdata' blocknum ];
    root2 = ['/Users/bak/desktop/gfix/rawdata' blocknum '_fixhead'];

    if exist(root2,'dir') ~= 7
        unix(['mkdir ' root2]);
    end

    fn = ['OS' inst '_di346' blocknum '_' sprintf('%06d',kseq) '.ENX'];
    rawfile = [root '/' fn];
    otfile = [root2 '/' fn];

    [fidraw,message] = fopen(rawfile,'r','l');
    fidout = fopen(otfile,'w','l');

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
    ensnum = hdgin;
    % read the times all at once, so only need a single interp

    numdt = H_n.Ndt; % number of data types; eg on jc069:
    % %     H_n =
    % %        ID: [127 127]
    % %       NBy: 1492
    % %     spare: 0
    % %       Ndt: 9
    % %       off: [24 84 144 626 868 1110 1352 1386 1412]
    data_id = nan+ones(numdt,2);
    % read a frame to find where in the frame we find the Binary nav data
    % that we want to scan
    inframe = fread(fidraw,nperframe,'uint8');
    status=fseek(fidraw,0,'bof');
    bno = nan; bvlo = nan;
    for kdtloop = 1:numdt
        data_id(kdtloop,:) = inframe(H_n.off(kdtloop)+[1:2]); % first two bytes of each data type identify that data type
        if data_id(kdtloop,1) == 0 & data_id(kdtloop,2) == 32; % we have found the data we want
            bin_nav_offset = H_n.off(kdtloop); % offset for data type, eg 1412
            bno = bin_nav_offset;
        end
        if data_id(kdtloop,1) == 128 & data_id(kdtloop,2) == 0; % we have found binary variable leader data
            bvl_offset = H_n.off(kdtloop); % offset for data type, eg 84
            bvlo = bvl_offset;
        end
    end

    if isnan(bno)
        fprintf(2,'%s\n', 'Binary nav data identifier not found')
        return
    end
    if isnan(bvlo)
        fprintf(2,'%s\n', 'Binary variable leader data identifier not found')
        return
    end

    for kframes = 1:nframes
        inframe = fread(fidraw,nperframe,'uint8');
        ensnum(kframes) = b2to1(inframe((bvlo + [3:4]))); % bak jc069 ensemble number
        time = inframe(bvlo+[5:11]); % pc clock time
        off_pc_m_utc = b4to1(inframe(bno+[11:14]),1)/1000; % use dummy arg may be negative
        pc_date = datenum([2000+time(1) time(2) time(3) time(4) time(5) time(6)+time(7)/100]);
        pc_date_corrected = pc_date-off_pc_m_utc/86400;
        pcoff(kframes) = off_pc_m_utc;
        pctimesraw(kframes) = pc_date;
        pctimes(kframes) = pc_date_corrected;
        utcyyyy = b2to1(inframe(bno+[5:6]));
        utcmo = inframe(bno+4);
        utcdd = inframe(bno+3);
        utcfraclast(kframes) = b4to1(inframe(bno+[23:26]))/86400/10000; % fraction of a day since midnight
        utcfracfirst(kframes) = b4to1(inframe(bno+[7:10]))/86400/10000; % fraction of a day since midnight
        utcorg(kframes) = datenum([utcyyyy utcmo utcdd]) ;
        utclast(kframes) = utcorg(kframes) + utcfraclast(kframes);
        latlast(kframes) = b4to1(inframe(bno+[27:30]))/scl;
        lonlast(kframes) = b4to1(inframe(bno+[31:34]))/scl;
    end

    newheadings = interp1(gtime,ghead,pctimes);
    status=fseek(fidraw,0,'bof');

    for kframes = 1:nframes
        inframe = fread(fidraw,nperframe,'uint8');
        otframe = inframe(1:end-2);
%         hdgin(kframes) = b2to1(inframe(103:104))/100;
        hdgin(kframes) = b2to1(inframe(bvlo+[19:20]))/100;

        newhdg = newheadings(kframes);

%         otframe(103:104) = b1to2(100*newhdg); % write new heading in
        otframe(bvlo+[19:20]) = b1to2(100*newhdg); % write new heading in

        % checksum
        chk = rem(sum(otframe),65536);
        chk2 = b1to2(chk);
        otframe = [otframe(:)' chk2(:)'];

        fwrite(fidout,otframe,'uint8');
    end
end
fclose(fidraw);
fclose(fidout);
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
zz.ensnum = ensnum;
zz.bvlo = bvlo;
zz.bno = bno;

zz.nperframe = nperframe;

zz.newheadings = newheadings;
keyboard
return

