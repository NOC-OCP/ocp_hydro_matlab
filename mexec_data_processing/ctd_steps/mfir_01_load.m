function mfir_01_load(stn)
% mfir_01: read in .bl file and create fir file
%
% Use: mfir_01        and then respond with station number, or for station 16
%      stn = 16; mfir_01;

m_common

% input file names
opt1 = 'ctd_proc'; opt2 = 'nisk_infiles'; run(MEXEC_G.opt_cruise)
opt1 = 'setup'; opt2 = 'pfiles'; run(MEXEC_G.opt_cruise)
if ~exist(infiles.ctd_nisk,'file')
    fprintf(2,'Niskin bottle file for cast %03d not found; try sync again and enter to continue\n',stn); 
    pause
    if ~exist(infiles.ctd_nisk,'file')
        warning('no file %s; skipping',infiles.ctd_nisk)
        return
    end
end
if MEXEC_G.quiet<=1; fprintf(1,['reading in .bl file to ' dataname '.nc\n'],stn_string); end

%read firing position and scan number when fired 
[pos, scn] = msbe_niskins_load(infiles.ctd_nisk);
comment = ['input data from ' infiles.ctd_nisk];
%in case cast was stitched together from multiple files by offsetting scan
opt1 = 'ctd_proc'; opt2 = 'ctd_raw_extra'; run(MEXEC_G.opt_cruise)
for no = 1:length(append_stn_strings)
    if isnan(append_scan_offsets(no))
        warning('not applying NaN offset to .bl scan number for %s',stn_string)
    else
        infile= replace(infiles.ctd_nisk,stn_string,append_stn_strings{no});
        if exist(infile,'file')
            %load and append
            [p, s] = msbe_niskins_load(infile);
            comment = [comment ' and ' infile];
            pos = [pos; p]; scn = [scn; s+append_scan_offsets(no)];
        end
    end
end

%add (from defaults) corresponding information like bottle S/N, bottle flag
opt1 = 'ctd_proc'; opt2 = 'nisk_numbers'; run(MEXEC_G.opt_cruise)
niskin_number = niskin_number(:);
niskin_pos = niskin_pos(:);
[~,ia,ib] = intersect(pos,niskin_pos);
position = niskin_pos;
scan = NaN+position;
scan(ib) = scn(ia);
niskin_flag = 9+zeros(size(scan)); %default flag 9 means not closed
niskin_flag(ib) = 2; %if bottle closed, defaults to 2
m = isfinite(scan);
scan = scan(m);
position = position(m);
niskin = niskin_number(m);
niskin_flag = niskin_flag(m);
clear m ia ib
%niskin flags will be changed later, in constructing appended sample file

%save
timestring = ['[' sprintf('%d %d %d %d %d %d',MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN) ']'];
MEXEC_A.MARGS_IN = {
    pfiles.ctd_nisk
    'scan'
    'position'
    'niskin'
    'niskin_flag'
    ' '
    ' '
    '1'
    sprintf('fir_%s_%s',MEXEC_G.mcruise,stn_string)
    '/'
    '2'
    MEXEC_G.PLATFORM_TYPE
    MEXEC_G.PLATFORM_IDENTIFIER
    MEXEC_G.PLATFORM_NUMBER
    '/'
    '4'
    timestring
    '/'
    '7'
    '-1'
    comment
    '/'
    '/'
    '8'
    'scan'
    '/'
    'number'
    'position'
    '/'
    'on.rosette'
    'niskin'
    '/'
    'number'
    'niskin_flag'
    '/'
    'woce_4.8'
    '-1'
    '-1'
    };
msave
mfixperms(otfile)

