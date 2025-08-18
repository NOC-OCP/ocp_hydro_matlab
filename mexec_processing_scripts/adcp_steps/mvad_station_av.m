function mvad_station_av(stn, inst, cast_select, varargin)
% mvad_station_av(stn, inst, cast_select)
% mvad_station_av(stn, inst, cast_select, time_list_file)
%
% extract on-station vmadcp data, output to file suitable for LDEO IX LADCP
%   processing and output an averaged profile to Mstar-format file
% 
% inputs: 
%   stn: CTD cast number (statnum)
%   inst: 'os75nb' or 'os150nb'
%   cast_select: 'ctd': use dcs files for station start and end times
%                any other single-word string: read start and end times
%                  from the file specified as the 4th input argument,
%                  containing one or more rows of 
%                    stn start_time end_time
%                  (where start and end times can be date vectors [yyyy mm
%                  dd HH MM SS] or Matlab datenum scalars). 
%
% mvad_station_av(1,'os75nb', 'ctd')
% outputs OS75 velocities averaged over the cast time to files 
%    data/vmadcp/mproc/os75nb_$cruise_ctd_001_ave.nc, 
%    data/vmadcp/mproc/os75nb_$cruise_ctd_001_forladcp.mat
%
% mvad_station_av(5,'os150nb', 'file', '~/cruise/data/vmadcp/mproc/list_stn_wait.txt')
% reads the specified file containing station numbers, start times, end
%    times***, outputs OS150 velocities averaged over the time interval, 
%    (for instance, if station 5 was a shallow, quick cast, you may want to
%    average VMADCP over 2 hours instead for a better reference) and
%    outputs to  
%    data/vmadcp/mproc/os150nb_$cruise_wait_005_ave.nc,
%    data/vmadcp/mproc/os150nb_$cruise_wait_005_forladcp.mat
%
% mvad_station_av(2,'os75nb', 'list')
% first calls mvad_list_station to display when ship was on station, then
%   asks user to reset cast_select ('ctd' or 'file') and if relevant
%   time_list_file before preceeding as above
%
%
% YLF jc238, based on mvad_03 and mvad_for_ladcp (BAK jc069, jc159, jc211)

if nargin>3
    time_list_file = varargin{1};
end
if strcmp(cast_select,'list')
    mvad_list_station(stn, inst)
    cast_select = input('''ctd'' to use times from dcs file, ''file'' to use times from list file, or ''q'' to quit','s');
    if strcmp('q',cast_select)
        return
    elseif strcmp('file',cast_select)
        a = input('full path of file containing time interval to use for this station, or enter if you already supplied this','s');
        if ~isempty(a)
            time_list_file = a;
        end
    end
end

m_common
opt1 = 'ctd_proc'; opt2 = 'minit'; get_cropt

%paths and filenames
root_ctd = mgetdir('M_CTD');

dataname = [inst '_' mcruise '_' cast_select '_' stn_string];
opt1 = 'adcp_proc'; get_cropt

%get start and end times
if strcmp(cast_select,'ctd')
    [dd, hd] = mloadq(fullfile(root_ctd,['dcs_' mcruise '_' stn_string]),'/');
    tstart = m_commontime(dd,'time_start',hd,'datenum');
    tend = m_commontime(dd,'time_end',hd,'datenum');
else
    tt = readtable(time_list_file);
    ii = find(tt(:,1)==stn); ii = ii(end);
    if size(tt,2)==3
        %numbers
        tstart = tt{ii,2};
        tend = tt{ii,3};
    else
        %vectors, read in as a mix of strings and numbers
        tstart = datenum([str2double(tt{ii,2}{1}(2:end)) tt{ii,3:6} str2double(tt{ii,7}{1}(1:end-1))]);
        tend = datenum([str2double(tt{ii,8}{1}(2:end)) tt{ii,9:12} str2double(tt{ii,13}{1}(1:end-1))]);
    end
end
sstart = datestr(tstart,31); send = datestr(tend,31);

%get vmadcp data
[d, h] = codas_to_mstar(inst);
d.time = m_commontime(d,'time',h,'datenum');

%find indices of vmadcp data in interval, and check whether tstart and tend
%are outside vmadcp time series
mt = (d.time(1,:)>=tstart & d.time(1,:)<=tend);
if sum(mt)==0
    error('no times in interval %s to %s found in %s file',sstart,send,inst);
else
    % check ctd times contained in vmadcp
    if tstart < min(d.time)
        merr = ['ctd start time ' sstart ' earlier than start of vmadcp data ' sprintf('%s',datestr(min(d.time),31))];
        fprintf(MEXEC_A.Mfider,'%s\n',merr)
        query = input('Type ''y'' to continue anyway; anything else to exit ','s');
        if strcmp(query,'y')
        else
            return
        end
    end
    if tend > max(d.time)
        merr = ['ctd end time ' send ' later than end of vmadcp data ' sprintf('%s',datestr(max(d.time),31))];
        fprintf(MEXEC_A.Mfider,'%s\n',merr)
        query = input('Type ''y'' to continue anyway; anything else to exit ','s');
        if strcmp(query,'y')
        else
            return
        end
    end
    % check that the number of vmadcp profiles in ctd cast is not too small
    opt1 = 'ladcp_proc'; get_cropt

    nvmadcpprf = sum(mt);
    if nvmadcpprf < min_nvmadcpprf
        mwarn = ['Warning [station ' stn_string ']: Number of vmADCP profiles (' num2str(nvmadcpprf) ') is less than minimum (' num2str(min_nvmadcpprf) ')'];
        fprintf(MEXEC_A.Mfider, '%s\n', mwarn)
    end

    % check for vmADCP bins with too many gaps
    uadcp_aux = d.(h.fldnam{5})(:,mt);
    vadcp_aux = d.(h.fldnam{6})(:,mt);
    fgu = ~isnan(uadcp_aux);
    fgv = ~isnan(vadcp_aux);
    fguv = fgu==fgv; % u and v should have the same gaps
    if ~all(fguv(:))
        fprintf(MEXEC_A.Mfider, '%s\n', ['Warning[station ' stn_string ']: vmADCP u and v have different gaps'])
    end
    np = sum(fgu,2);
    fbprf = max(find(np>0));
    if ~isempty(fbprf) && min(np(1:fbprf)) < min_nvmadcpbin %mask depths with good profiles less than a threshold
        fmsk = np < min_nvmadcpbin;
        d.(h.fldnam{5})(fmsk,mt) = NaN;
        d.(h.fldnam{6})(fmsk,mt) = NaN;
        uadcp_aux2 = d.(h.fldnam{5})(:,mt);
        vadcp_aux2 = d.(h.fldnam{6})(:,mt);
    end

    %throw a warning if the watertrack reference layer (bins 2:10) is too
    %gappy at some depth
    ntref = 2;
    nbref = 10;
    uadcp_refl = d.(h.fldnam{5})(ntref:nbref,mt);
    if any(sum(~isnan(uadcp_refl),2) < min_nvmadcpbin_refl)
        mwarn = ['Warning [station ' stn_string ']: Bin with too few valid data points (less than ' num2str(min_nvmadcpbin_refl) ') in vmADCP reference layer (bins ' num2str(ntref) '-' num2str(nbref) ')'];
        fprintf(MEXEC_A.Mfider, '%s\n', mwarn)
    end
end

% average
for no = 1:length(h.fldnam)
    da.(h.fldnam{no}) = m_nanmean(d.(h.fldnam{no})(:,mt),2);
end
ha = h;
ha.dataname = dataname;
ha.latitude = da.lat(1); ha.lon = da.lon(1);
%ha.instrument_depth_metres = 5; %***
if strcmp(cast_select,'ctd')
    ha.comment = [h.comment sprintf('\n averaged over %s to %s from dcs_%s_%s.nc',sstart,send,mcruise,stn_string)];
else
    ha.comment = [h.comment sprintf('\n averaged over %s to %s from %s',sstart,send,time_list_file)];
end

%check dims
mfsave(avfile,da,ha); 

opt1 = 'mstar'; get_cropt
if docf
    [~,to] = timeunits_mstar_cf(h.fldunt{strcmp('decday',h.fldnam)});
else
    to = h.data_time_origin;
end
%file for ladcp
if MEXEC_G.ix_ladcp && sum(mt)>1
    % CV 2018/11/17: edit to get the right variable names and time for LDEO_IX_12
    tim_sadcp = d.decday(1,mt) + julian(to(1),to(2),to(3));
    lat_sadcp = d.lat(1,mt);
    lon_sadcp = d.lon(1,mt);
    velun = h.fldunt(strcmp('uabs',h.fldnam));
    if strcmp(velun,'m/s')
        u_sadcp   = d.uabs(:,mt);
        v_sadcp   = d.vabs(:,mt);
    elseif strcmp(velun,'cm/s')
        u_sadcp = d.uabs(:,mt)/100;
        v_sadcp = d.vabs(:,mt)/100;
    end
    z_sadcp   = d.depth(:,1);
    save(ladfile, 'tim_sadcp', 'z_sadcp', 'u_sadcp', 'v_sadcp', 'lon_sadcp', 'lat_sadcp'); mfixperms(ladfile);
end
