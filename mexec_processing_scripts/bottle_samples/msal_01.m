function msal_01
% msal_01: read in the bottle salinities from digitized autosal log(s)
% and save to sal_cruise_01.nc, tsgsal_cruise_01.nc
%
% Use: msal_01 
%
%   uses gsw: salinity = gsw_SP_salinometer((runavg+offset)/2, cellT);
%
% the input files must include a column or field "sampnum" which takes the
% form
% sampnum = 100*statnum + position
%     where statnum is the station and position the niskin position 
%     ([1 24] or [1 36])
%     for ctd samples,
% and for tsg samples, 
% sampnum = yyyymmddhhmm
% or 
% sampnum = -dddhhmm (where ddd is year-day, and the negative sign is
%   important) 
%
% and for standards, 
% sampnum = 999NNN
%     where NNN increments sequentially as the standards were run
%     (998NNN, 990NNN, etc. may be used for sub-standards)
% 
% lines where the sampnum column is empty will be filled in from the last
% non-empty sampnum above 

m_common
if MEXEC_G.quiet<1; fprintf(1, 'loading bottle salinities from the file(s) specified in opt_%s and writing ctd samples to sal_%s_01.nc and sam_%s_all.nc, and underway samples to tsg_%s_01.nc',mcruise,mcruise,mcruise,mcruise); end

std_samp_range = [999000 1e6]; %sample numbers for ssw are in this range, e.g. 999000, 999001, etc.
sub_samp_range = [998000 998999]; %substandards
%ctd sampnums are <1e5, and tsg sampnums are either <0 or larger than 1e7

% find list of files and information on variables
root_sal = mgetdir('M_BOT_SAL');
salfiles = dir(fullfile(root_sal, ['sal_' mcruise '_*.csv'])); 
hcpat = {'sampnum'}; chrows = 1; chunits = [];
sheets = 1; iopts = struct([]);
datform = 'dd/mm/yyyy';
timform = 'HH:MM:SS';
opt1 = 'botpsal'; opt2 = 'sal_files'; get_cropt %list of files to load
if isempty(salfiles)
    warning(['no salinity data files found in ' root_sal '; skipping']);
    return
end
salfiles = fullfile({salfiles.folder}',{salfiles.name}');

%%%%%% load and parse %%%%%%

%load
%***datetime format is already read in wrong by default? causes wrong
%ordering of samples***
[ds_sal, salhead] = load_samdata(salfiles, 'hcpat', hcpat, 'chrows', chrows, 'chunits', chunits, 'sheets', sheets, iopts); 
if isempty(ds_sal)
    error('no data loaded')
end
if isfield(ds_sal,'sampnum') && sum(isnan(ds_sal.sampnum))
    %if repeat readings are on different lines and sampnum has only been
    %filled in for the first (average) line, for example
    ds_sal = fill_samdata_statnum(ds_sal, 'sampnum');
end
%remove NaN sampnum lines
ds_sal(isnan(ds_sal.sampnum),:) = [];

%parse, for instance getting information from header
% for no = 1:length(salhead)
%     sh = salhead{no};
%     md = strncmp(sh,'Date',4);
%     mt = strncmp(sh,'Time',4);
%     mr = strncmp(sh,'Reference',9);
%     if sum(md)==1 && sum(mt)==1 && sum(mr)==1
%         l = sh{mr};
%         ii = strfind(l,'ture:,')+7;
%         l = str2num(l(ii:ii+1));
%     end
% end
opt1 = 'botpsal'; opt2 = 'sal_parse'; get_cropt
opt1 = 'check_sams'; get_cropt

if calcsal
    %add option to fill in information about cellt or Bath Temp and k15 from header***
    fn = ds_sal.Properties.VariableNames;
    if ~sum(strcmp('cellt',fn)) || sum(isfinite(ds_sal.cellt))==0
        ds_sal.cellt = repmat(cellT,size(ds_sal,1),1);
    end
    fn = ds_sal.Properties.VariableNames;
    if sum(strcmp('k15',fn)) && sum(~isnan(ds_sal.k15))==0
        ds_sal.k15 = [];
    end
    fn = ds_sal.Properties.VariableNames;
    if ~sum(strcmp('k15',fn)) && exist('ssw_k15','var')
        ds_sal.k15 = repmat(ssw_k15,size(ds_sal,1),1);
    end

    %rename
    clear samevars
    samevars.sample_1 = {'sample1' 'reading_1' 'reading1' 'r1'};
    samevars.sample_2 = {'sample2' 'reading_2' 'reading2' 'r2'};
    samevars.sample_3 = {'sample3' 'reading_3' 'reading3' 'r3'};
    samevars.sample_4 = {'sample4' 'reading_4' 'reading4' 'r4'};
    samevars.runavg = {'average'};
    vars = fieldnames(samevars);
    fn = ds_sal.Properties.VariableNames;
    for vno = 1:length(vars)
        if ~sum(strcmp(vars{vno},fn)) && ~sum(contains(samevars.(vars{vno}),fn))
            %add this one
            ds_sal.(vars{vno}) = nan(size(ds_sal,1),1);
            fn = [fn vars{vno}];
        end
    end
    fn = ds_sal.Properties.VariableNames;

    %deal with time variable(s)
    md = strcmp('date',fn); mt = strcmp('time',fn);
    if sum(md) && sum(mt)
        if ischar(ds_sal{:,mt})
            tim = datevec(ds_sal{:,mt},timform);
        else
            tim = datevec(ds_sal{:,mt});
        end
        if ischar(ds_sal{:,md})
            dat = datevec(ds_sal{:,md},datform);
        else
            dat = datevec(ds_sal{:,md});
        end
        ds_sal.runtime = datenum(dat + tim); %***
        ds_sal.time = []; ds_sal.date = [];
        fn = ds_sal.Properties.VariableNames;
    end

    if ~sum(strcmp('flag',fn))
        ds_sal.flag = 2+zeros(size(ds_sal,1),1);
    else
        ds_sal.flag(isnan(ds_sal.flag)) = 9;
    end

    if ~ismember('sample_4',fn)
        ds_sal.sample_4 = NaN+ds_sal.sample_1;
    end

    %temporarily shift tsg sampnum times for plotting if using >0 method
    iitsg = find(ds_sal.sampnum>1000e8);
    ds_sal.sampnum(iitsg) = ds_sal.sampnum(iitsg)-MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1)*1e8;

    %edits
    reapply_saledits = 1; edfile = fullfile(root_sal,'editlogs','bad_sal_readings');
    opt1 = 'botpsal'; opt2 = 'sal_flags'; get_cropt
    if reapply_saledits
        [ds_sal, ~] = apply_guiedits(ds_sal, 'sampnum', [edfile '*']);
    end

    ds_sal.runavg = m_nanmean([ds_sal.sample_1 ds_sal.sample_2 ds_sal.sample_3 ds_sal.sample_4],2);

    %inspect for new edits
    if check_sal
        %standards and substandards (999NNN and 998NNN): plot together
        iis = find(ds_sal.sampnum>=std_samp_range(1) & ds_sal.sampnum<=std_samp_range(2));
        iis = [iis; find(ds_sal.sampnum>=sub_samp_range(1) & ds_sal.sampnum<=sub_samp_range(2))];
        iis_all = {iis};
        %regular stations (including test casts)
        maxstsam = 99936;
        stns = check_sal:max(floor(ds_sal.sampnum(ds_sal.sampnum<=maxstsam)/100));
        n = 1;
        for no = stns
            iis_all{n+1} = find(floor(ds_sal.sampnum/100)==no); n = n+1;
        end
        %underway option 1
        iis = find(ds_sal.sampnum>std_samp_range(2));
        if ~isempty(iis); iis_all{n+1} = iis; n = n+1; end
        %underway option 2
        iis = find(ds_sal.sampnum<0);
        if ~isempty(iis); iis_all{n+1} = iis; n = n+1; end
        %everything else
        iis = find(ds_sal.sampnum>maxstsam & ds_sal.sampnum<sub_samp_range(1));
        if ~isempty(iis); iis_all{n+1} = iis; n = n+1; end
        d = struct();
        d.sampnum = ds_sal.sampnum;
        d.sample_1 = ds_sal.sample_1-ds_sal.runavg;
        d.sample_2 = ds_sal.sample_2-ds_sal.runavg;
        d.sample_3 = ds_sal.sample_3-ds_sal.runavg;
        d.sample_4 = ds_sal.sample_4-ds_sal.runavg;
        d.ref_hi = ones(size(ds_sal.sampnum))*2.5e-5;
        d.ref_low = -d.ref_hi;
        markers = {'o';'s';'<';'.';'none';'none'};
        lines = {'none';'none';'none';'none';'-';'-'};
        bads = gui_editpoints(d,'sampnum','edfilepat',edfile,'markers',markers,'lines',lines,'xgroups',iis_all);
        clear d
    end
    if exist('bads','var') && ~isempty(bads) %new edits to apply
        [ds_sal, ~] = apply_guiedits(ds_sal, 'sampnum', [edfile '*']);
    
    end

    %put year back on to tsg samples
    ds_sal.sampnum(iitsg) = ds_sal.sampnum(iitsg) + MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1)*1e8;

    opt1 = 'botpsal'; opt2 = 'sal_flags'; get_cropt
    %recalculate mean
    a = [ds_sal.sample_1 ds_sal.sample_2 ds_sal.sample_3 ds_sal.sample_4];
    ds_sal.runavg = m_nanmean(a,2);
    %flag based on stdev and number of remaining points
    s3 = 3e-5; s4 = 5e-5;
    an = sum(~isnan(a),2);
    ds_sal.flag(an==2) = max(ds_sal.flag(an==2),3);
    ds_sal.flag(an==1) = 4;
    as = m_nanstd(a,2);
    ds_sal.flag(as>s3) = max(ds_sal.flag(as>s3),3);
    ds_sal.flag(as>s4) = 4;

    %609 619 620

    %%%%%% standards offsets %%%%%%

    opt1 = 'botpsal'; opt2 = 'sal_calc'; get_cropt
    if ~strcmp(salin_off_base,'sampnum_list') && sum(strcmp('runtime',fn))
        [~,ii] = sort(ds_sal.runtime);
        ds_sal = ds_sal(ii,:);
    end

    fn = ds_sal.Properties.VariableNames;
    [~,ii] = unique(ds_sal.sampnum,'stable');
    if length(ii)<length(ds_sal.sampnum)
        warning('duplicate sample numbers will be discarded: ')
        disp(ds_sal.sampnum(setdiff(1:length(ds_sal.sampnum),ii))')
        ds_sal = ds_sal(ii,:);
    end

    %plot standards
    iistd = find(ds_sal.sampnum>=std_samp_range(1) & ds_sal.sampnum<std_samp_range(2));
    iisu = find(ds_sal.sampnum>=sub_samp_range(1) & ds_sal.sampnum<sub_samp_range(2));
    iis = setdiff(1:length(ds_sal.sampnum),[iistd; iisu]);
    if sum(strcmp('k15',fn))
        figure(10); clf
        subplot(211)
        st = ds_sal.k15*2;
        if strcmp(salin_off_base,'sampnum_run')
            x = ds_sal.runtime - datenum(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN);
            plot(x,st-ds_sal.runavg,'oc'); hold on
            disp('cyan o: all sample averages recorded')
            ist = 1;
        else
            x = [1:length(ds_sal.sampnum)]';
            if ~isempty(iisu) %look for neighbouring substandards
            xsu = nan(size(iisu));
            m = ismember(iisu+1,iistd);
            xsu(m) = x(iisu(m)+1);
            m = ismember(iisu-1,iistd);
            xsu(m) = x(iisu(m)-1);
            m = isnan(xsu);
            xsu(m) = interp1(find(~m),xsu(~m),find(m));
            end
            ist = 0;
        end
        plot(x(iistd),st(iistd)-ds_sal.sample_1(iistd),'kx', ...
            x(iistd),st(iistd)-ds_sal.sample_2(iistd),'r+', ...
            x(iistd),st(iistd)-ds_sal.sample_3(iistd),'m.', ...
            x(iistd),st(iistd)-ds_sal.sample_4(iistd),'go', ...
            x(iistd),st(iistd)-ds_sal.runavg(iistd),'sb');
        if ist
            s = ds_sal.sampnum(iistd)-std_samp_range(1);
            text(x(iistd),zeros(1,length(iistd)),num2str(s(:)));
            disp('labels: sequential standard number'); xlabel('day')
        else
            xlabel('index')
            if sum(strcmp('runtime',ds_sal.Properties.VariableNames))
            text(x(iistd),zeros(1,length(iistd)),datestr(ds_sal.runtime(iistd),'dd'));
            text(x(iistd),-5e-6+zeros(1,length(iistd)),datestr(ds_sal.runtime(iistd),'HH:MM'));
            disp('labels: dd;HH:MM of standard');
            end
        end
        ylim([-1 1]*1e-4); ylabel('nominal (2xK15) - recorded value')
        grid on
        disp('(k,r,m): reading1, 2, 3 of standards; blue squares: average of standards. (fixed scale.)');
        cont = input('examine standards, ''k'' for keyboard prompt, enter to continue\n','s');
        if strcmp(cont,'k'); keyboard; end
    else
        warning('no standards plotted because no K15 found')
    end


    %get offsets for samples
    if isempty(sal_adj_comment) && ~isempty(salin_off)
        sal_adj_comment = ['Adjustments specified in opt_' mcruise];
    end
    if isempty(salin_off)
        sal_adj_comment = 'no standards adjustment';
    elseif length(salin_off)==1
        ds_sal.salin_off = repmat(salin_off, size(ds_sal.sampnum));
    elseif length(salin_off)==length(ds_sal.sampnum)
        ds_sal.salin_off = salin_off;
    else
        %interpolate
        switch salin_off_base
            case 'sampnum_run' %offsets given using standards sampnums (must be found in ds_sal); interpolate between them using runtime or order
                dt = ds_sal.runtime(iis)'-ds_sal.runtime(iistd);
                dt(dt<0) = NaN; [dt1,ii1] = min(dt);
                dt = ds_sal.runtime(iis)'-ds_sal.runtime(iistd);
                dt(dt>0) = NaN; [dt2,ii2] = max(dt); dt2 = -dt2;
                iiw = (min(dt1,dt2)>1/24 | max(dt1,dt2)>3/24); %***
                if sum(iiw)
                    warning('%s\n %s\n','these samples are an hour or more from any standard; if a standard was not run','on either side of each crate, sampnum_run may not be the best method:');
                    disp(ds_sal.sampnum(iis(iiw)))
                end
                [c,ia,ib] = intersect(salin_off(:,1),ds_sal.sampnum);
                ds_sal.salin_off = NaN+zeros(size(ds_sal.sampnum));
                ds_sal.salin_off(ib) = salin_off(ia,2);
                if sum(strcmp('runtime',ds_sal.Properties.VariableNames))
                    ds_sal.salin_off(iis) = interp1(ds_sal.runtime(iistd),ds_sal.salin_off(iistd),ds_sal.runtime(iis));
                else
                    ds_sal.salin_off(iis) = interp1(iistd,ds_sal.salin_off(iistd),iis); %***
                end
            case 'sampnum_list' %offsets given based on indices in ds_sal -- use this if you are missing standards (e.g. salin_off(:,1) could contain 0, or 50.5, etc.)
                ds_sal.salin_off = interp1(salin_off(:,1), salin_off(:,2), [1:length(ds_sal.sampnum)]');
                % [~,ia,ib] = intersect(ds_sal.sampnum(iistd),salin_off(:,1));
                % if ~isempty(ib) && length(ia)<length(iistd)
                %     warning('no offsets for some standards: ')
                %     disp(ds_sal.sampnum(iistd(setdiff(1:length(iistd),ia)))-std_samp_range(1))
                % end
                % if length(ib)<size(salin_off(:,1))
                %     warning('offsets present for standards not in file: ')
                %     disp(salin_off(setdiff(1:length(salin_off),ib))-std_samp_range(1))
                % end
                % ds_sal.salin_off(iistd(ia)) = salin_off(ib,2);
                % ds_sal.salin_off(iis) = interp1(iistd,ds_sal.salin_off(iistd),iis);
        end
    end

    %apply offsets
    ds_sal.salinity = gsw_SP_salinometer(ds_sal.runavg/2, ds_sal.cellt); %changed on JC103 in rapid branch, after JR16002 in JCR branch
    if ~isempty(salin_off)
        ds_sal.salinity_adj = gsw_SP_salinometer((ds_sal.runavg+ds_sal.salin_off)/2, ds_sal.cellt);
        iin = find(isnan(ds_sal.salinity_adj));
        ds_sal.flag(iin) = max(4,ds_sal.flag(iin));
    else
        ds_sal.salinity_adj = NaN+ds_sal.salinity;
    end

    %check or add units
    salunits.sampnum = {'number'};
    salunits.runtime = {'MATLAB_datenum'};
    salunits.sample_1 = {'2Rt'};
    salunits.sample_2 = {'2Rt'};
    salunits.sample_3 = {'2Rt'};
    mctd_evaluate_salunits.runavg = {'2Rt'};
    salunits.cellt = {'degC'};
    salunits.k15 = {'2Rt'};
    salunits.flag = {'woce_9.4'};
    salunits.salinity = {'psu'};
    salunits.salinity_adj = {'psu'};
    if ~isempty(ds_sal.Properties.VariableUnits)
        [ds_sal, ~] = check_units(ds_sal, salunits);
    end

else

    salunits.sampnum = {'number'};
    salunits.flag = {'woce_9.4'};
    salunits.salinity = {'psu'};
end
opt1 = 'botpsal'; opt2 = 'sal_flags'; get_cropt

%%%%%% save %%%%%%

dataname = ['sal_' mcruise '_01'];
salfile = fullfile(root_sal, [dataname '.nc']);
opt1 = 'ship'; opt2 = 'ship_data_sys_names'; get_cropt
tsgfile = fullfile(root_sal, ['tsgsal_' mcruise '_all.nc']);

%select the variables we want to save
fn = ds_sal.Properties.VariableNames;
fn0 = fieldnames(salunits);
clear d hc
hc.fldnam = {}; hc.fldunt = {};
[~,ia,ib] = intersect(fn0,fn);
for no = 1:length(ia)
    d.(fn0{ia(no)}) = ds_sal{:,ib(no)};
    hc.fldnam = [hc.fldnam fn0{ia(no)}];
    if isempty(ds_sal.Properties.VariableUnits) || isempty(ds_sal.Properties.VariableUnits{ib(no)})
        hc.fldunt = [hc.fldunt salunits.(fn0{ia(no)})];
    else
        hc.fldunt = [hc.fldunt ds_sal.Properties.VariableUnits{ib(no)}];
    end
end

%write all to sal_ file
hc.comment = [sal_adj_comment];
mfsave(salfile, d, hc);

%plot CTD samples
opt1 = 'check_sams'; get_cropt
if check_sal
    figure(10); subplot(223)
    ii = find(d.sampnum>0 & d.sampnum<9e5);
    plot(d.sampnum(ii),d.salinity(ii),'o',d.sampnum(ii),d.salinity_adj(ii),'s')
    title('CTD'); xlabel('sampnum'); legend('sal', 'sal adj')
end

%write some fields for CTD samples to sam_ file
msal_to_sam

%get TSG samples, figure out times: either -dddhhmm (where ddd is
%year-day starting at 1), or yyyymmddhhmm, or mmddhhmm
ii = find(d.sampnum>=1e6 & d.sampnum<1e7);
d.sampnum(ii) = d.sampnum(ii) + MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1)*1e8;
iiu = find(d.sampnum<0 | d.sampnum>=1e6);
if ~isempty(iiu)

    fnd = fieldnames(d);
    for no = 1:length(fnd)
        dsu.(fnd{no}) = d.(fnd{no})(iiu,:);
    end

    tsg.sampnum = dsu.sampnum;
    tsg.dnum = NaN+zeros(size(tsg.sampnum));
    ii = find(tsg.sampnum>1e7);
    if ~isempty(ii)
        tsg.dnum(ii) = datenum(num2str(tsg.sampnum(ii)),'yyyymmddHHMM');
    end
    ii = find(tsg.sampnum<0);
    if ~isempty(ii)
        s = num2str(-tsg.sampnum(ii));
        jjj = str2num(s(:,1:3));
        HH = str2num(s(:,4:5));
        MM = str2num(s(:,6:7));
        tsg.dnum(ii) = datenum(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1),1,1) + jjj-1 + (HH+MM/60)/24;
    end
    opt1 = 'botpsal'; opt2 = 'tsg_sampnum'; get_cropt
    [c,ia,ib] = intersect(dsu.sampnum,tsg.sampnum);
    dsu.time = NaN+dsu.sampnum;
    opt1 = 'mstar'; get_cropt
    if docf
        un = ['seconds since ' datestr(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN,'yyyy-mm-dd HH:MM:SS')];
    else
        un = ['seconds since ' datestr(hc.data_time_origin,'yyyy-mm-dd HH:MM:SS')];
    end
    dsu.time(ia) = m_commontime(tsg.dnum(ib),'datenum',un);
    if sum(isnan(dsu.time))>0
        warning('missing times for tsg samples:')
        disp(dsu.sampnum(isnan(dsu.time)))
        keyboard
    end
    hu = hc;
    hu.fldnam = [hu.fldnam 'time'];
    hu.fldunt = [hu.fldunt un];
    hu.comment = hc.comment;
    hu.dataname = ['tsgsal_' mcruise '_all'];
    mfsave(tsgfile, dsu, hu);

    figure(10); subplot(224)
    x = dsu.time/86400+1;
    plot(x,dsu.salinity,'o',x,dsu.salinity_adj,'s')
    title('TSG'); xlabel('yearday');

end
