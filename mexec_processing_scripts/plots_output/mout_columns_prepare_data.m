function [d, params] = mout_columns_prepare_data(params, kloop)
% [d, params] = mout_columns_prepare_data(params, kloop)
%
% called by mout_columns to load data and put into table
% 

m_common

% load input file
switch params.in
    case 'ctd'
        stn = params.stnlist{kloop};
        opt1 = 'ctd_proc'; opt2 = 'minit'; get_cropt
        fname = sprintf('%s_%s_%s%s.nc',params.in,mcruise,stn_string,params.suf);
        params.stn_string = stn_string;
    case 'sam'
        fname = sprintf('%s_%s_all.nc',params.in,mcruise);
end
infile = fullfile(params.ddir,fname);
if ~exist(infile,'file')
    warning('skipping %s',fname)
    d = []; return
end
[d, h] = mloadq(infile, '/');

%allow regular or upcast variables, and for backwards compatibility variant
%abbreviations of lat, lon
[timvar, ~, iit] = intersect({'time','utime'},h.fldnam,'stable'); timvar = timvar{1};
[latvar, ~, iim] = intersect({'lat', 'latitude', 'ulatitude'},h.fldnam,'stable'); latvar = latvar{1};
[lonvar, ~, iiz] = intersect({'lon', 'longitude', 'ulongitude'},h.fldnam,'stable'); lonvar = lonvar{1};
[pvar, ~, iip] = intersect({'press','upress'},h.fldnam,'stable'); pvar = pvar{1};
if strcmp(pvar(1),'u'); dvar = 'udepth'; else; dvar = 'depth'; end

%convert time variable and/or units (operate on structures)
if isfield(params, 'datetimeform') && sum(strcmp('datetime',params.vars_units(:,1)))
    %print datestring (1 column)
    d.datetime = datestr(m_commontime(d,timvar,h,'datenum'), params.datetimeform);
    h.fldnam = [h.fldnam 'datetime']; h.fldunt = [h.fldunt params.datetimeform];
elseif isfield(params, 'dateform')
    %print datestring and timestring (2 columns)
    dn = m_commontime(d,timvar,h,'datenum');
    d.date = datestr(dn, params.dateform);
    d.time = datestr(dn, params.timeform);
    h.fldnam = [h.fldnam 'date' 'time']; h.fldunt = [h.fldunt params.dateform params.timeform];
else
    %print time as numeric
    if ~isempty(iit)
        if ~isempty(h.data_time_origin)
            %old mstar format, first convert units to CF
            h.fldunt{iit} = sprintf('%s since %s',datestr(h.data_time_origin),h.fldunt{iit},'yyyy-mm-dd HH:MM:SS');
            h.data_time_origin = [];
        end
        if isfield(params,'time_units')
            %convert to desired time units
            [d.(timvar),h.fldunt{iit}] = m_commontime(d,timvar,h,params.time_units);
        end
    end
    params.time_units = h.fldunt{m};
end
if isfield(params,'varsh') && ~isempty(params.varsh)
    if sum(strcmp('date',params.varsh(:,3))) && (~isfield(h,'date') && (~isfield(params,'extrah') || ~isfield(params.extrah,'date')))
        dn = m_commontime(d.time(d.press==max(d.press)),'time',h,'datenum');
        if ~isfield(params,'dateform'); params.dateform = 'yyyymmdd'; end
        if ~isfield(params,'timeform'); params.timeform = 'HHMM'; end
        h.date = datestr(dn,params.dateform);
        h.time = datestr(dn,params.timeform);
    end
    if sum(strcmp('statnum',params.varsh(:,3))) && strcmp('ctd',params.in)
        h.statnum = params.stnlist(kloop);
    end
end

%now convert to table and carry units in table
d = struct2table(d);
d.Properties.VariableUnits = h.fldunt;

% limit stations if necessary
if strcmp(params.in,'sam')
    if params.stnlist>=0
        % limit stations
        m = ismember(d.statnum,params.stnlist);
        d = d(m,:);
    end
    if sum(~isnan(d.upress))==0
        warning('skipping %s, no good data',fname)
        d = []; return
    end
end

%tile (constant) station positions and depths
varn = d.Properties.VariableNames;
if strcmp(params.out,'exch') && strcmp(params.in,'sam')
    %tile certain variables that should be listed on every line but be constant

    if ~sum(strcmp('stnlat',varn))
        if isempty(iim)
            d.stnlat = NaN+d.statnum; d.stnlon = d.stnlat;
        else
            d.stnlat = d.(latvar); 
            d.stnlon = d.(lonvar);
            d.Properties.VariableUnits(end-1:end) = d.Properties.VariableUnits([iim(1) iiz(1)]);
        end
    end
    if ~sum(strcmp('stndepth',varn))
        if sum(strcmp(dvar,darn))
            d.Properties.VariableUnits{end} = 'm';
        else
            d.stndepth = NaN+d.statnum;
        end
    end

    %check single pos for each station and if not, fill or estimate; also fill
    %depth if necessary
    sumfn = [mgetdir('M_SUM') '/station_summary_' mcruise '_all.nc'];
    if exist(sumfn,'file')
        [dsum, ~] = mloadq(sumfn,'/');
    else
        clear dsum; dsum.statnum = [];
    end
    stns = unique(d.statnum); ns = length(stns);
    for sno = 1:ns
        m = d.statnum==stns(sno);
        ms = dsum.statnum==stns(sno);
        if length(unique(d.stnlat(m)))~=1 || length(unique(d.stnlon(m)))~=1 || ~sum(~isnan(d.stnlat(m)) & d.stnlat(m)>-999)
            if sum(ms)
                d.stnlat(m) = dsum.lat(ms);
                d.stnlon(m) = dsum.lon(ms);
            else
                %pos at deepest bottle
                mp = m & d.upress==max(d.upress(m));
                d.stnlat(m) = d.stnlat(mp);
                d.stnlon(m) = d.stnlon(mp);
            end
        end
        if length(unique(d.stndepth(m)))~=1 || ~sum(~isnan(d.stndepth(m)) & d.stndepth(m)>-999)
            if sum(ms)
                d.stndepth(m) = dsum.cordep(ms);
            else
                d.stndepth(m) = max(d.stndepth(m));
            end
        end
    end
end
varn = d.Properties.VariableNames;
params.nr = size(d,1);

%depth and density
if isfield(params,'vars_units')

    if sum(strcmpi(dvar,params.vars_units(:,1))) && ~sum(strcmp(dvar,varn))
        d.(dvar) = sw_dpth(d.(pvar),d.(latvar)); %or d.depth?***
        d.Properties.VariableUnits{end} = 'm';
        if sum(strcmp([pvar '_flag'],varn))
            d.([dvar '_flag']) = d.([pvar '_flag']);
            d.Properties.VariableUnits{end} = 'woce_4.9';
        end
    end
    if sum(strcmpi('dens',params.vars_units(:,1))) && ~sum(strcmp('dens',varn))
        d.dens = sw_dens(d.psal,d.temp,d.press);
        d.Properties.VariableUnits{end} = 'kg/m3';
        if sum(strcmp('psal_flag',varn)) && sum(strcmp(temp_flag',varn)) %***
            d.dens_flag = max(d.psal_flag,d.temp_flag);
            d.Properties.VariableUnits{end} = 'woce_4.9';
        end
    end
    if sum(strcmpi('pden0',params.vars_units(:,1))) && ~sum(strcmp('pden0',varn))
        d.pden0 = sw_pden(d.psal,d.temp,d.press,0);
        d.Properties.VariableUnits{end} = 'kg/m3';
        if sum(strcmp('psal_flag',d)) && sum(strcmp('temp_flag',d))
            d.pden0_flag = max(d.psal_flag,d.temp_flag);
            d.Properties.VariableUnits{end} = 'woce_4.9';
        end
    end

    %discard columns we don't need (now that we've calculated new variables)
    if isfield(params,'vars_units')
        d(:,~ismember(d.Properties.VariableNames,params.vars_units(:,1))) = [];
    end

end

%flags
varn0 = d.Properties.VariableNames;
d = hdata_flagnan(d,'nanval',[NaN -999],'keepemptyrows',0);
varn = d.Properties.VariableNames;
if strcmp('mstar',params.out)
    if ~isfield(params,'header'); params.header = {}; end
    params.header = [params.header '\n' h.comment];
    if length(varn)>length(varn0)
        params.header = [params.header ' \ndefault flags used'];
    end
end
%require pressure, otherwise other data no good***only
%relevant for binned data?
m = ~isnan(d.(pvar));
d = d(m,:);

%discard columns we don't need (any new flags we don't need)
if isfield(params,'vars_units')
    [~,ii] = intersect(varn,params.vars_units(:,1),'stable');
    d = d(:,ii);
end

%average/grid
if strcmp(params.in,'ctd')
    if sum(~isnan(d.press))==0
        warning('skipping %s, no good data',fname)
        d = []; return
    end
    if ismember(params.suf,{'_24hz','_psal'})
        dfile = fullfile(mgetdir(params.in),sprintf('dcs_%s_%s.nc',mcruise,stn_string));
        dd = mloadq(dfile,'statnum scan_start scan_bot scan_end ');
        if isfield(params,'bin_units') && strcmp(params.bin_units,'hz')
            %in-water good part of the cast only
            params.iiav = find(d.scan>=dd.scan_start(dd.statnum==stnlocal)&d.scan<=dd.scan_end(dd.statnum==stnlocal));
        elseif isfield(params,'bin_prof') && strcmp(params.bin_prof,'up')
            %upcast only
            params.iiav = find(d.scan>=dd.scan_bot(dd.statnum==stnlocal)&d.scan<=dd.scan_end(dd.statnum==stnlocal));
        else
            %downcast only
            params.iiav = find(d.scan>=dd.scan_start(dd.statnum==stnlocal)&d.scan<=dd.scan_bot(dd.statnum==stnlocal));
        end
        d = d(params.iiav,:);
    end
    %average/grid
    if params.dobin
        disp('binning')
        varu = d.Properties.VariableUnits;
        d = table2struct(d,'ToScalar',true);
        switch params.bin_units
            case 'hz'
                if ~isfield(params,'xg')
                    params.xg = [d.time(1):d.time(end)+params.bin_size*24];
                    if size(d.time,1)>1; params.xg = params.xg'; end
                end
                d = grid_profile(d, params.gvar, params.xg, params.gmethod, params.gopts);
            case {'dbar','m'}
                d = grid_profile(d, params.gvar, params.xg, params.gmethod, params.gopts);                    
        end
        d = struct2table(d); d.Properties.VariableUnits = varu;
    end
end


%tile extra variables
if isfield(params,'vars_units') && sum(strcmp('blank',params.vars_units(:,1))) && (~isfield(params,'extras') || ~isfield(params.extras,'blank'))
    params.extras.blank = ' ';
end
if isfield(params,'extras')
    fn = fieldnames(params.extras);
    for fno = 1:length(fn)
        d.(fn{fno}) = repmat(params.extras.(fn{fno}),params.nr,1);
    end
end

