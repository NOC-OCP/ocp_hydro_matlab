function get_sensor_groups(klist)
%parse raw ctd file header comments to find S/Ns for temp1,
%cond1, temp2, cond2, oxygen1, oxygen2; save to sam file (if there were
%bottles fired) and .mat file (anyway)

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

st = {'Temperature','Conductivity','Oxygen'};
sa = {'temp','cond','oxygen'};

opt1 = 'castpars'; opt2 = 'ctdsens_groups'; get_cropt
if exist(sgfile,'file')
    load(sgfile,'sg','sng')
else
    for sno = 1:length(st)
        sg.([sa{sno} '1']) = [];
        sg.([sa{sno} '2']) = [];
        sng = struct();
    end
end

root_ctd = mgetdir('ctd');
for stn = klist
    if ~isempty(sg.temp1) && sum(sg.temp1(:,1)==stn)>0
        continue %don't redo
    end

    rfile = sprintf('%s/ctd_%s_%03d_raw.nc',root_ctd,mcruise,stn);
    if ~exist(rfile,'file')
        rfile = [rfile(1:end-3) '_noctm.nc'];
        if ~exist(rfile,'file')
            continue
        end
    end
    h = m_read_header(rfile);
    iisns = strfind(h.comment,'<SerialNumber>');
    iisne = strfind(h.comment,'</SerialNumber>');

    for sno = 1:length(st)
        ii = strfind(h.comment,['<' st{sno} 'Sensor']);

        if ~isempty(ii)
            ii1 = min(iisns(iisns>ii(1)))+14:min(iisne(iisne>ii(1)))-1;
            sn1 = str2double(h.comment(ii1));
            n1 = [sa{sno} '1'];
            sg.(n1) = [sg.(n1); [stn sn1]];
            sn = [sa{sno} '_' num2str(sn1)];
            if isfield(sng,sn)
                sng.(sn) = [sng.(sn); [stn 1]];
            else
                sng.(sn) = [stn 1];
            end
            if length(ii)>1
                ii2 = min(iisns(iisns>ii(2)))+14:min(iisne(iisne>ii(2)))-1;
                sn2 = str2double(h.comment(ii2));
                n2 = [sa{sno} '2'];
                sg.(n2) = [sg.(n2); [stn sn2]];
                sn = [sa{sno} '_' num2str(sn2)];
                if isfield(sng,sn)
                    sng.(sn) = [sng.(sn); [stn 2]];
                else
                    sng.(sn) = [stn 2];
                end
            end
        end

    end
end
fn = fieldnames(sg);
for fno = 1:length(fn)
    if isempty(sg.(fn{fno}))
        sg = rmfield(sg,fn{fno});
    end
end
sng = orderfields(sng);

readme = {'sg has lists of stations and serial numbers for each sensor/position (e.g. temp1, cond1);'
    'sng has lists of stations and sensor-positions for each serial number'};
save(sgfile,'sg','sng','readme')

%now save to sam file
samfile = fullfile(mgetdir('sam'),['sam_' mcruise '_all']);
if ~exist(m_add_nc(samfile),'file')
    return
end
[ds, hs] = mload(samfile,'/');
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
                ii = find(sg.(fn{fno})(:,1)==stn); ii = ii(end);
                ds.(['sn_' fn{fno}])(msam) = sg.(fn{fno})(ii,2);
            end
        end
    end
end
mfsave(samfile, ds, hs)
