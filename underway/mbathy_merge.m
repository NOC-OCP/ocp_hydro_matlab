%add data from one file to another by
%interpolation for comparison and editing

if ism && iss
    
    docstr = ['merge swath_depth and single-beam depth onto each other''s files'];
    mdocshow(mfilename, docstr);

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
        hs.comment = [hs.comment 'Swath depth from ' shortnames{iim} ' interpolated onto single-beam times as swath_depth'];
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
