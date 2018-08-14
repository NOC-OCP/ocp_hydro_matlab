% msam_updateall: update the sam_xxxxx_all file with a new sam file from a
% station. This saves re-appending the whole sam set.
%
% Use: msam_updateall        and then respond with station number, or for station 16
%      stn = 16; msam_updateall;
%
% first edits the station sam file to make all analysis value flags bad where niskin flag is bad***

scriptname = 'msam_updateall';
minit
mdocshow(scriptname, ['updates sam_' mcruise '_' stn_string '.nc rows in sam_' mcruise '_all.nc']);

root_ctd = mgetdir('M_CTD');
prefix1 = ['sam_' mcruise '_'];
infile1 = [root_ctd '/' prefix1 stn_string];
otfile1 = [root_ctd '/' prefix1 'all'];

if exist(m_add_nc(infile1),'file') ~= 2
    % skip this station
    msg = ['input file ' infile1 ' not found: skipping'];
    fprintf(MEXEC_A.Mfider,'%s\n',msg);
    return
end


%--------------------------------
MEXEC_A.MARGS_IN = {
otfile1
infile1
'y'
'sampnum'
'sampnum'
'/'
'/'
};
mpaste
%--------------------------------
