% get combined file of nav data from best source (specified in m_setup)
%
% Use: mnav_best       and then respond with day number, or for day 20
%      day = 20; mnav_best;

mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

%start with the original data in the same directory
opt1 = 'ship'; opt2 = 'datasys_best'; get_cropt
abbrev = default_navstream;
headpre = default_hedstream;
if strcmp(MEXEC_G.MSCRIPT_CRUISE_STRING(1:2),'di')
    headpre = 'gys';
end

root_pos = mgetdir(abbrev);
root_head = fullfile(MEXEC_G.mexec_data_root,'nav',[headpre(4:end) '_heading']);

prefixp = [abbrev '_' mcruise '_'];
prefixh = [headpre '_' mcruise '_'];
prefixo = ['bst_' mcruise '_'];

infile = fullfile(root_pos, [prefixp '01']);
avfile = fullfile(root_pos, [prefixp 'ave']);
spdfile = fullfile(root_pos, [prefixp 'spd']);
infileh = fullfile(root_head, [prefixh '01']);
avfileh = fullfile(root_head, [prefixh 'ave']);
bstfile = fullfile(root_pos, [prefixo '01']);

if MEXEC_G.quiet<=1
    fprintf(1,'averaging 1-Hz navigation stream from %s01.nc to 30 s in %save.nc and calculate speed, course, distrun for %sspd.nc\n',prefixp,prefixp,prefixp);
    fprintf(1,'averaging 1-Hz navigation stream from %s01.nc to 30 s in %save.nc, merge onto 30 s averaged speed from %sspd.nc for %s01.nc\n',prefixh,prefixh,prefixp,prefixo);
end


opt1 = 'uway_proc'; opt2 = 'avtime'; get_cropt
tave_period = round(avnav); % seconds
tav2 = round(tave_period/2);


%%%%% create smoothed nav file from 1-Hz positions %%%%%

[d, h] = mloadq(infile,'/');
timvar = 'time'; %dnum?
d = m_commontime(d, timvar, h, MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN);
h.data_time_origin = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN;
tg = (floor(min(d.time)/86400)*86400 - tav2):tave_period:(ceil(max(d.time)/86400)*86400+1);
clear opts
opts.ignore_nan = 1;
opts.grid_extrap = [0 0];
opts.postfill = 30;
dg = grid_profile(d, 'time', tg, 'medbin', opts);
h.comment = [h.comment '\n median over bins of width ' num2str(tave_period)];
mfsave(avfile, dg, h);


%%%%% calculate speed, course, distrun from the 30-s averages %%%%%

latvar = munderway_varname('latvar', h.fldnam, 1 ,'s');
lonvar = munderway_varname('lonvar', h.fldnam, 1, 's');
[dist, ang] = sw_dist(dg.(latvar), dg.(lonvar), 'km');
delt = diff(dg.time);
speed = 1000*dist./delt;
ve = zeros(size(dg.(latvar))); vn = ve;
ve(2:end) = speed.*cos(ang*pi/180);
vn(2:end) = speed.*sin(ang*pi/180);
[dg.smg, dg.cmg] = uvsd(ve, vn, 'uvsd');
dist(isnan(dist)) = 0;
dg.distrun = cumsum(dist);
h.fldnam = [h.fldnam 'smg' 'cmg' 'distrun'];
h.fldunt = [h.fldunt 'm/s' 'degrees' 'km'];
h.comment = [h. comment '\n speed, course over ground, and distance run calculated'];


%%%%% create 30-second heading file from 1-Hz positions %%%%%

[dh, hh] = mloadq(infileh, '/');
%first compute dummy easting and northing and grid them
headvar = munderway_varname('headvar', hh.fldnam, 1, 's');
[dh.dum_e, dh.dum_n] = uvsd(ones(size(dh.(headvar))), dh.(headvar), 'sduv');
dh = rmfield(dh,headvar);
dh = m_commontime(dh, timvar, hh, MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN);
hh.data_time_origin = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN;
tg = (floor(min(d.time)/86400)*86400 - tav2):tave_period:1e10;
clear opts
opts.ignore_nan = 1;
opts.grid_extrap = [0 0];
dgh = grid_profile(dh, 'time', tg, 'medbin', opts);
%convert back to heading
[~, dgh.(headvar)] = uvsd(dgh.dum_e, dgh.dum_n, 'uvsd');
dgh = rmfield(dgh, {'dum_e'; 'dum_n'});
hh.comment = [hh.comment '\n median over bins of width ' num2str(tave_period)];
mfsave(avfileh, dgh, hh);


%%%%% merge vector-averaged heading onto average speed, course %%%%%

dg.(headvar) = interp1(dgh.time, dgh.(headvar), dg.time);
h.fldnam = [h.fldnam headvar];
h.fldunt = [h.fldunt 'degrees']; %***reference/coord sys?
h.comment = [h.comment '\n vector-averaged heading interpolated onto position times'];
mfsave(bstfile, dg, h);

%--------------------------------
if strncmp(MEXEC_G.MSCRIPT_CRUISE_STRING,'di',2) % old discovery techsas with ashtech present
    wkfile = ['wk_' mfilename '_' datestr(now,30)];
    root_ash = mgetdir('M_ASH'); infile4 = fullfile(root_ash, ['ash_' mcruise '_01']);
    calcvar = 'heading_av a_minus_g';
    calcstr = ['y = mcrange(x1+x2,0,360);']; % prepare to add a_minus_g on discovery

    %--------------------------------
    % merge in the a-minus-g heading correction from the ashtech file into the
    % bestnav file
    MEXEC_A.MARGS_IN = {
        wkfile
        bstfile
        '/'
        'time'
        infile4
        'time'
        'a_minus_g'
        'k'
        };
    mmerge

    %calculate the corrected heading <heading_av_corrected> using the a-minus-g
    %heading correction. mcrange is used to ensure that this heading variable
    %is always between 0 and 360 degrees.
    % bak on jr281: on cook and jcr, there correction is zero because heading
    % comes from an absolute source instead of the gyro.
    MEXEC_A.MARGS_IN = {
        wkfile
        bstfile
        '/'
        calcvar
        calcstr
        'heading_av_corrected'
        'degrees'
        ' '
        };
    mcalc
    delete(m_add_nc(wkfile))

end
