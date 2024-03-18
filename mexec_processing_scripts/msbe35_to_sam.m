% msbe35_to_sam: read in sbe35 temperature data from sbe35_cruise_01.nc,
% save to sam_cruise_all.nc
%

m_common
if MEXEC_G.quiet<=1; fprintf(1, 'writing sbe35 data to sam_%s_all.nc\n',mcruise,mcruise); end

dataname = ['sbe35_' mcruise '_01'];
infile = fullfile(mgetdir('M_SBE35'), dataname);
otfile2 = fullfile(mgetdir('M_CTD'), ['sam_' mcruise '_all']);
[ds,hnew] = mloadq(infile,'/');
vars = {'sampnum'; 'sbe35temp'; 'sbe35temp_flag'};
[~,ii] = setdiff(hnew.fldnam,vars);
ds = rmfield(ds,hnew.fldnam(ii)); hnew.fldnam(ii) = []; hnew.fldunt(ii) = [];

%exclude sbe35 data not corresponding to real niskins (as set in mfir_01 cruise options)
[dsam,hsam] = mloadq(otfile2,'sampnum');
m = ismember(ds.sampnum,dsam.sampnum);
if sum(m)<length(ds.sampnum)
    warning('excluding %d sbe35 samples; see mfir_01 cruise options for list of niskins on carousel',length(setdiff(ds.sampnum,dsam.sampnum)))
    for fno = 1:length(hnew.fldnam)
        ds.(hnew.fldnam{fno}) = ds.(hnew.fldnam{fno})(m);
    end
end

%save
hnew = rmfield(hnew, 'dataname');
hnew.comment = ['SBE35 data from sbe35_' mcruise '_01.nc'];
MEXEC_A.Mprog = mfilename;
mfsave(otfile2, ds, hnew, '-merge', 'sampnum');
