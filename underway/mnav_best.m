% get combined file of nav data from best source (specified in m_setup)
%
% Use: mnav_best       and then respond with day number, or for day 20
%      day = 20; mnav_best;

mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

%start with the original data in the same directory
abbrev = MEXEC_G.default_navstream;
headpre = MEXEC_G.default_hedstream;
if strcmp(MEXEC_G.MSCRIPT_CRUISE_STRING(1:2),'di')
    headpre = 'gys';
end

root_pos = mgetdir(abbrev);
root_head = mgetdir(headpre);

prefixp = [abbrev '_' mcruise '_'];
prefixh = [headpre '_' mcruise '_'];
prefixo = ['bst_' mcruise '_'];

infile = fullfile(root_pos, [prefixp '01']);
avfile = fullfile(root_pos, [prefixp 'ave']);
spdfile = fullfile(root_pos, [prefixp 'spd']);
infileh = fullfile(root_head, [prefixh '01']);
avfileh = fullfile(root_head, [prefixh 'ave']);
bstfile = fullfile(root_pos, [prefixo '01']);
clear wkfile
for no = 1:7
    wkfile{no} = ['wk' num2str(no) '_' mfilename '_' datestr(now,30)];
end

mdocshow(mfilename, ['average 1-Hz navigation stream from ' infile ' to 30 s in ' avfile ' and calculate speed, course, distrun into ' spdfile]);
mdocshow(mfilename, ['average 1-Hz navigation stream from ' infileh ' to 30 s in ' avfileh, ' merge onto 30 s averaged speed from ' spdfile ' into ' bstfile]);


scriptname = 'ship'; oopt = 'avtime'; get_cropt
tave_period = round(avnav); % seconds
tav2 = round(tave_period/2);


%%%%% create 30-second nav file from 1-Hz positions %%%%%

[d, h] = mloadq(infile,'time',' ');
latvar = munderway_varname('latvar', h.fldnam, 1 ,'s');
lonvar = munderway_varname('lonvar', h.fldnam, 1, 's');

MEXEC_A.MARGS_IN = {
    infile
    wkfile{1}
    ['time ' latvar ' ' lonvar]
    ' '
    ' '
    ' '
    };
mcopya

t1 = min(d.time);
tdays = floor(t1/86400);
t1 = tdays*86400;
t1 = t1-tav2;
tavstring = [sprintf('%d',t1) ' 1e10 ' sprintf('%d',tave_period)];
MEXEC_A.MARGS_IN = {
    wkfile{1}
    avfile
    '/'
    'time'
    tavstring
    'b'
    };
msmoothnav


%%%%% calculate speed, course, distrun from the 30-s averages %%%%%

MEXEC_A.MARGS_IN = {
    avfile
    wkfile{2}
    ['time ' latvar ' ' lonvar]
    ['time ' latvar ' ' lonvar]
    'm'
    've'
    'vn'
    };
mposspd

MEXEC_A.MARGS_IN = {
    wkfile{2}
    wkfile{3}
    '/'
    '1'
    've vn'
    'smg'
    ' '
    'cmg'
    ' '
    };
muvsd

MEXEC_A.MARGS_IN = {
    wkfile{3}
    spdfile
    '/'
    [latvar ' ' lonvar]
    'y = m_nancumsum(sw_dist(x1,x2,''km'')); y(2:length(y)+1) = y; y(1) = 0;'
    'distrun'
    'km'
    ' '
    };
mcalc

%%%%% create 30-second heading file from 1-Hz positions %%%%%


[d, h] = mload(infileh, 'time', ' ');
t1 = min(d.time);
tdays = floor(t1/86400);
t1 = tdays*86400;
% unlike positions files, make gyro average be vector average of period ending on final timestamp, not centered on timestamp.
tavstring = [sprintf('%d',t1) ' 1e10 ' sprintf('%d',tave_period)];
toffstring = ['y = x + ' sprintf('%d',tav2)];
headvar = munderway_varname('headvar', h.fldnam, 1, 's');

MEXEC_A.MARGS_IN = {
    infileh
    wkfile{4}
    '/'
    [headvar ' ' headvar]
    'y = 1+x1-x2'
    'dummy'
    'none'
    ' '
    };
mcalc

MEXEC_A.MARGS_IN = {
    wkfile{4}
    wkfile{5}
    '/'
    '2'
    ['dummy ' headvar]
    'dum_e'
    ' '
    'dum_n'
    ' '
    };
muvsd

MEXEC_A.MARGS_IN = {
    wkfile{5}
    wkfile{6}
    '/'
    '1'
    tavstring
    'b'
    };
mavrge

MEXEC_A.MARGS_IN = {
    wkfile{6}
    avfileh
    'time'
    '1'
    'dum_e dum_n'
    'dumspd'
    ' '
    'heading_av'
    ' '
    };
muvsd

MEXEC_A.MARGS_IN = {
    avfileh
    'y'
    'time'
    toffstring
    ' '
    ' '
    ' '
    };
mcalib


%%%%% merge vector-averaged heading onto average speed, course %%%%%

MEXEC_A.MARGS_IN = {
    bstfile
    spdfile
    '/'
    'time'
    avfileh
    'time'
    'heading_av'
    'k'
    };
mmerge

%--------------------------------
switch MEXEC_G.MSCRIPT_CRUISE_STRING(1:2)
    % bak on jr281 march 23 2013: bad weather break, adding to edits from jc069
    case {'jc' 'jcr' 'dy' 'jr'} % ashtech broken on jr281 and not needed on cook
        copyfile(m_add_nc(bstfile), m_add_nc(wkfile{7}));
        calcvar = 'heading_av';
        calcstr = ['y = mcrange(x1+0,0,360);']; % no ashtech correction on jr281 yet
    case 'di' % old discovery techsas with ashtech present
        root_ash = mgetdir('M_ASH'); infile4 = fullfile(root_ash, ['ash_' mcruise '_01']);
        calcvar = 'heading_av a_minus_g';
        calcstr = ['y = mcrange(x1+x2,0,360);']; % prepare to add a_minus_g on discovery
        
        %--------------------------------
        % merge in the a-minus-g heading correction from the ashtech file into the
        % bestnav file
        MEXEC_A.MARGS_IN = {
            wkfile{7}
            bstfile
            '/'
            'time'
            infile4
            'time'
            'a_minus_g'
            'k'
            };
        mmerge
        
        %calculate the corrected heading <heading_av_corrected> using the a-minus-g
        %heading correction. mcrange is used to ensure that this heading variable
        %is always between 0 and 360 degrees.
        % bak on jr281: on cook and jcr, there correction is zero because heading
        % comes from an absolute source instead of the gyro.
        MEXEC_A.MARGS_IN = {
            wkfile{7}
            bstfile
            '/'
            calcvar
            calcstr
            'heading_av_corrected'
            'degrees'
            ' '
            };
        mcalc
        
end

for no = 1:length(wkfile)
    delete(m_add_nc(wkfile{no}))
end
