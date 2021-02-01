% make gridded section(s) by calling mgridp
%
% formerly run_mgridp_ctd
%
% you can specify gstart, gstop, gstep, or use the section defaults, or set
% cruise defaults in opt_cruise

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

root_ctd = mgetdir('M_CTD');

if ~exist('sections','var') | strcmp(sections, 'all') %if list exists, don't overwrite
    scriptname = mfilename; oopt = 'sections'; get_cropt %get list of sections
end

if ~exist('gstart')
    scriptname = mfilename; oopt = 'gpars'; get_cropt
else
    disp(['using existing gstart, gstop, gstep, or finding them from ' mfilename])
end

for ksec = 1:length(sections)
    section = sections{ksec};
    
    if isempty(gstart) %parameters differ by section
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
        
    end
    pgrid = sprintf('%d %d %d',gstart,gstop,gstep);
    xpress = gstart:gstep:gstop;
    % bak jc191: clear gstart now that we have used it, so it can be reset
    % for next section in ksec loop
    gstart = []; gstop = []; gstep = [];
    
    numlev = length(xpress);
    
    dataname = ['ctd_' mcruise];
    otfile = [root_ctd '/' dataname '_' section];
    otfile2 = [root_ctd '/grid_' mcruise '_' section];
    
    %ctd data
    scriptname = mfilename; oopt = 'ctd_regridlist'; get_cropt
    if length(ctd_regridlist)>0
        MEXEC_A.MARGS_IN = {
            otfile
            [dataname '_' section]
            't'
            };
        for kstn = kstns
            % bak jc191 check to see if a file exists before adding it to
            % the list
            fn_2db = sprintf('%s/%s%03d_2db.nc', root_ctd, dataname, kstn);
            if exist(fn_2db,'file') == 2
                MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN;
                    fn_2db
                    ];
            else
                fprintf(2,'%s\n',fn_2db,' was not found');
            end
        end
        l = length(MEXEC_A.MARGS_IN);
        MEXEC_A.MARGS_IN{l+2} = ctd_regridlist;
        MEXEC_A.MARGS_IN{l+3} = pgrid;
        mgridp
    end
    
    %sample data
    scriptname = mfilename; oopt = 'sec_stns'; get_cropt
    wkfile = ['gridwk_' datestr(now,30)];
    stnline = sprintf('y = repmat([%s], %d, 1);', num2str(kstns), numlev);
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
    
    % select vars to map
    samfn = [root_ctd '/sam_' MEXEC_G.MSCRIPT_CRUISE_STRING '_all' ];
    scriptname = 'm_maptracer'; oopt = 'samfn'; get_cropt; % bak jc191: choose sam_all or sam_all_nutkg
    scriptname = mfilename; oopt = 'sam_gridlist'; get_cropt
    [varuselist.names, a, iiv] = mvars_in_file(varuselist.names, samfn);

    for kv = 1:length(varuselist.names)
        kuse = find(strcmp(varuselist.names{kv},varlist(:,1)));
        if length(kuse) ~= 1
            msg = ['Failure to match variable ''' varuselist.names{kv} ''' in preparation for maptracer'];
            fprintf(2,'%s\n',msg);
            return
        end
        varuselist.flags{kv} = varlist{kuse,2};
        varuselist.units{kv} = varlist{kuse,3};
    end
    
    MEXEC_A.MARGS_IN = {
        wkfile
        otfile2
        '/'
        };
    for klist = 1:length(varuselist.names)
        MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; 'statnum psal temp press'];
        yline = ['y = m_maptracer(x1,x2,x3,x4,''' varuselist.names{klist} ''',''' [varuselist.names{klist} '_flag'] ''')'];
        MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; yline];
        MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; varuselist.names{klist}];
%        MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; varuselist.units{klist}]; %units shouldn't change
    end
    MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; ' '];
    mcalc
    
    unix(['/bin/rm ' m_add_nc(wkfile)])
end

clear sections gstart gstop gstep
