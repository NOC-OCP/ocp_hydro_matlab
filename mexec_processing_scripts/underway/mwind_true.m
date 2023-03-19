function mwind_true(days)
% add smoothed nav to met wind to make true wind
% where directions are in the wind vector sense (direction to)
%
% acts on appended files; requires mnav_best to have been run first to
% generate bestnav_cruise_all.nc

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

opt1 = 'ship'; opt2 = 'ship_data_sys_names'; get_cropt
root_pos = fullfile(MEXEC_G.mexec_data_root,'nav');
root_wnd = fullfile(MEXEC_G.mexec_data_root,'met','wnd');
infilen = fullfile(root_pos, ['bestnav_' mcruise '.nc']);
wfiles = dir(fullfile(root_wnd,'*_all_raw.nc'));
if isempty(wfiles)
    warning('no wind files found')
    return
end

%nav data
[dn, hn] = mload(infilen, '/');

avmet = 30;
opt1 = 'uway_proc'; opt2 = 'avtime'; get_cropt
tave_period = round(avmet); tav2 = round(tave_period/2);

%loop through wind from different instruments
for no = 1:length(wfiles)
    infile = fullfile(root_wnd,wfiles(no).name);
    wpre = infile(1:end-11);
    infilew =[wpre '_all_raw.nc'];
    if ~exist(infilew,'file')
        infilew = infile;
    end
    otfile = [wpre '_true.nc'];

    clear dnew hnew

    %wind data
    [dw, hw] = mload(infilew, '/');
    
    %variable names
    ws = munderway_varname('rwindsvar',hw.fldnam,1,'s');
    wd = munderway_varname('rwinddvar',hw.fldnam,1,'s');
    if isempty(ws) || isempty(wd)
        if sum(strcmp('xcomponent',hw.fldnam)) && sum(strcmp('ycomponent',hw.fldnam))
            %calculate relative speed and direction (0 from fore, 90 from
            %stbd) from relative u and v*** are xcomponent etc from or
            %to?***
            if strcmp('m/s',hw.fldunt(strcmp('xcomponent',hw.fldnam)))
                sc = 1;
            elseif strcmp('cm/s',hw.fldunt(strcmp('xcomponent',hw.fldnam)))
                sc = 0.01;
            end
            uv = complex(dw.xcomponent*sc,dw.ycomponent*sc);
            ws = 'windspeed'; wd = 'winddirection';
            dw.(ws) = abs(uv); dw.(wd) = -90+(angle(uv)*180/pi);
            hw.fldnam = [hw.fldnam ws wd]; hw.fldunt = [hw.fldunt 'm/s' 'degrees'];
        else
            continue
        end
    end

    %nav times in time coordinate of (this) dw
    dn.timew = m_commontime(dn.time, hn, hw);
    %ship heading as a vector
    headvar = munderway_varname('headvar', hn.fldnam, 1, 's');
    [headav_e, headav_n] = uvsd(ones(size(dn.(headvar))), dn.(headvar), 'sduv');
    %interpolate to wind file times
    headav_e = interp1(dn.timew, headav_e, dw.time);
    headav_n = interp1(dn.timew, headav_n, dw.time);
    %back to ship heading
    [~, merged_heading] = uvsd(headav_e, headav_n, 'uvsd');

    %add to relative wind direction to get wind direction in degrees_to earth
    %coordinates
    relwind_direarth = mcrange(180+(dw.(wd)+merged_heading), 0, 360);
    %vector wind relative to ship (in earth coordinates)
    [relwind_e, relwind_n] = uvsd(dw.(ws), relwind_direarth,'sduv');

    %ship velocity
    [shipv_e, shipv_n] = uvsd(dn.smg, dn.cmg, 'sduv');
    %interpolate to wind file times
    shipv_e = interp1(dn.timew, shipv_e, dw.time);
    shipv_n = interp1(dn.timew, shipv_n, dw.time);

    %vector wind over earth
    dw.truwind_e = relwind_e + shipv_e;
    dw.truwind_n = relwind_n + shipv_n;

    hw.fldnam = [hw.fldnam 'truwind_e' 'truwind_n'];
    hw.fldunt = [hw.fldunt 'm/s eastward' 'm/s northward'];
    hw.comment = [hw.comment sprintf('\n truwind calculated using average nav and heading data from %s along with %s',infilen,infilew)];

    %average variables other than speed and direction
    excl = {ws wd};
    [excl,~,iie] = intersect(excl,hw.fldnam);
    hw.fldnam(iie) = []; hw.fldunt(iie) = [];
    dw = rmfield(dw,excl);
    tg = (floor(min(dw.time)/86400)*86400 - tav2):tave_period:(ceil(max(dw.time)/86400)*86400+1);
    if ~isempty(days)
        yd = floor(tg/86400)+1;
        tg = tg(ismember(yd,days));
        m = dw.time>=tg(1)-tave_period & dw.time<=tg(end)+tave_period;
        dw = struct2table(dw);
        dw = table2struct(dw(m,:),'ToScalar',true);
    end
    clear opts
    opts.ignore_nan = 1;
    opts.grid_extrap = [1 1];
    opts.postfill = 30;
    opts.bin_partial = 0;
    dg = grid_profile(dw, 'time', tg, 'medbin', opts);
    dg.time = .5*(tg(1:end-1)+tg(2:end))';
    hw.comment = [hw.comment '\n averaged to by median over bins of width ' num2str(tave_period)];

    %recalculate wind speed and direction from averaged vectors
    [dg.truwind_spd, dg.truwind_dir] = uvsd(dg.truwind_e, dg.truwind_n, 'uvsd');
    hw.fldnam = [hw.fldnam 'truwind_spd']; hw.fldunt = [hw.fldunt 'm/s'];
    hw.fldnam = [hw.fldnam 'truwind_dir']; hw.fldunt = [hw.fldunt 'degrees N of E'];

    %save
    [~,~,ib] = intersect(fieldnames(dg),hw.fldnam,'stable');
    hw.fldnam = hw.fldnam(ib); hw.fldunt = hw.fldunt(ib);
    hw.comment = [hw.comment sprintf('\n truwind averaged over %d seconds',tave_period)];
    if exist(m_add_nc(otfile),'file')
        mfsave(otfile, dg, hw, '-merge', 'time');
    else
        mfsave(otfile, dg, hw);
    end

end
