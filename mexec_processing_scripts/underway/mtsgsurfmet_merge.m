%add data from one file to another by interpolation for comparison and
%editing
%for techsas, will add tsg data to met data
%for rvdas, add tsg and windsonic data to met data

scriptname = 'ship'; oopt = 'ship_data_sys_names'; get_cropt
clear dnew hnew

filemet = [mgetdir(metpre) '/' metpre '_' mcruise '_01.nc'];
if exist(filemet, 'file')
    [dm, hm] = mloadq(filemet, '/');
    dm.timec = dm.time/3600/24+datenum(hm.data_time_origin);
    hnew.fldnam = {}; hnew.fldunt = {};
    
    %use best available file
    filetsg = [mgetdir('tsg') '/tsg_' mcruise '_01_medav_clean_cal.nc'];
    if ~exist(filetsg,'file')
        filetsg = [mgetdir('tsg') '/tsg_' mcruise '_01_medav_clean.nc'];
        if ~exist(filetsg,'file')
            filetsg = [mgetdir('tsg') '/tsg_' mcruise '_01.nc'];
            if exist(filetsg,'file')
                disp('run mtsg_medav_clean_cal when you have calibration data')
            else
                warning('no tsg file; skipping')
            end
        end
    end
    
    if exist(filetsg,'file')
        if MEXEC_G.quiet<=1; fprintf(1,'merging tsg data into %s_%s_01.nc\n',metpre,mcruise); end
        [dt, ht] = mloadq(filetsg, '/');
        dt.timec = dt.time/3600/24+datenum(ht.data_time_origin);
        
        %add tsg variables to structure to save into file
        addvars = munderway_varname({'salvar' 'tempvar' 'condvar' 'sstvar' 'svelvar'}, ht.fldnam, 's');
        for vno = 1:length(addvars)
            ii = find(strcmp(addvars{vno}, ht.fldnam));
            if ~isempty(ii)
                dnew.(addvars{vno}) = interp1(dt.timec, dt.(addvars{vno}), dm.timec);
                hnew.fldnam = [hnew.fldnam addvars{vno}];
                hnew.fldunt = [hnew.fldunt ht.fldunt{ii}];
            end
            ii = find(strcmp([addvars{vno} '_raw'], ht.fldnam));
            if ~isempty(ii)
                dnew.([addvars{vno} '_raw']) = interp1(dt.timec, dt.([addvars{vno} '_raw']), dm.timec);
                hnew.fldnam = [hnew.fldnam [addvars{vno} '_raw']];
                hnew.fldunt = [hnew.fldunt ht.fldunt{ii}];
            end
        end
        hnew.comment = sprintf('variables interpolated from %s:', filetsg);
        hnew.comment = [hnew.comment sprintf(' %s,', addvars{:})]; hnew.comment(end) = [];
    end
    
    switch MEXEC_G.Mshipdatasystem
        case 'rvdas'
            %vector interpolate windsonic data onto met times
            filesa = [mgetdir('windsonic') '/windsonic_' mcruise '_01.nc'];
            if exist(filesa, 'file')
                [ds, hs] = mloadq(filesa, '/');
                ds.timec = ds.time/3600/24+datenum(hs.data_time_origin);
                
                windsin = munderway_varname('twindsvar', hs.fldnam, 1, 's');
                winddin = munderway_varname('twinddvar', hs.fldnam, 1, 's');
                windssa = [windsin '_sonic']; winddsa = [winddin '_sonic'];
                data = interp1(ds.timec, ds.(windsin).*exp(sqrt(-1)*ds.(winddin)/180*pi), dm.timec);
                dnew.(windssa) = abs(data); dnew.(winddsa) = mod(angle(data)*180/pi,360);
                hnew.fldnam = [hnew.fldnam windssa winddsa];
                hnew.fldunt = [hnew.fldunt 'm/s' 'degrees'];
                hnew.comment = sprintf('variables interpolated from windsonic_%s_01.nc:', mcruise);
            end
            
    end
    
    %save
    if ~isempty(hnew.fldnam) %we did find something to do
        mfsave(filemet, dnew, hnew, '-addvars');
    end
    
end
