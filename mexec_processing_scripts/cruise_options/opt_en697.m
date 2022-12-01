switch scriptname
    
    case 'm_setup'
        switch oopt
            case 'setup_datatypes'
                use_ix_ladcp = 'no';
            case 'time_origin'
                %this used to be in m_setup but seems cruise-specific
                %rather than processing-run-specific, hence moved here
                MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [2023 1 1 0 0 0];
        end
        
        %below are parameters you will need to set early on; for
        %information see setdef_cropt_cast (or setdef_cropt_* for other
        %options) and for examples see opt_jc238
        
    case 'castpars'
        switch oopt
            case 'nnisk'
        end
        
    case 'mfir_01'
        switch oopt
            case 'blinfile'
            case 'nispos'
        end
        
    case 'mctd_01'
        switch oopt
            case 'cnvfilename'
        end
        
end
