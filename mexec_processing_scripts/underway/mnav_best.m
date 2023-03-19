function mnav_best(days)
% combine nav and heading data from best sources (specified in m_setup)
% using vector easting, northing to interpolate
% works on days, or if days is empty on all days in input files

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

opt1 = 'ship'; opt2 = 'datasys_best'; get_cropt
root_pos = fullfile(MEXEC_G.mexec_data_root,'nav','pos');
root_hed = fullfile(MEXEC_G.mexec_data_root,'nav','hed');
if exist('default_attstream','var')
    doatt = 1;
    root_att = fullfile(MEXEC_G.mexec_data_root,'nav','att');
else
    doatt = 0;
end
infilen = fullfile(root_pos,[default_navstream '_' mcruise '_all_edt.nc']);
if ~exist(infilen,'file')
    infilen = fullfile(root_pos,[default_navstream '_' mcruise '_all_raw.nc']);
end
infileh = fullfile(root_hed,[default_hedstream '_' mcruise '_all_edt.nc']); %easting and northing only in edt file
if ~exist(m_add_nc(infilen),'file') || ~exist(m_add_nc(infileh),'file')
    error('at least one of best nav and heading stream %s and %s files not found',default_navstream,default_hedstream)
end
if doatt
    infilea = fullfile(root_att,[default_attstream '_' mcruise '_all_edt.nc']);
    if ~exist(infilea,'file')
        infilea = fullfile(root_att,[default_attstream '_' mcruise '_all_edt.nc']);
    end
end
if ~exist(infilea,'file')
    doatt = 0;
end
otfile = fullfile(MEXEC_G.mexec_data_root,'nav',['bestnav_' mcruise]);

if MEXEC_G.quiet<=1
    fprintf(1,'averaging 1-Hz navigation stream from %s to 30 s and calculate speed, course, distrun\n',default_navstream);
end

avnav = 30;
opt1 = 'uway_proc'; opt2 = 'avtime'; get_cropt
tave_period = round(avnav); % seconds
tav2 = round(tave_period/2);


%%%%% create smoothed nav file from 1-Hz positions %%%%%
[d, h] = mload(infilen,'/');
excvars = {'utctime'};
[h.fldnam,ii] = setdiff(h.fldnam,excvars,'stable');
if length(ii)<length(h.fldunt)
    h.fldunt = h.fldunt(ii); d = rmfield(d,excvars);
end
timvar = 'time'; 
timestring = ['seconds since ' datestr(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN,'yyyy-mm-dd HH:MM:SS')];
d.(timvar) = m_commontime(d, timvar, h, timestring);
opt1 = 'mstar'; get_cropt
if docf
    h.data_time_origin = [];
    h.fldunt{strcmp(timvar,h.fldnam)} = timestring;
else
    h.data_time_origin = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN;
end
tg = floor(min(d.time))-tav2:tave_period:ceil(max(d.time))+tav2;
if ~isempty(days)
    yd = floor(tg/86400)+1;
    tg = tg(ismember(yd,days));
    m = d.time>=tg(1)-tave_period & d.time<=tg(end)+tave_period;
    d = struct2table(d);
    d = table2struct(d(m,:),'ToScalar',true);
end
clear opts
opts.ignore_nan = 1;
opts.grid_extrap = [1 1];
opts.postfill = 30;
opts.bin_partial = 0;
dg = grid_profile(d, 'time', tg, 'medbin', opts);
dg.time = .5*(tg(1:end-1)+tg(2:end))';
h.comment = [h.comment '\n position median over bins of width ' num2str(tave_period)];
h.fldinst = repmat({default_navstream},size(h.fldnam));

%%%%% average attitude to same times (independently) and merge %%%%%
if doatt
    [da, ha] = mload(infilea,'/');
    dga = grid_profile(da, 'time', tg, 'medbin', opts);
    vars = setdiff(h.fldnam,'time');
    for vno = 1:length(vars)
        dg.(vars{vno}) = dga.(vars{vno});
        h.fldnam = [h.fldnam vars{vno}];
        h.fldunt = [h.fldunt ha.fldunt(strcmp(vars{vno},h.fldnam))];
        h.fldinst = [h.fldinst repmat({default_attstream},1,length(vars))];
    end
    h.comment = [h.comment '\n attitude from ' default_attstream ' median over bins of width ' num2str(tave_period)];
end

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
dg.distrun = [0; cumsum(dist)];
h.fldnam = [h.fldnam 'smg' 'cmg' 'distrun'];
h.fldunt = [h.fldunt 'm/s' 'degrees' 'km'];
h.fldinst = [h.fldinst repmat({default_navstream},1,3)];
h.comment = [h. comment '\n speed, course over ground, and distance run calculated'];


if MEXEC_G.quiet<=1
    fprintf(1,'averaging 1-Hz navigation stream from %s to 30 s, merge onto 30 s averaged speed, save in bestnav_%s_all.nc\n',default_hedstream,mcruise);
end

%%%%% create 30-second heading from 1-Hz data %%%%%
[dh, hh] = mload(infileh, '/');
excvars = {'utctime'};
[hh.fldnam,ii] = setdiff(hh.fldnam,excvars,'stable');
if length(ii)<length(hh.fldunt)
    hh.fldunt = hh.fldunt(ii); dh = rmfield(dh,excvars);
end
dh.(timvar) = m_commontime(dh, timvar, hh, timestring);
hh.data_time_origin = h.data_time_origin;
if docf
    hh.fldunt{strcmp(timvar,hh.fldnam)} = timestring;
end
%grid the dummy easting and northing
clear opts
opts.ignore_nan = 1;
opts.grid_extrap = [0 0];
dgh = grid_profile(dh, 'time', tg, 'medbin', opts);
dgh.time = .5*(tg(1:end-1)+tg(2:end))';
%convert back to heading
headvar = munderway_varname('headvar', hh.fldnam, 1, 's');
[~, dgh.(headvar)] = uvsd(dgh.dum_e, dgh.dum_n, 'uvsd');
h.comment = [h.comment '\n heading from vector median over bins of width ' num2str(tave_period)];


%%%%% merge vector-averaged heading onto average speed, course %%%%%
dg.(headvar) = interp1(dgh.(timvar), dgh.(headvar), dg.time);
h.fldnam = [h.fldnam headvar];
h.fldunt = [h.fldunt 'degrees']; %***reference/coord sys?
h.fldinst = [h.fldinst default_hedstream];
h.comment = [h.comment '\n vector-averaged heading interpolated onto position times'];


%%%%%% save %%%%%%
mfsave(otfile, dg, h, '-merge', 'time');
