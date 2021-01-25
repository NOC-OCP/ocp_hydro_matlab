%%%%%%%%%% Warnings for unset options (called at end of get_cropt, after opt_cruise) %%%%%%%%%
switch scriptname
    
        %%%%%%%%%% mctd_02a %%%%%%%%%%
    case 'mctd_02a'
        switch oopt
            case 'prectm_rawedit'
                if redoctm & length(pvars)+length(sevars)+length(revars)+length(dsvars)==0
                    warning(['rerunning cell thermal mass correction on raw file for station ' stn_string 'but no raw edits are specified under mctd_02a, editraw in opt_' mcruise])
                end
        end
                %%%%%%%%%% end mctd_02a %%%%%%%%%%

    %%%%%%%%%% mctd_02b %%%%%%%%%%
    case 'mctd_02b'
        switch oopt
            case 'oxyrev'
                if length(H1)>1 | length(H2)>1 | length(H3)>1
                    warning('mcoxyhyst_rev not set up to use vector parameters') %***should probably modify this anyway
                end
        end
        %%%%%%%%%% end mctd_02b %%%%%%%%%%
        
        %%%%%%%%%% mctd_03 %%%%%%%%%%
    case 'mctd_03'
        switch oopt
            case '24hz_edit'
                if length(switchscans24)>0 & sum(strcmp('temp', switchscans24(:,1))) + sum(strcmp('cond', switchscans24(:,1))) == 1
                    warning('you have chosen to switch primary and secondary for either cond or temp but not both')
                    error('using T and C from different CTDs will lead to erroneous salinity; revise opt_cruise file ''mctd_03'', ''24hz_edit'' case')
                end
        end
        %%%%%%%%%% end mctd_03 %%%%%%%%%%
     
        %%%%%%%%%% msal_standardise_avg %%%%%%%%%%
    case 'msal_standardise_avg'
        switch oopt
            case 'plot_stations'
                if ~exist('iistno'); iistno = [1:length(stnos)]; end
            case 'std2use'
                if ~exist('std2use'); disp('set autosal standards readings to use for this cruise'); keyboard; end
            case 'sam2use'
                if ~exist('sam2use'); disp('set salinity sample readings to use for this cruise'); keyboard; end
        end
        %%%%%%%%%% end msal_standardise_avg %%%%%%%%%%
        
        %%%%%%%%%% cond_apply_cal %%%%%%%%%%
    case 'cond_apply_cal'
        if 
        if ~exist('off','var') & ~exist('fac','var')
            warning(['no cond cal set for sensor ' sensor]); 
        elseif exist('off','var') & exist('fac','var')
        if off==0 & fac==1
        warning(['cond cal for sensor ' sensor ' will have no effect'])
        end
        end
        %%%%%%%%%% end cond_apply_cal %%%%%%%%%%
        
        %%%%%%%%%% tsgsal_apply_cal %%%%%%%%%%
    case 'tsgsal_apply_cal'
        switch oopt
            case 'saladj'
                if ~exist('salout'); warning(['no salinity cal set for TSG']); end
            case 'tempadj'
                if ~exist('tempout'); warning(['no temperature adjustment set for TSG']); end
        end
        %%%%%%%%%% end cond_apply_cal %%%%%%%%%%
        
        %%%%%%%%%% temp_apply_cal %%%%%%%%%%
    case 'temp_apply_cal'
        if ~exist('tempadj'); warning(['no temp cal set for sensor ' sensor]); end
        %%%%%%%%%% end temp_apply_cal %%%%%%%%%%
        
        %%%%%%%%%% oxy_apply_cal %%%%%%%%%%
    case 'oxy_apply_cal'
        if ~exist('alpha') & ~exist('beta'); warning(['no oxy cal set for sensor ' sensor]); end
        %%%%%%%%%% end oxy_apply_cal %%%%%%%%%%
        
        %%%%%%%%%% fluor_apply_cal %%%%%%%%%%
    case 'fluor_apply_cal'
        if ~exist('fac') & ~exist('expco'); warning(['no fluor cal set']); end
        %%%%%%%%%% end fluor_apply_cal %%%%%%%%%%
        
        %%%%%%%%%% miso_02 %%%%%%%%%%
    case 'miso_02'
        if ~exist('cvars'); warning(['must set cvars, list of isotope variable names to write, in miso_02 options']); end
        %%%%%%%%%% end miso_02 %%%%%%%%%%
        
end % End of second "switch scriptname" to check for unset options
