function mvad_station_av(stn, inst, cast_select, varargin)
% function mvad_station_av(stn, inst, cast_select, varargin)
%
% extract on-station vmadcp data, output to file suitable for LDEO IX LADCP
%   processing and (averaged profile) to Mstar-format file
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
% mvad_station(os75nb, 1, 'ctd')
% outputs OS75 velocities averaged over the cast time to files 
%    data/vmadcp/mproc/os75nb_$cruise_ctd_001_ave.nc and
%    data/ladcp/SADCP/os75nb_$cruise_ctd_001_forladcp.mat
%
% mvad_station(os150nb, 5, 'wait', '~/cruise/data/vmadcp/mproc/list_stn_wait.txt')
% outputs OS150 velocities averaged over the time intervals in the
%    specified file (for instance, if station 5 was a shallow, quick cast,
%    you may want to average VMADCP over 2 hours instead for a better
%    reference) and outputs to 
%    data/vmadcp/mproc/os150nb_$cruise_wait_005_ave.nc,
%    data/ladcp/SADCP/os150nb_$cruise_wait_005_forladcp.mat,
%
%
% YLF jc238, based on mvad_03 and mvad_for_ladcp (BAK jc069, jc159, jc211)

m_common
scriptname = 'castpars'; oopt = 'minit'; get_cropt

%paths and filenames
root_ctd = mgetdir('M_CTD');
root_vmadcp = mgetdir('M_VMADCP');
root_ladcp = mgetdir('M_LADCP');

dataname = [inst '_' mcruise '_' cast_select '_' stn_string];
avfile = fullfile(root_vmadcp, 'mproc', [dataname '_ave.nc']);
if ~isempty(root_ladcp)
    ladfile = fullfile(root_ladcp, 'SADCP', [dataname '_forladcp.mat']);
end
if nargin>3
    listfile = varargin{1};
end

%get start and end times
if strcmp(cast_select,'ctd')
    [dd, hd] = mloadq(fullfile(root_ctd,['dcs_' mcruise '_' stn_string]),'/');
    tstart = dd.time_start/86400+datenum(hd.data_time_origin);
    tend = dd.time_end/86400+datenum(hd.data_time_origin);
else
    tt = readtable(listfile);
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
d.time = d.time/86400 + datenum(h.data_time_origin);

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
    ha.comment = [h.comment sprintf('\n averaged over %s to %s from %s',sstart,send,listfile)];
end
%check dims
mfsave(avfile,da,ha);

%file for ladcp
if ~isempty(root_ladcp) && sum(mt)>1
    % CV 2018/11/17: edit to get the right variable names and time for LDEO_IX_12
    tim_sadcp = d.decday(1,mt) + julian(h.data_time_origin(1),h.data_time_origin(2),h.data_time_origin(3));
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
    save(fullfile(root_ladcp, 'SADCP', [inst '_' mcruise '_' stn_string '_forladcp']), 'tim_sadcp', 'z_sadcp', 'u_sadcp', 'v_sadcp', 'lon_sadcp', 'lat_sadcp');
end
