% mnut_to_sam: read in bottle nut data from nut_cruise_01.nc, convert from 
% umol/L to umol/kg, average replicates***, save to sam_cruise_all.nc
%

% load from nut file(s), load sam sal for converting to /kg
root_nut = mgetdir('bot_nut');
nutfile = fullfile(root_nut,['nut_' mcruise '_01.nc']);
[d,h] = mloadq(nutfile, '/');

samfile = fullfile(mgetdir('M_CTD'), ['sam_' mcruise '_all.nc']);
[ds,hs] = mloadq(samfile,'sampnum','niskin_flag','uasal',' ');

[~,iis,iio] = intersect(ds.sampnum,d.sampnum);
clear hnew
hnew.fldnam = {'sampnum'};
hnew.fldunt = {'number'};

%average replicates?
use_nut_repl = 0;
%opt1 = mfilename; opt2 = 'use_nut_repl'; get_cropt
labtemp = 21+zeros(size(d.sampnum)); %***

%convert to umol/kg
dens = gsw_rho(ds.uasal(iis),gsw_CT_from_t(ds.uasal(iis),labtemp(iio),0),0);
fn = setdiff(h.fldnam,{'sampnum' 'statnum' 'position'});
for no = 1:length(fn)
    if ~contains(fn{no},'_flag')
        newname = fn{no}(1:end-6);
        ds.(newname) = NaN+zeros(size(ds.sampnum));
        ds.(newname)(iis) = d.(fn{no})(iio)./(dens/1000);
        hnew.fldnam = [hnew.fldnam newname];
        hnew.fldunt = [hnew.fldunt 'umol/kg'];
    else
        ds.(fn{no}) = 9+zeros(size(ds.sampnum));
        ds.(fn{no})(iis) = d.(fn{no})(iio);
        hnew.fldnam = [hnew.fldnam fn{no}];
        hnew.fldunt = [hnew.fldunt 'woce_9.4'];
    end
end

hnew.comment = [h.comment ' converted to umol/kg using CTD salinity (uasal) and lab temperature 21\n ']; %***

%apply niskin flags (and also confirm consistency between sample and flag)
ds = hdata_flagnan(ds, 'keepempty', 1);
%just keep the fields set above (don't need to keep niskin_flag etc. here)
fn = fieldnames(ds);
[~, ia, ib] = intersect(fn, hnew.fldnam, 'stable');
if length(ia)<length(fn)
    ds = rmfield(ds, fn(setdiff(1:length(fn),ia)));
end
hnew.fldnam = hnew.fldnam(ib); hnew.fldunt = hnew.fldunt(ib);

%save
mfsave(samfile, ds, hnew, '-merge', 'sampnum');
