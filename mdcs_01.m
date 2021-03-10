% mdcs_01: create empty data cycles file, if one does not already exist
%
% Use: mdcs_01        and then respond with station number, or for station 16
%      stn = 16; mdcs_01;
%
% The input list of variable names, example filename dcs_varlist.csv
%    is a comma-delimited list of vars and units to be added to under the
%    header varname, varunit (but probably you don't need to edit)

minit; 
mdocshow(mfilename, ['finds scan number corresponding to bottom of cast, writes to dcs_' mcruise '_' stn_string '.nc']);

% resolve root directories for various file types
root_templates = mgetdir('M_TEMPLATES');
root_ctd = mgetdir('M_CTD');

% get bottom index
infile1 = [root_ctd '/ctd_' mcruise '_' stn_string '_psal'];
infile0 = [root_ctd '/ctd_' mcruise '_' stn_string '_24hz'];
[d1, h1] = mloadq(infile1,'time','scan','press',' ');
d24 = mloadq(infile0,'scan',' ');
scriptname = mfilename; oopt = 'kbot'; get_cropt

%get variables to save
clear ds statnum dc_bot scan_bot press_bot time_bot dc24_bot
ds.statnum = stnlocal;
ds.dc_bot = kbot;
ds.scan_bot = floor(d1.scan(ds.dc_bot));
ds.press_bot = d1.press(ds.dc_bot);
ds.time_bot = d1.time(ds.dc_bot);
ds.dc24_bot = min(find(d24.scan >= ds.scan_bot));

m = ['Bottom of cast is at dc ' sprintf('%d',ds.dc_bot) ' pressure ' sprintf('%8.1f',ds.press_bot) ' and scan ' sprintf('%d',ds.scan_bot)];
fprintf(MEXEC_A.Mfidterm,'%s\n','',m)

% write
dataname = ['dcs_' mcruise '_' stn_string];
otfile = [root_ctd '/' dataname];

varnames = {'statnum' 'time_bot' 'dc_bot' 'scan_bot' 'press_bot' 'dc24_bot'};
varunits = {'number' 'seconds' 'number' 'number' 'dbar' 'number'};

MEXEC_A.Mprog = mfilename;
if exist(m_add_nc(otfile),'file')

    %add to existing file
    hnew.fldnam = varnames; hnew.fldunt = varunits;
    mfsave(otfile, ds, hnew, '-addvars');
    
else
    
    %save new file
    mvarnames_units %turns varnames, varunits, ds into varnames_units and variables with names varnames
    timestring = ['[' sprintf('%d %d %d %d %d %d',h1.data_time_origin) ']'];
    %--------------------------------
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
    
end
