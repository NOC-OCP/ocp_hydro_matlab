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

oopt = 'nnisk'; scriptname = 'general'; get_cropt %number of niskins (may be station-dependent)

root_sam = mgetdir('M_SAM');
dataname = ['sam_' mcruise '_'];
otfile = [root_sam '/' dataname];
otfile2 = [root_sam '/sam_' mcruise '_template_' num2str(num_bottles)];

if ~exist(otfile2, 'file')
    %if there is no sam_cruise_template file of the right size, create file
    %for this station, and copy to template
    disp(['copying from ' otfile2])
    
    %get list of variables and units
    scriptname = mfilename; oopt = 'samvars'; get_cropt
    varnames = {}; varunits = {}; ds.junk = [];
    for vno = 1:length(samvars_use)
        iir = find(strcmp(samvars_replace(:,1), samvars_use{vno}));
        ii0 = find(strcmp(ds_sam.varname, samvars_use{vno}));
        iia = find(strcmp(samvars_add(:,1), samvars_use{vno}));
        if length(ii0)>0
            if length(iir)>0
                warning(sprintf('replacing %s, %s, %s with %s, %s, %s',ds_sam.varname(ii0), ds_sam.varunit(ii0), ds_sam.fillvalue(ii0), samvars_replace{iir,1}, samvars_replace{iir,2}, samvars_replace{iir,3}));
                varnames = [varnames; samvars_use{vno}];
                varunits = [varunits; samvars_replace{iir,2}];
                ds = setfield(ds, samvars_use{vno}, repmat(samvars_replace{iir,3},nnisk,1));
            else
                varnames = [varnames; samvars_use{vno}];
                varunits = [varunits; ds_sam.varunit(ii)];
                ds = setfield(ds, samvars_use{vno}, repmat(ds_sam.fillvalue(ii),nnisk,1));
            elseif length(iia)>0
                varnames = [varnames; samvars_use{vno}];
                varunits = [varunits; samvars_add{iia,2}];
                ds = setfield(ds, samvars_use{vno}, repmat(samvars_add{iia,3},nnisk,1));
            else
                error(sprintf('variable %s not found in either templates/sam_varlist.csv or in samvars_add from opt_%s', samvars_use{vno}, mcruise));
            end
        end
    end
    mvarnames_units %get varnames_units, and variables with default values
    
    %set values of the not-blank variables
    position = [1:nnisk]';
    sampnum = stnlocal*100+position;
    statnum = repmat(stnlocal,nnisk,1);
        
    %write to file
    timestring = ['[' sprintf('%d %d %d %d %d %d',MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN) ']'];
    
    MEXEC_A.MARGS_IN_1 = {
        otfile
        };
    MEXEC_A.MARGS_IN_2 = varnames(:);
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
    MEXEC_A.MARGS_IN_4 = varnames_units(:);
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