function zpressgrid = section_grid_params(section)

zpressgrid_deep = [0 5 25 50 75 100 175 250 375 500 ...
    625 750 875 1000 1250 1500 1750 2000 2250 2500 ...
    2750 3000 3250 3500 3750 4000 4250 4500 4750 ...
    5000 5250 5500 5750 6000 6250 6500]';
zpressgrid_shal = [0 5 25 50 75 100 125 150 175 200 225 250 ...
    275 300 350 400 450 500 550 600 650 700 800 900 1000 ...
    1100 1200 1300 1400 1500 1600 1700 1800 1900 2000]';

switch section
    case {'24n', 'fc'}
        zpressgrid = zpressgrid_deep(zpressgrid_deep<=6500);
    case {'abas' 'falk' '24s'}
        zpressgrid = zpressgrid_deep(zpressgrid_deep<=6000);
    case {'sr1b' 'sr1bb' 'orkney' 'a23' 'srp' 'nsra23'}
        zpressgrid = zpressgrid_deep(zpressgrid_deep<=5000);
    case {'osnapwall' 'laball' 'arcall' 'osnapeall' 'lineball' 'linecall' 'eelall' 'nsr' 'ar7e'}
        zpressgrid = zpressgrid_deep(zpressgrid_deep<=4000);
    case {'bc' 'ben' 'bc2' 'bc3' 'osnape' 'ta' 'km' 'kgh'}
        zpressgrid = zpressgrid_deep(zpressgrid_deep<=3000);
    case {'fs27n' 'fs27n2'}
        zpressgrid = zpressgrid_shal(zpressgrid_shal<=1000);
    case {'osnapwupper' 'labupper' 'arcupper' 'osnapeupper' 'linebupper' 'linecupper' 'eelupper' 'cumb'}
        zpressgrid = zpressgrid_shal(zpressgrid_shal<=500);
    otherwise
        zpressgrid = zpressgrid_deep;
end
