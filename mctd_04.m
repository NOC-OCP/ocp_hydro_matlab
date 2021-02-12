% mctd_04: extract downcast and upcast data from 24hz file with derived vars
%          (psal etc.) using index information in dcs file;
%          sort, average to 2dbar, interpolate gaps and recalculate potemp.
%
% Use: mctd_04        and then respond with station number, or for station 16
%      stn = 16; mctd_04;

minit;
mdocshow(mfilename, ['averages from 24 hz to 2 dbar in ctd_' mcruise '_' stn_string '_2db.nc (downcast) and _2up.nc (upcast)']);

root_ctd = mgetdir('M_CTD');

wscriptname = mfilename;
wkfile_dvars = [root_ctd '/wk_dvars_' mcruise '_' stn_string];
infile2 = [root_ctd '/dcs_' mcruise '_' stn_string];
otfile1d = [root_ctd '/ctd_' mcruise '_' stn_string '_2db'];
otfile1u = [root_ctd '/ctd_' mcruise '_' stn_string '_2up'];
wkfile1d = ['wk1d_' wscriptname '_' datestr(now,30)];
wkfile1u = ['wk1u_' wscriptname '_' datestr(now,30)];
wkfile2d = ['wk2d_' wscriptname '_' datestr(now,30)];
wkfile2u = ['wk2u_' wscriptname '_' datestr(now,30)];
wkfile3d = ['wk3d_' wscriptname '_' datestr(now,30)];
wkfile3u = ['wk3u_' wscriptname '_' datestr(now,30)];

if exist(m_add_nc(wkfile_dvars),'file') ~= 2
    mess = ['File ' m_add_nc(wkfile_dvars) ' not found, rerun mctd_03b?'];
    fprintf(MEXEC_A.Mfider,'%s\n',mess)
    return
end


%%%%% determine where to break cast into down and up segments %%%%%

[d h] = mloadq(infile2,'statnum','dc24_start','dc24_bot','dc24_end',' ');
% allow for the possibility that the dcs file contains many stations
kf = find(d.statnum == stnlocal);
dcstart = d.dc24_start(kf);
dcbot = d.dc24_bot(kf);
dcend = d.dc24_end(kf);
copystr = {[sprintf('%d',round(dcstart)) ' ' sprintf('%d',round(dcbot))]};
copystrup = {[sprintf('%d',round(dcbot)) ' ' sprintf('%d',round(dcend))]};


%%%%% determine what variables will go in 2 dbar averaged files %%%%%
%%%%% copy those from wkfile4 (24 hz data with added vars) to working files %%%%%
%%%%% for downcast and upcast %%%%%

var_copycell = mcvars_list(1);
% remove any vars from copy list that aren't available in the input file
numcopy = length(var_copycell);
h_input = m_read_header(wkfile_dvars);
var_copystr = ' ';
for kloop_scr = numcopy:-1:1
    if length(strmatch(var_copycell{kloop_scr},h_input.fldnam,'exact'))>0
        var_copystr = [var_copystr var_copycell{kloop_scr} ' '];
    else
        var_copycell(kloop_scr) = [];
    end
end
var_copystr([1 end]) = [];

%use oxy_end to NaN that many seconds before dcs scan_start
scriptname = 'castpars'; oopt = 'oxy_align'; get_cropt
if oxy_end==1
    scriptname = 'castpars'; oopt = 'oxyvars'; get_cropt
    dd = mloadq(infile2,'scan_end');
    MEXEC_A.MARGS_IN = {wkfile_dvars; 'y'};
    for no = 1:size(oxyvars,1)
        MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN
            oxyvars{no,2}
            [oxyvars{no,2} ' scan']
            sprintf('y = x1; y(x2>=%d) = NaN;',dd.scan_end-24*oxy_align)
            ' '
            ' '];
    end
    disp(['will edit out last ' num2str(oxy_end*24) ' scans from oxygen'])
    MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; ' '];
    mcalib2
end

%might have to remove some contaminated data or substitute upcast data before averaging
%although the former you should probably do in mctd_03 (case 'interp24') instead
scriptname = mfilename; oopt = 'pre_2_treat'; get_cropt

%%%%%% copy downcast and upcast ranges to new files %%%%%%

MEXEC_A.MARGS_IN = {
    wkfile_dvars
    wkfile1d
    var_copystr
    };
MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN;
    copystr
    ];
MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN;
    ' '
    ' '
    ];
margsin = MEXEC_A.MARGS_IN;
mcopya

MEXEC_A.MARGS_IN = {
    wkfile_dvars
    wkfile1u
    var_copystr
    };
MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN;
    copystrup
    ];
MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN;
    ' '
    ' '
    ];
mcopya


%%%%% optionally loopedit downcast %%%%%
scriptname = mfilename; oopt = 'doloopedit'; get_cropt
if doloopedit
    disp(['applying loopediting for ' otfile1d])
    %loopedit involves a big matrix so to save time, NaN pressure first,
    %then use to NaN other fields
    MEXEC_A.MARGS_IN = {wkfile1d
        'y'
        'press'
        'press'
        sprintf('y = m_loopedit(x1, %f);', ptol);
        ' '
        ' '
        ' '};
    mcalib2
    MEXEC_A.MARGS_IN = {wkfile1d; 'y'};
    for kloop_scr = 1:length(var_copycell)
        if ~strcmp(var_copycell{kloop_scr},'press')
            MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN
                var_copycell{kloop_scr}
                [var_copycell{kloop_scr} ' press']
                'y = x1; y(isnan(x2)) = NaN;'
                ' '
                ' '];
        end
    end
    MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; ' '];
    mcalib2
end


%%%%% sort by pressure %%%%%

MEXEC_A.MARGS_IN = {
    wkfile1d
    wkfile2d
    'press'
    };
msort

MEXEC_A.MARGS_IN = {
    wkfile1u
    wkfile2u
    'press'
    };
msort

%%%%% average to 2 dbar %%%%%

MEXEC_A.MARGS_IN = {
    wkfile2d
    wkfile3d
    '/'
    'press'
    '0 10000 2'
    'b'
    };
mavrge

MEXEC_A.MARGS_IN = {
    wkfile2u
    wkfile3u
    '/'
    'press'
    '0 10000 2'
    'b'
    };
mavrge

%%%%%interpolate to fill in gaps %%%%%

scriptname = mfilename; oopt = 'interp2db'; get_cropt

if interp2db
    MEXEC_A.MARGS_IN = {
        wkfile3d
        'y'
        '/'
        'press'
        '0'
        '0'
        };
    mintrp
    
    MEXEC_A.MARGS_IN = {
        wkfile3u
        'y'
        '/'
        'press'
        '0'
        '0'
        };
    mintrp
end

%%%%% add potemp and contemp %%%%%

MEXEC_A.MARGS_IN = {
    wkfile3d
    otfile1d
    var_copystr
    'press'
    'y = -gsw_z_from_p(x1,h.latitude)'
    'depth'
    'metres'
    'asal temp press'
    'y = gsw_pt0_from_t(x1,x2,x3)'
    'potemp'
    'degc90'
    'asal1 temp1 press'
    'y = gsw_pt0_from_t(x1,x2,x3)'
    'potemp1'
    'degc90'
    'asal2 temp2 press'
    'y = gsw_pt0_from_t(x1,x2,x3)'
    'potemp2'
    'degc90'
    ' '
    };
margsin = MEXEC_A.MARGS_IN;
mcalc

MEXEC_A.MARGS_IN = {
    wkfile3u
    otfile1u
    var_copystr
    'press'
    'y = -gsw_z_from_p(x1,h.latitude)'
    'depth'
    'metres'
    'asal temp press'
    'y = gsw_pt0_from_t(x1,x2,x3)'
    'potemp'
    'degc90'
    'asal1 temp1 press'
    'y = gsw_pt0_from_t(x1,x2,x3)'
    'potemp1'
    'degc90'
    'asal2 temp2 press'
    'y = gsw_pt0_from_t(x1,x2,x3)'
    'potemp2'
    'degc90'
    ' '
    };
mcalc

unix(['/bin/rm ' wkfile1d '.nc ' wkfile2d '.nc ' wkfile3d '.nc']);
unix(['/bin/rm ' wkfile1u '.nc ' wkfile2u '.nc ' wkfile3u '.nc']);
unix(['/bin/rm ' wkfile_dvars '.nc'])
