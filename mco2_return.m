% mco2_01: read in the bottle co2 data
%
% Use: mco2_01        and then respond with station number, or for station 16
%      stn = 16; mco2_01;

scriptname = 'mco2_return';

% BAK on jc032; data from Ute; 3 files and structures contain data from all
% stations
% % % % % if exist('stn','var')
% % % % %     m = ['Running script ' scriptname ' on station ' sprintf('%03d',stn)];
% % % % %     fprintf(MEXEC_A.Mfidterm,'%s\n',m)
% % % % % else
% % % % %     stn = input('type stn number ');
% % % % % end
% % % % % stn_string = sprintf('%03d',stn);
% % % % % % clear stn % so that it doesn't persist

% resolve root directories for various file types
root_co2 = mgetdir('M_BOT_CO2');
root_ctd = mgetdir('M_CTD');
root_co2 = [root_co2 '/100219'];

prefix1 = ['co2_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
prefix2 = ['co2_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];

samname = [root_ctd '/' 'sam_' MEXEC_G.MSCRIPT_CRUISE_STRING '_all'];
dcsname = [root_ctd '/' 'dcs_' MEXEC_G.MSCRIPT_CRUISE_STRING '_all_pos'];
% stn_off = 1000; % jc032
stn_off = 0; % di346

clear fn

% fn{1} = 'Hardy_data.mat'; % di346 no Hardy
fn{1} = 'Laurel_data.mat';
fn{2} = 'Lucy_data.mat';

% time = [];
insampnum = [];
instn = [];
inalk = [];
inalk_flag = [];
indic = [];
indic_flag  = [];

[dbot hbot] = mload(samname,'/');
[dctd hctd] = mload(dcsname,'/');
lat = nan+ones(200,1);
lon = lat;
fprintf(MEXEC_A.Mfidterm,'%s\n','reading headers')
for ks = 1:200
    dcsfn = ['../dcs_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' sprintf('%03d',ks) '.nc'];
    if exist(dcsfn,'file') == 2
        hdcs = m_read_header(dcsfn);
        lat(ks) = hdcs.latitude;
        lon(ks) = hdcs.longitude;
    end
end

for kf = 1:length(fn)
    infile = [root_co2 '/' fn{kf}];
    d = load(infile);
    indata = d.data;
    % temporary fix
    if kf == 3; indata.stn(1989) = 999; end
    if kf == 1; indata.stn(357:364) = 999; end
    dims = size(indata.samplename);
    indata.instname = repmat(fn(kf),dims); % save instrument file name from which data came
    nsamp = length(indata.date); % number of samples in this file
    insampnum = (indata.stn-stn_off)*100+indata.nisk;
    instation = indata.stn-stn_off;
    indata.CTD_press = nan+indata.CTD_temp;
    indata.stn_time_on_deck = nan+indata.CTD_temp;
    for ks = 1:nsamp
%         if (instation(ks) < 1 | instation(ks) > 999); continue; end % not
%         a bottle sample; % jc032 junks are 999 and standards are 900,
%         both of which are < 1 after subtracting 1000. di346 stations are
%         1 to 200 (or whatever max stn num is)
        if (instation(ks) < 1 | instation(ks) > 800); continue; end % not a bottle sample % di346 standards and junks are 900 and 999
        stnstr = sprintf('%03d',instation(ks));
        kstnindex = find(dctd.statnum == instation(ks));
        kbot = find(dbot.sampnum == insampnum(ks));
        indata.CTD_phosphate(ks) = dbot.phos(kbot);
        indata.CTD_silicate(ks) = dbot.silc(kbot);
        indata.CTD_nitrate(ks) = dbot.totnit(kbot);
        indata.CTD_temp(ks) = dbot.utemp(kbot);
        indata.CTD_salinity(ks) = dbot.upsal(kbot);
        indata.CTD_press(ks) = dbot.upress(kbot);
        indata.stn_lat(ks) = lat(instation(ks));
        indata.stn_lon(ks) = lon(instation(ks));
        indata.depth(ks) = sw_dpth(indata.CTD_press(ks),indata.stn_lat(ks));
        if isempty(kstnindex); continue; end
        indata.stn_time_on_deck(ks) = datenum(hctd.data_time_origin) + dctd.time_end(kstnindex(1))/86400;
    end
    data = indata;
    otf = [root_co2 '/x' fn{kf}];
    save(otf,'data');
end
