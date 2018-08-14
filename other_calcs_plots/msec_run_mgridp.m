% make gridded section(s) by calling mgridp
%
% formerly run_mgridp_ctd
% 
% you can specify gstart, gstop, gstep, or use the defaults (per cruise/section)

%m_common %maybe this should be done as a function...
scriptname = 'msec_run_mgridp';
stn = 0; minit
root_ctd = mgetdir('M_CTD');

% grid = '10 6000 20'; % jc032

if ~exist('sections','var') | strcmp(sections, 'all') %if list exists, don't overwrite
   oopt = 'sections'; get_cropt %opt_cruise should have the list of all the sections for this cruise
end

if ~exist('gstart')
   oopt = 'gpars'; get_cropt
else
   disp('using existing gpars')
end

for ksec = 1:length(sections)
    section = sections{ksec};
    
    if isempty(gstart) %parameters differ by section
        switch section
            case {'sr1b' 'orkney' 'a23' 'srp' 'nsr' 'nsra23'}
                gstart = 10; gstop = 5000; gstep = 20;
            case {'abas' 'falk'}
                gstart = 10; gstop = 6000; gstep = 20;
            case {'osnapwall' 'laball' 'arcall' 'osnapeall' 'lineball' 'linecall' 'eelall'}
                gstart = 10; gstop = 4000; gstep = 20;
            case {'osnapwupper' 'labupper' 'arcupper' 'osnapeupper' 'linebupper' 'linecupper' 'eelupper'}
                gstart = 5; gstop = 500; gstep = 5;
            case {'fs27n' 'fs27n2'}
                gstart = 5; gstop = 1000; gstep = 10;
            case {'24n'}
                gstart = 10; gstop = 6500; gstep = 20;
            case {'bc' 'ben'}
                gstart = 5; gstop = 3000; gstep = 10;
            case {'24s'}
                gstart = 10; gstop = 6000; gstep = 20;
            otherwise
                gstart = 10; gstop = 4000; gstep = 20;
        end

    end
    pgrid = sprintf('%d %d %d',gstart,gstop,gstep);
    xpress = gstart:gstep:gstop;
    numlev = length(xpress);

    oopt = 'varlist'; get_cropt
    
    oopt = 'kstns'; get_cropt
    eval(['kstns = ' sstring ';'])

    prefix = ['ctd_' mcruise '_'];
    prefix2 = ['grid_' mcruise '_'];
    
    otfile = [root_ctd '/' prefix section];
    otfile2 = [root_ctd '/' prefix2 section];
    
    dataname = [prefix section];
    
% % % % % %         
% % % % % %     %--------------------------------
% % % % % %     MEXEC_A.MARGS_IN = {
% % % % % %         otfile
% % % % % %         dataname
% % % % % %         't'
% % % % % %         };
% % % % % %     for kstn = kstns
% % % % % %         MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN;
% % % % % %             sprintf('%s/%s%03d_2db', root_ctd, prefix, kstn)
% % % % % %             ];
% % % % % %     end
% % % % % %     l = length(MEXEC_A.MARGS_IN);
% % % % % %     MEXEC_A.MARGS_IN{l+2} = varlist;
% % % % % %     MEXEC_A.MARGS_IN{l+3} = pgrid;
% % % % % %     mgridp
% % % % % %     %--------------------------------
    %return
    
    wkfile = ['gridwk_' datestr(now,30)];
    stnline = sprintf('y = repmat(%s, %d, 1);', sstring, numlev);
    %--------------------------------
    MEXEC_A.MARGS_IN = {
        otfile
        wkfile
        '/'
        '1'
        stnline
        'statnum'
        'number'
        ' '
        };
    mcalc
    %--------------------------------
    
    %--------------------------------
    varlist = { % list of possible names, flags and units that might be mapped on a cruise
        'botoxy'   'botoxyflag'   'umol/kg'
        'silc_per_kg'     'silc_flag'    'umol/kg'
        'phos_per_kg'     'phos_flag'    'umol/kg'
        'totnit_per_kg'   'totnit_flag'  'umol/kg'
        'alk'      'alk_flag'     'umol/kg'
        'dic'      'dic_flag'     'umol/kg'
        'cfc11'    'cfc11_flag'   'pmol/kg' % jc159 data come across from analysts as per kg
        'cfc12'    'cfc12_flag'   'pmol/kg'
        'cfc13'    'cfc13_flag'   'pmol/kg'
        'f113'     'f113_flag'    'pmol/kg'
        'sf6'      'sf6_flag'     'fmol/kg'
        'sf5cf3'   'sf5cf3_flag'  'fmol/kg'
        'ccl4'     'ccl4_flag'    'pmol/kg'
        'tn'       'tn_flag'      'umol/kg'
        'tp'       'tp_flag'      'umol/kg'
        'don'      'don_flag'     'umol/kg'
        'dop'      'dop_flag'     'umol/kg'
        };
    
    % select vars to map
    oopt = 'varuse'; get_cropt
    for kv = 1:length(varuselist.names)
        kuse = strmatch(varuselist.names{kv},varlist(:,1));
        if length(kuse) ~= 1
            msg = ['Failure to match variable ''' varuselist.names{kv} ''' in preparation for maptracer'];
            fprintf(2,'%s\n',msg);
            return
        end
        varuselist.flags{kv} = varlist{kuse,2};
        varuselist.units{kv} = varlist{kuse,3};
    end
    
    MEXEC_A.MARGS_IN_2 = {};
    
    for klist = 1:length(varuselist.names)
        MEXEC_A.MARGS_IN_2 = [MEXEC_A.MARGS_IN_2; 'statnum psal temp press'];
        yline = ['y = m_maptracer(x1,x2,x3,x4,''' varuselist.names{klist} ''',''' varuselist.flags{klist} ''')'];
        MEXEC_A.MARGS_IN_2 = [MEXEC_A.MARGS_IN_2; yline];
        MEXEC_A.MARGS_IN_2 = [MEXEC_A.MARGS_IN_2; varuselist.names{klist}];
        MEXEC_A.MARGS_IN_2 = [MEXEC_A.MARGS_IN_2; varuselist.units{klist}];
    end
    
    
    
    MEXEC_A.MARGS_IN_1 = {
        wkfile
        otfile2
        '/'
        };
    
    MEXEC_A.MARGS_IN_3 = {
        ' '
        };
    
    MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN_1; MEXEC_A.MARGS_IN_2; MEXEC_A.MARGS_IN_3];
    
    mcalc
    %--------------------------------
    
    unix(['/bin/rm ' m_add_nc(wkfile)])
end
