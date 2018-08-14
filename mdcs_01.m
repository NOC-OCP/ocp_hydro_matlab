% mdcs_01: create empty data cycles file
%
% Use: mdcs_01        and then respond with station number, or for station 16
%      stn = 16; mdcs_01;
%
% The input list of variable names, example filename dcs_jr193_varlist.csv
%    is a comma-delimeted list of vars and units to be created
%    The format of each line is
%    varname,newunits
% The set of names is parsed and written back to dcs_jr193_varlist_out.csv
% The set of names can be prepared in any unix text editor.
% It can also be prepared in excel and saved as csv, but on BAK's
% mac this generates csv files with c/r instead of n/l. Thus the
% _out.csv file is more suitable for editing on unix.

scriptname = 'mdcs_01';
minit
mdocshow(scriptname, ['creates empty data cycles file dcs_' mcruise '_' stn_string '.nc based on templates/dcs_varlist.csv']);

% resolve root directories for various file types
root_templates = mgetdir('M_TEMPLATES');
root_ctd = mgetdir('M_CTD');

prefix1 = ['dcs_' mcruise '_'];
prefixt = ['dcs_'];

varfile = [root_templates '/' prefixt 'varlist.csv']; % read list of var names and units for empty sam template
varfileout = [root_templates '/' prefixt 'varlist_out.csv']; % write list of var names and units for empty sam template
otfile = [root_ctd '/' prefix1 stn_string];

dataname = [prefix1 stn_string];

num_bottles = 1;

cellall = mtextdload(varfile,','); % load all text

clear snames sunits
for kline = 1:length(cellall)
    cellrow = cellall{kline}; % unpack rows
    snames{kline} = m_remove_outside_spaces(cellrow{1});
    sunits{kline} = m_remove_outside_spaces(cellrow{2});
end
snames = snames(:);
sunits = sunits(:);
numvar = length(snames);

fidmsam01 = fopen(varfileout,'w'); % save back to out file
for k = 1:numvar
    fprintf(fidmsam01,'%s%s%s\n',snames{k},',',sunits{k});
end
fclose(fidmsam01);

null = nan+zeros(num_bottles,1);
for k = 1:numvar
    cmd = [snames{k} ' = null;']; eval(cmd);
end

checknames = {'statnum'};
checkunits = {'number'};
% ensure at least these three names exist in the list
for k = 1:length(checknames)
    cname = checknames{k};
    kmatch = strmatch(cname,snames,'exact');
    if isempty(kmatch)
        snames = [cname; snames(:)];
        sunits = [checkunits{k}; sunits(:)];
    end
end
    
position = [1:num_bottles]';
statnum = stnlocal+0*position;

snames_units = {};
for k = 1:length(snames)
    snames_units = [snames_units; snames(k)];
    snames_units = [snames_units; {'/'}];
    snames_units = [snames_units; sunits(k)];
end

timestring = ['[' sprintf('%d %d %d %d %d %d',MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN) ']'];
 
%--------------------------------
% 2009-01-26 16:40:45
% msave
% input files
% Filename    Data Name :   <version>  <site> 
% output files
% Filename sam_jr193_016.nc   Data Name :  sam_jr193_016 <version> 17 <site> bak_macbook
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
%--------------------------------

