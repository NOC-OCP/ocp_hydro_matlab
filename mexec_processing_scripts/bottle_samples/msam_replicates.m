function [dnew, hnew] = msam_replicates(ds, samtyp)
% [dnew, hnew] = msam_replicates(ds, samtyp)
%
% ds is a structure or table including columns sampnum, (tabdatavar), and
% flag 
%
% for each tabdatavar, adds units, separates and renames replicates, makes
% flags consistent, and puts into a structure and header suitable for
% writing to mstar-format .nc files 
%

if isstruct(ds)
    ds = struct2table(ds);
end

%masks for different types of fields (only want to look for main sample
%data)
names0 = ds.Properties.VariableNames;
m1 = ismember(names0,{'sampnum'}); %everything in ~m1 will be replicated
mf = ~m1 & cellfun(@(x) contains(x,'_flag'),names0);
if sum(mf); ds.Properties.VariableUnits(mf) = {'woce_4.9'}; end
if strcmp(samtyp, 'oxy')
    mt = ~m1 & ~mf & cellfun(@(x) contains(x, '_temp'), names0); %only for botoxy_temp
    if sum(mt); ds.Properties.VariableUnits(mt) = {'degC'}; end
else
    mt = false(size(names0));
end
mi = ~m1 & ~mf & cellfun(@(x) contains(x, '_inst'), names0);
mv = ~m1 & ~mf & ~mt & ~mi; %"normal" variables

%replace NaN flags with 9
dat = ds{:,mf}; dat(isnan(dat)) = 9; ds{:,mf} = dat;

%turn names of different analysing instruments into numbers
for no = find(mi)
    gi = findgroups(ds.(names0{no}));
    gis = groupsummary(ds,names0{no});
    ds.(names0{no}) = gi;
    ds.Properties.VariableUnits{no} = strjoin(gis.(names0{no}),' / ');
end

%fill missing sampnums with unique values (so as not to group)
m = ~isfinite(ds.sampnum);
ds.sampnum(m) = [0:sum(m)-1]-1e10; %these sampnums aren't used for anything even TSG times

%separate out replicates
names0 = ds.Properties.VariableNames;
gs = groupsummary(ds,"sampnum");
mr = max(gs.GroupCount);
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

%for output
hnew.fldnam = ds.Properties.VariableNames;
hnew.fldunt = ds.Properties.VariableUnits;
dnew = table2struct(gs,'ToScalar',true);
