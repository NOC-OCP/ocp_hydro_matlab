%edit bathymetry data (ideally by comparing two streams)
%then average each for _01 file

%load singlebeam if we have it
iss = 0;
[~,iis,~] = intersect(shortnames,{'sim' 'ea600' 'ea640' 'singleb'});
if ~isempty(iis)
    filesbin = fullfile(root_u, udirs{iis}, [shortnames{iis} '_' mcruise '_d' daystr '_edt.nc']);
    if exist(filesbin,'file')
        [ds,hs] = mload(filesbin,'/');
        ds.time = ds.time/86400+1;
        filesbot = fullfile(root_u, udirs{iis}, [shortnames{iis} '_' mcruise '_d' daystr '_edt_av.nc']);
        iss = 1;
    end
end

%load multibeam if we have it
ism = 0;
[~,iim,~] = intersect(shortnames,{'em120' 'em122' 'multib'});
if ~isempty(iim)
    filembin = fullfile(root_u, udirs{iim}, [shortnames{iim} '_' mcruise '_d' daystr '_edt.nc']);
    if exist(filembin,'file')
        [dm,hm] = mload(filembin,'/');
        dm.time = dm.time/86400+1;
        filembot = fullfile(root_u, udirs{iim}, [shortnames{iim} '_' mcruise '_d' daystr '_edt_av.nc']);
        ism = 1;
    end
end

if ~iss && ~ism
    return
end

% %get gridded bathy interpolated to track
% dn1 = datenum(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1),1,1)+str2num(daystr)-1;
% dn2 = dn1+1;
% switch MEXEC_G.Mshipdatasystem
%     case 'rvdas'
%         dnav = mrload(MEXEC_G.default_navstream,dn1,dn2);
%     case 'techsas'
%         dnav = mtload(MEXEC_G.default_navstream,dn1,dn2);
%     case 'scs'
%         dnav = msload(MEXEC_G.default_navstream,dn1,dn2);
%     otherwise
%         msg = ['choose ship navigation source and enter new case in msim_plot.m'];
%         fprintf(2,'\n\n%s\n\n\n',msg);
%         return
% end
% latvar = munderway_varname('latvar',fieldnames(dnav),1,'s');
% lonvar = munderway_varname('lonvar',fieldnames(dnav),1,'s');
% scriptname = 'bathy'; oopt = 'bathy_grid'; get_cropt
% if mean(dnav.(lonvar))<0 && hs.longitude>0; top.lon = top.lon-360; end
% iix = find(top.lon>=min(dnav.(lonvar))-1 & top.lon<=max(dnav.(lonvar))+1); iiy = find(top.lat>=min(dnav.(latvar))-1 & top.lat<=max(dnav.(latvar))+1);
% ssdeps = -interp2(top.lon(iix), top.lat(iiy)', top.depth(iiy,iix), dnav.(lonvar)(1:dt:end), dnav.(latvar)(1:dt:end));

marker_s = 'o';
marker_m = '.';

figure(1); clf
%plot(dnav.time,ssdeps,'k'); hold on
if iss
    hls = plot(ds.time,ds.waterdepth,'b','marker',marker_s); hold on
end
if ism
    hlm = plot(dm.time,dm.waterdepth,'r','marker',marker_m);
end
grid

%add step to reapply previous edits***

%editing gui
done = 0;
bads = []; badm = [];
while ~done
    typ = input('are you editing singlebeam (blue: ''s'') or multibeam (red: ''m'') or neither (enter)?\n','s');
    if isempty(typ)
        done = 1; continue
    end
    if strcmp(typ,'s')
        delete(hls); hls = plot(ds.time,ds.waterdepth,'b.-'); hold on
        delete(hlm); hlm = plot(dm.time,dm.waterdepth,'r'); 
    elseif strcmp(typ,'m')
        delete(hls); hls = plot(ds.time,ds.waterdepth,'b'); hold on
        delete(hlm); hlm = plot(dm.time,dm.waterdepth,'r.-'); 
    end
    disp('select bottom left and top right corners of box around bad data');
    [x,y] = ginput(2);
    if strcmp(typ,'s') && ~isempty(x)
        bad = ds.time>=x(1) & ds.time<=x(2) & ds.waterdepth>=y(1) & ds.waterdepth<=y(2);
        if sum(bad)
            ds.waterdepth(bad) = NaN;
            delete(hls); hls = plot(ds.time,ds.waterdepth,'b','marker',marker_s); hold on
            if ism; delete(hlm); hlm = plot(dm.time,dm.waterdepth,'r','marker',marker_m); end
            bads = [bads; [x' y']];
        end
    elseif strcmp(typ,'m') && ~isempty(x)
        bad = dm.time>=x(1) & dm.time<=x(2) & dm.waterdepth>=y(1) & dm.waterdepth<=y(2);
        if sum(bad)
            dm.waterdepth(bad) = NaN;
            if iss; delete(hls); hls = plot(ds.time,ds.waterdepth,'b','marker',marker_s); hold on; end
            delete(hlm); hlm = plot(dm.time,dm.waterdepth,'r','marker',marker_m);
            badm = [badm; [x' y']];
        end
    else
        disp('must enter ''s'' or ''m''; try again');
        continue
    end
    cont = input('enter ''w'' to finish and write to file(s)\n, or zoom or pan then enter ''e'' to edit more points\n','s');
    if strcmp(cont,'w')
        done = 1;
    end
end


%save edited to file, also write edits to text file in case overwritten
if ~isempty(bads)
    ds.time = (ds.time-1)*86400;
    mfsave(filesbin,ds,hs);
    fid = fopen(fullfile(root_u,udirs{iis},['bathyed_' datestr(now,'yyyymmdd_HHMMSS') '_d' daystr]),'w');
    for no = 1:size(bads,1)
        fprintf(fid,'%f %f %f %f\n',bads(no,:));
    end
    fclose(fid);
end
if ~isempty(badm)
    dm.time = (dm.time-1)*86400;
    mfsave(filembin,dm,hm);
    fid = fopen(fullfile(root_u,udirs{iim},['bathyed_' datestr(now,'yyyymmdd_HHMMSS') '_d' daystr]),'w');
    for no = 1:size(badm,1)
        fprintf(fid,'%f %f %f %f\n',badm(no,:));
    end
    fclose(fid);
end

%average each one
if (iss || ism) && MEXEC_G.quiet<=1; fprintf(1,'5-minute median averaging bathymetry streams'); end
if iss
    wkfile = 'wkfile_bathyav1.nc';
    MEXEC_A.MARGS_IN = {filesbin; wkfile; '/'; 'time'; '-150,1e10,300'; '/'};
    mavmed
    movefile(wkfile, filesbot);
end
clear filesbin
if ism
    wkfile = 'wkfile_bathyav2.nc';
    MEXEC_A.MARGS_IN = {filembin; wkfile; '/'; 'time'; '-150,1e10,300'; '/'};
    mavmed
    movefile(wkfile, filembot);
end
clear filesbot
