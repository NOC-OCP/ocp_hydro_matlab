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
    load(sgfile,'sg','sng','sn_list')
else
    for sno = 1:length(sa)
        sg.([sa{sno} '1']) = {};
        sg.([sa{sno} '2']) = {};
        sn_list.(sa{sno}) = {};
    end
    sng = struct();
end

root_ctd = mgetdir('ctd');
for stn = klist
    if ~isempty(sg.temp1) && sum(cell2mat(sg.temp1(:,1))==stn)>0
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
    [sg, sng, sn_list] = sns_from_hdr(h, sg, sng, sn_list, st, sa, stn);
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
save(sgfile,'sg','sng','sn_list','readme'); mfixperms(sgfile);

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
                ii = find(cell2mat(sg.(fn{fno})(:,1))==stn); ii = ii(end);
                %***can only store numbers in mstar data, so for now, just
                %discard anything else
                a = regexprep(sg.(fn{fno})(ii,2), '[^0-9]',''); 
                ds.(['sn_' fn{fno}])(msam) = str2double(a);
            end
        end
    end
end
mfsave(samfile, ds, hs)


function [sg, sng, sn_list] = sns_from_hdr(h, sg, sng, sn_list, st, sa, stn)
% extract sensor s/ns either from fldserial (if already done by
% msbe_to_mstar) or from header (comment)

if ~isfield(h,'fldserial')
    iisns = strfind(h.comment,'<SerialNumber>');
    iisne = strfind(h.comment,'</SerialNumber>');
end

for sno = 1:length(st)
    ii = strfind(h.comment,['<' st{sno} 'Sensor']);

    if ~isempty(ii)
        n1 = [sa{sno} '1'];
        if isfield(h,'fldserial')
            sn1 = h.fldserial{contains(h.fldnam,sa{sno}) & contains(h.fldnam,'1')};
        else
            ii1 = min(iisns(iisns>ii(1)))+14:min(iisne(iisne>ii(1)))-1;
            sn1 = h.comment(ii1);
            sn1 = regexprep(sn1, '[^a-zA-Z0-9]','_');
        end
        sg.(n1) = [sg.(n1); {stn sn1}];
        if isnumeric(sn1)
            sn = [sa{sno} '_' num2str(sn1)];
        else
            sn = [sa{sno} '_' sn1];
        end
        if isfield(sng,sn)
            sng.(sn) = [sng.(sn); [stn 1]];
        else
            sng.(sn) = [stn 1];
        end
        if ~ismember(sn1,sn_list.(sa{sno}))
            sn_list.(sa{sno}) = [sn_list.(sa{sno}) sn1];
        end
        if length(ii)>1
            n2 = [sa{sno} '2'];
            if isfield(h,'fldserial')
                sn2 = h.fldserial{contains(h.fldnam,sa{sno}) & contains(h.fldnam,'2')};
            else
                ii2 = min(iisns(iisns>ii(2)))+14:min(iisne(iisne>ii(2)))-1;
                sn2 = h.comment(ii2);
                sn2 = regexprep(sn2, '[^a-zA-Z0-9]','_');
            end
            sg.(n2) = [sg.(n2); {stn sn2}];
            if isnumeric(sn2)
                sn = [sa{sno} '_' num2str(sn2)];
            else
                sn = [sa{sno} '_' sn2];
            end
            if isfield(sng,sn)
                sng.(sn) = [sng.(sn); [stn 2]];
            else
                sng.(sn) = [stn 2];
            end
            if ~ismember(sn2,sn_list.(sa{sno}))
                sn_list.(sa{sno}) = [sn_list.(sa{sno}) sn2];
            end
        end
    end
end
