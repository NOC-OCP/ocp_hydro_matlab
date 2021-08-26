%in case variables listed (by SBE name) in cell array newvars were missed
%out of varlists/ctd_renamelist.csv the first time through, adds them to
%_raw and (if it exists) _raw_cleaned
%
%follow by running
% mctd_rawedit and ctd_all_postedit, or just continue through without new
% edits
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
%
%will also add to _24hz but will check if variables already exist (don't
%want to overwrite calibrated variables)

scriptname = 'castpars'; oopt = 'minit'; get_cropt
mdocshow(mfilename, ['adds variables in newvars to _raw and _raw_cleaned and _24hz']);

scriptname = mfilename; oopt = 'newvars'; get_cropt

if ~isempty(newvars)
    
    dataname = ['ctd_' mcruise '_' stn_string];
    root_cnv = mgetdir('M_CTD_CNV');
    root_ctd = mgetdir('M_CTD');
    redoctm = 0; oopt = 'cnvfilename'; scriptname = 'mctd_01'; get_cropt
    infile = fullfile(root_cnv, infile);
    if ~exist(infile,'file')
        warning(['file ' infile ' not found; make sure it''s there (and not gzipped) and return to try again, or ctrl-c to quit'])
        disp(['note mctd_addvars is not set up to handle _noctm files; in that case rerun starting from mctd_01'])
        pause
    end
    otfile = fullfile(root_ctd, [dataname '_raw']);
    
    %variables to rename
    root_templates = mgetdir('M_TEMPLATES');
    renamefile = fullfile(root_templates, 'ctd_renamelist.csv');
    dsv = dataset('File', renamefile, 'Delimiter', ',');
    if length(unique(dsv.sbename))<length(dsv.sbename)
        error(['There is a duplicate name in the list of variables to rename; use ctdvars_replace rather than ctdvars_add in opt_' mcruise]);
    end
    [~, iiv, ~] = intersect(dsv.sbename, newvars);
    dsv = dsv(iiv,:);

    %load from .cnv file
    disp('loading new variables from .cnv file')
    wkfile = fullfile(root_ctd, ['wk_mctd_addvars_' datestr(now,30) '.nc']);
    MEXEC_A.MARGS_IN = {
        infile
        'y'
        'y'
        wkfile
        };
    msbe_to_mstar(['scan' newvars]); %can take varargin, these could specify what to read/save

    %limit list of variables
    [varnames, junk, iiv] = mvars_in_file(dsv.sbename, wkfile);
    dsv = dsv(iiv,:);
    varnames_units = {};
    for vno = 1:length(dsv)
        varnames_units = [varnames_units; dsv.sbename{vno}; dsv.varname{vno}; dsv.varunit{vno}];
    end
    
    %write to _raw and _raw_cleaned
   disp('writing to _raw')
    [d,h] = mload(wkfile,'/');
    clear dnew hnew
    hnew.fldnam = {}; hnew.fldunt = {};
    for no = 1:length(newvars)
        ii = find(strcmp(newvars{no},dsv.sbename));
        dnew.(dsv.varname{ii}) = d.(newvars{no});
        hnew.fldnam = [hnew.fldnam dsv.varname{ii}];
        hnew.fldunt = [hnew.fldunt dsv.varunit{ii}];
    end
    unix(['chmod 644 ' m_add_nc(otfile)]);
    mfsave(m_add_nc(otfile), dnew, hnew, '-addvars');
    unix(['chmod 444 ' m_add_nc(otfile)]);
    otfile = [otfile '_cleaned.nc'];
    if exist(otfile, 'file')
        disp('writing to _raw_cleaned')
        unix(['chmod 644 ' m_add_nc(otfile)]);
        mfsave(otfile, dnew, hnew, '-addvars');
        unix(['chmod 644 ' m_add_nc(otfile)]);
    end
    
    %write to _24hz
    otfile = fullfile(root_ctd, ['ctd_' mcruise '_' stn_string '_24hz.nc']);
    h = m_read_header(otfile);
    [~, ii, ~] = intersect(hnew.fldnam, h.fldnam);
    if length(ii)>0
        disp(hnew.fldnam{ii})
        m = 'overwrite these variables in _24hz file? y/n \n warning: would overwrite calibrations and other corrections made in mctd_02b ';
        cont = input(m,'s');
        if ~strcmp(cont,'y')
            for no = 1:length(ii)
                dnew = rmfield(dnew, hnew.fldnam{ii(no)});
            end
            warning('not overwriting existing variables in _24hz file')
            hnew.fldnam(ii) = []; hnew.fldunt(ii) = [];
        end
    end
    if ~isempty(hnew.fldnam)
        disp('writing to _24hz')
        mfsave(otfile, dnew, hnew, '-addvars');
    end
    
    delete(m_add_nc(wkfile))
    
    cont = input('carry on without re-running mctd_rawedit? y/n ', 's');
    if strcmp(cont, 'y')
        ssd0 = MEXEC_G.ssd; MEXEC_G.ssd = 1;
        stn = stnlocal; mctd_03;
        stn = stnlocal; mctd_04;
        stn = stnlocal; mfir_03;
        stn = stnlocal; mfir_to_sam;
        MEXEC_G.ssd = ssd0;
    end
    
end
