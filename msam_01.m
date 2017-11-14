% msam_01: create empty sam file
%
% Use: msam_01        and then respond with station number, or for station 16
%      stn = 16; msam_01;
%
% The input list of variable names, example filename sam_jr193_varlist.csv
%    is a comma-delimeted list of vars and units to be created
%    The format of each line is
%    varname,newunits,default_value
% The set of names is parsed and written back to ctd_jr193_varlist_out.csv
% The set of names can be prepared in any unix text editor.
% It can also be prepared in excel and saved as csv, but on BAK's
% mac this generates csv files with c/r instead of n/l. Thus the
% _out.csv file is more suitable for editing on unix.
%
% bak on jr302: add a default value to the template, so water sample flags
% start as a default of 9 instead of nan.

scriptname = 'msam_01';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

if ~exist('stn','var')
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
stnlocal = stn; clear stn % so that it doesn't persist

mdocshow(scriptname, ['creating empty sam_' cruise '_' stn_string '.nc based on templates/sam_cruise_varlist.csv']);

% resolve root directories for various file types
root_templates = mgetdir('M_TEMPLATES');
root_sam = mgetdir('M_SAM');

prefix1 = ['sam_' cruise '_'];

varfile = [root_templates '/' prefix1 'varlist.csv']; % read list of var names and units for empty sam template
varfileout = [root_templates '/' prefix1 'varlist_out.csv']; % write list of var names and units for empty sam template
otfile = [root_sam '/' prefix1 stn_string];

dataname = [prefix1 stn_string];

num_bottles = 24;

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
for k = 1:numvar
    cmd = [snames{k} ' = ' sdef{k} ' + z;']; eval(cmd); % sdef is nan or value
end

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
    
position = [1:num_bottles]';
sampnum = stnlocal*100+position;
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

