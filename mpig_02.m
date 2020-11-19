% mpig_02: paste pig data into sam file

scriptname = 'mpig_02';
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

if ~exist('stn','var')
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
stnlocal = stn; clear stn % so that it doesn't persist

mdocshow(scriptname, ['pastes bottle pigment data from pig_' mcruise '_' stn_string '.nc to sam_' mcruise '_' stn_string '.nc']);

root_pig = mgetdir('M_BOT_PIG');
root_ctd = mgetdir('M_CTD');
prefix1 = ['pig_' mcruise '_'];
prefix2 = ['sam_' mcruise '_'];
infile1 = [root_pig '/' prefix1 stn_string];
otfile2 = [root_ctd '/' prefix2 stn_string];

if ~exist(m_add_nc(infile1), 'file')
    mess = ['file ' m_add_nc(infile1) ' not found']; % bak on jc069 exit if file not in the right place
    fprintf(MEXEC_A.Mfider,'%s\n',mess);
    return
end

%--------------------------------
% 2009-03-13 17:06:01
% mpaste
% input files
% Filename pig_jc191_003.nc   Data Name :  pig_jc191_003 <version> 1 <site> jc191
% output files
% Filename sam_jc191_003.nc   Data Name :  sam_jc191_003 <version> 10 <site> jc191
MEXEC_A.MARGS_IN = {
otfile2
infile1
'y'
'sampnum'
'sampnum'
'chla chla_flag pheoa pheoa_flag'
'chla chla_flag pheoa pheoa_flag'
};
mpaste
