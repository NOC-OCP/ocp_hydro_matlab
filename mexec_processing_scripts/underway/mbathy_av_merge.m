%combine xducer depth and depth from xducer (if necessary)
%average
%and merge single- and multi-beam onto each other's files by interpolation
%for comparison and editing

%first calculate and average singlebeam
[~,iis,~] = intersect(shortnames,{'sim' 'ea600' 'ea640' 'singleb'});
if ~isempty(iis)
    filesbin = fullfile(root_u, udirs{iis}, [shortnames{iis} '_' mcruise '_d' daystr '_edt.nc']);
end
if isempty(iis) || ~exist(filesbin,'file')
    iist = find(strcmp(shortnames,'singleb_t'));
    if ~isempty(iist)
        filest = fullfile(root_u, udirs{iist}, [shortnames{iist} '_' mcruise '_d' daystr '_edt.nc']);
        if exist(filest,'file')
            if MEXEC_G.quiet<=1; fprintf(1,'%s\n', 'calculating single beam water depth from xducer depth and depth_below_xducer'); end
            [d,h] = mloadq(filest,'/');
            files = fullfile(root_u, udirs{iist}, ['singleb_' mcruise '_d' daystr '_edt.nc']);
            clear dnew hnew
            dnew.time = d.time;
            newname = 'depth'; %this is after mday_01_namesunits
            dnew.depth = d.waterdepth_below_transduce + d.transduceroffset;
            hnew.fldnam = {'time', 'depth'};
            hnew.fldunt = {'seconds', 'metres'};
            hnew.comment = [h.comment '\n created from ' filest];
            mfsave(files, dnew, hnew);
            filesbin = files;
            if isempty(iis)
                udirs = [udirs; udirs{iist}];
                shortnames = [shortnames; 'singleb'];
                streamnames = [streamnames; ['not_rvdas_but_calculated_from_' streamnames{iist}]];
                iis = length(udirs)-1;
            end
            udirs(iist,:) = [];
            shortnames(iist) = [];
            streamnames(iist) = [];
            if ~ismember(MEXEC_G.MDIRLIST(:,1),'singleb')
                MEXEC_G.MDIRLIST = [MEXEC_G.MDIRLIST; {'singleb'} udirs(end)];
            end
            iss = 1;
        else
            iss = 0;
        end
    else
        iss = 0;
    end
    clear iist
else
    iss = 1;
end
if iss
    filesbot = fullfile(root_u, udirs{iis}, [shortnames{iis} '_' mcruise '_d' daystr '_edt_av.nc']);
    if exist(filesbin,'file')
        wkfile = 'wkfile_bathyav1.nc';
        MEXEC_A.MARGS_IN = {filesbin; wkfile; '/'; 'time'; '-150,1e10,300'; '/'};
        mavmed
        movefile(wkfile, filesbot);
    end
end
clear filesbin

%next calculate and average multibeam
[~,iim,~] = intersect(shortnames,{'em120' 'em122' 'multib'});
if ~isempty(iim)
    filembin = fullfile(root_u, udirs{iim}, [shortnames{iim} '_' mcruise '_d' daystr '_edt.nc']);
end
if isempty(iim) || ~exist(filembin,'file')
    iimt = find(strcmp(shortnames,'multib_t'));
    if ~isempty(iimt)
        filemt = fullfile(root_u, udirs{iimt}, [shortnames{iimt} '_' mcruise '_d' daystr '_edt.nc']);
        if exist(filemt,'file')
            if MEXEC_G.quiet<=1; fprintf(1,'%s\n', 'calculating multi beam water depth from xducer depth and depth_below_xducer'); end
            [d,h] = mloadq(filemt,'/');
            filem = fullfile(root_u, udirs{iimt}, ['multib_' mcruise '_d' daystr '_edt.nc']);
            clear dnew hnew
            dnew.time = d.time;
            newname = 'swath_depth'; %this is after mday_01_namesunits stage
            dnew.(newname) = d.waterdepth_below_transduce + d.transduceroffset;
            hnew.fldnam = {'time', newname};
            hnew.fldunt = {'seconds', 'metres'};
            hnew.comment = [h.comment '\n created from ' filemt];
            mfsave(filem, dnew, hnew);
            filembin = filem;
            if isempty(iim)
                udirs = [udirs; udirs{iimt}];
                shortnames = [shortnames; 'multib'];
                streamnames = [streamnames; ['not_rvdas_but_calculated_from_' streamnames{iimt}]];
                iim = length(udirs)-1;
            end
            udirs(iimt,:) = [];
            shortnames(iimt) = [];
            streamnames(iimt) = [];
            if ~ismember(MEXEC_G.MDIRLIST(:,1),'multib')
                MEXEC_G.MDIRLIST = [MEXEC_G.MDIRLIST; {'multib'} udirs(end)];
            end
            ism = 1;
        else
            ism = 0;
        end
    else
        ism = 0;
    end
    clear iimt
else
    ism = 1;
end
if ism
    filembot = fullfile(root_u, udirs{iim}, [shortnames{iim} '_' mcruise '_d' daystr '_edt_av.nc']);
    if exist(filembin,'file')
        wkfile = 'wkfile_bathyav2.nc';
        MEXEC_A.MARGS_IN = {filembin; wkfile; '/'; 'time'; '-150,1e10,300'; '/'};
        mavmed
        movefile(wkfile, filembot);
    end
end
clear filembin

if (iss || ism) && MEXEC_G.quiet<=1; fprintf(1,'5-minute median averaging bathymetry streams'); end

%add data from one file to another by
%interpolation for comparison and editing

if iss && ism
        
    if MEXEC_G.quiet<=1; fprintf(1,'merging swath_depth and single-beam depth onto each other''s files'); end

    [ds,hs] = mloadq(filesbot,'/');
    ds.timec = ds.time/3600/24+datenum(hs.data_time_origin);
    [dm,hm] = mloadq(filembot,'/');
    dm.timec = dm.time/3600/24+datenum(hm.data_time_origin);
        
    %interpolate swath depth onto single-beam times, save to single-beam file
    clear dsn
    dsn.swath_depth = interp1(dm.timec, dm.swath_depth, ds.timec);
    clear hnew
    hnew.fldnam = {'swath_depth'}; hnew.fldunt = {'m'};
    if ~sum(strcmp('swath_depth', hs.fldnam))
        hs.comment = [hs.comment '\n Swath depth from ' shortnames{iim} ' interpolated onto single-beam times as swath_depth'];
    end
    mfsave(filesbot, dsn, hnew, '-addvars');
    
    %interpolate single-beam depth onto swath times, save to swath file
    clear dmn
    dmn.depth = interp1(ds.timec, ds.depth, dm.timec);
    clear hnew
    hnew.fldnam = {'depth'}; hnew.fldunt = {'m'};
    if ~sum(strcmp('depth', hm.fldnam))
        hnew.comment = ['Single-beam depth from ' shortnames{iis} ' interpolated onto swath times as depth'];
    end
    mfsave(filembot, dmn, hnew, '-addvars');

end

clear iss ism filembot filesbot iis iim