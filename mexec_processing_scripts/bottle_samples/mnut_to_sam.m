function mnut_to_sam
% mnut_to_sam: read in bottle nut data from nut_cruise_01.nc, convert from 
% umol/L to umol/kg, average replicates***, save to sam_cruise_all.nc
%

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

% load from nut file(s), load sam sal for converting to /kg
root_nut = mgetdir('bot_nut');
nutfile = fullfile(root_nut,['nut_' mcruise '_01.nc']);
[d,h] = mloadq(nutfile, '/');

samfile = fullfile(mgetdir('M_CTD'), ['sam_' mcruise '_all.nc']);
[ds,~] = mload(samfile,'sampnum','niskin_flag','uasal',' ');

[~,iin,iis] = intersect(d.sampnum,ds.sampnum,'stable');
ds = struct2table(ds);
ds = table2struct(ds(iis,:),'ToScalar',true);
clear hnew
hnew.fldnam = {'sampnum'};
hnew.fldunt = {'number'};

%average replicates?
use_nut_repl = 0;
%opt1 = mfilename; opt2 = 'use_nut_repl'; get_cropt
labtemp = 20+zeros(size(d.sampnum)); %***

%convert to umol/kg
dens = gsw_rho(ds.uasal,gsw_CT_from_t(ds.uasal,labtemp(iin),0),0);
fn = setdiff(h.fldnam,{'sampnum' 'statnum' 'position'});
for no = 1:length(fn)
    if ~contains(fn{no},'_flag')
        newname = fn{no}(1:end-6);
        ds.(newname) = NaN+zeros(size(ds.sampnum));
        ds.(newname) = d.(fn{no})(iin)./(dens/1000);
        hnew.fldnam = [hnew.fldnam newname];
        hnew.fldunt = [hnew.fldunt 'umol/kg'];
    else
        ds.(fn{no}) = 9+zeros(size(ds.sampnum));
        ds.(fn{no})= d.(fn{no})(iin);
        hnew.fldnam = [hnew.fldnam fn{no}];
        hnew.fldunt = [hnew.fldunt 'woce_9.4'];
    end
end

hnew.comment = [h.comment sprintf(' converted to umol/kg using CTD salinity (uasal) and lab temperature %d\n ',m_nanmean(labtemp))];

%apply niskin flags (and also confirm consistency between sample and flag)
ds = hdata_flagnan(ds, 'keepempty', 1, 'nisk_badflags', [4 9]); %***change this back!
%just keep the fields set above (don't need to keep niskin_flag etc. here)
fn = fieldnames(ds);
[~, ia, ib] = intersect(fn, hnew.fldnam, 'stable');
if length(ia)<length(fn)
    ds = rmfield(ds, fn(setdiff(1:length(fn),ia)));
end
hnew.fldnam = hnew.fldnam(ib); hnew.fldunt = hnew.fldunt(ib);

%save
mfsave(samfile, ds, hnew, '-merge', 'sampnum');
