%loop through _raw ctd files, parse header comments to find S/Ns for temp1,
%cond1, temp2, cond2, oxygen1, oxygen2; save to sam_cruise_all.nc

mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

if ~exist('klist','var')
    klist = input('list stations to search for sensor numbers (vector)  ');
end

st = {'Temperature','Conductivity','Oxygen'};
sa = {'temp','cond','oxygen'};

clear sg sng
for sno = 1:length(st)
    sg.([sa{sno} '1']) = [];
    sg.([sa{sno} '2']) = [];
    sng = struct();
end

root_ctd = mgetdir('ctd');
for kloop = klist
    stn = kloop; stnlocal = stn;
    rfile = sprintf('%s/ctd_%s_%03d_raw.nc',root_ctd,mcruise,stnlocal);
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
            sg.(n1) = [sg.(n1); [stnlocal sn1]];
            sn = [sa{sno} '_' num2str(sn1)];
            if isfield(sng,sn)
                sng.(sn) = [sng.(sn); [stnlocal 1]];
            else
                sng.(sn) = [stnlocal 1];
            end
            if length(ii)>1
                ii2 = min(iisns(iisns>ii(2)))+14:min(iisne(iisne>ii(2)))-1;
                sn2 = str2double(h.comment(ii2));
                n2 = [sa{sno} '2'];
                sg.(n2) = [sg.(n2); [stnlocal sn2]];
                sn = [sa{sno} '_' num2str(sn2)];
                if isfield(sng,sn)
                    sng.(sn) = [sng.(sn); [stnlocal 2]];
                else
                    sng.(sn) = [stnlocal 2];
                end
            end
        end

    end
end
sng = orderfields(sng);

readme = {'sg has lists of stations and serial numbers for each sensor/position (e.g. temp1, cond1);'
    'sng has lists of stations and sensor-positions for each serial number'};

save(fullfile(root_ctd,'sensor_groups.mat'),'sg','sng','readme')
