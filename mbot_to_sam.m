% mbot_to_sam: paste niskin bottle data into sam_all file
%
% formerly mbot_02

minit;
mdocshow(mfilename, ['paste Niskin bottle data for station ' stn_string ' into sam_' mcruise '_all.nc'])

root_ctd = mgetdir('M_CTD');
root_bot = mgetdir('M_CTD_BOT'); % the bottle file(s) is/are in the ascii files directory
infile = [root_bot '/bot_' mcruise '_' stn_string];
otfile = [root_ctd '/sam_' mcruise '_all'];

if exist(m_add_nc(infile),'file') == 2
    [d,h] = mloadq(infile,'/');
    h.comment = []; % BAK fixing comment problem: Don't pass in this comment string
    if sum(~isnan(d.sampnum))>0
        mfsave(otfile, d, h, '-merge', 'sampnum');
    end
end
