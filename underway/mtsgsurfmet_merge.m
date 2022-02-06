%add data from one file to another by interpolation for comparison and
%editing

metnames = {'met_tsg', 'surfmet'}; %***
for no = 1:length(metnames)
    if length(mgetdir(metnames{no}))>0
        filemet = [mgetdir(metnames{no}) '/' metnames{no} '_' mcruise '_01.nc'];
        if exist(filemet, 'file')
            [dm, hm] = mloadq(filemet, '/'); 
            dm.timec = dm.time/3600/24+datenum(hm.data_time_origin);
            hnew.fldnam = hm.fldnam; hnew.fldunt = hm.fldunt;
            
            switch MEXEC_G.Mshipdatasystem
                
                case 'techsas'
                    
                    filetsg = [mgetdir('tsg') '/tsg_' mcruise '_01.nc'];                    
                    if exist(filetsg,'file')
                        mdocshow(mfilename, ['merge tsg data into met_tsg_' mcruise '_01.nc'])
                        [dt, ht] = mloadq(filetsg, '/');
                        dt.timec = dt.time/3600/24+datenum(ht.data_time_origin);
                        
                        %calculate salinity if necessary
                        if ~isfield(dt, 'psal')
                            havevars = 1;
                            condvars = {'cond' 'conductivity' 'conductivity_raw'};
                            tempvars = {'tstemp' 'temp_h' 'temp_m' 'temp_housing_raw' 'temp_housing'};
                            condvar = mvarname_find(condvars, h.fldnam);
                            tempvar = mvarname_find(tempvars, h.fldnam);
                            if length(condvar)>0 & length(tempvar)>0
                                dt.psal = gsw_SP_from_C(10*dt.(condvar),dt.(tempvar),0)'; %we have S/m, gsw wants mS/cm
                                ht.fldnam = [ht.fldnam 'psal'];
                                ht.fldunt = [ht.fldunt 'pss-78'];
                            end
                        end
                        
                        %paste in the variables
                        addvars = {'psal' 'temp_r' 'temp_h' 'cond' 'sndspeed'};
                        for vno = 1:length(addvars)
                            ii = find(strcmp(addvars{vno}, ht.fldnam));
                            if length(ii)>0
                                dm.(addvars{vno}) = interp1(dt.timec, dt.(addvars{vno}), dm.timec);
                                hnew.fldnam = [hnew.fldnam addvars{vno}];
                                hunt.fldnam = [hnew.fldunt ht.fldunt{ii}];
                                hnew.comment = sprintf('variables interpolated from tsg_%s_01.nc:', mcruise);
                                hnew.comment = [hnew.comment sprintf(' %s,', addvars{:})]; hnew.comment(end) = [];
                            end
                        end
                        
                    end
                    
                case 'rvdas'
                    
                    %vector interpolate windsonic data onto met times
                    filesa = [mgetdir('windsonic') '/windsonic_' mcruise '_01.nc'];
                    if exist(filesa, 'file')
                        [ds, hs] = mloadq(filesa, '/'); 
                        ds.timec = ds.time/3600/24+datenum(hs.data_time_origin);
                        
                        windsin = mvarname_find({'windspeed_raw' 'wind_speed_ms' 'relwind_spd_raw'}, hs.fldnam);
                        winddin = mvarname_find({'winddirection_raw' 'direct' 'wind_dir' 'relwind_dirship_raw'}, hs.fldnam);
                        windssa = [windsin '_sonic']; winddsa = [winddin '_sonic'];
                        data = interp1(ds.timec, ds.(windsin).*exp(sqrt(-1)*ds.(winddin)/180*pi), dm.timec);
                        dm.(windssa) = abs(data); dm.(winddsa) = mod(angle(data)*180/pi,360);
                        hnew.fldnam = [hnew.fldnam windssa winddsa];
                        hnew.fldunt = [hnew.fldunt 'm/s' 'degrees'];
                        hnew.comment = sprintf('variables interpolated from windsonic_%s_01.nc:', mcruise);
                    end
                    
            end
            
            %save
            if length(hnew.fldnam)>length(h.fldnam) %we did find something to do
                dm = rmfield(dm, 'timec');
                [hnew.fldnam,iif] = unique(hnew.fldnam); hnew.fldunt = hnew.fldunt(iif);
                mfsave(filemet, dm, hnew, '-addvars');
            end
            
        end
    end
end
