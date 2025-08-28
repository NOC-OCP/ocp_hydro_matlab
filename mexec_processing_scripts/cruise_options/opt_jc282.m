switch opt1
    case 'setup'
        switch opt2
            case 'time_origin'
                MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [2025 1 1 0 0 0];
            case 'mdirlist' %temporary
                MEXEC_G.MDIRLIST{strcmp('M_BOT_SAL',MEXEC_G.MDIRLIST(:,1)),2} = fullfile('ctd','BOTTLE_SAL','AUTOSAL','Autosal Data');
        end

	case 'ship'
	switch opt2
		            case 'datasys_best'
                default_navstream = 'posmv_gpgga';
                default_hedstream = 'posmv_pashr';
                default_attstream = 'posmv_pashr';
		case 'rvdas_database'
		RVDAS.jsondir = ''; %look in cruise/data/json_files
		RVDAS.loginfile = '/data/pstar/plocal/rvdas_addr';
	end

    case 'ctd_proc'
        switch opt2
            case 'redoctm'
                redoctm = 1;
            case 'cnvfilename'
                cnvfile = fullfile(cdir,sprintf('%s_CTD%03d.cnv',upper(mcruise),stn));
            case 'sensor_choice' % -----> if we choose to use sensor 2 instead of sensor 1 for some or all of the stations
                s_choice = 1; 
                o_choice = 1;
                if ismember(stn, [17 19])
                    s_choice = 2;
                    o_choice = 2;
                end
        end

             case 'nisk_proc'
         switch opt2
             case 'blfilename'
                 blinfile = fullfile(root_botraw,sprintf('%s_CTD%03d.bl', upper(mcruise), stn));
            case 'botflags'
                %k_empty = find(niskin_number == -9); % positions with no bottle (cast 2) -- though these are excluded by msbe35_to_sam anyway so these lines may not be necessary
                %[~,kposempty,~] = intersect(position,k_empty); % index of empty places in set of positions that have appeared in .bl file
                %niskin_flag(kposempty) = 9;
                switch stnlocal
                    case 2
                        niskin_flag(position==14) = 4;
                    case 6
                        niskin_flag(position==9) = 4;
                    case 7
                        niskin_flag(position==7) = 3;
                        niskin_flag(position==17) = 3;
                    case 9
                        niskin_flag(position==5) = 3;
                        niskin_flag(position==9) = 4;
                    case 13
                        niskin_flag(position==5) = 3;
                        niskin_flag(position==15) = 4;
                   otherwise
                end
        end

    	case 'ladcp_proc'
        % cfg.uppat = sprintf('%s_LADCP_CTD%03dS*.000',upper(mcruise),stnlocal);
        % cfg.dnpat = sprintf('%s_LADCP_CTD%03dM*.000',upper(mcruise),stnlocal);
        cfg.uppat = sprintf('%s_CTD%03dS*.000',upper(mcruise),stnlocal);
        cfg.dnpat = sprintf('%s_CTD%03dM*.000',upper(mcruise),stnlocal);
        cfg.rawdir = fullfile(mgetdir('ladcp'),'rawdata');
        cfg.p.vlim = 4; %rather than ambiguity vel, match this to LV

    case 'check_sams'
        %make this display-dependent? (or session-dependent?)
        check_sal = 1;
        check_oxy = 1;
        check_sbe35 = 0;

    case 'botpsal'
        switch opt2
            case 'sal_files'                
   %***need to change filename form for JC282
       		    salfiles = dir(fullfile(root_sal,'JC282*.csv')); 
            case 'sal_parse'
                cellT = 21;
                ssw_k15 = 0.99993;
                ssw_batch = 'P168';
            case 'sal_calc'
                salin_off = -1.5e-5; %constant
            case 'sal_flags'

        end

    case 'botoxy'
        switch opt2
            case 'oxy_files'
		    %***need to change filename form for JC282
                ofiles = dir(fullfile(root_oxy,'JC282_oxy_CTD*.xls'));
                %hcpat = {'Niskin';'Bottle'};
                %chrows = 1:2;
                %chunits = 3;
                hcpat = {'Bottle';'Number'}; %Flag is on 2nd line so start here
                chrows = 1;
                chunits = 2;
            case 'oxy_parse'
                calcoxy = 1;
                labT = [];
		%***need to check column headers in spreadsheet and how they are parsed by readtable
                varmap.statnum = {'number'};
                varmap.position = {'bottle_number'};
                varmap.vol_blank = {'titre_mls'};
                varmap.vol_std = {'vol_mls'};
                varmap.vol_titre_std = {'titre_mls_1'};
                varmap.fix_temp = {'temp_c'};
                varmap.bot_vol_tfix = {'at_tfix_mls'};
                varmap.sample_titre = {'titre_mls_2'};
            case 'oxy_flags'
                flr = [103 4 4 9; ...
                       119 2 4 9; ...
                       205 4 9 9; ...
                       207 4 9 9; ...
                       301 4 4 9; ...
                       903 4 2 9; ...
                       910 4 9 9; ...
                       ];
        end

	    case 'outputs'
	    switch opt2
	    case 'exch'
		    %fill in/correct details here
	    nsta_nros = [NaN 24];
shipcode = '740H'; %James Cook
dates = ['20250809'; '20250831'];
submitter = 'OCPNOCDGE'; %group institution person
crname = 'JC282; ReBELs 2';
reg = 'Labrador Sea; Subpolar North Atlantic';
cs = 'F. Carvalho (NOC)';
acknowl = 'Supported by grant from the UK Natural Environment Research Council';
dept = {'COR'; 'water depth from CTDPRS + CTD altimeter range to bottom'}; %speed of sound corrected if relevant
datas.CTD.who = 'D.G. Evans (NOC)';
datas.CTD.status = 'preliminary';
datas.Salinity.who = 'D.G. Evans (NOC)';
datas.Salinity.status = 'preliminary';
datas.Salinity.comment = '(SSW batch P???)' %***need to fill in standard seawater batch number
%***add datas.Oxygen (like datas.Salinity)
end

	case 'batchactions'
		switch opt2
			case 'output_for_others'
system('rsync -au /data/pstar/cruise/data/collected_files/ /mnt/public/JC282/CTD/collected_files/')
		end

end
