switch scriptname
    
    case 'mctd_01'
        switch oopt
            case 'cnvfilename'
                if redoctm
                    infile = sprintf('DY130_%03d.cnv', stnlocal);
                else
                    infile = sprintf('DY130_%03d_align_CTM.cnv', stnlocal);
                end
        end
   
    case 'mfir_01'
        switch oopt
            case 'blinfile'
                infile = sprintf('DY130_%03d.bl', stnlocal);
        end
        
    case 'mbot_01'
        switch oopt
            case 'blfilename'
                infile = sprintf('DY130_%03d.bl', stnlocal);
        end
        
end
