function gs = msam_replicates(ds, samtyp)
% gs = msam_replicates(ds, samtyp)
%
% ds is a structure or table including columns sampnum, (tabdatavar), and
% flag 
%
% for each tabdatavar, adds units, separates and renames replicates, makes
% flags consistent, and outputs in table gs
%

if isstruct(ds)
    ds = struct2table(ds);
end

%masks for different types of fields (only want to look for main sample
%data)
names0 = ds.Properties.VariableNames;
m1 = ismember(names0,{'sampnum'}); %everything in ~m1 will be replicated where sampnum is repeated, and given alphabetic suffixes
mf = ~m1 & cellfun(@(x) contains(x,'_flag'),names0);
if strcmp(samtyp, 'oxy')
    mt = ~m1 & ~mf & cellfun(@(x) contains(x, '_temp'), names0); %only for botoxy_temp
else
    mt = false(size(names0));
end
mi = ~m1 & ~mf & cellfun(@(x) contains(x, '_inst'), names0);
mv = ~m1 & ~mf & ~mt & ~mi; %"normal" variables

%turn names of different analysing instruments into numbers***why?
for no = find(mi)
    gi = findgroups(ds.(names0{no}));
    gis = groupsummary(ds,names0{no});
    ds.(names0{no}) = gi;
    ds.Properties.VariableUnits{no} = strjoin(gis.(names0{no}),' / ');
end

%fill missing sampnums with unique values (so as not to group)
m = ~isfinite(ds.sampnum);
ds.sampnum(m) = [0:sum(m)-1]-1e10; %these sampnums aren't used for anything even TSG times

%compute mean and stdev of replicates
gm = groupsummary(ds,"sampnum","mean");
mr = max(gm.GroupCount);
gs = groupsummary(ds,"sampnum","std");

%separate out replicates
names0 = ds.Properties.VariableNames;
g = findgroups(ds.sampnum);
alph = 'abcdefghijklmnopqrstuvwxyz'; alph = [alph;repmat(' ',1,length(alph))];
alph = alph(:)'; alph = strsplit(alph);
alph = alph(1:mr);
for no = find(~m1)
    nc = size(gs,2);
    varn = names0{no};
    %padded array for each sampnum
    a = splitapply(@(x) [x(:)' nan(1,mr-length(x))], ds.(varn), g);
    %append to table gs
    gs = [gs array2table(a)];
    if mv(no)
        %names with letter suffixes
        gs.Properties.VariableNames(nc+1:end) = cellfun(@(x) [varn x],alph,'UniformOutput',false);
    elseif mf(no) || mt(no) || mi(no)
        %letters go in the middle, before _flag (or _temp, if relevant)
        ii = strfind(varn,'_'); ii = ii(end);
        gs.Properties.VariableNames(nc+1:end) = cellfun(@(x) [varn(1:ii-1) x varn(ii:end)],alph,'UniformOutput',false);
    end
    %copy units
    gs.Properties.VariableUnits(nc+1:end) = ds.Properties.VariableUnits(strcmp(varn,names0));
end
gs.GroupCount = [];
%recalculate statnum and position
gs.statnum = floor(gs.sampnum/100);
gs.position = gs.sampnum-gs.statnum*100;
gs.Properties.VariableUnits(end-1:end) = {'number','on.rosette'};

%add existing flags from editlogs***
opt1 = 'samp_proc'; opt2 = 'flag'; get_cropt %apply flags if specified in opt_cruise
