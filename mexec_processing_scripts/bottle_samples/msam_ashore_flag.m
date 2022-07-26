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
%sets vars, sampnums, flagvals, flagvars

%get sampnums to merge on, and niskin_flag
root_sam = mgetdir('M_CTD');
samfile = fullfile(root_sam, ['sam_' mcruise '_all']);
[ds,hs] = mloadq(samfile,'sampnum','niskin_flag',' ');

clear hnew
hnew.fldnam = {'sampnum'};
hnew.fldunt = {'number'};

%fill in flag values for sets of sampnums for each variable
vars = fieldnames(shore_sams);
for nno = 1:length(vars)
    if do_empty_vars && 
        hnew.fldnam = [hnew.fldnam vars{nno}];
        hnew.fldunt = [hnew.fldunt shore_sams.(vars{nno}).unit];
        if ~isfield(ds,vars{nno})
            ds.(vars{nno}) = NaN+zeros(size(ds.sampnum));
        end
    end
    flagname = [vars{nno} '_flag'];
    hnew.fldnam = [hnew.fldnam flagname];
    hnew.fldunt = [hnew.fldunt 'woce_table_4.8'];
    if ~isfield(ds,flagname)
        ds.(flagname) = 9+zeros(size(ds.sampnum));
    end
    for fno = 1:length(flagvals)
        snum = sampnums{nno,fno}; snum = snum(:);
        [~,iis,iio] = intersect(ds.sampnum,snum);
        ds.(flagname)(iis) = flagvals(fno);
    end
    ds.(flagname)(ds.niskin_flag==4) = max(5,ds.(flagname)(ds.niskin_flag==4));
    ds.(flagname)(ds.niskin_flag==9) = 9;
end

%save
ds = rmfield(ds, {'niskin_flag'}); %don't need to rewrite these to file
ii = strfind(fnin, mgetdir('M_BOT_ISO')); if isempty(ii); ii = -1; end
hnew.comment = ['flags for shore-analysed samples set based on ' fnin(ii(end)+2:end)];
MEXEC_A.Mprog = mfilename;
mfsave(samfile, ds, hnew, '-merge', 'sampnum');
