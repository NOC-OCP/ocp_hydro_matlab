% msam_addnewvars
%
% add new variables from sam_jc191_template to the existing sam files.
%
% steps
%
% 1) edit the template file sam_varlist.csv
%
% 2) run msam_01 for an unused station number; This will create a new
%   sam_ccccc_template.nc file. 
%
% 3) Edit the variable numbers below to select ones to copy from the old
% sam files and ones to copy from the new template. 
% 
% this could probably go in a cruise opt.
%
% At present, the output goes to samx_ccccc_nnn. When all sam files have been fixed, the
% samx_cccc_nnn can be renamed to sam_cccc_nnn and a new sam_all made.
%
% It would have been better to create a directory called eg sam_working, move the
% exisitng sam files there, and use this script to create a new file in the
% usual place and name. This would avoid renaming files afterwards.
%

scriptname = 'msam_addnewvars';
minit
mdocshow(scriptname, ['adds new variables to sam_' mcruise '_' stn_string '.nc']);

% resolve root directories for various file types
root_ctd = mgetdir('M_CTD');

% load
prefix1 = ['sam_' mcruise '_'];
prefix2 = ['samx_' mcruise '_'];
prefix3 = ['sam_' mcruise '_'];
infile1 = [root_ctd '/' prefix1 stn_string];
otfile2 = [root_ctd '/' prefix2 stn_string];
infile3 = [root_ctd '/' prefix3 'template'];
clear stn % so that it doesn't persist



%--------------------------------
% 2020-02-14 07:54:11
% maddvars
% calling history, most recent first
%    maddvars in file: maddvars.m line: 130
%    msam_addnewvars in file: msam_addnewvars.m line: 58
% input files
% Filename /local/users/pstar/jc191/mcruise/data/ctd/sam_jc191_100.nc   Data Name :  sam_jc191_100 <version> 3 <site> jc191_atsea
% Filename /local/users/pstar/jc191/mcruise/data/ctd/sam_jc191_template.nc   Data Name :  sam_jc191_101 <version> 2 <site> jc191_atsea
% output files
% Filename /local/users/pstar/jc191/mcruise/data/ctd/samx_jc191_100.nc   Data Name :  sam_jc191_100 <version> 5 <site> jc191_atsea
MEXEC_A.MARGS_IN = {
infile1
otfile2
'1~65'
infile3
'66~77'
};
maddvars
%--------------------------------