function uopts = mday_01_default_autoedits(h, streamtype)
%%%%% default range limits and despiking settings %%%%%
% uopts = mday_01_default_autoedits(h)
% 
% define by variable type and apply to variable names in each category
% actually found in h
% 

uopts = struct();

%set range limits by variable type
uvar.head = [0 360];
uvar.pitch = [-5 5];
uvar.roll = [-7 7];
uvar.lon = [-181 181];
uvar.lat = [-91 91];
uvar.airtemp = [-50 50];
uvar.humid = [0.1 110];
uvar.rwindd = [-0.1 360.1];
uvar.twindd = [-0.1 360.1];
uvar.rwinds = [-0.001 200];
uvar.twinds = [-0.001 200];
uvar.airpres = [0.01 1500];
uvar.ppar = [-10 1500];
uvar.ptir = uvar.ppar;
uvar.spar = uvar.ppar;
uvar.stir = uvar.ppar;
uvar.sst = [-2 50];
uvar.temp = uvar.sst;
uvar.cond = [0 10];
uvar.trans = [0 105];
uvar.dep = [20 1e4];
uvar.depsref = uvar.dep;
uvar.deptref = uvar.dep;
%now assign them to all variables in category in this file
fn = fieldnames(uvar);
for pno = 1:length(fn)
    n = munderway_varname([fn{pno} 'var'], h.fldnam, 's');
    for nno = 1:length(n)
        uopts.rangelim.(n{nno}) = uvar.(fn{pno});
    end
end

%despike bathymetry
n = munderway_varname('depvar', h.fldnam, 's');
n = union(n, munderway_varname('depsrefvar', h.fldnam, 's'));
n = union(n, munderway_varname('deptrefvar', h.fldnam, 's'));
for nno = 1:length(n)
    uopts.despike.(n{nno}) = [10 5 3]; %m
end

