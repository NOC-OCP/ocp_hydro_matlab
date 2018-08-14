% mcfc_03: create matlab file with merged cfc and physics bottle data
% bak jc069 5 feb 2012

scriptname = 'mcfc_03';
minit
mdocshow(scriptname, ['add documentation string for ' scriptname])

% now edit to do all stations

% % if exist('stn','var')
% %     m = ['Running script ' scriptname ' on station ' sprintf('%03d',stn)];
% %     fprintf(MEXEC_A.Mfidterm,'%s\n',m)
% % else
% %     stn = input('type stn number ');
% % end
% % stn_string = sprintf('%03d',stn);
% % stnlocal = stn;
% % clear stn % so that it doesn't persist

root_ctd = mgetdir('M_CTD');
otfile = [MEXEC.mstar_root '/data/pickup/' 'cfc_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' 'all'];

ncols = 30;

varnames = cell(1,ncols);

varnames{1} = 'station_number';
varnames{2} = 'position';
varnames{3} = 'ctd_pressure';
varnames{4} = 'ctd_potemp';
varnames{5} = 'ctd_psal';
varnames{6} = 'ctd_temp_insitu';
varnames{25} = 'ctd_depth'; % moved from 15 so sf6 can go in cols 15:16
varnames{17} = 'latitude';
varnames{18} = 'longitude';
varnames{19} = 'sigma0';
varnames{20} = 'gamma_n';
varnames{21} = 'sigma1';
varnames{22} = 'sigma2';
varnames{23} = 'time_bottom';
varnames{24} = 'bottle_qc_flag';

cfc_summary = [];
otnull = nan+ones(24,ncols);

for kstn = 1:900
    stn_string = sprintf('%03d',kstn);

    prefix1 = ['sam_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
    prefix2 = ['ctd_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
    prefix3 = ['dcs_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
    infile1 = [ prefix1 stn_string];
    infile2 = [ prefix2 stn_string '_2db'];
    infile3 = [ prefix3 stn_string];

    if exist(m_add_nc(infile1),'file') ~= 2; continue; end
    if exist(m_add_nc(infile2),'file') ~= 2; continue; end
    if exist(m_add_nc(infile3),'file') ~= 2; continue; end

    [dsam hsam] = mload(infile1,'/');
    [dctd hctd] = mload(infile2,'/');
    [ddcs hdcs] = mload(infile3,'/');
    
    if length(find(~isnan(dsam.upress))) == 0; continue; end % no finite bottle depths


    otdata = otnull;

    sigma0 = sw_pden(dsam.upsal,dsam.utemp,dsam.upress,0)-1000;
    sigma1 = sw_pden(dsam.upsal,dsam.utemp,dsam.upress,1000)-1000;
    sigma2 = sw_pden(dsam.upsal,dsam.utemp,dsam.upress,2000)-1000;
    gamman = gamma_n(dsam.upsal,dsam.utemp,dsam.upress,hctd.longitude,hctd.latitude);
    timebot = datenum(hdcs.data_time_origin) + ddcs.time_bot/86400;
    depth = sw_dpth(dsam.upress,hctd.latitude);

    otdata(:,1) = dsam.statnum;
    otdata(:,2) = dsam.position;
    otdata(:,3) = dsam.upress;
    otdata(:,4) = dsam.upotemp;
    otdata(:,5) = dsam.upsal;
    otdata(:,6) = dsam.utemp;
    otdata(:,25) = depth;
    otdata(:,17) = hctd.latitude;
    otdata(:,18) = hctd.longitude;
    otdata(:,19) = sigma0;
    otdata(:,20) = gamman;
    otdata(:,21) = sigma1;
    otdata(:,22) = sigma2;
    otdata(:,23) = timebot;
    otdata(:,24) = dsam.bottle_qc_flag;
    
    cfc_summary = [cfc_summary; otdata];
end


cmd = ['save ' otfile ' cfc_summary varnames']; eval(cmd)
msg = ['Output file was ' otfile];
fprintf(MEXEC_A.Mfidterm,'%s\n',msg);
