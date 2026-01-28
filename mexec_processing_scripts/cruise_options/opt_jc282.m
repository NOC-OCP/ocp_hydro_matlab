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
            case 'rawedit_auto'
                if stn==17
                    co.badscan.cond1 = [42700 54000]; co.badscan.temp1 = co.badscan.cond1; %harder to see in temp but on zoom problem is there too
                    co.badscan.oxygen_sbe1 = [42600 inf];
                elseif stn==8
                    co.badscan.cond1 = [74500 85000]; co.badscan.temp1 = co.badscan.cond1;
                    co.badscan.oxygen_sbe1 = [74000 90000];
                end
            case 'ctd_cals' % -----> to apply calibration
                co.docal.temp = 1;
                co.docal.cond = 1;
                co.docal.oxygen = 1;
                co.calstr.temp.sn35838.jc282 = 'dcal.temp = d0.temp - 5e-4 -5e-6*d0.statnum;';
                co.calstr.temp.sn35838.msg = 'temp s/n 35838 adjusted based on trend relative to 88 SBE35 measurements with low background gradient/variance';
                co.calstr.temp.sn34116.jc282 = 'dcal.temp = d0.temp - 7.9e-4 -1.9e-5*d0.statnum;';
                co.calstr.temp.sn34116.msg = 'temp s/n 34116 adjusted based on trend relative to 86 SBE35 measurements with low background gradient/variance';
                co.calstr.cond.sn43258.jc282 = 'dcal.cond = d0.cond.*(1+(interp1([0 3600],[-2.5e-3 -5e-3],d0.press))/35);';
                co.calstr.cond.sn43258.msg = 'pressure-dependent factor applied to cond s/n 43258 based on 46 bottle salinity measurements with low background gradient/variance';
                co.calstr.cond.sn44143.jc282 = 'dcal.cond = d0.cond.*(1+interp1([0 3600],[-4e-3 -7e-3],d0.press)/35);';
                co.calstr.cond.sn44143.msg = 'pressure-dependent factor applied to cond s/n 44143 based on 47 bottle salinity measurements with low background gradient/variance';
                co.calstr.oxygen.sn430709.jc282 = 'dcal.oxygen = d0.oxygen.*interp1([0 3600],[1.04 1.075],d0.press)+0.58;';
                co.calstr.oxygen.sn430709.msg = 'pressure-dependent factor applied to oxygen s/n 430709 based on 194 bottle measurements';
                co.calstr.oxygen.sn432818.jc282 = 'dcal.oxygen = d0.oxygen.*interp1([0 3600],[1.055 1.085],d0.press);';
                co.calstr.oxygen.sn432818.msg = 'pressure-dependent factor applied to oxygen s/n 432818 based on 209 bottle measurements';
            case 'doloopedit'
                doloopedit = 1;
            case 'sensor_choice' % -----> if we choose to use sensor 2 instead of sensor 1 for some or all of the station
                s_choice = 1;
                o_choice = 1;
                if ismember(stn, [8 17])
                    s_choice = 2;
                    o_choice = 2;
                end
        end

    case 'sbe35'
        switch opt2
            case 'sbe35file'
                sbe35file = 'JC282_CTD*.asc';

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
                    case 17
                        niskin_flag(position==1) = 4; %replicate bottle oxys agree but not with CTD, probably niskin
                    case 37
                        niskin_flag(position==18) = 4;
                    case 39
                        niskin_flag(position==17) = 4;
                        niskin_flag(position==19) = 4;
                    case 41
                        niskin_flag(position==9) = 4; %bottle sal and oxy are too far off CTD, probably niskin
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
        check_sal = 0;
        check_oxy = 0;
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
                ds_sal.flag(ismember(ds_sal.sampnum,[601 4109])) = 3;
        end

    case 'botoxy'
        switch opt2
            case 'oxy_files'
		    %***need to change filename form for JC282
                ofiles = dir(fullfile(root_oxy,'JC282_oxy_CTD*.xls*'));
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
                       1701 3 3 9; ...
                       3809 3 9 9; ...
                       ];
                                [~,ifl,id] = intersect(flr(:,1),d.sampnum);
                d.botoxya_flag(id) = max(d.botoxya_flag(id),flr(ifl,2));
                d.botoxyb_flag(id) = max(d.botoxyb_flag(id),flr(ifl,3));
                d.botoxyc_flag(id) = max(d.botoxyc_flag(id),flr(ifl,4));
        end

	    case 'outputs'
	    switch opt2
	    case 'exch'
		    %fill in/correct details here
	    nsta_nros = [30 24]; %number of stations included in bottle file, number of places on rosette (>= number of bottles on rosette)
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
datas.CTD.comment = 'CTDPRS; CTDTMP; CTDSAL; CTDOXY are all good. CTDTMP adjusted to SBE35. CTDSAL; CTDOXY calibrated with bottle samples. CTDFLUOR is not bottle-calibrated.';
datas.Salinity.who = 'D.G. Evans (NOC)';
datas.Salinity.status = 'final';
datas.Salinity.comment = '(SSW batch P168)';
datas.Oxygen.who = '';
datas.Oxygen.status = 'final';
datas.Oxygen.comment = '';
end

	case 'batchactions'
		switch opt2
			case 'output_for_others'
system('rsync -au /data/pstar/cruise/data/collected_files/ /mnt/public/JC282/CTD/collected_files/')
		end

end
