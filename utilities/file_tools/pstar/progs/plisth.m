function h = plisth(filename)

% plisth: load a pstar file header and echo it to the screen
%use:
% h = plisth(filename)
%where filename is the name of a pstar file.
%
% BAK at SOC 31 March 2005

if nargin < 1
    filename = input('Type name of pstar file to load :\n','s');
end

if exist(filename,'file') ~= 2
    disp(['Filename ''' filename ''' not found']);
    return
end

magvar=1344950870;
magdat=1344950852;
magvr8=1344951864;
magdr8=1344947256;

r5 = 1365;
r8 = 1024;

fid = fopen(filename,'r','b');

h.datnam = char(fread(fid,8,'*uchar'))';
h.vers = char(fread(fid,2,'*uchar'))';
h.opwrit = char(fread(fid,1,'*uchar'))';
h.rawdat = char(fread(fid,1,'*uchar'))';
h.pipefl = char(fread(fid,1,'*uchar'))';
h.archiv = char(fread(fid,1,'*uchar'))';
h.magic = fread(fid,1,'uint32');

lb = 0;
if h.magic == magvar | h.magic == magdat 
    lb = r5;
elseif h.magic == magvr8 | h.magic == magdr8
    lb = r8;
else
    disp('Problem with magic number - quitting')
    return
end

storvar = '   ';
if h.magic == magvar | h.magic == magvr8
    storvar = 'var';
else
    storvar = 'dcs';
end

blank6 = char(fread(fid,6,'*uchar'))';
h.prefil = char(fread(fid,8,'*uchar'))';
h.postfl = char(fread(fid,8,'*uchar'))';
h.noflds = fread(fid,1,'uint32');
h.norecs = fread(fid,1,'uint32');
h.nrows = fread(fid,1,'uint32');
h.nplane = fread(fid,1,'uint32');
h.icent = fread(fid,1,'uint32');
h.iymd = fread(fid,1,'uint32');
h.ihms = fread(fid,1,'uint32');
h.platnam = char(fread(fid,12,'*uchar'))';
h.platyp = char(fread(fid,8,'*uchar'))';
h.pltnum = char(fread(fid,8,'*uchar'))';
h.instmt = char(fread(fid,12,'*uchar'))';
blank4 = char(fread(fid,4,'*uchar'))';
h.recint = char(fread(fid,16,'*uchar'))';

if lb == r5 %read them as real*5 and unpack; skip the status byte at read time. Then skip 2 blanks.
    alat6 = char(fread(fid,5,'5*uchar',1))';
    blank2 = char(fread(fid,2,'*uchar'))';
    alat = punpack(alat6);
    along6 = char(fread(fid,5,'5*uchar',1))';    
    blank2 = char(fread(fid,2,'*uchar'))';
%     blank2 = char(fread(fid,2,'5*uchar',1))';
    % long standing bug in above line fixed by BAK on 26 Aug 2008.
    % In the above line, there is an incorrect (not required) skip as the fourth argument of the call to fread.
    % In older versions of matlab, the fact that 2 bytes were read to 5*uchar meant that the skip was
    % never executed. In a newer version running on solaris workstation 'rapid', the skip was executed once
    % even though the 5*uchar was not filled. This meant an extra byte was read out of the pstar header,
    % and all following data were corrupt, especially the filenames. This error was obviously apparent,
    % far too obvious to inadvertantly not notice. So there is no danger of loaded files 'aprearing to be OK but actually bad'
    along = punpack(along6);
    dpthi6 = char(fread(fid,5,'5*uchar',1))';
    blank2 = char(fread(fid,2,'*uchar'))';
    dpthi = punpack(dpthi6);
    dpthw6 = char(fread(fid,5,'5*uchar',1))';
    blank2 = char(fread(fid,2,'*uchar'))';
    dpthw = punpack(dpthw6);
else %lb == r8; read them as real*8
    alat = fread(fid,1,'double');
    along = fread(fid,1,'double');
    dpthi = fread(fid,1,'double');
    dpthw = fread(fid,1,'double');
end
h.alat = alat;
h.along = along;
h.dpthi = dpthi;
h.dpthw = dpthw;

for k = 1:12
    h.coment(k,1:72) = char(fread(fid,72,'*uchar'))';
end
ifldxx = 128;
for k = 1:ifldxx
    h.fldnam{k} = char(fread(fid,8,'*uchar'))';
end

for k = 1:ifldxx
    h.fldunt{k} = char(fread(fid,8,'*uchar'))';
end

if lb == r5
    %128*5 = 640; We need 640 bytes in fives, which gives 128 5-byte elements.
    %we skip 1 status byte with each element, so we read 128*(5+1) = 768 bytes.
    %So skip 256 more, so we advance 1024 bytes for each array.
    alrlim_array = char(fread(fid,ifldxx*5,'5*uchar',1))';
    fseek(fid,256,0);
    uprlim_array = char(fread(fid,ifldxx*5,'5*uchar',1))';
    fseek(fid,256,0);
    absent_array = char(fread(fid,ifldxx*5,'5*uchar',1))';
    fseek(fid,256,0);
    alrlim = punpack(alrlim_array(1:ifldxx*5));
    uprlim = punpack(uprlim_array(1:ifldxx*5));
    absent = punpack(absent_array(1:ifldxx*5));
else %lb == r8
    alrlim = fread(fid,128,'double');
    uprlim = fread(fid,128,'double');
    absent = fread(fid,128,'double');
end

h.alrlim = alrlim(:)';
h.uprlim = uprlim(:)';
h.absent = absent(:)';

blank = char(fread(fid,2046,'*uchar'))';
h.site = char(fread(fid,2,'*uchar'))';

h

latd = fix(alat);
latm = abs(60*(alat-latd));
lond = fix(along);
lonm = abs(60*(along-lond));
disp(['Data Name :  ' h.datnam ' ' h.site ' ' h.vers]);
disp(['Platform :   ' h.platyp ' ' h.platnam ' ' h.pltnum]);
disp(['Instrument :' h.instmt '   dpthi ' sprintf('%8.2f',h.dpthi) '   dpthw ' sprintf('%8.2f',h.dpthw)]);
disp(['Fields :    ' sprintf('%3d',h.noflds) '     Data Cycles ' sprintf('%8d',h.norecs) '     Rows ' sprintf('%4d',h.nrows) '   Planes ' sprintf('%4d',h.nplane)]);
disp(['Position (lat lon) : '  sprintf('%10.5f',alat) '  ' sprintf('%10.5f',along)]);
disp(['Position (lat lon) : '  sprintf('%4d %06.3f',latd,latm) ' ' sprintf('%4d %06.3f',lond,lonm)]);
disp(['Time origin : ' sprintf('%02d',h.icent/100) '/' sprintf('%06d',h.iymd) '/' sprintf('%06d',h.ihms)]);
disp('************************************************************************');
for k = 1:h.noflds
    disp(['*' sprintf('%3d',k) '*' h.fldnam{k} '*' h.fldunt{k} '* ' sprintf('%15.3f',h.alrlim(k)) ' * ' sprintf('%15.3f',h.uprlim(k)) ' * ' sprintf('%10.3f',h.absent(k)) ' *']);
end
disp('************************************************************************');
for k = 1:12
    thiscoment = h.coment(k,:);
    blank72 = '                                                                        ';
    if strcmp(blank72,thiscoment) == 0
        disp(thiscoment);
    end
end


fclose(fid);

return
