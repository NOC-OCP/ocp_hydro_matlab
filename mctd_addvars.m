%in case variables listed (by SBE name) in cell array newvars were missed
%out of varlists/ctd_renamelist.csv the first time through, adds them to
%_raw and (if it exists) _raw_cleaned
%
%follow by running
% mctd_rawedit (if new variables might be edited either automatically or
% manually) and
% ctd_all_postedit (in any case, to propagate through to _24hz, _psal,
% _2db, _2up, and fir and sam files)
%
%mostly this is to avoid overwriting other variables that have already been
%edited in _raw_cleaned, so if you haven't edited a given cast you could
%just as well run ctd_all_part1 and ctd_all_part2 instead of mctd_addvars
%and ctd_all_postedit
%
%this doesn't work with redoctm
%
%everything in newvars will be overwritten in _raw and _raw_cleaned, so if
%it includes existing variables that have been edited, you will need to
%redo the edits (or check newvars and don't include these variable names)

minit;
mdocshow(mfilename, ['adds variables in newvars to _raw and _raw_cleaned']);

scriptname = mfilename; oopt = 'newvars'; get_cropt

if ~isempty(newvars)
    
    dataname = ['ctd_' mcruise '_' stn_string];
    root_cnv = mgetdir('M_CTD_CNV');
    root_ctd = mgetdir('M_CTD');
    redoctm = 0; oopt = 'cnvfilename'; scriptname = 'mctd_01'; get_cropt
    infile = fullfile(root_cnv, infile);
    if ~exist(infile,'file')
        warning(['file ' infile ' not found; make sure it''s there (and not gzipped) and return to try again, or ctrl-c to quit'])
        pause
    end
    otfile = fullfile(root_ctd, [dataname '_raw']);
    
    wkfile = fullfile(root_ctd, ['wk_mctd_addvars_' datestr(now,30) '.nc']);
    MEXEC_A.MARGS_IN = {
        infile
        'y'
        'y'
        wkfile
        };
    msbe_to_mstar;
    
    root_templates = mgetdir('M_TEMPLATES');
    renamefile = fullfile(root_templates, 'ctd_renamelist.csv');
    dsv = dataset('File', renamefile, 'Delimiter', ',');
    if length(unique(dsv.sbename))<length(dsv.sbename)
        error(['There is a duplicate name in the list of variables to rename; use ctdvars_replace rather than ctdvars_add in opt_' mcruise]);
    end
    [~, iiv, ~] = intersect(dsv.sbename, newvars);
    dsv = dsv(iiv,:);
    [varnames, junk, iiv] = mvars_in_file(dsv.sbename, wkfile);
    dsv = dsv(iiv,:);
    varnames_units = {};
    for vno = 1:length(dsv)
        varnames_units = [varnames_units; dsv.sbename{vno}; dsv.varname{vno}; dsv.varunit{vno}];
    end
    
    [d,h] = mload(wkfile,'/');
    dnew.scan = d.scan;
    for no = 1:length(newvars)
        dnew.(newvars{no}) = d.(newvars{no});
    end
    [hnew.fldnam,ii,~] = intersect(h.fldnam,fieldnames(dnew)); 
    hnew.fldunt = h.fldunt(ii);
    unix(['chmod 644 ' m_add_nc(otfile)])
    mfsave(m_add_nc(otfile), dnew, hnew, '-addvars');
    unix(['chmod 444 ' m_add_nc(otfile)])
    otfile = [otfile '_cleaned.nc'];
    if exist(otfile, 'file')
        unix(['chmod 644 ' m_add_nc(otfile)])
        mfsave(otfile, dnew, hnew, '-addvars');
        unix(['chmod 644 ' m_add_nc(otfile)])
    end
    
    delete(m_add_nc(wkfile))
    
end
