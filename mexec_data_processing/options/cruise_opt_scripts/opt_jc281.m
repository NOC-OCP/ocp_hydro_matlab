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
                    case 'rvdas_database'
                RVDAS.jsondir = ''; %no "original" on shared drive, copy is already in cruise/data/rvdas/json_files
                RVDAS.loginfile = '/data/pstar/plocal/rvdas_addr'; %contains credentials, address, and database, e.g. postgresql://user:passwd@ip.ad.re.ss/DY186
        end

    %from here: temporary for training on dy180 data!    
    case 'ctd_proc'
        switch opt2
            case 'redoctm'
                redoctm = 1;
            case 'cnvfilename'
                cnvfile = fullfile(cdir,sprintf('%s_CTD%03dS.cnv','DY180',stn)); %try stainless first
                if ~exist(cnvfile,'file')
                    cnvfile = fullfile(cdir,sprintf('%s_CTD%03dT.cnv','DY180',stn)); %try Ti
                end
        end

            case 'nisk_proc'
        switch opt2
            case 'blfilename'
                blinfile = fullfile(root_botraw,sprintf('%s_CTD%03dS.bl', 'DY180', stn));
                if ~exist(blinfile,'file')
                    blinfile = fullfile(root_botraw,sprintf('%s_CTD%03dT.bl', 'DY180',stn));
                end
        end

    case 'ladcp_proc'
        cfg.uppat = sprintf('%s_LADCP_CTD%03dS*.000','DY180',stnlocal);
        cfg.dnpat = sprintf('%s_LADCP_CTD%03dM*.000','DY180',stnlocal);
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

end