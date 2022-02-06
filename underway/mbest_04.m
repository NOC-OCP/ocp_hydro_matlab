% mbest_04: merge vector-averaged heading onto average speed, course
%
% Use: mbest_04        and then respond with day number, or for day 20
%      day = 20; mbest_04;
% 2011 09 06 It has been added the Seapath heading (attsea) instead of
% gyros for James Cook cruises due its better accuracy. CFL/GDM

mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

clear infile* otfile* wkfile*

wkfile = ['wk_' mfilename '_' datestr(now,30)];

abbrev = MEXEC_G.default_navstream;
root_dir = mgetdir(abbrev);
prefix1 = [abbrev '_' mcruise '_'];
infile1 = fullfile(root_dir, [prefix1 'spd']);

prefix3 = ['bst_' mcruise '_'];
otfile = fullfile(root_dir, [prefix3 '01']);

switch MEXEC_G.MSCRIPT_CRUISE_STRING(1:2)
    case {'jc' 'jr' 'dy'}
        abbrev = MEXEC_G.default_hedstream;
    case 'di'
        abbrev = 'gys';
        root_ash = mgetdir('M_ASH'); infile4 = fullfile(root_ash, ['ash_' mcruise '_01']);
    otherwise
        abbrev = MEXEC_G.default_hedstream;  
end
root_head = mgetdir(abbrev);
infile2 = fullfile(root_head, [abbrev '_' mcruise '_ave']);

mdocshow(mfilename, ['merge vector-averaged heading from ' abbrev '_' mcruise '_ave onto 30 s averaged speed, in bst_' mcruise '_01.nc']);

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
switch MEXEC_G.MSCRIPT_CRUISE_STRING(1:2)
    % bak on jr281 march 23 2013: bad weather break, adding to edits from jc069
    case {'jc' 'jcr' 'dy' 'jr'} % ashtech broken on jr281 and not needed on cook
        copyfile(m_add_nc(otfile), m_add_nc(wkfile));
        calcvar = 'heading_av';
        calcstr = ['y = mcrange(x1+0,0,360);']; % no ashtech correction on jr281 yet
    case 'di' % old discovery techsas with ashtech present
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

delete(m_add_nc(wkfile));
