function mfir_01_load(stn)
% mfir_01: read in .bl file and create fir file
%
% Use: mfir_01        and then respond with station number, or for station 16
%      stn = 16; mfir_01;

m_common

% input file names
opt1 = 'ctd_proc'; opt2 = 'niskfilename'; get_cropt
if ~exist(blinfile,'file')
    fprintf(2,'.bl file for cast %03d not found; try sync again and enter to continue\n',stn);
    pause
    if ~exist(blinfile,'file')
        warning('no .bl file %s; skipping',blinfile)
        return
    end
end
if MEXEC_G.quiet<=1; fprintf(1,['reading in .bl file to ' dataname '.nc\n'],stn_string); end
opt1 = 'setup'; opt2 = 'procfiles'; get_cropt
f = sprintf(firfile.fir,stn_string);

%load scan and position for each rosette firing, from .bl or .btl file
if contains(blinfile,'.bl')
    cellall = mtextdload(blinfile,',',10); % load all text
    if size(cellall,2)<4
        warning('no bottles for cast %s; skipping',stn_string)
        return
    end
    nr = size(cellall,1);
    n = 1;
    pos = NaN; scn = NaN;
    for kline = 1:nr
        if ~isempty(cellall{kline,4})
            pos(n) = str2double(cellall{kline,2});
            scn(n) = str2double(cellall{kline,4});
            n = n+1;
        end
    end
elseif contains(blinfile,'.btl')
    n = 0; pos = []; scn = [];
    iis = nan; iip = nan;
    cont = true;
    fid = fopen(blinfile,'r');
    while cont
        s = fgets(fid);
        if ~ischar(s); break; elseif contains(s,'#') || contains(s,'*'); continue; end
        if isnan(iis) %haven't set this yet
            %first header line
            iis = strfind(s,'Scan');
            if isempty(iis); warning('no Scan in .btl file line %s; skipping', s); return; end
            iip = strfind(s,'Bottle');
            if isempty(iip); warning('no Bottle Position in .btl file line %s; skipping', s); return; end
            iis = iis-4:iis+4; %allow for a slight misalignment
            iip = iip-1:iip+3; %allow for a slight misalignment
        elseif contains(s,'avg') %or could test later for non-empty s(iip)
            %subsequently data lines
            if ~isempty(str2double(s(iip)))
                n = n+1; pos(n) = str2double(s(iip)); scn(n) = str2double(s(iis));
            end
        end
    end
    fclose(fid);
% elseif contains(blinfile,'.ros')
%     [d,h] = msbe_to_mstar(blinfile,'y','y');
%     pos = d.Position; h = d.scan;
else
    warning('bottle file type not recognised for cast %s; skipping',stn_string)
    return
end

pos = pos(:);
scn = scn(:);

%add (from defaults) corresponding information like bottle S/N, bottle flag
opt1 = 'ctd_proc'; opt2 = 'niskins'; get_cropt
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
opt1 = 'ctd_proc'; opt2 = 'botflags'; get_cropt %change flags here
%check that possible bad code in opt file hasn't added dimensions
if size(niskin)==size(niskin_flag)
else
    error('niskin and niskin_flag sizes do not match; check opt_%s',mcruise)
end

%in case cast was stitched together by offsetting scan
opt1 = 'ctd_proc'; opt2 = 'cast_split_comb'; get_cropt
blappend = 0;
if exist('comb_stns','var') && comb_stns(1)==stnlocal
    if isnan(comb_stns(3))
        warning('not applying NaN offset to .bl scan number for %s',stn_string)
    else
        scan = scan + comb_stns(3);
        stn = comb_stns(2); opt1 = 'setup'; opt2 = 'minit'; get_cropt
        f = sprintf(firfile.fir,stn_string);
        if exist(m_add_nc(f),'file')
            blappend = 1;
        end
    end
end

%write to .fir file
comment = ['input data from ' blinfile];
if blappend
    d.scan = scan; d.position = position;
    d.niskin = niskin; d.niskin_flag = niskin_flag;
    h = m_read_header(f);
    [h.fldnam,~,ib] = intersect(fieldnames(d),h.fldnam,'stable');
    h.fldunt = h.fldunt(ib); 
    if isfield(h,'fldserial')
        h.fldserial = h.fldserial(ib);
    else
        h.fldserial = repmat({'n/a'},length(h.fldnam),1);
    end
    h = rmfield(h,{'alrlim','uprlim','absent','num_absent','dimrows','dimcols','dimsset'});
    h.comment = [h.comment '\n' comment];
    mfsave(f, d, h, '-merge', 'scan')

else

    timestring = ['[' sprintf('%d %d %d %d %d %d',MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN) ']'];
    MEXEC_A.MARGS_IN = {
        f
        'scan'
        'position'
        'niskin'
        'niskin_flag'
        ' '
        ' '
        '1'
        sprintf(firfile.dataname,stn_string)
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
    %--------------------------------
end
