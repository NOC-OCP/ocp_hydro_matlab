%median average bathymetry, then add data from one file to another by
%interpolation for comparison and editing

if exist(filesbot,'file') & exist(filembot,'file')
    
    docstr = ['merge swath_depth and single-beam depth onto each other''s files'];
    mdocshow(mfilename, docstr);

    [ds,hs] = mloadq(filesbot,'/');
    ds.timec = ds.time/3600/24+datenum(hs.data_time_origin);
    [dm,hm] = mloadq(filembot,'/');
    dm.timec = dm.time/3600/24+datenum(hm.data_time_origin);
    
    %interpolate single-beam depth onto swath times and vice versa
    dm.depth = interp1(ds.timec, ds.depth, dm.timec);
    ds.swath_depth = interp1(dm.timec, dm.swath_depth, ds.timec);
    dm = rmfield(dm, 'timec'); ds = rmfield(ds, 'timec');
    
    %save to single-beam file
    hnew.fldnam = [hs.fldnam 'swath_depth']; hnew.fldunt = [hs.fldunt 'm'];
    hnew.comment = ['Swath depth from ' shortnames{iim} ' interpolated onto single-beam times as swath_depth'];
    mfsave(filesbot, ds, hnew, '-addvars');
    %and to swath file
    hnew.fldnam = [hm.fldnam 'depth']; hnew.fldunt = [hm.fldunt 'm'];
    hnew.comment = ['Single-beam depth from ' shortnames{iis} ' interpolated onto swath times as depth'];
    mfsave(filembot, dm, hnew, '-addvars');
    
end
