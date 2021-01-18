% msam_01: if no template sam file exists, create; (then) 
%          copy template to file for this station and edit station number
%          etc.
% 
% Use: msam_01        and then respond with station number, or for station 16
%      stn = 16; msam_01;
%
% The input list of variable names, templates/sam_varlist.csv, 
%    is a comma-delimeted list of vars and units to be created
%    The format of each line is
%    varname,newunits,default_value
% The set of names is parsed and written back to templates/ctd_varlist_out.csv
% The set of names can be prepared in any unix text editor.
% It can also be prepared in excel and saved as csv, but on BAK's
% mac this generates csv files with c/r instead of n/l. Thus the
% _out.csv file is more suitable for editing on unix.
%

minit; scriptname = mfilename; 
mdocshow(scriptname, ['creating empty sam_' mcruise '_' stn_string '.nc based on templates/sam_varlist.csv']);

% resolve root directories for various file types
root_templates = mgetdir('M_TEMPLATES');
root_sam = mgetdir('M_SAM');

prefixt = ['sam_'];
prefix1 = ['sam_' mcruise '_'];

oopt = 'nbot'; get_cropt %number of niskins (may be station-dependent)

otfile = [root_sam '/' prefix1 stn_string];
otfile2 = [root_sam '/' prefix1 'template_' num2str(num_bottles)];

dataname = [prefix1 stn_string];

if ~exist(otfile2, 'file') 
    %if there is no sam_cruise_template file of the right size, create file
    %for this station, and copy to template
    disp(['copying from ' otfile2])

    %what variables we want, from templates/
    varfile = [root_templates '/' prefixt 'varlist.csv']; % read list of var names and units for empty sam template
    varfileout = [root_templates '/' prefixt 'varlist_out.csv']; % write list of var names and units for empty sam template
    cellall = mtextdload(varfile,','); % load all text
    clear snames sunits sdef
    for kline = 1:length(cellall)
        cellrow = cellall{kline}; % unpack rows
        snames{kline} = m_remove_outside_spaces(cellrow{1});
        sunits{kline} = m_remove_outside_spaces(cellrow{2});
        if length(cellrow) > 2 % unpick default value if its there
            sdef{kline} = m_remove_outside_spaces(cellrow{3}); % string, inserted in a command later on
        else
            sdef{kline} = 'nan'; % backwards compatible. If there's no default use nan
        end
    end
    snames = snames(:);
    sunits = sunits(:);
    sdef = sdef(:);
    numvar = length(snames);
    fidmsam01 = fopen(varfileout,'w'); % save back to out file
    for k = 1:numvar
        fprintf(fidmsam01,'%s%s%s\n',snames{k},',',sunits{k});
    end
    fclose(fidmsam01);
    
    z = zeros(num_bottles,1); % mod by bak on jr302 to use default value from template
    data.junk = [];
    for k = 1:numvar
        data = setfield(data, snames{k}, sdef{k}+z);
    end
    data = rmfield(data, 'junk');

    checknames = {'position' 'statnum' 'sampnum'};
    checkunits = {'on.rosette' 'number' 'number'};
    % ensure at least these three names exist in the list
    for k = 1:length(checknames)
        cname = checknames{k};
        kmatch = strmatch(cname,snames,'exact');
        if isempty(kmatch)
            snames = [cname; snames(:)];
            sunits = [checkunits{k}; sunits(:)];
        end
    end

    snames_units = {};
    for k = 1:length(snames)
        snames_units = [snames_units; snames(k)];
        snames_units = [snames_units; {'/'}];
        snames_units = [snames_units; sunits(k)];
    end

    %set values of the not-blank variables
    position = [1:num_bottles]';
    sampnum = stnlocal*100+data.position;
    statnum = stnlocal+0*data.position;

    %write to file
    timestring = ['[' sprintf('%d %d %d %d %d %d',MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN) ']'];

    MEXEC_A.MARGS_IN_1 = {
        otfile
        };
    MEXEC_A.MARGS_IN_2 = snames(:);
    MEXEC_A.MARGS_IN_3 = {
        ' '
        ' '
        '1'
        dataname
        '/'
        '2'
        MEXEC_G.PLATFORM_TYPE
        MEXEC_G.PLATFORM_IDENTIFIER
        MEXEC_G.PLATFORM_NUMBER
        '/'
        '4'
        timestring
        '/'
        '8'
        };
    MEXEC_A.MARGS_IN_4 = snames_units(:);
    MEXEC_A.MARGS_IN_5 = {
        '-1'
        '-1'
        };
    MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN_1; MEXEC_A.MARGS_IN_2; MEXEC_A.MARGS_IN_3; MEXEC_A.MARGS_IN_4; MEXEC_A.MARGS_IN_5];
    msave

    %copy to template file, for next time
    unix(['cp ' m_add_nc(otfile) ' ' m_add_nc(otfile2)])
    
else
    %there is a template file, just copy and edit sampnum, statnum
    %this replaces msam_01b
    
    %copy from template to this station
    unix(['cp ' m_add_nc(otfile2) ' ' m_add_nc(otfile)])
    
    %edit dataname
    MEXEC_A.MARGS_IN = {
        infile
        'y'
        '1'
        dataname
        '/'
        '/'
        };
    mheadr
    
    %edit statnum and sampnum
    statstr = ['y = ' stn_string ' + 0 * x1'];
    sampstr = ['y = 100 * x1 + x2'];
    MEXEC_A.MARGS_IN = {
        infile
        'y'
        'statnum'
        'statnum'
        statstr
        '/'
        '/'
        'sampnum'
        'statnum position'
        sampstr
        ' '
        ' '
        ' '
        };
    mcalib2
    
end