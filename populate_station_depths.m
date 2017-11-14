% Prepare a mat file with station depths for use in mdep_01
% bak on jr281 April 2013
%
% depths should be in corrected metres.
% Best depths are from LADCP data that have been merged with CTD,
% and LADCP determines water depth in metres from height off combined with
% CTD data
%
% populate a file called 'station_depths_jr281.mat' with a single
% array of depths, one per station number. Missing stations have a NaN as a
% placeholder
% 
% presently outputs depths for stations up to number 999.
%
% any gaps can be set manually, or by any other method, in the
% cruise-specific branches.
%
% input file example name is 
% jr281_stn_depth.txt
% contains depths from LADCP provided by Xingfeng Liang

scriptname = 'populate_station_depths';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
oopt = '';

root_ctddep = mgetdir('M_CTD_DEP');
oopt = 'fnin'; get_cropt

nout = 999;
bestdeps = nan+ones(nout,1);
for ks = 1:nout
    kin = find(stns == ks);
    if isempty(kin)
        bestdeps(ks) = nan;
    else
        bestdeps(ks) = deps(kin);
    end
end

oopt = 'bestdeps'; get_cropt

cmd = ['save ' prefix0 '/' fnot ' bestdeps']; eval(cmd)
