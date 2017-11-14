% mbest_04: merge vector-averaged heading onto average speed, course
%
% Use: mbest_04        and then respond with day number, or for day 20
%      day = 20; mbest_04;
% 2011 09 06 It has been added the Seapath heading (attsea) instead of
% gyros for James Cook cruises due its better accuracy. CFL/GDM

scriptname = 'mbest_04';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

clear infile* otfile* wkfile*

wkfile = ['wk_' scriptname '_' datestr(now,30)];

abbrev = MEXEC_G.default_navstream;
root_dir = mgetdir(['M_' upper(abbrev)])
prefix1 = [abbrev '_' cruise '_'];
infile1 = [root_dir '/' prefix1 'spd'];

prefix3 = ['bst_' cruise '_'];
otfile = [root_dir '/' prefix3 '01'];

switch MEXEC_G.Mship
    case 'cook'
        abbrev = 'attsea';
    case 'jcr' % bak on jr281
        abbrev = 'seatex_hdt';
    otherwise
        abbrev = 'gys';
        root_ash = mgetdir('M_ASH'); infile4 = [root_ash '/ash_' cruise '_01'];
end
root_head = mgetdir(['M_' upper(abbrev)]);
infile2 = [root_head '/' abbrev '_' cruise '_ave'];

mdocshow(scriptname, ['merge vector-averaged heading from ' abbrev '_' cruise '_ave onto 30 s averaged speed, in bst_' cruise '_01.nc']);

MEXEC_A.MARGS_IN = {
    otfile
    infile1
    '/'
    'time'
    infile2
    'time'
    'heading_av'
    'k'
    };
mmerge

%--------------------------------
switch MEXEC_G.Mship
    % bak on jr281 march 23 2013: bad weather break, adding to edits from jc069
    case {'cook' 'jcr'} % ashtech broken on jr281 and not needed on cook
        cmd = ['/bin/cp -p ' m_add_nc(otfile) ' ' m_add_nc(wkfile)]; unix(cmd);
        calcvar = 'heading_av';
        calcstr = ['y = mcrange(x1+0,0,360);']; % no ashtech correction on jr281 yet
    case 'discovery' % old discovery techsas with ashtech present
        calcvar = 'heading_av a_minus_g';
        calcstr = ['y = mcrange(x1+x2,0,360);']; % prepare to add a_minus_g on discovery
        
        %--------------------------------
        % merge in the a-minus-g heading correction from the ashtech file into the
        % bestnav file
        MEXEC_A.MARGS_IN = {
            wkfile
            otfile
            '/'
            'time'
            infile4
            'time'
            'a_minus_g'
            'k'
            };
        mmerge
        %--------------------------------
end
%--------------------------------
%calculate the corrected heading <heading_av_corrected> using the a-minus-g
%heading correction. mcrange is used to ensure that this heading variable
%is always between 0 and 360 degrees.
% bak on jr281: on cook and jcr, there correction is zero because heading
% comes from an absolute source instead of the gyro.
MEXEC_A.MARGS_IN = {
    wkfile
    otfile
    '/'
    calcvar
    calcstr
    'heading_av_corrected'
    'degrees'
    ' '
    };
mcalc
%--------------------------------

unix(['/bin/rm ' wkfile '.nc']);
