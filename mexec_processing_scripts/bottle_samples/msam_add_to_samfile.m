function msam_add_to_samfile(paramtyp)
%
% msam_add_to_samfile(param)
%
% load sample (Niskin bottle or SBE35) data from specific type of file
% (e.g. sal, nut, oxy), convert (e.g. to umol/kg) and average replicates as
% necessary, paste into combined sam_mcruise_all.nc file
%
% which variables to use and conversions to apply are specified by
% switch-case on paramtype, below, can can be modified in the opt_cruise
% file 
%
% called by msal_01, moxy_01, mnut_01, msam_other, msam_ashore_flag

m_common
if MEXEC_G.quiet<1; fprintf(1, 'loading bottle %s from %s_%s_01.nc, writing to sam_%s_all.nc',mcruise,mcruise); end
samfile = fullfile(mgetdir('M_CTD'), ['sam_' mcruise '_all.nc']);

%defaults
dataname = [paramtyp '_' mcruise '_01'];
paramfile = fullfile(mgetdir(['bot_' paramtyp]),[dataname '.nc']); %input file
svars = {'sampnum','niskin_flag'}; %variables to load from sample file
varrename = {}; %don't rename, keep all input variables. if set, varrename is applied before any conversions.
convs.replavg = 0; %no conversions

%modify defaults
%convs applied in subfunction add_samdata include umol_per_l_to_per_kg and
%replavg
switch paramtyp
    case 'chl'
        convs.replavg = 1; %do average replicates
        hnew.comment = ['chlorophyll data from ' dataname '.nc'];
    case 'oxy'
        %varrename
        svars = [svars, 'uasal'];
        convs.umol_per_l_to_per_kg.temp = 'botoxya_temp'; %convert using oxygen draw temperature from the first sample ***used to use temperature from each sample, if available***difference should be extremely small
        convs.replavg = 1; %do average replicates
        opt1 = 'samp_proc'; opt2 = 'oxy_to_sam'; get_cropt %could set to not avg, or could set to not convert units if they were already reported in /kg
        hnew.comment = ['oxygen data from ' dataname '.nc'];
        %losing backwards compatibility to make an appended oxy file
        %first***
    case 'nut'
        svars = [svars, 'uasal'];
        convs.umol_per_l_to_per_kg.temp = 20; %convert using default lab temperature***
        convs.replavg = 1; %do average replicates
        opt1 = 'samp_proc'; opt2 = 'nut_to_sam'; get_cropt %could set to not avg, or change the lab temp***
        hnew.comment = ['nutrient data from ' dataname '.nc']; %***overwrite comment or add comment?
    case 'sal'
        varrename = {'botpsal', {'salinity_adj','salinity'};...
            'botpsal_flag', {'flag'}};
        hnew.comment = ['salinity data from ' dataname '.nc'];
    case 'sbe35'
        paramfile = fullfile(mgetdir('M_SBE35'), dataname);
        varrename = {'sbe35temp'; 'sbe35temp_flag'}; %list which to copy because we don't need to copy tdiff etc.
        hnew.comment = ['SBE35 data from ' dataname '.nc'];
    case 'iso'
        %***just default?
    otherwise
end

%load data
[dp, hp] = mloadq(paramfile, '/');
dp = struct2table(dp);
if isempty(varrename)
    %all data/flag variables
    varrename = setdiff(hp.fldnam, {'sampnum', 'statnum', 'position'})';
end
[ds,hs] = mloadq(samfile, strjoin(svars, ' ')); %***
ds = struct2table(ds);
%match on sampnum
[~,isam,iparam] = intersect(ds.sampnum,dp.sampnum,'stable');
es = length(unique(dp.sampnum))-length(iparam);
if es
    warning('%d %s samples have no sampnum in %s, will be ignored',es,paramtyp,samfile)
end

%add data from d to ds, converting as necessary
hnew.fldunt = hs.fldunt(ismember(hs.fldnam,svars)); hnew.fldnam = hs.fldnam(ismember(hs.fldnam,svars));
[ds, hnew] = add_samdata(ds, hnew, isam, svars, dp, hp, iparam, varrename, convs);

%***eventually put msam_ashore_flag here to just read in sample collection
%flag data from logs?

%apply niskin flags (and also confirm consistency between sample and
%flag)
ds = table2struct(ds,'ToScalar',true);
ds = hdata_flagnan(ds, 'keepemptyvars', 1);
fn = fieldnames(ds);
fne = fn(cellfun(@(x) contains(x,'_inst_flag'),fn));
ds = rmfield(ds,fne);
%don't need to rewrite fields that we loaded from samfile originally
%(except sampnum)
svars = setdiff(svars,{'sampnum'});
ds = rmfield(ds,svars);
hnew.fldunt(ismember(hnew.fldnam,svars)) = []; hnew.fldnam(ismember(hnew.fldnam,svars)) = [];

%save
mfsave(samfile, ds, hnew, '-merge', 'sampnum');


function [ds, hnew] = add_samdata(ds, hnew, isam, svars, dp, hp, iparam, varrename, convs)

%rename variables while adding to ds
for no = 1:size(varrename,1)
    nn = varrename{no,1};
    if size(varrename,2)>1
        [~,~,ii] = intersect(varrename{no,2},hp.fldnam,'stable');
    else
        ii = find(strcmp(nn,hp.fldnam));
    end
    if isempty(ii)
        warning('match for %s not found, skipping',varrename{no,1})
    else
        on = hp.fldnam{ii(1)};
        if contains(nn,'_flag')
            ds.(nn) = 9+zeros(size(ds.sampnum));
            ds.(nn)(isam) = dp.(on)(iparam);
            un = 'woce_4.9';
        else
            ds.(nn) = NaN+ds.sampnum;
            ds.(nn)(isam) = dp.(on)(iparam);
            un = hp.fldunt{ii(1)};
        end
        hnew.fldnam = [hnew.fldnam nn];
        hnew.fldunt = [hnew.fldunt un];
    end
end

%conversions
convn = fieldnames(convs);
for cno = 1:length(convn)
    switch convn{cno}

        case 'umol_per_l_to_per_kg'
            %use CTD salinity, but temperature to use depends on parameter
            temp = convs.(convn{cno});
            if isnumeric(temp)
                if isscalar(temp) %e.g., constant lab temp (approx)
                    ds.ctemp = repmat(temp,size(ds.sampnum));
                    temp = [num2str(temp) 'C'];
                elseif numel(temp)==numel(ds.sampnum) %varying temperature (must already be interpolated to samfile***)
                    ds.ctemp = temp;
                    temp = 'temperature specified in opt_cruise';
                else
                    error('convs.umol_per_l_to_per_kg.temp must be string, scalar, or match size of ds.sampnum')
                end
            else
                ds.ctemp = ds.(temp); %e.g. botoxya_temp
            end
            dens = gsw_rho(ds.uasal, gsw_CT_from_t(ds.uasal, ds.ctemp, 0), 0);
            %convert all variables whose units are umol_per_l
            m = strcmp('umol_per_l',hnew.fldunt);
            ds(:,m) = ds(:,m)./(repmat(dens,1,sum(m))/1000);
            %change units
            hnew.fldunt(m) = {'umol_per_kg'};
            %if variable names also contained _per_l, change them
            hnew.fldnam(m) = cellfun(@(x) replace(x,'_per_l',''), hnew.fldnam(m), 'UniformOutput', false); %***
            hnew.comment = [hnew.comment ', converted from umol/l to umol/kg using ' c.temp ' and CTD salinity'];

        case 'replavg'
            if convs.(convn{cno})
                %find data parameters
                isflag = cellfun(@(x) contains(x,'_flag'), hnew.fldnam);
                %***do special things for botoxytemp (just report
                %botoxya_temp)
                vnames = unique(cellfun(@(x) x(1:end-1), setdiff(hnew.fldnam(~isflag), svars), 'UniformOutput', false));
                %and loop through them to average
                keyboard %***chla_ins ets.
                for nno = 1:length(vnames)
                    vname = vnames{nno};
                    m = strncmp(vname,hnew.fldnam,length(vname));
                    mv = m & ~isflag;
                    mf = m & isflag;
                    un = unique(hnew.fldunt(mv));
                    %is there more than one column that starts with vname? with matching flags?
                    if sum(mv)>1 && sum(mf)==sum(mv)
                        %do all columns starting with vname have the same units?                        %the same?
                        if isscalar(un)
                            vunit = un{1};
                        else
                            warning('different units for %s',vname)
                            keyboard
                        end
                        data = ds(:,mv);
                        flag = ds(:,mf);
                        rnames = hnew.fldnam(mv);  %***check these end in a,b,c?
                        rfnames = hnew.fldnam(mf);
                        %find best flag
                        flagav = min(flag,[],2);
                        %mask values worse than best flag, and average
                        data(flag~=flagav) = NaN;
                        dataav = mean(data,2,'omitnan',true);
                        %where two or more points were averaged, set flag to 6,
                        %unless both were flagged bad (4)***what about
                        %questionable (3)?
                        numav = sum(flag==flagav,2);
                        flagav(numav>1 & flagav<4) = 6;
                        %add new fields
                        ds.(vname) = dataav;
                        ds.(fname) = flagav;
                        hnew.fldnam = [hnew.fldnam vname fname];
                        hnew.fldunt = [hnew.fldunt vunit 'woce_4.9'];
                        if sum(flagav==6)
                            hnew.comment = [hnew.comment ', ' vname ' average of replicates (' strjoin(rname,',') ')'];
                        end
                        %remove replicate fields
                        m = ismember(hnew.fldnam,[rnames rfnames]);
                        ds(:,m) = []; hnew.fldnam(m) = []; hnew.fldunt(m) = [];
                    end
                end
            end

    end
end
