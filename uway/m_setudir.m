% get the list of mexec abbreviations and directories for the subset of the underway
% streams listed in mtechsas which are available and linked to (so, this relies on
% sedexec_startall or techsas_linkscript running)
%
% save this list in m_udirs.m and make directories if necessary
%
% this script will be called by m_setup if m_udirs.m is not found with the current cruise name
% at the top
%
% subsequently, m_udirs will be used and it is not necessary to rerun this script unless
% you edit mtnames/msnames, or new streams become available (e.g. the swath comes online
% not right at the start of a cruise)
%
% you should comment out any rows which correspond to the same techsas/scs stream in mtnames/msnames
% for the ship you are on (e.g. for cook, comment out either ea600m or sim, because both are
% associated with 'EA600-EA600_JC1.EA600')

% first the names and directories list
% several short names may correspond to the same data directories, but it is not likely that
% more than 1-2 (besides quality message streams) will be in use on a given ship/cruise


%%%%%% list streams with directories %%%%%%%

%nav streams
udirsn = {
     'adupos'              'nav/adu'
	 'adu5pat'             'nav/adu'
	 'ashtech'             'nav/ash'
	 'attsea'              'nav/seaatt'
	 'attseaaux'           'nav/seaatt'
     'attphins'            'nav/phinsatt'
     'attposmv'            'nav/posmvatt'
	 'cnav'                'nav/cnav'
	 'satinfocnav'         'nav/cnav'
	 'dps116'              'nav/dps'
     'posdps'              'nav/dps'
	 'satinfodps'          'nav/dps'
	 'dps116_regen'        'nav/dps'
	 'furuno_gga'          'nav/furuno'
	 'furuno_gll'          'nav/furuno'
	 'furuno_rmc'          'nav/furuno'
	 'furuno_vtg'          'nav/furuno'
	 'furuno_zda'          'nav/furuno'
	 'glonass'             'nav/glonass'
     'gps_g12'             'nav/gps'
	 'gps4000'             'nav/gps'
	 'satinfo4000'         'nav/gps'
	 'gpsfugro'            'nav/gps'
	 'satinfofugro'        'nav/gps'
	 'gps1'                'nav/gps'
	 'gps2'                'nav/gps'
     'gyropmv'             'nav/gyropmv'
	 'gyro_s'              'nav/gyros'
	 'posmvpos'            'nav/posmvpos'
	 'satinfoposmv'        'nav/posmvpos'
	 'posmvpos_regen'      'nav/posmvpos'
	 'posmvtss'            'nav/posmvtss'
	 'seapos'              'nav/seapos'
	 'satinfosea'          'nav/seapos'
     'posranger'           'nav/ranger'
     'satinforanger'       'nav/ranger'
	 'seapos_regen'        'nav/seapos'
	 'seatex_gga'          'nav/seatex'
	 'seatex_gll'          'nav/seatex'
	 'seatex_hdt'          'nav/seahead'
	 'seatex_psxn'         'nav/seatex'
	 'seatex_vtg'          'nav/seatex'
	 'seatex_zda'          'nav/seatex'
	 'tsshrp'	       'nav/tsshrp'
   	 'dopplerlog'      'nav/log'
	 'chf'             'nav/log'
	 'emlog_vlw'       'nav/log'
	 'emlog_vhw'       'nav/log'
	 'log_chf'         'nav/log'
	 'log_skip'        'nav/log'
        };

    %others
udirso = {
     'surflight'       'met/surflight'
	 'surflight_regen' 'met/surflight_regen'
     'met_light'       'met/surflight'
	 'surfmet'         'met/surfmet'
%	 'surfmet'         'met/anemom'
	 'anemometer'         'met/anemom'
	 'surfmet_regen'   'met/surfmet'
	 'met_tsg'         'ocl/tsg'
	 'surftsg'         'ocl/tsg'
	 'oceanlogger'     'ocl/tsg'
	 'ocl'             'ocl/tsg'
	 'SBE45'           'ocl/tsg'
	 'tsg'             'ocl/tsg'
%	 'surftsg'         'ocl/tsg'
	 'surftsg_regen'   'ocl/tsg'
	 'sim'             'bathy/sim'
	 'em120'           'bathy/em120'
	 'em122'           'bathy/em120'
	 'gravity'	       'uother/gravity'
	 'mag'		       'uother/mag'
	 'seaspy'	       'uother/mag'
	 'netmonitor'      'uother/netmonitor'
	 'usbpos'	       'uother/usbl'
	 'satinfousb'      'uother/usbl'
	 'usbl'		       'uother/usbl'
	 'usbl_gga'	       'uother/usbl'
	 'winch'	       'uother/winch'
        };

udirs = [udirsn; udirso]; clear udirsn udirso
for no = 1:size(udirs,1)
   udirs{no, 3} = ['M_' upper(udirs{no,1})];
end
udirs = udirs(:, [1 3 2]); %mexec short name, M_ABBREV, directory


%%%%%%% test that underway streams present match what's expected %%%%%%%
%%%%%%% and keep list of the expected streams that are found %%%%%%%
%%%%%%% and which directories they go with %%%%%%%

switch(MEXEC_G.Mshipdatasystem)
    case 'techsas'
        % based on m_check_mtnames by bak on jc184 4 july 2019 uhdas trials
        matlist = mtnames; am = matlist(:,3); % mtnames list
        as = mtgetstreams; % list of all streams found
        f = 'mtnames';
    case 'scs'
        matlist = msnames; am = matlist(:,3); %msnames list
        as = msgetstreams; %list of all streams found
        f = 'msnames';
end

fprintf(2,'\n\n%s\n\n',['The following ' MEXEC_G.Mshipdatasystem ' stream names are not identified in ' f])
for kl = 1:length(as)
    if sum(strcmp(as{kl},am))==0
        fprintf(1,'%s\n',as{kl}); 
    end
end
fprintf(1,'\n%s\n\n\n\n','End of list')

fprintf(1,'%s\n\n',['The following ' f ' stream names are not found in ' MEXEC_G.Mshipdatasystem])
iim = zeros(length(am),1);
for kl = 1:length(am)
    if sum(strcmp(am{kl},as))==0
        fprintf(1,'%s\n',am{kl}); 
    else
        iid = find(strcmp(matlist{kl,1}, udirs(:,1)));
        if length(iid)>0; iim(kl) = iid; end
    end
end
fprintf(1,'\n%s\n\n','End of list')
matlist(iim==0,:) = []; iim(iim==0) = [];



%%%%%%% write m_udirs function using available underway streams %%%%%%%
%%%%%%% and make directories as necessary %%%%%%%

fid = fopen([MEXEC.mexec_processing_scripts '/uway/m_udirs.m'], 'w');
fprintf(fid, '%s\n\n', 'function [udirs, udcruise] = m_udirs();');
fprintf(fid, 'udcruise = ''%s'';\n', MEXEC_G.MSCRIPT_CRUISE_STRING);
fprintf(fid, '%s\n', 'udirs = {');

switch MEXEC_G.Mshipdatasystem
   case 'techsas'
      fn1 = '*'; fn2 = '';
   case 'scs'
      fn1 = ''; fn2 = '.ACO';
end

for sno = 1:size(matlist,1)
    iid = iim(sno);
    fprintf(fid, '''%s''    ''%s''    ''%s''    ''%s'';\n', udirs{iid,1}, udirs{iid,2}, udirs{iid,3}, matlist{sno,3});
    if ~exist([MEXEC_G.MEXEC_DATA_ROOT '/' udirs{iid,2}], 'dir')
        unix(['mkdir -p ' MEXEC_G.MEXEC_DATA_ROOT '/' udirs{iid,3}]);
    end
end

%wrap up
fprintf(fid, '%s\n', '};');
fclose(fid);
addpath([MEXEC.mexec_processing_scripts])
