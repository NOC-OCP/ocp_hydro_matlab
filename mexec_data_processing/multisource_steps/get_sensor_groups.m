function get_sensor_groups(klist,varargin)
% get_sensor_groups(klist)
% parse raw ctd file header comments to find S/Ns for temp1,
%   cond1, temp2, cond2, oxygen1, oxygen2; append to .mat file and to
%   sam_*_all.nc file if it exists
%
% get_sensor_groups(klist,'restart')
% as above but don't use existing .mat file if any
%
% get_sensor_groups(klist,'samonly')
% load the existing .mat file as-is and save to sam_*_all.nc file

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
pd = mexec_file_locations('procfiles','ctd');
pds = mexec_file_locations('procfiles','samp');

if (nargin>1 && strcmp(varargin{1},'restart')) || ~exist(pd.sg,'file')
    %initialise empty
    for sno = 1:length(sa)
        sg.([sa{sno} '1']) = {};
        sg.([sa{sno} '2']) = {};
        sn_list.(sa{sno}) = {};
    end
    sng = struct();
else
    %load existing, either to use or to modify/append to
    load(pd.sg,'sg','sng','sn_list')
end

if nargin==1 || ~strcmp(varargin{1},'samonly')
    %get serial numbers from raw ctd file headers
    for stn = klist
        opt1 = 'setup'; opt2 = 'm_stn_string'; run(MEXEC_G.opt_cruise)
        if ~isempty(sg.temp1) && sum(cell2mat(sg.temp1(:,1))==stn)>0
            continue %don't redo
        end
        if exist(sprintf(pd.ctdraw,stn_string),'file')
            h = m_read_header(sprintf(pd.ctdraw,stn_string));
            [sg, sng, sn_list] = sns_from_sbe_hdr(h, sg, sng, sn_list, stn);
        else
            warning('no %s, skipping S/Ns from %s',sprintf(pd.ctdraw,stn_string),stn_string)
        end
    end

    fn = fieldnames(sg);
    for fno = 1:length(fn)
        if isempty(sg.(fn{fno}))
            sg = rmfield(sg,fn{fno});
        end
    end
    sng = orderfields(sng);

    readme = {'sg has lists of stations and serial numbers for each sensor-position (e.g. temp1, cond1, temp2);'
        'sng has lists of stations and sensor-positions for each serial number';
        'sn_list has lists of serial numbers for each sensor (e.g. temp)'};
    save(pd.sg,'sg','sng','sn_list','readme'); mfixperms(pd.sg);
end

%now save data from sgfile to sam_*_all file
if ~exist(m_add_nc(pds.samc),'file')
    return
end
[ds, hs] = mload(pds.samc,'/');
if sum(ismember(ds.statnum,klist)&~isnan(ds.upress))
    fn = fieldnames(sg);
    for fno = 1:length(fn)
        if ~isfield(ds,['sn_' fn{fno}])
            ds.(['sn_' fn{fno}]) = NaN+ds.sampnum;
            hs.fldnam = [hs.fldnam ['sn_' fn{fno}]];
            hs.fldunt = [hs.fldunt 'number'];
        end
    end
    for stn = klist
        msam = ds.statnum==stn;
        if sum(msam)
            for fno = 1:length(fn)
                ii = find(cell2mat(sg.(fn{fno})(:,1))==stn); ii = ii(end);
                %***can only store numbers in mstar data, so for now, just
                %discard anything else
                a = regexprep(sg.(fn{fno})(ii,2), '[^0-9]','');
                ds.(['sn_' fn{fno}])(msam) = str2double(a);
            end
        end
    end
end
mfsave(pds.samc, ds, hs)
