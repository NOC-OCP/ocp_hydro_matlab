%loop through _raw ctd files, parse header comments to find S/Ns for temp1,
%cond1, temp2, cond2, oxygen1, oxygen2; save to sam_cruise_all.nc

mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

if ~exist('klist','var')
    klist = getinput('list stations to search for sensor numbers (vector)');
end

st = {'Temperature','Conductivity','Oxygen'};
sa = {'temp','cond','oxygen'};

otfile = fullfile(mgetdir(M_CTD)); sg = struct();
clear sg
for sno = 1:length(st)

for kloop = klist
    stn = kloop; stnlocal = stn;
    scriptname = 'mctd_01'; oopt = 'cnvfilename'; get_cropt
    h = m_read_header(cnvfile);
    iisns = strfind(h.comment,'<SerialNumber>');
    iisnn = strfind(h.comment,'<\SerialNumber>');

    for sno = 1:length(st)
        ii = strfind(h.comment,['<' st{sno} 'Sensor']);
    
        if ~isempty(ii)
            ii1 = min(iisns(iisns>ii(1)))+14:min(iisne(iisne>ii(1)))-1; 
sn1 = str2double(h.comment(ii1));
sg.([sa{sno} '1']) = [stnlocal sn1];
            if length(ii)>1
                ii2 = min(iisns(iisns>ii(2)))+14:min(iisne(iisne>ii(2)))-1;
sn2 = str2double(h.comment(ii2));
            end
        end

    end
end
