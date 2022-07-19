        switch section
            case {'24n', 'fc'}
                gstart = 10; gstop = 6500; gstep = 20;
            case {'abas' 'falk' '24s'}
                gstart = 10; gstop = 6000; gstep = 20;
            case {'sr1b' 'sr1bb' 'orkney' 'a23' 'srp' 'nsra23'}
                gstart = 10; gstop = 5000; gstep = 20;
            case {'osnapwall' 'laball' 'arcall' 'osnapeall' 'lineball' 'linecall' 'eelall' 'nsr'}
                gstart = 10; gstop = 4000; gstep = 20;
            case {'bc' 'ben' 'bc' 'bc2' 'bc3'}
                gstart = 5; gstop = 3000; gstep = 10;
            case {'fs27n' 'fs27n2'}
                gstart = 5; gstop = 1000; gstep = 10;
            case {'osnapwupper' 'labupper' 'arcupper' 'osnapeupper' 'linebupper' 'linecupper' 'eelupper' 'cumb'}
                gstart = 5; gstop = 500; gstep = 5;
            otherwise
                gstart = 10; gstop = 4000; gstep = 20;
        end      
