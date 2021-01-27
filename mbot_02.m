% mbot_02: paste niskin bottle data into sam file

minit; scriptname = mfilename;
mdocshow(scriptname, ['paste Niskin bottle data into sam_' mcruise '_' stn_string '.nc']);

root_ctd = mgetdir('M_CTD');
prefix1 = ['bot_' mcruise '_'];
prefix2 = ['sam_' mcruise '_'];
infile1 = [root_ctd '/' prefix1 stn_string];
otfile2 = [root_ctd '/' prefix2 stn_string];

if exist(m_add_nc(infile1),'file') ~= 2
    % skip if no input file
    return
end

MEXEC_A.MARGS_IN = {
otfile2
infile1
'y'
'sampnum'
'sampnum'
'bottle_number bottle_qc_flag'
'bottle_number bottle_qc_flag'
};
mpaste
