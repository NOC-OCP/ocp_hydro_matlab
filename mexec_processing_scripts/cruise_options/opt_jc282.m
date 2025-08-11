switch opt1
    case 'setup'
        switch opt2
            case 'time_origin'
                MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [2025 1 1 0 0 0];
            case 'mdirlist' %temporary
                MEXEC_G.MDIRLIST{strcmp('M_BOT_SAL',MEXEC_G.MDIRLIST(:,1)),2} = fullfile('ctd','BOTTLE_SAL','AUTOSAL','Autosal Data');
        end


    case 'ctd_proc'
        switch opt2
            case 'redoctm'
                redoctm = 1;
            case 'cnvfilename'
                cnvfile = fullfile(cdir,sprintf('%s_CTD%03d.cnv',upper(mcruise),stn));
        end

            case 'nisk_proc'
        switch opt2
            case 'blfilename'
                blinfile = fullfile(root_botraw,sprintf('%s_CTD%03d.bl', upper(mcruise), stn));
        end

    case 'ladcp_proc'
        cfg.uppat = sprintf('%s_LADCP_CTD%03dS*.000',upper(mcruise),stnlocal);
        cfg.dnpat = sprintf('%s_LADCP_CTD%03dM*.000',upper(mcruise),stnlocal);
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
                salfiles = dir(fullfile(root_sal,'DY180*.csv')); 
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
                ofiles = dir(fullfile(root_oxy,'DY180_oxy_CTD*.xls'));
                %hcpat = {'Niskin';'Bottle'};
                %chrows = 1:2;
                %chunits = 3;
                hcpat = {'Bottle';'Number'}; %Flag is on 2nd line so start here
                chrows = 1;
                chunits = 2;
            case 'oxy_parse'
                calcoxy = 1;
                labT = [];
                varmap.statnum = {'number'};
                varmap.position = {'bottle_number'};
                varmap.vol_blank = {'titre_mls'};
                varmap.vol_std = {'vol_mls'};
                varmap.vol_titre_std = {'titre_mls_1'};
                varmap.fix_temp = {'temp_c'};
                varmap.bot_vol_tfix = {'at_tfix_mls'};
                varmap.sample_titre = {'titre_mls_2'};
            case 'oxy_flags'

        end

	    case 'outputs'
	    switch opt2
	    case 'exch'
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
datas.Salinity.comment = '(SSW batch P???)';
end

	case 'batchactions'
		switch opt2
			case 'output_for_others'
system('rsync -au /data/pstar/cruise/data/collected_files/ /mnt/public/JC282/CTD/collected_files/')
		end

end
