% msam_ashore_flag
% 
% set samtype (string) before calling
%
% add list(s) of samples drawn for shoreside analysis to sam_cruise_all.nc
% from one or more files
% use opt_cruise to specify which fields to look for in which file(s),
% based on samtype

mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

if ~exist('samtype', 'var')
    samtype = input('sample type? ','s');
end
scriptname = mfilename; oopt = ['sam_ashore_' samtype]; get_cropt 

root_sam = mgetdir('M_CTD');

samfile = [root_sam '/sam_' mcruise '_all'];
[d,h] = mloadq(samfile,'/');
iibb = find(d.niskin_flag==4);

clear dnew hnew
hnew.fldnam = {'sampnum'}; hnew.fldunt = {'number'};
dnew.sampnum = d.sampnum;
for nno = 1:length(varnames)
    flagname = [varnames{nno} '_flag'];
    hnew.fldnam = [hnew.fldnam flagname];
    hnew.fldunt = [hnew.fldunt 'woce_table_4.8'];
    if ~isfield(d,flagname)
        dnew.(flagname) = 9+zeros(size(d.sampnum));
    else
        dnew.(flagname) = d.(flagname);
    end
    for fno = 1:length(flagvals)
       snum = sampnums{nno,fno}; snum = snum(:);
       [c,ia,ib] = intersect(snum,d.sampnum);
       dnew.(flagname)(ib) = flagvals(fno);
    end
    dnew.(flagname)(iibb) = max(5,dnew.(flagname)(iibb)); %if niskin was bad, not analysed, presumably
    dnew.(flagname)(d.niskin_flag==9) = 9;
end

ii = strfind(fnin, mgetdir('M_BOT_ISO')); if isempty(ii); ii = -1; end
hnew.comment = ['flags for shore-analysed samples set based on ' fnin(ii(end)+2:end)];
MEXEC_A.Mprog = mfilename;
mfsave(samfile, dnew, hnew, '-merge', 'sampnum');

